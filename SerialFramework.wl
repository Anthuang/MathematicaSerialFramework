(* ::Package:: *)

(* ::Title:: *)
(*Serial Framework*)


BeginPackage["SerialFramework`"];


ConnectDevice::usage = "ConnectDevice[ DeviceAddress_: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote], BaudRate_: 9600 ]
Connects through serial to DeviceAddress. Sets the baud rate to BaudRate. Returns the connection to the device. This connection can be passed into the ReadMessage and WriteMessage functions.

DeviceAddress depends on the operating system of the computer the device is connected to:
Windows: \[OpenCurlyDoubleQuote]COM#\[CloseCurlyDoubleQuote]
MacOS or Linux: \[OpenCurlyDoubleQuote]/dev/ttyXX\[CloseCurlyDoubleQuote] or \[OpenCurlyDoubleQuote]/dev/tty.usbserialXX\[CloseCurlyDoubleQuote] or something similar

Default value of DeviceAddress: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] - connects to nothing.
Default value of BaudRate: 9600 - default baud rate supported by most boards.

Examples:
ConnectDevice[\"/dev/cu.usbmodem1413\"] // for Mac or Linux users
ConnectDevice[\"COM4\"] // for Windows users
";
WriteMessage::usage = "WriteMessage[ Device_: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote], BoardID_: 1, WriteMessageArg_: 0, WriteMessage_: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] ]
Send a write request to the connection Device to the board with ID BoardID with the arguments as WriteMessageArg and WriteMessage. WriteMessage writes an instruction packet with the form [Start][ID][Length][Instruction][WriteMessageArg][Parameter 1]...[Parameter N][Checksum].  Device is the connection to a device. BoardID is an integer which indicates the board to receive information from. WriteMessageArg indicates what to change and WriteMessage indicate what to change it to.

WriteMessageArg is an integer.
WriteMessage is an array of integers or floats.

Default value of DeviceAddress: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] - reads from nothing.
Default value of BoardID: 1 - reads from board with ID 1.
Default value of WriteMessageArg: 0 - writes information to the board with argument as 0.
Default value of WriteMessage: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] - writes nothing. This could unintentionally erase important data, so be careful.

Examples:
dev = ConnectDevice[\"/dev/cu.usbmodem1413\"]  // first connect to device and set a variable to save the connection
WriteMessage[dev,1] // write \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] to board with ID 1 through connection dev with default argument 0.
WriteMessage[dev,1,2] // same as above except the argument is 2. 
WriteMessage[dev,1,1,{40}] // write {40} with argument as 1.
WriteMessage[dev,1,3,{45,45,45}] // write {45,45,45} with argument as 3.
";
ReadMessage::usage = "ReadMessage[ Device_: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote], BoardID_: 1, ReadMessageArg_: 0 ]
Send a read request to the connection Device to the board with ID BoardID with the argument as ReadMessageArg. 
ReadMessage writes an instruction packet with the form [Start][ID][Length][Instruction][ReadMessageArg][Checksum]. Device is the connection to a device . BoardID is an integer which indicates the board to receive information from. ReadMessageArg is an integer which is parsed in the connected device. Depending on the integer, mbed can return different information through serial. ReadMessage returns values received from serial after the read request is sent.

Default value of DeviceAddress: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] - reads from nothing.
Default value of BoardID: 1 - reads from board with ID 1.
Default value of ReadMessageArg: 0 - reads information from the board with argument as 0. 0 is usually used to return all information.

Returns a string.

Examples:
dev = ConnectDevice[\"/dev/cu.usbmodem1413\"]  // first connect to device and set a variable to save the connection
ReadMessage[dev,1] // read from board with ID 1 through connection dev with argument as default, 0.
ReadMessage[dev,1, 2]  // same as above except the argument is 2.
";
DisconnectDevice::usage = "DisconnectDevice[ ]
Disconnects Device.
Default value of Device: \[OpenCurlyDoubleQuote]\[CloseCurlyDoubleQuote] - does nothing.

Example:
dev = ConnectDevice[\"/dev/cu.usbmodem1413\"]
DisconnectionDevice[dev] // disconnects the connection dev
";


Begin["`Private`"];


ConnectDevice[dev_, baud_: 9600]:=
Module[{},
$startbit = 124;
Return[DeviceOpen["Serial", {dev, "BaudRate" -> baud}]];
];


WriteMessage[dev_, boardid_: 1, arg_: 0, msg_]:=
Module[{},
 numparam = Length[msg] + 1;
 len = numparam + 2;
 func = 0;

 (*Write protocol separately*)
 DeviceWrite[dev, $startbit];
 DeviceWrite[dev, boardid];
 DeviceWrite[dev, len];
 DeviceWrite[dev, func];
 DeviceWrite[dev, arg];

 (*Checksum*)
 sum = $startbit + boardid + len + func + arg;
 Do[
  DeviceWrite[dev, msg[[i]]];
  sum = sum + msg[[i]];
 , {i, 1, Length[msg]}]

 (*Make sure checksum is below 256 before writing*)
 While[sum > 255, sum = sum - 256;];
 DeviceWrite[dev, sum];
]


ReadMessage[dev_, boardid_: 1, arg_: 0]:=
Module[{},
 DeviceReadBuffer[dev];

 len = 3;
 func = 1;

 (*Write protocol separately*)
 DeviceWrite[dev, $startbit];
 DeviceWrite[dev, boardid];
 DeviceWrite[dev, len];
 DeviceWrite[dev, func];
 DeviceWrite[dev, arg];

 (*Checksum*)
 sum = $startbit + boardid + len + func + arg;
 While[sum > 255, sum = sum - 256;];
 DeviceWrite[dev, sum];

 (*Read character by character from serial until semicolon*)
 token = "1";
 reader = "";
 While[token!=";",
  token = FromCharacterCode[DeviceRead[dev]];
  If[token==";", Break;,reader = reader <> ToString[token];];
 ];
 Return[reader];
]


DisconnectDevice[dev_]:=DeviceClose[dev];


End[];
EndPackage[];
