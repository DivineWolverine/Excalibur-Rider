
import 'dart:convert';
import 'dart:math';

import 'package:cando/Assistants/requestAssistant.dart';
import 'package:cando/DataHandler/appData.dart';
import 'package:cando/Models/History.dart';
import 'package:cando/Models/address.dart';
import 'package:cando/Models/allUsers.dart';
import 'package:cando/Models/directionDetails.dart';
import 'package:cando/configMaps.dart';
import 'package:cando/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:provider/provider.dart';
import 'package:http/http.dart' as http;
class AssistantMethods {
  static Future<String> searchcoordinateAddress(Position position,
      context) async {
    String placeAddress = "";
    String st1, st2, st3, st4;
    String url = "https://maps.googleapis.com/maps/api/geocode/json?latlng=${position
        .latitude},${position.longitude}&key=$mapkey";
    var response = await RequestAssistant.getRequest(url);
    if (response != "failed") {
//placeAddress=response["results"][0]["formatted_address"];
      st1 = response["results"][0]["address_components"][0]["long_name"];
      st2 = response["results"][0]["address_components"][1]["long_name"];
// st3=response["results"][0]["address_components"][5]["long_name"];
      st4 = response["results"][0]["address_components"][6]["long_name"];
      placeAddress = st1 + ", " + st2 + "," + st4;

      Address userpickedAddress = new Address();
      userpickedAddress.longitude = position.longitude;
      userpickedAddress.latitude = position.latitude;
      userpickedAddress.placeName = placeAddress;
      Provider.of<AppData>(context, listen: false).updatePickuplocationAddress(
          userpickedAddress);
    }
    return placeAddress;
  }

  static Future<directionDetails> obtainplacedirectionDetails(LatLng initialPosition,LatLng finalPosition)async{
    String directionUrl="https://maps.googleapis.com/maps/api/directions/json?origin=${initialPosition.latitude},${initialPosition.longitude}&destination=${finalPosition.latitude},${finalPosition.longitude}&key=AIzaSyB8gHnZ83HcD5_XNtl7PCpIXvWlNuz0G50&compnents=country:lk";
    // var ress=await RequestAssistant.getRequest(directionUrl);
    // var ress=await Requests.get(url);
    var client = http.Client();
    var response = await client.get(Uri.parse(directionUrl));

    String resp = response.body;
    var ress = json.decode(resp);
    print("ressss"+ress.toString());
    if(ress=="failed"){
      return null;
    }
    directionDetails directiondetailss=directionDetails();
    directiondetailss.distanceText=ress["routes"][0]["legs"][0]["distance"]["text"];
    directiondetailss.distancevalue=ress["routes"][0]["legs"][0]["distance"]["value"];
    directiondetailss.durationText=ress["routes"][0]["legs"][0]["duration"]["text"];
    directiondetailss.durationvalue=ress["routes"][0]["legs"][0]["duration"]["value"];
    directiondetailss.encodedPoints=ress["routes"][0]["overview_polyline"]["points"];
    return directiondetailss;


  }
static int calculatefares(directionDetails directionDetailss){
    double timeTravelledFare=(directionDetailss.durationvalue/60)*0.20;
    double distanceTravelledFare=(directionDetailss.distancevalue/1000)*0.20;
    double totalFareAmount=timeTravelledFare+distanceTravelledFare;
    //local currency
  // double totalLocalAmount=totalFareAmount*320;
  return totalFareAmount.truncate();
}
static void getCurrentOnlineUserInfo()async{
    firebaseuser=await FirebaseAuth.instance.currentUser;
    String userId=firebaseuser.uid;
    DatabaseReference reference=FirebaseDatabase.instance.reference().child("users").child(userId);
    reference.once().then((DataSnapshot dataSnapshot) {
      if(dataSnapshot.value!=null){
        userCurrentInfo=Users.fromSnapshot(dataSnapshot);
      }
    });
}
static double createRandomNumber(int num){
    var random=Random();
    int randNumber=random.nextInt(num);
    return randNumber.toDouble();
}
  static void retrieveHistoryinfo(context) {



    //rertieve and dipslay Trip History
    DatabaseReference historyRef=FirebaseDatabase.instance.reference().child("historyride");
    historyRef.child(firebaseuser.uid).once().then((
        DataSnapshot datasnapshot) {
      if (datasnapshot.value != null) {
        Map<dynamic, dynamic> keys = datasnapshot.value;
        int tripcounter = keys.length;

        Provider.of<AppData>(context, listen: false).updateTripsCounter(
            tripcounter);

        List<String> tripHistoryKeys = [];
        keys.forEach((key, value) {
          tripHistoryKeys.add(key);
        });
        Provider.of<AppData>(context, listen: false).updateTripHistoryKeys(
            tripHistoryKeys);
         obtainTripRequestHistoryData(context);
      }
    });
  }
  static void obtainTripRequestHistoryData(context) {
    // DatabaseReference historyRef=FirebaseDatabase.instance.reference().child("historyride");
    historyRef.orderByChild(firebaseuser.uid)
    .once().then((DataSnapshot snapshot){

      if(snapshot.value!=null){
        print("uuuuuu"+snapshot.value.toString());
        Map<dynamic,dynamic>j=snapshot.value;
        for (var i = 0; i <j.length; i++) {

          History fff=History();
          fff.PaymentMethod=j.values.toList()[i]["payment_method"].toString();
          fff.createdAt=j.values.toList()[i]["created_at"].toString();
          fff.fare=j.values.toList()[i]["fares"].toString();
          fff.status=j.values.toList()[i]["status"].toString();
          fff.rider=j.values.toList()[i]["rider"].toString();
          fff.riders_phone=j.values.toList()[i]["riders_phone"].toString();




          Provider.of<AppData>(context,listen: false).updateTripHistoryData(fff);

        }}
      // }
    });
  }

 }