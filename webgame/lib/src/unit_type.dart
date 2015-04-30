part of deskovka_libs.base;

class UnitType{
  static const TAG_UNDEAD  = "undead";
  static const TAG_ETHERNAL = "ethernal";
  String id;
  Race race;
  int health;
  int armor;  
  int speed;
  int range = 0;
  int cost;
  List<int> attack;
  List<Ability> abilities = [];
  int actions=1;
  var tags;
  
  UnitType();
  
  void fromJson(Map json){
    id = json["id"];
    race = races[json["race"].toString().toLowerCase()];
    race.unitTypes[id] = this;
    health = json["health"];
    armor = json["armor"];
    speed = json["speed"];
    range = json["range"];
    cost = json["cost"];
    List attackJson = json["attack"];
    attack = [0,0,0,0,0,0];
    for(int i = 0;i<attackJson.length;i++){
      attack[5-i] = attackJson[attackJson.length-i-1];
    }
    List<String> abils = json["abilities"];
    for(dynamic ability in abils){
      if(ability is String){
        abilities.add(abilityMap[ability.toLowerCase()]);
      }else if(ability is Map){
        Ability newAbility = abilityMap[ability["class"]];
        if(newAbility==null){
          throw new Exception("Missing ability ${ability["class"]}");
        }
        newAbility.setDefaults(ability);
        abilities.add(newAbility);
      }
    }
    if(json.containsKey("actions")&&json["actions"]!=null){
      actions = json["actions"];
    }else{
      actions = 1;
    }
    if(json.containsKey("tags")){
      tags = json["tags"];
    }
    
  }

  Map toJson(){
    Map out = {};
    out["id"] = id;
    if(lang!=null){
      out["name"] = lang["types"][id];
    }
    out["race"] = race.toJson();
    out["health"] = health;
    out["armor"] = armor;
    out["speed"] = speed;
    out["range"] = range;
    out["cost"] = cost;
    out["attack"] = attack;
    out["actions"] = actions;
    List abils = [];
    for(Ability a in abils){
      abils.add(a.toJson());
    }
    out["abilities"] = abils;
    return out;
  }
}