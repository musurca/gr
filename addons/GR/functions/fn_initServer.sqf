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

GR_TASK_OWNERS = [] call CBA_fnc_hashCreate;
GR_PLAYER_TASKS = [[],[]] call CBA_fnc_hashCreate;

// trace ID of corpse
["ace_placedInBodyBag", {
	params["_target","_bodybag"];
	
	// Set up GR variables
	_bodybag setVariable ["CORPSE_ID",_target call BIS_fnc_netId];
	_bodybag setVariable ["AGE",_target getVariable ["AGE",0],true]; // only broadcast AGE to clients when in the bodybag
	_bodybag setVariable ["GR_NEXTOFKIN",_target getVariable ["GR_NEXTOFKIN",objNull]];
	_bodybag setVariable ["GR_HIDEBODY_TASK",_target getVariable ["GR_HIDEBODY_TASK",""]];
	
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
	_bodybag setVariable ["GR_CARGO",_cargo call BIS_fnc_netId];
	
	[_cargo,_items,_weaps,_mags] spawn {
		params["_cargo","_items","_weaps","_mags"];
		sleep 0.5;
		{ _cargo addItemCargoGlobal [_x,1]; } forEach _items;
		{ _cargo addWeaponCargoGlobal [_x,1]; } forEach _weaps;
		{ _cargo addMagazineCargoGlobal [_x,1]; } forEach _mags;
	};
}] call CBA_fnc_addEventHandler;

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