/*

 fn_onUnitKilled.sqf
 by @musurca
 
 Event handler that dispatches missions for dead civilians.

*/

if (!isServer) exitWith {};

params ["_killed", ["_killer", objNull]];

//Workaround for ACE3 Medical bug in which "killed" EH is called twice
if (_killed getVariable ["GR_WASKILLED",0] == 1) exitWith {};
_killed setVariable ["GR_WASKILLED",1];

if ((isNull _killer) || {_killer == _killed}) then {
	_killer = _killed getVariable ["ace_medical_lastDamageSource", objNull];
};
	
// See if it's a vehicle
if ((!isNull _killer) && {!(_killer isKindof "CAManBase")}) then {
	_killer = effectiveCommander _killer;
};

// Store information about death for autopsy.
_killed setVariable ["GR_TIMEOFDEATH",date];
_killed setVariable ["GR_KILLERSIDE",side _killer];
// cause of death not updated immediately, so a delay is required
[_killed] spawn {
	params ["_killed"];
	private ["_deathCause"];
	sleep 1;
	// extract cause of death from ACE Medical
	_wounds = _killed getVariable ["ace_medical_openWounds",[]];
	if(count _wounds > 0) then {
		_type = 1;
		_severity = 0;
		_rank = 0;
		{
			_xType = _x select 0;
			_xSeverity = _x select 1;
			_xRank = _x select 4;
			if (_xRank >= _rank) then {
				_rank = _xRank;
				if(_xType > _type) then {
					_type = _xType;
				};
				if (_xSeverity > _severity) then {
					_severity = _xSeverity;
				};
			};
		} forEach _wounds;
		_type = floor _type;
		if(_type == 1) then {
			if (_severity >= 15) then {
				_deathCause = GR_COD_BULLET;
			} else {
				_deathCause = GR_COD_VEHICLE;
			};
		} else {
			_type = _type-1;
			if(_type < (count GR_COD_CAUSES)) then {
				_deathCause = GR_COD_CAUSES select _type;
			} else {
				_deathCause = GR_COD_SHELL;
			};
		};
	};
	if (isNil "_deathCause") then {
		_deathCause = GR_COD_UNKNOWN;
	};
	_killed setVariable ["GR_DEATHCAUSE", _deathCause];
};

if ((side group _killed) == civilian) then {
	_vicAge = round random [15,40,79];
	_killed setVariable ["AGE",_vicAge];
	
	_killedId = _killed call BIS_fnc_netId;
	_killed setVariable ["CORPSE_ID",_killedId];

	// Notify the players of the killing
	[name _killer, name _killed, _vicAge, position _killed, _killedId] remoteExec ["GR_fnc_localNotifyCivDeath", side _killer];

	// Players get an "apology" mission
	if (isPlayer _killer) then {
		if(GR_ONKILL_ADDBODYBAG) then {
			_killed addItem "ACE_bodyBag";
		};
	
		if( (random 100) < GR_MISSION_CHANCE ) then {
			[_killer, _killed] call GR_fnc_makeMissionDeliverBody;
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