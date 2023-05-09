import 'dart:async';
import 'package:cando/Models/allUsers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

String mapkey="AIzaSyB8gHnZ83HcD5_XNtl7PCpIXvWlNuz0G50";
User firebaseuser;
Users userCurrentInfo;
int driverRequestTimeOut=20;
Timer timer;
String rideStatus="Driver is coming";
String carDetailsDriver="";
String driversname="";
String driversphone="";
StreamSubscription<Event>rideStreamSubscription;
StreamSubscription<Event>riderequestStreamSubscription;


String statusRide="";
String statusRidetwo="";
double starCounter=0.0;
String title="";
String carRideType="";