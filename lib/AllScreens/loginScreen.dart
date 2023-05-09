import 'package:cando/AllScreens/MainScreen.dart';
import 'package:cando/AllScreens/RegistrationScreen.dart';
import 'package:cando/AllWidgets/progressDialog.dart';
import 'package:cando/main.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class LoginScreen extends StatelessWidget{
  static const String idScreen="login";
  TextEditingController emailTestEditingController=TextEditingController();
  TextEditingController passwordTestEditingController=TextEditingController();

  @override
  Widget build(BuildContext context) {
   return Scaffold(
     backgroundColor: Colors.white,
     body: SingleChildScrollView(
       child: Column(
         children: [
           SizedBox(
             height: 45.0),
             Image(image: AssetImage("images/logo.png"),
             width: 390.0,
             height: 250.0,
             alignment: Alignment.center,),
           SizedBox(
             height: 1.0,
           ),Text("Login as Rider",style: TextStyle(
             fontSize: 24.0,
             fontFamily: "Brand Bold",
           ),textAlign: TextAlign.center,

           ),Padding(padding:EdgeInsets.all(20.0),
           child: Column(
             children: [
               SizedBox(height: 1.0,),
               TextField(
                 controller: emailTestEditingController,
                 keyboardType: TextInputType.emailAddress,
               decoration: InputDecoration(
                 labelText: "Email",
                 labelStyle: TextStyle(
                   fontSize: 14.0,
                 ),hintStyle: TextStyle(
                 color: Colors.grey,
                 fontSize: 10.0,
               ),
               ),style: TextStyle(
                   fontSize: 14.0,
                 ),

               ),TextField(
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
               ),SizedBox(
                 height: 1.0,
               ),RaisedButton(
                 color: Colors.yellow,
                 child: Container(
                   height: 50.0,
                   child: Center(
                     child: Text("Login",
                     style: TextStyle(
                       fontSize: 18.0,
                       fontFamily: "Brand Bold"
                     ),

                     ),
                   ),
                 ),shape: new RoundedRectangleBorder(
                 borderRadius: new BorderRadius.circular(
                   24.0,
                 ),
               ),onPressed: (){
                   if(!emailTestEditingController.text.contains("@")){
                     displayToastMesssage("email address is not valid", context);
                   }else if(passwordTestEditingController.text.isEmpty){
                     displayToastMesssage("password is mandatory", context);
                   }else{
                     loginAndAuthenticateUser(context);

                   }


               },
               ),

             ],
           ),

           ),FlatButton(onPressed: (){
             Navigator.pushNamedAndRemoveUntil(context, RegistrationScreen.idScreen, (route) => false);

           },child: Text(
             "Do not have an Account? Register here"
           ),  ),


         ],
       ),
     ),
   );
  }
  final FirebaseAuth _firebaseAuth=FirebaseAuth.instance;
  void loginAndAuthenticateUser(BuildContext context)async{
showDialog(context: context,barrierDismissible: false,builder: (BuildContext context){
  return ProgressDialog(message: "Authenticating.. please wait...",);
} );
    final User firebaseUser=(await _firebaseAuth.signInWithEmailAndPassword
      (email: emailTestEditingController.text,
        password: passwordTestEditingController.text).catchError((errMsg){
          Navigator.pop(context);
            displayToastMesssage("Error: "+errMsg.toString(), context);
    })).user;
    if(firebaseUser!=null){
      userRef.child(firebaseUser.uid).once().then((DataSnapshot snap){
if(snap.value!=null){
  Navigator.pushNamedAndRemoveUntil(context, MainScreen.idScreen, (route) => false);
  displayToastMesssage("you are logged in!", context);
}else{
  Navigator.pop(context);
  _firebaseAuth.signOut();
  displayToastMesssage("No record for this user! please create account!", context);

}


      });}else{
      Navigator.pop(context);

      displayToastMesssage("Error ocurred can not sign in", context);
    }
  }
  displayToastMesssage(String message,BuildContext context){
    Fluttertoast.showToast(msg: message);
  }
}