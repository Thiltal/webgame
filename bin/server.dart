// Copyright (c) 2015, <your name>. All rights reserved. Use of this source code
// is governed by a BSD-style license that can be found in the LICENSE file.
library deskovka_server;
import 'dart:io';
import '../packages/args/args.dart';
import 'package:shelf/shelf.dart' as Shelf;
import 'package:shelf/shelf_io.dart' as Io;
import 'package:path/path.dart' show join, dirname;
import '../lib/shelf_static/shelf_static.dart' as Static;
import '../lib/shelf_web_socket/shelf_web_socket.dart' as sWs;
import 'package:shelf_route/shelf_route.dart' as Route;
import 'package:shelf_simple_session/shelf_simple_session.dart' as SimpleSession;
//import 'package:path/path.dart' as Path;
import 'dart:async';
import 'dart:convert';
import "../lib/deskovka_libs.dart";
part "src/worlds.dart";
part "src/player.dart";
part "src/server_world.dart";
part "src/load.dart";
part "src/action.dart";
part "src/game.dart";
part "src/games.dart";
part "src/utils.dart";

typedef DHandler(Shelf.Request request, StreamController controller);
const PATH_TO_RESOURCES = "resources/module.json";
const LOGGED_PLAYER = "logged";
Games games = new Games();
List<Player> players = [];
int lastPlayerId = 0;
int lastWorldId = 0;
int lastUnitId = 0;
Route.Router myRouter;
Shelf.Middleware middle;

void main(List<String> args){
  runZoned((){
    load();
    var parser = new ArgParser()
      ..addOption('port', abbr: 'p', defaultsTo: '80');
    var result = parser.parse(args);
    var port = int.parse(result['port'], onError: (val){
      stdout.writeln('Could not parse port value "$val" into a number.');
      exit(1);
    });
    var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'web');
//    var pathToBuild = join(dirname(Platform.script.toFilePath().replaceAll("\\bin", "")), 'web');
    var staticHandler = Static.createStaticHandler(pathToBuild, defaultDocument: 'index.html', serveFilesOutsidePath: true, disableCache: true);
    middle = SimpleSession.sessionMiddleware(new SimpleSession.SimpleSessionStore());

    myRouter = Route.router();
    myRouter.get("/$CONTROLLER_DATA", data, middleware: middle);
    myRouter.get("/$CONTROLLER_WEBSOCKET", sWs.webSocketHandler(handleSockets), middleware: middle);

    Shelf.Handler handler = new Shelf.Cascade().add(myRouter.handler).add(staticHandler).handler;
    Io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server){
      print('Serving at http://${server.address.host}:${server.port}');
    });
  }, onError: (e, stackTrace)=> print('Oh noes! $e $stackTrace'));
}

void handleSockets(socket, protocol, Shelf.Request request){
  Player player = getPlayer(request);
  player.socket = socket;
  socket.listen((String message){
    Map json = JSON.decode(message);
    String action = json["action"];
    Map data = json["data"];
    Map outBox = {};
    outBox["data"] = {};
    Map out = outBox["data"];
    String outAction;
    switch(action){
      case CONTROLLER_STATE:
        outAction = getState(out, player, data);
        break;
      case ACTION_LOGIN:
        outAction = login(out, player, data);
        break;
      case ACTION_HOST:
        outAction = host(out, player, data);
        break;
      case ACTION_GAMES:
        outAction = getGames(out, player, data);
        break;
      case ACTION_SELECTED_UNITS:
        outAction = player.game.unitsSelected(out, player, data);
        break;
      case ACTION_ENTER_GAME:
        outAction = enterGame(out, player, data);
        break;
      case ACTION_TRACK_CHANGE:
        outAction = trackChange(out, player, data);
        break;
      case ACTION_NEXT_TURN:
        outAction = newTurn(out, player, data);
        break;
    }
    if(outAction==ACTION_DO_NOTHING)return;
    outBox["state"] = player.state;
    outBox["action"] = outAction;
    outBox["origin"] = "main_handler";
    socket.add(JSON.encode(outBox));
  });
}

String newTurn(Map out, Player player, Map data){
  player.game.nextTurn(player);
  return ACTION_DO_NOTHING;
}


String trackChange(Map out, Player player, Map data){
//  print("action trackChnge sent to ${player.game.opponent(player).nick}");
  player.game.opponent(player)
..sendMessage(ACTION_TRACK_CHANGE, data);
  return ACTION_DO_NOTHING;
}

String enterGame(Map out, Player player, Map data){
  String id = data["gameId"];
  String raceId = data["race"];
  player.race = races[raceId];
  if(player.race==null){
    player.race = races.values.first;
  }
  Game game = games.getGameById(id);
  game.addPlayer(player);
  return ACTION_DO_NOTHING;
}


String getGames(Map out, Player player, Map data){
  out["games"] = games.toMatchmakingJson();
  out["players"] = playersToMatchmakingJson();
  return ACTION_GAMES;
}

String getState(Map out, Player player, _){
  if(player.state == null){
    player.state = STATE_NOT_LOGGED;
  }
  String state = player.state;
  if(player.game != null){
    out["game"] = player.game.toJson(player, player.state!=STATE_GAME);
  }else{
    out["player"] = player.toJson(player);
  }
  if(state == STATE_MATCHMAKING){
    out["games"] = games.toMatchmakingJson();
    out["players"] = playersToMatchmakingJson();
  }
  return ACTION_CHANGE_STATE;
}

String login(Map out, Player player, Map data){
  String nick = data["nick"];
  player.nick = nick;
  player.state = STATE_MATCHMAKING;
  return getState(out, player, data);
}

String host(Map out, Player player, Map data){
  player.state = STATE_UNITS;
  player.race = races[data["race"]];
  if(player.race==null){
    print("undefined race in host data ${JSON.encode(data)}");
  }
  Game newGame = games.createGame();
  newGame.hostGame(data["gold"], player);
  return getState(out, player, data);
}

Shelf.Response data(Shelf.Request request){
  var headers = <String, String>{HttpHeaders.CONTENT_TYPE: "text/json", HttpHeaders.CONTENT_ENCODING: "utf8"};
  File file = new File(PATH_TO_RESOURCES);
  return new Shelf.Response.ok(file.openRead(), headers: headers);
}

