import socket
import json

my_IP = "127.0.0.1"
my_PORT = 8192

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)
sock.bind((my_IP, my_PORT))

sock.settimeout(1.0)

print("waiting...")

try:
    while True:
        try:
            data, address = sock.recvfrom(1024)

            data_str = data.decode('utf-8')

            data_dict = json.loads(data_str)

            if data_dict["name"] == "exit":
                break

            print(data_dict)

        except socket.timeout:
            continue

except KeyboardInterrupt:
    print("\nexit")
    sock.close()