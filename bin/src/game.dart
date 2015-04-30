part of deskovka_server;

class Game {
  String id;
  World world;
  int gold;
  List<Player> players = [];
  Units units;
  Player playerOnMove;

  Game(){
    units = new Units();
  }

  void nextTurn(Player player){
    if(player!=playerOnMove){
      return;
    }
    playerOnMove.onMove = false;
    playerOnMove = opponent(playerOnMove);
    playerOnMove.onMove = true;
    units.newTurn();
    for(Player player in players){
      player.sendMessage(ACTION_NEXT_TURN,{
        "playerOnMove": playerOnMove.id
      });
    }
  }

  void addPlayer(Player player){
    player.gold = gold;
    player.left = false;
    player.game = this;
    players.add(player);
    player.state = STATE_UNITS;
    player.sendMessage(ACTION_JOINED_GAME, toJson(player, true));
  }

  void hostGame(int gold, Player player){
    this.gold = gold;
    players.add(player);
    player.game = this;
    player.gold = gold;
    player.left = true;
    playerOnMove = player;
    world = new World(7);
    world.createFields();
    world.id = (++lastWorldId).toString();
    games.sendMatchmakingJson();
  }

  Map toMatchmakingJson(){
    Map out = {};
    out["gold"] = gold;
    out["id"] = id;
    if(world != null){
      out["worldId"] = world.id;
    }
    List pls = [];
    for(Player p in players){
      pls.add(p.toSimpleJson());
    }
    out["players"] = pls;
    return out;
  }

  Map toJson([Player requestingPlayer, bool hideUnitsAndRace = false]){
    Map out = {};
    out["id"] = id;
    out["gold"] = gold;
    if(!hideUnitsAndRace){
      out["units"] = getUnitsJson();
    }
    out["players"] = getPlayersJson(requestingPlayer, hideUnitsAndRace);
    if(world != null){
      out["worldId"] = world.id;
    }
    out["playerOnMove"] = playerOnMove.id;
    return out;
  }

  List getUnitsJson(){
    List out = [];
    for(Unit u in units.list){
      out.add(u.toSimpleJson());
    }
    return out;
  }

  List getPlayersJson([Player requestingPlayer, bool hideUnitsAndRace = false]){
    List out = [];
    for(Player p in players){
      out.add(p.toJson(requestingPlayer, hideUnitsAndRace));
    }
    return out;
  }

  String unitsSelected(Map out, Player player, Map data){
    Map worldData = data["world"];
    List<Map> unitsData = worldData["units"];
    for(Map u in unitsData){
      String type = u["type"];
      int fieldX = u["field"]["x"];
      int fieldY = u["field"]["y"];
      Unit newUnit = new Unit((lastUnitId++).toString(), unitTypes[type], player, world.getField(fieldX, fieldY));
      units.addUnit(newUnit);
    }
    player.state = STATE_GAME;
    if(players.length == 2 && players.first.state == STATE_GAME && players.last.state == STATE_GAME){
      for(Player p in players){
        p.sendMessage(ACTION_START_GAME, toJson(p));
      }
    }else{
      for(Player p in players){
        p.sendMessage(ACTION_UNIT_SELECTION_COMPLETE, {"playerId": p.id});
      }
    }
    return ACTION_DO_NOTHING;
  }

  Player opponent(Player player){
    for(Player p in players){
      if(p!=player){
        return p;
      }
    }
    return null;
  }
}