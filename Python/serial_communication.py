import serial
import time 
import struct

arduino_port = "/dev/cu.usbmodem142201" # Update if necessary
baud_rate = 9600

ser = serial.Serial(port=arduino_port, baudrate=baud_rate, timeout=1)
time.sleep(2) # Give connection time to initialize

# Read initial messages from Arduino
while ser.in_waiting > 0:
    init_msg = ser.readline().decode().strip()
    print(f"Arduino: {init_msg}")

def send_elevation_to_arduino(elevations):
    # Convert the list of integers to a comma-separated string
    data_str = elevations.strip() + '\n'  # Add newline as a terminator

    # Send the string over serial
    ser.write(data_str.encode())

    # Wait a moment for the Arduino to process the data
    time.sleep(1)

    # Read response from Arduino
    while ser.in_waiting > 0:
        response = ser.readline().decode().strip()
        print(f"Arduino: {response}")

# msg = "[1000,4000,1000,4000,1000,4000,1000,4000,1000,4000]"
# send_elevation_to_arduino(elevations=msg)

#ser.close() # Close the serial port after communication is complete


# elevation = [2078, 2103, 2420, 3086, 3376, 3306, 2638, 2177, 1847, 1812]