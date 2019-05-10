/*

 fn_MPhint.sqf
 by @musurca
 
 Function for printing text notifications from server. Depends on player/mission/server-determined notification style.

*/

switch (GR_DEATHNOTIFY_STYLE) do {
	case GR_NOTIFY_HINT: { hintSilent parseText _this };
	case GR_NOTIFY_SIDECHAT: { [side player, "HQ"] sideChat parseText _this };
};
