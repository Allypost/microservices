package main

import (
	"fmt"
	"io"
	"log"
	"net"
	"net/http"
	"os"
	"strings"

	"github.com/golang/gddo/httputil"
)

func extractIpFromRequest(r *http.Request) *net.IP {
	var userIp string
	if len(r.Header.Get("CF-Connecting-IP")) > 1 {
		userIp = r.Header.Get("CF-Connecting-IP")
	} else if len(r.Header.Get("X-Forwarded-For")) > 1 {
		userIp = r.Header.Get("X-Forwarded-For")
	} else if len(r.Header.Get("X-Real-IP")) > 1 {
		userIp = r.Header.Get("X-Real-IP")
	} else {
		userIp = r.RemoteAddr
		ip, _, err := net.SplitHostPort(r.RemoteAddr)
		if err != nil {
			return nil
		}
		userIp = ip
	}

	str := strings.Split(userIp, ",")

	if len(str) < 1 {
		return nil
	}

	ip := str[len(str)-1]
	ip = strings.TrimSpace(ip)

	parsedIp := net.ParseIP(ip)

	if parsedIp == nil {
		return nil
	}

	return &parsedIp
}

func handleIp(w http.ResponseWriter, r *http.Request) {
	userIp := extractIpFromRequest(r)

	contentType := httputil.NegotiateContentType(r, []string{"text/plain", "application/json", "text/html"}, "text/plain")

	w.Header().Add("content-type", contentType)

	if userIp == nil {
		w.WriteHeader(400)
		switch contentType {
		case "text/plain":
			break
		case "application/json":
			io.WriteString(w, `{"error": "invalid ip"}`)
		case "text/html":
			io.WriteString(w, `Got an invalid ip`)
		}
		return
	}

	ip := userIp.String()

	switch contentType {
	case "application/json":
		io.WriteString(w, fmt.Sprintf(`{"ip":"%s"}`, ip))
	case "text/html":
		io.WriteString(w, fmt.Sprintf(`%s`, ip))
	default:
		io.WriteString(w, ip)
	}
}

func main() {
	mux := http.NewServeMux()

	mux.HandleFunc("/", handleIp)

	host := strings.TrimSpace(os.Getenv("HOST"))
	if len(host) == 0 {
		host = "0.0.0.0"
	}

	port := strings.TrimSpace(os.Getenv("PORT"))
	if len(port) == 0 {
		port = "8080"
	}

	ln, err := net.Listen("tcp", fmt.Sprintf("%s:%s", host, port))
	if err != nil {
		log.Fatal(err)
	}

	log.Printf("Listening on: http://%s", ln.Addr().String())

	log.Fatal(http.Serve(ln, mux))
}
