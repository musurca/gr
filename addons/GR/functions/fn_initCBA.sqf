/*

 fn_initCBA.sqf
 by @musurca
 
 Initializes CBA settings and mission event handlers.

 */
 
 
// For storing event handlers
GR_EH_CIVDEATH = [];
GR_EH_DELIVERBODY = [];
GR_EH_CONCEALDEATH = [];

// CBA settings
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