/*

 fn_doautopsy.sqf
 by @musurca

 Performs an autopsy on a bodybag and sends information about the cause of death.
 More information is provided if near a medical facility.

*/

if(!isServer) exitWith {};

params ["_target","_player"];

// Are we near a medical facility?
_medicF=false;
_nearObjs = _target nearObjects 15;
{
	if(_x getVariable ["ace_medical_medicClass", 0]==1) exitWith { _medicF = true };
} forEach _nearObjs;

// Patient name & age
_dogtagData = _target getVariable ["DOGTAG_DATA",[]];
if ((count _dogtagData) == 0) then {
	_dogtagData = [_target] call ace_dogtags_fnc_getDogtagData;
};
_patientName = _dogtagData select 0;
_patientAge = _target getVariable ["AGE",(round random [18,30,50])];
_isUnknown = false;
if(_patientName == "Unknown" || (_patientName isEqualTo "Bodybag")) then { 
	_isUnknown = true; 
} else {
	_patientName = format ["%1 (age %2)",_patientName,_patientAge];
};
_causeMsg = "NAME: " + _patientName + "<br/><br/>"; 

// Cause of death
_causeMsg = _causeMsg + "CAUSE OF DEATH: " + 
			(GR_COD_MSGS select (_target getVariable ["GR_DEATHCAUSE",GR_COD_UNKNOWN]));

// Additional information that can only be determined at a medical facility
if(_medicF) then {
	_killerSide = _target getVariable ["GR_KILLERSIDE",CIVILIAN];
	if(_killerSide != CIVILIAN) then {
		_factionName = "no one";
		if(_killerSide == EAST) then {
			_factionName = GR_FACTIONNAME_EAST;
		};
		if(_killerSide == WEST) then {
			_factionName = GR_FACTIONNAME_WEST;
		};
		if(_killerSide == INDEPENDENT) then {
			_factionName = GR_FACTIONNAME_IND;
		};
		_causeMsg = _causeMsg + " The wounds are consistent with equipment used by " + _factionName + ".<br/><br/>";
	} else {
		_causeMsg = _causeMsg + "<br/><br/>";
	};

	_timeOfDeath = _target getVariable ["GR_TIMEOFDEATH",[]];
	if(count _timeOfDeath > 0) then {
		_year = _timeOfDeath select 0;
		_month = _timeOfDeath select 1;
		_day = _timeOfDeath select 2;
		_hour = _timeOfDeath select 3;
		
		_monthText = ["January","February","March","April","May","June","July","August","September","October",
					  "November","December"] select (_month - 1);
		_hourText = str (_hour) + "00 hours";
		if(_hour < 10) then {
			_hourText = "0" + _hourText;
		};
		_dateText = format ["%1 %2, around %3.",_monthText,_day,_hourText];
		
		_causeMsg = _causeMsg + "TIME OF DEATH: " + _dateText;
	};

	if(_isUnknown) then {
		_firstName = _dogtagData select 1;
		_lastName = _dogtagData select 2;
		_actualName = format ["%1 %2",_firstName,_lastName];
		_target setVariable ["DOGTAG_DATA",[_actualName,"",""]];
		_causeMsg = _causeMsg + "<br/><br/>IDENTITY: Dental records indicate that the patient may be " + format ["%1, a %2-year-old male. His family has been notified.",_actualName,_patientAge];
	
		[_player, _target, _actualName] call GR_fnc_makeMissionDeliverBody;
	};
} else {
	_causeMsg = _causeMsg + "<br/><br/>To learn more, you would need to perform this autopsy closer to a medical facility.";
};

// Send to player
_causeMsg remoteExec ["GR_fnc_localNotifyAutopsy",owner _player];