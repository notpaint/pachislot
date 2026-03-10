import socket

# 設定
LISTEN_IP = "0.0.0.0"  # すべてのインターフェースで待ち受け
LISTEN_PORT = 16384
TARGET_IP = "100.76.19.10"
TARGET_PORT = 8192

def main():
    # 受信用のUDPソケットを作成
    # AF_INET: IPv4を使用
    # SOCK_DGRAM: UDPプロトコルを使用
    with socket.socket(socket.AF_INET, socket.SOCK_DGRAM) as sock:
        # ポートをバインド（待ち受け開始）
        sock.bind((LISTEN_IP, LISTEN_PORT))
        
        print(f"Python relay server started on {LISTEN_PORT} -> {TARGET_IP}:{TARGET_PORT}")
        
        while True:
            # データを受信 (バッファサイズ 8192バイト)
            data, addr = sock.recvfrom(8192)
            
            print(f"Received {len(data)} bytes from {addr}")
            
            # ターゲットに転送
            # 送信用に新しいソケットを作らず、同じソケットを使って送信することも可能です
            sock.sendto(data, (TARGET_IP, TARGET_PORT))
            
            print("Forwarded to target")

if __name__ == "__main__":
    try:
        main()
    except KeyboardInterrupt:
        print("
Relay server stopped.")
