part of deskovka_libs.base;

class Unit {
  int armor = 0;
  int speed = 0;
  int range = 0;
  List<int> attack;

  int _health = 0;
  int _far = 0;
  String id;
  int _actions = 1;
  int _steps = 1;
  UnitType type;
  Field field;
  PlayerBase player;
  List<Ability> abilities = [];
  List<Buff> _buffs = [];

  List<String> tags = [];

  bool get isUndead=> tags.contains(UnitType.TAG_UNDEAD);

  bool get isEthernal=> tags.contains(UnitType.TAG_ETHERNAL);

  void addBuff(Buff buff){
    _buffs.add(buff);
    _recalc();
  }

  void removeBuff(Buff buff){
    _buffs.remove(buff);
    _recalc();
  }

  // called on buffs and type change
  void _recalc(){
    armor = type.armor;
    speed = type.speed;
    range = type.range;
    attack = type.attack.toList(growable:false);
    for(Buff buff in _buffs){
      armor += buff.armorDelta;
      speed += buff.speedDelta;
      if(range != null)range += buff.rangeDelta;
      for(int i = 0;i < 6;i++){
        attack[i] += buff.attackDelta[i];
      }
    }
    if(armor > 4)armor = 4;
    if(speed > 7)speed = 7;
    if(range != null && range > 7)range = 7;
    for(int i = 0;i < 6;i++){
      if(attack[i] > 9)attack[i] = 9;
    }
  }


  /// called on health change with previous health state
  Stream<int> onHealthChanged;
  StreamController<int> _onHealthChanged = new StreamController<int>();
  Stream<Field> onFieldChanged;
  StreamController<Field> _onFieldChanged = new StreamController<Field>();
  Stream<UnitType> onTypeChanged;
  StreamController<UnitType> _onTypeChanged = new StreamController<UnitType>();
  Stream<int> onStepsChanged;
  StreamController<int> _onStepsChanged = new StreamController<int>();
  Stream<int> onActionStateChanged;
  StreamController<int> _onActionStateChanged = new StreamController<int>();

  Unit.bare();

  Unit(this.id, this.type, this.player, this.field){
    onHealthChanged = _onHealthChanged.stream.asBroadcastStream();
    onFieldChanged = _onFieldChanged.stream.asBroadcastStream();
    onTypeChanged = _onTypeChanged.stream.asBroadcastStream();
    onStepsChanged = _onStepsChanged.stream.asBroadcastStream();
    onActionStateChanged = _onActionStateChanged.stream.asBroadcastStream();
    _recalc();
    _health = type.health;
    _steps = type.speed;
    setType(type);
//    _health = type.health;
//    for(Ability ability in type.abilities){
//      abilities.add(ability.clone());
//    }
    field.addUnit(this);
  }

  int get actions=> _actions;

  set actions(int val){
    if(val == actions)return;
    _actions = val;
    if(_actions <= 0){
      steps = 0;
    }else{
      field.refresh();
    }
  }


  set actualHealth(int val){
    if(val == _health)return;
    int original = _health;
    _health = val;
    if(_health > type.health){
      _health = type.health;
    }
    if(_health < -5){
      destroy();
    }
    _onHealthChanged.add(original);
    field.refresh();
  }

  void destroy(){
  }

  get actualHealth=> _health;

  int get far=> _far;

  int get steps=> _steps;

  set steps(int val){
    if(val == steps)return;
    int original = steps;
    _far += _steps - val;
    _steps = val;
    if(_steps <= 0){
      _steps = 0;
      _actions = 0;
    }
    _onStepsChanged.add(original);
  }

  bool get isAlive=> _health > 0;

  Alea heal(Alea alea){
    if(alea.attack != null){
      alea.damage = alea.attack[alea.nums[0]];
      actualHealth += alea.damage;
    }
    return alea;
  }

  /// Type change cause nullation of abilities pseudostates.
  /// change type will not cause change in race, nation or faith
  void setType(UnitType type){
    // health is transformed by new maximum. If unit is alive, type change cannot kill it
    bool alive = isAlive;
    int newActualHealth = ((type.health / this.type.health) * actualHealth).floor();
    this.type = type;
    if(alive && actualHealth == 0){
      newActualHealth = 1;
    }else{
      actualHealth = newActualHealth;
    }

    if(_steps == null){
      _steps = type.speed;
    }else{
      // steps are transformed in the same way as health
      bool hasStep = steps > 0;
      int newSteps = ((type.speed / speed) * steps).floor();
      if(newSteps == 0 && hasStep){
        steps = 1;
      }else{
        steps = newSteps;
      }
    }

    abilities.clear();
    for(Ability a in type.abilities){
      abilities.add(a.clone());
    }

    if(type.tags != null){
      tags = type.tags.toList();
    }

    _recalc();
  }

  void addAbility(Ability ability){
    abilities.add(ability);
    ability.setInvoker(this);
  }

  void move(Field field, int steps){
    this.steps -= steps;
    transport(field);
  }

  void transport(Field field){
    this.field.removeUnit(this);
    field.addUnit(this);
  }

  int harm(Alea alea){
    int realDamage = 0;
    int damage = alea.getDamage();
    damage -= armor;
    if(damage < 0){
      damage = 0;
    }
    realDamage = Math.min(damage, actualHealth);
    actualHealth -= damage;
    return realDamage;
  }

  void newTurn(){
    _steps = speed;
    _actions = type.actions;
    _far = 0;
    for(Ability a in abilities){
      if(a.trigger != null && a.trigger == Ability.TRIGGER_MINE_TURN_START && player.onMove){
        a.perform(null);
      }
    }
    field.refresh();
  }

  Alea dice(){
    return new Alea(attack);
  }

  void fromJson(Map json){
    type = unitTypes[json["type"]];
    id = json["id"];
    _buffs.clear();
    if(json.containsKey("buffs")){
      for(Map buff in json["buffs"]){
        _buffs.add(new Buff.fromJson(buff));
      }
    }

    abilities.clear();
    for(String ability in json["abilities"]){
      abilities.add(abilityMap[ability].clone());
    }

    player.world.getField(json["fieldX"].toInt(), json["fieldY"].toInt());


  }

  Map toSimpleJson(){
    Map out = {};
    out["id"] = id;
    out["type"] = type.id;
    out["field"] = field.toSimpleJson();
    out["player"] = player.id;
    return out;
  }


  Ability getAbility(Track track, bool shift, bool alt, bool ctrl){
    List<Ability> possibles = abilities.toList();
    List<Ability> toRemove = [];
    for(Ability ability in possibles){
      if(
         (actions < ability.actions) ||
         (track.fields.length - 1 > ability.getPossiblesSteps() - far) ||
      (far > ability.getPossiblesSteps()) ||
         (ability.freeWayNeeded() && track.isEnemy(player))){
        toRemove.add(ability);
        break;
      }

      //match target
      if(!track.matchTarget(ability.target, this)){
        toRemove.add(ability);
        break;
      }
    }
    for(Ability a in toRemove){
      possibles.remove(a);
    }

    int used = 0;
    if(possibles.isEmpty){
      return null;
    }else if(possibles.length > 0){
      if(possibles.length == 2 && (shift || alt || ctrl))used = 1;else if(possibles.length == 3){
        if(ctrl)used = 1;else if(shift || alt)used = 2;
      }else if(possibles.length > 3){
        if(ctrl)used = 1;else if(shift)used = 2;else if(alt)used = 3;
      }
    }
    return possibles[used];
  }
}
