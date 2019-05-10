/*

 XEH_PreInit.sqf
 by @musurca
 
 Initializes CBA settings.

 */

GR_NOTIFY_DIARY=0;
GR_NOTIFY_SIDECHAT=1;
GR_NOTIFY_HINT=2;

[
    "GR_DEATHNOTIFY_STYLE",
    "LIST",
	"Civilian Death Notification Style",
	"Guilt & Remembrance",
	[[GR_NOTIFY_DIARY,GR_NOTIFY_SIDECHAT,GR_NOTIFY_HINT],["Diary Record Only","Side Chat (lower left)","Hint (top right)"],2]
] call CBA_fnc_AddSetting;