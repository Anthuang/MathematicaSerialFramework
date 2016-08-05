(* ::Package:: *)

(* ::Title:: *)
(*Robot Data Visualization*)


(* ::Text:: *)
(*This package is an example usage of our Serial Framework package to display data obtained from robots. We implemented data visualization for data from the IMU and commands sent to the servos. This package must be complemented by the mbed class or else it may not function properly.*)
(**)
(*Note: We wrote and tested this package using a Nucleo-F411RE development board. We have no control over errors that arise due to different boards. We sincerely apologize for any inconvenience.*)


BeginPackage["SnakeRobotVisualization`"];


Init::usage="Initializes variables.
Init[]

Must be run before any other functions are run.
Can also be used to reset all variables.
";
ConnectNucleo::usage="Connects to Nucleo device through Serial.
ConnectNucleo[]

Calls the ConnectDevice function from the SerialFramework package.

Parameters:
dev - address of the board.
baud - baud rate.

For more information, check out the Serial Framework documentation.
";
ConstructIMUGUI::usage="Constructs a simple user interface for IMU.
EnableIMU[]
";
ConstructServoGUI::usage="Constructs a simple user interface for Servo.
ConstructServoGUI[]
";
ReadSerialData::usage="Reads data through serial.
ReadSerialData[]

How to use:
Depending on what buttons are pressed, this function will return the data accordingly. This function runs a While Loop, which means that nothing else can be run while this function is running. Thus, this function should be run after the graphs are enabled.
";


Begin["`Private`"];


Needs["SerialFramework`"];


ConnectNucleo[dev_:"",baud_:9600]:=$dev=SerialFramework`ConnectDevice[dev, baud];


Init[]:=
Module[{},
$gGXList={};
$gGYList={};
$gGZList={};
$gAXList={};
$gAYList={};
$gAZList={};
$gMXList={};
$gMYList={};
$gMZList={};
$gMList={};
$roll=0.0;
$pitch=0.0;
$yaw=0.0;
$pov={0,0,Infinity};
$writeCode="";

(*Flags*)
$runprogram = False;
$IMUflag = False;
$gyrflag = False;
$accflag = False;
$magflag = False;
$IMUgraphflag = False;

(*Angles graph initialization*)
$numservos=1;
$angles={0};
$servograph=Graphics[{RGBColor[0, 0, 0],{Rectangle[{0, 0},{1, 3}],Rectangle[{0, 4},{1, 7}]}},Background->White];
$g2=Graphics[{Yellow,Rectangle[{0.2, 0.25},{0.4,0.5}],Yellow,Rectangle[{0.6,0.25},{0.8,0.5}]}];
$g3=Graphics[{Black,Thick,Line[{{0.5,7.5},{0.5,8.5}}]}];
$g4=Graphics[{Red,Text[0, {0.5,3.5}, {0, 0}]}];
]


EnableGyr[]:=Dynamic[Labeled[ListLinePlot[{$gGXList, $gGYList, $gGZList}, PlotRange->All,PlotRangeClipping->False, ImageSize->Medium, PlotLegends->{"gx","gy", "gz"}],"gyroscope"],UpdateInterval->1]


EnableAcc[]:=Dynamic[Labeled[ListLinePlot[{$gAXList, $gAYList, $gAZList}, PlotRange->All,PlotRangeClipping->False, ImageSize->Medium, PlotLegends->{"ax","ay", "az"}],"accelerometer"],UpdateInterval->1]


EnableMag[]:=Dynamic[Labeled[ListLinePlot[{$gMXList, $gMYList, $gMZList}, PlotRange->All,PlotRangeClipping->False, ImageSize->Medium, PlotLegends->{"mx","my", "mz"}],"magnetometer"],UpdateInterval->1]


EnableAngles[]:=Dynamic[Show[$servograph, $g2, $g3, $g4]]


EnableIMU[]:=
Module[{},
imu:=Graphics3D[Dynamic[GeometricTransformation[Cuboid[{-2,-2,-2},{2,2,2}],RotationTransform[$roll Degree,{1,0,0}].RotationTransform[$pitch Degree,{0,1,0}].RotationTransform[$yaw Degree,{0,0,1}]]],ImageSize->Medium,Axes->True,AxesOrigin->{0,0,0},Boxed->False,PlotRange->{{-5,5},{-5,5},{-5,5}},Ticks->None,ViewPoint->Dynamic[$pov]];
axeslabel=Graphics3D[{Text[Style["x",Large], {7, 0, 0}], Text[Style["y",Large], {0, 7, 0}], Text[Style["z",Large], {0, 0, 7}]}];
Labeled[Show[imu,axeslabel],"IMU"]
RadioButtonBar[Dynamic[$pov],{{0,0,Infinity}->"Above",{0,0,-Infinity}->"Below",{0,-Infinity,0}->Front,{0,Infinity,0}->Back,{Infinity,0,0}->Right,{-Infinity,0,0}->Left}]
]


SetAngles[]:=
Module[{},
(*Initialize values*)
$servocubes = Array[0&, $numservos + 1];
rectstats = Array[0&, $numservos + 1];
angletext = Array[0&, $numservos];

Do[
 $servocubes[[i]] = Rectangle[{0, (i - 1) * 4}, {1, (i - 1) * 4 + 3}];
, {i, $numservos + 1}];
Do[
 rectstats[[i]] = {0.5, 3.5 + (i - 1) * 4};
, {i, $numservos + 1}];

Do[
 Do[
  $servocubes[[j]] = Rotate[$servocubes[[j]], -$angles[[i - 1]]Degree, rectstats[[i - 1]]];
  rectstats[[j]] = RotationTransform[-$angles[[i - 1]]Degree, rectstats[[i - 1]]][rectstats[[j]]];
  , {j, i, $numservos + 1, 1}];
 , {i, 2, $numservos + 1, 1}];
$servograph = Graphics[{RGBColor[0, 0, 0], $servocubes},Background -> White];

(*Eyes and tail for the snake*)
eye1 = Rectangle[{0.2, 0.25}, {0.4, 0.5}];
eye2 = Rectangle[{0.6, 0.25}, {0.8, 0.5}];
$g2 = Graphics[{Yellow, eye1, Yellow, eye2}];
vec = Normalize[rectstats[[$numservos + 1]] - rectstats[[$numservos]]];
tail = Line[{rectstats[[$numservos + 1]], rectstats[[$numservos + 1]] + vec}];
$g3 = Graphics[{Black, Thick, tail}];

(*Angles display with text*)
Do[
 If[$angles[[i]] < 0, angletext[[i]] = Text[$angles[[i]], rectstats[[i]], {0, 0}], angletext[[i]] = Text[$angles[[i]], rectstats[[i]], {0, 0}]];
, {i, $numservos}];
$g4 = Graphics[{Red, angletext}];
]


ConstructIMUGUI[]:=
Module[{},
Print[Column[{
Row[{
Button["Enable Gyr",
 Print[EnableGyr[]];
 $IMUflag = True;
 $gyrflag = True;
],
Button["Disable Gyr",
 $gyrflag = False;
 If[Not[$gyrflag]&&Not[$accflag]&&Not[$magflag]&&Not[$IMUgraphflag],$IMUflag = False,];
]}],
Row[{
Button["Enable Acc",
 Print[EnableAcc[]];
 $IMUflag = True;
 $accflag = True;
],
Button["Disable Acc",
 $accflag = False;
 If[Not[$gyrflag]&&Not[$accflag]&&Not[$magflag]&&Not[$IMUgraphflag],$IMUflag = False,];
]}],
Row[{
Button["Enable Mag",
 Print[EnableMag[]];
 $IMUflag = True;
 $magflag = True;
],
Button["Disable Mag",
 $magflag = False;
 If[Not[$gyrflag]&&Not[$accflag]&&Not[$magflag]&&Not[$IMUgraphflag],$IMUflag = False,];
]}],
Row[{
Button["Enable IMU",
 Print[EnableIMU[]];
 $IMUflag = True;
 $IMUgraphflag = True;
],
Button["Disable IMU",
 $IMUgraphflag = False;
 If[Not[$gyrflag]&&Not[$accflag]&&Not[$magflag]&&Not[$IMUgraphflag],$IMUflag = False,];
]}],
Button["Stop", 
 $runprogram = False;
 $IMUflag = False;
 $gyrflag = False;
 $accflag = False;
 $magflag = False;
 $IMUgraphflag = False;
]}]];
]


ConstructServoGUI[]:=
Module[{},
numservosstring="3";
anglestring="0,0,0";
Print[Column[{
Button["Enable Angles",
 Print[EnableAngles[]];
],
Panel[Grid[{{Style["Plot",Bold],SpanFromLeft},{"Number of Servos:",InputField[Dynamic[numservosstring],String]},{"Angles:",InputField[Dynamic[anglestring],String]},{Button["Send",
 $numservos = ToExpression[numservosstring];
 $angles = ToExpression/@StringSplit[anglestring,","];
 writeangles = Array[0&, $numservos];
 Do[
  writeangles[[i]] = $angles[[i]] + 90;
 , {i, 1, $numservos}]
 SetAngles[];
 If[$runprogram,$anglesflag=True,SerialFramework`WriteMessage[$dev, 1, 1, writeangles]];
]}}]],
Button["Stop",
 $runprogram = False;
 $IMUflag = False;
 $gyrflag = False;
 $accflag = False;
 $magflag = False;
 $IMUgraphflag = False;
]
}]];
]


ReadSerialData[]:=
Module[{},
	$runprogram = True;
	While[$runprogram,
		If[$anglesflag,Module[{},
        	SerialFramework`WriteMessage[$dev, 1, 1, writeangles];
	        $anglesflag=False;
	    ]];
        If[$IMUflag,Module[{},
        	If[$IMUgraphflag,Module[{},
				reader = SerialFramework`ReadMessage[$dev, 1, 5];
				readerarr=StringSplit[reader];
				$roll=ToExpression[Part[readerarr,1]];
				$pitch=ToExpression[Part[readerarr,2]];
				$yaw=ToExpression[Part[readerarr,3]];
        	]];
            If[$gyrflag,Module[{},
				reader = SerialFramework`ReadMessage[$dev, 1, 2];
				readerarr=StringSplit[reader];
				gGX=ToExpression[Part[readerarr, 1]];
				gGY=ToExpression[Part[readerarr, 2]];
				gGZ=ToExpression[Part[readerarr, 3]];
				AppendTo[$gGXList,gGX];
				AppendTo[$gGYList,gGY];
				AppendTo[$gGZList,gGZ];
            ]];
            If[$accflag,Module[{},
				reader = SerialFramework`ReadMessage[$dev, 1, 3];
				readerarr=StringSplit[reader];
				gAX=ToExpression[Part[readerarr, 1]];
				gAY=ToExpression[Part[readerarr, 2]];
				gAZ=ToExpression[Part[readerarr, 3]];
				AppendTo[$gAXList,gAX];
				AppendTo[$gAYList,gAY];
				AppendTo[$gAZList,gAZ];
        	]];
        	If[$magflag,Module[{},
				reader = SerialFramework`ReadMessage[$dev, 1, 4];
				readerarr=StringSplit[reader];
            	gMX=ToExpression[Part[readerarr, 1]];
                gMY=ToExpression[Part[readerarr, 2]];
                gMZ=ToExpression[Part[readerarr, 3]];
                AppendTo[$gMXList,gMX];
                AppendTo[$gMYList,gMY];
                AppendTo[$gMZList,gMZ];
        	]];
        ]];
	]
]


End[];
EndPackage[];
