package main

import (
	"context"
	"log"
	"os"

	"github.com/tailscale/tailscale-client-go/tailscale"
)

func main() {
	apiKey := os.Getenv("TAILSCALE_API_KEY")
	tailnet := os.Getenv("TAILSCALE_TAILNET")

	client, err := tailscale.NewClient(apiKey, tailnet)
	if err != nil {
		log.Fatalln(err)
	}

	// List all your devices
	devices, err := client.Devices(context.Background())
	log.Printf("%+v", devices)
}
