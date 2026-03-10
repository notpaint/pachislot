import socket

my_IP = "127.0.0.1"
my_PORT = 8192

sock = socket.socket(socket.AF_INET, socket.SOCK_DGRAM)

sock.bind((my_IP, my_PORT))

sock.settimeout(1.0)

counter = 0

print(f"waiting...")
try:
    while True:
        try:
            data, address = sock.recvfrom(1024)

            msg = data.decode('utf-8')
            print(f">:{msg}")
        except socket.timeout:
            continue

except KeyboardInterrupt:
    print("\nexit")
    sock.close()