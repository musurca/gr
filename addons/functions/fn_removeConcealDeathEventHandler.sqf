/*
 fn_removeConcealDeathEventHandler.sqf
 by @musurca
 
 Removes a previously-added custom event handler to be called upon a concealed death.
 
*/
GR_EH_CONCEALDEATH = GR_EH_CONCEALDEATH - [_this select 0];