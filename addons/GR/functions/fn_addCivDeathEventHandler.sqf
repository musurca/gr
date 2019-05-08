/*

 fn_addCivDeathEventHandler.sqf
 by @musurca
 
 Adds a custom event handler to be called upon civilian deaths.
 
 Arguments passed to the function are:
  0 - Object - the player unit who killed the civilian
  1 - Object - the dead civilian
  2 - Object - the next-of kin. Will be nil if no kin was created.

*/

GR_EH_CIVDEATH pushBack (_this select 0);