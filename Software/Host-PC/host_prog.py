import serial
import time
import argparse
import csv


def main():
    parser = argparse.ArgumentParser(description="UART File Transfer using PySerial")
    parser.add_argument("--port", default="/dev/ttyACM0", help="Serial port (e.g. COM3 or /dev/ttyACM0)")
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

        values = []
        fA = open(args.matrixA, 'r', encoding='utf-8-sig')
        reader_A = csv.reader(fA, quoting=csv.QUOTE_NONNUMERIC)

        fB = open(args.matrixB, 'r', encoding='utf-8-sig')
        reader_B = csv.reader(fB, quoting=csv.QUOTE_NONNUMERIC)

        ser.reset_input_buffer()

        m = sum(1 for line in fA)
        fA.seek(0)
        kA = 0
        for line in reader_A:
            for value in line:
                kA += 1
            break
        fA.seek(0)

        kB = sum(1 for line in fB)
        fB.seek(0)
        n = 0
        for line in reader_B:
            for value in line:
                n += 1
            break
        fB.seek(0)

        if (kA != kB):
            print("Matrix A and matrix B hidden dimension do not match. Matrix multiplication is impossible.")
            fA.close()
            fB.close()
        
        k = kA

        # Setup packets
        for dimension in [m, k, n]:
            for byte in int(dimension).to_bytes(4, 'little', signed=False):
                values.append(byte)

        # Matrix A
        for row in reader_A:
            for value in row:
                values.append(int.from_bytes(int(value).to_bytes(1, 'little', signed=True), 'little', signed=False))

        # Matrix B
        for row in reader_B:
            for value in row:
                values.append(int.from_bytes(int(value).to_bytes(1, 'little', signed=True), 'little', signed=False))


        ser.write(values)
        ser.flush()

        print("Transfer complete.")

        fA.close()
        fB.close()


if __name__ == "__main__":
    main()

