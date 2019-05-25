/*

 fn_vandalizegrave.sqf
 by @musurca
 
 Remote command from client. Strikes a name off a grave, making the body
 impossible to identify. If the body is currently the subject of a delivery
 mission, the mission will be completed if the body was buried far enough
 away from a populated area.

*/
if(!isServer) exitWith {};
	
params ["_target"];
//TODO: play sound?	
_target setVariable ["IS_LEGIBLE",false,true];
_name = (_target getVariable ["DOGTAG_DATA",["Unknown","",""]]) select 0;
_firstName = "John";
_lastName = "Doe";
if (_name != "Unknown") then {
	_nameToks = _name splitString " ";
	_firstName = _nameToks select 0;
	if (count _nameToks > 1) then {
		_lastName = _nameToks select 1;
	};
};
// Hide name, recoverable by autopsy at medical facility
_target setVariable ["DOGTAG_DATA",["Unknown",_firstName,_lastName],true];

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
			_pUID = _taskInfo select 2;

			_kin = _target getVariable "GR_NEXTOFKIN";
			[_task,"Succeeded",false] call BIS_fnc_taskSetState;
			["TaskSucceeded",["","Conceal Death"]] remoteExec ["BIS_fnc_showNotification",_taskOwner];

			// Remove from player responsibilities
			_deathArray = [GR_PLAYER_TASKS,_pUID] call CBA_fnc_hashGet;
			if (count _deathArray > 0) then {
				_deathArray = _deathArray - [_kin];
				[GR_PLAYER_TASKS,_pUID,_deathArray] call CBA_fnc_hashSet; 
			};
			[GR_TASK_OWNERS, _task] call CBA_fnc_hashRem;

			_kin setVariable ["GR_WILLDELETE",true];
			_killer = allPlayers select {(getPlayerUID _x) == _pUID};
			// Custom event upon concealment of death
			{
 				[_killer, _kin, _target] call _x;
 			} forEach GR_EH_CONCEALDEATH;
			
			// Clean up
			_target setVariable ["GR_HIDEBODY_TASK",""];
			if ( _kin getVariable ["GR_WILLDELETE",false] ) then {
				_target setVariable ["GR_NEXTOFKIN",objNull];
				deleteVehicle _kin;
			};
				
			[_task] spawn {
				sleep 180;
				[_this select 0] call BIS_fnc_deleteTask;
			};
		};
	};
};