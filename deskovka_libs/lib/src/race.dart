part of deskovka_libs.base;

class Race{
  String id;
  Map<String, UnitType> unitTypes = {};
  String get name{
    if(lang!=null){
      return lang["races"][id];
    }else{
      return "lang not loaded";
    }
  }

  String toString()=>"Race $name";

  var color;
  Race(Map json){
    id = json["id"];
    color = json["color"];
  }

  Map toJson(){
    Map out = {};
    out["id"] = id;
    out["name"] = name;
    return out;
  }
}