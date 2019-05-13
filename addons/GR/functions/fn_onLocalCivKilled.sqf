/*

 fn_onLocalCivKilled.sqf
 by @musurca
 
 Client-side-only event about dead civilian.

*/

params ["_killed", ["_killer", objNull]];

if ((isNull _killer) || {_killer == _killed}) then {
	_killer = _killed getVariable ["ace_medical_lastDamageSource", objNull];
};
	
// See if it's a vehicle
if ((!isNull _killer) && {!(_killer isKindof "CAManBase")}) then {
	_killer = effectiveCommander _killer;
};

if(side (group _killed) == civilian) then {
	[_killed, _killer, name _killed] remoteExecCall ["GR_fnc_onClientCivKilled",2];
};