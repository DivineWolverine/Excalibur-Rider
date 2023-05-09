
import 'dart:async';

import 'package:cando/AllScreens/MainScreen.dart';
import 'package:cando/configMaps.dart';
import 'package:cando/main.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:smooth_star_rating/smooth_star_rating.dart';
class ratingScreen extends StatefulWidget {
  final String driverr_id;

  // final int fareAmount;
  ratingScreen({this.driverr_id});

  @override
  ratingScreenState createState() => ratingScreenState();
}
class ratingScreenState extends State<ratingScreen>{
  StreamSubscription<Event>adelStreamSubscription;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey[200],
      body: Dialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12.0),
        ),backgroundColor: Colors.transparent,
        child: Container(
          margin: EdgeInsets.all(5.0),
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(5.0),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(height: 22.0,),
              Text("Rate This Driver",style: TextStyle(
                fontFamily: "Brand-Bold",fontSize: 20.0,
                color: Colors.black54,
              ),),
              SizedBox(height: 22.0,),
              Divider(height: 2.0,thickness: 2.0,),
              SizedBox(height: 16.0,),
SmoothStarRating(rating: starCounter,color: Colors.green,allowHalfRating: false,starCount: 5,size: 45,onRated: (value){
  starCounter=value;
  if(starCounter==1){
    setState(() {
      title="Very Bad";
    });
  }else if(starCounter==2){
    setState(() {
      title="Bad";
    });
  }else if(starCounter==3){
    setState(() {
      title="Good";
    });
  }else if(starCounter==4){
    setState(() {
      title="Very Good";
    });
  }if(starCounter==5){
    setState(() {
      title="Excellent";
    });
  }
},),
              SizedBox(height: 14.0,),
              Text(title,style: TextStyle(fontSize: 65.0,fontFamily: "Signatra",color: Colors.green),),
              SizedBox(height: 16.0,),
              Padding(padding: EdgeInsets.symmetric(horizontal: 16.0),
                child: RaisedButton(
                  onPressed: ()async{

              adelStreamSubscription=driversRee.child(widget.driverr_id).onValue.listen((event) async {
              
    if(event.snapshot.value!= null){

      
      double oldRating=double.parse(event.snapshot.value["ratings"].toString());
      double addRatings=oldRating+starCounter;
      double averageRatings=addRatings/2;
Map m={"ratings":averageRatings.toString()};
      driversRee.child(widget.driverr_id).set(m);



      adelStreamSubscription.cancel();
      adelStreamSubscription=null;
      Navigator.of(context).push(MaterialPageRoute(builder:(context)=>MainScreen()));

    }else{
    
    Map n={"ratings":starCounter.toString()};
      driversRee.child(widget.driverr_id).set(n);
     
      adelStreamSubscription.cancel();
      adelStreamSubscription=null;
      Navigator.of(context).push(MaterialPageRoute(builder:(context)=>MainScreen()));
    }
                    });
                  },
                  color: Colors.deepPurpleAccent,
                  child: Padding(
                    padding: EdgeInsets.all(16.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Text("Submit",
                          style: TextStyle(
                            fontSize: 20.0,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),),
              SizedBox(height: 30.0,),
            ],
          ),
        ),
      ),
    );
  }}



