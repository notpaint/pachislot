package main

import (
	"fmt"
	"net"
	"os"
)

func main() {
	conn, err := net.ListenPacket("udp", ":16384")
	if err != nil {
		fmt.Println("Error", err)
		os.Exit(1)
	}
	defer conn.Close()

	fmt.Println("waiting...")
	fmt.Println("Ctrl + C to exit")

	buffer := make([]byte, 1024)

	for {
		n, address, err := conn.ReadFrom(buffer)
		if err != nil {
			fmt.Println("Read Error", err)
			continue
		}

		msg := string(buffer[:n])
		fmt.Printf("%v>: %v\n", address, msg)
	}
}
