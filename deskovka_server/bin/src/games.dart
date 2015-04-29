part of deskovka_server;

class Games{
  static int lastGameId = 0;
  List<Game> list = [];

  Game createGame(){
    Game newGame = new Game();
    list.add(newGame);
    newGame.id = (lastGameId++).toString();
    return newGame;
  }

  void sendMatchmakingJson(){
    for(Player p in players){
      if(p.state == STATE_MATCHMAKING){
        p.sendMessage(ACTION_GAMES,{"games": toMatchmakingJson()});
      }
    }
  }

  List toMatchmakingJson(){
    List out = [];
    for(Game g in list){
      if(g.gold==null)continue;
      out.add(g.toMatchmakingJson());
    }
    return out;
  }

  Game getGameById(String id){
    for(Game game in list){
      if(game.id==id)return game;
    }
    return null;
  }
}