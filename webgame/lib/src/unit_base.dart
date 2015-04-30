part of deskovka_libs.base;

class UnitBase{
  String id;
  int health;
  int armor;
  int range;
  int speed;
  
  int far;
  int _actions;
  int _steps;
  UnitType type;
  Field field;
  List<int> attack;
  PlayerBase player;
  List<Ability> abilities = []; 
}