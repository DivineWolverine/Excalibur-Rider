class placePredictions{
  String secondary_text;
  String main_text;
  String place_id;
  placePredictions({this.secondary_text,this.main_text,this.place_id});
  placePredictions.fromJson(Map<String,dynamic>json){
    place_id=json["place_id"];
    secondary_text=json["structured_formatting"]["secondary_text"];
    main_text=json["structured_formatting"]["main_text"];
  }
}