import socket
import json

target_IP = "127.0.0.1"
target_PORT = 16384

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print("JSON mode")
print("send 'exit' as name to finish")

while True:
    name_input = input("Enter the name >:")
    if name_input == "exit":
        payout_input = "0"
    else:
        payout_input = input("Enter the payout >:")

    if payout_input == "cancel":
        continue

    data = {
        "name" : name_input,
        "payout": int(payout_input)
    }

    json_data = json.dumps(data)

    sock.sendto(json_data.encode('utf-8'), (target_IP, target_PORT))

    if name_input == "exit":
        print("detected exit command")
        break

sock.close()