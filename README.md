# Guilt & Remembrance
Framework for handling civilian deaths, reparations, and war crimes in Arma 3 missions.
Requirements: CBA_A3, ACE3

v1.0

Usage:
in your mission's init.sqf, add the following lines:

```
/// set the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];
// set the maximum distance from murder than next-of-kin will be spawned
GR_MAX_KIN_DIST = 10000;
[] call compile preprocessFile "gr\init.sqf";


/// OPTIONAL: register custom event functions, e.g.

// On civilian murder by player:
[yourCustomEvent_OnCivDeath] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed, _nextofkin]

// On body delivery:
[yourCustomEvent_OnDeliverBody] call GR_fnc_addDeliverBodyEventHandler; // args [_killer, _nextofkin, _body]

// On concealment of a death:
[yourCustomEvent_OnConcealDeath] call GR_fnc_addConcealDeathEventHandler; // args [_killer, _nextofkin, _grave]

// NOTE: if your event uses _nextofkin or _body, make sure to turn off garbage collection with:
// _nextofkin setVariable ["GR_WILLDELETE",false];
// _body setVariable ["GR_WILLDELETE",false];
```
