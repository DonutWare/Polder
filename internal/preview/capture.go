package preview

import (
	"math"
	"regexp"
	"strconv"
	"strings"

	"github.com/rwcarlsen/goexif/exif"
)

var iso6709Location = regexp.MustCompile(`^([+-]\d+(?:\.\d+)?)([+-]\d+(?:\.\d+)?)`)

type location struct {
	latitude  float64
	longitude float64
}

type capture struct {
	cameraMake   string
	cameraModel  string
	lens         string
	focalLength  float64
	aperture     float64
	exposureTime float64
	iso          int
	location     *location
	videoCodec   string
	audioCodec   string
	frameRate    float64
	bitrate      int64
}

func (c capture) addTo(meta map[string]any) {
	addText(meta, "cameraMake", c.cameraMake)
	addText(meta, "cameraModel", c.cameraModel)
	addText(meta, "lens", c.lens)
	addNumber(meta, "focalLength", c.focalLength)
	addNumber(meta, "aperture", c.aperture)
	addNumber(meta, "exposureTime", c.exposureTime)
	addNumber(meta, "iso", float64(c.iso))
	if c.location != nil {
		meta["latitude"], meta["longitude"] = c.location.latitude, c.location.longitude
	}
	addText(meta, "videoCodec", c.videoCodec)
	addText(meta, "audioCodec", c.audioCodec)
	addNumber(meta, "frameRate", math.Round(c.frameRate*100)/100)
	addNumber(meta, "bitrate", float64(c.bitrate))
}

func addText(meta map[string]any, key, value string) {
	if value != "" {
		meta[key] = value
	}
}

func addNumber(meta map[string]any, key string, value float64) {
	if value > 0 && !math.IsInf(value, 0) && !math.IsNaN(value) {
		meta[key] = value
	}
}

func (c *capture) applyExif(metadata *exif.Exif) {
	c.cameraMake = exifText(metadata, exif.Make)
	c.cameraModel = exifText(metadata, exif.Model)
	c.lens = exifText(metadata, exif.LensModel)
	c.focalLength = exifRational(metadata, exif.FocalLength)
	c.aperture = exifRational(metadata, exif.FNumber)
	c.exposureTime = exifRational(metadata, exif.ExposureTime)
	if tag, err := metadata.Get(exif.ISOSpeedRatings); err == nil {
		if value, err := tag.Int(0); err == nil {
			c.iso = value
		}
	}
	if latitude, longitude, err := metadata.LatLong(); err == nil && validLocation(latitude, longitude) {
		c.location = &location{latitude: latitude, longitude: longitude}
	}
}

func exifText(metadata *exif.Exif, field exif.FieldName) string {
	tag, err := metadata.Get(field)
	if err != nil {
		return ""
	}
	value, err := tag.StringVal()
	if err != nil {
		return ""
	}
	return strings.TrimSpace(strings.TrimRight(value, "\x00"))
}

func exifRational(metadata *exif.Exif, field exif.FieldName) float64 {
	tag, err := metadata.Get(field)
	if err != nil {
		return 0
	}
	numerator, denominator, err := tag.Rat2(0)
	if err != nil || denominator == 0 {
		return 0
	}
	return float64(numerator) / float64(denominator)
}

func validLocation(latitude, longitude float64) bool {
	return math.Abs(latitude) <= 90 && math.Abs(longitude) <= 180 && (latitude != 0 || longitude != 0)
}

func (p probeResult) capture() capture {
	tags := p.Format.Tags
	found := capture{
		cameraMake:  firstTag(tags, "com.apple.quicktime.make", "com.android.manufacturer", "make"),
		cameraModel: firstTag(tags, "com.apple.quicktime.model", "com.android.model", "model"),
		location:    parseISO6709(firstTag(tags, "com.apple.quicktime.location.ISO6709", "location")),
	}
	found.bitrate, _ = strconv.ParseInt(p.Format.BitRate, 10, 64)
	for _, stream := range p.Streams {
		switch {
		case stream.CodecType == "video" && stream.Disposition["attached_pic"] == 0 && found.videoCodec == "":
			found.videoCodec = stream.CodecName
			found.frameRate = parseFrameRate(stream.AverageFrameRate)
		case stream.CodecType == "audio" && found.audioCodec == "":
			found.audioCodec = stream.CodecName
		}
	}
	return found
}

func firstTag(tags map[string]string, keys ...string) string {
	for _, key := range keys {
		if value := strings.TrimSpace(tags[key]); value != "" {
			return value
		}
	}
	return ""
}

func parseISO6709(value string) *location {
	parts := iso6709Location.FindStringSubmatch(value)
	if parts == nil {
		return nil
	}
	latitude, latitudeErr := strconv.ParseFloat(parts[1], 64)
	longitude, longitudeErr := strconv.ParseFloat(parts[2], 64)
	if latitudeErr != nil || longitudeErr != nil || !validLocation(latitude, longitude) {
		return nil
	}
	return &location{latitude: latitude, longitude: longitude}
}

func parseFrameRate(value string) float64 {
	numerator, denominator, found := strings.Cut(value, "/")
	frames, err := strconv.ParseFloat(numerator, 64)
	if err != nil {
		return 0
	}
	if !found {
		return frames
	}
	seconds, err := strconv.ParseFloat(denominator, 64)
	if err != nil || seconds == 0 {
		return 0
	}
	return frames / seconds
}
