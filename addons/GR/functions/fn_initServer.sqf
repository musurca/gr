/*

 fn_initServer.sqf
 by @musurca
 
 Initializes server global variables and event handlers.

*/

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

// For storing event handlers
GR_EH_CIVDEATH = [];
GR_EH_DELIVERBODY = [];
GR_EH_CONCEALDEATH = [];

// trace ID of corpse
["ace_placedInBodyBag", {
	params["_target","_bodybag"];
	_bodybag setVariable ["CORPSE_ID",netId _target];
	_bodybag setVariable ["AGE",_target getVariable ["AGE",0],true]; // only broadcast AGE to clients when in the bodybag
	_bodybag setVariable ["GR_NEXTOFKIN",_target getVariable ["GR_NEXTOFKIN",objNull]];
	_bodybag setVariable ["GR_HIDEBODY_TASK",_target getVariable ["GR_HIDEBODY_TASK",""]];
}] call CBA_fnc_addEventHandler;

["CAManBase", "killed",{ 
	params ["_killed", ["_killer", objNull]];
	if ((isNull _killer) || {_killer == _killed}) then {
		_killer = _killed getVariable ["ace_medical_lastDamageSource", objNull];
	};
	
	// See if it's a vehicle
 	if ((!isNull _killer) && {!(_killer isKindof "CAManBase")}) then {
		_killer = effectiveCommander _killer;
	};

	if ((side group _killed) == civilian) then {
		_vicAge = round random [15,40,79];
		_killed setVariable ["AGE",_vicAge];

		// Notify the player of the killing
		//_text = format [GR_NOTIFY_TEXT, name _killer, name _killed, _vicAge];
		//_text remoteExec ["GR_fnc_MPhint", side _killer];
		[name _killer, name _killed, _vicAge] remoteExec ["GR_fnc_MPhint", side _killer];

		// Players get an "apology" mission
		if (isPlayer _killer) then {
			if( (random 100) < GR_MISSION_CHANCE ) then {
				[_killer, _killed] spawn GR_fnc_makeMissionDeliverBody;
			} else {
				// Call custom event upon civilian murder by player anyway
				{
 					[_killer, _killed, nil] call _x;
 				} forEach GR_EH_CIVDEATH;
			};
		};
	} else { // not a civilian
		// Generate an age for soldiers (18-50)
		_vicAge = round random [18,30,50];
		_killed setVariable ["AGE",_vicAge];
	};
}] call CBA_fnc_addClassEventHandler;
	
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