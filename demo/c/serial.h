#ifndef _SERIAL_H
#define _SERIAL_H

int set_interface_attribs(int fd, int speed, int parity);
int set_blocking(int fd, int should_block);
int open_serial_port(const char *portname);

#endif