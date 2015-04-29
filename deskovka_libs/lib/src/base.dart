library deskovka_libs.base;

import "dart:math" as Math;
import "dart:async";


part "field.dart";
part "unit.dart";
part "world.dart";
part "alea.dart";
part "player.dart";
part "unit_base.dart";
part "abilities/ability.dart";
part "abilities/move.dart";
part "abilities/raise.dart";
part "abilities/teleport.dart";
part "abilities/attack.dart";
part "abilities/shoot.dart";
part "abilities/change_type.dart";
part "abilities/heal.dart";
part "abilities/revive.dart";
part "abilities/regeneration.dart";
part "abilities/boost.dart";
part "abilities/hand_heal.dart";
part "abilities/linked_move.dart";
part "abilities/summon.dart";
part "abilities/step_shoot.dart";
part "abilities/fly.dart";
part "abilities/dark_shoot.dart";
part "abilities/light.dart";
part "unit_type.dart";
part "units.dart";
part "race.dart";
part "action.dart";
part "buff.dart";
part "track.dart";

const STATE_NOT_LOGGED = "state_not_logged";
const STATE_MATCHMAKING = "state_matchmaking";
const STATE_STATS = "state_stats";
const STATE_UNITS = "state_units";
const STATE_GAME = "state_game";

const CONTROLLER_STATE = "state";
const CONTROLLER_DATA = "data";
const CONTROLLER_WEBSOCKET= "ws";

const ACTION_LOGIN = "login";
const ACTION_HOST = "host";
const ACTION_GAMES = "games";
//const ACTION_INIT = "init";
const ACTION_CHANGE_STATE = "state";
const ACTION_SELECTED_UNITS = "selected_units";
const ACTION_UNIT_SELECTION_COMPLETE = "selection_complete";
const ACTION_ENTER_GAME = "enter";
const ACTION_JOINED_GAME = "joined";
const ACTION_START_GAME = "start_game";
const ACTION_DO_NOTHING = "do_nothing";
const ACTION_NEXT_TURN = "next_turn";
const ACTION_TRACK_CHANGE = "track_change";
const ACTION_PLAYERS_CHANGE = "players_change";

Math.Random random = new Math.Random();

Map<String, Ability> abilityMap = {};
Map<String, UnitType> unitTypes = {};
Map<String, Race> races = {};
/// base template service, by default merged by name
Map templates = {};
Map lang;


void setInitialJson(Map json){
  lang = json["lang_cz"];
  List racesJson = json["races"];
  for(Map race in racesJson){
    races[race["id"]] = new Race(race);
  }

  List abilitiesJson = json["abilities"];
  for(var ability in abilitiesJson){
    Ability abl;
    if(ability is String){
      abl = getAbilityByType(ability);
    }else{
      abl = getAbilityByType(ability["class"]);
    }
    if(abl==null){
      throw new Exception("ability ${ability["class"]} is not aviable in prorgam");
    }
    abl.fromJson(ability);
    abilityMap[abl.id] = abl;
  }

  List types = json["unit_types"];
  for(Map type in types){
    UnitType t =  new UnitType()..fromJson(type);
    unitTypes[type["id"].toString().toLowerCase()] = t;
  }


}

Ability getAbilityByType(String type){
  switch(type){
    case "move": return new MoveAbility();
    case "attack": return new AttackAbility();
    case "shoot": return new ShootAbility();
    case "heal": return new HealAbility();
    case "revive": return new ReviveAbility();
    case "hand_heal": return new HandHealAbility();
    case "boost": return new BoostAbility();
    case "linked_move": return new LinkedMoveAbility();
    case "step_shoot": return new StepShootAbility();
    case "light": return new LightAbility();
    case "summon": return new SummonAbility();
    case "fly": return new FlyAbility();
    case "raise": return new RaiseAbility();
    case "teleport": return new TeleportAbility();
    case "dark_shoot": return new DarkShootAbility();
    case "regeneration": return new RegenerationAbility();
    case "change_type": return new ChangeTypeAbility();
  }
  return null;
}

