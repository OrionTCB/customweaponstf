//==== [ hi ok ] ========================================================
//==== [ CONSTANTS ] ====================================================
/* Base.
 * ---------------------------------------------------------------------- */
#define MAXSLOTS                      4
#define PI                            3.1415926535897932384626433832795

/* Sounds, models and particles.
 * ---------------------------------------------------------------------- */
#define SOUND_EXPLOSION               "weapons/rocket_blackbox_explode3.wav"
#define SOUND_TBASH                   "weapons/samurai/tf_marked_for_death_impact_03.wav"
#define SOUND_UBER                    "player/invulnerable_on.wav"
#define SOUND_READY                   "player/recharged.wav"
#define SOUND_NOTREADY                "replay/record_fail.wav"
#define SOUND_DRINK                   "player/pl_scout_dodge_can_drink.wav"
#define SOUND_IMPACT_A                "physics/surfaces/underwater_impact_bullet1.wav"
#define SOUND_IMPACT_B                "physics/surfaces/underwater_impact_bullet2.wav"
#define SOUND_IMPACT_C                "physics/surfaces/underwater_impact_bullet3.wav"
#define SOUND_CHARGE_STICKYBOMB       "weapons/stickybomblauncher_charge_up.wav"
#define SOUND_SAPPER_BREAK            "weapons/sapper_removed.wav"
#define SOUND_STICKYEXPLOSION         "weapons/pipe_bomb3.wav"
#define SOUND_STICKYDETONATE          "weapons/stickybomblauncher_det.wav"
#define SOUND_GRENADE                 "weapons/grenade_launcher_shoot.wav"
#define SOUND_BBASH                   "weapons/halloween_boss/knight_axe_miss.wav"
#define SOUND_RADIANCE                "weapons/3rd_degree_hit_04.wav"
#define SOUND_REFLECT                 "weapons/samurai/tf_katana_06.wav"
#define SOUND_WEAPON_SHOTGUN          "weapons/shotgun_shoot.wav"
#define SOUND_VO_HEAVY_I_LIVE         "vo/heavy_battlecry06.mp3"
#define SOUND_SHIELD_BREAK            "player/spy_shield_break.wav"
#define SOUND_LVLUP1                  "weapons/vaccinator_charge_tier_01.wav"
#define SOUND_LVLUP2                  "weapons/vaccinator_charge_tier_02.wav"
#define SOUND_LVLUP3                  "weapons/vaccinator_charge_tier_03.wav"
#define SOUND_LVLUP4                  "weapons/vaccinator_charge_tier_04.wav"
#define MDL_BOMBLET                   "models/workshop/weapons/c_models/c_quadball/w_quadball_grenade.mdl"
#define PARTICLE_ZEUS                 "wrenchmotron_teleport_beam"
#define PARTICLE_DESOLATOR            "critical_rocket_redsparks"

/* Sounds tables.
 * ---------------------------------------------------------------------- */
stock String:s_strMiniCritDeal[][PLATFORM_MAX_PATH] = {
    "player/crit_hit_mini.wav", 
    "player/crit_hit_mini2.wav", 
    "player/crit_hit_mini3.wav", 
    "player/crit_hit_mini4.wav", 
    "player/crit_hit_mini5.wav"
}; 
stock String:s_strCritTake[][PLATFORM_MAX_PATH] = {
    "player/crit_recieved1.wav", 
    "player/crit_recieved2.wav", 
    "player/crit_recieved3.wav"
}; 
stock String:g_strSoundExplosionBox[][PLATFORM_MAX_PATH] = {
    "weapons/rocket_blackbox_explode1.wav", 
    "weapons/rocket_blackbox_explode2.wav", 
    "weapons/rocket_blackbox_explode3.wav"
}; 

/* Damage Type.
 * ---------------------------------------------------------------------- */
#define HL_DMG_GENERIC                      0                                                       // 0
#define TF_DMG_CRUSH                        (1 << 0)                                                // 1
#define TF_DMG_BULLET                       (1 << 1)                                                // 2            ► Bullet in general && Sniper Rifle ( Exception: The Classic ) && Scout's Homerun && Heavy's Showdown.
#define TF_DMG_BLEED                        (1 << 2)                                                // 4            ► Bleed in general && Cleaver && Spy's Fencing final damage.
#define TF_DMG_BURN                         (1 << 3)                                                // 8
#define SDK_DMG_UNKNOWN                     (1 << 4)                                                // 16
#define TF_DMG_FALL                         (1 << 5)                                                // 32           ► Fall in general && Mantreads's stomp.
#define TF_DMG_BLAST                        (1 << 6)                                                // 64           ► Also Engineer's Organ Grinder final damage.
#define TF_DMG_MISC                         (1 << 7)                                                // 128          ► Sandman's ball && Wrap Assassin's ball && Shield && Demoman's Decapitation Taunt Kill && Engineer's Dischord && Headless Horseless Horsemann.
#define SDK_DMG_SHOCK                       (1 << 8)                                                // 256
#define TF_DMG_LASER                        (1 << 9)                                                // 512          ► Righteous Bison && Pomson 6000.
#define DOTA_DMG_DISPERSION                 (1 << 10)                                               // 1024
#define TF_DMG_PREVENT_PHYSICS_FORCE        (1 << 11)                                               // 2048
#define TF_DMG_SOMETAUNTKILLS               TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_BULLET            // 2050         ► Engineer's Organ Grinder spinning phase && Medic's Spinal Tap initial AND final damage && Sniper's Skewer.
#define TF_DMG_SPY_FENCING                  TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_BLEED             // 2052         ► Only the first 2 damages instances.
#define TF_DMG_AFTERBURN                    TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_BURN              // 2056
#define TF_DMG_BLAST_WRAPASSASSIN           TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_BLAST             // 2112
#define TF_DMG_NEVERGIB                     (1 << 12)                                               // 4096
#define TF_DMG_ALWAYSGIB                    (1 << 13)                                               // 8192
#define TF_DMG_DROWN                        (1 << 14)                                               // 16384
#define DOTA_DMG_OTHER                      (1 << 15)                                               // 32768
#define TF_DMG_ENV                          (1 << 16)                                               // 65536
#define SDK_DMG_UNKNOWN3                    (1 << 17)                                               // 131072
#define SDK_DMG_UNKNOWN4                    (1 << 18)                                               // 262144
#define TF_DMG_GRENADE                      SDK_DMG_UNKNOWN4 | TF_DMG_BLAST                         // 262208
#define TF_DMG_DROWNRECOVER                 (1 << 19)                                               // 524288
#define TF_DMG_CRIT                         (1 << 20)                                               // 1048576      ► Also Mini-Crit.
#define TF_DMG_GRENADE_CRIT                 TF_DMG_GRENADE | TF_DMG_CRIT                            // 1310784      ► Also Double Donk.
#define SDK_DMG_UNKNOWN5                    (1 << 21)                                               // 2097152
#define TF_DMG_BULLET2                      SDK_DMG_UNKNOWN5 | TF_DMG_BULLET                        // 2097154      ► Pistol && Minigun && Short Circuit && SMG.
#define TF_DMG_SOLDIER_KAMIKAZE             SDK_DMG_UNKNOWN5 | TF_DMG_BLAST                         // 2097216      ► Also the Caber's explosion.
#define TF_DMG_SYRINGE                      SDK_DMG_UNKNOWN5 | SDK_DMG_UNKNOWN3 | TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_BULLET    // 2230274
#define TF_DMG_SENTRY                       SDK_DMG_UNKNOWN5 | SDK_DMG_UNKNOWN3 | TF_DMG_NEVERGIB | TF_DMG_BULLET                 // 2232322
#define TF_DMG_ROCKET                       SDK_DMG_UNKNOWN5 | TF_DMG_GRENADE                       // 2359360      ► Also Sentry's Rocket.
#define TF_DMG_STICKY                       SDK_DMG_UNKNOWN5 | SDK_DMG_UNKNOWN3 | TF_DMG_GRENADE    // 2490432
#define TF_DMG_BULLET2_CRIT                 TF_DMG_BULLET2 | TF_DMG_CRIT                            // 3145730      ► Pistol && Minigun && Short Circuit && SMG.
#define TF_DMG_ROCKET_CRIT                  TF_DMG_ROCKET | TF_DMG_CRIT                             // 3407936
#define TF_DMG_STICKY_CRIT                  TF_DMG_STICKY | TF_DMG_CRIT                             // 3539008
#define TF_DMG_REMOVENORAGDOLL              (1 << 22)                                               // 4194304
#define SDK_DMG_UNKNOWN6                    (1 << 23)                                               // 8388608
#define TF_DMG_FIRE                         (1 << 24)                                               // 16777216     ► Fire in general && Pyro's Armageddon && Huo-Long Heater's Ring of Fire.
#define TF_DMG_FLARE                        TF_DMG_FIRE | TF_DMG_BULLET                             // 16777218
#define TF_DMG_PYRO_HADOUKEN                TF_DMG_FIRE | TF_DMG_BURN                               // 16777224
#define TF_DMG_FLAMETHROWER                 TF_DMG_PREVENT_PHYSICS_FORCE | TF_DMG_FIRE              // 16779264
#define TF_DMG_SCORCHSHOT                   TF_DMG_FLAMETHROWER | TF_DMG_BULLET                     // 16779266     ► Scorch Shot && Pyro's Execution.
#define TF_DMG_FLARE_CRIT                   TF_DMG_FLARE | TF_DMG_CRIT                              // 17825794
#define TF_DMG_FLAMETHROWER_CRIT            TF_DMG_FLAMETHROWER | TF_DMG_CRIT                       // 17827840
#define TF_DMG_BLAST_FLARE                  TF_DMG_FLARE | SDK_DMG_UNKNOWN4                         // 17039362     ► Scorch Shot && Detonator explosion.
#define TF_DMG_BLAST_FLARE_CRIT             TF_DMG_FLARE_CRIT | SDK_DMG_UNKNOWN4                    // 18087938     ► Scorch Shot && Detonator explosion.
#define TF_DMG_COWMANGLER_CHARGED           TF_DMG_FIRE | TF_DMG_ROCKET | TF_DMG_CRIT               // 20185152
#define SDK_DMG_UNKNOWN7                    (1 << 25)                                               // 33554432
#define TF_DMG_RIFLE_CHARGED                SDK_DMG_UNKNOWN7 | TF_DMG_BULLET                        // 33554434     ► Also Crusader's Crossbow && Huntsman && The Classic.
#define TF_DMG_RIFLE_CRIT                   TF_DMG_RIFLE_CHARGED | TF_DMG_CRIT                      // 34603010     ► Also Crusader's Crossbow && Huntsman && The Classic.
#define TF_DMG_AMBASSADOR                   SDK_DMG_UNKNOWN7 | TF_DMG_BULLET2                       // 35651586
#define TF_DMG_AMBASSADOR_CRIT              TF_DMG_AMBASSADOR | TF_DMG_CRIT                         // 35651586     ► Only when able to Headshot.
#define SDK_DMG_UNKNOWN8                    (1 << 26)                                               // 67108864
#define TF_DMG_BLAST_SURFACE                (1 << 27)                                               // 134217728
#define TF_DMG_MELEE                        TF_DMG_BLAST_SURFACE | TF_DMG_NEVERGIB | TF_DMG_MISC    // 134221952
#define TF_DMG_MELEE_CRIT                   TF_DMG_MELEE | TF_DMG_CRIT                              // 135270528
#define DOTA_DMG_BLADEMAIL                  (1 << 28)                                               // 268435456
#define SDK_DMG_UNKNOWN9                    (1 << 29)                                               // 536870912
#define TF_DMG_SCATTERGUN                   SDK_DMG_UNKNOWN9 | SDK_DMG_UNKNOWN5                     // 538968064    ► Scattergun && Shotgun && Rescue Ranger.
#define TF_DMG_SHORTSTOP                    TF_DMG_SCATTERGUN | TF_DMG_BULLET                       // 538968066
#define TF_DMG_SCATTERGUN_CRIT              TF_DMG_SCATTERGUN | TF_DMG_CRIT                         // 540016640    ► Scattergun && Shotgun && Rescue Ranger.
#define TF_DMG_SHORTSTOP_CRIT               TF_DMG_SHORTSTOP | TF_DMG_CRIT                          // 540016642
//#define SDK_DMG_UNKNOWN10                 (1 << 30)                                               // 1073741824

//==== [ VARIABLES ] ====================================================
stock Handle:m_hGetPlayerMaxHealth = INVALID_HANDLE; 
stock bool:s_bGlowEnabled[MAXPLAYERS + 1]; 

//==== [ ON MAP START ] =================================================
public OnMapStart( )
{
    PrecacheSound( SOUND_EXPLOSION, true ); 
    PrecacheSound( SOUND_TBASH, true ); 
    PrecacheSound( SOUND_UBER, true ); 
    PrecacheSound( SOUND_READY, true ); 
    PrecacheSound( SOUND_NOTREADY, true ); 
    PrecacheSound( SOUND_DRINK, true ); 
    PrecacheSound( SOUND_IMPACT_A, true ); 
    PrecacheSound( SOUND_IMPACT_B, true ); 
    PrecacheSound( SOUND_IMPACT_C, true ); 
    PrecacheSound( SOUND_CHARGE_STICKYBOMB, true ); 
    PrecacheSound( SOUND_STICKYDETONATE, true ); 
    PrecacheSound( SOUND_STICKYEXPLOSION, true ); 
    PrecacheSound( SOUND_GRENADE, true ); 
    PrecacheSound( SOUND_BBASH, true ); 
    PrecacheSound( SOUND_RADIANCE, true ); 
    PrecacheSound( SOUND_REFLECT, true ); 
    PrecacheSound( SOUND_VO_HEAVY_I_LIVE, true ); 
    PrecacheSound( SOUND_SHIELD_BREAK, true ); 
    PrecacheSound( SOUND_LVLUP1, true ); 
    PrecacheSound( SOUND_LVLUP2, true ); 
    PrecacheSound( SOUND_LVLUP3, true ); 
    PrecacheSound( SOUND_LVLUP4, true ); 
    PrecacheModel( MDL_BOMBLET ); 
    PrecacheParticle( PARTICLE_ZEUS ); 
    PrecacheParticle( PARTICLE_DESOLATOR ); 
    new loop; 
    for ( loop = 0 ; loop < sizeof( g_strSoundExplosionBox ) ; loop++ ) PrecacheSound( g_strSoundExplosionBox[loop], true ); 
    for ( loop = 0 ; loop < sizeof( s_strCritTake ) ; loop++ ) PrecacheSound( s_strCritTake[loop], true ); 
    for ( loop = 0 ; loop < sizeof( s_strMiniCritDeal ) ; loop++ ) PrecacheSound( s_strMiniCritDeal[loop], true ); 
}

//==== [ STOCKS ] =======================================================
//==== [ IS VALID CLIENT ] ==============================================
stock bool:IsValidClient( client, bool:replaycheck = true )
{
    if ( client <= 0 || client > MaxClients ) return false; 
    if ( !IsClientInGame( client ) ) return false; 
    if ( !IsClientConnected( client ) ) return false; 
    if ( GetEntProp( client, Prop_Send, "m_bIsCoaching" ) ) return false; 
    if ( replaycheck )
    {
        if ( IsClientSourceTV( client ) || IsClientReplay( client ) ) return false; 
    }
    return true; 
}

//==== [ CLEAR TIMER ] ==================================================
stock bool:ClearTimer( &Handle:timer, bool:autoClose = false )
{
    if ( timer != INVALID_HANDLE )
    {
        KillTimer( timer, autoClose ); 
        timer = INVALID_HANDLE; 
        return true; 
    }
    return false; 
}

//==== [ DEAL DAMAGE ] ==================================================
stock DealDamage( victim, damage, attacker = 0, dmg_type = HL_DMG_GENERIC, String:logname[] = "" )
{
    if ( victim > 0 && IsValidEdict( victim ) && IsClientInGame( victim ) && IsPlayerAlive( victim ) && damage > 0 )
    {
        new String:dmg_str[16]; 
        IntToString( damage, dmg_str, 16 ); 
        new String:dmg_type_str[32]; 
        IntToString( dmg_type, dmg_type_str, 32 ); 
        new pointHurt = CreateEntityByName( "point_hurt" ); 
        if( pointHurt )
        {
            DispatchKeyValue( victim, "targetname", "war3_hurtme" ); 
            DispatchKeyValue( pointHurt, "DamageTarget", "war3_hurtme" ); 
            DispatchKeyValue( pointHurt, "Damage", dmg_str ); 
            DispatchKeyValue( pointHurt, "DamageType", dmg_type_str ); 
            if( !StrEqual( logname, "" ) )
            {
                DispatchKeyValue( pointHurt, "classname", logname ); 
            }
            DispatchSpawn( pointHurt ); 
            AcceptEntityInput( pointHurt, "Hurt", (attacker>0)?attacker:-1 ); 
            DispatchKeyValue( pointHurt, "classname", "point_hurt" ); 
            DispatchKeyValue( victim, "targetname", "war3_donthurtme" ); 
            RemoveEdict( pointHurt ); 
        }
    }
}

//==== [ HEALTH ] =======================================================
stock TF2_GetClientMaxHealth( client ) return SDKCall( m_hGetPlayerMaxHealth, client ); 
/*
stock TF2_SetHealth( client, NewHealth )
{
    SetEntProp( client, Prop_Send, "m_iHealth", NewHealth, 1 ); 
    SetEntProp( client, Prop_Data, "m_iHealth", NewHealth, 1 ); 
}
*/

//==== [ ÜBERCHARGE ] ===================================================
stock Float:TF2_GetClientUberLevel( client )
{
    new entity = TF2_Medigun( client ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) ) return GetEntPropFloat( entity, Prop_Send, "m_flChargeLevel" )*100.0; 
    return 0.0; 
}
stock TF2_SetClientUberLevel( client, Float:level )
{
    new entity = TF2_Medigun( client ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) ) {
        if ( level < 0.0 ) level = 0.0; 
        if ( level > 100.0 ) level = 100.0; 
        SetEntPropFloat( entity, Prop_Send, "m_flChargeLevel", level / 100.0 ); 
    }
}
stock TF2_ReleaseUbercharge( client )
{
    new entity = TF2_Medigun( client ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) ) SetEntProp( entity, Prop_Send, "m_bChargeRelease", 1 ); 
}
stock bool:TF2_IsUberchargeDeployed( client )
{
    new entity = TF2_Medigun( client ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) ) {
        if ( GetEntProp( entity, Prop_Send, "m_bChargeRelease" ) > 0 ) return true; 
    }
    return false; 
}
stock TF2_StopUbercharge( client )
{
    new entity = TF2_Medigun( client ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) ) SetEntProp( entity, Prop_Send, "m_bChargeRelease", 0 ); 
}
stock TF2_Medigun( client )
{
    new entity = GetPlayerWeaponSlot( client, 1 ); 
    if ( IsValidEntity( entity ) && IsValidEdict( entity ) )
    {
        new String:strClassname[64]; 
        GetEntityNetClass( entity, strClassname, sizeof( strClassname ) ); 
        if ( StrEqual( strClassname, "CWeaponMedigun" ) ) return entity; 
    }
    return -1; 
}

//==== [ METAL ] ========================================================
stock TF2_GetClientMetal( client ) return GetEntProp( client, Prop_Data, "m_iAmmo", 4, 3 ); 
stock TF2_SetClientMetal( client, NewMetal )
{
    new Float:mult = 1.0; 
    new Address:attribute; 
    if ( NewMetal < 0 ) NewMetal = 0; 
    for ( new i = 0 ; i <= 4 ; i++ )
    {
        if ( TF2Attrib_GetByName( GetPlayerWeaponSlot( client, i ), "maxammo metal increased" ) ) {
            attribute = TF2Attrib_GetByName( GetPlayerWeaponSlot( client, i ), "maxammo metal increased" ); 
            mult *= TF2Attrib_GetValue( attribute ); 
        }
        if ( TF2Attrib_GetByName( GetPlayerWeaponSlot( client, i ), "maxammo metal reduced" ) ) {
            attribute = TF2Attrib_GetByName( GetPlayerWeaponSlot( client, i ), "maxammo metal reduced" ); 
            mult *= TF2Attrib_GetValue( attribute ); 
        }
    }
    if ( NewMetal > 200 * mult ) NewMetal = RoundToFloor( 200 * mult ); 
    SetEntProp( client, Prop_Data, "m_iAmmo", NewMetal, 4, 3 ); 
}

//==== [ AMMUNITIONS ] ==================================================
stock SetCarriedAmmo( client, slot, newAmmo )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( IsValidEntity( weapon ) )
        {
            new type = GetEntProp( weapon, Prop_Send, "m_iPrimaryAmmoType" ); 
            if ( type > 0 || type < 31 ) SetEntProp( client, Prop_Send, "m_iAmmo", newAmmo, _, type ); 
        }
    }
}
stock GetCarriedAmmo( client, slot )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( IsValidEntity( weapon ) )
        {
            new type = GetEntProp( weapon, Prop_Send, "m_iPrimaryAmmoType" ); 
            if ( type > 0 || type < 31 )
                return GetEntProp( client, Prop_Send, "m_iAmmo", _, type ); 
        }
    }
    return 0; 
}
stock SetClipAmmo( client, slot, ammo )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( IsValidEntity( weapon ) )
            SetEntProp( weapon, Prop_Send, "m_iClip1", ammo ); 
    }
}
stock GetClipAmmo( client, slot )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( IsValidEntity( weapon ) )
            return GetEntProp( weapon, Prop_Data, "m_iClip1" ); 
    }
    return 0; 
}
stock SetLoadedAmmo( client, slot, ammo = -1, ammo2 = -1 )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if( IsValidEntity( weapon ) )
        {
            if ( ammo >= 0 ) SetEntData( client, FindSendPropInfo( "CTFPlayer", "m_iAmmo" )+4, ammo ); 
            if ( ammo >= 0 ) SetEntData( client, FindSendPropInfo( "CTFPlayer", "m_iAmmo" )+8, ammo ); 
            if ( ammo2 >= 0 ) SetEntData( weapon, FindSendPropInfo( "CBaseCombatWeapon", "m_iClip1" ), ammo2, 4 ); 
        }
    }
}
stock GetLoadedAmmo( client, slot )
{
    if ( IsValidClient( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( IsValidEntity( weapon ) )
        {
            new iOffset = GetEntProp( weapon, Prop_Send, "m_iPrimaryAmmoType", 1 )*4; 
            new iAmmoTable = FindSendPropInfo( "CTFPlayer", "m_iAmmo" ); 
            return GetEntData( client, iAmmoTable+iOffset ); 
        }
    }
    return 0; 
}

//==== [ SLOT ] =========================================================
stock TF2_SetClientSlot( client, slot )
{
    if ( IsValidClient( client ) && IsPlayerAlive( client ) )
    {
        new weapon = GetPlayerWeaponSlot( client, slot ); 
        if ( weapon != -1 && IsValidEntity( weapon ) && IsValidEdict( weapon ) )
        {
            SetEntPropEnt( client, Prop_Send, "m_hActiveWeapon", weapon ); 
            
            TF2_RemoveCondition( client, TFCond_Slowed ); 
            TF2_RemoveCondition( client, TFCond_Zoomed ); 
        }
    }
}
stock TF2_GetClientActiveSlot( client ) {
    if ( IsValidClient( client ) && IsPlayerAlive( client ) ) return GetWeaponSlot( client, TF2_GetClientActiveWeapon( client ) ); 
    return -1; 
}
stock GetWeaponSlot( client, weapon )
{
    if ( IsValidClient( client ) && IsValidEntity( weapon ) && IsValidEdict( weapon ) )
    {
        for ( new i = 0; i <= 4; i++ ) {
            new j = GetPlayerWeaponSlot( client, i ); 
            if ( j != -1 && IsValidEntity( j ) && IsValidEdict( j ) && weapon == j ) return i; 
        }
    }
    return -1; 
}
stock TF2_GetClientActiveWeapon( client )
{
    if ( IsValidClient( client ) ) {
        new weapon = GetEntPropEnt( client, Prop_Data, "m_hActiveWeapon" ); 
        if ( weapon != -1 && IsValidEntity( weapon ) && IsValidEdict( weapon ) ) return weapon; 
    }
    return INVALID_ENT_REFERENCE; 
}
stock TF2_GetWeaponSlot( client, weapon = -1 )
{
    new slot = -1; 
    if ( IsValidClient( client ) )
    {
        slot = TF2_GetClientActiveSlot( client ); 
        if ( weapon != -1 && IsValidEdict( weapon ) && IsValidEdict( weapon ) )
            slot = GetWeaponSlot( client, weapon ); 
    }

    return slot; 
}

//==== [ HEAL ] =========================================================
stock Float:TF2_HealPlayer( target, Float:healed, Float:newOverheal = 1.0, bool:ShowHealth = true )
{
    new Float:healing; 
    healing += healed;
    if ( healing >= 1.0 )
    {
        new heal = RoundToFloor( healing ); 
        if ( heal >= 1 )
        {
            healing -= float( heal ); 
            new health = GetClientHealth( target ); 
            new newhealth = health + heal; 
            new overheal = RoundFloat( TF2_GetClientMaxHealth( target ) * ( 1.5 * newOverheal ) ); 
            if ( health <= overheal )
            {
                if ( newhealth > overheal ) newhealth = overheal; 
                SetEntityHealth( target, newhealth ); 
                if ( ShowHealth ) TF2_ShowHealthGain( target, newhealth - health ); 
            }
        }
    }
}
stock TF2_ShowHealthGain( client, healed ) // Chdata.
{
    new target = GetClientUserId( client ); 
    new Handle:event = CreateEvent( "player_healed", true ); 
    SetEventBool( event, "sourcemod", true ); 
    SetEventInt( event, "patient", target ); 
    SetEventInt( event, "healer", target ); 
    SetEventInt( event, "amount", healed ); 
    FireEvent( event ); 
    
    // I would love to see this on the actual health bar like health regeneration does.
}
stock TF2_GetHealingTarget( client )
{
    if( IsValidClient( client ) && TF2_GetPlayerClass( client ) == TFClass_Medic )
    {
        new entity = TF2_Medigun( client ); 
        if ( entity ) {
            if( GetEntProp( entity, Prop_Send, "m_bHealing" ) == 1 ) return GetEntPropEnt( entity, Prop_Send, "m_hHealingTarget" ); 
        }
    }
    return -1; 
}

//==== [ CRITICAL ] =====================================================
stock bool:IsCritBoosted( client )
{
    if ( TF2_IsPlayerInCondition( client, TFCond_Kritzkrieged ) || TF2_IsPlayerInCondition( client, TFCond_HalloweenCritCandy )
        || TF2_IsPlayerInCondition( client, TFCond_CritCanteen ) || TF2_IsPlayerInCondition( client, TFCond_CritDemoCharge )
        || TF2_IsPlayerInCondition( client, TFCond_CritOnFirstBlood ) || TF2_IsPlayerInCondition( client, TFCond_CritOnWin )
        || TF2_IsPlayerInCondition( client, TFCond_CritOnFlagCapture ) || TF2_IsPlayerInCondition( client, TFCond_CritOnKill )
        || TF2_IsPlayerInCondition( client, TFCond_CritMmmph ) || TF2_IsPlayerInCondition( client, TFCond_CritOnDamage )
        || TF2_IsPlayerInCondition( client, TFCond_CritRuneTemp ) )
    {
        return true; 
    }
    return false; 
}
stock RemoveCrit( client )
{
    TF2_RemoveCondition( client, TFCond_Kritzkrieged ); 
    TF2_RemoveCondition( client, TFCond_HalloweenCritCandy ); 
    TF2_RemoveCondition( client, TFCond_CritCanteen ); 
    TF2_RemoveCondition( client, TFCond_CritDemoCharge ); 
    TF2_RemoveCondition( client, TFCond_CritOnFirstBlood ); 
    TF2_RemoveCondition( client, TFCond_CritOnWin ); 
    TF2_RemoveCondition( client, TFCond_CritOnFlagCapture ); 
    TF2_RemoveCondition( client, TFCond_CritOnKill ); 
    TF2_RemoveCondition( client, TFCond_CritMmmph ); 
    TF2_RemoveCondition( client, TFCond_CritOnDamage ); 
    TF2_RemoveCondition( client, TFCond_CritRuneTemp ); 
}
stock bool:IsMiniCritBoosted( client )
{
    if ( TF2_IsPlayerInCondition( client, TFCond_Buffed ) || TF2_IsPlayerInCondition( client, TFCond_CritCola )
    || TF2_IsPlayerInCondition( client, TFCond_CritHype ) || TF2_IsPlayerInCondition( client, TFCond_MiniCritOnKill ) )
    {
        return true; 
    }
    return false; 
}
stock RemoveMiniCrit( client )
{
    TF2_RemoveCondition( client, TFCond_Buffed ); 
    TF2_RemoveCondition( client, TFCond_CritCola ); 
    TF2_RemoveCondition( client, TFCond_CritHype ); 
    TF2_RemoveCondition( client, TFCond_MiniCritOnKill ); 
}

//==== [ MOVEMENT SPEED ] ===============================================
stock Float:GetClientMovementSpeed( client ) return GetEntPropFloat( client, Prop_Send, "m_flMaxspeed" ); 
stock SetClientMovementSpeed( client, Float:value ) SetEntPropFloat( client, Prop_Send, "m_flMaxspeed", value ); 
stock Float:GetClassBaseMovementSpeed( client )
{
    if ( IsValidClient( client ) && IsPlayerAlive( client ) )
    {
        if ( TF2_GetPlayerClass( client ) == TFClass_Scout ) return 400.0; 
        if ( TF2_GetPlayerClass( client ) == TFClass_Medic || TF2_GetPlayerClass( client ) == TFClass_Spy ) return 320.0; 
        if ( TF2_GetPlayerClass( client ) == TFClass_DemoMan ) return 280.0; 
        if ( TF2_GetPlayerClass( client ) == TFClass_Soldier ) return 240.0; 
        if ( TF2_GetPlayerClass( client ) == TFClass_Heavy ) return 230.0; 
        
        return 300.0; 
    }

    return 0.0; 
}
stock Float:GetClientMovementSpeedAttributes( client )
{
    if ( IsValidClient( client ) && IsPlayerAlive( client ) )
    {
        new bool:active[MAXSLOTS + 1]; 
        new Float:mult = 1.0; 
        new Address:attribute = Address_Null; 

        for ( new i = 0 ; i <= 4 ; i++ )
        {
            new weapon_slot = GetPlayerWeaponSlot( client, i ); 
            new active_slot = TF2_GetClientActiveSlot( client ); 
            
            if ( IsValidEdict( weapon_slot ) && IsValidEntity( weapon_slot ) )
            {
                if ( ( attribute = TF2Attrib_GetByName( weapon_slot, "provide on active" ) ) != Address_Null ) 
                    active[i] = true; 
                
                attribute = TF2Attrib_GetByName( weapon_slot, "move speed bonus" ); 
                if ( attribute != Address_Null )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 
                
                attribute = TF2Attrib_GetByName( weapon_slot, "move speed penalty" ); 
                if ( attribute != Address_Null )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 

                attribute = TF2Attrib_GetByName( weapon_slot, "aiming movespeed increased" ); 
                if ( attribute != Address_Null && TF2_IsPlayerInCondition( client, TFCond_Slowed ) )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 

                attribute = TF2Attrib_GetByName( weapon_slot, "aiming movespeed decreased" ); 
                if ( attribute != Address_Null && TF2_IsPlayerInCondition( client, TFCond_Slowed ) )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 

                attribute = TF2Attrib_GetByName( weapon_slot, "sniper aiming movespeed decreased" ); 
                if ( attribute != Address_Null && TF2_IsPlayerInCondition( client, TFCond_Slowed ) )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 

                attribute = TF2Attrib_GetByName( weapon_slot, "speed boost when active" ); 
                if ( attribute != Address_Null )
                    mult *= GetMultMoveSpeed( attribute, active[i], active_slot, i ); 
            }
        }
        
        return mult; 
    }

    return 1.0; 
}
stock Float:GetMultMoveSpeed( Address:attribute, bool:active, active_slot, slot )
{
    if ( attribute != Address_Null ) {
        if ( attribute && !active
           || attribute && active && active_slot == slot )
            return TF2Attrib_GetValue( attribute ); 
    }
    return 1.0; 
}

//==== [ VELOCITY ] =====================================================
stock GetVelocity( client, Float:vVector[3] ) GetEntPropVector( client, Prop_Data, "m_vecVelocity", vVector ); 
stock AnglesToVelocity( Float:fAngle[3], Float:fVelocity[3], Float:fSpeed = 1.0 )
{
    fVelocity[0] = Cosine( DegToRad( fAngle[1] ) ); 
    fVelocity[1] = Sine( DegToRad( fAngle[1] ) ); 
    fVelocity[2] = Sine( DegToRad( fAngle[0] ) ) * -1.0; 
    
    NormalizeVector( fVelocity, fVelocity ); 
    
    ScaleVector( fVelocity, fSpeed ); 
}
stock bool:IsEntityStuck( entity )
{
    new Float:fPos[3], Float:fMins[3], Float:fMaxs[3]; 
    GetEntPropVector( entity, Prop_Send, "m_vecOrigin", fPos ); 
    GetEntPropVector( entity, Prop_Send, "m_vecMins", fMins ); 
    GetEntPropVector( entity, Prop_Send, "m_vecMaxs", fMaxs ); 
    
    TR_TraceHullFilter( fPos, fPos, fMins, fMaxs, MASK_SOLID, TraceFilterIgnoreSelf, entity ); 
    return TR_DidHit( ); 
}
stock bool:WillEntityGetStuck( entity, Float:fPos[3] = {0.0, 0.0, 0.0}, Float:fMins[3] = {0.0, 0.0, 0.0}, Float:fMaxs[3] = {0.0, 0.0, 0.0} )
{
    TR_TraceHullFilter( fPos, fPos, fMins, fMaxs, MASK_SOLID, TraceFilterIgnoreSelf, entity ); 
    return TR_DidHit( ); 
}
stock Float:GetVectorDistanceMeter( const Float:vec1[3], const Float:vec2[3], bool:squared = false ) // Thx RavensBro.
{
    return ( GetVectorDistance( vec1, vec2, squared ) / 50.00 ); 
}
stock Float:GetVectorAnglesTwoPoints( const Float:startPos[3], const Float:endPos[3], Float:angles[3] )
{
    static Float:tmpVec[3]; 
    tmpVec[0] = endPos[0] - startPos[0]; 
    tmpVec[1] = endPos[1] - startPos[1]; 
    tmpVec[2] = endPos[2] - startPos[2]; 
    GetVectorAngles( tmpVec, angles ); 
}
stock bool:IsClientLookingAWall( client, Float:distance = 40.0 ) {

    decl Float:posEye[3], Float:posEyeAngles[3]; 
    
    GetClientEyePosition( client, posEye ); 
    GetClientEyeAngles( client, posEyeAngles ); 
    posEyeAngles[0] = 0.0; 

    new Handle:trace = TR_TraceRayFilterEx( posEye, posEyeAngles, CONTENTS_SOLID, RayType_Infinite, TraceFilterEntity ); 
    
    if ( TR_DidHit( trace ) ) {
        
        if ( TR_GetEntityIndex( trace ) > 0 ) {
            CloseHandle( trace ); 
            return false; 
        }
        
        decl Float:posEnd[3]; 
        TR_GetEndPosition( posEnd, trace ); 
        
        if ( GetVectorDistance( posEye, posEnd, true ) <= ( distance * distance ) ) {
            CloseHandle( trace ); 
            return true; 
        }
    }
    
    CloseHandle( trace ); 
    return false; 
}

//==== [ SOUND ] ========================================================
stock EmitSoundFromOrigin( const String:sound[], const Float:orig[3] )
{
    EmitSoundToAll( sound, SOUND_FROM_WORLD, SNDCHAN_AUTO, SNDLEVEL_NORMAL, SND_NOFLAGS, SNDVOL_NORMAL, SNDPITCH_NORMAL, -1, orig, NULL_VECTOR, true, 0.0 ); 
}

//==== [ RAGDOLLS ] =====================================================
public Action:RemoveBody( Handle:timer, any:client )
{
    new iBodyRagdoll; 
    iBodyRagdoll = GetEntPropEnt( client, Prop_Send, "m_hRagdoll" ); 

    if( IsValidEdict( iBodyRagdoll ) ) RemoveEdict( iBodyRagdoll ); 
}
public Action:TF2_RemoveGibs( Handle:timer, any:ent )
{
    if( IsValidEntity( ent ) )
    {
        decl String:sClassname[64]; 
        GetEdictClassname( ent, sClassname, sizeof( sClassname ) ); 

        if( StrEqual( sClassname, "tf_ragdoll", false ) ) RemoveEdict( ent ); 
    }
}

//==== [ TRACERS ] ======================================================
public bool:TraceFilterPlayer( entity, contentsMask, any:hiok )
{
    if( entity == hiok || entity > MaxClients || entity >= 1 && entity <= MaxClients ) return false; 

    return true; 
}
public bool:TraceFilterIgnoreSelf( entity, contentsMask, any:hiok )
{
    if ( entity == hiok || entity > 0 && entity <= MaxClients ) return false; 
    return true; 
}
public bool:TraceFilterEntity( entity, contentsMask, any:hiok )
{
    return entity == 0; 
}

//==== [ SPAWN ] ========================================================
stock SpawnThing( String:entity[32] = "", Float:duration = 0.0, victim, team = -1 )
{
    new ent = CreateEntityByName( entity ); 
    if ( IsValidEntity( ent ) )
    {
        DispatchSpawn( ent ); 
    
        if ( StrEqual( entity, "tf_zombie_spawner" ) ) {
            SetEntProp( ent, Prop_Data, "m_nSkeletonType", 1 ); 
            AcceptEntityInput( ent, "Enable" ); 
        }
        else if ( StrEqual( entity, "tf_zombie" ) ) {
            if ( team == 2 ) DispatchKeyValue( ent, "skin", "0" ); 
            else if ( team == 3 ) DispatchKeyValue( ent, "skin", "1" ); 
            SetEntProp( ent, Prop_Send, "m_iTeamNum", team ); 
        }
        else if ( StrEqual( entity, "eyeball_boss" ) ) SetEntProp( ent, Prop_Data, "m_iTeamNum", 5 ); 

        new Float:POSa[3], Float:POSe[3]; 
        GetClientAbsOrigin( victim, POSa ); 
        GetClientEyeAngles( victim, POSe ); 
        TeleportEntity( ent, POSa, POSe, NULL_VECTOR ); 

        CreateTimer( duration, m_tSpawnSkeletonOnKill_TimerDuration, ent ); 
    }
}
stock SpawnBombz( client, m_iEnt, bool:m_bCritical = false, m_iCount = 0, Float:m_flDamage = 1.0, Float:m_flRadius = 1.0 )
{
    new Float:pos[3]; 
    GetEntPropVector( m_iEnt, Prop_Send, "m_vecOrigin", pos ); 
    EmitSoundFromOrigin( SOUND_STICKYDETONATE, pos ); 

    if ( m_iCount > 400 ) m_iCount = 400; 
    for ( new i = 1; i <= m_iCount; i++ )
    {
        decl Float:m_flAngle[3]; 
        m_flAngle[0] = GetRandomFloat( -360.0 - ( m_iCount * 2 ), 360.0 + ( m_iCount * 2 ) );       //Left, Right
        m_flAngle[1] = GetRandomFloat( -360.0 - ( m_iCount * 2 ), 360.0 + ( m_iCount * 2 ) );       //Forward, Back
        m_flAngle[2] = GetRandomFloat( -360.0 + ( m_iCount * 2 ), 360.0 + ( m_iCount * 2 ) );        //Up, Down
        
        EmitAmbientSound( SOUND_GRENADE, pos, m_iEnt, _, _, 0.5, 150 ); 
        
        new ent2 = CreateEntityByName( "tf_projectile_pipe" ); 
        
        if( ent2 != -1 )
        {
            SetEntPropEnt( ent2, Prop_Data, "m_hThrower", client ); 
            SetEntProp( ent2, Prop_Send, "m_iTeamNum", GetClientTeam( client ) ); 
            if ( m_bCritical ) SetEntProp( ent2, Prop_Send, "m_bCritical", true ); 
            //SetEntPropFloat( ent2, Prop_Send, "m_flModelScale", 1 ); 
            SetEntPropFloat( ent2, Prop_Send, "m_DmgRadius", ( 146.0 * m_flRadius ) ); 
            SetEntPropFloat( ent2, Prop_Send, "m_flDamage", ( 100.0 * m_flDamage ) ); 
            
            DispatchSpawn( ent2 ); 
            
            SetEntityModel( ent2, MDL_BOMBLET ); 
            
            TeleportEntity( ent2, pos, NULL_VECTOR, m_flAngle ); 
        }
    }
}

//==== [ HOMING PROJECTILE ] ============================================
stock SetHomingProjectile( client, const String:classname[], Float:radius, mode, type )
{
    new entity = -1; 
    while( ( entity = FindEntityByClassname( entity, classname ) )!= INVALID_ENT_REFERENCE )
    {
        new owner = GetEntPropEnt( entity, Prop_Data, "m_hOwnerEntity" ); 
        if ( !IsValidEntity( owner ) ) continue; 
        if ( owner == client )
        {
            new Target = GetClosestTarget( entity, owner, mode ); 
            if ( !Target ) continue; 

            new Float:EntityPos[3], Float:TargetPos[3]; 
            GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityPos ); 
            GetClientAbsOrigin( Target, TargetPos ); 
            new Float:distance = GetVectorDistance( EntityPos, TargetPos ); 
            
            if( distance <= radius )
            {
                new Float:ProjLocation[3], Float:ProjVector[3], Float:BaseSpeed, Float:NewSpeed, Float:ProjAngle[3], Float:AimVector[3], Float:InitialSpeed[3]; 
                
                GetEntPropVector( entity, Prop_Send, "m_vInitialVelocity", InitialSpeed ); 
                if ( GetVectorLength( InitialSpeed ) < 10.0 ) GetEntPropVector( entity, Prop_Data, "m_vecAbsVelocity", InitialSpeed ); 
                BaseSpeed = GetVectorLength( InitialSpeed ) * 0.5; 
                
                GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", ProjLocation ); 
                GetClientAbsOrigin( Target, TargetPos ); 
                TargetPos[2] += ( 40.0 + Pow( distance, 2.0 ) / 10000.0 ); 
                
                MakeVectorFromPoints( ProjLocation, TargetPos, AimVector ); 
                
                if ( type == 0 ) GetEntPropVector( entity, Prop_Data, "m_vecAbsVelocity", ProjVector ); 
                else if ( type == 1 ) SubtractVectors( TargetPos, ProjLocation, ProjVector ); 
                AddVectors( ProjVector, AimVector, ProjVector ); 
                NormalizeVector( ProjVector, ProjVector ); 
                
                GetEntPropVector( entity, Prop_Data, "m_angRotation", ProjAngle ); 
                GetVectorAngles( ProjVector, ProjAngle ); 
                
                NewSpeed = ( BaseSpeed * 2.0 ) + GetEntProp( entity, Prop_Send, "m_iDeflected" ) * BaseSpeed * 1.1; 
                ScaleVector( ProjVector, NewSpeed ); 
                
                TeleportEntity( entity, NULL_VECTOR, ProjAngle, ProjVector ); 
            }
        }
    }   
}
stock GetClosestTarget( entity, owner, mode = 0 )
{
    new Float:TargetDistance = 0.0; 
    new ClosestTarget = 0; 
    for( new i = 1; i <= MaxClients; i++ ) 
    {
        if ( !IsValidForHoming( i, owner, entity, mode ) ) continue; 
        
        new Float:EntityLocation[3], Float:TargetLocation[3]; 
        GetEntPropVector( entity, Prop_Data, "m_vecAbsOrigin", EntityLocation ); 
        GetClientAbsOrigin( i, TargetLocation ); 
        
        new Handle:hTrace = TR_TraceRayFilterEx( TargetLocation, EntityLocation, MASK_SOLID, RayType_EndPoint, TraceFilterIgnoreSelf, entity ); 
        if( hTrace != INVALID_HANDLE )
        {
            if( TR_DidHit( hTrace ) )
            {
                CloseHandle( hTrace ); 
                continue; 
            }
            
            CloseHandle( hTrace ); 
            
            new Float:distance = GetVectorDistance( EntityLocation, TargetLocation ); 
            if( TargetDistance ) {
                if( distance < TargetDistance ) {
                    ClosestTarget = i; 
                    TargetDistance = distance;          
                }
            } else {
                ClosestTarget = i; 
                TargetDistance = distance; 
            }
        }
    }
    return ClosestTarget; 
}
stock bool:IsValidForHoming( client, owner, entity, mode )
{
    if ( IsValidClient( owner ) && IsValidClient( client ) && IsValidEntity( entity ) )
    {
        new Float:OwnerPos[3], Float:TargetPos[3]; 
        GetClientAbsOrigin( owner, OwnerPos ); 
        GetClientAbsOrigin( client, TargetPos ); 
        new Float:distance_d = GetVectorDistance( OwnerPos, TargetPos ); 
        if ( distance_d <= 146.0 ) return false; 
    
        new team = GetEntProp( entity, Prop_Send, "m_iTeamNum" ); 
        if ( IsPlayerAlive( client ) && client != owner && GetClientTeam( owner ) != GetClientTeam( client ) )
        {
            if ( !TF2_IsPlayerInCondition( client, TFCond_Cloaked ) && !TF2_IsPlayerInCondition( client, TFCond_Ubercharged )
                && !TF2_IsPlayerInCondition( client, TFCond_Bonked ) && !TF2_IsPlayerInCondition( client, TFCond_Stealthed )
                && !TF2_IsPlayerInCondition( client, TFCond_BlastImmune ) && !TF2_IsPlayerInCondition( client, TFCond_HalloweenGhostMode )
                && !TF2_IsPlayerInCondition( client, TFCond_Disguised ) && GetEntProp( client, Prop_Send, "m_nDisguiseTeam" ) != team )
            {
                if ( mode == 0 ) return true; // No mode.
                if ( mode == 1 && TF2_IsPlayerInCondition( client, TFCond_OnFire ) ) return true; // Heat Seeking.
                if ( mode == 2 && !( GetEntityFlags( client ) & FL_ONGROUND ) && !( GetEntityFlags( client ) & FL_INWATER ) ) return true; // Airborne.
                if ( mode == 3 && GetEntityFlags( client ) & FL_INWATER ) return true; // Torpedo.
                if ( mode == 4 && TF2_IsPlayerInCondition( client, TFCond_OnFire ) && !( GetEntityFlags( client ) & FL_ONGROUND ) && !( GetEntityFlags( client ) & FL_INWATER ) ) return true; // Heat Seeking Airborne.
                if ( mode == 5 && !( GetEntityFlags( client ) & FL_ONGROUND ) ) return true; // Airborne Torpedo.
            }
        }
    }
    
    return false; 
}

//==== [ PARTICLES ] ====================================================
stock ShowText( client, String:text[] = "" )
{
    decl Float:vOrigin[3]; 
    GetClientEyePosition( client, vOrigin ); 
    vOrigin[2] += 2.0; 

    new particle = CreateEntityByName( "info_particle_system" ); 
    if ( IsValidEntity( particle ) )
    {
        TeleportEntity( particle, vOrigin, NULL_VECTOR, NULL_VECTOR ); 
        DispatchKeyValue( particle, "effect_name", text ); 
        DispatchSpawn( particle ); 
        ActivateEntity( particle ); 
        AcceptEntityInput( particle, "start" ); 
        SetVariantString( "OnUser1 !self:Kill::8:-1" ); 
        AcceptEntityInput( particle, "AddOutput" ); 
        AcceptEntityInput( particle, "FireUser1" ); 
    }
}
stock any:AttachParticle( ent, String:particleName[], Float:duration = 0.0, Float:addPos[3] = NULL_VECTOR, Float:addAngle[3] = NULL_VECTOR, bool:bAttach = true, String:strVariant[] = "", bool:bMaintain = false, bool:bEyes = false )
{
    new particle = CreateEntityByName( "info_particle_system" ); 
    if ( IsValidEdict( particle ) )
    {
        new Float:pos[3]; 
        new Float:ang[3]; 
        decl String:tName[32]; 
        GetEntPropVector( ent, Prop_Send, "m_vecOrigin", pos ); 
        if ( bEyes && IsValidClient( ent ) ) GetClientEyePosition( ent, pos ); 
        AddVectors( pos, addPos, pos ); 
        GetEntPropVector( ent, Prop_Send, "m_angRotation", ang ); 
        AddVectors( ang, addAngle, ang ); 

        Format( tName, sizeof( tName ), "target%i", ent ); 
        DispatchKeyValue( ent, "targetname", tName ); 

        TeleportEntity( particle, pos, ang, NULL_VECTOR ); 
        DispatchKeyValue( particle, "targetname", "tf2particle" ); 
        DispatchKeyValue( particle, "parentname", tName ); 
        DispatchKeyValue( particle, "effect_name", particleName ); 
        DispatchSpawn( particle ); 
        SetEntPropEnt( particle, Prop_Send, "m_hOwnerEntity", ent ); 
        
        if ( bAttach ) SetVariantString( tName ); 
        else SetVariantString( "!activator" ); 
        AcceptEntityInput( particle, "SetParent", ent, particle, 0 ); 
        
        if ( !StrEqual( strVariant, "" ) )
        {
            SetVariantString( strVariant ); 
            if ( bMaintain ) AcceptEntityInput( particle, "SetParentAttachmentMaintainOffset", ent, particle, 0 ); 
            else AcceptEntityInput( particle, "SetParentAttachment", ent, particle, 0 ); 
        }
        ActivateEntity( particle ); 
        AcceptEntityInput( particle, "start" ); 
        if ( duration > 0.0 ) CreateTimer( duration, RemoveParticle, particle ); 
    }
    else return -1; 
    
    return particle; 
}
stock AddParticle( client, entity, String:m_strParticle[], m_iCount )
{
    if ( IsValidClient( client ) )
    {
        for ( new i = 0; i < m_iCount; i++ )
        {
            AttachParticle( entity, m_strParticle ); 
        }
    }
}
stock CreateEntityParticle( const String:particleName[], Float:time, Float:pos[3], Float:ang[3] = NULL_VECTOR )
{
    new particle = CreateEntityByName( "info_particle_system" ); 
    if( IsValidEdict( particle ) )
    {
        TeleportEntity( particle, pos, ang,  NULL_VECTOR ); 
        DispatchKeyValue( particle, "effect_name", particleName ); 
        DispatchSpawn( particle ); 
        ActivateEntity( particle ); 
        AcceptEntityInput( particle, "start" ); 
        CreateTimer( time, RemoveParticle, particle ); 
    }
    else return -1; 
    
    return particle; 
}
stock SetEntitySelfDestruct( entity, bool:customduration )
{
    new String:output[64]; 
    Format( output, sizeof( output ), "OnUser1 !self:kill::%.1f:1", ( customduration ? 1.0 : 1.0 ) ); 
    SetVariantString( output ); 
    AcceptEntityInput( entity, "AddOutput" ); 
    AcceptEntityInput( entity, "FireUser1" ); 
}
stock PrecacheParticle( String:name[] )
{
    if( IsValidEntity( 0 ) ) // Is this necessary ?
    {
        new particle = CreateEntityByName( "info_particle_system" ); 
        if ( IsValidEdict( particle ) )
        {
            new String:tName[32]; 
            GetEntPropString( 0, Prop_Data, "m_iName", tName, sizeof( tName ) ); 
            DispatchKeyValue( particle, "targetname", "tf2particle" ); 
            DispatchKeyValue( particle, "parentname", tName ); 
            DispatchKeyValue( particle, "effect_name", name ); 
            DispatchSpawn( particle ); 
            SetVariantString( tName ); 
            AcceptEntityInput( particle, "SetParent", 0, particle, 0 ); 
            ActivateEntity( particle ); 
            AcceptEntityInput( particle, "start" ); 
            CreateTimer( 0.01, RemoveParticle, particle ); 
        }
    }
}
public Action:RemoveParticle( Handle:timer, any:particle )
{
    if ( particle >= 0 && IsValidEntity( particle ) )
    {
        new String:classname[32]; 
        GetEdictClassname( particle, classname, sizeof( classname ) ); 
        if ( StrEqual( classname, "info_particle_system", false ) )
        {
            AcceptEntityInput( particle, "Stop" ); 
            AcceptEntityInput( particle, "Kill" ); 
            AcceptEntityInput( particle, "Deactivate" ); 
            particle = -1; 
        }
    }
}

//==== [ SPECIAL ] =====================================================
stock bool:TF2_ShouldReveal( client ) {
    if ( TF2_IsPlayerInCondition( client, TFCond_Cloaked ) ) return true; 
    if ( TF2_IsPlayerInCondition( client, TFCond_Disguised ) ) return false; 
    
    return true; 
}
stock bool:TF2_DamageWillKill( client, Float:damage, bool:beSure = false )
{
    new health = GetClientHealth( client ); 
    if ( beSure ) damage += 5.0; 
    if ( damage >= health ) return true; 
    
    return false; 
}
stock TF2_RemoveBadCondition( client, bool:melee = false )
{
    TF2_RemoveCondition( client, TFCond_Slowed ); 
    TF2_RemoveCondition( client, TFCond_Zoomed ); 
    TF2_RemoveCondition( client, TFCond_Bonked ); 
    TF2_RemoveCondition( client, TFCond_Dazed ); 
    TF2_RemoveCondition( client, TFCond_OnFire ); 
    TF2_RemoveCondition( client, TFCond_Jarated ); 
    TF2_RemoveCondition( client, TFCond_Bleeding ); 
    TF2_RemoveCondition( client, TFCond_Milked ); 
    TF2_RemoveCondition( client, TFCond_MarkedForDeath ); 
    TF2_RemoveCondition( client, TFCond_MarkedForDeathSilent ); 
    TF2_RemoveCondition( client, TFCond_HalloweenBombHead ); 
    if ( melee ) TF2_RemoveCondition( client, TFCond_RestrictToMelee ); 
    if ( melee ) TF2_RemoveCondition( client, TFCond_MeleeOnly ); 
}
stock bool HasInvulnerabilityCond( client )
{
    if ( TF2_IsPlayerInCondition( client, TFCond_Ubercharged )
        || TF2_IsPlayerInCondition( client, TFCond_Bonked )
        || TF2_IsPlayerInCondition( client, TFCond_HalloweenGhostMode ) ) return true; 
    
    return false; 
}
stock bool:IsValidEnt( entity )
{
    if ( IsValidEdict( entity ) )
    {
        char classname[32]; 
        GetEdictClassname( entity, classname, sizeof( classname ) ); 
        if ( StrEqual( classname, "eyeball_boss" )
            || StrEqual( classname, "headless_hatman" )
            || StrEqual( classname, "tank_boss" )
            || StrEqual( classname, "merasmus" )
            || StrEqual( classname, "tf_zombie" )
            || StrEqual( classname, "obj_dispenser" )
            || StrEqual( classname, "obj_sentrygun" )
            || StrEqual( classname, "obj_teleporter" ) )
        {
            return true; 
        }
    }
    return false; 
}
stock AttackSpeedLimit( client, weapon, slot, Float:attack_speed )
{
    if ( IsValidClient( client ) && IsValidEntity( weapon ) && IsValidEdict( weapon ) )
    {
        if ( slot < 2 )
        {
            if ( attack_speed < 0.0 ) TF2Attrib_SetByName( weapon, "fire rate bonus", 0.0 ); 
        }
        else if ( slot == 2 )
        {
            if ( TF2_GetPlayerClass( client ) == TFClass_Scout ) {
                if ( attack_speed < 0.392 ) TF2Attrib_SetByName( weapon, "fire rate bonus", 0.392 ); 
            } else if ( TF2_GetPlayerClass( client ) == TFClass_Spy ) {
                if ( attack_speed < 0.001 ) TF2Attrib_SetByName( weapon, "fire rate bonus", 0.001 ); 
            } else {
                if ( attack_speed < 0.245 ) TF2Attrib_SetByName( weapon, "fire rate bonus", 0.245 ); 
            }
        }
    }
}
stock bool:IsAProjectile( entity )
{
    if ( IsValidEdict( entity ) )
    {
        char classname[32]; 
        GetEdictClassname( entity, classname, sizeof( classname ) ); 
        if ( StrEqual( classname, "tf_projectile_arrow" )
            || StrEqual( classname, "tf_projectile_ball_ornament" )
            || StrEqual( classname, "tf_projectile_energy_ball" )
            || StrEqual( classname, "tf_projectile_energy_ring" )
            || StrEqual( classname, "tf_projectile_cleaver" )
            || StrEqual( classname, "tf_projectile_flare" )
            || StrEqual( classname, "tf_projectile_grapplinghook" )
            || StrEqual( classname, "tf_projectile_healing_bolt" )
            || StrEqual( classname, "tf_projectile_pipe" )
            || StrEqual( classname, "tf_projectile_pipe_remote" )
            || StrEqual( classname, "tf_projectile_rocket" )
            || StrEqual( classname, "tf_projectile_stun_ball" )
            || StrEqual( classname, "tf_projectile_syringe" ) )
        {
            return true; 
        }
    }
    return false; 
}
