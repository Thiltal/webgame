part of deskovka_server;


//void action(Shelf.Request request, StreamController controller){
//  Map mySession = SimpleSession.session(request);
//  Player player = getPlayer(request);
//  if(player==null){
//    getState(request, controller);
//    return;
//  }
//  Game game= player.game;
//   if(game==null){
//    getState(request, controller);
//    return;
//  }
//  request.readAsString().then((String data) {
//    Map json = JSON.decode(data);
//    String action = json["action"];
//
//    if(action == ACTION_INIT){
//
//    }
//    getState(request, controller);
//  });
//}