package preview

import (
	"bytes"
	"context"
	"encoding/json"
	"errors"
	"fmt"
	"image"
	"math"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
	"strings"
	"time"
)

const (
	probeTimeout        = 30 * time.Second
	frameTimeout        = 2 * time.Minute
	videoFrameOffset    = 0.1
	inputDescriptor     = "/dev/fd/3"
	cpuDecoding         = "none"
	maxErrorOutputBytes = 300
	tileGridGroup       = "Tile Grid"
	toneMapFilter       = "zscale=t=linear:npl=100,format=gbrpf32le,zscale=p=bt709,tonemap=tonemap=hable:desat=0,zscale=t=bt709:m=bt709:r=tv,format=yuv420p"
)

var highDynamicRangeTransfers = map[string]bool{"smpte2084": true, "arib-std-b67": true}

type FFmpegOptions struct {
	Path          string
	HWAccel       string
	HWAccelDevice string
}

type ffmpegRenderer struct {
	ffmpegPath    string
	ffprobePath   string
	hwaccel       string
	hwaccelDevice string
	canToneMap    bool
}

func newFFmpegRenderer(options FFmpegOptions) ffmpegRenderer {
	ffmpegPath, err := exec.LookPath(options.Path)
	if err != nil {
		return ffmpegRenderer{}
	}
	ffprobePath, err := exec.LookPath(filepath.Join(filepath.Dir(ffmpegPath), "ffprobe"))
	if err != nil {
		return ffmpegRenderer{}
	}
	renderer := ffmpegRenderer{
		ffmpegPath:    ffmpegPath,
		ffprobePath:   ffprobePath,
		hwaccel:       options.HWAccel,
		hwaccelDevice: options.HWAccelDevice,
	}
	filters, err := exec.Command(ffmpegPath, "-hide_banner", "-filters").Output()
	renderer.canToneMap = err == nil && bytes.Contains(filters, []byte(" zscale ")) && bytes.Contains(filters, []byte(" tonemap "))
	if !renderer.canToneMap {
		logger.Info("ffmpeg has no zscale or tonemap filter; HDR previews will look washed out", "ffmpeg", ffmpegPath)
	}
	return renderer
}

func (r ffmpegRenderer) installed() bool { return r.ffmpegPath != "" }

func (r ffmpegRenderer) renderVideo(ctx context.Context, file *os.File, maxEdge int) (decodedImage, error) {
	probed, err := r.probe(ctx, file)
	if err != nil {
		return decodedImage{}, err
	}
	shown, err := probed.shownPicture()
	if err != nil {
		return decodedImage{}, err
	}
	decoded := decodedImage{width: shown.width, height: shown.height, orientation: orientationNormal}
	decoded.duration = probed.duration()
	decoded.takenAt = probed.recordedAt()
	return r.renderFrame(ctx, file, shown, decoded, decoded.duration*videoFrameOffset, maxEdge)
}

func (r ffmpegRenderer) renderStillImage(ctx context.Context, file *os.File, maxEdge int) (decodedImage, error) {
	probed, err := r.probe(ctx, file)
	if err != nil {
		return decodedImage{}, err
	}
	shown, err := probed.shownPicture()
	if err != nil {
		return decodedImage{}, err
	}
	decoded := decodedImage{width: shown.width, height: shown.height, orientation: orientationNormal}
	if metadata := findExif(file); metadata != nil {
		decoded.applyExif(metadata, shown.rotation == 0)
		decoded.swapSidewaysDimensions()
	}
	return r.renderFrame(ctx, file, shown, decoded, 0, maxEdge)
}

func (r ffmpegRenderer) renderFrame(ctx context.Context, file *os.File, shown picture, decoded decodedImage, offset float64, maxEdge int) (decodedImage, error) {
	filterGraph := shown.filterGraph + scaleFilter(maxEdge)
	if r.canToneMap && highDynamicRangeTransfers[shown.transfer] {
		filterGraph += "," + toneMapFilter
	}
	var failures []error
	for _, hwaccel := range r.hwaccelAttempts() {
		for _, seconds := range []float64{offset, 0} {
			frame, err := r.extractFrame(ctx, file, hwaccel, seconds, filterGraph+"[out]")
			if err == nil {
				decoded.image = frame
				return decoded, nil
			}
			failures = append(failures, fmt.Errorf("hwaccel %s at %.1fs: %w", hwaccel, seconds, err))
			if seconds == 0 {
				break
			}
		}
	}
	return decoded, errors.Join(failures...)
}

func scaleFilter(maxEdge int) string {
	edge := strconv.Itoa(maxEdge)
	return "scale=w='min(iw," + edge + ")':h='min(ih," + edge + ")':force_original_aspect_ratio=decrease"
}

func (r ffmpegRenderer) hwaccelAttempts() []string {
	if r.hwaccel == "" || r.hwaccel == cpuDecoding {
		return []string{cpuDecoding}
	}
	return []string{r.hwaccel, cpuDecoding}
}

func (r ffmpegRenderer) extractFrame(ctx context.Context, file *os.File, hwaccel string, seconds float64, filterGraph string) (image.Image, error) {
	ctx, cancel := context.WithTimeout(ctx, frameTimeout)
	defer cancel()
	args := []string{"-nostdin", "-hide_banner", "-loglevel", "error"}
	if hwaccel != cpuDecoding {
		args = append(args, "-hwaccel", hwaccel)
		if r.hwaccelDevice != "" {
			args = append(args, "-hwaccel_device", r.hwaccelDevice)
		}
	}
	args = append(args,
		"-ss", strconv.FormatFloat(seconds, 'f', 3, 64),
		"-i", inputDescriptor,
		"-filter_complex", filterGraph,
		"-map", "[out]",
		"-frames:v", "1",
		"-f", "image2pipe", "-c:v", "png", "pipe:1",
	)
	output, err := runWithFile(ctx, file, r.ffmpegPath, args...)
	if err != nil {
		return nil, err
	}
	if len(output) == 0 {
		return nil, errors.New("no frame")
	}
	frame, _, err := image.Decode(bytes.NewReader(output))
	return frame, err
}

type sideData struct {
	Rotation float64 `json:"rotation"`
}

type probeStream struct {
	Index         int               `json:"index"`
	CodecType     string            `json:"codec_type"`
	Width         int               `json:"width"`
	Height        int               `json:"height"`
	ColorTransfer string            `json:"color_transfer"`
	SideDataList  []sideData        `json:"side_data_list"`
	Disposition   map[string]int    `json:"disposition"`
	Tags          map[string]string `json:"tags"`
}

type probeTile struct {
	StreamIndex int `json:"stream_index"`
	X           int `json:"tile_horizontal_offset"`
	Y           int `json:"tile_vertical_offset"`
}

type probeTileGrid struct {
	Width            int         `json:"width"`
	Height           int         `json:"height"`
	HorizontalOffset int         `json:"horizontal_offset"`
	VerticalOffset   int         `json:"vertical_offset"`
	SideDataList     []sideData  `json:"side_data_list"`
	Tiles            []probeTile `json:"subcomponents"`
}

type probeStreamGroup struct {
	Type       string          `json:"type"`
	Components []probeTileGrid `json:"components"`
}

type probeResult struct {
	Streams      []probeStream      `json:"streams"`
	StreamGroups []probeStreamGroup `json:"stream_groups"`
	Format       struct {
		Duration string            `json:"duration"`
		Tags     map[string]string `json:"tags"`
	} `json:"format"`
}

func (r ffmpegRenderer) probe(ctx context.Context, file *os.File) (probeResult, error) {
	ctx, cancel := context.WithTimeout(ctx, probeTimeout)
	defer cancel()
	output, err := runWithFile(ctx, file, r.ffprobePath, "-hide_banner", "-loglevel", "error", "-print_format", "json",
		"-show_format", "-show_streams", "-show_stream_groups", inputDescriptor)
	if err != nil {
		return probeResult{}, err
	}
	var probed probeResult
	if err := json.Unmarshal(output, &probed); err != nil {
		return probeResult{}, fmt.Errorf("parse ffprobe output: %w", err)
	}
	return probed, nil
}

type picture struct {
	filterGraph string
	width       int
	height      int
	rotation    int
	transfer    string
}

func (p probeResult) shownPicture() (picture, error) {
	for _, group := range p.StreamGroups {
		if group.Type == tileGridGroup && len(group.Components) > 0 && len(group.Components[0].Tiles) > 0 {
			return p.tileGridPicture(group.Components[0]), nil
		}
	}
	for _, stream := range p.Streams {
		if stream.CodecType == "video" && stream.Disposition["attached_pic"] == 0 {
			degrees := rotationDegrees(stream.SideDataList)
			width, height := displayedSize(stream.Width, stream.Height, degrees)
			return picture{
				filterGraph: fmt.Sprintf("[0:%d]", stream.Index),
				width:       width,
				height:      height,
				rotation:    degrees,
				transfer:    stream.ColorTransfer,
			}, nil
		}
	}
	return picture{}, errors.New("no picture or video stream")
}

func (p probeResult) tileGridPicture(grid probeTileGrid) picture {
	var inputs, layout strings.Builder
	for i, tile := range grid.Tiles {
		fmt.Fprintf(&inputs, "[0:%d]", tile.StreamIndex)
		if i > 0 {
			layout.WriteByte('|')
		}
		fmt.Fprintf(&layout, "%d_%d", tile.X, tile.Y)
	}
	filterGraph := inputs.String()
	if len(grid.Tiles) > 1 {
		filterGraph += fmt.Sprintf("xstack=inputs=%d:layout=%s:fill=black,", len(grid.Tiles), layout.String())
	}
	filterGraph += fmt.Sprintf("crop=%d:%d:%d:%d,", grid.Width, grid.Height, grid.HorizontalOffset, grid.VerticalOffset)
	degrees := rotationDegrees(grid.SideDataList)
	if upright := uprightFilter(degrees); upright != "" {
		filterGraph += upright + ","
	}
	width, height := displayedSize(grid.Width, grid.Height, degrees)
	shown := picture{filterGraph: filterGraph, width: width, height: height, rotation: degrees}
	for _, stream := range p.Streams {
		if stream.Index == grid.Tiles[0].StreamIndex {
			shown.transfer = stream.ColorTransfer
		}
	}
	return shown
}

func rotationDegrees(sides []sideData) int {
	for _, side := range sides {
		if side.Rotation != 0 {
			return int(math.Round(side.Rotation))
		}
	}
	return 0
}

func displayedSize(width, height, degrees int) (int, int) {
	if (degrees/90)%2 != 0 {
		return height, width
	}
	return width, height
}

func uprightFilter(degrees int) string {
	switch ((-degrees % 360) + 360) % 360 {
	case 90:
		return "transpose=clock"
	case 180:
		return "hflip,vflip"
	case 270:
		return "transpose=cclock"
	}
	return ""
}

func (p probeResult) duration() float64 {
	seconds, err := strconv.ParseFloat(p.Format.Duration, 64)
	if err != nil || seconds < 0 || math.IsInf(seconds, 0) || math.IsNaN(seconds) {
		return 0
	}
	return seconds
}

func (p probeResult) recordedAt() time.Time {
	for _, key := range []string{"com.apple.quicktime.creationdate", "creation_time"} {
		value, ok := p.Format.Tags[key]
		if !ok {
			continue
		}
		for _, layout := range []string{time.RFC3339Nano, "2006-01-02T15:04:05-0700"} {
			if parsed, err := time.Parse(layout, value); err == nil && parsed.Year() > 1970 {
				return parsed
			}
		}
	}
	return time.Time{}
}

func runWithFile(ctx context.Context, file *os.File, program string, args ...string) ([]byte, error) {
	command := exec.CommandContext(ctx, program, args...)
	command.ExtraFiles = []*os.File{file}
	var stdout, stderr bytes.Buffer
	command.Stdout, command.Stderr = &stdout, &stderr
	if err := command.Run(); err != nil {
		message := strings.TrimSpace(stderr.String())
		if len(message) > maxErrorOutputBytes {
			message = message[:maxErrorOutputBytes]
		}
		return nil, fmt.Errorf("%s: %w: %s", filepath.Base(program), err, message)
	}
	return stdout.Bytes(), nil
}
