package calendar

import (
	"strconv"
	"strings"
	"sync"
	"time"

	"github.com/emersion/go-ical"
)

var windowsZones = map[string]string{
	"Dateline Standard Time":          "Etc/GMT+12",
	"UTC-11":                          "Etc/GMT+11",
	"Hawaiian Standard Time":          "Pacific/Honolulu",
	"Alaskan Standard Time":           "America/Anchorage",
	"Pacific Standard Time":           "America/Los_Angeles",
	"Pacific Standard Time (Mexico)":  "America/Tijuana",
	"US Mountain Standard Time":       "America/Phoenix",
	"Mountain Standard Time":          "America/Denver",
	"Mountain Standard Time (Mexico)": "America/Mazatlan",
	"Central America Standard Time":   "America/Guatemala",
	"Central Standard Time":           "America/Chicago",
	"Central Standard Time (Mexico)":  "America/Mexico_City",
	"Canada Central Standard Time":    "America/Regina",
	"SA Pacific Standard Time":        "America/Bogota",
	"Eastern Standard Time":           "America/New_York",
	"Eastern Standard Time (Mexico)":  "America/Cancun",
	"US Eastern Standard Time":        "America/Indianapolis",
	"Venezuela Standard Time":         "America/Caracas",
	"Atlantic Standard Time":          "America/Halifax",
	"SA Western Standard Time":        "America/La_Paz",
	"Pacific SA Standard Time":        "America/Santiago",
	"Newfoundland Standard Time":      "America/St_Johns",
	"E. South America Standard Time":  "America/Sao_Paulo",
	"Argentina Standard Time":         "America/Buenos_Aires",
	"SA Eastern Standard Time":        "America/Cayenne",
	"Greenland Standard Time":         "America/Godthab",
	"Montevideo Standard Time":        "America/Montevideo",
	"UTC-02":                          "Etc/GMT+2",
	"Azores Standard Time":            "Atlantic/Azores",
	"Cape Verde Standard Time":        "Atlantic/Cape_Verde",
	"UTC":                             "Etc/UTC",
	"GMT Standard Time":               "Europe/London",
	"Greenwich Standard Time":         "Atlantic/Reykjavik",
	"Morocco Standard Time":           "Africa/Casablanca",
	"W. Europe Standard Time":         "Europe/Berlin",
	"Central Europe Standard Time":    "Europe/Budapest",
	"Romance Standard Time":           "Europe/Paris",
	"Central European Standard Time":  "Europe/Warsaw",
	"W. Central Africa Standard Time": "Africa/Lagos",
	"GTB Standard Time":               "Europe/Bucharest",
	"Middle East Standard Time":       "Asia/Beirut",
	"Egypt Standard Time":             "Africa/Cairo",
	"E. Europe Standard Time":         "Europe/Chisinau",
	"South Africa Standard Time":      "Africa/Johannesburg",
	"FLE Standard Time":               "Europe/Kiev",
	"Israel Standard Time":            "Asia/Jerusalem",
	"Jordan Standard Time":            "Asia/Amman",
	"Arabic Standard Time":            "Asia/Baghdad",
	"Turkey Standard Time":            "Europe/Istanbul",
	"Arab Standard Time":              "Asia/Riyadh",
	"Russian Standard Time":           "Europe/Moscow",
	"E. Africa Standard Time":         "Africa/Nairobi",
	"Iran Standard Time":              "Asia/Tehran",
	"Arabian Standard Time":           "Asia/Dubai",
	"Azerbaijan Standard Time":        "Asia/Baku",
	"Georgian Standard Time":          "Asia/Tbilisi",
	"Caucasus Standard Time":          "Asia/Yerevan",
	"Afghanistan Standard Time":       "Asia/Kabul",
	"West Asia Standard Time":         "Asia/Tashkent",
	"Pakistan Standard Time":          "Asia/Karachi",
	"India Standard Time":             "Asia/Calcutta",
	"Sri Lanka Standard Time":         "Asia/Colombo",
	"Nepal Standard Time":             "Asia/Katmandu",
	"Central Asia Standard Time":      "Asia/Almaty",
	"Bangladesh Standard Time":        "Asia/Dhaka",
	"Myanmar Standard Time":           "Asia/Rangoon",
	"SE Asia Standard Time":           "Asia/Bangkok",
	"North Asia Standard Time":        "Asia/Krasnoyarsk",
	"China Standard Time":             "Asia/Shanghai",
	"Singapore Standard Time":         "Asia/Singapore",
	"W. Australia Standard Time":      "Australia/Perth",
	"Taipei Standard Time":            "Asia/Taipei",
	"Tokyo Standard Time":             "Asia/Tokyo",
	"Korea Standard Time":             "Asia/Seoul",
	"Cen. Australia Standard Time":    "Australia/Adelaide",
	"AUS Central Standard Time":       "Australia/Darwin",
	"E. Australia Standard Time":      "Australia/Brisbane",
	"AUS Eastern Standard Time":       "Australia/Sydney",
	"West Pacific Standard Time":      "Pacific/Port_Moresby",
	"Tasmania Standard Time":          "Australia/Hobart",
	"Vladivostok Standard Time":       "Asia/Vladivostok",
	"Central Pacific Standard Time":   "Pacific/Guadalcanal",
	"New Zealand Standard Time":       "Pacific/Auckland",
	"Fiji Standard Time":              "Pacific/Fiji",
	"Tonga Standard Time":             "Pacific/Tongatapu",
	"Samoa Standard Time":             "Pacific/Apia",
}

var loadedLocations sync.Map

func ValidTimezone(name string) bool {
	if name == "" {
		return true
	}
	_, ok := ianaLocation(name)
	return ok
}

func LocationOrUTC(name string) *time.Location {
	if location, ok := ianaLocation(name); ok && name != "" {
		return location
	}
	return time.UTC
}

func ianaLocation(name string) (*time.Location, bool) {
	if name == "" || name == "Local" || strings.Contains(name, "..") {
		return nil, false
	}
	if cached, ok := loadedLocations.Load(name); ok {
		location, found := cached.(*time.Location)
		return location, found
	}
	location, err := time.LoadLocation(name)
	if err != nil {
		loadedLocations.Store(name, false)
		return nil, false
	}
	loadedLocations.Store(name, location)
	return location, true
}

type zoneSet struct {
	definitions map[string]*ical.Component
	floating    *time.Location
}

func newZoneSet(cal *ical.Calendar, floating *time.Location) zoneSet {
	zones := zoneSet{definitions: map[string]*ical.Component{}, floating: floating}
	if zones.floating == nil {
		zones.floating = time.UTC
	}
	for _, child := range cal.Children {
		if child.Name != ical.CompTimezone {
			continue
		}
		if id := child.Props.Get(ical.PropTimezoneID); id != nil {
			zones.definitions[id.Value] = child
		}
	}
	return zones
}

func (z zoneSet) location(tzid string) *time.Location {
	tzid = strings.Trim(tzid, `"`)
	if location, ok := ianaLocation(tzid); ok {
		return location
	}
	if mapped, ok := windowsZones[tzid]; ok {
		if location, found := ianaLocation(mapped); found {
			return location
		}
	}
	if location, ok := ianaLocation(lastPathSegments(tzid)); ok {
		return location
	}
	if definition, ok := z.definitions[tzid]; ok {
		if location, found := definedLocation(tzid, definition); found {
			return location
		}
	}
	logger.Debug("unknown timezone, using UTC", "tzid", tzid)
	return time.UTC
}

func lastPathSegments(tzid string) string {
	parts := strings.Split(strings.Trim(tzid, "/"), "/")
	if len(parts) < 2 {
		return ""
	}
	return parts[len(parts)-2] + "/" + parts[len(parts)-1]
}

func definedLocation(tzid string, definition *ical.Component) (*time.Location, bool) {
	if location := hintedLocation(definition); location != nil {
		return location, true
	}
	for _, child := range definition.Children {
		if child.Name != ical.CompTimezoneStandard {
			continue
		}
		if offset := child.Props.Get(ical.PropTimezoneOffsetTo); offset != nil {
			if seconds, ok := parseUTCOffset(offset.Value); ok {
				return time.FixedZone(tzid, seconds), true
			}
		}
	}
	return nil, false
}

func hintedLocation(definition *ical.Component) *time.Location {
	for _, name := range []string{"X-LIC-LOCATION", "X-MICROSOFT-CDO-TZID"} {
		if prop := definition.Props.Get(name); prop != nil {
			if location, ok := ianaLocation(prop.Value); ok {
				return location
			}
		}
	}
	return nil
}

func parseUTCOffset(value string) (int, bool) {
	if len(value) != 5 && len(value) != 7 {
		return 0, false
	}
	sign := 1
	switch value[0] {
	case '-':
		sign = -1
	case '+':
	default:
		return 0, false
	}
	hours, errHours := strconv.Atoi(value[1:3])
	minutes, errMinutes := strconv.Atoi(value[3:5])
	seconds := 0
	var errSeconds error
	if len(value) == 7 {
		seconds, errSeconds = strconv.Atoi(value[5:7])
	}
	if errHours != nil || errMinutes != nil || errSeconds != nil {
		return 0, false
	}
	return sign * (hours*3600 + minutes*60 + seconds), true
}

func formatUTCOffset(seconds int) string {
	sign := "+"
	if seconds < 0 {
		sign = "-"
		seconds = -seconds
	}
	value := sign + twoDigits(seconds/3600) + twoDigits(seconds%3600/60)
	if rest := seconds % 60; rest != 0 {
		value += twoDigits(rest)
	}
	return value
}

func twoDigits(value int) string {
	if value < 10 {
		return "0" + strconv.Itoa(value)
	}
	return strconv.Itoa(value)
}

func TimezoneCalendar(name string) string {
	location, ok := ianaLocation(name)
	if !ok {
		return ""
	}
	cal := ical.NewCalendar()
	cal.Props.SetText(ical.PropVersion, "2.0")
	cal.Props.SetText(ical.PropProductID, ProductID)
	cal.Children = append(cal.Children, timezoneComponent(location, time.Now().Year()))
	data, err := encodeCalendar(cal)
	if err != nil {
		return ""
	}
	return string(data)
}

func TimezoneName(data string) string {
	cal, err := decodeCalendar([]byte(strings.TrimSpace(data)))
	if err != nil {
		return ""
	}
	zones := newZoneSet(cal, time.UTC)
	for tzid := range zones.definitions {
		name := zones.location(tzid).String()
		if _, known := ianaLocation(name); known && name != "UTC" {
			return name
		}
	}
	return ""
}
