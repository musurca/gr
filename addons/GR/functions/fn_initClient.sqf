/*
 
 fn_initClient.sqf
 by @musurca

 Assorted client actions: Zeus support, ACE actions, etc.

*/

if(!hasInterface) exitWith{};

//shouldn't happen, but just in case of CBA failure
if (isNil "GR_DEATHNOTIFY_STYLE") then { 
	GR_DEATHNOTIFY_STYLE=GR_NOTIFY_HINT;
};

// If made Zeus after connecting to a dedicated server,
// transfer ownership of civilian units to the server
if (!isServer) then {
	[] spawn {
		waitUntil {!isNull (getAssignedCuratorLogic player)};
		(getAssignedCuratorLogic player) addEventHandler ["CuratorObjectPlaced", {
			params["_curator", "_entity"];
			if ((side group _entity) == civilian) then {
				{
					if(_x isKindOf "CAManBase") then {	
						[_x, name _x] remoteExecCall ["GR_fnc_onZeusCivPlaced",2];
					};
				} forEach units (group _entity);
			};
		}];
	};
};

// new ACE actions for body bags and graves
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