package emails

import (
	"context"
	_ "embed"
	"math"
	"strconv"
	"strings"

	"polder-server/internal/mail"
	"polder-server/internal/settings"
)

const (
	defaultName   = "Polder"
	defaultAccent = "#24E2F2"
	iconContentID = "brand-icon@polder"
	darkText      = "#111418"
	lightText     = "#FFFFFF"
)

//go:embed default_icon.png
var defaultIcon []byte

var inlineImageTypes = map[string]string{
	"image/png":  "icon.png",
	"image/jpeg": "icon.jpg",
	"image/gif":  "icon.gif",
}

type Brand struct {
	Name      string
	Accent    string
	OnAccent  string
	IconCID   string
	PublicURL string
	icon      *mail.Attachment
}

type BrandSource struct {
	settings  *settings.Store
	images    *settings.Images
	publicURL string
}

func NewBrandSource(store *settings.Store, images *settings.Images, publicURL string) BrandSource {
	return BrandSource{settings: store, images: images, publicURL: publicURL}
}

func (b BrandSource) Current(ctx context.Context) Brand {
	brand := Brand{Name: defaultName, Accent: defaultAccent, PublicURL: b.publicURL}
	if b.settings != nil {
		if current, err := b.settings.Get(ctx); err == nil {
			brand = withServerSettings(brand, current)
		}
	}
	brand.OnAccent = readableOn(brand.Accent)
	brand.icon = b.inlineIcon()
	brand.IconCID = brand.icon.ContentID
	return brand
}

func withServerSettings(brand Brand, current settings.ServerSettings) Brand {
	if name := strings.TrimSpace(current.InstanceName); name != "" {
		brand.Name = name
	}
	if current.AccentColor != "" {
		brand.Accent = strings.ToUpper(current.AccentColor)
	}
	return brand
}

func (b BrandSource) inlineIcon() *mail.Attachment {
	if custom := b.customIcon(); custom != nil {
		return custom
	}
	return &mail.Attachment{ContentType: "image/png", Filename: "icon.png", ContentID: iconContentID, Content: defaultIcon}
}

func (b BrandSource) customIcon() *mail.Attachment {
	if b.images == nil {
		return nil
	}
	info := b.images.Icon()
	if info == nil {
		return nil
	}
	filename, inlinable := inlineImageTypes[info.ContentType]
	if !inlinable {
		return nil
	}
	image, err := b.images.ReadIcon(info.ID)
	if err != nil {
		return nil
	}
	return &mail.Attachment{ContentType: image.ContentType, Filename: filename, ContentID: iconContentID, Content: image.Content}
}

func readableOn(background string) string {
	luminance, ok := relativeLuminance(background)
	if !ok {
		return darkText
	}
	darkLuminance, _ := relativeLuminance(darkText)
	againstDark := (luminance + 0.05) / (darkLuminance + 0.05)
	againstLight := 1.05 / (luminance + 0.05)
	if againstDark >= againstLight {
		return darkText
	}
	return lightText
}

func relativeLuminance(hex string) (float64, bool) {
	value, err := strconv.ParseUint(strings.TrimPrefix(hex, "#"), 16, 32)
	if err != nil || len(hex) != 7 {
		return 0, false
	}
	red := linearChannel(value >> 16 & 0xFF)
	green := linearChannel(value >> 8 & 0xFF)
	blue := linearChannel(value & 0xFF)
	return 0.2126*red + 0.7152*green + 0.0722*blue, true
}

func linearChannel(channel uint64) float64 {
	scaled := float64(channel) / 255
	if scaled <= 0.04045 {
		return scaled / 12.92
	}
	return math.Pow((scaled+0.055)/1.055, 2.4)
}
