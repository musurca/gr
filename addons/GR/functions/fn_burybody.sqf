/*

 fn_burybody.sqf
 by @musurca

 Buries a body in a bodybag, and saves information about the corpse in
 the grave.

*/

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
_timeOfDeath = _target getVariable ["GR_TIMEOFDEATH",[]];
_killerSide = _target getVariable ["GR_KILLERSIDE",CIVILIAN];
_causeOfDeath = _target getVariable ["GR_DEATHCAUSE",GR_COD_UNKNOWN];	

_dogtagData = _target getVariable ["DOGTAG_DATA",[]];
if ((count _dogtagData) == 0) then {
	_dogtagData = [_target] call ace_dogtags_fnc_getDogtagData;
	[_player, _target] call ace_dogtags_fnc_takeDogtag;
};

_cargo = _target getVariable ["GR_CARGO",objNull];
if (!(_cargo isEqualTo objNull)) then {
	detach _cargo;
	_cargo setPos [0,0,0];
};

deleteVehicle _target;

_grave = "Land_Grave_dirt_F" createVehicle [0,0,0];
_grave setVectorDirAndUp [_vDir,_vUp];
_grave setPos _posTarget;
_grave setVariable ["CORPSE_ID", _cId];
_grave setVariable ["DOGTAG_DATA", _dogtagData, true];
_grave setVariable ["AGE",_vicAge, true];
_grave setVariable ["GR_CARGO",_cargo];
_grave setVariable ["GR_TIMEOFDEATH",_timeOfDeath];
_grave setVariable ["GR_KILLERSIDE",_killerSide];
_grave setVariable ["GR_DEATHCAUSE",_causeOfDeath];
if (_task != "") then {
	_grave setVariable ["GR_HIDEBODY_TASK",_task];
	_grave setVariable ["GR_NEXTOFKIN",_nextOfKin];
};