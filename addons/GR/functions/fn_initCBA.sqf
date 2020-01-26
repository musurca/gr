/*

 fn_initCBA.sqf
 by @musurca
 
 Initializes CBA settings and mission event handlers.

 */
 
 
// For storing event handlers
GR_EH_CIVDEATH = [];
GR_EH_DELIVERBODY = [];
GR_EH_CONCEALDEATH = [];
GR_EH_REVEALDEATH = [];

// CBA settings
GR_NOTIFY_DIARY=0;
GR_NOTIFY_SIDECHAT=1;
GR_NOTIFY_HINT=2;

GR_AUTOPSY_ANYONE=0;
GR_AUTOPSY_MEDICS=1;
GR_AUTOPSY_DOCTORS=2;

[
    "GR_DEATHNOTIFY_STYLE",
    "LIST",
	["Civilian death notification style","Choose where the notification of a civilian death appears."],
	"Guilt & Remembrance",
	[[GR_NOTIFY_DIARY,GR_NOTIFY_SIDECHAT,GR_NOTIFY_HINT],["Diary Record Only","Side Chat (lower left)","Hint (top right)"],2]
] call CBA_fnc_AddSetting;

[
    "GR_DEATHNOTIFY_MARKER",
    "CHECKBOX",
	["Mark civilian deaths on map?","If selected, civilian deaths will be marked on the map with a yellow dot."],
	"Guilt & Remembrance",
	true
] call CBA_fnc_AddSetting;

[
    "GR_AUTOPSY_CLASS",
    "LIST",
	["Who can perform autopsies?","Choose which class(es) can perform basic autopsies."],
	"Guilt & Remembrance",
	[[GR_AUTOPSY_ANYONE,GR_AUTOPSY_MEDICS,GR_AUTOPSY_DOCTORS],["Anyone","Medics+Doctors","Doctors only"],1]
] call CBA_fnc_AddSetting;

[
    "GR_ONKILL_ADDBODYBAG",
    "CHECKBOX",
	["Add bodybag to dead civilian's inventory?","Use in scenarios where bodybags would be otherwise impossible to obtain, e.g. Antistasi."],
	"Guilt & Remembrance",
	false
] call CBA_fnc_AddSetting;