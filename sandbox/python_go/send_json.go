package main

import (
	"bufio"
	"encoding/json"
	"fmt"
	"net"
	"os"
	"strconv"
)

type gamedata struct {
	Name   string `json:"name"`
	Payout int    `json:"payout"`
}

func main() {
	conn, err := net.Dial("udp", "127.0.0.1:16384")
	if err != nil {
		fmt.Println(err)
		return
	}
	defer conn.Close()

	fmt.Println("JSON mode")
	fmt.Println("send 'exit' as name to finish")

	buffer := bufio.NewScanner(os.Stdin)

	for {

		fmt.Print("Enter the name >:")

		if !buffer.Scan() {
			break
		}

		nameInput := buffer.Text()

		if nameInput == "exit" {
			exitData := gamedata{Name: "exit", Payout: 0}
			exitData_json, _ := json.Marshal(exitData)
			conn.Write(exitData_json)
			fmt.Println("exit command detected")
			break
		}

		fmt.Print("Enter the payout >:")

		if !buffer.Scan() {
			break
		}

		payoutInput := buffer.Text()
		payoutInt, err := strconv.Atoi(payoutInput)

		if err != nil {
			fmt.Println("error do not enter string as payout")
			continue
		}

		data := gamedata{
			Name:   nameInput,
			Payout: payoutInt,
		}

		json_data, err := json.Marshal(data)
		if err != nil {
			fmt.Println("json error", err)
			continue
		}

		conn.Write(json_data)
	}
}
