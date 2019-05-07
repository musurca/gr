/*
--------------------------------------------
 GUILT & REMEMBRANCE for ARMA 3
 by musurca
 
 Usage:

in your mission's init.sqf, add the following lines:
------------------------------------------------------
// customize with the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];
[] call compile preprocessFile "gr\init.sqf";


// OPTIONAL: register custom event functions, e.g.
[ALIVE_reduceForcePool] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed]
[ALiVE_addForcePoolBig] call GR_fnc_addDeliverBodyEventHandler; // args [_killer]
[ALiVE_addForcePoolSmall] call GR_fnc_addConcealDeathEventHandler; // args [_killer]

*/

GR_TASK_OWNERS = [] call CBA_fnc_hashCreate;
GR_PLAYER_TASKS = [[],[]] call CBA_fnc_hashCreate;

GR_EH_CIVDEATH = [];
GR_EH_DELIVERBODY = [];
GR_EH_CONCEALDEATH = [];

GR_fnc_addCivDeathEventHandler = {
	GR_EH_CIVDEATH pushBack (_this select 0);
};

GR_fnc_addDeliverBodyEventHandler = {
	GR_EH_DELIVERBODY pushBack (_this select 0);
};

GR_fnc_addConcealDeathEventHandler = {
	GR_EH_CONCEALDEATH pushBack (_this select 0);
};

GR_fnc_MPhint = { hintSilent parseText _this; };

GR_fnc_burybody = {
	if(!isServer) exitWith {};
	
	params ["_target","_player"];
	//TODO: play sound?	
	// Replace bodybag w/ grave (rotated 90 deg)
	_targ_vDir = vectorDir _target;
	_vDir = [-(_targ_vDir select 1),_targ_vDir select 0, _targ_vDir select 2];
	_vUp = vectorUp _target;
	_posTarget = position _target;
	_cId = _target getVariable ["CORPSE_ID",0];	
	_vicAge = _target getVariable ["AGE",0];
	_task = _target getVariable ["GR_HIDEBODY_TASK",""];
	_nextOfKin = _target getVariable ["GR_NEXTOFKIN",objNull];
	if (_vicAge == 0) then {
		_vicAge = round random [18, 28, 47];
	};

	_dogtagData = _target getVariable ["DOGTAG_DATA",[]];
	if ((count _dogtagData) == 0) then {
		_dogtagData = [_target] call ace_dogtags_fnc_getDogtagData;
		[_player, _target] call ace_dogtags_fnc_takeDogtag;
	};
	deleteVehicle _target;

	_grave = "Land_Grave_dirt_F" createVehicle [0,0,0];
	_grave setVectorDirAndUp [_vDir,_vUp];
	_grave setPos _posTarget;
	_grave setVariable ["CORPSE_ID", _cId];
	_grave setVariable ["DOGTAG_DATA", _dogtagData, true];
	_grave setVariable ["AGE",_vicAge, true];
	if (_task != "") then {
		_grave setVariable ["GR_HIDEBODY_TASK",_task];
		_grave setVariable ["GR_NEXTOFKIN",_nextOfKin];
	};
};

GR_fnc_exhumebody = {
	if(!isServer) exitWith {};
	
	params ["_target"];
	//TODO: play sound?	
	// Replace grave w/ bodybag (rotated -90 deg)
	_targ_vDir = vectorDir _target;
	_vDir = [_targ_vDir select 1,-(_targ_vDir select 0), _targ_vDir select 2];
	_vUp = vectorUp _target;
	_posTarget = position _target;
	_posTarget = [_posTarget select 0, _posTarget select 1, (_posTarget select 2)+0.5];
	_cId = _target getVariable ["CORPSE_ID",0];
	_dogtagData = _target getVariable "DOGTAG_DATA";
	_vicAge = _target getVariable "AGE";
	_task = _target getVariable ["GR_HIDEBODY_TASK",""];
	_nextOfKin = _target getVariable ["GR_NEXTOFKIN",objNull];
	deleteVehicle _target;

	_body = "ACE_bodyBagObject" createVehicle [0,0,0];
	_body setVectorDirAndUp [_vDir,_vUp];
	_body setPos _posTarget;
	_body setVariable ["CORPSE_ID", _cId];
	_body setVariable ["DOGTAG_DATA", _dogtagData,true];
	_body setVariable ["AGE", _vicAge,true];
	if (_task != "") then {
		_body setVariable ["GR_HIDEBODY_TASK",_task];
		_body setVariable ["GR_NEXTOFKIN",_nextOfKin];
	};
};

GR_fnc_vandalizegrave = {
	if(!isServer) exitWith {};
	
	params ["_target"];
	//TODO: play sound?	
	_target setVariable ["IS_LEGIBLE",false,true];
	_target setVariable ["DOGTAG_DATA",["Unknown","",""],true];

	_task = _target getVariable ["GR_HIDEBODY_TASK",""];
	if (_task != "") then {
		_taskState = [_task] call BIS_fnc_taskState;
		if ((_taskState != "") && (_taskState != "Succeeded") && (_taskState != "Failed")) then {
			// First check if we've buried the body far enough away
			_locs = nearestLocations [position _target, ["NameCity","NameCityCapital","NameVillage"], 300];
			if ((count _locs) == 0) then {
				_taskInfo = [GR_TASK_OWNERS, _task] call CBA_fnc_hashGet;
				_taskOwner = _taskInfo select 0;
				_taskSide = _taskInfo select 1;

				_kin = _target getVariable "GR_NEXTOFKIN";
				[_task,"Succeeded",false] call BIS_fnc_taskSetState;
				["TaskSucceeded",["","Conceal Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];

				// Custom event upon concealment of death
				{
 					[_taskOwner] call _x;
 				} forEach GR_EH_CONCEALDEATH;

				// Clean up
				deleteVehicle _kin;
				[GR_TASK_OWNERS, _task] call CBA_fnc_hashRem;
				_target setVariable ["GR_HIDEBODY_TASK",""];
				_target setVariable ["GR_NEXTOFKIN",objNull];
				
				[_task] spawn {
					sleep 180;
					[_this select 0] call BIS_fnc_deleteTask;
				};
			};
		};
	};
};

GR_ace_burialAction = ["actionBury","Bury","",{
	player playMove "acts_miller_knockout"; //alt: 'Acts_CivilTalking_2'
	[
		8,
		_target,
		{ // success
			params["_target"];
			player switchMove "";
			[_target,player] remoteExecCall ["GR_fnc_burybody",2];
		},
		{ // interruption
			player switchMove "";
		},
		"Burying body..."
	] call ace_common_fnc_progressBar;
}, {"ACE_EntrenchingTool" in (items _player)}] call ace_interact_menu_fnc_createAction;
["ACE_bodyBagObject",0,["ACE_MainActions"],GR_ace_burialAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_vandalizeAction = ["actionVandalize","Vandalize marker","",{
	if(_target getVariable ["IS_LEGIBLE",true]) then {
		player playMove "acts_miller_knockout";
		[
			2,
			_target,
			{ // success
				params["_target"];
				[_target,player] remoteExecCall ["GR_fnc_vandalizegrave",2];
				player switchMove "";
				hint "You scratch out the name on the marker.";
			},
			{ // interruption
				player switchMove "";
			},
			"Vandalizing marker..."
		] call ace_common_fnc_progressBar;
	} else {
		hintSilent "The marker is already illegible.";
	};
}, {true}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_vandalizeAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_exhumeAction = ["actionExhume","Exhume","",{
	player playMove "acts_miller_knockout";
	[
		6,
		_target,
		{
			params["_target"];
			[_target,player] remoteExecCall ["GR_fnc_exhumebody",2];
			player switchMove "";
		},
		{ 
			player switchMove "";
		},
		"Exhuming body..."
	] call ace_common_fnc_progressBar;
}, {"ACE_EntrenchingTool" in (items _player)}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_exhumeAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_readEpitaphAction = ["actionEpitaph","Read marker","",{
	params ["_target", "_player"];
	if(_target getVariable ["IS_LEGIBLE",true]) then {
		_name = (_target getVariable ["DOGTAG_DATA", ["Unknown","",""]]) select 0;
		_age = _target getVariable ["AGE",0];
		_yearDied = date select 0;
		_yearBorn = _yearDied - _age;
		if (_name != "Unknown") then {
			hintSilent parseText (format ["<t align='center'>%1<br/>Born %2  Died %3</t>",toUpper _name,_yearBorn,_yearDied]);
		} else {
			hintSilent parseText (format ["<t align='center'>UNKNOWN<br/>Died %1</t>",_yearDied]);
		};
	} else {
		hintSilent "Someone has scratched out the name on this grave."; 
	}; 
}, {true}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_readEpitaphAction] call ace_interact_menu_fnc_addActionToClass;

GR_fnc_makeMissionDeliverBody = {
	params["_killer", "_killed", "_deathPos", "_killedName"];
	
	_corpseId = netId _killed;
	if (isInRemainsCollector _killed) then {
		removeFromRemainsCollector [_killed];
	};

	// Spawn the next-of-kin somewhere within 20km
	_locs = nearestLocations [_deathPos, ["NameCity","NameCityCapital","NameVillage"], 4000];
	_bposlist = [];
	while {count _bposlist == 0} do {
		_startLocPos = _deathPos;
		if ((count _locs) > 0) then {
			_startLocPos = locationPosition (selectRandom _locs);
		};

		// Find a house within 300m of town center and put him in it
		_nearBldgs = nearestTerrainObjects [_startLocPos, ["House","Church","Chapel","Building","Hospital"], 300,false];
		{
			if ([_x] call BIS_fnc_isBuildingEnterable) then {
				_bposlist append (_x buildingPos -1);
			};
		} forEach _nearBldgs;
	};
	_spawnPos = (selectRandom _bposlist);

	_nextOfKinGrp = createGroup civilian;
	_nextOfKinGrp = [_spawnPos, civilian, [selectRandom GR_CIV_TYPES]] call BIS_fnc_spawnGroup;
	sleep 5;
	_nextOfKin = (units _nextOfKinGrp) select 0;
	_nextOfKin setPosATL _spawnPos;
	_nextOfKin setUnitPos "up";
	_nextOfKin allowFleeing 0;
	doStop _nextOfKin;

	_bigTask = format ["CivDead%1",netId _nextOfKin];
	[side _killer,_bigTask,[format ["Deliver the body of %1 to his nearest relative.",_killedName],"Deal with Civilian Death","meet"], _nextOfKin,"CREATED",0,false,"meet"] call BIS_fnc_taskCreate;

	_nextOfKin setVariable ["GR_DELIVERBODY_TASK",_bigTask];
	_nextOfKin setVariable ["GR_CORPSE_ID",_corpseId];
	_killed setVariable ["GR_HIDEBODY_TASK",_bigTask];
	_killed setVariable ["GR_NEXTOFKIN",_nextOfKin];
	[GR_TASK_OWNERS, _bigTask, [owner _killer,side _killer]] call CBA_fnc_hashSet;

	_eh = _nextOfKin addEventHandler ["Killed", {
		_kin = _this select 0;
		_task = _kin getVariable ["GR_DELIVERBODY_TASK",""];
		_taskOwner = ([GR_TASK_OWNERS,_task] call CBA_fnc_hashGet) select 0;

		[_task,"Failed",false] call BIS_fnc_taskSetState;
		["TaskFailed",["","Deal with Civilian Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
		[GR_TASK_OWNERS,_task] call CBA_fnc_hashRem;		

		// Clean up
		[_task] spawn {
			sleep 180;
			[_this select 0] call BIS_fnc_deleteTask;
		};
	}];
	
	// Add this NPC to the player's list of responsiblities
	_playerName = name _killer;
	_deathArray = [GR_PLAYER_TASKS,_playerName] call CBA_fnc_hashGet;
	if(count _deathArray == 0) then {
		_deathArray = [];
	};
	_deathArray pushBack _nextOfKin;
	[GR_PLAYER_TASKS,_playerName,_deathArray] call CBA_fnc_hashSet; 

	// Handle body delivery or death of next of kin
	[_nextOfKin, _eh] spawn {
		params["_kin","_handle"];

		_task = _kin getVariable ["GR_DELIVERBODY_TASK",""];
		_taskInfo = [GR_TASK_OWNERS,_task] call CBA_fnc_hashGet;
		_taskOwner = _taskInfo select 0;
		_taskSide = _taskInfo select 1;		

		// Wait to announce the mission
		sleep random [20, 40, 60];
		["TaskCreated",["","Deal with Civilian Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
		
		_bodyDelivered=false;
		waitUntil {
			sleep 6;

			if( ({_x distance _kin <= 20} count allPlayers) > 0 ) then {
				_objs = _kin nearObjects ["ACE_bodyBagObject", 5];
				if (count _objs > 0) then {
					_cId = _kin getVariable ["GR_CORPSE_ID",0];
					_body = objNull;
					{ 
						if ((_x getVariable ["CORPSE_ID",0]) == _cId) exitWith { _body = _x};
					} forEach _objs;

					if (_body != objNull) then {
						_kin lookAt _body;

						// TODO various text reactions
						// indifferent, beneficent, annoyed at the inconvenence, grief-stricken, in a rage
						// pull out a gun and shoot you, etc., make all the local civilians turn into a militia
						// _kin addMagazine "somepistolammo";
						// _kin addWeapon "somepisol";
						// _grp = createGroup EAST;
						// [_kin] joinSilent _grp;

						[_task,"Succeeded",false] call BIS_fnc_taskSetState;
						["TaskSucceeded",["","Deliver Body"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];
						[GR_TASK_OWNERS, _task] call CBA_fnc_hashRem;
						
						// Call custom events upon delivery of body
						{
 							[_taskOwner] call _x;
 						} forEach GR_EH_DELIVERBODY;

						// Remove failure upon death event
						_kin removeEventHandler ["Killed", _handle];
						_bodyDelivered = true;
					};
				};
			};

			( (!alive _kin) || _bodyDelivered )
		};
		
		// remove this action and garbage collect
		sleep 180;
		deleteVehicle _kin;
		deleteVehicle _body;
		[_task] call BIS_fnc_deleteTask;
		
		// remove from GR_PLAYER_TASKS
		_deathArray = [GR_PLAYER_TASKS,_name] call CBA_fnc_hashGet;
		if (count _deathArray > 0) then {
			_deathArray = _deathArray - [_kin];
			[GR_PLAYER_TASKS,_playerName,_deathArray] call CBA_fnc_hashSet; 
		};
	};
};

if (isServer) then {
	// trace ID of corpse
	["ace_placedInBodyBag", {
		params["_target","_bodybag"];
		_bodybag setVariable ["CORPSE_ID",netId _target];
		_bodybag setVariable ["AGE",_target getVariable ["AGE",0],true];
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
			_vicAge = round random [12,40,79];
			_killed setVariable ["AGE",_vicAge,true];

			_text = format ["<t color='#cc0808' align='center'>%1 has killed a civilian.<br/><t color='#dddddd'>(%2, age %3)</t></t>", name _killer, name _killed, _vicAge];
			_text remoteExec ["GR_fnc_MPhint", side _killer];

			// Call custom event upon civilian murder
			{
 				[_killer, _killed] call _x;
 			} forEach GR_EH_CIVDEATH;

			// Players get an "apology" mission
			if (isPlayer _killer) then {
				[_killer, _killed, getPos _killed, name _killed] spawn GR_fnc_makeMissionDeliverBody;
			};
		};
	}] call CBA_fnc_addClassEventHandler;
	
	// Remove GR tasks from a player's responsibility 10 min after disconnect
	addMissionEventHandler ["HandleDisconnect", {
		params ["_unit", "_id", "_uid", "_name"];
		
		_deathArray = [GR_PLAYER_TASKS,_name] call CBA_fnc_hashGet;
		if(count _deathArray > 0) then {
			[_deathArray,_name] spawn {
				params["_deathArray","_name"];
				sleep 600; // wait 10 min for possible reconnect
				if ({ name _x == _name } count allPlayers == 0) then {
					{
						// additional cleanup occurs in next-of-kin triggers
						deleteVehicle _x; 
					} forEach _deathArray;
					[GR_PLAYER_TASKS,_name,[]] call CBA_fnc_hashSet;
				};
			};
		};
	}];
};