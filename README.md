# Guilt & Remembrance
Mod for handling civilian deaths, reparations, and war crimes in Arma 3. Atone for your "collateral damage" by delivering the bodies of dead civilians to their next-of-kin -- or else attempt to conceal the deaths by secretly disposing of the bodies.

Requirements: [CBA_A3](https://github.com/CBATeam/CBA_A3), [ACE3](https://github.com/acemod/ACE3)

**Features:**
* When a player kills a civilian, a new task is generated requiring the player to deliver the body to their next-of-kin, who lives in a house in the AO (within 20km by default).
* Alternatively, players may attempt to conceal the death by taking the body at least 300m away from a populated center, burying it, and striking off the dead civilian’s name from the grave marker.
* Any corpse in a body bag can now be buried or exhumed (requires an Entrenching Tool).
* Burying any corpse produces a burial mound from which the dead person’s name and age can be read.
* Mission creators can attach functions to event handlers to produce custom events upon civilian death, body delivery to next-of-kin, or death concealment.

**Planned features to come:**
* Medics will be able to perform an autopsy to determine cause of death and probable faction of killer (when near medical facility)

**FOR PLAYERS:**
In order to deliver a dead civilian to their next-of-kin, you must first place it in a Body Bag via an ACE action (Interactions -> Place body in body bag). The Body Bag can then be loaded into the cargo of a vehicle, driven to the destination, unloaded, and then manually dragged to the next-of-kin.

(Note: while the task to deliver the body is created immediately after you have killed the civilian, you will not be notified for 20-60 seconds so as not to distract you if you happen to be in the middle of combat.)

You can also bury or exhume any body bags if you are carrying an Entrenching Tool.

**FOR MISSION CREATORS & SERVER OPERATORS:**
This mod is fully signed for multiplayer use, and has been tested on both local and dedicated servers. It must be run on both the client and server. 

The following mod settings are customizable from your mission scripts:

```
// set the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];
// set the maximum distance from murder that next-of-kin will be spawned
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

GUILT & REMEMBRANCE is licensed under [APL-SA (Arma Public License - Share-Alike)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike) and is free for non-commercial use. If you add it to your server, please tell me about it — I'm interested in how this mod will be used.

For questions, comments, or bug reports, please contact me directly at nick.musurca@gmail.com.

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1736188034)
[Bohemia Forums](https://forums.bohemia.net/forums/topic/223257-guilt-remembrance-civilian-deaths-reparations-war-crimes/)
