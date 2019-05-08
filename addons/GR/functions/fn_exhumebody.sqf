/*
 
 fn_exhumebody.sqf
 by @musurca

 Exhumes a body from a grave, preserving all information known about it.

*/

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
