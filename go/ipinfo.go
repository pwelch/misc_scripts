package main

// Go app to run on a server so that clients can see what their external IP is

import (
	"encoding/json"
	"log"
	"net"
	"net/http"
)

// JSON Struct for IP Info
type IPInfo struct {
	IP string
}

func main() {
	http.HandleFunc("/", textIP)
	http.HandleFunc("/text", textIP)
	http.HandleFunc("/json", jsonIP)

	http.ListenAndServe(":3000", nil)
}

// Get Request IP Address
func getIP(w http.ResponseWriter, req *http.Request) string {
	ip, _, err := net.SplitHostPort(req.RemoteAddr)
	if err != nil {
		log.Fatal("Request IP: %q is not IP:port", req.RemoteAddr)
		w.Write([]byte("ERROR"))
	}

	requestIP := net.ParseIP(ip)
	return requestIP.String()
}

// Plain Text Response
func textIP(w http.ResponseWriter, req *http.Request) {
	w.Write([]byte(getIP(w, req)))
}

// JSON Response
func jsonIP(w http.ResponseWriter, req *http.Request) {
	info := IPInfo{getIP(w, req)}
	js, err := json.Marshal(info)
	if err != nil {
		http.Error(w, err.Error(), http.StatusInternalServerError)
		return
	}

	w.Header().Set("Content-Type", "application/json")
	w.Write(js)
}

// http://www.alexedwards.net/blog/golang-response-snippets
