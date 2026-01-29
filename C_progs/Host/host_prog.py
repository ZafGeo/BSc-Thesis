import serial
import time
import argparse
import math

def send_chunk(ser, mA, mB, chunk_size=256):
    """Send file data to FPGA over UART."""
    with open(mA, "rb") as f:
        while True:
            chunk = f.read(chunk_size)
            if not chunk:
                return f
            ser.write(chunk)
            ser.flush()
            time.sleep(0.001)  # Small delay to avoid FPGA overrun

def receive_chunk(ser, output_file, timeout=5):
    """Receive data from FPGA and write to file."""
    ser.timeout = timeout
    with open(output_file, "wb") as f:
        while True:
            data = ser.read(1024)
            if not data:
                break
            f.write(data)

def main():
    parser = argparse.ArgumentParser(description="UART File Transfer using PySerial")
    parser.add_argument("--port", default="/dev/ttyUSB0", help="Serial port (e.g. COM3 or /dev/ttyUSB0)")
    parser.add_argument("--baud", type=int, default=115200, help="Baud rate")
    parser.add_argument("--matrixA", required=True, help="Input file for matrix A to send to FPGA")
    parser.add_argument("--matrixB", required=True, help="Input file for matrix B to send to FPGA")
    parser.add_argument("--rx", default=f'{time.time()}.csv', help="Output file to store received data")
    args = parser.parse_args()

    with serial.Serial(
        port=args.port,
        baudrate=args.baud,
        bytesize=serial.EIGHTBITS,
        parity=serial.PARITY_NONE,
        stopbits=serial.STOPBITS_ONE,
    ) as ser:

        fA = open(args.matrixA)
        fB = open(args.matrixB)
        fOut = open(args.rx)
        matrix_dimension = math.sqrt(fB.read())
        time.sleep(2)  # Allow FPGA/UART to reset

        for i in range(math.ceil(matrix_dimension/64)):

            send_chunk(ser, fA, fB)
            time.sleep(1)
            fOut = receive_chunk(ser, fOut)
            time.sleep(1)

        print("Transfer complete.")

        fA.close()
        fB.close()

        fOut.close()

if __name__ == "__main__":
    main()
