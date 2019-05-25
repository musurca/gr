class CfgPatches {
	class GuiltAndRemembrance
	{
		author="musurca";
		name="Guilt & Remembrance";
		units[]={};
		weapons[]={};
		requiredAddons[]={"A3_Modules_F","CBA_main","ace_main"};
	};
};

class CfgFunctions 
{
	class GR
	{
		tag = "GR";
    	class funcs
    	{
        	file = "\GR\functions";
        	class initCBA							{ preInit = 1; };
			class initClient      	  				{ postInit = 1; }; 
			class initServer          				{ postInit = 1; };
			class onUnitKilled						{};
			class onLocalCivKilled					{};
			class onClientCivKilled					{};	
			class makeMissionDeliverBody			{};
			class burybody							{};
			class exhumebody						{};
			class vandalizegrave            		{};
			class doautopsy							{};
			class addCivDeathEventHandler			{};
			class removeCivDeathEventHandler		{};
			class addConcealDeathEventHandler		{};
			class removeConcealDeathEventHandler	{};
			class addDeliverBodyEventHandler		{};
			class removeDeliverBodyEventHandler		{};
			class addRevealDeathEventHandler		{};
			class removeRevealDeathEventHandler		{};
			class localNotifyCivDeath				{};
			class localBodyBagged					{};
			class localNotifyAutopsy				{};
    	};
	};
};

class Extended_Killed_EventHandlers {
    class CAManBase {
        class GR_CAManBase_Init {
            killed = "if(!isServer) then { [_this select 0, _this select 1] call GR_fnc_onLocalCivKilled; }";
        };
    };
};