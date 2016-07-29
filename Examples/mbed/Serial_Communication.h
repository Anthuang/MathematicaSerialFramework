#ifndef Serial_Communication_H
#define Serial_Communication_H

#include "mbed.h"
#include "BufferedSerial.h"

class Serial_Communication {
    public:
        /**
         * Creates a Serial_Communication object. Creates a serial connection with the pins tx and rx.
         * Sets the baud rate of the connection to baud_rate.
         * Initializes the values for all public and private variables.
         *
         * Parameters:
         * tx is the pin for the TX line
         * rx is the pin for the RX line
         * baud_rate is baud rate for the serial communication. Must be the same as in Mathematica. Default value is 9600.
         */
        Serial_Communication(PinName tx, PinName rx, int baud_rate = 9600);
        
        /**
         * Reads a packet sent from Mathematica. Function runs until a packet is read, or until function timeouts.
         * Returns true if the packet is read successfully and returns false if packet is broken (checksum mismatch).
         * Also returns false if function timeouts. Destroys the packet before returning false.
         * Sets the public and private variables to values in the packet.
         *
         * Parameters:
         * timeout is time in ms till function timeouts and quits. Default value is 100 ms.
         */
        bool read_packet(int timeout = 100);
        
        /**
         * Destroys the current packet. Does so by setting all the public and private variables back to their initial values.
         * Function must be called before reading another packet.
         */
        void packet_destroy();
        
        int packet_data[256]; // arguments in the packet
        int packet_size; // length of the arguments in the packet
        int packet_id, packet_instruc; // ID and instruction in the packet
        int packet_header, packet_length, packet_checksum; // header, length, and checksum in the packet
        
        BufferedSerial pc; // the serial connection
        
    private:
        /**
         * Validates the checksum. Calculated in the same way as in Mathematica (summing up all the bytes except the checksum itself).
         * Returns true if checksum is the same as in the packet and returns false otherwise.
         */
        bool validate_checksum();
        int packet_mode;
        bool read_mode;
};

#endif

