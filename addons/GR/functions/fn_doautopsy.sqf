/*

 fn_doautopsy.sqf
 by @musurca

 Performs an autopsy on a bodybag and sends information about the cause of death.
 More information is provided if near a medical facility.

*/

if(!isServer) exitWith {};

params ["_target","_player"];

// Are we a doctor or are we near a medical facility?
_medicF=false;
if(_player getVariable ["ace_medical_medicClass", 0] == 2) then {
	_medicF=true;
} else {
	_nearObjs = _target nearObjects 15;
	if(_nearObjs findIf {(_x getVariable ["ace_medical_isMedicalFacility", false]) || ((!isPlayer _x) && (_x getVariable ["ace_medical_medicClass", 0] > 0))} != -1) then {
		_medicF = true;
	};
};

// Patient name & age
_dogtagData = _target getVariable ["DOGTAG_DATA",[]];
if ((count _dogtagData) == 0) then {
	_dogtagData = [_target] call ace_dogtags_fnc_getDogtagData;
};
_patientName = _dogtagData select 0;
_patientAge = _target getVariable [localize "STR_AUTOPSY_Age",(round random [18,30,50])];
_isUnknown = false;
if(_patientName == localize "STR_EXHUMEBODY_Unknown" || (_patientName isEqualTo "Bodybag")) then {
	_isUnknown = true;
} else {
	_patientName = format [localize "STR_AUTOPSY_Name_Age",_patientName,_patientAge];
};
_causeMsg = localize "STR_AUTOPSY_Name" + _patientName + "<br/><br/>";

// Cause of death
_causeMsg = _causeMsg + localize "STR_AUTOPSY_Cause" +
			(GR_COD_MSGS select (_target getVariable ["GR_DEATHCAUSE",GR_COD_UNKNOWN]));

// Additional information that can only be determined at a medical facility
if(_medicF) then {
	_killerSide = _target getVariable ["GR_KILLERSIDE",CIVILIAN];
	if(_killerSide != CIVILIAN) then {
		_factionName = localize "STR_AUTOPSY_killernone";
		if(_killerSide == EAST) then {
			_factionName = GR_FACTIONNAME_EAST;
		};
		if(_killerSide == WEST) then {
			_factionName = GR_FACTIONNAME_WEST;
		};
		if(_killerSide == INDEPENDENT) then {
			_factionName = GR_FACTIONNAME_IND;
		};
		_causeMsg = _causeMsg + localize "STR_AUTOPSY_CauseMsg" + _factionName + ".<br/><br/>";
	} else {
		_causeMsg = _causeMsg + "<br/><br/>";
	};

	_timeOfDeath = _target getVariable ["GR_TIMEOFDEATH",[]];
	if(count _timeOfDeath > 0) then {
		_year = _timeOfDeath select 0;
		_month = _timeOfDeath select 1;
		_day = _timeOfDeath select 2;
		_hour = _timeOfDeath select 3;

		_monthText = [localize "STR_AUTOPSY_January",localize "STR_AUTOPSY_February",localize "STR_AUTOPSY_March",localize "STR_AUTOPSY_April",localize "STR_AUTOPSY_May",localize "STR_AUTOPSY_June",localize "STR_AUTOPSY_July",localize "STR_AUTOPSY_August",localize "STR_AUTOPSY_September",localize "STR_AUTOPSY_October",
					  localize "STR_AUTOPSY_November", localize "STR_AUTOPSY_December"] select (_month - 1);
		_hourText = str (_hour) + localize "STR_AUTOPSY_hours";
		if(_hour < 10) then {
			_hourText = "0" + _hourText;
		};
		_dateText = format [localize "STR_AUTOPSY_Timeofdeath_text",_monthText,_day,_hourText];

		_causeMsg = _causeMsg + localize "STR_AUTOPSY_Timeofdeath" + _dateText;
	};

	if(_isUnknown) then {
		_firstName = _dogtagData select 1;
		_lastName = _dogtagData select 2;
		_actualName = format [localize "STR_AUTOPSY_Actualname",_firstName,_lastName];
		_target setVariable ["DOGTAG_DATA",[_actualName,"",""]];
		_causeMsg = _causeMsg + localize "STR_AUTOPSY_identityMsg" + format [localize "STR_AUTOPSY_identityMsgtext",_actualName,_patientAge];

		[_player, _target, _actualName] call GR_fnc_makeMissionDeliverBody;
		
		// Call custom event handler on reveal of concealed identity
		{
			[_player, _target, _killerSide] call _x;
		} forEach GR_EH_REVEALDEATH;
	};
} else {
	_causeMsg = _causeMsg + localize "STR_AUTOPSY_learnmore_text";
};

// Send to player
_causeMsg remoteExec ["GR_fnc_localNotifyAutopsy",owner _player];
