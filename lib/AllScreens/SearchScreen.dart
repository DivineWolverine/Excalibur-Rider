
import 'package:cando/AllWidgets/DividerWidget.dart';
import 'package:cando/AllWidgets/progressDialog.dart';
import 'package:cando/Assistants/requestAssistant.dart';
import 'package:cando/DataHandler/appData.dart';
import 'package:cando/Models/address.dart';
import 'package:cando/Models/placePredictions.dart';
import 'package:cando/configMaps.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class SearchScreen extends StatefulWidget{
  @override
  SearchScreenState createState()=>SearchScreenState();
}
class SearchScreenState extends State<SearchScreen> {
  TextEditingController pickuptexteditingController=new TextEditingController();
  TextEditingController dropOfftexteditingController=new TextEditingController();
  List<placePredictions>placepredictionlist=[];

  @override
  Widget build(BuildContext context) {
    String placeAddress=Provider.of<AppData>(context).pickUplocation.placeName ?? "";
    pickuptexteditingController.text=placeAddress;


    return Scaffold(
      body: Column(
        children: [
          Container(
            height: 215.0,
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(
                  color: Colors.black,
                  blurRadius: 6.0,
                  spreadRadius: 0.5,
                  offset: Offset(0.7,0.7),
                ),
              ],
            ),
            child: Padding(
              padding: EdgeInsets.only(left: 25.0,right: 25.0,top: 25.0,bottom: 20.0),
              child: Column(
                children: [
                  SizedBox(height: 5.0,),
                  Stack(
                    children: [
                      GestureDetector(
                        onTap:(){
                          Navigator.pop(context);
                        },
                        child: Icon(Icons.arrow_back,
                        ),
                      ),
                      Center(
                        child: Text(
                          "Set Drop Off",
                          style: TextStyle(
                            fontSize: 18.0,
                            fontFamily: "Brand-Bold",
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Image.asset("images/pickicon.png",height: 16.0,width: 16.0,),
                      SizedBox(width: 18.0,),
                      Expanded(child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            controller: pickuptexteditingController,
                            decoration: InputDecoration(
                              hintText: "Pick Up Location",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 11.0,top: 8.0,bottom: 8.0),
                            ),
                          ),
                        ),
                      )),

                    ],
                  ),   SizedBox(height: 10.0,),
                  Row(
                    children: [
                      Image.asset("images/desticon.png",height: 16.0,width: 16.0,),
                      SizedBox(width: 18.0,),
                      Expanded(child: Container(
                        decoration: BoxDecoration(
                          color: Colors.grey[400],
                          borderRadius: BorderRadius.circular(5.0),
                        ),
                        child: Padding(
                          padding: EdgeInsets.all(3.0),
                          child: TextField(
                            onChanged: (val){
                              findPlace(val);
                            },
                            controller: dropOfftexteditingController,
                            decoration: InputDecoration(
                              hintText: "Where To?",
                              fillColor: Colors.grey[400],
                              filled: true,
                              border: InputBorder.none,
                              isDense: true,
                              contentPadding: EdgeInsets.only(left: 11.0,top: 8.0,bottom: 8.0),
                            ),
                          ),
                        ),
                      )),

                    ],
                  ),
                ],
              ),
            ),
          ),
          SizedBox(height: 10.0,),
          //title for predictions
          (placepredictionlist.length>0)?Padding(
            padding: EdgeInsets.symmetric(horizontal: 16.0,vertical: 8.0),
            child: ListView.separated(
              padding:EdgeInsets.all(0.0),
              itemBuilder: (context,index){
                return PredictionTile(PlacePredictions:placepredictionlist[index],);
              },separatorBuilder: (BuildContext context,int index)=>DividerWidget(),
              itemCount: placepredictionlist.length,
              shrinkWrap: true,
              physics: ClampingScrollPhysics(),
            ),
          ):Container(

          ),
        ],
      ),
    );
  }
  void findPlace(String placeName)async{
    if(placeName.length>1){
      // String autocompleteUrl="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=$mapKey&sessiontoken=1234567890&components=country:lk";
      String autocompleteUrl="https://maps.googleapis.com/maps/api/place/autocomplete/json?input=$placeName&key=AIzaSyB8gHnZ83HcD5_XNtl7PCpIXvWlNuz0G50&sessiontoken=1234567890&components=country:lk";
      var res=await RequestAssistant.getRequest(autocompleteUrl);
      if(res=="failed"){
        return;
      }
      if(res["status"]=="OK"){
        var predictions=res["predictions"];
        var placelist=(predictions as List).map((e) => placePredictions.fromJson(e)).toList();
        setState(() {
          placepredictionlist=placelist;
        });
      }
    }
  }
}
class PredictionTile extends StatelessWidget{
  final placePredictions PlacePredictions;

  PredictionTile({Key key,this.PlacePredictions}):super(key: key);

  @override
  Widget build(BuildContext context) {
    return FlatButton(
      padding: EdgeInsets.all(0.0),
      onPressed: (){
        getplaceAddressDetails(PlacePredictions.place_id, context);
      },
      child: Container(

        child: Column(
          children: [
            SizedBox(width: 10.0,),
            Row(
              children: [
                Icon(Icons.add_location),
                SizedBox(width:14.0),
                Expanded(
                  child:   Column(

                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      SizedBox(height: 8.0,),
                      Text(

                        PlacePredictions.main_text,overflow:TextOverflow.ellipsis,style: TextStyle(

                        fontSize: 16.0,

                      ),

                      ),

                      SizedBox(height: 2.0,),

                      Text(

                        PlacePredictions.secondary_text,overflow:TextOverflow.ellipsis,style: TextStyle(

                        fontSize: 12.0,

                        color: Colors.grey,



                      ),

                      ),SizedBox(height: 2.0,),

                    ],

                  ),
                )
              ],
            ),
            SizedBox(width: 10.0,),
          ],
        ),
      ),
    );
  }
  void getplaceAddressDetails(String placeId,context)async{
    showDialog(
        context: context,
        builder:(BuildContext context)=>ProgressDialog(message: "Setting dropoff,Please Wait..",)
    );
    String placedetailsurl="https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=AIzaSyB8gHnZ83HcD5_XNtl7PCpIXvWlNuz0G50";
    var res=await RequestAssistant.getRequest(placedetailsurl);
    Navigator.pop(context);
    if(res=="failed"){
      return;
    }
    if(res["status"]=="OK"){
       Address address=Address();

      address.placeName=res["result"]["name"];
      address.placeId=placeId;
      address.latitude=res["result"]["geometry"]["location"]["lat"];
      address.longitude=res["result"]["geometry"]["location"]["lng"];
      Provider.of<AppData>(context,listen: false).updateDropOfflocationAddress(address);
      print("This is Dropoff location::");
      print(address.placeName);
      Navigator.pop(context,"obtainDirection");

    }
  }
}


