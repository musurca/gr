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
			class makeMissionDeliverBody			{};
			class burybody							{};
			class exhumebody						{};
			class vandalizegrave            		{};
			class addCivDeathEventHandler			{};
			class removeCivDeathEventHandler		{};
			class addConcealDeathEventHandler		{};
			class removeConcealDeathEventHandler	{};
			class addDeliverBodyEventHandler		{};
			class removeDeliverBodyEventHandler		{};
			class MPhint							{};
    	};
	};
};