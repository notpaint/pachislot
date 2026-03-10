package main

import (
	"fmt"
	"net"
	"os"
)

const (
	ListenPort    = ":16384"
	TargetAddress = "100.76.19.10:8192"
)

func main() {
	conn, err := net.ListenPacket("udp", ListenPort)
	if err != nil {
		fmt.Println("Error", err)
		os.Exit(1)
	}
	defer conn.Close()

	fmt.Println("Go relay server started on", ListenPort, "->", TargetAddress)

	dataChannel := make(chan []byte, 8192)

	go relaying(dataChannel)

	buffer := make([]byte, 8192)

	for {
		n, adress, err := conn.ReadFrom(buffer)
		if err != nil {
			continue
		}

		fmt.Printf("Received %d bytes from %s\n", n, adress)

		data := make([]byte, n)
		copy(data, buffer[:n])

		dataChannel <- data
	}
}

func relaying(ch chan []byte) {
	conn, err := net.Dial("udp", TargetAddress)
	if err != nil {
		fmt.Println("connection error", err)
		return
	}
	defer conn.Close()

	for data := range ch {
		_, err := conn.Write(data)
		if err != nil {
			fmt.Println("send error", err)
		} else {
			fmt.Println("send to Docker")
		}
	}
}
