/*

 fn_localBodyBagged.sqf
 by @musurca
 
 Callback from server notifying client that a corpse has been bagged.

*/

params["_corpseId"];

deleteMarkerLocal format["GRmrk_%1",_corpseId];