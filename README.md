# Guilt & Remembrance
Framework for handling civilian deaths, reparations, and war crimes in Arma 3 missions.
Requirements: CBA_A3, ACE3

Usage:
in your mission's init.sqf, add the following lines:

```
// customize with the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];
[] call compile preprocessFile "gr\init.sqf";

// OPTIONAL: register custom event functions, e.g.
[ALIVE_reduceForcePool] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed]
[ALiVE_addForcePoolBig] call GR_fnc_addDeliverBodyEventHandler; // args [_killer]
[ALiVE_addForcePoolSmall] call GR_fnc_addConcealDeathEventHandler; // args [_killer]
```
