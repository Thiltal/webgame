library deskovka_server;

import 'dart:io';
import 'package:args/args.dart';
import 'package:shelf/shelf.dart' as shelf;
import 'package:shelf/shelf_io.dart' as io;
import 'package:path/path.dart' show join, dirname;
import '../lib/shelf_web_socket/shelf_web_socket.dart' as sWs;
import '../lib/shelf_static/shelf_static.dart';
import 'package:shelf_route/shelf_route.dart';
import 'package:shelf_simple_session/shelf_simple_session.dart';
import 'dart:async';
import 'dart:convert';
import "../lib/deskovka_libs.dart";


//Pool pool;
Router myRouter;
int nextUserId = 1;

String uri =
'postgres://xifqxsdvnegrgu:yqMF8WD0rEnkr_UXWDF_9zVt3K@ec2-54-83-43-49.compute-1.amazonaws.com:5432/dbo2tavcvt2rtl?sslmode=require';

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
  shelf.Middleware middle = sessionMiddleware(new SimpleSessionStore());

  myRouter = router()..get("/db", (shelf.Request request) {
    return new shelf.Response.ok("db");
  }, middleware: middle);


  shelf.Handler handler = new shelf.Cascade().add(staticHandler).add(myRouter.handler).handler;
  io.serve(handler, InternetAddress.ANY_IP_V4, port).then((server) {
    print('Serving at http://${server.address.host}:${server.port}');
  });

}

void logout(StreamController controller, shelf.Request request) {
  Map mySession = session(request);
  mySession.remove("logged");
  controller.add(const Utf8Codec().encode(JSON.encode({
    "logout": true
  })));
  controller.close();
}
