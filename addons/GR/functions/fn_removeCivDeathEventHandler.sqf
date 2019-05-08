/*
 fn_removeCivDeathEventHandler.sqf
 by @musurca
 
 Removes a previously-added custom event handler to be called upon civilian deaths.
 
*/
GR_EH_CIVDEATH = GR_EH_CIVDEATH - [_this select 0];