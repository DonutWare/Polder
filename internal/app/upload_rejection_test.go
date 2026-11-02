package app_test

import (
	"bufio"
	"bytes"
	"encoding/json"
	"fmt"
	"net"
	"net/http"
	"strings"
	"testing"

	"polder-server/internal/config"
)

func TestRejectedUploadIsAnsweredOnceTheBodyIsSent(t *testing.T) {
	server := startServer(t, config.DriverSQLite, "")
	alice := server.createUser(server.setupAdmin(), "alice", 1<<20)
	body := bytes.Repeat([]byte("x"), 32<<20)

	connection, err := net.Dial("tcp", strings.TrimPrefix(server.server.URL, "http://"))
	if err != nil {
		t.Fatal(err)
	}
	defer connection.Close()
	fmt.Fprintf(connection, "PUT /api/v1/files/content?path=%%2Fbig.bin&baseRev=0 HTTP/1.1\r\nHost: polder\r\nAuthorization: Bearer %s\r\nContent-Length: %d\r\n\r\n", alice.token, len(body))
	if _, err := connection.Write(body); err != nil {
		t.Fatalf("server hung up during the upload: %v", err)
	}

	response, err := http.ReadResponse(bufio.NewReader(connection), nil)
	if err != nil {
		t.Fatalf("no response after the upload: %v", err)
	}
	defer response.Body.Close()
	var rejected errorResponse
	if err := json.NewDecoder(response.Body).Decode(&rejected); err != nil {
		t.Fatal(err)
	}
	if response.StatusCode != http.StatusInsufficientStorage || rejected.Error.Code != "quota_exceeded" {
		t.Fatalf("status %d, error %+v", response.StatusCode, rejected)
	}
}
