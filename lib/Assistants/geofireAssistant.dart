import '../Models/nearbyAvailableDrivers.dart';

class GeofireAssistant{
  static List <NearbyAvailableDrivers> nearbyAvailableDriversList=[];
  static void removeDriverFromList(String key){
    int index=nearbyAvailableDriversList.indexWhere((element) => element.key==key);
    nearbyAvailableDriversList.removeAt(index);
  }
 static void updateDriverNearbyLocation(NearbyAvailableDrivers drivers){
    int index=nearbyAvailableDriversList.indexWhere((element) => element.key==drivers.key);
    nearbyAvailableDriversList[index].latitude=drivers.latitude;
    nearbyAvailableDriversList[index].longitude=drivers.longitude;
  }
}