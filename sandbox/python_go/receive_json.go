package main

import (
	"encoding/json"
	"fmt"
	"net"
	"os"
)

type gamedata struct {
	Name   string `json:"name"`
	Payout int    `json:"Payout"`
}

func main() {
	conn, err := net.ListenPacket("udp", ":16384")
	if err != nil {
		fmt.Println("Error", err)
		os.Exit(1)
	}
	defer conn.Close()

	fmt.Println("send 'exit' as name to finish")
	fmt.Println("waiting JSON...")

	buffer := make([]byte, 1024)

	var result []gamedata

	for {
		n, _, err := conn.ReadFrom(buffer)
		if err != nil {
			continue
		}
		var data gamedata

		parseerr := json.Unmarshal(buffer[:n], &data)

		if parseerr != nil {
			fmt.Println("json error", parseerr)
			continue
		}

		if data.Name == "exit" {
			fmt.Println("detected exit command")
			break
		}

		fmt.Printf("%v\n", data)
		result = append(result, data)
	}

	fmt.Printf("-----result------\n")

	for i, v := range result {
		fmt.Printf("[%d] name:%s : payout:%d\n", i+1, v.Name, v.Payout)
	}
}
