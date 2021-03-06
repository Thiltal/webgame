part of deskovka_libs.base;

class Field {
  int index;
  List<Unit> units = [];
  int x;
  int y;
  World map;
  bool get hasUnit => !units.isEmpty;
  PlayerBase get player {
    if (units.isEmpty) return null;
    return units.first.player;
  }

  Field(this.index, this.x, this.y);

  List<Unit> alivesOnField() {
    List<Unit> out = [];
    for (Unit unit in units) {
      if (unit.isAlive){
        out.add(unit);
      }
    }
    return out;
  }
  
  List<Unit> deathsOnField() {
    List<Unit> out = [];
    for (Unit unit in units) {
      if (!unit.isAlive){
        out.add(unit);
      }
    }
    return out;
  }

  /// is one or more alive units on field
  bool isAliveOnField() {
    for (Unit unit in units) {
      if (unit.isAlive) return true;
    }
    return false;
  }

  void refresh() {
//    reimplement in ancestor
  }

  Field getFieldWithUnitNear() {
    if (hasUnit) return this;
    var fields = map.getFieldsRound(this);
    for (Field field in fields) {
      if (field.hasUnit) return field;
    }
    return null;
  }

  Field getFieldWithAliveUnitNear() {
    if (isAliveOnField()) return this;
    var fields = map.getFieldsRound(this);
    for (Field field in fields) {
      if (field.isAliveOnField()) return field;
    }
    return null;
  }

  void addUnit(Unit unit) {
    units.add(unit);
    refresh();
  }

  void removeUnit(Unit unit) {
    units.remove(unit);
    refresh();
  }

  Alea attack(Alea alea) {
    alea.damage = 0;
    for (Unit unit in units) {
      alea.damage += unit.harm(alea);
    }
    return alea;
  }

  bool isAllyOnField(PlayerBase player) {
    if (units.isEmpty) return false;
    return units.first.player == player;
  }

  bool isCorpseOnField() {
    for (Unit unit in units) {
      if (!unit.isAlive) return true;
    }
    return false;
  }

  bool areOnlyCorpsesOnField() {
    for (Unit unit in units) {
      if (unit.isAlive) return false;
    }
    return !units.isEmpty;
  }

  void rollUp() {

  }

  void rolldown() {

  }


  Map toSimpleJson(){
    return {
      "x": x,
      "y": y
    };
  }
}
