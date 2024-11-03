import socket
import serial_communication as sc

# Set up the socket server
server_socket = socket.socket(socket.AF_INET, socket.SOCK_STREAM)
server_socket.bind(('0.0.0.0', 12346))  # Listen on all IPs, port 12345
server_socket.listen(1)


print("Waiting for connection...")

client_socket, addr = server_socket.accept()
print(f"Connected to {addr}")

try:
    while True:
        data = client_socket.recv(1024).decode()
        if not data:
            print("Client disconnected.")
            break  # Stop the loop if the client disconnects.

        print(f"altitude reached python socket: {data}")

        # Handle a shutdown command.
        if data.strip().lower() == 'exit':
            print("Shutdown command received. Closing connection.")
            break

        # Send data to Arduino.
        sc.send_elevation_to_arduino(elevations=data)

finally:
    # Clean up the sockets to ensure safe closure.
    client_socket.close()
    server_socket.close()
    print("Connection closed.")