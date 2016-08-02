Il# Nucleo Framework
Framework in Mathematica for communication with other platforms for robotic applications.

The goal is to provide a platform where the user can perform both control and data analysis together.

Please read the [documentation file](https://github.com/Anthuang/NucleoFramework/blob/master/SerialDocumentation.pdf) for more information.

## Purpose
We aim to provide a platform where the user can perform tasks, control, and data analysis together. This platform will be a better environment for researchers and programmers alike to interact with robots.
![purpose](https://github.com/Anthuang/NucleoFramework/blob/master/purpose.png)

## Functionality
- [x] Serial communication
- [x] Simple GUI and graphing
- [ ] Improve speed of communication
- [ ] Communication between Mathematica and multiple connected devices
- [ ] Communication between Mathematica and simulation applications

## Serial Protocol
All messages must follow the following format:

**[Start][ID][Length][Instruction][Parameter 1]...[Parameter N][Checksum]**
![flowchart](https://github.com/Anthuang/MathematicaSerialFramework/blob/master/img/serial_flowchart.png)

## IMU Graphing Demo
![demo](https://github.com/Anthuang/MathematicaSerialFramework/blob/master/img/imudemo.gif)

## Usage
In order to use the package, you will need to run
```
Needs["SerialFramework`”]
```
Note that you must have the package’s folder listed under the $Path variable of Mathematica. Without it, Mathematica would not be able to find the package with the Needs[“SerialFramework`”] command. You can check the $Path variable by simply running $Path in Mathematica.

Afterwards, you can run for example
```
$dev = SerialFramework`ConnectDevice[“/dev/cu.submoden1413”, 115200]
SerialFramework`ReadMessage[$dev, 1, 5]
```
Notice that you must write code on whatever platform you are using to interpret the protocol sent from Mathematica. We used mbed (on a Nucleo board) for the snake robot in the examples to receive commands from Mathematica.

For more detailed information on the usage of functions please read the documentation.

## Contact
For any comments or suggestions, please contact us at thomaseh@umich.edu
