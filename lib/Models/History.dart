import 'package:firebase_database/firebase_database.dart';

class History{
  String PaymentMethod;
  String createdAt;
  String status;
  String fare;
  String rider;
  String riders_phone;

  History({this.PaymentMethod,this.createdAt,this.status,this.fare,this.rider,this.riders_phone});
  History.fromSnapshot(DataSnapshot snapshot){
    PaymentMethod=snapshot.value["payment_method"];
    createdAt=snapshot.value["created_at"];
    status=snapshot.value["status"];
    fare=snapshot.value["fare"];
    rider=snapshot.value["rider"];
    riders_phone=snapshot.value["riders_phone"];


  }
}