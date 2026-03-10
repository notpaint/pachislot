import socket

target_IP = "127.0.0.1"
target_PORT = 16384

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

print(f"Enter the message")
print("Enter the 'exit' to terminate")

while True:
    msg = input(">:")

    if msg == "exit":
        break

    sock.sendto(msg.encode('utf-8'), (target_IP, target_PORT))

sock.close()