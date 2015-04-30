part of deskovka_libs.base;

abstract class PlayerBase{
  String id;
  String nick;
  Race race;
  int gold;
  List<Unit> units = [];
  dynamic world;
  bool you;
  bool left;
  bool onMove;

  PlayerBase(this.id);

  void fromJson(Map json);

}