/*
 fn_addConcealDeathEventHandler.sqf
 by @musurca
 
 Adds a custom event handler to be called upon a successfully concealed death.
 
 Arguments passed to the function are:
  0 - Object - the player unit who killed the civilian
  1 - Object - the next-of kin
  2 - Object - the grave in which the body was buried
*/
GR_EH_CONCEALDEATH pushBack (_this select 0);