/*

 fn_localNotifyCivDeath.sqf
 by @musurca
 
 Function for printing text notifications from server. Depends on player/mission/server-determined notification style.
 Civilian deaths always go into the player's diary record.

*/

params["_killerName","_killedName","_killedAge", "_killedPos", "_killedId"];

switch (GR_DEATHNOTIFY_STYLE) do {
	case GR_NOTIFY_HINT: {
		_text = format [localize "STR_LOCALNOTIFYCIVDEATH_Civkilled_hint",
						_killerName, _killedName, _killedAge];
		hintSilent parseText _text 
	};
	case GR_NOTIFY_SIDECHAT: {
		_text = format [localize "STR_LOCALNOTIFYCIVDEATH_Civkilled_chat",_killerName, _killedName, _killedAge];
		[side player, "HQ"] sideChat _text
	};
};

if (GR_DEATHNOTIFY_MARKER) then {
	_marker = createMarkerLocal [format["GRmrk_%1",_killedId],_killedPos];
	_marker setMarkerShapeLocal "ICON";
	_marker setMarkerTypeLocal "mil_dot";
	_marker setMarkerColorLocal "ColorYellow";
	_marker setMarkerAlphaLocal 0.5;
};

// Make diary record of killing
_diaryText= format [localize "STR_LOCALNOTIFYCIVDEATH_Civkilled_diary", _killerName, _killedName, _killedAge];
player createDiaryRecord ["Diary", [localize "STR_LOCALNOTIFYCIVDEATH_diary", _diaryText]];
