part of deskovka_libs.base;

class Units{
  Stream<Unit> onUnitAdded;
  StreamController<Unit> _onUnitAdded = new StreamController<Unit>();
  Stream<Unit> onUnitRemoved;
  StreamController<Unit> _onUnitRemoved = new StreamController<Unit>();
  
  List<Unit> list = [];
  
  Units(){
    onUnitAdded = _onUnitAdded.stream.asBroadcastStream();
    onUnitRemoved = _onUnitRemoved.stream.asBroadcastStream();
  }
  
  void removeUnit(Unit unit){
    list.remove(unit);
    _onUnitRemoved.add(unit);
  }
  
  void addUnit(Unit unit){
    list.add(unit);
    _onUnitAdded.add(unit);
  }

  void newTurn(){
    for(Unit unit in list){
      unit.newTurn();
    }
  }
}