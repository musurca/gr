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
if (isNil "GR_DEATHNOTIFY_MARKER") then { 
	GR_DEATHNOTIFY_MARKER=true;
};
if (isNil "GR_AUTOPSY_CLASS") then {
	GR_AUTOPSY_CLASS=1;
};

// new ACE actions for body bags and graves
GR_ace_autopsyAction = ["actionAutopsy",localize "STR_FNINITCLIENT_Autopsy_action","",{
	player playMove "acts_miller_knockout"; //alt: 'Acts_CivilTalking_2'
	[
		8,
		_target,
		{ // success
			params["_target"];
			player switchMove "";
			[_target,player] remoteExecCall ["GR_fnc_doautopsy",2];
		},
		{ // interruption
			player switchMove "";
		},
		localize "STR_FNINITCLIENT_Autopsy_process"
	] call ace_common_fnc_progressBar;
}, {("ACE_surgicalKit" in (items _player)) && (_player getVariable ["ace_medical_medicClass", 0] >= GR_AUTOPSY_CLASS) }] call ace_interact_menu_fnc_createAction;
["ACE_bodyBagObject",0,["ACE_MainActions"],GR_ace_autopsyAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_burialAction = ["actionBury",localize "STR_FNINITCLIENT_Bury_action","",{
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
		localize "STR_FNINITCLIENT_Bury_process"
	] call ace_common_fnc_progressBar;
}, {"ACE_EntrenchingTool" in (items _player)}] call ace_interact_menu_fnc_createAction;
["ACE_bodyBagObject",0,["ACE_MainActions"],GR_ace_burialAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_vandalizeAction = ["actionVandalize",localize "STR_FNINITCLIENT_Vandalize_action","",{
	if(_target getVariable ["IS_LEGIBLE",true]) then {
		player playMove "acts_miller_knockout";
		[
			2,
			_target,
			{ // success
				params["_target"];
				[_target,player] remoteExecCall ["GR_fnc_vandalizegrave",2];
				player switchMove "";
				hint localize "STR_FNINITCLIENT_Vandalize_hint";
			},
			{ // interruption
				player switchMove "";
			},
			localize "STR_FNINITCLIENT_Vandalize_process"
		] call ace_common_fnc_progressBar;
	} else {
		hintSilent localize "STR_FNINITCLIENT_Vandalized_hint";
	};
}, {true}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_vandalizeAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_exhumeAction = ["actionExhume",localize "STR_FNINITCLIENT_Exhume_action","",{
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
		localize "STR_FNINITCLIENT_Exhume_process"
	] call ace_common_fnc_progressBar;
}, {"ACE_EntrenchingTool" in (items _player)}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_exhumeAction] call ace_interact_menu_fnc_addActionToClass;

GR_ace_readEpitaphAction = ["actionEpitaph",localize "STR_FNINITCLIENT_Readmarker_action","",{
	params ["_target", "_player"];
	if(_target getVariable ["IS_LEGIBLE",true]) then {
		_name = (_target getVariable ["DOGTAG_DATA", [localize "STR_EXHUMEBODY_Unknown","",""]]) select 0;
		_age = _target getVariable ["AGE",0];
		_yearDied = date select 0;
		_yearBorn = _yearDied - _age;
		if (_name != localize "STR_EXHUMEBODY_Unknown") then {
			hintSilent parseText (format [localize "STR_FNINITCLIENT_epitaphy_text",toUpper _name,_yearBorn,_yearDied]);
		} else {
			hintSilent parseText (localize "STR_FNINITCLIENT_unknown_text");
		};
	} else {
		hintSilent localize "STR_FNINITCLIENT_scratched_hint";
	};
}, {true}] call ace_interact_menu_fnc_createAction;
["Land_Grave_dirt_F",0,["ACE_MainActions"],GR_ace_readEpitaphAction] call ace_interact_menu_fnc_addActionToClass;

[] spawn {
	if(profileNamespace getVariable ["GR_BLM_MESSAGE_SHOWN",0] != 1) then {
		profileNamespace setVariable ["GR_BLM_MESSAGE_SHOWN",1];
		sleep 1;
		_blmText = parseText "<t>Dear American friends:<br/>In the wake of George Floyd&#39;s murder by the Minneapolis Police, people all across the country have taken to the streets to protest the use of lethal force by local and state police. Nearly everywhere the police have responded with extreme violence: using batons, rubber bullets, and tear gas against crowds of unarmed and largely peaceful protesters. Many have suffered severe and permanent injuries; some have even been killed.<br/><br/>It is time to stop the flow of military equipment to the police, and end policies that have shielded violent police officers from prosecution. If you can, please support collective action by clicking the links below to support the following organizations:</t><t align='center'><br/><br/><a href='https://www.joincampaignzero.org'>Campaign Zero</a><br/><a href='https://www.naacpldf.org/'>NAACP Legal Defense Fund</a><br/><a href='https://blacklivesmatter.com/'>Black Lives Matter</a></t><t><br/><br/>Thanks for reading-- and please note that after clicking OK below, you will not see this message again.<br/><br/></t><t font='PuristaBold' align='center'>In solidarity with the international struggle against state violence in Hong Kong, Russia, France, and beyond.</t>";
		[_blmText, "Guilt & Remembrance - June 3, 2020", "OK"] spawn BIS_fnc_guiMessage;
	};
};
