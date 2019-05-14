/*

 fn_onUnitKilled.sqf
 by @musurca
 
 Event handler that dispatches missions for dead civilians.

*/

if (!isServer) exitWith {};

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
	
	_killedId = _killed call BIS_fnc_netId;
	_killed setVariable ["CORPSE_ID",_killedId];

	// Notify the players of the killing
	[name _killer, name _killed, _vicAge, position _killed, _killedId] remoteExec ["GR_fnc_localNotifyCivDeath", side _killer];

	// Players get an "apology" mission
	if (isPlayer _killer) then {
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