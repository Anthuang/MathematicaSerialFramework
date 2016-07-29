#include "Serial_Communication.h"

Serial_Communication::Serial_Communication(PinName tx, PinName rx, int baud_rate) : pc(tx, rx) {
    
    // set the baud rate of the serial communication
    pc.baud(baud_rate);
    
    // initializes variables
    packet_header = packet_id = packet_length = packet_instruc = packet_checksum = -1;
    packet_mode = 0;
    packet_size = 0;
    read_mode = false;
}

bool Serial_Communication::read_packet(int timeout) {
    Timer LocalTimer;
    float init_time = LocalTimer.read();
    int packet_current_size = 0;
    float timetime, timetime2 = 0.0f;
    while(packet_mode != 5) { // while read is not finished
        if(pc.readable()) { // if anything is sent through serial
            if(read_mode) { // read_mode is true when header is detected
                switch(packet_mode) { // current mode or state
                    case 0: // 1. ID
                        packet_id = pc.getc();
                        packet_mode += 1;
                        break;
                    case 1: // 2. Length (num of args + 2)
                        packet_length = pc.getc();
                        packet_size = packet_length - 2;
                        packet_mode += 1;
                        break;
                    case 2: // 3. Instruction
                        packet_instruc = pc.getc();
                        packet_mode += 1;
                        break;
                    case 3: // 4. Args
                        if(packet_current_size < packet_size) {
                            packet_data[packet_current_size] = pc.getc();
                            packet_current_size += 1;
                        } else {
                            packet_mode += 1;
                        }
                        break;
                    case 4: // 5. Checksum
                        packet_checksum = pc.getc();
                        if (!validate_checksum()) {
                            packet_destroy(); // if checksum does not match, destroy the packet (transmission error)
                        return false;
                        }
                        packet_mode += 1;
                        break;
                }
            } else {
                packet_header = pc.getc();
                if(packet_header == 124) { // if header is detected (124 is starting byte)
                    read_mode = true;
                }
            }
        }
        float cur_time = LocalTimer.read();
        if(cur_time > timeout) { // if time is greater than timeout time
            packet_destroy(); // destroy the packet
            return false;
        }
    }
    return true;
}

// destroys the packet (resets all variables to initial values)
void Serial_Communication::packet_destroy() {
    packet_header = packet_id = packet_length = packet_instruc = packet_checksum = -1;
    packet_mode = 0;
    packet_size = 0;
    read_mode = false;
}

// validates the checksum
// calculates the checksum by summing up all the int values except the checksum
// if the sum is greater than 255 (8 bytes), then subtract it by 256
bool Serial_Communication::validate_checksum() {
    int sum = packet_header + packet_id + packet_length + packet_instruc;
    for(int j = 0; j < packet_length - 2; j++) {
        sum += packet_data[j];
    }
    while(sum > 255) {
        sum -= 256;
    }
    return sum == packet_checksum;
}

