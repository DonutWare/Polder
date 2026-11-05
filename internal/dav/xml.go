package dav

import (
	"bytes"
	"encoding/xml"
	"errors"
	"io"
	"net/http"
	"regexp"
	"strconv"
)

const (
	NamespaceDAV            = "DAV:"
	NamespaceOwnCloud       = "http://owncloud.org/ns"
	NamespaceOCM            = "http://open-cloud-mesh.org/ns"
	NamespaceOCS            = "http://open-collaboration-services.org/ns"
	NamespaceCalDAV         = "urn:ietf:params:xml:ns:caldav"
	NamespaceCalendarServer = "http://calendarserver.org/ns/"
	NamespaceAppleICal      = "http://apple.com/ns/ical/"

	MaxBodyBytes  = 1 << 20
	maxXMLDepth   = 32
	maxXMLTokens  = 20000
	maxAttributes = 16
)

var prefixByNamespace = map[string]string{
	NamespaceDAV:            "d",
	NamespaceOwnCloud:       "oc",
	NamespaceOCM:            "ocm",
	NamespaceOCS:            "ocs",
	NamespaceCalDAV:         "cal",
	NamespaceCalendarServer: "cs",
	NamespaceAppleICal:      "ical",
}

var xmlNamePattern = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9._-]{0,127}$`)

func NamespaceAttributes(namespaces ...string) []string {
	attributes := make([]string, 0, len(namespaces)*2)
	for _, namespace := range namespaces {
		attributes = append(attributes, "xmlns:"+prefixByNamespace[namespace], namespace)
	}
	return attributes
}

type Writer struct {
	buffer bytes.Buffer
}

func NewWriter() *Writer {
	w := &Writer{}
	w.buffer.WriteString(`<?xml version="1.0" encoding="UTF-8"?>`)
	return w
}

func (w *Writer) Start(name string, attributes ...string) {
	w.buffer.WriteByte('<')
	w.buffer.WriteString(name)
	w.attributes(attributes)
	w.buffer.WriteByte('>')
}

func (w *Writer) Empty(name string, attributes ...string) {
	w.buffer.WriteByte('<')
	w.buffer.WriteString(name)
	w.attributes(attributes)
	w.buffer.WriteString("/>")
}

func (w *Writer) attributes(attributes []string) {
	for i := 0; i+1 < len(attributes); i += 2 {
		w.buffer.WriteByte(' ')
		w.buffer.WriteString(attributes[i])
		w.buffer.WriteString(`="`)
		_ = xml.EscapeText(&w.buffer, []byte(attributes[i+1]))
		w.buffer.WriteByte('"')
	}
}

func (w *Writer) End(name string) {
	w.buffer.WriteString("</")
	w.buffer.WriteString(name)
	w.buffer.WriteByte('>')
}

func (w *Writer) Text(value string) {
	_ = xml.EscapeText(&w.buffer, []byte(value))
}

func (w *Writer) Element(name, value string) {
	w.Start(name)
	w.Text(value)
	w.End(name)
}

func (w *Writer) Append(fragment *Writer) {
	w.buffer.Write(fragment.buffer.Bytes())
}

func (w *Writer) Len() int {
	return w.buffer.Len()
}

func (w *Writer) Bytes() []byte {
	return w.buffer.Bytes()
}

func (w *Writer) WriteTo(rw http.ResponseWriter, status int) {
	rw.Header().Set("Content-Type", `application/xml; charset="utf-8"`)
	rw.Header().Set("Content-Length", strconv.Itoa(w.buffer.Len()))
	rw.WriteHeader(status)
	_, _ = rw.Write(w.buffer.Bytes())
}

type Name struct {
	Space string
	Local string
}

func DAV(local string) Name { return Name{Space: NamespaceDAV, Local: local} }

func (n Name) Valid() bool {
	return xmlNamePattern.MatchString(n.Local) && len(n.Space) <= 512
}

type ForeignNames struct {
	prefixes map[string]string
}

func (f *ForeignNames) Qualified(name Name) (string, []string) {
	if prefix, known := prefixByNamespace[name.Space]; known {
		return prefix + ":" + name.Local, nil
	}
	if name.Space == "" {
		return name.Local, []string{"xmlns", ""}
	}
	if f.prefixes == nil {
		f.prefixes = map[string]string{}
	}
	prefix, seen := f.prefixes[name.Space]
	if !seen {
		prefix = "x" + strconv.Itoa(len(f.prefixes))
		f.prefixes[name.Space] = prefix
	}
	return prefix + ":" + name.Local, []string{"xmlns:" + prefix, name.Space}
}

type Element struct {
	Name       Name
	Attributes map[string]string
	Children   []*Element
	Text       string
}

func (e *Element) Child(space, local string) *Element {
	for _, child := range e.Children {
		if child.Name.Space == space && child.Name.Local == local {
			return child
		}
	}
	return nil
}

func (e *Element) ChildrenNamed(space, local string) []*Element {
	var matches []*Element
	for _, child := range e.Children {
		if child.Name.Space == space && child.Name.Local == local {
			matches = append(matches, child)
		}
	}
	return matches
}

func (e *Element) Attribute(local string) string {
	return e.Attributes[local]
}

func ReadBody(r *http.Request) (*Element, error) {
	if r.Body == nil {
		return nil, nil
	}
	limited := io.LimitReader(r.Body, MaxBodyBytes+1)
	content, err := io.ReadAll(limited)
	if err != nil {
		return nil, err
	}
	if len(content) > MaxBodyBytes {
		return nil, ErrBodyTooLarge
	}
	if len(bytes.TrimSpace(content)) == 0 {
		return nil, nil
	}
	return Parse(content)
}

func Parse(content []byte) (*Element, error) {
	decoder := xml.NewDecoder(bytes.NewReader(content))
	decoder.Strict = true
	var root *Element
	var stack []*Element
	tokens := 0
	for {
		token, err := decoder.Token()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return nil, ErrMalformedXML
		}
		if tokens++; tokens > maxXMLTokens {
			return nil, ErrBodyTooLarge
		}
		switch t := token.(type) {
		case xml.StartElement:
			if len(stack) >= maxXMLDepth || len(t.Attr) > maxAttributes {
				return nil, ErrMalformedXML
			}
			element := &Element{Name: Name{Space: t.Name.Space, Local: t.Name.Local}, Attributes: elementAttributes(t.Attr)}
			if len(stack) == 0 {
				if root != nil {
					return nil, ErrMalformedXML
				}
				root = element
			} else {
				parent := stack[len(stack)-1]
				parent.Children = append(parent.Children, element)
			}
			stack = append(stack, element)
		case xml.EndElement:
			if len(stack) == 0 {
				return nil, ErrMalformedXML
			}
			stack = stack[:len(stack)-1]
		case xml.CharData:
			if len(stack) > 0 && len(stack[len(stack)-1].Text) < MaxBodyBytes {
				stack[len(stack)-1].Text += string(t)
			}
		case xml.Directive:
			return nil, ErrMalformedXML
		}
	}
	if root == nil || len(stack) != 0 {
		return nil, ErrMalformedXML
	}
	return root, nil
}

func elementAttributes(attributes []xml.Attr) map[string]string {
	var byName map[string]string
	for _, attribute := range attributes {
		if attribute.Name.Space == "xmlns" || attribute.Name.Local == "xmlns" {
			continue
		}
		if byName == nil {
			byName = map[string]string{}
		}
		byName[attribute.Name.Local] = attribute.Value
	}
	return byName
}
