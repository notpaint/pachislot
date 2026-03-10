package main

import (
	"bufio"
	"fmt"
	"net"
	"os"
)

func main() {
	conn, err := net.Dial("udp", "127.0.0.1:16384")
	if err != nil {
		fmt.Println("Error", err)
		os.Exit(1)
	}
	defer conn.Close()

	fmt.Println("Enter the message")
	fmt.Println("Enter the 'exit' to terminate")

	buffer := bufio.NewScanner(os.Stdin)

	for {

		fmt.Print(">")

		if !buffer.Scan() {
			break
		}

		text := buffer.Text()

		if text == "exit" {
			break
		}

		conn.Write([]byte(text))
	}
}
