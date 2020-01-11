/*

 fn_onLocalCivKilled.sqf
 by @musurca
 
 Client-side-only event about dead civilian.

*/

params ["_killed", ["_killer", objNull]];

//Workaround for ACE3 Medical bug in which "killed" EH is called twice
if (_killed getVariable ["GR_WASKILLED",0] == 1) exitWith {};
_killed setVariable ["GR_WASKILLED",1];

if(side (group _killed) == civilian) then {
	// Workaround for ACE medical	
	if ((isNull _killer) || {_killer == _killed}) then {
		_killer = _killed getVariable ["ace_medical_lastDamageSource", objNull];
	};
	
	// Civilian killed by vehicle?
	if ((!isNull _killer) && {!(_killer isKindof "CAManBase")}) then {
		_killer = effectiveCommander _killer;
	};

	// Tell the server about killing and start transfer of ownership
	[_killed, _killer, name _killed] remoteExecCall ["GR_fnc_onClientCivKilled",2];
};