part of deskovka_libs.base;

abstract class Ability{
  static const TARGET_ENEMY = "enemy";
  static const TARGET_FIELD = "field";
  static const TARGET_ALLY = "ally";
  static const TARGET_CORPSE = "corpse";
  static const TARGET_ME = "me";
  static const TARGET_WOUNDED_ALLY = "wonundedAlly";
  static const TARGET_WOUNDED_ENEMY = "woundedEnemy";
  static const TARGET_NOT_UNDEAD_CORPSE = "not_undead_corpse";
  static const TRIGGER_MINE_TURN_START = "mine_turn_start";
  Unit invoker;
  int actions = 1;
  String trigger;

  int range;
  String name;
  String id;
  String img;
  List<String> target = [];
  
  void setInvoker(Unit unit){
    invoker = unit;
  }
  
  void show(Track track);
  void perform(Track track);
  void resetProperties(){
    
  }

  void setDefaults(Map defaults){}
  
  Ability clone();
  
  void fromJson(Map ability){
    id = ability["class"].toString().toLowerCase();
    img = ability["img"];
    target = ability["target"];
    if(lang!=null){
      name = lang["abilities"][id];
    }
  }


  Map toJson(){
    Map out = {};
    out["name"] = name;
    return out;
  }
  /// steps needed to next
  int getPossiblesSteps(){
    return 0;
  }

  bool freeWayNeeded(){
    return true;
  }
}