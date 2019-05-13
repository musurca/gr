/*

 fn_onClientCivKilled.sqf
 by @musurca
 
 Remote call from client about dead civilian.

*/

if (!isServer) exitWith {};

params["_killed", "_killer", "_name"];

// Transfer ownership to server immediately
(group _killed) setGroupOwner 2;

// Fix strange name transfer bug
_nameTokens = _name splitString " ";
_killed setName [_name, _nameTokens select 0, _nameTokens select 1];

[_killed, _killer] call GR_fnc_onUnitKilled;
