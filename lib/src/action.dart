part of deskovka_libs.base;

class Action{
  Ability ability;
  Unit unit;
  List<Field> track;
}

class Affected{
  bool health = false;
  bool steps = false;
  bool type = false;
  bool field = false;
}

