/*

 fn_makeMissionDeliverBody.sqf
 by @musurca
 
 Spawn a next-of-kin, and create a task to deliver the body of the corpse to him.
 Handles both mission success and the untimely death of the next-of-kin.

*/
params["_killer", "_killed","_nameKilled"];

if(isNil "_nameKilled") then {
	_nameKilled = name _killed;
};
	
_corpseId = _killed call BIS_fnc_netId;
if (isInRemainsCollector _killed) then {
	removeFromRemainsCollector [_killed];
};

// Spawn the next-of-kin somewhere within GR_MAX_KIN_DIST (20km by default)
_deathPos = getPos _killed;
_locs = (nearestLocations [_deathPos, ["NameCity","NameCityCapital","NameVillage"], GR_MAX_KIN_DIST]) call BIS_fnc_arrayShuffle;
_locSelect = 0;
_bposlist = [];
while { (count _bposlist == 0) && (_locSelect < (count _locs)) } do {
	_startLocPos = _deathPos;
	_startLocPos = locationPosition (_locs select _locSelect);

	// Find a house within 300m of town center and put him in it
	_nearBldgs = nearestTerrainObjects [_startLocPos, ["House","Church","Chapel","Building","Hospital"], 300,false];
	{
		if ([_x] call BIS_fnc_isBuildingEnterable) then {
			_bposlist append (_x buildingPos -1);
		};
	} forEach _nearBldgs;
	_locSelect = _locSelect+1;
};
if (count _bposlist == 0) exitWith { // no place for kin to spawn
	// call event handler without kin and exit
	{
		[_killer, _killed, nil] call _x;
	} forEach GR_EH_CIVDEATH
};
		
_spawnPos = (selectRandom _bposlist);

_nextOfKinGrp = createGroup civilian;
_nextOfKin = _nextOfKinGrp createUnit [selectRandom GR_CIV_TYPES, _spawnPos, [],0, "NONE"];
_nextOfKin setPosATL _spawnPos;
_nextOfKin setUnitPos "up";
_nextOfKin allowFleeing 0;
doStop _nextOfKin;

_bigTask = format ["GRtsk_%1",_nextOfKin call BIS_fnc_netId];
[side _killer,_bigTask,[format ["Deliver the body of %1 to his nearest relative.",_nameKilled],"Deal with Civilian Death","meet"], _nextOfKin,"CREATED",0,false,"meet"] call BIS_fnc_taskCreate;

_nextOfKin setVariable ["GR_DELIVERBODY_TASK",_bigTask];
_nextOfKin setVariable ["GR_CORPSE_ID",_corpseId];
_killed setVariable ["GR_HIDEBODY_TASK",_bigTask];
_killed setVariable ["GR_NEXTOFKIN",_nextOfKin];

_playerUID = getPlayerUID _killer;
[GR_TASK_OWNERS, _bigTask, [owner _killer,side _killer, _playerUID]] call CBA_fnc_hashSet;

_eh = _nextOfKin addEventHandler ["Killed", {
	_kin = _this select 0;
	_task = _kin getVariable ["GR_DELIVERBODY_TASK",""];
	_taskInfo = [GR_TASK_OWNERS,_task] call CBA_fnc_hashGet;
	_taskOwner = _taskInfo select 0;
	_pUID = _taskInfo select 2;

	[_task,"Failed",false] call BIS_fnc_taskSetState;
	["TaskFailed",["","Deal with Civilian Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
		
	// Remove from player responsibilities
	_deathArray = [GR_PLAYER_TASKS,_pUID] call CBA_fnc_hashGet;
	if (count _deathArray > 0) then {
		_deathArray = _deathArray - [_kin];
		[GR_PLAYER_TASKS,_pUID,_deathArray] call CBA_fnc_hashSet; 
	};
	[GR_TASK_OWNERS,_task] call CBA_fnc_hashRem;				

	// Clean up
	[_task] spawn {
		sleep 180;
		[_this select 0] call BIS_fnc_deleteTask;
	};
}];
	
// Add this NPC to the player's list of responsiblities
_deathArray = [GR_PLAYER_TASKS,_playerUID] call CBA_fnc_hashGet;
if(count _deathArray == 0) then {
	_deathArray = [];
};
_deathArray pushBack _nextOfKin;
[GR_PLAYER_TASKS,_playerUID,_deathArray] call CBA_fnc_hashSet; 

// Handle body delivery or death of next of kin
[_nextOfKin, _eh] spawn {
	params["_kin","_handle"];

	_task = _kin getVariable ["GR_DELIVERBODY_TASK",""];
	_taskInfo = [GR_TASK_OWNERS,_task] call CBA_fnc_hashGet;
	_taskOwner = _taskInfo select 0;
	_taskSide = _taskInfo select 1;
	_playerUID = _taskInfo select 2;	

	// Wait to announce the mission
	sleep random [GR_TASK_MIN_DELAY, GR_TASK_MID_DELAY, GR_TASK_MAX_DELAY];
	["TaskCreated",["","Deal with Civilian Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
		
	_bodyDelivered=false;
	waitUntil {
		sleep 6;

		if( ({_x distance _kin <= 20} count allPlayers) > 0 ) then {
			_objs = _kin nearObjects ["ACE_bodyBagObject", 5];
			if (count _objs > 0) then {
				_cId = _kin getVariable ["GR_CORPSE_ID","0:0"];
				_bodyFound=false;
				_body = objNull;
				{ 
					if ((_x getVariable ["CORPSE_ID","-1:-1"]) == _cId) exitWith { _body = _x; _bodyFound=true };
				} forEach _objs;

				if (_bodyFound) then {
					_kin lookAt _body;

					[_task,"Succeeded",false] call BIS_fnc_taskSetState;
					["TaskSucceeded",["","Deliver Body"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
						
					// remove from player responsibility
					_deathArray = [GR_PLAYER_TASKS,_playerUID] call CBA_fnc_hashGet;
					if (count _deathArray > 0) then {
						_deathArray = _deathArray - [_kin];
						[GR_PLAYER_TASKS,_playerUID,_deathArray] call CBA_fnc_hashSet; 
					};
					[GR_TASK_OWNERS, _task] call CBA_fnc_hashRem;
						
					// Remove failure upon death event
					_kin removeEventHandler ["Killed", _handle];
					
					// Try to find the player who originally killed this civilian
					_killerTry = allPlayers select {(getPlayerUID _x) == _playerUID};
					if(count _killerTry > 0) then {
						_killer = _killerTry select 0;
					} else {
						_killer = objNull;
					};
					_kin setVariable ["GR_WILLDELETE",true];
					_body setVariable ["GR_WILLDELETE",true];
					// Call custom events upon delivery of body
					{
 						[_killer, _kin, _body] call _x;
 					} forEach GR_EH_DELIVERBODY;
 						
 					// remove this action and garbage collect if allowed
					[_kin,_body,_task] spawn {
						params["_kin","_body","_task"];
						sleep 180;
						[_task] call BIS_fnc_deleteTask;
			
						if ( _kin getVariable ["GR_WILLDELETE",false] ) then {
							deleteVehicle _kin;
						};
			
						if ( _body getVariable ["GR_WILLDELETE",false] ) then {
							_cargo = _body getVariable ["GR_CARGO",objNull];
							if (_cargo != objNull) then {
								deleteVehicle _cargo;
							};

							deleteVehicle _body;
						};
					};
						
					_bodyDelivered = true;
				};
			};
		};

		( (!alive _kin) || _bodyDelivered )
	};
};
	
// Call custom event upon civilian murder by player
{
	[_killer, _killed, _nextOfKin] call _x;
} forEach GR_EH_CIVDEATH;