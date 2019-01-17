UNIT_BOSS_HULK = undefined;
UNIT_BASS_ROUND = 1

function Check() {
    var data = CustomNetTables.GetTableValue( "event", "unit" );

    if (data != null && data.creature != null) 
    {
        UNIT_BOSS_HULK = Number(data.creature); UNIT_BASS_ROUND = Number(data.round) || 1; UpdateData();
    }

    $.Schedule( 0.2, function() {
        Check()
    } )
}

function UpdateData()
{
    var hp = Entities.GetHealth( UNIT_BOSS_HULK ) + " / " + Entities.GetMaxHealth( UNIT_BOSS_HULK )
    var hp_ptc = Entities.GetHealthPercent( UNIT_BOSS_HULK )

    var damage = Entities.GetDamageMax( UNIT_BOSS_HULK ) + Entities.GetDamageBonus( UNIT_BOSS_HULK )
    var armor = Entities.GetPhysicalArmorValue( UNIT_BOSS_HULK )
    var round = "Round #" + UNIT_BASS_ROUND; $("#Waves").text = round;

    $("#XPLabel").text = hp; $("#XPProgress").value = hp_ptc;  $("#Damage").text = "Hulk's damage: " + damage; $("#Armor").text = "Hulk's armor: " + armor;
}

(function()
{    
    $.Schedule( 0.2, function() {
        Check()
    } )
})();