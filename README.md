# Guilt & Remembrance
Mod for handling civilian deaths, reparations, and war crimes in Arma 3 missions.
Requirements: CBA_A3, ACE3

v1.0

The following settings are customizable by mission creators from scripts:

```
// set the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];
// set the maximum distance from murder than next-of-kin will be spawned
GR_MAX_KIN_DIST = 20000;
// Chance that a player murdering a civilian will get an "apology" mission
GR_MISSION_CHANCE = 100;

// You can also add/remove custom event handlers to be called upon
// certain events. Adding event handlers must occur AFTER postInit
// (in other words, just add a small sleep).

[] spawn {
sleep 1;
// On civilian murder by player:
[yourCustomEvent_OnCivDeath] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed, _nextofkin]
[yourCustomEvent_OnCivDeath] call GR_fnc_removeCivDeathEventHandler;

// On body delivery:
[yourCustomEvent_OnDeliverBody] call GR_fnc_addDeliverBodyEventHandler; // args [_killer, _nextofkin, _body]
[yourCustomEvent_OnDeliverBody] call GR_fnc_removeDeliverBodyEventHandler;

// On concealment of a death:
[yourCustomEvent_OnConcealDeath] call GR_fnc_addConcealDeathEventHandler; // args [_killer, _nextofkin, _grave]
[yourCustomEvent_OnConcealDeath] call GR_fnc_removeConcealDeathEventHandler;

// NOTE: if your event handler uses _nextofkin or _body, make sure to turn off garbage collection with:
// _nextofkin setVariable ["GR_WILLDELETE",false];
// _body setVariable ["GR_WILLDELETE",false];
};
```
