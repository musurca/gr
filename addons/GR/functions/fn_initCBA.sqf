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
	[localize "STR_FNINITCBA_civdeath_noticestyle",localize "STR_FNINITCBA_civdeath_noticestyle2"],
	"Guilt & Remembrance",
	[[GR_NOTIFY_DIARY,GR_NOTIFY_SIDECHAT,GR_NOTIFY_HINT],[localize "STR_FNINITCBA_notice_diary",localize "STR_FNINITCBA_notice_chat",localize "STR_FNINITCBA_notice_hint"],2]
] call CBA_fnc_AddSetting;

[
    "GR_DEATHNOTIFY_MARKER",
    "CHECKBOX",
	[localize "STR_FNINITCBA_civdeath_marks",localize "STR_FNINITCBA_civdeath_marks2"],
	"Guilt & Remembrance",
	true
] call CBA_fnc_AddSetting;

[
    "GR_AUTOPSY_CLASS",
    "LIST",
	[localize "STR_FNINITCBA_candoautopsy",localize "STR_FNINITCBA_candoautopsy2"],
	"Guilt & Remembrance",
	[[GR_AUTOPSY_ANYONE,GR_AUTOPSY_MEDICS,GR_AUTOPSY_DOCTORS],[localize "STR_FNINITCBA_anyone", lozalize "STR_FNINITCBA_medicsdoctors",localize"STR_FNINITCBA_doctorsonly"],1]
] call CBA_fnc_AddSetting;

[
    "GR_ONKILL_ADDBODYBAG",
    "CHECKBOX",
	[localize "STR_FNINITCBA_addbodybag",localize "STR_FNINITCBA_addbodybag2"],
	"Guilt & Remembrance",
	false
] call CBA_fnc_AddSetting;
