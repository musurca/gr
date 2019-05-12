/*

 fn_onZeusCivPlaced.sqf
 by @musurca
 
 Remote call from curator client about new civilian.

*/

if (!isServer) exitWith {};

params["_entity", "_name"];

// Transfer ownership to server immediately
(group _entity) setGroupOwner 2;

// Fix strange name transfer bug
_nameTokens = _name splitString " ";
_entity setName [_name, _nameTokens select 0, _nameTokens select 1];