(* ::Package:: *)

(* ::Title:: *)
(*Servo Control For Snake Robots*)


(* ::Text:: *)
(*This package is an example usage of our Serial Framework package to control snake robots. We implemented functions to set angles for each servo and a loop function to move the snake forward using a mathematical function. This package is not yet well tested, so please use with caution.*)


BeginPackage["ServoControl`"];


Init::usage="Initialize variables.";
SetAngles::usage="Set the angles.";
Setup::usage="Setup all the variables.";
Loop::usage="Run the snake.";


Begin["Private`"];


Needs["SerialFramework`"];


Init[]:=Module[{},
$dev=SerialFramework`ConnectDevice["/dev/cu,usbmodem1413",115200];
];


SetAngles[angles_]:=Module[{},
WriteMessage[$dev, 1, 1, angles];
];


Setup[numServos_]:=Module[{},
$AMP=40.0;$FRE=0.2;$PD=40;$servoCenter=100.0;$numServos=numServos;
$rad=Range[$numServos];$theta=Range[$numServos];
$time=Range[$numServos];$timetwo=0;$PL=1000/FRE;
s={12000,3500,10000,4000,10000};
$servoCenterList={$servoCenter,$servoCenter,$servoCenter,$servoCenter,$servoCenter};
$a={s[[0]],s[[0]]+s[[1]],s[[0]]+s[[1]]+s[[2]],s[[0]]+s[[1]]+s[[2]]+s[[3]],s[[0]]+s[[1]]+s[[2]]+s[[3]]+s[[4]]};
For[j=0,j<$numServos,j++,Module[{},
$rad[[j]]=$FRE/1000*2*Pi*$time[[j]]+$PD*j*Pi/180.0;
$theta[[j]]=$AMP*Sin[$rad[[j]]]+$servoCenter;
]];
(*write the theta/radian angles to each servo here*)
WriteMessage[$dev, 1, 1, $theta];
(*********************************************)
RunScheduledTask[Module[{},
For[i=0,i<$numServos,i++,Module[{},classclassclass
time[[i]]++;
If[$time[[i]]>$PL,$time[[i]]=0];
]];
$timetwo++;
]];
];


Loop[]:=Module[{},
If[$timetwo<$a[[0]],$servoCenter=$servoCenterList[[0]]];
If[$a[[0]]<$timetwo&&$timetwo<$a[[1]],$servoCenter=$servoCenterList[[1]]];
If[$a[[1]]<$timetwo&&$timetwo<$a[[2]],$servoCenter=$servoCenterList[[2]]];
If[$a[[2]]<$timetwo&&$timetwo<$a[[3]],$servoCenter=$servoCenterList[[3]]];
If[$a[[3]]<$timetwo&&$timetwo<$a[[4]],$servoCenter=$servoCenterList[[4]]];
For[j=0,j<$numServos,j++,Module[{},
$rad[[j]]=$FRE/1000*2*Pi*$time[[j]]+$PD*j*Pi/180.0;
$theta[[j]]=$AMP*Sin[$rad[[j]]]+$servoCenter;
];
];
(*write the theta/radian angles to each servo here*)
WriteMessage[$dev, 1, 1, $theta];
(*********************************************)
];


End[];
EndPackage[];
