/*

 fn_localNotifyAutopsy.sqf
 by @musurca
 
 Function for printing text of autopsy report.

*/

params["_autopsyText"];

_xmlText = format["<t>%1</t>",_autopsyText];
[parseText _xmlText, "Autopsy Report", "Approve"] call BIS_fnc_guiMessage;