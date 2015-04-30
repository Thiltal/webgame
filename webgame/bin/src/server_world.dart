part of deskovka_server;
//
//class ServerWorld{
//  int gold;
//  String id;
//  List<Player> players = [];
//  World world;
//  Units units;
//  List<Field> get fields=>world.fields;
//
//  ServerWorld(this.gold, Player player){
//    world = new World(7);
//    units = new Units();
//    id = (++lastWorldId).toString();
//    addPlayer(player);
//  }
//
//  void addPlayer(Player player){
//    player.left = players.isEmpty;
//    players.add(player);
//    player.gold = gold;
//    player.world = this;
//  }
//
//  Map toJson([Player player]) {
//    Map out = {};
//    out["players"] = getPlayersJson(player);
//    out["gold"] = gold;
//    out["worldId"] = id;
//    return out;
//  }
//
//  List getPlayersJson([Player player]){
//    List out = [];
//    for(Player p in players){
//      out.add(p.toJson(player));
//    }
//    return out;
//  }
//}