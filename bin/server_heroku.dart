library deskovka_server;

import 'dart:io';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as Shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' show join, dirname;
import '../lib/shelf_web_socket/shelf_web_socket.dart' as sWs;
import '../lib/shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart' as Route;
import 'package:shelf_simple_session/shelf_simple_session.dart' as SimpleSession;
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


void main() {
  runZoned((){
  load();
  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 80 : int.parse(portEnv);
  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'web');
  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');
  middle = SimpleSession.sessionMiddleware(new SimpleSession.SimpleSessionStore());

  myRouter = Route.router();
//  myRouter.get("/$CONTROLLER_DATA", data, middleware: middle);
//  myRouter.get("/$CONTROLLER_WEBSOCKET", sWs.webSocketHandler(handleSockets), middleware: middle);

  Shelf.Handler handler = new Shelf.Cascade().add(myRouter.handler).add(staticHandler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });
  }, onError: (e, stackTrace)=> print('Oh noes! $e $stackTrace'));
}
