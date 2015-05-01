part of deskovka_server;

Player getPlayer(Shelf.Request request){
  Player player = SimpleSession.session(request)[LOGGED_PLAYER];
  if(player == null){
    player = new Player((lastPlayerId++).toString());
    players.add(player);
    SimpleSession.session(request)[LOGGED_PLAYER] = player;
  }
  return player;
}

void sendPlayersChange(){
  for(Player p in players){
    if(p.socket!=null && p.state==STATE_MATCHMAKING){
      p.sendMessage(ACTION_PLAYERS_CHANGE, {
        "players": playersToMatchmakingJson()
      });
    }
  }
}

List playersToMatchmakingJson(){
  List out = [];
  for(Player p in players){
    if(p.nick==null)continue;
    out.add(p.toSimpleJson());
  }
  return out;
}


void route(String path, DHandler handler){
  myRouter.post(path, (Shelf.Request request)=> controller(request, handler), middleware: middle);
}

void write(StreamController controller, String out){
  controller.add(const Utf8Codec().encode(out));
}

Shelf.Response controller(Shelf.Request request, Function controller){
  StreamController innerController = new StreamController();
  Stream<List<int>> out = innerController.stream;
  controller(request, innerController);
  var headers = <String, String>{HttpHeaders.CONTENT_TYPE: "text/json"};
  return new Shelf.Response.ok(out, headers: headers);
}