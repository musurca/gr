/*

 fn_onClientCivKilled.sqf
 by @musurca
 
 Remote call from client about dead civilian.

*/

if (!isServer) exitWith {};

params["_killed", "_killer", "_name"];

/* Workaround for name bug in MP engine.
   (Only last names of civilians created on the client
   are given to the server when ownership is transferred.)
*/
_nameTokens = _name splitString " ";
_killed setName [_name, _nameTokens select 0, _nameTokens select 1];

// Call event handler as if civilian was killed on server
[_killed, _killer] call GR_fnc_onUnitKilled;

// Schedule a transfer of ownership to server.
// The short delay prevents strange rag-doll behavior.
[_killed] spawn {
	params["_killed"];
	sleep 5;
	(group _killed) setGroupOwner 2;
	sleep 5;
	if (isInRemainsCollector _killed) then {
		removeFromRemainsCollector [_killed];
	};
};