# Guilt & Remembrance
Mod for handling civilian deaths, reparations, and war crimes in Arma 3. Atone for your "collateral damage" by bringing the bodies of dead civilians back to their family — or else attempt to conceal the deaths by secretly disposing of the evidence.

Requirements: [CBA_A3](https://github.com/CBATeam/CBA_A3), [ACE3](https://github.com/acemod/ACE3)

**Features:**
* When a player kills a civilian, a new task is generated requiring the player to deliver the body to a member of their family, who lives in a house in the AO (within 20km by default).
* Alternatively, players may attempt to conceal the death by taking the body at least 300m away from a populated center, burying it, and striking off the dead civilian’s name from the grave marker.
* Any corpse in a body bag can now be buried or exhumed (requires an Entrenching Tool).
* Burying any corpse produces a burial mound from which the dead person’s name and age can be read.
* The items carried by the dead are transferred to the body bag, and persist through burial and exhumation.
* Mission creators can attach functions to event handlers to produce custom events upon civilian death, body delivery to next-of-kin, or death concealment.

**Planned features to come:**
* Medics will be able to perform an autopsy to determine cause of death and probable faction of killer (when near medical facility).

**FOR PLAYERS:**
In order to deliver a dead civilian to their family member, you must first place it in a Body Bag via an ACE action (Interactions -> Place body in body bag). The Body Bag can then be loaded into the cargo of a vehicle, driven to the destination, unloaded, and then manually dragged to the relative.

(Note: while the task to deliver the body is created immediately after you have killed the civilian, you will not be notified for 20-60 seconds so as not to distract you if you happen to be in the middle of combat.)

You can also bury or exhume any body bags if you are carrying an Entrenching Tool.

You can change how your notifications for civilian casualties are displayed in your Addon Settings (listed under "Guilt & Remembrance."). Note that this setting may be overriden by the mission creator or server operator.

**FOR MISSION CREATORS & SERVER OPERATORS:**
This mod is fully signed for multiplayer use, and has been tested on both local and dedicated servers. It must be run on both the client and server. 

The following mod settings are customizable from your mission scripts (run only on server):

```
// set the civilian types that will act as next-of-kin
GR_CIV_TYPES = ["C_man_polo_1_F_asia","C_man_polo_5_F_asia"];

// set the maximum distance from murder that next-of-kin will be spawned
GR_MAX_KIN_DIST = 20000;

// Chance that a player murdering a civilian will get an "apology" mission
GR_MISSION_CHANCE = 100;

// Delay in seconds after death until player is notified of body delivery mission
GR_TASK_MIN_DELAY=20;
GR_TASK_MID_DELAY=40;
GR_TASK_MAX_DELAY=60;

// You can also add/remove custom event handlers to be called upon
// certain events.

// On civilian murder by player:
[yourCustomEvent_OnCivDeath] call GR_fnc_addCivDeathEventHandler; // args [_killer, _killed, _nextofkin]
// (NOTE: _nextofkin will be nil if a body delivery mission wasn't generated.)
[yourCustomEvent_OnCivDeath] call GR_fnc_removeCivDeathEventHandler;

// On body delivery:
[yourCustomEvent_OnDeliverBody] call GR_fnc_addDeliverBodyEventHandler; // args [_killer, _nextofkin, _body]
[yourCustomEvent_OnDeliverBody] call GR_fnc_removeDeliverBodyEventHandler;

// On successful concealment of a death:
[yourCustomEvent_OnConcealDeath] call GR_fnc_addConcealDeathEventHandler; // args [_killer, _nextofkin, _grave]
[yourCustomEvent_OnConcealDeath] call GR_fnc_removeConcealDeathEventHandler;

// NOTE: if your event handler uses _nextofkin or _body, make sure to turn off garbage collection with:
// _nextofkin setVariable ["GR_WILLDELETE",false];
// _body setVariable ["GR_WILLDELETE",false];
```

GUILT & REMEMBRANCE is licensed under [APL-SA (Arma Public License - Share-Alike)](https://www.bohemia.net/community/licenses/arma-public-license-share-alike) and is free for non-commercial use. If you add it to your server, please tell me about it — I'm interested in how this mod will be used.

For questions, comments, or bug reports, please contact me directly at nick.musurca@gmail.com.

[Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=1736188034)

[Bohemia Forums](https://forums.bohemia.net/forums/topic/223257-guilt-remembrance-civilian-deaths-reparations-war-crimes/)


CHANGELOG:
---------------------

v1.22 (May 13, 2019):
* bugfix: now supports Antistasi (as well as other mods/game types where civilians are created on the client-side)

v1.21 (May 11, 2019):
* bugfix: death of Zeus-placed civilians now registered on dedicated servers

v1.2 (May 11, 2019):
* inventory of corpse now transfers to body bag
* body bag inventory persistent through burial & exhumation
* bugfixes for dedicated server

v1.11 (May 10, 2019):
* hotfix: singleplayer scenarios should now work
* event handler init moved into preInit -- no need to sleep before adding them

v1.1 (May 10, 2019):
* added CBA setting to customize notification style
* civilian deaths now always add a diary record
* added more classes to default GR_CIV_TYPES
* GR_TASK_MIN/MID/MAX_DELAY

v1.0 (May 8, 2019):
* Initial release
