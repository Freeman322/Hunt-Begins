"use strict";

GameUI.SetCameraTerrainAdjustmentEnabled( false );

var TABLE_KEY_PLAYERDATA = "players"

var PAGES = [
    $("#Book_Left"),
    $("#Book_LeftPageTwo")
]

var COSTS = []
COSTS.Archer = 50
COSTS.Palladin = 10
COSTS.Warrior = 25


var PAGE = 0
var MAX_PAGES = PAGES.length

var g_flDialogAdvanceTime = -1;
var g_nCurrentCharacter = 0;
var g_flCharacterAdvanceRate = 0.0075;
var g_szPendingDialog = null;
var g_nCurrentDialogEnt = -1;
var g_nCurrentDialogLine = -1;
var g_bSentToAll = false;
var g_szConfirmToken = null;
var g_bShowAdvanceButton = true;
var g_nMovingCameraOffset = 600;
var g_nStillCameraOffset = 0;
var g_flTimeSpentMoving = 0.0;
var HUD_THINK = 0.005;
var g_bInBossIntro = false;
var g_nBossCameraEntIndex = -1;
var g_flCameraDesiredOffset = 128.0;
var g_flAdditionalCameraOffset = 0.0;
var g_flMaxLookDistance = 1200.0;
var g_bSentGuideDisable = false;
var g_szLastZoneLocation = null;
var g_ZoneList = [ 	"start", 
					"forest", 
					"forest_holdout", 
					"darkforest_death_maze", 
					"darkforest_rescue", 
					"darkforest_pass", 
					"underground_temple", 
					"desert_start", 
					"desert_town", 
					"desert_expanse",
					"desert_outpost",
					"desert_chasm",
                    "desert_fortress" ];
                    
(function(){
	GameEvents.Subscribe( "on_area_discovered", OnDiscovered );
    GameEvents.Subscribe( "on_escape", OnEscape );
    GameEvents.Subscribe( "on_escape_done", OnEscapeDone );
    GameEvents.Subscribe( "on_boss_killed", OnBossKilled );
    GameEvents.Subscribe( "on_boss_found", OnBossFound );

    CustomNetTables.SubscribeNetTableListener("gamemode", OnGameStateChanged);

    PageChanged()
})();

(function HUDThink()
{	
	var flThink = HUD_THINK;

	if ( !g_bSentToAll && $( "#FloatingDialogPanel" ).BHasClass( "Visible") )
	{
		var vAbsOrigin = Entities.GetAbsOrigin( g_nCurrentDialogEnt );
		var nX = Game.WorldToScreenX( vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2] );
		var nY = Game.WorldToScreenY( vAbsOrigin[0], vAbsOrigin[1], vAbsOrigin[2] );
		$( "#FloatingDialogPanel" ).style.x = ( nX / $( "#FloatingDialogPanel" ).actualuiscale_x ) + 25 + "px"; 
		$( "#FloatingDialogPanel" ).style.y = ( nY / $( "#FloatingDialogPanel" ).actualuiscale_y  ) - 100 + "px";
	}

	$( "#DungeonHUDContents" ).SetHasClass( "HasAbilityToSpend", Entities.GetAbilityPoints( Players.GetLocalPlayerPortraitUnit() ) > 0 );

	if( !g_bSentGuideDisable )
	{
		$.DispatchEvent( 'DOTAShopSetGuideVisibility', false);
		g_bSentGuideDisable = true;
	}

	if ( Entities.GetUnitName( Players.GetLocalPlayerPortraitUnit() ) === "npc_dota_creature_invoker" && Game.IsShopOpen() === false )
	{
		Game.SetCustomShopEntityString( "invoker_shop" );
		$.DispatchEvent( "DOTAHUDShopOpened", DOTA_SHOP_TYPE.DOTA_SHOP_CUSTOM, true );
	}

	$.Schedule( flThink, HUDThink );
})();

(function CameraThink() {
    if (g_bInBossIntro === false)
    {
    	if ( Game.GetState() < DOTA_GameState.DOTA_GAMERULES_STATE_POST_GAME && Entities.IsAlive( Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() ) ))
    	{
        	UpdateCameraOffset();
        }
    }
    $.Schedule(0, CameraThink);
})();

function OnBossFound(params)
{
    ShowBossNotify(params.boss, params.unit_name)
}

function ShowBossNotify(label, name)
{
    $("#BossNotify").SetHasClass("Hidden", false)
    
    $("#BossText").text = $.Localize(name)
    $("#BossImage").style.backgroundImage = 'url("s2r://panorama/images/bosses/' + label + '_psd.vtex")';

    Game.EmitSound("DOTA_Item.Buckler.Activate")

    $.Schedule( 6, function() {
        $("#BossNotify").SetHasClass("Hidden", true)
        $("#BossNotify").RemoveClass("animation")
    });
}

var g_nCachedCameraEntIndex = -1;

function UpdateCameraOffset()
{
	var localCamFollowIndex = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() );
	//handle spectators
	if ( Players.IsLocalPlayerInPerspectiveCamera() )
	{
		localCamFollowIndex = Players.GetPerspectivePlayerEntityIndex();
	}

	if ( g_nBossCameraEntIndex !== -1 )
	{
		localCamFollowIndex = g_nBossCameraEntIndex;
	}
	if ( localCamFollowIndex !== -1 )
	{
		if ( Entities.IsAlive( localCamFollowIndex ) === false )
			return;

		var vDesiredLookAtPosition = Entities.GetAbsOrigin( localCamFollowIndex );
		var vLookAtPos = GameUI.GetCameraLookAtPosition();
		var flCurOffset = GameUI.GetCameraLookAtPositionHeightOffset();
		var flCameraRawHeight = vLookAtPos[2] - flCurOffset;
		var flEntityHeight = vDesiredLookAtPosition[2];
		vDesiredLookAtPosition[1] = vDesiredLookAtPosition[1] - 180.0;
		
		var bMouseWheelDown = GameUI.IsMouseDown( 2 );
		if ( bMouseWheelDown )
		{
			var vScreenWorldPos = GameUI.GetScreenWorldPosition( GameUI.GetCursorPosition() );
			if ( vScreenWorldPos !== null )
			{
				var vToCursor = [];
				vToCursor[0] = vScreenWorldPos[0] - vDesiredLookAtPosition[0];
				vToCursor[1] = vScreenWorldPos[1] - vDesiredLookAtPosition[1];
				vToCursor[2] = vScreenWorldPos[2] - vDesiredLookAtPosition[2];
				vToCursor = Game.Normalized( vToCursor );
				var flDistance = Math.min( Game.Length2D( vScreenWorldPos, vDesiredLookAtPosition ), g_flMaxLookDistance );
				vDesiredLookAtPosition[0] = vDesiredLookAtPosition[0] + vToCursor[0] * flDistance;
				vDesiredLookAtPosition[1] = vDesiredLookAtPosition[1] + vToCursor[1] * flDistance;
				vDesiredLookAtPosition[2] = vDesiredLookAtPosition[2] + vToCursor[2] * flDistance;
			}
		}

		var flHeightDiff = flCameraRawHeight - flEntityHeight;
		var flNewOffset = g_flCameraDesiredOffset - flHeightDiff + 50;
		var key = 0;
		
		var flAdditionalOffset = 0.0;
		var t = Game.GetGameFrameTime() / 1.5;
		if ( t > 1.0 ) { t = 1.0; }

		g_flAdditionalCameraOffset = g_flAdditionalCameraOffset * t + flAdditionalOffset * ( 1.0 - t ); 
		flNewOffset = flNewOffset + g_flAdditionalCameraOffset;

		var flLerp = 0.05;
		if ( bMouseWheelDown )
		{
			flLerp = 0.1;
		}
		if ( g_nCachedCameraEntIndex !== localCamFollowIndex )
		{
			flLerp = 1.5;
		}

		GameUI.SetCameraTargetPosition(vDesiredLookAtPosition, flLerp);
		GameUI.SetCameraLookAtPositionHeightOffset( flNewOffset );

		g_nCachedCameraEntIndex = localCamFollowIndex;
	}
	else
	{
		GameUI.SetCameraLookAtPositionHeightOffset( 0.0 );
	}
}


var HERO = -1;
var playerData = {}

function OnDiscovered(data)
{
    $("#DiscoverText").SetHasClass("Hidden", false)
    $("#DiscoverText").AddClass("animation")
    
    $("#DiscoverText").text = $.Localize("Discovered") + data.area

    Game.EmitSound("Event.AreaDiscovered")

    $.Schedule( 5, function() {
        $("#DiscoverText").SetHasClass("Hidden", true)
        $("#DiscoverText").RemoveClass("animation")
    });
}

function OnEscape(data)
{
    var time = data.time;

    $("#EscapeText").SetHasClass("Hidden", false)
    $("#EscapeText").AddClass("animationEscape")
    
    $("#EscapeText").text = $.Localize("Escape") + time + " sec"

    $.Schedule( 0.85, function() {
        $("#EscapeText").SetHasClass("Hidden", true)
        $("#EscapeText").RemoveClass("animation")
    });
}

function OnEscapeDone()
{
    $("#EscapeText").SetHasClass("Hidden", false)
    
    $("#EscapeText").text = $.Localize("EscapeDone")

    $.Schedule( 5, function() {
        $("#EscapeText").SetHasClass("Hidden", true)
    });
}

function OnGameStateChanged(table_name, key, data) {
    if(key == TABLE_KEY_PLAYERDATA)
    {
        if(data[Game.GetLocalPlayerID()] != undefined)
        {
            var params = data[Game.GetLocalPlayerID()]

            $("#GoldText").text = params.Gold
			$("#ExpText").text = params.Exp
			
			var userdata = params.Data

			$("#PlayerEscapes").text = "Successful raids: " + userdata.escapes 
			$("#PlayerLevel").text = "Level: " + div(userdata.exp, 1000)
			$("#PlayerDeaths").text = "Deaths: " + userdata.deaths 
			$("#PlayerGold").text = "Saved Gold: " + userdata.gold 

			var need = userdata.exp % 1000
			var value = need / 1000

			$("#ExpProgress").value = value
			$("#ExpLabel").text = need + " / " + 1000
        }
    }
}

function OnBossKilled(data)
{
	var bossName = data.name;
	
	$("#BossNotifyKilled").SetHasClass("Hidden", false)
    
    $("#BossTextKilled").text = $.Localize(bossName) + " is killed on " + data.location 

    Game.EmitSound("DOTA_Item.Buckler.Activate")

    $.Schedule( 5, function() {
        $("#BossNotifyKilled").SetHasClass("Hidden", true)
    });
}

function OnOpenBook()
{
	$("#Book").SetHasClass("Hidden", !$("#Book").BHasClass("Hidden"))
	HERO = current_hero();

	BuildItems();
}

function OnBuyHero(id)
{
	if(!CanBuy())
	{
		GameEvents.SendEventClientSide("dota_hud_error_message", {
            "splitscreenplayer": 0,
            "reason": 80,
            "message": "There is no shop near!"
		})
		
		return;
	}

	if (HERO != -1) return;
	
    GameEvents.SendCustomGameEventToServer("on_buy_hero", {hero_id: id});
}

function PageChanged()
{
    PAGE++;

    for(var page in PAGES)
    {
        PAGES[page].SetHasClass("Hidden", true)   
    }

    if(PAGE > MAX_PAGES - 1) PAGE = 0;

    PAGES[PAGE].SetHasClass("Hidden", false)   
}

function BuildItems()
{
	for (var index = 0; index < $("#ItemsPanel").GetChildCount(); index++) {
		var panel = $("#ItemsPanel").GetChild(index)
		panel.DeleteAsync(0)
	}

	for(var item in ITEMS)
	{
		if (ITEMS[item].name.indexOf("recipe") !== -1){
			delete ITEMS[item];
		};
	}

	var result = ITEMS.sort(function(a, b){return a.level - b.level});

	var pLevel = get_level()

    for(var item in ITEMS)
    {
		var name = ITEMS[item].name
		var level = ITEMS[item].level || 0

        if (name.indexOf("recipe") !== -1) continue;

        var item_panel = $.CreatePanel("DOTAItemImage", $("#ItemsPanel"), name);
		item_panel.AddClass("GameItem")
		item_panel.itemname = name
		
		if(pLevel > level)
		{
			var func = (function(name, level) {
				return function() { OnBuyItem(name, level) }
			}
			(name, level));

			item_panel.SetPanelEvent("onmouseactivate", func);

			var label = $.CreatePanel("Label", item_panel, undefined)
			label.text = ITEMS[item].cost;
			label.AddClass("Active")
		}
		else
		{
			item_panel.SetHasClass("Inactive", true)
			item_panel.enabled = false
			item_panel.hittest = false

			var label = $.CreatePanel("Label", item_panel, undefined)
			label.AddClass("LevelReq")
			label.text = "On level: " + level

			label.hittest = false
		}
	}

	for (var index = 0; index < $("#Heroes").GetChildCount(); index++) {
		var panel = $("#Heroes").GetChild(index)
		
		if(COSTS[panel.id] > pLevel)
		{
			panel.enabled = false
			panel.hittest = false
			panel.hittestchildren = false
			
			var label = $.CreatePanel("Label", panel, undefined)
			label.AddClass("LevelReqHero")
			label.text = "On level: " + COSTS[panel.id]

			panel.SetHasClass("Inactive", true)
		}
	}
}

function OnBuyItem(item, level)
{
	if(!CanBuy())
	{
		GameEvents.SendEventClientSide("dota_hud_error_message", {
            "splitscreenplayer": 0,
            "reason": 80,
            "message": "There is no shop near!"
		})
		
		return;
	}

    GameEvents.SendCustomGameEventToServer("on_buy_item", {item: item});
}

function CanBuy()
{
	var player = Players.GetPlayerHeroEntityIndex( Players.GetLocalPlayer() )

	return UnitHasModifier(player, "modifier_shop")
}

function UnitHasModifier(entity, modifier_name) {
	var num = Entities.GetNumBuffs( entity )
	
    for (var i = 0; i <= 100; i++) {
		var buff = Entities.GetBuff( entity, i )
        if (Buffs.GetName( entity, i ) == modifier_name)
        {
            return true
        }
    }
    return false
}

function div(val, by){
    return (val - val % by) / by;
}

function get_level()
{
	var table = CustomNetTables.GetTableValue("gamemode", "players")
	if (table[Game.GetLocalPlayerID()])
		return div(table[Game.GetLocalPlayerID()].Data.exp, 1000)

	return 0;
}

function current_hero()
{
	var table = CustomNetTables.GetTableValue("gamemode", "players")
	if (table[Game.GetLocalPlayerID()])
		return table[Game.GetLocalPlayerID()].Hero 

	return -1;
}