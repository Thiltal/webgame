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

  var portEnv = Platform.environment['PORT'];
  var port = portEnv == null ? 9999 : int.parse(portEnv);

  var pathToBuild = join(dirname(Platform.script.toFilePath()), '..', 'web');

//  pool = new Pool(uri, minConnections: 1, maxConnections: 10,
//      idleTimeout: const Duration(seconds:100),
//      maxLifetime: const Duration(seconds:300),
//      leakDetectionThreshold:const Duration(seconds:300));
//  pool.messages.listen(print);
//  pool.start().then((_) {
//    pool.connect().then((conn) {
//      conn.query("""
//              select max(id) from "User"
//          """).toList().then((List<Row> rows) {
//        nextUserId = rows.first.toList().first.toInt() + 1;
//      }).then((event) {
//
//        return conn.close();
//      }) // Return connection to pool
//      .catchError((err) => print('Query error: $err'));
//      conn.close();
//    });
//  });


  var staticHandler = createStaticHandler(pathToBuild, defaultDocument: 'index.html');


//  SimpleSessionStore store = new SimpleSessionStore();
  Shelf.Middleware middle = SimpleSession.sessionMiddleware(new SimpleSession.SimpleSessionStore());

  myRouter = Route.router()..get("/db", (Shelf.Request request) {
    return new Shelf.Response.ok("db");
  }, middleware: middle);


  Shelf.Handler handler = new Shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

}

void logout(StreamController controller, Shelf.Request request) {
  Map mySession = SimpleSession.session(request);
  mySession.remove("logged");
  controller.add(const Utf8Codec().encode(JSON.encode({
    "logout": true
  })));
  controller.close();
}
