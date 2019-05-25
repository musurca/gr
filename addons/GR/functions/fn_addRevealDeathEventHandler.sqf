/*

 fn_addRevealDeathEventHandler.sqf
 by @musurca
 
 Adds a custom event handler to be called upon a concealed death revealed by an autopsy.
 
 Arguments passed to the function are:
  0 - Object - the player unit who performed the autopsy
  1 - Object - the body of the dead civilian
  2 - Side - the side of the killer

*/

GR_EH_REVEALDEATH pushBack (_this select 0);