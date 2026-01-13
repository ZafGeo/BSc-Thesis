#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <fcntl.h>
#include <errno.h>
#include <termios.h>
#include <sys/select.h>

#define UART_DEVICE "/dev/ttyUSB0"
#define BAUDRATE B115200

#define START_BYTE 0xAA
#define MAX_PAYLOAD 256

static int uart_open(const char *device);
static int uart_send_frame(int fd, const uint8_t *data, uint8_t len);
static int uart_receive_frame(int fd, uint8_t *data, uint8_t *len);

int main(void)
{
    int fd = uart_open(UART_DEVICE);
    if (fd < 0) {
        return 1;
    }

    /* Example payload */
    const char *msg = "Hello FPGA";
    uart_send_frame(fd, (const uint8_t *)msg, strlen(msg));

    printf("Sent: \"%s\"\n", msg);

    /* Receive loop */
    while (1) {
        uint8_t rx_buf[MAX_PAYLOAD];
        uint8_t rx_len;

        int ret = uart_receive_frame(fd, rx_buf, &rx_len);
        if (ret == 0) {
            printf("Received (%d bytes): ", rx_len);
            for (int i = 0; i < rx_len; i++)
                printf("%c", rx_buf[i]);
            printf("\n");
            break;
        }
    }

    close(fd);
    return 0;
}

/* ------------------------------------------------------------ */

static int uart_open(const char *device)
{
    int fd = open(device, O_RDWR | O_NOCTTY | O_SYNC);
    if (fd < 0) {
        perror("open");
        return -1;
    }

    struct termios tty;
    memset(&tty, 0, sizeof tty);

    if (tcgetattr(fd, &tty) != 0) {
        perror("tcgetattr");
        close(fd);
        return -1;
    }

    cfsetospeed(&tty, BAUDRATE);
    cfsetispeed(&tty, BAUDRATE);

    tty.c_cflag = (tty.c_cflag & ~CSIZE) | CS8;
    tty.c_cflag |= (CLOCAL | CREAD);
    tty.c_cflag &= ~(PARENB | PARODD);
    tty.c_cflag &= ~CSTOPB;
    tty.c_cflag &= ~CRTSCTS;

    tty.c_iflag &= ~(IXON | IXOFF | IXANY);
    tty.c_lflag = 0;
    tty.c_oflag = 0;

    tty.c_cc[VMIN]  = 1;
    tty.c_cc[VTIME] = 1;

    if (tcsetattr(fd, TCSANOW, &tty) != 0) {
        perror("tcsetattr");
        close(fd);
        return -1;
    }

    printf("UART opened: %s\n", device);
    return fd;
}

/* ------------------------------------------------------------ */

static int uart_send_frame(int fd, const uint8_t *data, uint8_t len)
{
    uint8_t frame[2 + MAX_PAYLOAD];
    frame[0] = START_BYTE;
    frame[1] = len;
    memcpy(&frame[2], data, len);

    int total = len + 2;
    int written = write(fd, frame, total);
    if (written != total) {
        perror("write");
        return -1;
    }
    return 0;
}

/* ------------------------------------------------------------ */

static int uart_receive_frame(int fd, uint8_t *data, uint8_t *len)
{
    uint8_t byte;
    static enum { WAIT_START, WAIT_LEN, WAIT_DATA } state = WAIT_START;
    static uint8_t index = 0;
    static uint8_t expected_len = 0;

    while (read(fd, &byte, 1) == 1) {
        switch (state) {
        case WAIT_START:
            if (byte == START_BYTE) {
                state = WAIT_LEN;
            }
            break;

        case WAIT_LEN:
            expected_len = byte;
            index = 0;
            state = WAIT_DATA;
            break;

        case WAIT_DATA:
            data[index++] = byte;
            if (index >= expected_len) {
                *len = expected_len;
                state = WAIT_START;
                return 0;
            }
            break;
        }
    }
    return -1;
}
