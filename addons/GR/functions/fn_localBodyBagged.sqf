/*

 fn_localBodyBagged.sqf
 by @musurca
 
 Callback from server notifying client that a corpse has been bagged.

*/

params["_corpseId"];

try {
	deleteMarkerLocal format["GRmrk_%1",_corpseId];
} catch { 
	// no marker to delete
};