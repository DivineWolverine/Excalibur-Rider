

import 'dart:async';

import 'package:animated_text_kit/animated_text_kit.dart';
import 'package:cando/AllScreens/HistoryScreen.dart';
import 'package:cando/AllScreens/SearchScreen.dart';
import 'package:cando/AllScreens/aboutScreen.dart';
import 'package:cando/AllScreens/loginScreen.dart';
import 'package:cando/AllScreens/profileTabPage.dart';
import 'package:cando/AllScreens/ratingScreen.dart';
import 'package:cando/AllWidgets/CollectFareDialog.dart';
import 'package:cando/AllWidgets/DividerWidget.dart';
import 'package:cando/AllWidgets/NoDriverAvailableDialog.dart';
import 'package:cando/AllWidgets/progressDialog.dart';
import 'package:cando/Assistants/assistantMethods.dart';
import 'package:cando/Assistants/geofireAssistant.dart';
import 'package:cando/DataHandler/appData.dart';
import 'package:cando/Models/directionDetails.dart';
import 'package:cando/Models/nearbyAvailableDrivers.dart';
import 'package:cando/Notificationss.dart';
import 'package:cando/configMaps.dart';
import 'package:cando/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_geofire/flutter_geofire.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

void main(){
  runApp(new MaterialApp(
home: new MainScreen(),
),);
}

class MainScreen extends StatefulWidget{


  static const String idScreen="mainScreen";
  @override
  _State createState()=>new _State();
}
class _State extends State<MainScreen> with TickerProviderStateMixin {
  Completer<GoogleMapController>_controllerGoogleMap = Completer();
  GoogleMapController newGoogleMapController;
  GlobalKey<ScaffoldState>scaffoldKey = new GlobalKey<ScaffoldState>();
  directionDetails tripDirectionDetails;

  List<LatLng>plineCoordinates = [];
  Set<Polyline>polylineSet = {};
  Set<Marker>markersSet = {};
  Set<Circle>circleSet = {};
  double rideDetailsContainerHeight = 0;
  double requestRideContainerHeight = 0;
  double searchContainerHeight = 300.0;
  bool drawerOpen = true;
  bool nearbyAvailableDriversLoaded=false;
  DatabaseReference rideRequestRef;
BitmapDescriptor nearbyIcon;
List<NearbyAvailableDrivers>availableDrivers;
  String state="normal";
  String uName="";
  // Timer timer;
  double driverDetailsContainerHeight=0;
  bool isRequestingPositionDetails=false;
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    AssistantMethods.getCurrentOnlineUserInfo();
  }

  void saveRideRequest() {
    rideRequestRef =
        FirebaseDatabase.instance.reference().child("Ride Requests");
    var pickUp = Provider
        .of<AppData>(context, listen: false)
        .pickUplocation;
    var dropoff = Provider
        .of<AppData>(context, listen: false)
        .dropOffLocation;
    Map pickUpLocMap = {
      "latitude": pickUp.latitude.toString(),
      "longitude": pickUp.longitude.toString(),
    };
    Map dropOffLocMap = {
      "latitude": dropoff.latitude.toString(),
      "longitude": dropoff.longitude.toString(),
    };
    Map riderInfoMap = {
      "driver_id": "waiting",
      "payment_method": "cash",
      "pickup": pickUpLocMap,
      "dropoff": dropOffLocMap,
      "created_at": DateTime.now().toString(),
      "rider_name": userCurrentInfo.name,
      "rider_phone": userCurrentInfo.phone,
      "pickup_address": pickUp.placeName,
      "dropoff_address": dropoff.placeName,
      "ride_type":carRideType,
    };
    // rideRequestRef.push().set(riderInfoMap);
    rideRequestRef.push().set(riderInfoMap);


  }

  void displayRequestRideContainer() {
    setState(() {
      requestRideContainerHeight = 250.0;
      rideDetailsContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      drawerOpen = true;
    });
    saveRideRequest();
  }

  void cancelRequest() {
    rideRequestRef.remove();
    setState(() {
      state="normal";
    });
  }

  void displayRideDetailsContainer() async {
    await getPlaceDirection();
    setState(() {
      searchContainerHeight = 0;
      rideDetailsContainerHeight = 340.0;
      bottomPaddingOfMap = 360.0;
      drawerOpen = false;
    });
  }
  void displayDriverDetailsContainer(){
    setState(() {
      requestRideContainerHeight=0.0;
      rideDetailsContainerHeight=0.0;
      bottomPaddingOfMap=250.0;
      driverDetailsContainerHeight=330.0;
    });
  }

  Position currentPosition;
  var geolocator = Geolocator();
  double bottomPaddingOfMap = 0;

  void locationPosition() async {
    Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high
    );
    currentPosition = position;
    LatLng latLatPosition = LatLng(position.latitude, position.longitude);
    CameraPosition cameraPosition = new CameraPosition(
        target: latLatPosition, zoom: 14);
    newGoogleMapController.animateCamera(
        CameraUpdate.newCameraPosition(cameraPosition
        ));
    String address = await AssistantMethods.searchcoordinateAddress(
        position, context);
    print("This is your Address ::" + address);
    initGeoFireListener();
    uName=userCurrentInfo.name;
    AssistantMethods.retrieveHistoryinfo(context);
  }

  final CameraPosition _kGooglePlex = CameraPosition(target:
  LatLng(6.927079, 79.861244), zoom: 14.4746
  );

  @override
  Widget build(BuildContext context) {
    createIconMarker();
    return Scaffold(
      drawer: Container(
        color: Colors.white,
        width: 255.0,
        child: Drawer(
          child: ListView(
            children: [
              Container(
                height: 165.0,
                child: DrawerHeader(
                  decoration: BoxDecoration(
                    color: Colors.white,
                  ), child: Row(
                  children: [
                    Image.asset(
                      "images/user_icon.png", height: 65.0, width: 65.0,),
                    SizedBox(width: 16.0,),
                    Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(uName, style: TextStyle(
                          fontSize: 16.0,
                          fontFamily: "Brand Bold",
                        ),

                        ), SizedBox(height: 6.0,),
                        GestureDetector(onTap: (){
                          Navigator.push(context, MaterialPageRoute(builder:(context)=>ProfileTabPage()));
                        },
                        child: GestureDetector(
                            onTap: (){
                              Navigator.push(context, MaterialPageRoute(builder:(context)=>ProfileTabPage()));
                            },
                            child: Text("Visit Profile"))),

                      ],
                    ),
                  ],
                ),
                ),
              ), DividerWidget(),
              SizedBox(height: 12.0,),
              GestureDetector(
                onTap: (){
                  Navigator.push(context, MaterialPageRoute(builder: (context)=>HistoryScreen()));
                },
                child: ListTile(leading: Icon(Icons.history),
                  title: Text("History", style: TextStyle(
                    fontSize: 15.0,
                  ),
                  ),
                ),
              ),
              ListTile(leading: Icon(Icons.person), title: GestureDetector(
                onTap: (){

                  Navigator.push(context, MaterialPageRoute(builder:(context)=>ProfileTabPage()));
                },
                child: Text(
                  "Visit Profile", style: TextStyle(
                  fontSize: 15.0,

                ),
                ),
              ),
              ),
              GestureDetector(
                onTap: (){
                  Navigator.pushNamedAndRemoveUntil(context, aboutScreen.idScreen, (route) => false);
                },
                child: ListTile(leading: Icon(Icons.info), title: Text(
                  "About", style: TextStyle(
                  fontSize: 15.0,

                ),
                ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  FirebaseAuth.instance.signOut();
                  Navigator.pushNamedAndRemoveUntil(
                      context, LoginScreen.idScreen, (route) => false);
                },
                child: ListTile(
                  leading: Icon(Icons.logout),
                  title: Text("Sign Out", style: TextStyle(
                      fontSize: 15.0
                  ),),
                ),
              ),
            ],
          ),
        ),

      ),

      body: Stack(
        children: [
          GoogleMap(
            padding: EdgeInsets.only(bottom: bottomPaddingOfMap),
            mapType: MapType.normal,
            myLocationButtonEnabled: true,
            myLocationEnabled: true,
            zoomControlsEnabled: true,
            zoomGesturesEnabled: true,
            polylines: polylineSet,
            markers: markersSet,
            circles: circleSet,
            initialCameraPosition: _kGooglePlex,
            onMapCreated: (GoogleMapController controller) {
              _controllerGoogleMap.complete(controller);
              newGoogleMapController = controller;
              setState(() {
                bottomPaddingOfMap = 300.0;
              });
              locationPosition();
            },),
          //hambuger button for drawer
          Positioned(top: 38.0, left: 22.0,
            child: GestureDetector(

              onTap: () {
                if (drawerOpen) {
                  scaffoldKey.currentState.openDrawer();
                } else {
                  resetApp();
                }
              },
              child: Container(
                decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(22.0), boxShadow: [
                  BoxShadow(
                    blurRadius: 6.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                        0.7, 0.7
                    ),
                  ),

                ]
                ), child: CircleAvatar(
                backgroundColor: Colors.white,
                child: Icon((drawerOpen) ? Icons.menu : Icons.close,
                  color: Colors.black,), radius: 20.0,
              ),
              ),
            ),),
          //search ui
          Positioned(
            left: 0.0, right: 0.0, bottom: 0.0,
            child:

            AnimatedSize(
              vsync: this, curve: Curves.bounceIn,
              duration: new Duration(milliseconds: 160),
              child: Container(

                height: searchContainerHeight, decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(18.0),
                    topRight: Radius.circular(18.0),
                  ), boxShadow: [
                BoxShadow(
                    color: Colors.black, blurRadius: 16.0, spreadRadius: 0.5,
                    offset: Offset(
                        0.7, 07
                    )),
              ]
              ), child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0, vertical: 18.0,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(height: 6.0,),
                    Text(
                      "Hi there", style: TextStyle(
                      fontSize: 12.0,
                    ),
                    ),
                    Text(
                      "Where To", style: TextStyle(
                      fontSize: 20.0,
                      fontFamily: "Brand Bold",
                    ),
                    ), SizedBox(
                      height: 20.0,
                    ), GestureDetector(
                      onTap: () async {
                        var res = await Navigator.push(context,
                            MaterialPageRoute(
                                builder: (context) => SearchScreen()));
                        if (res == "obtainDirection") {
                          displayRideDetailsContainer();
                        }
                      },
                      child: Container(
                        decoration: BoxDecoration(color: Colors.white,
                            borderRadius: BorderRadius.circular(5.0),
                            boxShadow: [
                              BoxShadow(
                                  color: Colors.black54,
                                  blurRadius: 6.0,
                                  spreadRadius: 0.5,
                                  offset: Offset(
                                    0.7, 0.7,
                                  )
                              ),
                            ]
                        ), child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.search, color: Colors.blueAccent,),
                            SizedBox(width: 10.0,),
                            Text(
                                "Search Drop Off"
                            ),
                          ],
                        ),
                      ),
                      ),
                    ), SizedBox(height: 24.0,),
                    Row(
                      children: [
                        Icon(
                          Icons.home,
                          color: Colors.grey,

                        ), SizedBox(
                          width: 12.0,
                        ),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(Provider
                                .of<AppData>(context)
                                .pickUplocation != null ?
                            Provider
                                .of<AppData>(context)
                                .pickUplocation
                                .placeName : "Add Home",),
                            SizedBox(height: 4.0,),
                            Text(
                              "Your living home Address",
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 12.0,
                              ),
                            ),
                          ],
                        ),

                      ],
                    ),

                    SizedBox(height: 10.0,),
                    DividerWidget(),
                    SizedBox(height: 16.0,),
                    Row(
                      children: [
                        Icon(Icons.work, color: Colors.grey,
                        ), SizedBox(width: 12.0,),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text("Add work"),
                            SizedBox(height: 4.0,),
                            Text("Your official address", style: TextStyle(
                              color: Colors.black54, fontSize: 12.0,
                            ),),
                          ],
                        )
                      ],
                    ),
                  ],
                ),
              ),

              ),
            ),),
          //ride details ui
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              height: rideDetailsContainerHeight,
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0),),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black,
                    blurRadius: 16.0,
                    spreadRadius: 0.5,
                    offset: Offset(
                      0.7,0.7,
                    ),
                  ),
                ],
              ),
              child: Padding(
                padding:EdgeInsets.symmetric(vertical: 17.0),
                child: Column(
                  children: [
                    //bike Ride
                    GestureDetector(
                      onTap: (){

                       displayToastMesssage("searching bike...", context);
                        setState(() {
                          state="requesting";
                          carRideType="bike";

                        });
                        displayRequestRideContainer();
                        availableDrivers=GeofireAssistant.nearbyAvailableDriversList;
                        searchNearbyDriver();

                        setState(() {
                          if(availableDrivers.length!=0) {
                            var driver = availableDrivers[0];
                                catchDriver(driver);
                          }else{
                            searchNearbyDriver();
                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,

                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/bike.png",height: 70.0,width: 80.0,),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Bike",style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Brand-Bold",
                                  ),
                                  ),
                                  Text(
                                    ((tripDirectionDetails!=null)?tripDirectionDetails.distanceText:''),style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails!=null)?'\$${(AssistantMethods.calculatefares(tripDirectionDetails))/2}':''),style: TextStyle(
                                fontFamily: "Brand-Bold",
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Divider(height: 2.0,thickness: 2.0,),
                    SizedBox(height: 10.0,),
                    //candogo Ride
                    GestureDetector(
                      onTap: (){
                        displayToastMesssage("searching cando-go..", context);
                        setState(() {
                          state="requesting";
                          carRideType="cando-go";
                        });
                        displayRequestRideContainer();
                        availableDrivers=GeofireAssistant.nearbyAvailableDriversList;
                        searchNearbyDriver();

                        setState(() {
                          if(availableDrivers.length!=0) {
                            var driver = availableDrivers[0];
                            // aiyooo(driver);
                            catchDriver(driver);
                          }else{
                            searchNearbyDriver();

                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,

                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/ubergo.png",height: 70.0,width: 80.0,),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cando-Go",style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Brand-Bold",
                                  ),
                                  ),
                                  Text(
                                    ((tripDirectionDetails!=null)?tripDirectionDetails.distanceText:''),style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails!=null)?'\$${AssistantMethods.calculatefares(tripDirectionDetails)}':''),style: TextStyle(
                                fontFamily: "Brand-Bold",
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Divider(height: 2.0,thickness: 2.0,),
                    SizedBox(height: 10.0,),
                    //Cando-x Ride
                    GestureDetector(
                      onTap: (){
                        displayToastMesssage("searching cando-x...", context);
                        setState(() {
                          state="requesting";
                          carRideType="cando-x";

                        });
                        displayRequestRideContainer();
                        availableDrivers=GeofireAssistant.nearbyAvailableDriversList;
                        searchNearbyDriver();

                        setState(() {
                          if(availableDrivers.length!=0) {
                            var driver = availableDrivers[0];
                            // aiyooo(driver);
                            catchDriver(driver);
                          }else{
                            searchNearbyDriver();

                          }
                        });
                      },
                      child: Container(
                        width: double.infinity,

                        child: Padding(
                          padding:EdgeInsets.symmetric(horizontal: 16.0),
                          child: Row(
                            children: [
                              Image.asset("images/uberx.png",height: 70.0,width: 80.0,),
                              SizedBox(
                                width: 16.0,
                              ),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Cando-X",style: TextStyle(
                                    fontSize: 18.0,
                                    fontFamily: "Brand-Bold",
                                  ),
                                  ),
                                  Text(
                                    ((tripDirectionDetails!=null)?tripDirectionDetails.distanceText:''),style: TextStyle(
                                    fontSize: 16.0,
                                    color: Colors.grey,
                                  ),
                                  ),
                                ],
                              ),
                              Expanded(child: Container()),
                              Text(
                                ((tripDirectionDetails!=null)?'\$${(AssistantMethods.calculatefares(tripDirectionDetails))*2}':''),style: TextStyle(
                                fontFamily: "Brand-Bold",
                              ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 10.0,),
                    Divider(height: 2.0,thickness: 2.0,),
                    SizedBox(height: 10.0,),
                    Padding(padding:EdgeInsets.symmetric(horizontal: 20.0),
                      child: Row(
                        children: [
                          Icon(
                            FontAwesomeIcons.moneyCheckAlt,size: 18.0,color: Colors.black54,),
                          SizedBox(width: 16.0,),
                          Text("Cash"),
                          SizedBox(width: 6.0,),
                          Icon(Icons.keyboard_arrow_down,color: Colors.black54,size: 16.0,),
                        ],
                      ),
                    ),



                  ],
                ),
              ),
            ),
          ),

          //request or cancel ui
          Positioned(
            bottom: 0.0,
            left: 0.0,
            right: 0.0,
            child: Container(
              decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(16.0), topRight:
                  Radius.circular(16.0),

                  ), color: Colors.white,
                  boxShadow: [
                    BoxShadow(spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7, 0.7),),
                  ]
              ), height: requestRideContainerHeight,
              child: Padding(
                padding: const EdgeInsets.all(30.0),
                child: Column(
                  children: [
                    SizedBox(height: 12.0,),
                    SizedBox(
                      width: double.infinity, child: ColorizeAnimatedTextKit(
                      onTap: () {
                        print("Tap Event");
                      },
                      text: [
                        "Requesting a Ride.... ",
                        "Please Wait...",
                        "Finding a Driver",
                      ],
                      textStyle: TextStyle(
                        fontSize: 55.0,
                        fontFamily: "Signatra",


                      ),
                      colors: [
                        Colors.green,
                        Colors.purple,
                        Colors.pink,
                        Colors.blue,
                        Colors.yellow,
                        Colors.red,
                      ],
                      textAlign: TextAlign.center,


                    ),
                    ),
                    SizedBox(height: 22.0,),
                    GestureDetector(
                      onTap: () {
                        cancelRequest();
                        resetApp();
                      },
                      child: Container(
                        height: 60.0,
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(26.0),
                          border: Border.all(width: 2.0,
                              color: Colors.grey[300]),

                        ), child: Icon(Icons.close, size: 26.0,),

                      ),
                    ), SizedBox(height: 10.0,),
                    Container(width: double.infinity,
                      child: Text(
                        "Cancel Ride", textAlign: TextAlign.center, style:
                      TextStyle(fontSize: 12.0),),),
                  ],
                ),
              ), alignment: AlignmentDirectional.topStart,

            ),
          ),
          //display assigned driver info
          //display assigned rider info
          Positioned(bottom: 0.0,left: 0.0,right: 0.0,
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.only(topLeft: Radius.circular(16.0),topRight: Radius.circular(16.0)),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      spreadRadius: 0.5,
                      blurRadius: 16.0,
                      color: Colors.black54,
                      offset: Offset(0.7,0.7),
                    ),
                  ],
                ),height: driverDetailsContainerHeight,
                child: Padding(
                  padding:const EdgeInsets.symmetric(horizontal: 24.0,vertical: 18.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(height: 6.0,),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(rideStatus,textAlign: TextAlign.center,style: TextStyle(
                            fontSize: 18.0,fontFamily: "Brand-Bold",
                          ),),

                        ],
                      ),   SizedBox(height: 22.0,),
                      Divider(height: 2.0,thickness: 2.0,),
                      SizedBox(height: 22.0,),
                      Text(carDetailsDriver??'',style: TextStyle(color: Colors.grey),),
                      Text(driversname??'',style: TextStyle(fontSize: 20.0,)),
                      SizedBox(height: 22.0,),
                      Divider(),
                      SizedBox(height: 22.0,),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 20.0,),
                            child: RaisedButton(
                              onPressed: ()async{
                                await launch(("tel://$driversphone"));
                              },
                              color: Colors.pink,
                              child: Padding(
                                padding: EdgeInsets.all(17.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                  children: [
                                    Text("Call Driver",
                                      style: TextStyle(
                                        fontSize: 20.0,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.white,
                                      ),),Icon(Icons.call,color: Colors.white,size: 26.0,),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ],),
                    ],
              ),
            ),
          ) ),
        ],
      ),
    );
  }

  Future<void> getPlaceDirection() async {
    var initialPos = Provider
        .of<AppData>(context, listen: false)
        .pickUplocation;
    var finalPos = Provider
        .of<AppData>(context, listen: false)
        .dropOffLocation;
    var pickuplatLang = LatLng(initialPos.latitude, initialPos.longitude);
    var dropOfflatLang = LatLng(finalPos.latitude, finalPos.longitude);
    showDialog(context: context,
        builder: (BuildContext context) =>
            ProgressDialog(message: "Please wait..",)
    );
    var details = await AssistantMethods.obtainplacedirectionDetails(
        pickuplatLang, dropOfflatLang);
    setState(() {
      tripDirectionDetails = details;
    });
    Navigator.pop(context);
    print("This is Encoded Points::");
    print(details.encodedPoints);
    PolylinePoints polylinePoints = PolylinePoints();
    List<PointLatLng> decodedPolylinePointsResult = polylinePoints
        .decodePolyline(details.encodedPoints);
    plineCoordinates.clear();
    if (decodedPolylinePointsResult.isNotEmpty) {
      decodedPolylinePointsResult.forEach((PointLatLng pointLatLng) {
        plineCoordinates.add(
            LatLng(pointLatLng.latitude, pointLatLng.longitude));
      });
      polylineSet.clear();
      setState(() {
        Polyline polyline = Polyline(color: Colors.pink,
          polylineId: PolylineId("PolylineID"),
          jointType: JointType.round,
          points: plineCoordinates,
          width: 5,
          startCap: Cap.roundCap,
          endCap: Cap.roundCap,
          geodesic: true,);
        polylineSet.add(polyline);
      });
      LatLngBounds latLngBounds;
      if (pickuplatLang.latitude > dropOfflatLang.latitude &&
          pickuplatLang.longitude > dropOfflatLang.longitude) {
        latLngBounds =
            LatLngBounds(southwest: dropOfflatLang, northeast: pickuplatLang);
      } else if (pickuplatLang.longitude > dropOfflatLang.longitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(pickuplatLang.latitude, dropOfflatLang.longitude
            ),
            northeast: LatLng(
                dropOfflatLang.latitude, pickuplatLang.longitude));
      } else if (pickuplatLang.latitude > dropOfflatLang.latitude) {
        latLngBounds = LatLngBounds(
            southwest: LatLng(dropOfflatLang.latitude, pickuplatLang.longitude
            ),
            northeast: LatLng(
                pickuplatLang.latitude, dropOfflatLang.longitude));
      } else {
        latLngBounds =
            LatLngBounds(southwest: pickuplatLang, northeast: dropOfflatLang);
      }
      newGoogleMapController.animateCamera(
          CameraUpdate.newLatLngBounds(latLngBounds, 70));
      Marker pickupLocMarker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(
              BitmapDescriptor.hueYellow), infoWindow: InfoWindow(
        title: initialPos.placeName, snippet: "My Location",
      ), position: pickuplatLang, markerId: MarkerId("pickupID"));
      Marker dropoffLocMarker = Marker(
          icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
          infoWindow: InfoWindow(
            title: finalPos.placeName, snippet: "Drop Off Location",
          ),
          position: dropOfflatLang,
          markerId: MarkerId("dropoffID"));
      setState(() {
        markersSet.add(pickupLocMarker);
        markersSet.add(dropoffLocMarker);
      });
      Circle pickupLocCircle = Circle(fillColor: Colors.blueAccent,
        center: pickuplatLang,
        radius: 12,
        strokeWidth: 4,
        strokeColor: Colors.blueAccent,
        circleId: CircleId("pickupID"),
      );
      Circle dropoffLocCircle = Circle(fillColor: Colors.red,
          center: dropOfflatLang,
          radius: 12,
          strokeWidth: 4,
          strokeColor: Colors.deepPurple,
          circleId: CircleId("dropoffID"));
      setState(() {
        circleSet.add(pickupLocCircle);
        circleSet.add(dropoffLocCircle);
      });
    }
  }

  resetApp() {
    setState(() {
      drawerOpen = true;
      searchContainerHeight = 300.0;
      rideDetailsContainerHeight = 0;
      requestRideContainerHeight = 0;
      bottomPaddingOfMap = 230.0;
      polylineSet.clear();
      markersSet.clear();
      circleSet.clear();
      plineCoordinates.clear();
      statusRide=null;
      driversname=null;
      driversphone=null;
      rideStatus="Driver is Coming";
      driverDetailsContainerHeight=0.0;
    });
    locationPosition();
  }

  void initGeoFireListener() {
    //comment
    Geofire.initialize("availableDrivers");
    Geofire.queryAtLocation(
        currentPosition.latitude, currentPosition.longitude, 15).listen((
        map) {
      print(map);
      if (map != null) {
        var callBack = map['callBack'];

        //latitude will be retrieved from map['latitude']
        //longitude will be retrieved from map['longitude']

        switch (callBack) {
          case Geofire.onKeyEntered:
            NearbyAvailableDrivers NearbyavailableDrivers=NearbyAvailableDrivers();
            NearbyavailableDrivers.key=map['key'];
            NearbyavailableDrivers.latitude=map['latitude'];
            NearbyavailableDrivers.longitude=map['longitude'];
            GeofireAssistant.nearbyAvailableDriversList.add(NearbyavailableDrivers);
             if(nearbyAvailableDriversLoaded==true){
               updateAvailableDriversOnMap();
             }
            break;

          case Geofire.onKeyExited:
            GeofireAssistant.removeDriverFromList(map['key']);
updateAvailableDriversOnMap();
            break;

          case Geofire.onKeyMoved:
            NearbyAvailableDrivers NearbyavailableDrivers=NearbyAvailableDrivers();
            NearbyavailableDrivers.key=map['key'];
            NearbyavailableDrivers.latitude=map['latitude'];
            NearbyavailableDrivers.longitude=map['longitude'];
            GeofireAssistant.updateDriverNearbyLocation(NearbyavailableDrivers);
                 updateAvailableDriversOnMap();

            break;
          case Geofire.onGeoQueryReady:
           updateAvailableDriversOnMap();

            break;
        }
      }

      setState(() {});
    });
    //comment

  }
  void updateAvailableDriversOnMap(){
    setState(() {
      markersSet.clear();
    });
    Set<Marker> setMarkers=Set<Marker>();
    for(NearbyAvailableDrivers driver in GeofireAssistant.nearbyAvailableDriversList){
      LatLng driverAvailablePosition=LatLng(driver.latitude, driver.longitude);
      Marker marker=Marker(markerId: MarkerId('driver${driver.key}'),
      position: driverAvailablePosition,
        icon: nearbyIcon,
        rotation: AssistantMethods.createRandomNumber(360)

      );
      setMarkers.add(marker);
    }
    setState(() {
      markersSet=setMarkers;
    });
  }
  void createIconMarker(){
    if(nearbyIcon==null){
      ImageConfiguration imageConfiguration=createLocalImageConfiguration(context,size: Size(2, 2));
      BitmapDescriptor.fromAssetImage(imageConfiguration, "images/car_ios.png").then((value) {nearbyIcon=value;});
    }
  }
  void noDriverFound(){
    showDialog(context: context,barrierDismissible: false
        , builder:(BuildContext context)=>NodriverNearbyAvailableDialog());
  }
  void searchNearbyDriver(){
    if(availableDrivers.length==0){
      cancelRequest();
      resetApp();
      noDriverFound();
      return;

    }
    // var driver=availableDrivers[0];
    // availableDrivers.removeAt(0);
    // NotifyDriver(driver);


    var driver=availableDrivers[0];
    driversRef.child(driver.key).child("car_details").child("type").once().then((DataSnapshot snap)async{
      if(await snap.value!=null){
        String carType=snap.value.toString();
        if(carType==carRideType){
          availableDrivers.removeAt(0);
          NotifyDriver(driver);
          // crazy(driver);
        }else{
          displayToastMesssage(carType+"Driver not available, Try Again..", context);
          // setState(() {
          //   cancelRequest();
          //   resetApp();
          //   noDriverFound();
          // });
        }
      }else{
        displayToastMesssage("No Car Found! Try Again..", context);
        // cancelRequest();
        // resetApp();
        // noDriverFound();
      }
    });
  }
  void NotifyDriver(NearbyAvailableDrivers driver) {
    // DatabaseReference driversRef =
    // FirebaseDatabase.instance.reference().child("drivers");
    driversRef.child(driver.key).once().then((DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        String stat = datasnapshot.value['newRide'].toString();

        print("cando" + stat);
        if (stat == "searching") {
          Notifictaionss notifictaionss = Notifictaionss();
          notifictaionss.initialize(context);
          notifictaionss.showNotification(context);
        } else {
          return;
        }
        const onesecondPassed = Duration(seconds: 1);
        timer = Timer.periodic(onesecondPassed, (timer) {
          if (state != "requesting") {
            driversRef.child(driver.key).child("newRide").set("cancelled");
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 1;
            timer.cancel();
          }
          driverRequestTimeOut = driverRequestTimeOut - 1;

          driversRef
              .child(driver.key)
              .child("newRide")
              .onValue
              .listen((event) {
            if (event.snapshot.value.toString() == "accepted") {
              driversRef.child(driver.key).child("newRide").onDisconnect();
              driverRequestTimeOut = 1;
              timer.cancel();
              catchDriver(driver);
            }
          });
          if (driverRequestTimeOut == 0) {
            driversRef.child(driver.key).child("newRide").set("searching");
            driversRef.child(driver.key).child("newRide").onDisconnect();
            driverRequestTimeOut = 1;
            timer.cancel();
            searchNearbyDriver();
          }

        });
      }
      });
    }

  void catchDriver(NearbyAvailableDrivers driver){

    rideStreamSubscription = driversRef.child(driver.key).onValue.listen((event) async {
      if(event.snapshot.value == null)
      {
        return;
      }
      if(statusRide == "accepted") {

        displayDriverDetailsContainer();
        Geofire.stopListener();
        deleteGroFireMarkers();
        rideStat(driver);
      }
      if(event.snapshot.value["car_details"] != null)
      {
        setState(() {
          carDetailsDriver= event.snapshot.value["car_details"]["car_color"].toString()+" "+event.snapshot.value["car_details"]["car_model"].toString();
        });
      }
      if(event.snapshot.value["name"] != null)
      {
        setState(() {
          driversname = event.snapshot.value["name"].toString();
        });
      }
      if(event.snapshot.value["phone"] != null)
      {
        setState(() {
          driversphone= event.snapshot.value["phone"].toString();
        });
      }
      if(event.snapshot.value["newRide"] != null)
      {
        statusRide = event.snapshot.value["newRide"].toString();
      }
});


  }
void catchTheDriver(){
  rideStreamSubscription=rideRequestRef.onValue.listen((event) {
    if(event.snapshot.value == null)
    {
      return;
    }
    if(event.snapshot.value["status"]!=null){
      statusRide=event.snapshot.value["status"].toString();
    }
    if(statusRide=="accepted"){
      displayDriverDetailsContainer();

    }
    if(event.snapshot.value["car_details"]!=null){
      setState(() {
        carDetailsDriver=event.snapshot.value["car_details"].toString();
      });
    }
    if(event.snapshot.value["driver_name"]!=null){
      setState(() {
        driversname=event.snapshot.value["driver_name"].toString();
      });
    }
    if(event.snapshot.value["driver_phone"]!=null){
      setState(() {
        driversname=event.snapshot.value["driver_phone"].toString();
      });
    }
  });

}
  void updateDriverTimeToPickUpLocation(LatLng drivercurrlocation)async{
    if(isRequestingPositionDetails==false){
      isRequestingPositionDetails=true;
      var PositionUserlatlng=LatLng(currentPosition.latitude, currentPosition.longitude);
      var details=await AssistantMethods.obtainplacedirectionDetails(drivercurrlocation,PositionUserlatlng);
      if(details==null){
        return;
      }
      setState(() {
        rideStatus="Driver is Coming -"+details.durationText;
      });isRequestingPositionDetails=false;
    }
  }
  void updateDriverTimeToDropOffLocation(LatLng drivercurrlocation)async{
    if(isRequestingPositionDetails==false){
      isRequestingPositionDetails=true;
      var dropoff=Provider.of<AppData>(context,listen: false).dropOffLocation;
      var Dropofflatlng=LatLng(dropoff.latitude, dropoff.longitude);
      var details=await AssistantMethods.obtainplacedirectionDetails(drivercurrlocation,Dropofflatlng);
      if(details==null){
        return;
      }
      setState(() {
        rideStatus="Going To Destination -"+details.durationText;
      });isRequestingPositionDetails=false;
    }
  }
  void deleteGroFireMarkers(){
    setState(() {
      markersSet.removeWhere((element) => element.markerId.value.contains("driver"));
    });
  }
  void rideStat(NearbyAvailableDrivers driver){
    DatabaseReference newRequestRef=FirebaseDatabase.instance.reference().child("Ride Requests");
    riderequestStreamSubscription = newRequestRef.child(driver.key).onValue.listen((event) async {
      if(event.snapshot.value == null)
      {
        return;
      }
      if(event.snapshot.value["status"]!=null){
        statusRidetwo=event.snapshot.value["status"].toString();
      }

      if(statusRidetwo == "accepted") {
        setState(() {

          double driverlat=double.parse(event.snapshot.value["drivers_location"]["latitude"].toString());
          double driverlongi=double.parse(event.snapshot.value["drivers_location"]["longitude"].toString());
          LatLng drivercurrlocation=LatLng(driverlat, driverlongi);
          updateDriverTimeToPickUpLocation(drivercurrlocation);
//newRequestRef.child(driver.key).child("status").set("onride");
        });

      }else if(statusRidetwo== "onride") {
        setState(() {
          double driverlat = double.parse(
              event.snapshot.value["drivers_location"]["latitude"].toString());
          double driverlongi = double.parse(
              event.snapshot.value["drivers_location"]["longitude"].toString());

          LatLng drivercurrlocation = LatLng(driverlat, driverlongi);
          updateDriverTimeToDropOffLocation(drivercurrlocation);
        });
      }else if(statusRidetwo == "arrived"){
        setState(() {
          rideStatus="Driver Has Arrived";
        });

      }else if(statusRidetwo=="ended") {
        if (event.snapshot.value["fares"] != null) {
          int fare = int.parse(event.snapshot.value["fares"].toString());
          var res = await showDialog(context: context,
            barrierDismissible: false,
            builder: (BuildContext context) =>
                CollectFareDialog(paymentMethod: "cash", fareAmount: fare,),

          );
          String driverr_id="";
          if (res == "close") {
            if(driver.key!=null){
              driverr_id=driver.key;

          }

            DateTime now=new DateTime.now();
            DateTime date=new DateTime(now.year,now.month,now.day);
            Map historyMap={
              "payment_method": "cash",
              "created_at":date.toString(),
              "fares":fare.toString(),
              "status":"ended",
              "rider":driversname.toString(),
              "riders_phone":driversphone.toString(),

            };
            historyRef.child(firebaseuser.uid).set(historyMap);

            Navigator.of(context).push(MaterialPageRoute(builder:(context)=>ratingScreen(driverr_id:driverr_id)));
            newRequestRef.onDisconnect();
            newRequestRef = null;
            rideStreamSubscription.cancel();
            rideStreamSubscription = null;
            riderequestStreamSubscription.cancel();
            riderequestStreamSubscription = null;
            resetApp();
            // Navigator.pop(context);
            // Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
          }
        }
      }
    });
  }
  displayToastMesssage(String message,BuildContext context){
    Fluttertoast.showToast(msg: message);
  }
}