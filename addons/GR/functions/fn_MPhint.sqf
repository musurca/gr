/*

 fn_MPhint.sqf
 by @musurca
 
 Function for printing text notifications from server. Depends on player/mission/server-determined notification style.
 Civilian deaths always go into the player's diary record.

*/

params["_killerName","_killedName","_killedAge"];

switch (GR_DEATHNOTIFY_STYLE) do {
	case GR_NOTIFY_HINT: { 
		_text = format ["<t color='#cc0808' align='center'>%1 has killed a civilian.<br/><t color='#dddddd'>(%2, age %3)</t></t>",
						_killerName, _killedName, _killedAge];
		hintSilent parseText _text 
	};
	case GR_NOTIFY_SIDECHAT: { 
		_text = format ["%1 has killed a civilian. (%2, age %3)",_killerName, _killedName, _killedAge];
		[side player, "HQ"] sideChat _text 
	};
};

// Make diary record of killing
_diaryText= format ["%1 killed %2 (age %3).", _killerName, _killedName, _killedAge];
player createDiaryRecord ["Diary", ["Civilian Deaths", _diaryText]];