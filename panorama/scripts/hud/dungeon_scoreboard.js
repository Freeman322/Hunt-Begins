"use strict"

function intToARGB(i) 
{ 
                return ('00' + ( i & 0xFF).toString( 16 ) ).substr( -2 ) +
                                               ('00' + ( ( i >> 8 ) & 0xFF ).toString( 16 ) ).substr( -2 ) +
                                               ('00' + ( ( i >> 16 ) & 0xFF ).toString( 16 ) ).substr( -2 ) + 
                                                ('00' + ( ( i >> 24 ) & 0xFF ).toString( 16 ) ).substr( -2 );
}

function ToggleMute( nRowID )
{

}


function GetLocalPlayerId()
{
	var localPlayerId = 0;
	var localPlayerInfo = Game.GetLocalPlayerInfo();
	if(typeof(localPlayerInfo) !== "undefined")
	{
		localPlayerId = localPlayerInfo.player_id;
	}

	if(Players.IsLocalPlayerInPerspectiveCamera())
	{
		//get local player info for selected portrait unit
		localPlayerId = Players.GetPerspectivePlayerId();
	}
	return localPlayerId;
}

function UpdatePlayerImages()
{
	
}

function UpdateZoneScores( zoneName )
{
	
	
}

function UpdatePlayerZones()
{
	//$.Msg( "UpdatePlayerZones" );
}

var g_nCurZone = -1;

function ZoneScoresReceived()
{
	

}

var g_szZoneNameClass = null;

function OnZoneCompleted( data )
{

}

function HideZoneCompleted()
{
	
}

function ScanForValidZoneName( nStart, nDir )
{
	
}

function FindZoneByName( zoneName )
{


	return -1;
}

function OnEasyModeStarted()
{
	$.GetContextPanel().SetHasClass( "EasyMode", true );
}

function SetFlyoutScoreboardVisible( bVisible )
{
	if(bVisible === true)
	{
		
	}
	else
	{
		
	}
	$.GetContextPanel().SetHasClass( "flyout_scoreboard_visible", bVisible );
	
}

function SetFlyoutScoreboardChangeZone( nDir )
{

	
}

(function()
{	
	//InitializeScoreboard();
	SetFlyoutScoreboardVisible(false);

	$("#ZoneRequirementContainer").SwitchClass("TabSlot", "Tab1Selected");
	
	$.RegisterEventHandler( "DOTACustomUI_SetFlyoutScoreboardVisible", $.GetContextPanel(), SetFlyoutScoreboardVisible );
	$.RegisterEventHandler("DOTACustomUI_SetFlyoutScoreboardChangeZone", $.GetContextPanel(), SetFlyoutScoreboardChangeZone);
})();

