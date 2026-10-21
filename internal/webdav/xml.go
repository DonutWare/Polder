package webdav

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
	nsDAV      = "DAV:"
	nsOwnCloud = "http://owncloud.org/ns"
	nsOCM      = "http://open-cloud-mesh.org/ns"
	nsOCS      = "http://open-collaboration-services.org/ns"

	maxXMLBodyBytes = 1 << 20
	maxXMLDepth     = 32
	maxXMLTokens    = 20000
	basicChallenge  = `Basic realm="Polder", charset="UTF-8"`
)

var prefixByNamespace = map[string]string{
	nsDAV:      "d",
	nsOwnCloud: "oc",
	nsOCM:      "ocm",
	nsOCS:      "ocs",
}

var xmlNamePattern = regexp.MustCompile(`^[A-Za-z_][A-Za-z0-9._-]{0,127}$`)

func namespaceAttributes(namespaces ...string) []string {
	attributes := make([]string, 0, len(namespaces)*2)
	for _, namespace := range namespaces {
		attributes = append(attributes, "xmlns:"+prefixByNamespace[namespace], namespace)
	}
	return attributes
}

type xmlWriter struct {
	buffer bytes.Buffer
}

func newXMLWriter() *xmlWriter {
	w := &xmlWriter{}
	w.buffer.WriteString(`<?xml version="1.0" encoding="UTF-8"?>`)
	return w
}

func (w *xmlWriter) start(name string, attributes ...string) {
	w.buffer.WriteByte('<')
	w.buffer.WriteString(name)
	w.attributes(attributes)
	w.buffer.WriteByte('>')
}

func (w *xmlWriter) empty(name string, attributes ...string) {
	w.buffer.WriteByte('<')
	w.buffer.WriteString(name)
	w.attributes(attributes)
	w.buffer.WriteString("/>")
}

func (w *xmlWriter) attributes(attributes []string) {
	for i := 0; i+1 < len(attributes); i += 2 {
		w.buffer.WriteByte(' ')
		w.buffer.WriteString(attributes[i])
		w.buffer.WriteString(`="`)
		_ = xml.EscapeText(&w.buffer, []byte(attributes[i+1]))
		w.buffer.WriteByte('"')
	}
}

func (w *xmlWriter) end(name string) {
	w.buffer.WriteString("</")
	w.buffer.WriteString(name)
	w.buffer.WriteByte('>')
}

func (w *xmlWriter) text(value string) {
	_ = xml.EscapeText(&w.buffer, []byte(value))
}

func (w *xmlWriter) element(name, value string) {
	w.start(name)
	w.text(value)
	w.end(name)
}

func (w *xmlWriter) writeTo(rw http.ResponseWriter, status int) {
	rw.Header().Set("Content-Type", `application/xml; charset="utf-8"`)
	rw.Header().Set("Content-Length", strconv.Itoa(w.buffer.Len()))
	rw.WriteHeader(status)
	_, _ = rw.Write(w.buffer.Bytes())
}

type propName struct {
	Space string
	Local string
}

func (n propName) valid() bool {
	return xmlNamePattern.MatchString(n.Local) && len(n.Space) <= 512
}

type foreignNames struct {
	prefixes map[string]string
}

func (f *foreignNames) qualified(name propName) (string, []string) {
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

type xmlElement struct {
	name     propName
	children []*xmlElement
	text     string
}

func (e *xmlElement) child(space, local string) *xmlElement {
	for _, child := range e.children {
		if child.name.Space == space && child.name.Local == local {
			return child
		}
	}
	return nil
}

func readXMLBody(r *http.Request) (*xmlElement, error) {
	if r.Body == nil {
		return nil, nil
	}
	limited := io.LimitReader(r.Body, maxXMLBodyBytes+1)
	content, err := io.ReadAll(limited)
	if err != nil {
		return nil, err
	}
	if len(content) > maxXMLBodyBytes {
		return nil, errBodyTooLarge
	}
	if len(bytes.TrimSpace(content)) == 0 {
		return nil, nil
	}
	return parseXML(content)
}

func parseXML(content []byte) (*xmlElement, error) {
	decoder := xml.NewDecoder(bytes.NewReader(content))
	decoder.Strict = true
	var root *xmlElement
	var stack []*xmlElement
	tokens := 0
	for {
		token, err := decoder.Token()
		if errors.Is(err, io.EOF) {
			break
		}
		if err != nil {
			return nil, errMalformedXML
		}
		if tokens++; tokens > maxXMLTokens {
			return nil, errBodyTooLarge
		}
		switch t := token.(type) {
		case xml.StartElement:
			if len(stack) >= maxXMLDepth {
				return nil, errMalformedXML
			}
			element := &xmlElement{name: propName{Space: t.Name.Space, Local: t.Name.Local}}
			if len(stack) == 0 {
				if root != nil {
					return nil, errMalformedXML
				}
				root = element
			} else {
				parent := stack[len(stack)-1]
				parent.children = append(parent.children, element)
			}
			stack = append(stack, element)
		case xml.EndElement:
			if len(stack) == 0 {
				return nil, errMalformedXML
			}
			stack = stack[:len(stack)-1]
		case xml.CharData:
			if len(stack) > 0 && len(stack[len(stack)-1].text) < maxXMLBodyBytes {
				stack[len(stack)-1].text += string(t)
			}
		case xml.Directive:
			return nil, errMalformedXML
		}
	}
	if root == nil || len(stack) != 0 {
		return nil, errMalformedXML
	}
	return root, nil
}
