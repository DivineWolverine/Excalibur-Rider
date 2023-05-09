import 'package:cando/Models/History.dart';
import 'package:cando/Models/address.dart';
import 'package:flutter/cupertino.dart';

class AppData extends ChangeNotifier{
Address pickUplocation;
Address dropOffLocation;
String earnings = "0";
int countTrips = 0;
List<String> tripHistoryKeys = [];
List<History> tripHistoryDataList = [];
void updatePickuplocationAddress(Address pickUpAddress){
  pickUplocation=pickUpAddress;
  notifyListeners();
}
void updateDropOfflocationAddress(Address dropOffAddress){
dropOffLocation=dropOffAddress;
  notifyListeners();
}

void updateTripsCounter(int tripCounter){
  countTrips=tripCounter;
  notifyListeners();

}

void updateTripHistoryKeys(List<String>newKeys){
  tripHistoryKeys=newKeys;
  notifyListeners();

}
void updateTripHistoryData(History history)
{
  tripHistoryDataList.add(history);
  notifyListeners();
}

}