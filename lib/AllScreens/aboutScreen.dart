
import 'package:cando/AllScreens/MainScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class aboutScreen extends StatefulWidget {
  static const String idScreen="about";
  @override
  _aboutScreenState createState() => _aboutScreenState();
}

class _aboutScreenState extends State<aboutScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ListView(
        children: [
          Container(height: 220,
          child: Center(
            child: Image.asset("images/uberx.png"),
          ),),
          //app name + info
          Padding(padding: EdgeInsets.only(top: 30,left: 24,right: 24),
          child: Column(
            children: [
              Text(
                "CanDo App",
                style: TextStyle(
                  fontSize: 90,
fontFamily: "Signatra",
                ),
              ),
              SizedBox(height: 30,),
              Text(
                'This app has been developed by Kulesh Abhayasundara, '
                    'Co-founder of Dream Big. This app offer cheap rides at cheap rates, '
                    'and that\'s why 10M+ people already use this app',
                style: TextStyle(fontFamily: "Brand-Bold"),
                textAlign: TextAlign.center,
              ),
            ],
          ),),
          SizedBox(height: 40,),
          FlatButton(
              onPressed: () {
                Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
              },
              child: const Text(
                  'Go Back',
                  style: TextStyle(
                      fontSize: 18, color: Colors.black
                  )
              ),
              shape: RoundedRectangleBorder(
                  borderRadius: new BorderRadius.circular(10.0))
          ),
        ],
      ),
    );
  }
}
