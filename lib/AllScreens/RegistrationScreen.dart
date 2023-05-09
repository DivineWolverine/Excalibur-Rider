import 'package:cando/AllScreens/MainScreen.dart';
import 'package:cando/AllScreens/loginScreen.dart';
import 'package:cando/AllWidgets/progressDialog.dart';
import 'package:cando/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class RegistrationScreen extends StatelessWidget{
  TextEditingController nameTestEditingController=TextEditingController();
  TextEditingController emailTestEditingController=TextEditingController();
  TextEditingController phoneTestEditingController=TextEditingController();
  TextEditingController passwordTestEditingController=TextEditingController();


static const String idScreen="register";
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Column(
          children: [
            SizedBox(
                height: 20.0),
            Image(image: AssetImage("images/logo.png"),
              width: 390.0,
              height: 250.0,
              alignment: Alignment.center,),
            SizedBox(
              height: 1.0,
            ), Text("Register as Rider", style: TextStyle(
              fontSize: 24.0,
              fontFamily: "Brand Bold",
            ), textAlign: TextAlign.center,

            ), Padding(padding: EdgeInsets.all(20.0),
              child: Column(
                children: [

                  SizedBox(height: 1.0,),
                  TextField(
                    controller: nameTestEditingController,
                    keyboardType: TextInputType.text,
                    decoration: InputDecoration(
                      labelText: "Name",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ), hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    ), style: TextStyle(
                      fontSize: 14.0,
                    ),

                  ),
                  SizedBox(height: 1.0,),
                  TextField(controller: emailTestEditingController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: InputDecoration(
                      labelText: "Email",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ), hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    ), style: TextStyle(
                      fontSize: 14.0,
                    ),

                  ),
                  SizedBox(height: 1.0,),
                  TextField(
                    controller:phoneTestEditingController,
                    keyboardType: TextInputType.phone,
                    decoration: InputDecoration(
                      labelText: "Phone",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ), hintStyle: TextStyle(
                      color: Colors.grey,
                      fontSize: 10.0,
                    ),
                    ), style: TextStyle(
                      fontSize: 14.0,
                    ),

                  ),
                  SizedBox(height: 1.0,),
                  TextField(
                    controller: passwordTestEditingController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: "Password",
                      labelStyle: TextStyle(
                        fontSize: 14.0,
                      ),
                      hintStyle: TextStyle(
                        color: Colors.grey,
                        fontSize: 10.0,
                      ),
                    ),
                  ), SizedBox(
                    height: 1.0,
                  ), RaisedButton(
                    color: Colors.yellow,
                    child: Container(
                      height: 50.0,
                      child: Center(
                        child: Text("Create Account",
                          style: TextStyle(
                              fontSize: 18.0,
                              fontFamily: "Brand Bold"
                          ),

                        ),
                      ),
                    ), shape: new RoundedRectangleBorder(
                    borderRadius: new BorderRadius.circular(
                      24.0,
                    ),
                  ), onPressed: () {
                      if(nameTestEditingController.text.length<3){
                        displayToastMesssage("name must be atleast 3 charatcers", context);
                      }else

                        if(!emailTestEditingController.text.contains("@")) {
                        displayToastMesssage("Email is not valid!", context);
                      }
                      else if(phoneTestEditingController.text.isEmpty){
                        displayToastMesssage("Number is mandatory", context);
                      }

                      else if(passwordTestEditingController.text.length<6){
                        displayToastMesssage("Passwod must be at least 6 characters", context);
                      }

                      else{
                        registerNewUser(context);

                      }
                  },
                  ),

                ],
              ),

            ), FlatButton(onPressed: () {
              Navigator.pushNamedAndRemoveUntil(
                  context, LoginScreen.idScreen, (route) => false);
            }, child: Text(
                "Already have an Account? Login here"
            ),),


          ],
        ),
      ),
    );
  }
    final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
void registerNewUser(BuildContext context)async{
  showDialog(context: context,barrierDismissible: false,builder: (BuildContext context){
  return ProgressDialog(message: "Registering.. please wait...",);
  } );
    final User firebaseUser=(await _firebaseAuth.createUserWithEmailAndPassword(
    email: emailTestEditingController.text,
      password: passwordTestEditingController.text,
    ).catchError((errMsg){
    displayToastMesssage("Error: "+errMsg.toString(),context);
    })).user;
    if(firebaseUser!=null){
      //save user
      userRef.child(firebaseUser.uid);
      Map userPathMap={
        "name":nameTestEditingController.text.trim(),
        "email":emailTestEditingController.text.trim(),
        "phone":phoneTestEditingController.text.trim(),
      };
      userRef.child(firebaseUser.uid).set(userPathMap);
      displayToastMesssage("Congratulations your account has been created!", context);
      Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);

    }else{
      //error ocurred
      Navigator.pop(context);
      displayToastMesssage("New user account has not been created!", context);
    }
}
displayToastMesssage(String message,BuildContext context){
  Fluttertoast.showToast(msg: message);
}
}