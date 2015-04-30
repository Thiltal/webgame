library deskovka_client;

import 'dart:html';
import 'dart:convert';
import 'dart:async';
import 'dart:math' as Math;
import '../lib/deskovka_libs.dart';
import '../lib/ui.dart';
import "package:mustache_no_mirror/mustache.dart" as Mustache;

part "src/client_world.dart";
part "src/client_field.dart";
part "src/game_flow.dart";
part "src/login.dart";
part "src/matchmaking.dart";
part "src/widgets/unit_selection.dart";
part "src/game.dart";
part "src/player.dart";
part "src/game_map_adapter.dart";
part "src/widgets/matchmaking_players.dart";
part "src/widgets/matchmaking_widget.dart";
part "src/widgets/matchmaking_games.dart";
part "src/widgets/game_phaser.dart";

List<Function>  repaints = [];
Map<String, ImageElement> images = {};
GameFlow gf;

void main() {
  window.onMouseWheel.listen((e){
    e.preventDefault();
  });
  HttpRequest.getString("$CONTROLLER_DATA").then(load);
}

void start(){
  gf = new GameFlow();
  gf.init();
  repaintLoop(null);
}

void load(String data){
  Map json = JSON.decode(data);
  setInitialJson(json);
  Map imagesJson = json["images"];
  imagesJson.forEach((k,v){
    images[k] = new ImageElement(src:v);
  });
  Map templatesJson = json["templates"];

  dynamic parseTemplate(String key, Object value){
    if(value is Map){
      Map row = {};
      value.forEach((k,v){
        row[k] = parseTemplate(k, v);
      });
      return row;
    }else{
      return Mustache.parse(value, lenient:true);
    }
  }

  templatesJson.forEach((k,v){
    templates[k] = parseTemplate(k, v);
  });
  start();
}


int _frame = 0;
int _lastTime = 0;
void repaintLoop(_){
    int time = new DateTime.now().millisecondsSinceEpoch;
    _frame++;
    if(time-_lastTime>1000){
//      document.title = _frame.toString();
      _frame = 0;
      _lastTime = time;
    }
    for (Function f in repaints) {
        f();
      }
   window.animationFrame.then(repaintLoop);
  }

void callAll(List<Function> functions){
  for(Function f in functions.toList(growable: false)){
    f();
  }
}