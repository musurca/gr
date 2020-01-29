/*

 fn_initServer.sqf
 by @musurca
 
 Initializes server global variables and event handlers.

*/

if (!isServer) exitWith {};

// Set some reasonable default values
if (isNil "GR_MAX_KIN_DIST") then {
	GR_MAX_KIN_DIST=20000;
};
if (isNil "GR_MISSION_CHANCE") then {
	GR_MISSION_CHANCE=100;
};
if (isNil "GR_CIV_TYPES") then {
	GR_CIV_TYPES=["C_man_polo_1_F","C_man_polo_1_F_asia","C_man_polo_1_F_afro","C_man_polo_1_F_euro","C_man_polo_2_F","C_man_polo_2_F_afro","C_man_polo_2_F_euro","C_man_polo_2_F_asia","C_man_polo_5_F","C_man_polo_5_F_asia","C_man_polo_5_F_afro","C_man_polo_5_F_euro"];
};
if (isNil "GR_TASK_MIN_DELAY") then {
	GR_TASK_MIN_DELAY=20;
};
if (isNil "GR_TASK_MID_DELAY") then {
	GR_TASK_MID_DELAY=40;
};
if (isNil "GR_TASK_MAX_DELAY") then {
	GR_TASK_MAX_DELAY=60;
};
if (isNil "GR_FACTIONNAME_EAST") then {
	GR_FACTIONNAME_EAST = "CSAT";
};
if (isNil "GR_FACTIONNAME_WEST") then {
	GR_FACTIONNAME_WEST = "NATO";
};
if (isNil "GR_FACTIONNAME_IND") then {
	GR_FACTIONNAME_IND = "the Syndikat";
};
// Only if CBA fails for some reason
if (isNil "GR_ONKILL_ADDBODYBAG") then {
	GR_ONKILL_ADDBODYBAG = false;
};

GR_TASK_OWNERS = [] call CBA_fnc_hashCreate;
GR_PLAYER_TASKS = [[],[]] call CBA_fnc_hashCreate;

// Causes of death
GR_COD_UNKNOWN=0;
GR_COD_BULLET=1;
GR_COD_VEHICLE=2;
GR_COD_GRENADE=3;
GR_COD_EXPLOSION=4;
GR_COD_SHELL=5;
GR_COD_CAUSES = [GR_COD_BULLET,GR_COD_GRENADE,GR_COD_GRENADE,GR_COD_EXPLOSION,GR_COD_EXPLOSION,GR_COD_EXPLOSION,GR_COD_SHELL];
GR_COD_MSGS = [
localize "STR_FNINITSERVER_COD_UNKNOWN",
localize "STR_FNINITSERVER_COD_BULLET",
localize "STR_FNINITSERVER_COD_VEHICLE",
localize "STR_FNINITSERVER_COD_GRENADE",
localize "STR_FNINITSERVER_COD_EXPLOSION",
localize "STR_FNINITSERVER_COD_SHELL"
];

// trace ID of corpse
["ace_placedInBodyBag", {
	params["_target","_bodybag"];
	if(!isServer) exitWith{};
	
	_corpseId = _target getVariable ["CORPSE_ID",0];
	_bodyTask = _target getVariable ["GR_HIDEBODY_TASK",""];
	if(_bodyTask != "") then {
		// Tell everyone on side that the body has been bagged
		_taskInfo = [GR_TASK_OWNERS,_bodyTask] call CBA_fnc_hashGet;
		_taskSide = _taskInfo select 1;
		[_corpseId] remoteExec ["GR_fnc_localBodyBagged",_taskSide];
	} else
	{
		// Just tell everyone because we're not sure who shot him
		[_corpseId] remoteExec ["GR_fnc_localBodyBagged"];
	};
	_timeOfDeath = _target getVariable ["GR_TIMEOFDEATH",[]];
	_killerSide = _target getVariable ["GR_KILLERSIDE",CIVILIAN];
	_causeOfDeath = _target getVariable ["GR_DEATHCAUSE",GR_COD_UNKNOWN];
	
	// Set up GR variables
	_bodybag setVariable ["CORPSE_ID",_corpseId];
	_bodybag setVariable ["AGE",_target getVariable ["AGE",0],true]; // only broadcast AGE to clients when in the bodybag
	_bodybag setVariable ["GR_NEXTOFKIN",_target getVariable ["GR_NEXTOFKIN",objNull]];
	_bodybag setVariable ["GR_HIDEBODY_TASK",_bodyTask];
	_bodybag setVariable ["GR_TIMEOFDEATH",_timeOfDeath];
	_bodybag setVariable ["GR_KILLERSIDE",_killerSide];
	_bodybag setVariable ["GR_DEATHCAUSE",_causeOfDeath];
	
	// Transfer inventory
	_weaps = weapons _target;
	_mags = magazines _target;
	_items = assignedItems _target;
	_items pushBack (items _target);
	_items pushBack (headgear _target);
	_items pushBack (goggles _target);
	_items pushBack (uniform _target);
	_items pushBack (vest _target);
	_items pushBack (backpack _target);
	
	_cargo = "Supply500" createVehicle [0,0,0];
	_cargo attachTo [_bodybag, [0,0,0.85]];
	_bodybag setVariable ["GR_CARGO",_cargo];
	
	[_cargo,_items,_weaps,_mags] spawn {
		params["_cargo","_items","_weaps","_mags"];
		sleep 0.5;
		{ _cargo addItemCargoGlobal [_x,1]; } forEach _items;
		{ _cargo addWeaponCargoGlobal [_x,1]; } forEach _weaps;
		{ _cargo addMagazineCargoGlobal [_x,1]; } forEach _mags;
	};
}] call CBA_fnc_addEventHandler;

// Add event handler for people killed on server
["CAManBase", "killed",GR_fnc_onUnitKilled] call CBA_fnc_addClassEventHandler;

// Remove GR tasks from a player's responsibility 10 min after disconnect
addMissionEventHandler ["HandleDisconnect", {
	params ["_unit", "_id", "_uid", "_name"];
		
	_deathArray = [GR_PLAYER_TASKS,_uid] call CBA_fnc_hashGet;
	if(count _deathArray > 0) then {
		[_deathArray,_uid] spawn {
			params["_deathArray","_uid"];
			sleep 600; // wait 10 min for possible reconnect
			if ({ (getPlayerUID _x) == _uid } count allPlayers == 0) then {
				{
					// additional cleanup occurs in next-of-kin triggers
					deleteVehicle _x;
				} forEach _deathArray;
				[GR_PLAYER_TASKS,_uid,[]] call CBA_fnc_hashSet;
			};
		};
	};
}];
