/*

 fn_MPhint.sqf
 by @musurca
 
 Function for printing text notifications from server. Depends on player/mission/server-determined notification style.
 Civilian deaths always go into the player's diary record.

*/

params["_killerName","_killedName","_killedAge"];

_text = format [GR_CLIENT_NOTIFY_TEXT, _killerName, _killedName, _killedAge];

switch (GR_DEATHNOTIFY_STYLE) do {
	case GR_NOTIFY_HINT: { hintSilent parseText _text };
	case GR_NOTIFY_SIDECHAT: { [side player, "HQ"] sideChat parseText _text };
};

// Make diary record of killing
_now = date;
_month = (_now select 1) - 1;
_day = _now select 2;
_hour = _now select 3;
if (_hour < 10) then {
	_hour = format["0%1",_hour];
};
_min = _now select 4;
if (_min < 10) then {
	_min = format["0%1",_min];
};


_formatTime = format ["%1 %2, %3%4",GR_MONTHS select _month,_day,_hour,_min];
_diaryText= format ["%1: %2 killed %3 (%4)", _formatTime,_killerName, _killedName, _killedAge];
player createDiaryRecord ["Diary", ["Civilian Death", _diaryText]];