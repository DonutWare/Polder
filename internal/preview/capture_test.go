package preview

import (
	"encoding/json"
	"testing"
)

func TestVideoCaptureReadsCameraLocationAndStreams(t *testing.T) {
	var probed probeResult
	err := json.Unmarshal([]byte(`{
		"streams": [
			{"index": 0, "codec_type": "video", "codec_name": "mjpeg", "disposition": {"attached_pic": 1}},
			{"index": 1, "codec_type": "video", "codec_name": "hevc", "avg_frame_rate": "30000/1001", "disposition": {"attached_pic": 0}},
			{"index": 2, "codec_type": "audio", "codec_name": "aac"}
		],
		"format": {"bit_rate": "8123456", "tags": {
			"com.apple.quicktime.make": "Apple",
			"com.apple.quicktime.model": "iPhone 15 Pro",
			"com.apple.quicktime.location.ISO6709": "+52.3702+004.8952+000.000/"
		}}
	}`), &probed)
	if err != nil {
		t.Fatal(err)
	}
	meta := map[string]any{}
	probed.capture().addTo(meta)
	expected := map[string]any{
		"cameraMake": "Apple", "cameraModel": "iPhone 15 Pro", "latitude": 52.3702, "longitude": 4.8952,
		"videoCodec": "hevc", "audioCodec": "aac", "frameRate": 29.97, "bitrate": float64(8123456),
	}
	for key, value := range expected {
		if meta[key] != value {
			t.Errorf("%s: expected %v, got %v", key, value, meta[key])
		}
	}
	if len(meta) != len(expected) {
		t.Errorf("unexpected keys in %v", meta)
	}
}

func TestISO6709RejectsMissingOrImpossibleLocations(t *testing.T) {
	for _, value := range []string{"", "garbage", "+00.0000+000.0000/", "+95.0000+004.0000/"} {
		if parsed := parseISO6709(value); parsed != nil {
			t.Errorf("%q should not parse, got %+v", value, parsed)
		}
	}
	if parsed := parseISO6709("-33.8688+151.2093/"); parsed == nil || parsed.latitude != -33.8688 || parsed.longitude != 151.2093 {
		t.Errorf("southern location parsed wrong: %+v", parsed)
	}
}

func TestFrameRateHandlesFractionsAndZeroDenominators(t *testing.T) {
	cases := map[string]float64{"25/1": 25, "60": 60, "0/0": 0, "": 0}
	for value, expected := range cases {
		if parsed := parseFrameRate(value); parsed != expected {
			t.Errorf("%q: expected %v, got %v", value, expected, parsed)
		}
	}
}
