/*
 fn_addDeliverBodyEventHandler.sqf
 by @musurca
 
 Adds a custom event handler to be called upon a successful body delivery.
 
 Arguments passed to the function are:
  0 - Object - the player unit who killed the civilian
  1 - Object - the next-of kin
  2 - Object - the body
*/
GR_EH_DELIVERBODY pushBack (_this select 0);