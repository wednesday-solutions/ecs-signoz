package main

import (
	"log"
	"net/http"
	"os"
	"time"
)

func main() {
	url := os.Getenv("CALL_URL")
	if url == "" {
		log.Println("url not present")
	}
	for {
		resp, err := http.Get(url)
		if err != nil {
			log.Println(err)
		}
		log.Println(resp.StatusCode)
		time.Sleep(1 * time.Second)
	}
}
