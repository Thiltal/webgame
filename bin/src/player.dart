part of deskovka_server;

class Player extends PlayerBase{
  String password;
  String email;
  String _state = null;

  String get state=> _state;
  set state(val){
    _state = val;
    sendPlayersChange();
  }

  Race race;
  Game game;
  bool left;
  var socket;

  Player(String id):super(id);

  void sendMessage(String action, Map data){
    socket.add(JSON.encode({
      "action": action,
      "data": data,
      "state": state,
      "origin": "player_message"
    }));
  }

  @override
  void fromJson(Map json) {
    nick = json["nick"];
    password = json["password"];
    email = json["email"];
  }

  Map toJson([Player player, bool hideUnitsAndRace = false]) {
    Map out = {};
    out["id"] = id;
    out["nick"] = nick;
    out["gold"] = gold;
    out["left"] = left;
    out["email"] = email;
    if(player!=null){
      out["you"] = player==this;
    }
    if(race!=null){
      if(player!=null && !hideUnitsAndRace){
        out["race"] = race.id;
      }
      if(player==null || player==this){
        out["race"] = race.id;
      }
    }
    return out;
  }

  Map toSimpleJson(){
    Map out = {};
    out["id"] = id;
    out["nick"] = nick;
    out["state"] = state;
    return out;
  }
}