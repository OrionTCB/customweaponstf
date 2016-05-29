#pragma semicolon 1
// ====[ hi ok ]=======================================================
// ====[ INCLUDES ]====================================================
#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <sdkhooks>
#include <cw3-attributes>
//#include <customweaponstf>
#include <customweaponstf_orionstock>
#include <time>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_VERSION                "1.04"

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
    name           = "Custom Weapons: More Advanced Weaponiser 2 Attributes",
    author         = "Orion && the AW2 dev team",
    description    = "Custom Weapons: More Advanced Weaponiser 2 Attributes",
    version        = PLUGIN_VERSION,
    url            = "https://forums.alliedmods.net/showpost.php?p=2193855&postcount=254"
};

// ====[ VARIABLES ]===================================================
new bool:m_bHasAttribute[MAXPLAYERS + 1][MAXSLOTS + 1];

enum
{
    Handle:m_hMiniMann_TimerCooldown = 0,
    Handle:m_hMiniMann_TimerDuration,
    Handle:m_hMiniMann_TimerDelay,
    Handle:m_hBonkHealth_TimerCooldown,
    Handle:m_hBonkHealth_TimerDelay,
    Handle:m_hRageDecrease_TimerDelay,
    Handle:m_hMarkVictim_TimerDuration,
    Handle:m_hMarkVictimForDeath_TimerDuration,
    Handle:m_hMissCauseDelay_TimerDuration,
    Handle:m_hDamageDone_TimerDuration,
    Handle:m_hTimer
};
new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];
enum
{
    m_bSniperCombo = 0,
    m_bLastWasMiss,
    m_bPyroCombo,
    m_bLastWasMissPISS,
    m_bDrainRage,
    m_bBool
};
new bool:m_bBools[MAXPLAYERS + 1][m_bBool];
enum
{
    m_flExplosionSound = 0,
    m_flDamageCharge,
    m_flTakeDamageCharge,
    m_flRespawn,
    m_flElectroshock,
    m_flElectroshockEngine,
    m_flFloat
};
new Float:m_flFloats[MAXPLAYERS + 1][m_flFloat];
enum
{
    m_iSniperComboHit = 0,
    m_iPyroComboHit,
    m_iJumpAmount,
    m_iJumpAmountBase,
    m_iMarkedVictim,
    m_iMarkedVictimForDeath,
    m_iInteger
};
new m_iIntegers[MAXPLAYERS + 1][m_iInteger];

new bool:m_bSlotDisabled[MAXPLAYERS + 1][MAXSLOTS + 1];
new bool:g_hPostInventory[MAXPLAYERS + 1]               = false;
new g_iLastButtons[MAXPLAYERS + 1]                      = -1;
new g_iLastWeapon[MAXPLAYERS + 1]                       = -1;
new g_pMarker[MAXPLAYERS + 1]                           = -1;
new Handle:g_hHudText_AW2;


    /* On Hit
     * ---------------------------------------------------------------------- */

new bool:m_bMarkVictim_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMarkVictim_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMarkVictim_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMarkVictimForDeath_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMarkVictimForDeath_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMarkVictimForDeath_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisableSlot_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDisableSlot_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDisableSlot_Slot[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisarmSilent_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDisarmSilent_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bIncreasedPushScale_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flIncreasedPushScale_Scale[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritHealingMedic_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDemoChargeOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDemoChargeOnHit_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Crit
     * ---------------------------------------------------------------------- */

new bool:m_bMiniCritDisguisedCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMiniCritDisguisedCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritDisguisedCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCritDisguisedCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Attack
     * ---------------------------------------------------------------------- */

new bool:m_bSniperCombo_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSniperCombo_DMGA[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSniperCombo_DMGB[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSniperCombo_DMGC[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bPyroCombo_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPyroCombo_DMGA[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPyroCombo_DMGB[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPyroCombo_DMGC[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bPissYourselfOnMiss_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMissCauseDelay_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissCauseDelay_Delay[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Kill
     * ---------------------------------------------------------------------- */

new bool:m_bUberchargeOnKill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flUberchargeOnKill_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Damage
     * ---------------------------------------------------------------------- */

new bool:m_bUberchargeToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flUberchargeToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bEnemyUberchargeToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnemyUberchargeToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bExplosiveDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveDamage_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveDamage_Force[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveDamage_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iExplosiveDamage_DamageMode[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bExplosiveCriticalDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveCriticalDamage_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveCriticalDamage_Force[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flExplosiveCriticalDamage_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iExplosiveCriticalDamage_DamageMode[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bLevelUpSystem_DamageDone_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageDone_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageDone_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageDone_CriticalChance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageDone_Lifesteal[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageDone_PocketUberchargeDuration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bNonCriticalDamageModifier_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flNonCriticalDamageModifier_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bFlyWhileShooting_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisorientateOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bNoBackstab_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flNoBackstab_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bElectroshock_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flElectroshock_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flElectroshock_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Prethink
     * ---------------------------------------------------------------------- */

new bool:m_bSpeedCloak_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSpeedCloak_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDemoCharge_Ubercharge_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDemoCharge_Invisibility_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritOnHealthPointsThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCritOnHealthPointsThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bSpeedBoostFire_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bRageDecrease_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRageDecrease_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisableAlt_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisablePrimAlt_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bJumpBonus_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iJumpBonus_BaseJumps[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iJumpBonus_Hit[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iJumpBonus_Kill[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iJumpBonus_MaxJumps[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDashOffSet;

new bool:m_bChargedAirblast_SOUNDONLY_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Damage Received
     * ---------------------------------------------------------------------- */

new bool:m_bLevelUpSystem_DamageReceived_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_CriticalDamageResistance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_HealthRegeneration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_Lifesteal[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLevelUpSystem_DamageReceived_OldHealthRegeneration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMetalShield_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMetalShield_DamageAbsorb[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMetalShield_DamageAbsorbMetalPct[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* To Activate
     * ---------------------------------------------------------------------- */

new bool:m_bAddCondAltFire_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAddCondAltFire_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAddCondAltFire_HealthPoints[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iAddCondAltFire_ID[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMiniMann_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMiniMann_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMiniMann_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMiniMann_Resize[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMiniMann_Speed[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMiniMann_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDeployUbercharge_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDeployUbercharge_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBonkHealth_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonkHealth_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonkHealth_Heal[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonkHealth_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Death
     * ---------------------------------------------------------------------- */

new bool:m_bRespawnWhereYouDied_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRespawnWhereYouDied_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRespawnWhereYouDied_Delay[MAXPLAYERS + 1][MAXSLOTS + 1];


// ====[ ON PLUGIN START ]=============================================
public OnPluginStart()
{
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame( i ) )
        {
            OnClientPutInServer( i );
        }
    }

    m_iDashOffSet = FindSendPropInfo( "CTFPlayer", "m_iAirDash" );

    HookEvent( "player_chargedeployed",      Event_ChargeDeployed );
    HookEvent( "post_inventory_application", Event_PostInventoryApplication );

    HookEvent( "player_death",           Event_Death,          EventHookMode_Pre );
    HookEvent( "teamplay_restart_round", Event_OnRoundRestart, EventHookMode_Pre );

    new Handle:m_hSDKConfig = LoadGameConfigFile( "sdkhooks.games" );
    if ( m_hSDKConfig != INVALID_HANDLE )
    {
        StartPrepSDKCall( SDKCall_Entity );
        PrepSDKCall_SetFromConf( m_hSDKConfig, SDKConf_Virtual, "GetMaxHealth" );
        PrepSDKCall_SetReturnInfo( SDKType_PlainOldData, SDKPass_Plain );
        m_hGetPlayerMaxHealth = EndPrepSDKCall();
        CloseHandle( m_hSDKConfig );
    }
    else LogMessage( "Custom Weapons 2 ERROR : MOREAW2 : SDKHooks failed to load ! Is Sourcemod well installed ? Health based attributes won't work correctly." );

    SetHudTextParams( 1.0, 0.5, 0.15, 255, 255, 255, 255 );  
    g_hHudText_AW2 = CreateHudSynchronizer();
}

// ====[ ON CLIENT PUT IN SERVER ]=====================================
public OnClientPutInServer( m_iClient )
{
    SDKHook( m_iClient, SDKHook_OnTakeDamage, OnTakeDamage );
    SDKHook( m_iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive );
    SDKHook( m_iClient, SDKHook_OnTakeDamagePost, OnTakeDamagePost );
    SDKHook( m_iClient, SDKHook_PreThink, OnClientPreThink );
}

// ====[ ON PLUGIN END ]===============================================
public OnPluginEnd()
{
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame( i ) )
        {
            for ( new e = 0; e < m_hTimer; e++ )
            {
                ClearTimer( m_hTimers[i][e] );
            }
            for ( new e = 0; e < m_bBool; e++ )
            {
                m_bBools[i][e]              = false;
            }
            for ( new e = 0; e < m_flFloat; e++ )
            {
                m_flFloats[i][e]            = 0.0;
            }
            for ( new e = 0; e < m_iInteger; e++ )
            {
                m_iIntegers[i][e]           = 0;
            }
            for ( new e = 0; e < MAXSLOTS; e++ )
            {
                m_bSlotDisabled[i][e]       = false;
            }
            g_iLastWeapon[i]  = -1;
            g_pMarker[i]      = -1;
            s_bGlowEnabled[i] = false;
            SetEntProp( i, Prop_Send, "m_bGlowEnabled", 0 );
        }
    }
}

// ====[ ON CLIENT DISCONNECT ]========================================
public OnClientDisconnect( m_iClient )
{
    for ( new i = 0; i < m_hTimer; i++ )
    {
        ClearTimer( m_hTimers[m_iClient][i] );
    }
    for ( new i = 0; i < m_flFloat; i++ )
    {
        m_flFloats[m_iClient][i]    = 0.0;
    }
    for ( new i = 0; i < m_bBool; i++ )
    {
        m_bBools[m_iClient][i]      = false;
    }
    for ( new i = 0; i < m_iInteger; i++ )
    {
        m_iIntegers[m_iClient][i]   = 0;
    }
    for ( new i = 0; i < MAXSLOTS; i++ )
    {
        m_bSlotDisabled[m_iClient][i] = false;
    }
    g_iLastWeapon[m_iClient]  = -1;
    g_pMarker[m_iClient]      = -1;
    s_bGlowEnabled[m_iClient] = false;
}

// ====[ EVENT: ON ROUND RESTART ]=====================================
public Event_OnRoundRestart( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame( i ) )
        {
            for ( new e = 0; e < m_hTimer; e++ )
            {
                ClearTimer( m_hTimers[i][e] );
            }
            for ( new e = 0; e < m_bBool; e++ )
            {
                m_bBools[i][e]      = false;
            }
            for ( new e = 0; e < m_flFloat; e++ )
            {
                m_flFloats[i][e]    = 0.0;
            }
            for ( new e = 0; e < m_iInteger; e++ )
            {
                m_iIntegers[i][e]   = 0;
            }
            g_iLastWeapon[i]  = -1;
            g_pMarker[i]      = -1;
            s_bGlowEnabled[i] = false;
            SetEntProp( i, Prop_Send, "m_bGlowEnabled", 0 );
        }
    }
}

// ====[ EVENT: CHANGE CLASS ]=========================================
public Event_ChangeClass( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );
    
    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) )
    {
        for ( new i = 0; i < m_hTimer; i++ )
        {
            ClearTimer( m_hTimers[m_iClient][i] );
        }
        for ( new i = 0; i < m_bBool; i++ )
        {
            m_bBools[m_iClient][i]          = false;
        }
        for ( new i = 0; i < m_flFloat; i++ )
        {
            m_flFloats[m_iClient][i]        = 0.0;
        }
        for ( new i = 0; i < m_iInteger; i++ )
        {
            m_iIntegers[m_iClient][i]       = 0;
        }
        if ( s_bGlowEnabled[m_iClient] ) {
            s_bGlowEnabled[m_iClient] = false;
            SetEntProp( m_iClient, Prop_Send, "m_bGlowEnabled", 0 );
        }
        g_pMarker[m_iClient]     = -1;
        g_iLastWeapon[m_iClient] = -1;
    }

    return;
}

// ====[ EVENT: POST INVENTORY APPLICATION ]===========================
public Event_PostInventoryApplication( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );
    
    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) )
    {
        if ( m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] );
        }
        if ( m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] );
        }
        if ( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] );
            SetEntPropFloat( m_iClient, Prop_Send, "m_flModelScale", 1.0 );
            TF2_RemoveCondition( m_iClient, TFCond_SpeedBuffAlly );
        }
        for ( new i = 0; i < MAXSLOTS; i++ ) m_bSlotDisabled[m_iClient][i] = false;

        if ( !g_hPostInventory[m_iClient] ) {
            CreateTimer( 0.02, m_tPostInventory, m_iClient );
            g_hPostInventory[m_iClient] = true;
        }
    }
    
    return;
}

// ====[ EVENT: ÜBERCHARGE DEPLOYED ]==================================
public Event_ChargeDeployed( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );

    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) ) {
        if ( HasAttribute( m_iClient, 1, m_bDeployUbercharge_ATTRIBUTE ) ) TF2_RemoveCondition( m_iClient, TFCond_Ubercharged );
    }

    return;
}

// ====[ ON CLIENT PRETHINK ]==========================================
public OnClientPreThink( m_iClient )
{
    OnPreThink( m_iClient );
}
public OnPreThink( m_iClient )
{
    if ( !IsPlayerAlive( m_iClient ) ) return;
    if ( !IsValidClient( m_iClient ) ) return;
    
    new m_iButtonsLast = g_iLastButtons[m_iClient];
    new m_iButtons = GetClientButtons( m_iClient );
    new m_iButtons2 = m_iButtons;
    
    new Handle:hArray = CreateArray();
    new m_iSlot = TF2_GetClientActiveSlot( m_iClient );
    if ( m_iSlot >= 0 ) PushArrayCell( hArray, m_iSlot );
    PushArrayCell( hArray, 4 );
    
    new m_iSlot2;
    for ( new i = 0; i < GetArraySize( hArray ); i++ ) // ACTIVE STUFF HERE.
    {
        m_iSlot2 = GetArrayCell( hArray, i );
        m_iButtons = ATTRIBUTE_ADDCONDALT( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_BONKHEALTH( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_CHARGEDAIRBLAST( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DAMAGEDONE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DAMAGERECEIVED( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DEPLOYUBERCHARGE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DISABLEALT( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DISABLEPRIMARY( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_FLYWHILESHOOTING( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_MINIMANN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
    }
    CloseHandle( hArray );
    
    m_iSlot2 = -1;
    
    for ( m_iSlot2 = 0; m_iSlot2 <= 4; m_iSlot2++ ) // ALWAYS ACTIVE | PASSIVE STUFF HERE.
    {
        m_iButtons = ATTRIBUTE_DEMOCHARGEUBERCHARGE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DEMOCHARGINVISIBLE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_ELECTROSHOCK( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_JUMPBONUS( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_RAGEDRAIN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_SPEEDCLOAK( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_SPEEDFIRE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = HUD_SHOWSYNCHUDTEXT( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = PRETHINK_STACKREMOVER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
    }

    if ( m_iButtons != m_iButtons2 ) SetEntProp( m_iClient, Prop_Data, "m_nButtons", m_iButtons );    
    g_iLastButtons[m_iClient] = m_iButtons;
}

ATTRIBUTE_DAMAGERECEIVED( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, true ) )
    {
        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        static bool:snd1[MAXPLAYERS + 1] = false;
        static bool:snd2[MAXPLAYERS + 1] = false;
        static bool:snd3[MAXPLAYERS + 1] = false;
        static bool:snd4[MAXPLAYERS + 1] = false;

        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 100.0 ) snd1[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 200.0 ) snd2[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 300.0 ) snd3[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 400.0 ) snd4[m_iClient] = false;

        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 100.0 && !snd1[m_iClient] )
        {
            snd1[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP1, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 200.0 )
        {
            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_OldAttackSpeed, true ) );
            new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
            new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
            new Float:fValue = GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_AttackSpeed, true );

            TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", fValue );

            if ( m_iSlot == 0 || m_iSlot == 1 ) {
                if ( m_flAttackSpeed < 0.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.0 );
            }
            else if ( m_iSlot == 2 ) {
                if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Scout ) {
                    if ( m_flAttackSpeed < 0.392 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.392 );
                } else if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Spy ) {
                    if ( m_flAttackSpeed < 0.001 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.001 );
                } else {
                    if ( m_flAttackSpeed < 0.245 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.245 );
                }
                // If the fire rate is too fast, the animation won't allow you to land your attack.
            }

            if ( !snd2[m_iClient] )
            {
                snd2[m_iClient] = true;
                EmitSoundToClient( m_iClient, SOUND_LVLUP2, _, _, _, _, 1.0 );
                TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
            }
        }
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 300.0 )
        {
            if ( !( TF2Attrib_GetByName( m_iWeapon, "health regen" ) ) ) TF2Attrib_SetByName( m_iWeapon, "health regen", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_OldHealthRegeneration, true ) );
            TF2Attrib_SetByName( m_iWeapon, "health regen", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_HealthRegeneration, true ) );
            
            if ( !snd3[m_iClient] )
            {
                snd3[m_iClient] = true;
                EmitSoundToClient( m_iClient, SOUND_LVLUP3, _, _, _, _, 1.0 );
                TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
            }
        }
        if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 400.0 && !snd4[m_iClient] )
        {
            snd4[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP4, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
    }

    return m_iButtons;
}

ATTRIBUTE_ADDCONDALT( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, true ) && m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
    {
        if ( GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) ) return m_iButtons;
        if ( !TF2_IsPlayerInCondition( m_iClient, TFCond:GetAttributeValueI( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_iAddCondAltFire_ID, true ) ) )
        {
            if ( GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_HealthPoints, true ) >= 1.0 )
            {
                if ( GetClientHealth( m_iClient ) > GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_HealthPoints, true ) )
                {
                    DealDamage( m_iClient, RoundToFloor( GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_HealthPoints, true ) ), m_iClient, TF_DMG_PREVENT_PHYSICS_FORCE );

                    TF2_AddCondition( m_iClient, TFCond:GetAttributeValueI( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_iAddCondAltFire_ID, true ), GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_Duration, true ) );
                    EmitSoundToClient( m_iClient, SOUND_READY );
                }
            } else {
                if ( GetClientHealth( m_iClient ) > TF2_GetClientMaxHealth( m_iClient ) * GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_HealthPoints, true ) )
                {
                    DealDamage( m_iClient, RoundToFloor( TF2_GetClientMaxHealth( m_iClient ) * GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_HealthPoints, true ) ), m_iClient, TF_DMG_PREVENT_PHYSICS_FORCE );

                    TF2_AddCondition( m_iClient, TFCond:GetAttributeValueI( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_iAddCondAltFire_ID, true ), GetAttributeValueF( m_iClient, _, m_bAddCondAltFire_ATTRIBUTE, m_flAddCondAltFire_Duration, true ) );
                    EmitSoundToClient( m_iClient, SOUND_READY );
                }
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DEPLOYUBERCHARGE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDeployUbercharge_ATTRIBUTE ) )
    {
        if ( HasAttribute( m_iClient, _, m_bDeployUbercharge_ATTRIBUTE, true ) && m_iButtons & IN_ATTACK2 == IN_ATTACK2 ) {
            if ( GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) ) return m_iButtons;
            if ( !TF2_IsUberchargeDeployed( m_iClient ) )
            {
                new Float:Threshold = GetAttributeValueF( m_iClient, _, m_bDeployUbercharge_ATTRIBUTE, m_flDeployUbercharge_Threshold, true );
                new Float:m_flUbercharge = TF2_GetClientUberLevel( m_iClient );
                if ( m_flUbercharge >= Threshold ) TF2_ReleaseUbercharge( m_iClient );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DAMAGEDONE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE ) )
    {
        if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE, true ) )
        {
            if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 ) {
                if ( GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) ) return m_iButtons;

                if ( !HasInvulnerabilityCond( m_iClient ) && m_hTimers[m_iClient][m_hDamageDone_TimerDuration] == INVALID_HANDLE && m_flFloats[m_iClient][m_flDamageCharge] >= 400.0 )
                {
                    m_hTimers[m_iClient][m_hDamageDone_TimerDuration] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE, m_flLevelUpSystem_DamageDone_PocketUberchargeDuration, true ), m_tDamageDone_TimerDuration, m_iClient );
                    TF2_AddCondition( m_iClient, TFCond_Ubercharged, GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE, m_flLevelUpSystem_DamageDone_PocketUberchargeDuration, true ) );
                    TF2_AddCondition( m_iClient, TFCond_TeleportedGlow, GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE, m_flLevelUpSystem_DamageDone_PocketUberchargeDuration, true ) );
                    EmitSoundToClient( m_iClient, SOUND_UBER );
                }
            }
        }
        if ( m_hTimers[m_iClient][m_hDamageDone_TimerDuration] != INVALID_HANDLE ) {
            m_flFloats[m_iClient][m_flDamageCharge] -= ( 0.75 / GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE, m_flLevelUpSystem_DamageDone_PocketUberchargeDuration ) );
            if ( m_flFloats[m_iClient][m_flDamageCharge] < 300 ) m_flFloats[m_iClient][m_flDamageCharge] = 300.0;
        }

        static bool:snd5[MAXPLAYERS + 1] = false;
        static bool:snd6[MAXPLAYERS + 1] = false;
        static bool:snd7[MAXPLAYERS + 1] = false;
        static bool:snd8[MAXPLAYERS + 1] = false;

        if ( m_flFloats[m_iClient][m_flDamageCharge] < 100.0 ) snd5[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flDamageCharge] < 200.0 ) snd6[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flDamageCharge] < 300.0 ) snd7[m_iClient] = false;
        if ( m_flFloats[m_iClient][m_flDamageCharge] < 400.0 ) snd8[m_iClient] = false;

        if ( m_flFloats[m_iClient][m_flDamageCharge] >= 100.0 && !snd5[m_iClient] )
        {
            snd5[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP1, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
        if ( m_flFloats[m_iClient][m_flDamageCharge] >= 200.0 && !snd6[m_iClient] )
        {
            snd6[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP2, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
        if ( m_flFloats[m_iClient][m_flDamageCharge] >= 300.0 && !snd7[m_iClient] )
        {
            snd7[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP3, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
        if ( m_flFloats[m_iClient][m_flDamageCharge] >= 400.0 && !snd8[m_iClient] )
        {
            snd8[m_iClient] = true;
            EmitSoundToClient( m_iClient, SOUND_LVLUP4, _, _, _, _, 1.0 );
            TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 2.0 ); 
        }
    }

    return m_iButtons;
}

ATTRIBUTE_FLYWHILESHOOTING( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bFlyWhileShooting_ATTRIBUTE, true ) && m_iButtons & IN_ATTACK == IN_ATTACK ) {

        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        if ( GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) ) return m_iButtons;
        if ( GetEntityFlags( m_iClient ) & FL_ONGROUND ) return m_iButtons;
        if ( GetEntityFlags( m_iClient ) & FL_INWATER ) return m_iButtons;
        if ( GetEntProp( m_iWeapon, Prop_Send, "m_bLowered" ) ) return m_iButtons;

        decl String:weaponStr[64];
        GetClientWeapon( m_iClient, weaponStr, sizeof( weaponStr ) );
        new primary = GetPlayerWeaponSlot( m_iClient, TFWeaponSlot_Primary );
        if ( primary > MaxClients && IsValidEntity( primary ) )
        {
            if ( StrEqual( weaponStr, "tf_weapon_flamethrower" ) )
            {
                new Float:Orig[3];
                new Float:Velo[3];
                GetEntPropVector( m_iClient, Prop_Data, "m_vecAbsVelocity", Velo );
                            
                GetClientEyeAngles( m_iClient, Orig );
                Orig[0] *= ( -1.0 );
                Orig[1] = DegToRad( Orig[1] );
                            
                if ( Velo[2] >= 0.0 )
                {
                    if ( Velo[2]<230.0 )
                    {
                        if ( Orig[0]>20.0 )Velo[2] *= 2.07;//FlyWhileShootingUpward[m_iWeapon];
                        else Velo[2] *= 1.47;//FlyWhileShootingUp[m_iWeapon];
                    }
                }
                else {
                    decl Handle:TraceEx;
                    decl Float:hitPos[3];
                    decl Float:clientPos[3];
                    decl Float:targetPos[3];
                    ( TraceEx = INVALID_HANDLE );
                    targetPos[0] = 0.0;
                    targetPos[1] = 0.0;
                    targetPos[2] = -4096.0;
                    GetClientAbsOrigin( m_iClient, clientPos );
                                
                    TraceEx = TR_TraceRayFilterEx( clientPos, targetPos, MASK_PLAYERSOLID, RayType_EndPoint, TraceFilterPlayer );
                    if ( TR_DidHit( TraceEx ) ) TR_GetEndPosition( hitPos, TraceEx );
                    if ( GetVectorDistanceMeter( clientPos, hitPos ) <= 0.5 ) Velo[2] = 133.33;
                    else Velo[2] *= 0.32;//FlyWhileShootingFall[m_iWeapon];

                    CloseHandle( TraceEx );
                }
                                
                decl Float:OrigLength[2];
                if ( Cosine( Orig[1] )<0 ) OrigLength[0] = Cosine( Orig[1] ) * ( -1.0 );
                else OrigLength[0] = Cosine( Orig[1] );
                if ( Sine( Orig[1] )<0 ) OrigLength[1] = Sine( Orig[1] ) * ( -1.0 );
                else OrigLength[1] = Sine( Orig[1] );
                        
                decl Float:fVelVector[3];
                fVelVector[2] = 0.0;
                if ( Velo[0]<230.0 && Velo[0]>-230.0 )
                {
                    if ( Velo[0]<5.0 && Velo[0]>-5.0 )
                    {
                        Velo[0] /= 2.64;//FlyWhileShootingForward[m_iWeapon]; - 1.32
                        fVelVector[0] = 0.0;
                    }
                    else {
                        fVelVector[0] = 2.64 * Cosine( Orig[1] );//FlyWhileShootingForward[m_iWeapon];
                        Velo[0] *= 2.64;//FlyWhileShootingForward[m_iWeapon];
                    }
                }
                if ( Velo[1]<230.0 && Velo[1]>-230.0 )
                {
                    if ( Velo[1]<5.0 && Velo[1]>-5.0 )
                    {
                        Velo[1] /= 2.64;//FlyWhileShootingForward[m_iWeapon];
                        fVelVector[1] = 0.0;
                    }
                    else {
                        fVelVector[1] = 2.64 * Sine( Orig[1] );//FlyWhileShootingForward[m_iWeapon];
                        Velo[1] *= 2.64;//FlyWhileShootingForward[m_iWeapon];
                    }
                }
                SetEntPropVector( m_iClient, Prop_Data, "m_vecAbsVelocity", Velo );
                AddVectors( Velo,fVelVector,Velo );
            }
        }
    }

    return m_iButtons;
}

/*new bool:m_bCharging[MAXPLAYERS + 1] = false;*/
ATTRIBUTE_CHARGEDAIRBLAST( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bChargedAirblast_SOUNDONLY_ATTRIBUTE, true ) )
    {
        if ( GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) ) return m_iButtons;

        new Float:m_flAirblastCost = 20.0;
        new Address:m_aAttribute;
        new m_iWeapon = GetPlayerWeaponSlot( m_iClient, TFWeaponSlot_Primary );

        if ( TF2Attrib_GetByName( m_iWeapon, "airblast cost increased" ) ) {
            m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "airblast cost increased" );
            m_flAirblastCost = 20.0 * TF2Attrib_GetValue( m_aAttribute );
        }
        else if ( TF2Attrib_GetByName( m_iWeapon, "airblast cost decreased" ) ) {
            m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "airblast cost decreased" );
            m_flAirblastCost = 20.0 * TF2Attrib_GetValue( m_aAttribute );
        }
        // If I do x *= value, it'll loop and de/increases indefinitly.

        new ammo = GetAmmo( m_iClient, TFWeaponSlot_Primary );
        if ( ammo < m_flAirblastCost ) return m_iButtons;

        static bool:m_bCharging[MAXPLAYERS + 1];

        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( !m_bCharging[m_iClient] ) EmitSoundToClient( m_iClient, SOUND_CHARGE_STICKYBOMB, _, SNDCHAN_WEAPON );
            m_bCharging[m_iClient] = true;
        } else {
            if ( m_bCharging[m_iClient] ) StopSound( m_iClient, SNDCHAN_WEAPON, SOUND_CHARGE_STICKYBOMB );
            m_bCharging[m_iClient] = false;
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DISABLEALT( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDisableAlt_ATTRIBUTE, true ) )
    {
        SetEntPropFloat( TF2_GetClientActiveWeapon( m_iClient ), Prop_Send, "m_flNextSecondaryAttack", GetGameTime()+10.0 );
    }

    return m_iButtons;
}

ATTRIBUTE_DISABLEPRIMARY( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDisablePrimAlt_ATTRIBUTE, true ) )
    {
        SetEntPropFloat( TF2_GetClientActiveWeapon( m_iClient ), Prop_Send, "m_flNextPrimaryAttack", GetGameTime()+10.0 );
    }

    return m_iButtons;
}

ATTRIBUTE_MINIMANN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bMiniMann_ATTRIBUTE ) )
    {
        if ( HasAttribute( m_iClient, _, m_bMiniMann_ATTRIBUTE, true ) && m_iButtons & IN_ATTACK == IN_ATTACK )
        {    
            if ( m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] == INVALID_HANDLE && m_hTimers[m_iClient][m_hMiniMann_TimerDelay] == INVALID_HANDLE && GetEntityFlags( m_iClient ) & FL_ONGROUND )
            {
                m_hTimers[m_iClient][m_hMiniMann_TimerDelay] = CreateTimer( 1.2, m_tMiniMann_Delay, m_iClient );
                m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_flMiniMann_Cooldown, true )+1.2, m_tMiniMann_Cooldown, m_iClient );
                if ( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] );
                else m_hTimers[m_iClient][m_hMiniMann_TimerDuration] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_flMiniMann_Duration, true )+1.2, m_tMiniMann_Duration, m_iClient );
            }
        }
        if ( m_hTimers[m_iClient][m_hMiniMann_TimerDelay] != INVALID_HANDLE )
        {
            if ( !( GetEntityFlags( m_iClient ) & FL_ONGROUND ) || TF2_IsPlayerInCondition( m_iClient, TFCond_Dazed ) )  {
                ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerDelay] );
                if ( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerDuration] );
                if ( m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] );
            }
        }
    }
    return m_iButtons;
}

ATTRIBUTE_BONKHEALTH( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bBonkHealth_ATTRIBUTE ) )
    {
        if ( HasAttribute( m_iClient, _, m_bBonkHealth_ATTRIBUTE, true ) && m_iButtons & IN_ATTACK == IN_ATTACK )
        {    
            if ( m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] == INVALID_HANDLE && m_hTimers[m_iClient][m_hBonkHealth_TimerDelay] == INVALID_HANDLE && GetEntityFlags( m_iClient ) & FL_ONGROUND )
            {
                m_hTimers[m_iClient][m_hBonkHealth_TimerDelay] = CreateTimer( 1.2, m_tBonkHealth_Delay, m_iClient );
                m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bBonkHealth_ATTRIBUTE, m_flBonkHealth_Cooldown, true )+1.2, m_tBonkHealth, m_iClient );
            }
        }
        if ( m_hTimers[m_iClient][m_hBonkHealth_TimerDelay] != INVALID_HANDLE )
        {
            if ( !( GetEntityFlags( m_iClient ) & FL_ONGROUND ) || TF2_IsPlayerInCondition( m_iClient, TFCond_Dazed ) )  {
                ClearTimer( m_hTimers[m_iClient][m_hBonkHealth_TimerDelay] );
                if ( m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] );
            }
        }
    }
    return m_iButtons;
}

ATTRIBUTE_SPEEDCLOAK( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bSpeedCloak_ATTRIBUTE ) )
    {
        new Float:m_flSpeed = GetEntPropFloat( m_iClient, Prop_Send, "m_flMaxspeed" );
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Cloaked ) )
        {
            if ( m_flSpeed > 5.0 )
            {
                new Float:m_flNewSpeed = GetAttributeValueF( m_iClient, _, m_bSpeedCloak_ATTRIBUTE, m_flSpeedCloak_Amount );
                SetEntPropFloat( m_iClient, Prop_Send, "m_flMaxspeed", m_flNewSpeed );
            }
        } else {
            if ( m_flSpeed > 5.0 ) SetEntPropFloat( m_iClient, Prop_Send, "m_flMaxspeed", 300.0 );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DEMOCHARGEUBERCHARGE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDemoCharge_Ubercharge_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Charging ) ) TF2_AddCondition( m_iClient, TFCond_Ubercharged, 0.1 );
    }

    return m_iButtons;
}

ATTRIBUTE_DEMOCHARGINVISIBLE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDemoCharge_Invisibility_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Charging ) ) TF2_AddCondition( m_iClient, TFCond_Stealthed, 0.1 );
    }

    return m_iButtons;
}

ATTRIBUTE_SPEEDFIRE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bSpeedBoostFire_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_OnFire ) ) TF2_AddCondition( m_iClient, TFCond_SpeedBuffAlly, 0.1 );
    }

    return m_iButtons;
}

ATTRIBUTE_RAGEDRAIN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bRageDecrease_ATTRIBUTE ) ) {
        if ( m_hTimers[m_iClient][m_hRageDecrease_TimerDelay] == INVALID_HANDLE && m_bBools[m_iClient][m_bDrainRage] )
        {
            new Float:m_flRage = GetEntPropFloat( m_iClient, Prop_Send, "m_flRageMeter" );
            if ( m_flRage > 0.0 ) SetEntPropFloat( m_iClient, Prop_Send, "m_flRageMeter", m_flRage - GetAttributeValueF( m_iClient, _, m_bRageDecrease_ATTRIBUTE, m_flRageDecrease_Amount ) );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_ELECTROSHOCK( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bElectroshock_ATTRIBUTE ) ) {
        if ( m_flFloats[m_iClient][m_flElectroshockEngine] >= GetEngineTime() - GetAttributeValueF( m_iClient, _, m_bElectroshock_ATTRIBUTE, m_flElectroshock_Duration ) )
        {
            SetWeaponAmmo( m_iClient, 0, 0 );
            SetWeaponAmmo( m_iClient, 1, 0 );
            SetEntityHealth( m_iClient, 1 );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_JUMPBONUS( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bJumpBonus_ATTRIBUTE ) ) {

        if ( m_iIntegers[m_iClient][m_iJumpAmount] < -1 ) m_iIntegers[m_iClient][m_iJumpAmount] = 0;
        if ( m_iIntegers[m_iClient][m_iJumpAmount] > GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_MaxJumps ) ) m_iIntegers[m_iClient][m_iJumpAmount] = GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_MaxJumps );
        if ( m_iIntegers[m_iClient][m_iJumpAmountBase] < 0 ) m_iIntegers[m_iClient][m_iJumpAmountBase] = 0;
        if ( m_iIntegers[m_iClient][m_iJumpAmountBase] > GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps ) ) m_iIntegers[m_iClient][m_iJumpAmountBase] = GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps );

        if ( GetEntityFlags( m_iClient ) & FL_ONGROUND ) m_iIntegers[m_iClient][m_iJumpAmountBase] = GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps );

        static bool:bJumping[MAXPLAYERS+1] = false;
        static bool:bIsInJump[MAXPLAYERS+1] = false;

        if ( m_iButtons & ~IN_JUMP && GetEntityFlags( m_iClient ) & FL_ONGROUND )
        {
            bJumping[m_iClient] = false;
            bIsInJump[m_iClient] = false;
        }

        if ( m_iButtons & IN_JUMP && !( GetEntityFlags( m_iClient ) & FL_ONGROUND ) ) // Thanks Chanz.
        {
            if ( ( m_iIntegers[m_iClient][m_iJumpAmount] <= GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_MaxJumps ) ) && ( m_iIntegers[m_iClient][m_iJumpAmount] > -1 ) && ( m_iIntegers[m_iClient][m_iJumpAmountBase] <= 0 ) )
            {
                if ( !bJumping[m_iClient] )
                {
                    bIsInJump[m_iClient] = true;
                    m_iIntegers[m_iClient][m_iJumpAmount]--;
                }
            }
            else if ( ( m_iIntegers[m_iClient][m_iJumpAmountBase] <= GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps ) ) && ( m_iIntegers[m_iClient][m_iJumpAmountBase] > 0 ) )
            {
                if ( !bJumping[m_iClient] ) m_iIntegers[m_iClient][m_iJumpAmountBase]--;
            }
            bJumping[m_iClient] = true;
        } else {
            bJumping[m_iClient] = false;
            bIsInJump[m_iClient] = false;
        }

        if ( GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps ) == 1 && !( bIsInJump[m_iClient] ) ) SetEntData( m_iClient, m_iDashOffSet, 1 );
        if ( bIsInJump[m_iClient] && m_iIntegers[m_iClient][m_iJumpAmount] > -1 ) SetEntData( m_iClient, m_iDashOffSet, 0 );
        if ( m_iIntegers[m_iClient][m_iJumpAmount] == 0 ) bIsInJump[m_iClient] = false;
    }
    else {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) m_iIntegers[m_iClient][m_iJumpAmount] = 0;
    }

    return m_iButtons;
}

PRETHINK_STACKREMOVER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bMarkVictim_ATTRIBUTE ) ) {
        if ( m_iIntegers[m_iClient][m_iMarkedVictim] < 0 ) m_iIntegers[m_iClient][m_iMarkedVictim] = 0;
    }
    if ( HasAttribute( m_iClient, _, m_bMarkVictimForDeath_ATTRIBUTE ) ) {
        if ( m_iIntegers[m_iClient][m_iMarkedVictimForDeath] < 0 ) m_iIntegers[m_iClient][m_iMarkedVictimForDeath] = 0;
    }

    if ( HasAttribute( m_iClient, _, m_bMiniMann_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Bonked ) ) TF2_RemoveCondition( m_iClient, TFCond_Bonked );
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_CritCola ) ) TF2_RemoveCondition( m_iClient, TFCond_CritCola );
    }
    if ( HasAttribute( m_iClient, _, m_bBonkHealth_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Bonked ) ) TF2_RemoveCondition( m_iClient, TFCond_Bonked );
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_CritCola ) ) TF2_RemoveCondition( m_iClient, TFCond_CritCola );
    }

    return m_iButtons;
}

HUD_SHOWSYNCHUDTEXT( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    new String:m_strHUDElectroshock[42];
    new String:m_strHUDJumpBonus[42];
    new String:m_strHUDLevelUpSystem_DamageDone[42];
    new String:m_strHUDLevelUpSystem_DamageReceived[42];
    new String:m_strHUDMeetThePyro[42];
    new String:m_strHUDMeetTheSniper[42];
    new String:m_strHUDRespawnWhereYouDied[42];

    if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE ) ) {
        new m_iLevel = RoundToFloor( m_flFloats[m_iClient][m_flTakeDamageCharge]/100.0 );
        if ( m_iLevel > 3 ) m_iLevel = 3;
        Format( m_strHUDLevelUpSystem_DamageReceived, sizeof( m_strHUDLevelUpSystem_DamageReceived ), "Upgrade %.0f%% [%i]", m_flFloats[m_iClient][m_flTakeDamageCharge] - ( m_iLevel*100 ), ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 400 ? 1 : 0 )+m_iLevel-( m_flFloats[m_iClient][m_flTakeDamageCharge] < 100 ? 1 : 0 )+( m_iLevel <= 0 ? 1 : 0 ) );

        if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, true ) )
        {
            new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

            if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 200.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_OldAttackSpeed, true ) );
            if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 200.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_AttackSpeed, true ) );
            if ( m_flFloats[m_iClient][m_flTakeDamageCharge] < 300.0 ) TF2Attrib_SetByName( m_iWeapon, "health regen", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_OldHealthRegeneration, true ) );
            if ( m_flFloats[m_iClient][m_flTakeDamageCharge] >= 300.0 ) TF2Attrib_SetByName( m_iWeapon, "health regen", GetAttributeValueF( m_iClient, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_HealthRegeneration, true ) );
        }
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bLevelUpSystem_DamageDone_ATTRIBUTE ) ) {
        new m_iLevel = RoundToFloor( m_flFloats[m_iClient][m_flDamageCharge]/100.0 );
        if ( m_iLevel > 3 ) m_iLevel = 3;
        Format( m_strHUDLevelUpSystem_DamageDone, sizeof( m_strHUDLevelUpSystem_DamageDone ), "Upgrade %.0f%% [%i]", m_flFloats[m_iClient][m_flDamageCharge] - ( m_iLevel*100 ), ( m_flFloats[m_iClient][m_flDamageCharge] >= 400 ? 1 : 0 )+m_iLevel-( m_flFloats[m_iClient][m_flDamageCharge] < 100 ? 1 : 0 )+( m_iLevel <= 0 ? 1 : 0 ) );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bRespawnWhereYouDied_ATTRIBUTE ) ) {
        Format( m_strHUDRespawnWhereYouDied, sizeof( m_strHUDRespawnWhereYouDied ), "Respawn %.0f%%", m_flFloats[m_iClient][m_flRespawn] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bElectroshock_ATTRIBUTE ) ) {
        Format( m_strHUDElectroshock, sizeof( m_strHUDElectroshock ), "Electroshock %.0f%%", m_flFloats[m_iClient][m_flElectroshock] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bJumpBonus_ATTRIBUTE ) )
    {
        /* ** Hacky way to display correct jumps because the Unique Base Jump make the 'last' ( 1/max ) not used, Idk why, but that's not a big deal. ** */
        new BaseJumps = GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_BaseJumps );
        new BaseJumps2 = ( BaseJumps == 1 ? 1 : 0 );
        new Diff = m_iIntegers[m_iClient][m_iJumpAmount] - BaseJumps2;
        if ( Diff < 0 ) Diff = 0;
        //new Jumps;
        //else Jumps = Diff;
        /* ** ! ** */
        new MaxJumps = GetAttributeValueI( m_iClient, _, m_bJumpBonus_ATTRIBUTE, m_iJumpBonus_MaxJumps );
        if ( MaxJumps >= 1024 ) {
            Format( m_strHUDJumpBonus, sizeof( m_strHUDJumpBonus ), "Jumps %i", Diff/*Jumps*/ );
        } else {
            Format( m_strHUDJumpBonus, sizeof( m_strHUDJumpBonus ), "Jumps %i/%i", Diff/*Jumps*/, MaxJumps-BaseJumps2 );
        }
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bSniperCombo_ATTRIBUTE, true ) ) {
        Format( m_strHUDMeetTheSniper, sizeof( m_strHUDMeetTheSniper ), "Combo %i", m_iIntegers[m_iClient][m_iSniperComboHit] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bPyroCombo_ATTRIBUTE, true ) ) {
        Format( m_strHUDMeetThePyro, sizeof( m_strHUDMeetThePyro ), "Combo %i", m_iIntegers[m_iClient][m_iPyroComboHit] );
    }
//-//
    if ( IfDoNextTime2( m_iClient, e_flNextHUDUpdate, 0.1 ) ) // Thanks CHData :D
    {
        ShowSyncHudText( m_iClient, g_hHudText_AW2, "%s \n%s \n%s \n%s \n%s \n%s \n%s", m_strHUDElectroshock,
                                                                                        m_strHUDJumpBonus,
                                                                                        m_strHUDLevelUpSystem_DamageDone,
                                                                                        m_strHUDLevelUpSystem_DamageReceived,
                                                                                        m_strHUDMeetThePyro,
                                                                                        m_strHUDMeetTheSniper,
                                                                                        m_strHUDRespawnWhereYouDied );
    }
    
    return m_iButtons;
}

// ====[ ON ADD ATTRIBUTE ]============================================
public Action:CW3_OnAddAttribute( m_iSlot, m_iClient, const String:m_sAttribute[], const String:m_sPlugin[], const String:m_sValue[], bool:m_bActive )
{
    if ( !StrEqual( m_sPlugin, "moreaw2" ) ) return Plugin_Continue;
    new Action:m_aAction;

    /* Übercharge To Damage
     *
     * ---------------------------------------------------------------------- */
    if ( StrEqual( m_sAttribute, "uber to dmg" ) )
    {
        m_flUberchargeToDamage_Multiplier[m_iClient][m_iSlot]    = StringToFloat( m_sValue );
        m_bUberchargeToDamage_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Enemy Übercharge To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "enemy uber to dmg" ) )
    {
        m_flEnemyUberchargeToDamage_Multiplier[m_iClient][m_iSlot]   = StringToFloat( m_sValue );
        m_bEnemyUberchargeToDamage_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Movement Speed While Cloaked
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "speed while cloaked" ) )
    {
        m_flSpeedCloak_Amount[m_iClient][m_iSlot]            = StringToFloat( m_sValue );
        m_bSpeedCloak_ATTRIBUTE[m_iClient][m_iSlot]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Invisible While Charging DEMOMAN
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "invis while charging demo" ) )
    {
        m_bDemoCharge_Invisibility_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Übercharge While Charging DEMOMAN
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "uber while charging demo" ) )
    {
        m_bDemoCharge_Ubercharge_ATTRIBUTE[m_iClient][m_iSlot]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Mark Victim
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "mark victim" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iMarkVictim_MaximumStack[m_iClient][m_iSlot]       = StringToInt( m_sValues[0] );
        m_flMarkVictim_Duration[m_iClient][m_iSlot]          = StringToFloat( m_sValues[1] );
        m_bMarkVictim_ATTRIBUTE[m_iClient][m_iSlot]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Mark Victim For Death
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "mark victim fd" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iMarkVictimForDeath_MaximumStack[m_iClient][m_iSlot]   = StringToInt( m_sValues[0] );
        m_flMarkVictimForDeath_Duration[m_iClient][m_iSlot]      = StringToFloat( m_sValues[1] );
        m_bMarkVictimForDeath_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Is Explosive
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg is explosive" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flExplosiveDamage_Force[m_iClient][m_iSlot]        = StringToFloat( m_sValues[0] );
        m_flExplosiveDamage_Radius[m_iClient][m_iSlot]       = StringToFloat( m_sValues[1] );
        m_flExplosiveDamage_Damage[m_iClient][m_iSlot]       = StringToFloat( m_sValues[2] );
        m_iExplosiveDamage_DamageMode[m_iClient][m_iSlot]   = StringToInt( m_sValues[3] );
        m_bExplosiveDamage_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical Damage Is Explosive
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit dmg is explosive" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flExplosiveCriticalDamage_Force[m_iClient][m_iSlot]        = StringToFloat( m_sValues[0] );
        m_flExplosiveCriticalDamage_Radius[m_iClient][m_iSlot]       = StringToFloat( m_sValues[1] );
        m_flExplosiveCriticalDamage_Damage[m_iClient][m_iSlot]       = StringToFloat( m_sValues[2] );
        m_iExplosiveCriticalDamage_DamageMode[m_iClient][m_iSlot]   = StringToInt( m_sValues[3] );
        m_bExplosiveCriticalDamage_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Übercharge On Kill
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "uber on kill" ) )
    {
        m_flUberchargeOnKill_Amount[m_iClient][m_iSlot]      = StringToFloat( m_sValue );
        m_bUberchargeOnKill_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Add Condition On Alt-Fire
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "addcond altfire" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flAddCondAltFire_HealthPoints[m_iClient][m_iSlot]  = StringToFloat( m_sValues[0] );
        m_iAddCondAltFire_ID[m_iClient][m_iSlot]             = StringToInt( m_sValues[1] );
        m_flAddCondAltFire_Duration[m_iClient][m_iSlot]      = StringToFloat( m_sValues[2] );
        m_bAddCondAltFire_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Deploy Übercharge
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "deploy uber" ) )
    {
        m_flDeployUbercharge_Threshold[m_iClient][m_iSlot]   = StringToFloat( m_sValue );
        m_bDeployUbercharge_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Weapon Level Up [dealt]
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "weapon lvlup" ) )
    {
        new String:m_sValues[5][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flLevelUpSystem_DamageDone_Charge[m_iClient][m_iSlot]                      = StringToFloat( m_sValues[0] ); // charge
        m_flLevelUpSystem_DamageDone_Lifesteal[m_iClient][m_iSlot]                   = StringToFloat( m_sValues[1] ); // 1
        m_flLevelUpSystem_DamageDone_BonusDamage[m_iClient][m_iSlot]                 = StringToFloat( m_sValues[2] ); // 2
        m_flLevelUpSystem_DamageDone_CriticalChance[m_iClient][m_iSlot]              = StringToFloat( m_sValues[3] ); // 3
        m_flLevelUpSystem_DamageDone_PocketUberchargeDuration[m_iClient][m_iSlot]    = StringToFloat( m_sValues[4] ); // 4
        m_bLevelUpSystem_DamageDone_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Weapon Level Up 2 [receieved]
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "weapon lvlup 2" ) )
    {
        new String:m_sValues[7][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flLevelUpSystem_DamageReceived_Charge[m_iClient][m_iSlot]                      = StringToFloat( m_sValues[0] ); // charge
        m_flLevelUpSystem_DamageReceived_Lifesteal[m_iClient][m_iSlot]                   = StringToFloat( m_sValues[1] ); // 1
        m_flLevelUpSystem_DamageReceived_AttackSpeed[m_iClient][m_iSlot]                 = StringToFloat( m_sValues[2] ); // 2
        m_flLevelUpSystem_DamageReceived_OldAttackSpeed[m_iClient][m_iSlot]              = StringToFloat( m_sValues[3] ); // -
        m_flLevelUpSystem_DamageReceived_HealthRegeneration[m_iClient][m_iSlot]          = StringToFloat( m_sValues[4] ); // 3
        m_flLevelUpSystem_DamageReceived_OldHealthRegeneration[m_iClient][m_iSlot]       = StringToFloat( m_sValues[5] ); // -
        m_flLevelUpSystem_DamageReceived_CriticalDamageResistance[m_iClient][m_iSlot]    = StringToFloat( m_sValues[6] ); // 4
        m_bLevelUpSystem_DamageReceived_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Respawn Where You Died
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "respawn where you died" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flRespawnWhereYouDied_Charge[m_iClient][m_iSlot]   = StringToFloat( m_sValues[0] );
        m_flRespawnWhereYouDied_Delay[m_iClient][m_iSlot]    = StringToFloat( m_sValues[1] );
        m_bRespawnWhereYouDied_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Fly While Shooting
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "fly while shooting" ) )
    {
        m_bFlyWhileShooting_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Mini Mann
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "minimann attr" ) )
    {
        new String:m_sValues[5][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flMiniMann_Resize[m_iClient][m_iSlot]              = StringToFloat( m_sValues[0] );
        m_flMiniMann_Duration[m_iClient][m_iSlot]            = StringToFloat( m_sValues[1] );
        m_flMiniMann_Cooldown[m_iClient][m_iSlot]            = StringToFloat( m_sValues[2] );
        m_iMiniMann_Type[m_iClient][m_iSlot]                 = StringToInt( m_sValues[3] );
        m_iMiniMann_Speed[m_iClient][m_iSlot]                = StringToInt( m_sValues[4] );
        m_bMiniMann_ATTRIBUTE[m_iClient][m_iSlot]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Disable Dlot
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disable slot" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iDisableSlot_Slot[m_iClient][m_iSlot]              = StringToInt( m_sValues[0] );
        m_flDisableSlot_Duration[m_iClient][m_iSlot]         = StringToFloat( m_sValues[1] );
        m_bDisableSlot_ATTRIBUTE[m_iClient][m_iSlot]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Disable Alt-Fire
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disable alt" ) )
    {
        m_bDisableAlt_ATTRIBUTE[m_iClient][m_iSlot]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Jump Bonus On Hit-Kill
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "jump bonus on hitkill" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iJumpBonus_Hit[m_iClient][m_iSlot]         = StringToInt( m_sValues[0] );
        m_iJumpBonus_Kill[m_iClient][m_iSlot]        = StringToInt( m_sValues[1] );
        m_iJumpBonus_MaxJumps[m_iClient][m_iSlot]    = StringToInt( m_sValues[2] );
        m_iJumpBonus_BaseJumps[m_iClient][m_iSlot]   = StringToInt( m_sValues[3] );
        /* ** Hacky way to set correct jumps because the Unique Base Jump make the 'last' ( 1/max ) not used, Idk why, but that's not a big deal. ** */
        if ( m_iJumpBonus_BaseJumps[m_iClient][m_iSlot] == 1 ) m_iJumpBonus_MaxJumps[m_iClient][m_iSlot]++;
        /* ** ! ** */
        m_bJumpBonus_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Bonk Health
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "bonk health" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBonkHealth_Heal[m_iClient][m_iSlot]              = StringToFloat( m_sValues[0] );
        m_flBonkHealth_Cooldown[m_iClient][m_iSlot]          = StringToFloat( m_sValues[1] );
        m_flBonkHealth_OverHealBonusCap[m_iClient][m_iSlot]  = StringToFloat( m_sValues[2] );
        m_bBonkHealth_ATTRIBUTE[m_iClient][m_iSlot]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical On Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit on hp pct" ) )
    {
        m_flCritOnHealthPointsThreshold_Threshold[m_iClient][m_iSlot]    = StringToFloat( m_sValue );
        m_bCritOnHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* MiniCrit While Disguised CLOSE RANGE
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "minicrit while disguised CLOSERANGE" ) )
    {
        m_flMiniCritDisguisedCLOSERANGE_Range[m_iClient][m_iSlot]    = StringToFloat( m_sValue );
        m_bMiniCritDisguisedCLOSERANGE_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical While Disguised CLOSE RANGE
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit while disguised CLOSERANGE" ) )
    {
        m_flCritDisguisedCLOSERANGE_Range[m_iClient][m_iSlot]    = StringToFloat( m_sValue );
        m_bCritDisguisedCLOSERANGE_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Non-Critical Damage Multiplier
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "non crit dmg pct" ) )
    {
        m_flNonCriticalDamageModifier_Multiplier[m_iClient][m_iSlot] = StringToFloat( m_sValue );
        m_bNonCriticalDamageModifier_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Ragemeter Decreases On No-Damage (doesn't mean anything, idc ( ͡° ͜ʖ ͡°))
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "ragemeter decrease nodmg" ) )
    {
        m_flRageDecrease_Amount[m_iClient][m_iSlot]          = StringToFloat( m_sValue );
        m_bRageDecrease_ATTRIBUTE[m_iClient][m_iSlot]        = true;
        m_aAction = Plugin_Handled;
    }
    /* Speed Boost While Burning
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "speed boost on fire" ) )
    {
        m_bSpeedBoostFire_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Disorientate On Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disorientate on hit" ) )
    {
        m_bDisorientateOnHit_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* No Backstab
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "no backstab" ) )
    {
        m_flNoBackstab_Damage[m_iClient][m_iSlot]   = StringToFloat( m_sValue );
        m_bNoBackstab_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Charged Airblast SOUNDONLY
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "charged airblast SOUNDONLY" ) )
    {
        m_bChargedAirblast_SOUNDONLY_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Meet The Sniper Combo
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "meet the sniper combo" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flSniperCombo_DMGA[m_iClient][m_iSlot]     = StringToFloat( m_sValues[0] );
        m_flSniperCombo_DMGB[m_iClient][m_iSlot]     = StringToFloat( m_sValues[1] );
        m_flSniperCombo_DMGC[m_iClient][m_iSlot]     = StringToFloat( m_sValues[2] );
        m_bSniperCombo_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Meet The Pyro Combo
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "meet the pyro combo" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flPyroCombo_DMGA[m_iClient][m_iSlot]       = StringToFloat( m_sValues[0] );
        m_flPyroCombo_DMGB[m_iClient][m_iSlot]       = StringToFloat( m_sValues[1] );
        m_flPyroCombo_DMGC[m_iClient][m_iSlot]       = StringToFloat( m_sValues[2] );
        m_bPyroCombo_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Increased Pushscale
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "increased pushscale" ) )
    {
        m_flIncreasedPushScale_Scale[m_iClient][m_iSlot]     = StringToFloat( m_sValue );
        m_bIncreasedPushScale_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Disarm Silent
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disarm silent" ) )
    {
        m_flDisarmSilent_Duration[m_iClient][m_iSlot] = StringToFloat( m_sValue );
        m_bDisarmSilent_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Miss Causes Delay
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "miss cause delay" ) )
    {
        m_flMissCauseDelay_Delay[m_iClient][m_iSlot]     = StringToFloat( m_sValue );
        m_bMissCauseDelay_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Electroshock
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "electroshock" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flElectroshock_Charge[m_iClient][m_iSlot]      = StringToFloat( m_sValues[0] );
        m_flElectroshock_Duration[m_iClient][m_iSlot]    = StringToFloat( m_sValues[1] );
        m_bElectroshock_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical Hit On Healing Medic
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit healing medic" ) )
    {
        m_bCritHealingMedic_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Democharge On Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "democharge on hit" ) ) // Volvo did it, BUT, I'm pretty sure it doesn't support 'minus' values, just like add uber on hit.
    {
        m_flDemoChargeOnHit_Charge[m_iClient][m_iSlot]   = StringToFloat( m_sValue );
        m_bDemoChargeOnHit_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Piss Yourself On Miss
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "piss yourself on miss" ) )
    {
        m_bPissYourselfOnMiss_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Disable Primary
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disable primary" ) )
    {
        m_bDisablePrimAlt_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal Shield
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal shield" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flMetalShield_DamageAbsorb[m_iClient][m_iSlot]         = StringToFloat( m_sValues[0] );
        m_flMetalShield_DamageAbsorbMetalPct[m_iClient][m_iSlot] = StringToFloat( m_sValues[1] );
        m_bMetalShield_ATTRIBUTE[m_iClient][m_iSlot]             = true;
        m_aAction = Plugin_Handled;
    }

    // Meh.
    if ( !m_bHasAttribute[m_iClient][m_iSlot] ) m_bHasAttribute[m_iClient][m_iSlot] = bool:m_aAction;
    return m_aAction;
}
// ====[ ON WEAPON REMOVED ]===========================================
public CW3_OnWeaponRemoved( m_iSlot, m_iClient )
{
    if ( IsValidClient( m_iClient ) )
    {
        if ( m_bHasAttribute[m_iClient][m_iSlot] )
        {
            m_bHasAttribute[m_iClient][m_iSlot] = false;


            /* On Hit
             * ---------------------------------------------------------------------- */

            m_bMarkVictim_ATTRIBUTE[m_iClient][m_iSlot]              = false;
            m_flMarkVictim_Duration[m_iClient][m_iSlot]              = 0.0;
            m_iMarkVictim_MaximumStack[m_iClient][m_iSlot]           = 0;

            m_bMarkVictimForDeath_ATTRIBUTE[m_iClient][m_iSlot]      = false;
            m_flMarkVictimForDeath_Duration[m_iClient][m_iSlot]      = 0.0;
            m_iMarkVictimForDeath_MaximumStack[m_iClient][m_iSlot]   = 0;

            m_bDisableSlot_ATTRIBUTE[m_iClient][m_iSlot]             = false;
            m_flDisableSlot_Duration[m_iClient][m_iSlot]             = 0.0;
            m_iDisableSlot_Slot[m_iClient][m_iSlot]                  = 0;

            m_bDisarmSilent_ATTRIBUTE[m_iClient][m_iSlot]            = false;
            m_flDisarmSilent_Duration[m_iClient][m_iSlot]            = 0.0;

            m_bIncreasedPushScale_ATTRIBUTE[m_iClient][m_iSlot]      = false;
            m_flIncreasedPushScale_Scale[m_iClient][m_iSlot]         = 0.0;

            m_bCritHealingMedic_ATTRIBUTE[m_iClient][m_iSlot]        = false;

            m_bDemoChargeOnHit_ATTRIBUTE[m_iClient][m_iSlot]         = false;
            m_flDemoChargeOnHit_Charge[m_iClient][m_iSlot]           = 0.0;


            /* On Crit
             * ---------------------------------------------------------------------- */

            m_bMiniCritDisguisedCLOSERANGE_ATTRIBUTE[m_iClient][m_iSlot] = false;
            m_flMiniCritDisguisedCLOSERANGE_Range[m_iClient][m_iSlot]    = 0.0;

            m_bCritDisguisedCLOSERANGE_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flCritDisguisedCLOSERANGE_Range[m_iClient][m_iSlot]        = 0.0;


            /* On Attack
             * ---------------------------------------------------------------------- */

            m_bSniperCombo_ATTRIBUTE[m_iClient][m_iSlot]         = false;
            m_flSniperCombo_DMGA[m_iClient][m_iSlot]             = 0.0;
            m_flSniperCombo_DMGB[m_iClient][m_iSlot]             = 0.0;
            m_flSniperCombo_DMGC[m_iClient][m_iSlot]             = 0.0;

            m_bPyroCombo_ATTRIBUTE[m_iClient][m_iSlot]           = false;
            m_flPyroCombo_DMGA[m_iClient][m_iSlot]               = 0.0;
            m_flPyroCombo_DMGB[m_iClient][m_iSlot]               = 0.0;
            m_flPyroCombo_DMGC[m_iClient][m_iSlot]               = 0.0;

            m_bPissYourselfOnMiss_ATTRIBUTE[m_iClient][m_iSlot]  = false;

            m_bMissCauseDelay_ATTRIBUTE[m_iClient][m_iSlot]      = false;
            m_flMissCauseDelay_Delay[m_iClient][m_iSlot]         = 0.0;


            /* On Kill
             * ---------------------------------------------------------------------- */

            m_bUberchargeOnKill_ATTRIBUTE[m_iClient][m_iSlot]    = false;
            m_flUberchargeOnKill_Amount[m_iClient][m_iSlot]      = 0.0;


            /* On Damage
             * ---------------------------------------------------------------------- */

            m_bUberchargeToDamage_ATTRIBUTE[m_iClient][m_iSlot]                          = false;
            m_flUberchargeToDamage_Multiplier[m_iClient][m_iSlot]                        = 0.0;

            m_bEnemyUberchargeToDamage_ATTRIBUTE[m_iClient][m_iSlot]                     = false;
            m_flEnemyUberchargeToDamage_Multiplier[m_iClient][m_iSlot]                   = 0.0;

            m_bExplosiveDamage_ATTRIBUTE[m_iClient][m_iSlot]                             = false;
            m_flExplosiveDamage_Damage[m_iClient][m_iSlot]                               = 0.0;
            m_flExplosiveDamage_Force[m_iClient][m_iSlot]                                = 0.0;
            m_flExplosiveDamage_Radius[m_iClient][m_iSlot]                               = 0.0;
            m_iExplosiveDamage_DamageMode[m_iClient][m_iSlot]                            = 0;

            m_bExplosiveCriticalDamage_ATTRIBUTE[m_iClient][m_iSlot]                     = false;
            m_flExplosiveCriticalDamage_Damage[m_iClient][m_iSlot]                       = 0.0;
            m_flExplosiveCriticalDamage_Force[m_iClient][m_iSlot]                        = 0.0;
            m_flExplosiveCriticalDamage_Radius[m_iClient][m_iSlot]                       = 0.0;
            m_iExplosiveCriticalDamage_DamageMode[m_iClient][m_iSlot]                    = 0;

            m_bLevelUpSystem_DamageDone_ATTRIBUTE[m_iClient][m_iSlot]                    = false;
            m_flLevelUpSystem_DamageDone_BonusDamage[m_iClient][m_iSlot]                 = 0.0;
            m_flLevelUpSystem_DamageDone_Charge[m_iClient][m_iSlot]                      = 0.0;
            m_flLevelUpSystem_DamageDone_CriticalChance[m_iClient][m_iSlot]              = 0.0;
            m_flLevelUpSystem_DamageDone_Lifesteal[m_iClient][m_iSlot]                   = 0.0;
            m_flLevelUpSystem_DamageDone_PocketUberchargeDuration[m_iClient][m_iSlot]    = 0.0;

            m_bNonCriticalDamageModifier_ATTRIBUTE[m_iClient][m_iSlot]                   = false;
            m_flNonCriticalDamageModifier_Multiplier[m_iClient][m_iSlot]                 = 0.0;

            m_bFlyWhileShooting_ATTRIBUTE[m_iClient][m_iSlot]                            = false;

            m_bDisorientateOnHit_ATTRIBUTE[m_iClient][m_iSlot]                           = false;

            m_bNoBackstab_ATTRIBUTE[m_iClient][m_iSlot]                                  = false;
            m_flNoBackstab_Damage[m_iClient][m_iSlot]                                    = 0.0;

            m_bElectroshock_ATTRIBUTE[m_iClient][m_iSlot]                                = false;
            m_flElectroshock_Charge[m_iClient][m_iSlot]                                  = 0.0;
            m_flElectroshock_Duration[m_iClient][m_iSlot]                                = 0.0;


            /* On Prethink
             * ---------------------------------------------------------------------- */

            m_bSpeedCloak_ATTRIBUTE[m_iClient][m_iSlot]                      = false;
            m_flSpeedCloak_Amount[m_iClient][m_iSlot]                        = 0.0;

            m_bDemoCharge_Ubercharge_ATTRIBUTE[m_iClient][m_iSlot]           = false;

            m_bDemoCharge_Invisibility_ATTRIBUTE[m_iClient][m_iSlot]         = false;

            m_bCritOnHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flCritOnHealthPointsThreshold_Threshold[m_iClient][m_iSlot]    = 0.0;

            m_bSpeedBoostFire_ATTRIBUTE[m_iClient][m_iSlot]                  = false;

            m_bRageDecrease_ATTRIBUTE[m_iClient][m_iSlot]                    = false;
            m_flRageDecrease_Amount[m_iClient][m_iSlot]                      = 0.0;

            m_bDisableAlt_ATTRIBUTE[m_iClient][m_iSlot]                      = false;

            m_bDisablePrimAlt_ATTRIBUTE[m_iClient][m_iSlot]                  = false;

            m_bJumpBonus_ATTRIBUTE[m_iClient][m_iSlot]                       = false;
            m_iJumpBonus_BaseJumps[m_iClient][m_iSlot]                       = 0;
            m_iJumpBonus_Hit[m_iClient][m_iSlot]                             = 0;
            m_iJumpBonus_Kill[m_iClient][m_iSlot]                            = 0;
            m_iJumpBonus_MaxJumps[m_iClient][m_iSlot]                        = 0;

            m_bChargedAirblast_SOUNDONLY_ATTRIBUTE[m_iClient][m_iSlot]       = false;


            /* On Damage Received
             * ---------------------------------------------------------------------- */

            m_bLevelUpSystem_DamageReceived_ATTRIBUTE[m_iClient][m_iSlot]                    = false;
            m_flLevelUpSystem_DamageReceived_AttackSpeed[m_iClient][m_iSlot]                 = 0.0;
            m_flLevelUpSystem_DamageReceived_Charge[m_iClient][m_iSlot]                      = 0.0;
            m_flLevelUpSystem_DamageReceived_CriticalDamageResistance[m_iClient][m_iSlot]    = 0.0;
            m_flLevelUpSystem_DamageReceived_HealthRegeneration[m_iClient][m_iSlot]          = 0.0;
            m_flLevelUpSystem_DamageReceived_Lifesteal[m_iClient][m_iSlot]                   = 0.0;
            m_flLevelUpSystem_DamageReceived_OldAttackSpeed[m_iClient][m_iSlot]              = 0.0;
            m_flLevelUpSystem_DamageReceived_OldHealthRegeneration[m_iClient][m_iSlot]       = 0.0;

            m_bMetalShield_ATTRIBUTE[m_iClient][m_iSlot]                                     = false;
            m_flMetalShield_DamageAbsorb[m_iClient][m_iSlot]                                 = 0.0;
            m_flMetalShield_DamageAbsorbMetalPct[m_iClient][m_iSlot]                         = 0.0;


            /* To Activate
             * ---------------------------------------------------------------------- */

            m_bAddCondAltFire_ATTRIBUTE[m_iClient][m_iSlot]      = false;
            m_flAddCondAltFire_Duration[m_iClient][m_iSlot]      = 0.0;
            m_flAddCondAltFire_HealthPoints[m_iClient][m_iSlot]  = 0.0;
            m_iAddCondAltFire_ID[m_iClient][m_iSlot]             = 0;

            m_bMiniMann_ATTRIBUTE[m_iClient][m_iSlot]            = false;
            m_flMiniMann_Cooldown[m_iClient][m_iSlot]            = 0.0;
            m_flMiniMann_Duration[m_iClient][m_iSlot]            = 0.0;
            m_flMiniMann_Resize[m_iClient][m_iSlot]              = 0.0;
            m_iMiniMann_Speed[m_iClient][m_iSlot]                = 0;
            m_iMiniMann_Type[m_iClient][m_iSlot]                 = 0;

            m_bDeployUbercharge_ATTRIBUTE[m_iClient][m_iSlot]    = false;
            m_flDeployUbercharge_Threshold[m_iClient][m_iSlot]   = 0.0;

            m_bBonkHealth_ATTRIBUTE[m_iClient][m_iSlot]          = false;
            m_flBonkHealth_Cooldown[m_iClient][m_iSlot]          = 0.0;
            m_flBonkHealth_Heal[m_iClient][m_iSlot]              = 0.0;
            m_flBonkHealth_OverHealBonusCap[m_iClient][m_iSlot]  = 0.0;


            /* On Death
             * ---------------------------------------------------------------------- */

            m_bRespawnWhereYouDied_ATTRIBUTE[m_iClient][m_iSlot] = false;
            m_flRespawnWhereYouDied_Charge[m_iClient][m_iSlot]   = 0.0;
            m_flRespawnWhereYouDied_Delay[m_iClient][m_iSlot]    = 0.0;
        }
    }
}

// ====[ ON TAKE DAMAGE ]==============================================
public Action:OnTakeDamage( m_iVictim, &m_iAttacker, &m_iInflictor, &Float:m_flDamage, &m_iType, &m_iWeapon, Float:m_flForce[3], Float:m_flPosition[3], m_iCustom )
{
    new Action:m_aAction;

    if ( m_flDamage >= 1.0
        && IsValidClient( m_iAttacker ) )
    {
        new m_iSlot = TF2_GetWeaponSlot( m_iAttacker, m_iWeapon, m_iInflictor );

        if ( IsValidClient( m_iVictim )
            && !HasInvulnerabilityCond( m_iVictim )
            && m_iAttacker != m_iVictim )
        {
            if ( HasAttribute( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, true ) && m_flFloats[m_iVictim][m_flTakeDamageCharge] >= 400.0 && GetAttributeValueF( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_CriticalDamageResistance, true ) == 0.0 ) {
                if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) )
                    m_flDamage = 0.0;
            }

            if ( m_flDamage >= 1.0 )
            {
                if ( HasAttribute( m_iVictim, _, m_bElectroshock_ATTRIBUTE ) )
                {
                    if ( m_flFloats[m_iVictim][m_flElectroshock] >= 100.0 )
                    {
                        if ( TF2_DamageWillKill( m_iVictim, m_flDamage, true ) )
                        {
                            EmitSoundToAll( SOUND_VO_HEAVY_I_LIVE, m_iVictim, _, SNDLEVEL_SCREAMING );
                            EmitSoundToClient( m_iVictim, SOUND_UBER, _, _, SNDLEVEL_SCREAMING );
                            TF2_AddCondition( m_iVictim, TFCond_Ubercharged, GetAttributeValueF( m_iVictim, _, m_bElectroshock_ATTRIBUTE, m_flElectroshock_Duration ) );
                            SetWeaponAmmo( m_iVictim, 0, 0 );
                            SetWeaponAmmo( m_iVictim, 1, 0 );
                            TF2_SetClientSlot( m_iVictim, 2 );
                                
                            m_flDamage = 0.0;
                            SetEntityHealth( m_iVictim, 1 );
                            m_flFloats[m_iVictim][m_flElectroshock] = 0.0;
                                
                            m_flFloats[m_iVictim][m_flElectroshockEngine] = GetEngineTime();
                                
                            decl Float:m_flAngles[3], Float:m_flVelocity[3], Float:m_flOrigin[3];
                            GetClientEyePosition( m_iVictim, m_flOrigin );
                            GetClientEyeAngles( m_iVictim, m_flAngles );
                            AnglesToVelocity( m_flAngles, m_flVelocity, 250.0 );
                                
                            AttachParticle( m_iVictim, PARTICLE_ZEUS, 1.5, m_flOrigin );
                                
                            m_flOrigin[0] += 10.0;
                            m_flOrigin[1] += 5.0;
                            m_flOrigin[2] += 5.0;
                                
                            AttachParticle( m_iVictim, PARTICLE_ZEUS, 1.5, m_flOrigin );
                                
                            m_flOrigin[0] -= 15.0;
                            m_flOrigin[1] -= 10.0;
                            m_flOrigin[2] -= 10.0;
                                
                            AttachParticle( m_iVictim, PARTICLE_ZEUS, 1.5, m_flOrigin );
                        }
                    }
                }

                if ( m_flDamage >= 1.0 && m_iWeapon != -1 )
                {
                    g_iLastWeapon[m_iAttacker] = m_iWeapon;
                    if ( m_bHasAttribute[m_iAttacker][m_iSlot] )
                    {

                        /* Mutiplies and Divides.
                         *
                         * -------------------------------------------------- */
                        if ( m_bExplosiveDamage_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            new particle = CreateEntityByName( "info_particle_system" );
                            if ( IsValidEntity( particle ) )
                            {
                                TeleportEntity( particle, m_flPosition, NULL_VECTOR, NULL_VECTOR );
                                DispatchKeyValue( particle, "effect_name", "ExplosionCore_MidAir" );
                                DispatchSpawn( particle );
                                ActivateEntity( particle );
                                AcceptEntityInput( particle, "start" );
                                SetVariantString( "OnUser1 !self:Kill::8:-1" );
                                AcceptEntityInput( particle, "AddOutput" );
                                AcceptEntityInput( particle, "FireUser1" );
                                
                                if ( m_flFloats[m_iAttacker][m_flExplosionSound] < GetEngineTime() - 0.1 )
                                {
                                    new m_iRandom = GetRandomInt( 0, sizeof( g_strSoundExplosionBox )-1 );
                                    EmitSoundFromOrigin( g_strSoundExplosionBox[m_iRandom], m_flPosition );
                                    m_flFloats[m_iAttacker][m_flExplosionSound] = GetEngineTime();
                                }
                            }

                            NormalizeVector( m_flForce, m_flForce );
                            if ( m_flForce[2] < 0.2 ) m_flForce[2] = 0.2;
                            
                            new Float:fScale = m_flDamage * m_flExplosiveDamage_Force[m_iAttacker][m_iSlot];
                            if ( fScale < 100.0 ) fScale = 100.0;
                            if ( fScale > 600.0 ) fScale = 600.0;
                            ScaleVector( m_flForce, fScale );
                            if ( m_flForce[2] < 320.0 && m_flDamage >= 10.0 ) m_flForce[2] = 320.0;
                            
                            decl Float:vClientVelocity[3];
                            GetVelocity( m_iVictim, vClientVelocity );
                            AddVectors( vClientVelocity, m_flForce, vClientVelocity );
                            TeleportEntity( m_iVictim, NULL_VECTOR, NULL_VECTOR, vClientVelocity );

                            new Float:flPos1[3];
                            GetClientEyePosition( m_iVictim, flPos1 );
                            flPos1[2] -= 30.0;

                            for ( new i = 1; i <= MaxClients; i++ )
                            {
                                if ( i != m_iAttacker && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iAttacker ) )
                                {
                                    if ( !HasInvulnerabilityCond( i ) )
                                    {
                                        new Float:flPos2[3];
                                        GetClientEyePosition( i, flPos2 );
                                        flPos2[2] -= 30.0;
                                        
                                        new Float:distance = GetVectorDistance( flPos1, flPos2 );
                                        if ( distance <= m_flExplosiveDamage_Radius[m_iAttacker][m_iSlot] )
                                        {
                                            decl Handle:m_hSee;
                                            ( m_hSee = INVALID_HANDLE );

                                            m_hSee = TR_TraceRayFilterEx( flPos1, flPos2, MASK_SOLID, RayType_EndPoint, TraceFilterPlayer, m_iVictim );
                                            if ( m_hSee != INVALID_HANDLE )
                                            {
                                                if ( !TR_DidHit( m_hSee ) )
                                                {
                                                    // Limit the minimum damage to 50%
                                                    // Begin the reduction at 73.0 HU.
                                                    new Float:dmg_reduction = 1.0;
                                                    if ( distance > 73.0 )
                                                        dmg_reduction = ( m_flDamage * ( m_flExplosiveDamage_Radius[m_iAttacker][m_iSlot] - ( ( distance - 73.0 ) * 0.5 ) ) / m_flExplosiveDamage_Radius[m_iAttacker][m_iSlot] ) / m_flDamage;

                                                    DealDamage( i, RoundToFloor( ( ( m_iExplosiveDamage_DamageMode[m_iAttacker][m_iSlot] == 1 ? m_flDamage : 1.0 ) * m_flExplosiveDamage_Damage[m_iAttacker][m_iSlot] ) * dmg_reduction ), m_iAttacker, ( m_iType & TF_DMG_CRIT ? TF_DMG_ALWAYSGIB|TF_DMG_BLAST|TF_DMG_CRIT|m_iType : TF_DMG_ALWAYSGIB|TF_DMG_BLAST|m_iType ), "pumpkindeath" );
                                                }
                                            }

                                            CloseHandle( m_hSee );
                                        }
                                    }
                                }
                            }
                        }
                    //-//
                        if ( m_bLevelUpSystem_DamageDone_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( m_flFloats[m_iAttacker][m_flDamageCharge] >= 200.0 ) m_flDamage *= m_flLevelUpSystem_DamageDone_BonusDamage[m_iAttacker][m_iSlot];
                            if ( m_flFloats[m_iAttacker][m_flDamageCharge] >= 300.0 ) {
                                if ( m_flLevelUpSystem_DamageDone_CriticalChance[m_iAttacker][m_iSlot] > GetRandomFloat( 0.0, 1.0 ) ) m_iType = TF_DMG_CRIT|m_iType;
                            }
                        }
                    //-//
                        if ( m_bNonCriticalDamageModifier_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( !( m_iType & TF_DMG_CRIT ) && !IsCritBoosted( m_iAttacker ) ) m_flDamage *= m_flNonCriticalDamageModifier_Multiplier[m_iAttacker][m_iSlot];
                        }
                    //-//
                        if ( m_bSniperCombo_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            m_bBools[m_iAttacker][m_bSniperCombo] = true;
                            m_iIntegers[m_iAttacker][m_iSniperComboHit]++;

                            decl String:m_strSound[PLATFORM_MAX_PATH];

                            if ( m_iIntegers[m_iAttacker][m_iSniperComboHit] <= 1 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_A );
                                m_flDamage *= m_flSniperCombo_DMGA[m_iAttacker][m_iSlot]; //0.35
                            }
                            else if ( m_iIntegers[m_iAttacker][m_iSniperComboHit] == 2 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_B );
                                m_flDamage *= m_flSniperCombo_DMGB[m_iAttacker][m_iSlot]; //0.6
                            }
                            else if ( m_iIntegers[m_iAttacker][m_iSniperComboHit] >= 3 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_C );
                                m_iType = TF_DMG_CRIT|m_iType;
                                m_flDamage *= m_flSniperCombo_DMGC[m_iAttacker][m_iSlot]; //3
                                m_iIntegers[m_iAttacker][m_iSniperComboHit] = 0;
                            }
                            if ( TF2_ShouldReveal( m_iVictim ) ) EmitSoundToClient( m_iAttacker, m_strSound );
                        }
                    //-//
                        if ( m_bPyroCombo_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            m_bBools[m_iAttacker][m_bPyroCombo] = true;
                            m_iIntegers[m_iAttacker][m_iPyroComboHit]++;

                            decl String:m_strSound[PLATFORM_MAX_PATH];

                            if ( m_iIntegers[m_iAttacker][m_iPyroComboHit] <= 1 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_A );
                                m_flDamage *= m_flPyroCombo_DMGA[m_iAttacker][m_iSlot];
                            }
                            else if ( m_iIntegers[m_iAttacker][m_iPyroComboHit] == 2 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_B );
                                m_flDamage *= m_flPyroCombo_DMGB[m_iAttacker][m_iSlot];
                            }
                            else if ( m_iIntegers[m_iAttacker][m_iPyroComboHit] >= 3 ) {
                                Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_C );
                                TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                                if ( TF2_GetPlayerClass( m_iVictim ) != TFClass_Pyro ) TF2_IgnitePlayer( m_iVictim, m_iAttacker );
                                m_iIntegers[m_iAttacker][m_iPyroComboHit] = 0;
                            }
                            if ( TF2_ShouldReveal( m_iVictim ) ) EmitSoundToClient( m_iAttacker, m_strSound );
                        }
                                
                        /* Adds and Subtracts.
                         *
                         * -------------------------------------------------- */
                        if ( m_bUberchargeToDamage_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            new Float:m_flUbercharge = TF2_GetClientUberLevel( m_iAttacker ) * m_flUberchargeToDamage_Multiplier[m_iAttacker][m_iSlot];
                            m_flDamage += m_flUbercharge;
                        }
                    //-//
                        if ( m_bEnemyUberchargeToDamage_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            new Float:m_flEnemyUbercharge = TF2_GetClientUberLevel( m_iVictim ) * m_flEnemyUberchargeToDamage_Multiplier[m_iAttacker][m_iSlot];
                            m_flDamage += m_flEnemyUbercharge;
                        }

                        /* Sets.
                         *
                         * -------------------------------------------------- */
                        if ( m_bNoBackstab_ATTRIBUTE[m_iAttacker][m_iSlot] && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Spy && m_iCustom == TF_CUSTOM_BACKSTAB )
                        {
                            m_iType = TF_DMG_MELEE;
                            m_flDamage = m_flNoBackstab_Damage[m_iAttacker][m_iSlot];
                        }

                        /* Critical.
                         *
                         * -------------------------------------------------- */
                        if ( m_bCritOnHealthPointsThreshold_ATTRIBUTE[m_iAttacker][m_iSlot] && !( m_iType & TF_DMG_CRIT ) ) {
                            if ( GetClientHealth( m_iAttacker ) <= m_flCritOnHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] * TF2_GetClientMaxHealth( m_iAttacker ) ) m_iType = TF_DMG_CRIT|m_iType;
                        }
                    //-//
                        if ( m_bMiniCritDisguisedCLOSERANGE_ATTRIBUTE[m_iAttacker][m_iSlot] && !( m_iType & TF_DMG_CRIT ) && TF2_IsPlayerInCondition( m_iAttacker, TFCond_Disguised ) && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Spy )
                        {
                            new Float:flPos1[3], Float:flPos2[3];
                            GetClientAbsOrigin( m_iAttacker, flPos1 );
                            GetClientAbsOrigin( m_iVictim, flPos2 );
                                                
                            new Float:distance = GetVectorDistance( flPos1, flPos2 );
                            if ( distance < m_flMiniCritDisguisedCLOSERANGE_Range[m_iAttacker][m_iSlot] )  TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                        }
                    //-//
                        if ( m_bCritDisguisedCLOSERANGE_ATTRIBUTE[m_iAttacker][m_iSlot] && !( m_iType & TF_DMG_CRIT ) && TF2_IsPlayerInCondition( m_iAttacker, TFCond_Disguised ) && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Spy )
                        {
                            new Float:flPos1[3], Float:flPos2[3];
                            GetClientAbsOrigin( m_iAttacker, flPos1 );
                            GetClientAbsOrigin( m_iVictim, flPos2 );
                                                
                            new Float:distance = GetVectorDistance( flPos1, flPos2 );
                            if ( distance < m_flCritDisguisedCLOSERANGE_Range[m_iAttacker][m_iSlot] ) m_iType = TF_DMG_CRIT|m_iType;
                        }
                    //-//
                        if ( m_bCritHealingMedic_ATTRIBUTE[m_iAttacker][m_iSlot] && !( m_iType & TF_DMG_CRIT ) ) {
                            if ( IsValidClient( TF2_GetHealingTarget( m_iVictim ) ) ) m_iType = TF_DMG_CRIT|m_iType;
                        }
                    }
                }

                if ( HasAttribute( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, true ) && m_flFloats[m_iVictim][m_flTakeDamageCharge] >= 400.0 ) {
                    if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) ) m_flDamage *= GetAttributeValueF( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_CriticalDamageResistance );
                }
                if ( HasAttribute( m_iVictim, _, m_bMetalShield_ATTRIBUTE ) )
                {
                    new metal = TF2_GetClientMetal( m_iVictim );

                    if ( metal > 0 )
                    {
                        new Float:metal_lost = m_flDamage * GetAttributeValueF( m_iVictim, _, m_bMetalShield_ATTRIBUTE, m_flMetalShield_DamageAbsorb ) * GetAttributeValueF( m_iVictim, _, m_bMetalShield_ATTRIBUTE, m_flMetalShield_DamageAbsorbMetalPct );
                        m_flDamage *= ( 1 - GetAttributeValueF( m_iVictim, _, m_bMetalShield_ATTRIBUTE, m_flMetalShield_DamageAbsorb ) );
                        if ( metal_lost > metal ) m_flDamage += ( ( metal_lost / GetAttributeValueF( m_iVictim, _, m_bMetalShield_ATTRIBUTE, m_flMetalShield_DamageAbsorbMetalPct ) ) - metal );

                        TF2_SetClientMetal( m_iVictim, RoundToFloor( metal - metal_lost ) );
                        metal = TF2_GetClientMetal( m_iVictim );
                        if ( metal <= 0 ) EmitSoundToClient( m_iVictim, SOUND_SHIELD_BREAK );
                    }
                }
            }
        }
    }
    if ( m_flDamage < 0.0 ) m_flDamage = 0.0;

    m_aAction = Plugin_Changed;
    return m_aAction;
}

// ====[ ON TAKE DAMAGE ALIVE ]========================================
public Action:OnTakeDamageAlive( m_iVictim, &m_iAttacker, &m_iInflictor, &Float:m_flDamage, &m_iType, &m_iWeapon, Float:m_flForce[3], Float:m_flPosition[3], m_iCustom )
{
    new Action:m_aAction;

    if ( m_flDamage >= 1.0
        && IsValidClient( m_iAttacker ) )
    {
        new m_iSlot = TF2_GetWeaponSlot( m_iAttacker, m_iWeapon, m_iInflictor );

        if ( IsValidClient( m_iVictim )
            && !HasInvulnerabilityCond( m_iVictim ) )
        {
            if ( m_iVictim != m_iAttacker )
            {
                if ( HasAttribute( m_iVictim, _, m_bMiniMann_ATTRIBUTE ) && m_hTimers[m_iVictim][m_hMiniMann_TimerDuration] != INVALID_HANDLE )
                {
                    if ( GetAttributeValueI( m_iVictim, _, m_bMiniMann_ATTRIBUTE, m_iMiniMann_Type ) == 2 ) TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                    else {
                        if ( m_iType & TF_DMG_BLAST || m_iType & TF_DMG_FIRE || m_iType & TF_DMG_AFTERBURN ) TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                    }
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, true ) )
                {
                    new Float:m_flValue;
                    m_flValue = m_flDamage * GetAttributeValueF( m_iVictim, _, m_bLevelUpSystem_DamageReceived_ATTRIBUTE, m_flLevelUpSystem_DamageReceived_Charge ) * 0.01;

                    if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] < 100.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] += m_flValue;
                    else if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] < 200.0 && m_flFloats[m_iVictim][m_flTakeDamageCharge] >= 100.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] += ( m_flValue / 1.5 );
                    else if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] < 300.0 && m_flFloats[m_iVictim][m_flTakeDamageCharge] >= 200.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] += ( m_flValue / 2.25 );
                    else if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] < 400.0 && m_flFloats[m_iVictim][m_flTakeDamageCharge] >= 300.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] += ( m_flValue / 3.0 );

                    if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] < 0.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] = 0.0;
                    if ( m_flFloats[m_iVictim][m_flTakeDamageCharge] > 400.0 ) m_flFloats[m_iVictim][m_flTakeDamageCharge] = 400.0;
                }
            //-//
                if ( HasAttribute( m_iAttacker, _, m_bRespawnWhereYouDied_ATTRIBUTE ) )
                {
                    new Float:m_flCharge = m_flDamage * GetAttributeValueF( m_iAttacker, _, m_bRespawnWhereYouDied_ATTRIBUTE, m_flRespawnWhereYouDied_Charge ) * 0.01;
                    m_flFloats[m_iAttacker][m_flRespawn] += m_flCharge;

                    if ( m_flFloats[m_iAttacker][m_flRespawn] > 100.0 ) m_flFloats[m_iAttacker][m_flRespawn] = 100.0;
                    if ( m_flFloats[m_iAttacker][m_flRespawn] < 0.0 ) m_flFloats[m_iAttacker][m_flRespawn] = 0.0;
                }
            //-//
                if ( HasAttribute( m_iAttacker, _, m_bElectroshock_ATTRIBUTE ) )
                {
                    new Float:m_flValue = m_flDamage * GetAttributeValueF( m_iAttacker, _, m_bElectroshock_ATTRIBUTE, m_flElectroshock_Charge ) * 0.01;
                    m_flFloats[m_iAttacker][m_flElectroshock] += m_flValue;

                    if ( m_flFloats[m_iAttacker][m_flElectroshock] > 100.0 ) m_flFloats[m_iAttacker][m_flElectroshock] = 100.0;
                    if ( m_flFloats[m_iAttacker][m_flElectroshock] < 0.0 ) m_flFloats[m_iAttacker][m_flElectroshock] = 0.0;
                }
            }

            if ( m_iWeapon != -1
                && m_bHasAttribute[m_iAttacker][m_iSlot] )
            {
                if ( m_bMarkVictim_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    g_pMarker[m_iVictim] = m_iAttacker;
                    if ( m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] != INVALID_HANDLE )
                    {
                        ClearTimer( m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] );
                        s_bGlowEnabled[m_iVictim] = false;
                        m_iIntegers[m_iAttacker][m_iMarkedVictim]--;
                    }
                    if ( m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] == INVALID_HANDLE && !s_bGlowEnabled[m_iVictim] && m_iIntegers[m_iAttacker][m_iMarkedVictim] < m_iMarkVictim_MaximumStack[m_iAttacker][m_iSlot] )
                    {
                        m_iIntegers[m_iAttacker][m_iMarkedVictim]++;
                        SetEntProp( m_iVictim, Prop_Send, "m_bGlowEnabled", 1 );
                        s_bGlowEnabled[m_iVictim] = true;

                        new Handle:m_hData01 = CreateDataPack();
                        m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] = CreateDataTimer( m_flMarkVictim_Duration[m_iAttacker][m_iSlot], m_tMarkVictim, m_hData01 );
                        WritePackCell( m_hData01, m_iVictim );
                        WritePackCell( m_hData01, m_iAttacker );
                    }
                }
            //-//
                if ( m_bMarkVictimForDeath_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    g_pMarker[m_iVictim] = m_iAttacker;
                    if ( m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] != INVALID_HANDLE )
                    {
                        ClearTimer( m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] );
                        m_iIntegers[m_iAttacker][m_iMarkedVictimForDeath]--;
                    }
                    if ( m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] == INVALID_HANDLE && m_iIntegers[m_iAttacker][m_iMarkedVictimForDeath] < m_iMarkVictimForDeath_MaximumStack[m_iAttacker][m_iSlot] )
                    {
                        m_iIntegers[m_iAttacker][m_iMarkedVictimForDeath]++;
                        TF2_AddCondition( m_iVictim, TFCond_MarkedForDeath, m_flMarkVictimForDeath_Duration[m_iAttacker][m_iSlot] );

                        new Handle:m_hData02 = CreateDataPack();
                        m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] = CreateDataTimer( m_flMarkVictimForDeath_Duration[m_iAttacker][m_iSlot], m_tMarkVictimForDeath, m_hData02 );
                        WritePackCell( m_hData02, m_iVictim );
                        WritePackCell( m_hData02, m_iAttacker );
                    }
                }
            //-//
                if ( m_bDisableSlot_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    if ( MakeSlotSleep( m_iVictim, m_iAttacker, m_iDisableSlot_Slot[m_iAttacker][m_iSlot], m_flDisableSlot_Duration[m_iAttacker][m_iSlot] ) )
                    {
                        EmitSoundToAll( SOUND_SHIELD_BREAK, m_iVictim, SNDCHAN_WEAPON );
                        EmitSoundToClient( m_iVictim, SOUND_SHIELD_BREAK );
                        EmitSoundToClient( m_iAttacker, SOUND_SHIELD_BREAK );
                    }
                }
            //-//
                if ( m_bDisorientateOnHit_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    new Float:m_vEyeAngles[3];
                    new Float:m_flSpin = m_flDamage;
                    if ( m_flSpin > 100.0 ) m_flSpin = 100.0;
                    if ( m_flSpin < 20.0 ) m_flSpin = 20.0;
                            
                    if ( m_flSpin <= 100.0 && m_flSpin >= 20.0 )
                    {
                        GetClientEyeAngles( m_iVictim, m_vEyeAngles );
                        m_vEyeAngles[0] += GetRandomFloat( -1.0, 1.0 ) * m_flSpin * 0.6;
                        m_vEyeAngles[1] += GetRandomFloat( -1.0, 1.0 ) * m_flSpin * 0.6;
                        TeleportEntity( m_iVictim, NULL_VECTOR, m_vEyeAngles, NULL_VECTOR );
                                
                        decl String:m_strSound[PLATFORM_MAX_PATH];
                        new m_iRandom = GetRandomInt( 1,3 );
                        if ( m_iRandom == 1 ) Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_A );
                        if ( m_iRandom == 2 ) Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_B );
                        else Format( m_strSound, sizeof( m_strSound ), SOUND_IMPACT_C );
                        
                        EmitSoundToClient( m_iVictim, m_strSound, _, _, SNDLEVEL_SCREAMING );
                                
                        if ( TF2_ShouldReveal( m_iVictim ) )
                        {
                            EmitSoundToClient( m_iAttacker, m_strSound, m_iVictim, _, SNDLEVEL_TRAIN );
                            decl Float:m_vPos[3];
                            GetClientEyePosition( m_iVictim, m_vPos );
                            m_vPos[2] += 2.0;
                            ShowText( m_iVictim, "hit_text" );
                        }
                    }
                }
            //-//
                if ( m_bIncreasedPushScale_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    decl Float:m_vAng[3], Float:m_vVelocity[3];
                    GetClientEyeAngles( m_iAttacker, m_vAng );
                    m_vAng[0] = -40.0;
                    AnglesToVelocity( m_vAng, m_vVelocity, ( 200.0 * m_flIncreasedPushScale_Scale[m_iAttacker][m_iSlot] ) ); //200.0
                            
                    TeleportEntity( m_iVictim, NULL_VECTOR, NULL_VECTOR, m_vVelocity );
                }
            //-//
                if ( m_bDisarmSilent_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    MakeSlotSleep( m_iVictim, m_iAttacker, 0, m_flDisarmSilent_Duration[m_iAttacker][m_iSlot], false );
                    MakeSlotSleep( m_iVictim, m_iAttacker, 1, m_flDisarmSilent_Duration[m_iAttacker][m_iSlot], false );
                }
                if ( m_iVictim != m_iAttacker )
                {
                    if ( m_bRageDecrease_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        m_bBools[m_iAttacker][m_bDrainRage] = false;

                        if ( m_hTimers[m_iAttacker][m_hRageDecrease_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iAttacker][m_hRageDecrease_TimerDelay] );
                        if ( m_hTimers[m_iAttacker][m_hRageDecrease_TimerDelay] == INVALID_HANDLE && GetEntPropFloat( m_iAttacker, Prop_Send, "m_flRageMeter" ) != 0.0 && !m_bBools[m_iAttacker][m_bDrainRage] )
                            m_hTimers[m_iAttacker][m_hRageDecrease_TimerDelay] = CreateTimer( 10.0, m_tRageDecrease, m_iAttacker );
                    }
                //-//
                    if ( m_bMissCauseDelay_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        if ( m_hTimers[m_iAttacker][m_hMissCauseDelay_TimerDuration] != INVALID_HANDLE )
                            ClearTimer( m_hTimers[m_iAttacker][m_hMissCauseDelay_TimerDuration] );
                    }
                //-//
                    if ( m_bDemoChargeOnHit_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        new Float:m_flChargeMeter = GetEntPropFloat( m_iAttacker, Prop_Send, "m_flChargeMeter" );
                        m_flChargeMeter += m_flDemoChargeOnHit_Charge[m_iAttacker][m_iSlot];
                                
                        if ( m_flChargeMeter >= 100.0 ) SetEntPropFloat( m_iAttacker, Prop_Send, "m_flChargeMeter", 100.0 );
                        if ( m_flChargeMeter < 100.0 ) SetEntPropFloat( m_iAttacker, Prop_Send, "m_flChargeMeter", m_flChargeMeter );
                    }
                //-//
                    if ( m_bPissYourselfOnMiss_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        m_bBools[m_iAttacker][m_bLastWasMissPISS] = false;
                //-//
                    if ( m_bJumpBonus_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        if ( ( m_iIntegers[m_iAttacker][m_iJumpAmount] + m_iIntegers[m_iAttacker][m_iJumpAmountBase] ) > m_iJumpBonus_BaseJumps[m_iAttacker][m_iSlot] )
                        {
                            m_iIntegers[m_iAttacker][m_iJumpAmount] += m_iJumpBonus_Hit[m_iAttacker][m_iSlot];
                            if ( m_iIntegers[m_iAttacker][m_iJumpAmount] > m_iJumpBonus_MaxJumps[m_iAttacker][m_iSlot] ) m_iIntegers[m_iAttacker][m_iJumpAmount] = m_iJumpBonus_MaxJumps[m_iAttacker][m_iSlot];
                        }
                        else
                        {
                            if ( m_iIntegers[m_iAttacker][m_iJumpAmount] < 0 ) m_iIntegers[m_iAttacker][m_iJumpAmount] = 0;
                            /* ** Hacky way to set correct jumps because the Unique Base Jump make the 'last' ( 1/max ) not used, Idk why, but that's not a big deal. ** */
                            if ( m_iJumpBonus_BaseJumps[m_iAttacker][m_iSlot] == 1 && m_iIntegers[m_iAttacker][m_iJumpAmount] == 0 ) m_iIntegers[m_iAttacker][m_iJumpAmount] += ( 1+m_iJumpBonus_Hit[m_iAttacker][m_iSlot] );
                            /* ** ! ** */
                            else if ( m_iJumpBonus_BaseJumps[m_iAttacker][m_iSlot] == 2 ) m_iIntegers[m_iAttacker][m_iJumpAmount] += m_iJumpBonus_Hit[m_iAttacker][m_iSlot];
                        }
                    }
                    if ( m_bLevelUpSystem_DamageDone_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        new Float:m_flValue = m_flDamage * ( m_flLevelUpSystem_DamageDone_Charge[m_iAttacker][m_iSlot] * 0.01 );

                        if ( m_hTimers[m_iAttacker][m_hDamageDone_TimerDuration] == INVALID_HANDLE ) {
                            if ( m_flFloats[m_iAttacker][m_flDamageCharge] < 100.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] += m_flValue; // from 0 to 1
                            else if ( m_flFloats[m_iAttacker][m_flDamageCharge] < 200.0 && m_flFloats[m_iAttacker][m_flDamageCharge] >= 100.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] += ( m_flValue / 1.5 ); // from 1 to 2
                            else if ( m_flFloats[m_iAttacker][m_flDamageCharge] < 300.0 && m_flFloats[m_iAttacker][m_flDamageCharge] >= 200.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] += ( m_flValue / 2.25 ); // from 2 to 3
                            else if ( m_flFloats[m_iAttacker][m_flDamageCharge] < 400.0 && m_flFloats[m_iAttacker][m_flDamageCharge] >= 300.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] += ( m_flValue / 3.0 ); // from 3 to 4
                        }

                        if ( m_flFloats[m_iAttacker][m_flDamageCharge] >= 100.0 )
                            TF2_HealPlayer( m_iAttacker, m_flDamage * m_flLevelUpSystem_DamageDone_Lifesteal[m_iAttacker][m_iSlot], 1.0, true );

                        if ( m_flFloats[m_iAttacker][m_flDamageCharge] < 0.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] = 0.0;
                        if ( m_flFloats[m_iAttacker][m_flDamageCharge] > 400.0 ) m_flFloats[m_iAttacker][m_flDamageCharge] = 400.0;
                    }
                    if ( m_bLevelUpSystem_DamageReceived_ATTRIBUTE[m_iAttacker][m_iSlot] )
                    {
                        if ( m_flFloats[m_iAttacker][m_flTakeDamageCharge] >= 100.0 )
                            TF2_HealPlayer( m_iAttacker, m_flDamage * m_flLevelUpSystem_DamageReceived_Lifesteal[m_iAttacker][m_iSlot], 1.0, true );
                    }
                }
            }
        }
    }
    if ( m_flDamage < 0.0 ) m_flDamage = 0.0;

    m_aAction = Plugin_Changed;
    return m_aAction;
}

// ====[ ON TAKE DAMAGE POST ]=========================================
public OnTakeDamagePost( m_iVictim, m_iAttacker, m_iInflictor, Float:m_flDamage, m_iType, m_iWeapon, Float:m_flForce[3], Float:m_flPosition[3] )
{
    if ( m_flDamage >= 1.0
        && IsValidClient( m_iAttacker ) )
    {
        new m_iSlot = TF2_GetWeaponSlot( m_iAttacker, m_iWeapon, m_iInflictor );

        if ( IsValidClient( m_iVictim )
            && !HasInvulnerabilityCond( m_iVictim )
            && m_iAttacker != m_iVictim
            && m_iWeapon != -1
            && m_bHasAttribute[m_iAttacker][m_iSlot] )
        {
            if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) )
            {
                if ( m_bExplosiveCriticalDamage_ATTRIBUTE[m_iAttacker][m_iSlot] )
                {
                    new particle = CreateEntityByName( "info_particle_system" );
                    if ( IsValidEntity( particle ) )
                    {
                        TeleportEntity( particle, m_flPosition, NULL_VECTOR, NULL_VECTOR );
                        DispatchKeyValue( particle, "effect_name", "ExplosionCore_MidAir" );
                        DispatchSpawn( particle );
                        ActivateEntity( particle );
                        AcceptEntityInput( particle, "start" );
                        SetVariantString( "OnUser1 !self:Kill::8:-1" );
                        AcceptEntityInput( particle, "AddOutput" );
                        AcceptEntityInput( particle, "FireUser1" );
                        
                        if ( m_flFloats[m_iAttacker][m_flExplosionSound] < GetEngineTime() - 0.1 )
                        {
                            new m_iRandom = GetRandomInt( 0, sizeof( g_strSoundExplosionBox )-1 );
                            EmitSoundFromOrigin( g_strSoundExplosionBox[m_iRandom], m_flPosition );
                            m_flFloats[m_iAttacker][m_flExplosionSound] = GetEngineTime();
                        }
                    }
                    
                    NormalizeVector( m_flForce, m_flForce );
                    if ( m_flForce[2] < 0.2 ) m_flForce[2] = 0.2;
                    
                    new Float:fScale = ( m_flDamage * 3.0 ) * m_flExplosiveCriticalDamage_Force[m_iAttacker][m_iSlot];
                    if ( fScale < 175.0 ) fScale = 175.0;
                    if ( fScale > 1750.0 ) fScale = 1750.0;
                    ScaleVector( m_flForce, fScale );
                    if ( m_flForce[2] < 555.0 && m_flDamage >= 30.0 ) m_flForce[2] = 555.0;
                    
                    decl Float:vClientVelocity[3];
                    GetVelocity( m_iVictim, vClientVelocity );
                    AddVectors( vClientVelocity, m_flForce, vClientVelocity );
                    TeleportEntity( m_iVictim, NULL_VECTOR, NULL_VECTOR, vClientVelocity );

                    new Float:flPos1[3];
                    GetClientEyePosition( m_iVictim, flPos1 );
                    
                    for ( new i = 1; i <= MaxClients; i++ )
                    {
                        if ( i != m_iAttacker && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iAttacker ) )
                        {
                            if ( !HasInvulnerabilityCond( i ) )
                            {
                                new Float:flPos2[3];
                                GetClientEyePosition( i, flPos2 );
                                    
                                new Float:distance = GetVectorDistance( flPos1, flPos2 );
                                if ( distance <= m_flExplosiveCriticalDamage_Radius[m_iAttacker][m_iSlot] )
                                {
                                    decl Handle:m_hSee;
                                    ( m_hSee = INVALID_HANDLE );

                                    m_hSee = TR_TraceRayFilterEx( flPos1, flPos2, MASK_SOLID, RayType_EndPoint, TraceFilterPlayer, m_iVictim );
                                    if ( m_hSee != INVALID_HANDLE )
                                    {
                                        if ( !TR_DidHit( m_hSee ) )
                                        {
                                            // Limit the minimum damage to 50%
                                            // Begin the reduction at 73.0 HU.
                                            new Float:dmg_reduction = 1.0;
                                            if ( distance > 73.0 )
                                                dmg_reduction = ( m_flDamage * ( m_flExplosiveCriticalDamage_Radius[m_iAttacker][m_iSlot] - ( ( distance - 73.0 ) * 0.5 ) ) / m_flExplosiveCriticalDamage_Radius[m_iAttacker][m_iSlot] ) / m_flDamage;
                
                                            DealDamage( i, RoundToFloor( ( ( m_iExplosiveCriticalDamage_DamageMode[m_iAttacker][m_iSlot] == 1 ? m_flDamage : 1.0 ) * m_flExplosiveCriticalDamage_Damage[m_iAttacker][m_iSlot] ) * dmg_reduction ), m_iAttacker, TF_DMG_ALWAYSGIB|TF_DMG_BLAST|TF_DMG_CRIT|m_iType, "pumpkindeath" );
                                        }
                                    }

                                    CloseHandle( m_hSee );
                                }
                            }
                        }
                    }
                }
            }
        }
    }

    return;
}

// ====[ CALC IS ATTACK CRITICAL ]=====================================
public Action:TF2_CalcIsAttackCritical( m_iClient, m_iWeapon, String:m_strName[], &bool:m_bResult )
{
    if ( IsValidClient( m_iClient )
        && IsPlayerAlive( m_iClient ) )
    {
        new m_iSlot = TF2_GetWeaponSlot( m_iClient, m_iWeapon );
        if ( m_iWeapon != -1
            && m_bHasAttribute[m_iClient][m_iSlot] )
        {
            if ( m_bSniperCombo_ATTRIBUTE[m_iClient][m_iSlot] )
            {
                if ( m_iIntegers[m_iClient][m_iSniperComboHit] > 0 ) {
                    m_bBools[m_iClient][m_bSniperCombo] = false;
                    CreateTimer( 0.1, m_tSniperCombo_TimerDealy, m_iClient );
                }
            }
        //-//
            if ( m_bMissCauseDelay_ATTRIBUTE[m_iClient][m_iSlot] && m_hTimers[m_iClient][m_hMissCauseDelay_TimerDuration] == INVALID_HANDLE && ( GetEntProp( m_iWeapon, Prop_Send, "m_bLowered" ) == 0 ) )
            {
                if ( m_hTimers[m_iClient][m_hMissCauseDelay_TimerDuration] != INVALID_HANDLE )
                    ClearTimer( m_hTimers[m_iClient][m_hMissCauseDelay_TimerDuration] );

                new m_iASlot = TF2_GetClientActiveSlot( m_iClient );

                new Handle:m_hData04 = CreateDataPack();
                WritePackCell( m_hData04, m_iClient );
                WritePackCell( m_hData04, m_iASlot );
                m_hTimers[m_iClient][m_hMissCauseDelay_TimerDuration] = CreateTimer( 0.0, m_tMissCauseDelay_TimerDelay, m_hData04 );
                
                if ( m_bBools[m_iClient][m_bLastWasMiss] )
                    EmitSoundToClient( m_iClient, SOUND_WEAPON_SHOTGUN, _, SNDCHAN_WEAPON, _, _, 0.5 ); // Judging by this, this attr was made for a shotgun. Might be the chain of command.
                                                                                                          
                m_bBools[m_iClient][m_bLastWasMiss] = false;
            }
        //-//
            if ( m_bPyroCombo_ATTRIBUTE[m_iClient][m_iSlot] )
            {
                if ( m_iIntegers[m_iClient][m_iPyroComboHit] > 0 ) {
                    m_bBools[m_iClient][m_bPyroCombo] = false;
                    CreateTimer( 0.4, m_tPyroCombo_TimerDealy, m_iClient );
                }
            }
        //-//
            if ( m_bPissYourselfOnMiss_ATTRIBUTE[m_iClient][m_iSlot] )
            {
                m_bBools[m_iClient][m_bLastWasMissPISS] = true;
                CreateTimer( 0.25, m_tPissMiss_TimerDelay, m_iClient );
            }
        }
    }
    return Plugin_Continue;
}

// ====[ EVENT: ON DEATH ]=============================================
public Action:Event_Death( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iVictim = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );
    new m_iKiller = GetClientOfUserId( GetEventInt( m_hEvent, "attacker" ) );
    new m_iInflictor = GetClientOfUserId( GetEventInt( m_hEvent, "inflictor_entindex" ) );
    new bool:m_bFeignDeath = bool:( GetEventInt( m_hEvent, "death_flags" ) & TF_DEATHFLAG_DEADRINGER );

    if ( IsValidClient( m_iVictim ) )
    {
        if ( m_iVictim && !m_bFeignDeath )
        {
            // ATTRIBUTE
            if ( HasAttribute( m_iVictim, _, m_bRespawnWhereYouDied_ATTRIBUTE ) && m_flFloats[m_iVictim][m_flRespawn] == 100.0 )
            {
                CreateTimer( GetAttributeValueF( m_iVictim, _, m_bRespawnWhereYouDied_ATTRIBUTE, m_flRespawnWhereYouDied_Delay ), m_tRespawnWhereYouDied, m_iVictim );
            }
            if ( m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] != INVALID_HANDLE )
            {
                if ( m_iIntegers[g_pMarker[m_iVictim]][m_iMarkedVictim] > 0 && GetClientTeam( g_pMarker[m_iVictim] ) != GetClientTeam( m_iVictim ) && HasAttribute( g_pMarker[m_iVictim], _, m_bMarkVictim_ATTRIBUTE ) )
                    m_iIntegers[g_pMarker[m_iVictim]][m_iMarkedVictim]--;
            }
            if ( m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] != INVALID_HANDLE )
            {
                if ( m_iIntegers[g_pMarker[m_iVictim]][m_iMarkedVictimForDeath] > 0 && GetClientTeam( g_pMarker[m_iVictim] ) != GetClientTeam( m_iVictim ) && HasAttribute( g_pMarker[m_iVictim], _, m_bMarkVictimForDeath_ATTRIBUTE ) )
                    m_iIntegers[g_pMarker[m_iVictim]][m_iMarkedVictimForDeath]--;
            }

            for ( new i = 0; i < m_hTimer; i++ )
            {
                ClearTimer( m_hTimers[m_iVictim][i] );
            }
            for ( new i = 0; i < m_bBool; i++ )
            {
                m_bBools[m_iVictim][i] = false;
            }
            for ( new i = 0; i < m_flFloat; i++ )
            {
                m_flFloats[m_iVictim][i] = 0.0;
            }
            for ( new i = 0; i < m_iInteger-2; i++ )
            {
                m_iIntegers[m_iVictim][i] = 0;
            }
            s_bGlowEnabled[m_iVictim] = false;
            SetEntProp( m_iVictim, Prop_Send, "m_bGlowEnabled", 0 );
            g_pMarker[m_iVictim] = -1;
        }
        if ( m_iKiller != m_iVictim )
        {
            if ( IsValidClient( m_iKiller ) )
            {
                new m_iWeapon = g_iLastWeapon[m_iKiller];
                new m_iSlot = TF2_GetWeaponSlot( m_iKiller, m_iWeapon, m_iInflictor );
                if ( m_iWeapon != -1 && m_bHasAttribute[m_iKiller][m_iSlot] )
                {
                    if ( m_bUberchargeOnKill_ATTRIBUTE[m_iKiller][m_iSlot] )
                        TF2_SetClientUberLevel( m_iKiller, TF2_GetClientUberLevel( m_iKiller ) + m_flUberchargeOnKill_Amount[m_iKiller][m_iSlot] );
                //-//
                    if ( m_bJumpBonus_ATTRIBUTE[m_iKiller][m_iSlot] )
                    {
                        m_iIntegers[m_iKiller][m_iJumpAmount] += m_iJumpBonus_Kill[m_iKiller][m_iSlot];

                        if ( m_iIntegers[m_iKiller][m_iJumpAmount] > m_iJumpBonus_MaxJumps[m_iKiller][m_iSlot] ) m_iIntegers[m_iKiller][m_iJumpAmount] = m_iJumpBonus_MaxJumps[m_iKiller][m_iSlot];
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}
// -
// --
// ---
// ----
// -----
// ------
// -------
// Timers.
// -------
// ------
// -----
// ----
// ---
// --
// -
public Action:m_tRespawnWhereYouDied( Handle:timer, any:m_iClient )
{
    if ( IsPlayerAlive( m_iClient ) ) return Plugin_Continue;
    if ( HasAttribute( m_iClient, _, m_bRespawnWhereYouDied_ATTRIBUTE ) )
    {
        new Float:m_flPos[3];
        GetClientAbsOrigin( m_iClient, m_flPos );
        TF2_RespawnPlayer( m_iClient );
        TeleportEntity( m_iClient, m_flPos, NULL_VECTOR, NULL_VECTOR );
    }
    return Plugin_Stop;
}
public Action:m_tMiniMann_Cooldown( Handle:timer, any:m_iClient ) m_hTimers[m_iClient][m_hMiniMann_TimerCooldown] = INVALID_HANDLE;
public Action:m_tMiniMann_Duration( Handle:timer, any:m_iClient )
{
    SetEntPropFloat( m_iClient, Prop_Send, "m_flModelScale", 1.0 );

    m_hTimers[m_iClient][m_hMiniMann_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tMiniMann_Delay( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bMiniMann_ATTRIBUTE ) )
    {
        if ( GetAttributeValueI( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_iMiniMann_Speed ) == 1 )
            TF2_AddCondition( m_iClient, TFCond_SpeedBuffAlly, GetAttributeValueF( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_flMiniMann_Duration ) );

        new Float:m_flSize = GetAttributeValueF( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_flMiniMann_Resize );
        if ( m_flSize < 0.25 ) m_flSize = 0.25;
        if ( m_flSize > 2.0 ) m_flSize = 2.0;
        SetEntPropFloat( m_iClient, Prop_Send, "m_flModelScale", m_flSize );

        new secondary = GetPlayerWeaponSlot( m_iClient, TFWeaponSlot_Secondary );
        if ( IsValidEntity( secondary ) ) SetEntPropFloat( secondary, Prop_Send, "m_flEffectBarRegenTime", GetGameTime() + GetAttributeValueF( m_iClient, _, m_bMiniMann_ATTRIBUTE, m_flMiniMann_Cooldown ) );
    }
    m_hTimers[m_iClient][m_hMiniMann_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tRageDecrease( Handle:timer, any:m_iAttacker )
{
    m_bBools[m_iAttacker][m_bDrainRage] = true;
    m_hTimers[m_iAttacker][m_hRageDecrease_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tMarkVictim( Handle:timer, any:m_hData01 )
{
    ResetPack( m_hData01 );

    new m_iVictim, m_iAttacker;
    m_iVictim = ReadPackCell( m_hData01 );
    m_iAttacker = ReadPackCell( m_hData01 );

    if ( IsValidClient( m_iVictim ) && IsValidClient( m_iAttacker ) )
    {
        m_iIntegers[m_iAttacker][m_iMarkedVictim]--;
        s_bGlowEnabled[m_iVictim] = false;
        SetEntProp( m_iVictim, Prop_Send, "m_bGlowEnabled", 0 );
        g_pMarker[m_iVictim] = -1;
    }

    m_hTimers[m_iVictim][m_hMarkVictim_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tMarkVictimForDeath( Handle:timer, any:m_hData02 )
{
    ResetPack( m_hData02 );

    new m_iVictim, m_iAttacker;
    m_iVictim = ReadPackCell( m_hData02 );
    m_iAttacker = ReadPackCell( m_hData02 );
    
    if ( IsValidClient( m_iVictim ) && IsValidClient( m_iAttacker ) )
    {
        m_iIntegers[m_iAttacker][m_iMarkedVictimForDeath]--;
        g_pMarker[m_iVictim] = -1;
    }

    m_hTimers[m_iVictim][m_hMarkVictimForDeath_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tWakeUpSlot_TimerDuration( Handle:timer, Handle:m_hData03 )
{
    ResetPack( m_hData03 );

    decl String:m_strWakeSound[PLATFORM_MAX_PATH];
    new m_iClient, m_iSlot, bool:m_bMiss;
    m_iClient = ReadPackCell( m_hData03 );
    m_iSlot = ReadPackCell( m_hData03 );
    m_bMiss = ReadPackCell( m_hData03 );
    ReadPackString( m_hData03, m_strWakeSound, sizeof( m_strWakeSound ) );
    CloseHandle( m_hData03 );

    if ( IsValidClient( m_iClient ) ) {

        m_bSlotDisabled[m_iClient][m_iSlot] = false;
        
        new m_iWeapon = GetPlayerWeaponSlot( m_iClient, m_iSlot );
        if ( IsValidEdict( m_iWeapon ) )
        {
            new m_iLowered = GetEntProp( m_iWeapon, Prop_Send, "m_bLowered" );
            if ( m_iLowered != 0 )
            {
                SetEntProp( m_iWeapon, Prop_Send, "m_bLowered", 0 );

                if ( IsPlayerAlive( m_iClient ) && !StrEqual( m_strWakeSound, "" ) )
                {
                    EmitSoundToAll( m_strWakeSound, m_iClient, SNDCHAN_WEAPON );
                    EmitSoundToClient( m_iClient, m_strWakeSound );
                }
            }
        }

        if ( !m_bMiss ) {
            EmitSoundToClient( m_iClient, SOUND_READY );
            PrintHintText( m_iClient, "Custom: Your weapon is back !" );
        }
    }
}
public Action:m_tBonkHealth( Handle:timer, any:m_iClient ) m_hTimers[m_iClient][m_hBonkHealth_TimerCooldown] = INVALID_HANDLE;
public Action:m_tBonkHealth_Delay( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bBonkHealth_ATTRIBUTE ) )
    {
        TF2_HealPlayer( m_iClient, GetAttributeValueF( m_iClient, _, m_bBonkHealth_ATTRIBUTE, m_flBonkHealth_Heal ), GetAttributeValueF( m_iClient, _, m_bBonkHealth_ATTRIBUTE, m_flBonkHealth_OverHealBonusCap ) );

        new secondary = GetPlayerWeaponSlot( m_iClient, TFWeaponSlot_Secondary );
        if ( IsValidEntity( secondary ) ) SetEntPropFloat( secondary, Prop_Send, "m_flEffectBarRegenTime", GetGameTime() + GetAttributeValueF( m_iClient, _, m_bBonkHealth_ATTRIBUTE, m_flBonkHealth_Cooldown ) );
    }

    m_hTimers[m_iClient][m_hBonkHealth_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tSniperCombo_TimerDealy( Handle:timer, any:m_iClient )
{
    if ( !( m_bBools[m_iClient][m_bSniperCombo] ) ) m_iIntegers[m_iClient][m_iSniperComboHit] = 0;
}
public Action:m_tPyroCombo_TimerDealy( Handle:timer, any:m_iClient )
{
    if ( !( m_bBools[m_iClient][m_bPyroCombo] ) ) m_iIntegers[m_iClient][m_iPyroComboHit] = 0;
}
public Action:m_tMissCauseDelay_TimerDelay( Handle:timer, Handle:m_hData04 )
{
    ResetPack( m_hData04 );

    new m_iClient, m_iSlot;
    m_iClient = ReadPackCell( m_hData04 );
    m_iSlot = ReadPackCell( m_hData04 );
     
    if ( HasAttribute( m_iClient, _, m_bMissCauseDelay_ATTRIBUTE ) )
    {
        if ( IsValidClient( m_iClient ) )
        {
            new Float:m_flDelay = GetAttributeValueF( m_iClient, _, m_bMissCauseDelay_ATTRIBUTE, m_flMissCauseDelay_Delay );
            MakeSlotSleep( m_iClient, m_iClient, m_iSlot, m_flDelay, false );
            m_bBools[m_iClient][m_bLastWasMiss] = true;
        }
    }

    m_hTimers[m_iClient][m_hMissCauseDelay_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tPissMiss_TimerDelay( Handle:timer, any:m_iClient )
{
    if ( m_bBools[m_iClient][m_bLastWasMissPISS] == true ) TF2_AddCondition( m_iClient, TFCond_Jarated, 5.0 );
}
public Action:m_tDamageDone_TimerDuration( Handle:timer, any:m_iClient ) m_hTimers[m_iClient][m_hDamageDone_TimerDuration] = INVALID_HANDLE;
// Super Timer
public Action:m_tPostInventory( Handle:timer, any:m_iClient ) g_hPostInventory[m_iClient] = false;

// -
// --
// ---
// ----
// -----
// ------
// -------
// STOCKS.
// -------
// ------
// -----
// ----
// ---
// --
// -
// In customweaponstf_orionstock.inc
stock bool:MakeSlotSleep( m_iClient, m_iAttacker, m_iSlot, Float:m_flTime = 1.0, bool:m_bSwitch = true, String:m_strWakeSound[] = "" )
{
    if ( !IsValidClient( m_iClient ) ) return false;
    if ( !IsPlayerAlive( m_iClient ) ) return false;
    if ( !IsValidClient( m_iAttacker ) ) return false;
    if ( m_iSlot < 0 ) return false;
    if ( m_iSlot > MAXSLOTS ) return false;
    if ( m_bSlotDisabled[m_iClient][m_iSlot] ) return false;
    if ( m_flTime <= 0.0 ) return false;
    
    new m_iWeapon = GetPlayerWeaponSlot( m_iClient, m_iSlot );
    if ( IsValidEdict( m_iWeapon ) )
    {
        new m_iLowered = GetEntProp( m_iWeapon, Prop_Send, "m_bLowered" );
        if ( m_iLowered <= 0 )
        {
            SetEntProp( m_iWeapon, Prop_Send, "m_bLowered", 10000 );
            
            m_bSlotDisabled[m_iClient][m_iSlot] = true;

            if ( m_bSwitch ) {
                if ( m_iSlot == 0 ) TF2_SetClientSlot( m_iClient, 2 );
                else TF2_SetClientSlot( m_iClient, 0 );
            }

            new bool:m_bMiss = false;
            if ( HasAttribute( m_iAttacker, _, m_bMissCauseDelay_ATTRIBUTE ) ) {
                if ( m_iClient == m_iAttacker ) m_bMiss = true;
            } else {
                new String:m_sSlot[10];
                if ( m_iSlot == 0 ) Format( m_sSlot, sizeof( m_sSlot ), "primary", m_sSlot );
                else if ( m_iSlot == 1 ) Format( m_sSlot, sizeof( m_sSlot ), "secondary", m_sSlot );
                else if ( m_iSlot == 2 ) Format( m_sSlot, sizeof( m_sSlot ), "melee", m_sSlot );

                if ( HasAttribute( m_iAttacker, _, m_bDisarmSilent_ATTRIBUTE ) ) PrintHintText( m_iClient, "Custom: Your primary and secondary weapons are disabled for %.0f seconds !", m_flTime );
                else PrintHintText( m_iClient, "Custom: Your %s weapon is disabled for %.0f seconds !", m_sSlot, m_flTime );
            }
            
            new Handle:m_hData03 = CreateDataPack();
            WritePackCell( m_hData03, m_iClient );
            WritePackCell( m_hData03, m_iSlot );
            WritePackCell( m_hData03, m_bMiss );
            WritePackString( m_hData03, m_strWakeSound );
            CreateTimer( m_flTime, m_tWakeUpSlot_TimerDuration, m_hData03 );
            
            return true;
        }
    }
    
    return false;
}
bool:HasAttribute( client, slot = -1, const attribute[][] = m_bHasAttribute, bool:active = false )
{
    if ( !IsValidClient( client ) ) return false;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( attribute[client][i] ) {
                    if ( slot == -1 || slot == i ) return true;
        }}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return false;

        new i = TF2_GetClientActiveSlot( client );
        if ( i != -1 ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( attribute[client][i] ) return true;
        }}
    }
    
    return false;
}
Float:GetAttributeValueF( client, slot = -1, const bool:baseAttribute[][], const Float:attribute[][], bool:active = false )
{
    if ( !IsValidClient( client ) ) return 0.0;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) {
                    if ( slot == -1 || slot == i ) return attribute[client][i];
        }}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return 0.0;

        new i = TF2_GetClientActiveSlot( client );
        if ( i != -1 ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) return attribute[client][i];
        }}
    }
    
    return 0.0;
}
GetAttributeValueI( client, slot = -1, const bool:baseAttribute[][], const attribute[][], bool:active = false )
{
    if ( !IsValidClient( client ) ) return 0;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) {
                    if ( slot == -1 || slot == i ) return attribute[client][i];
        }}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return 0;

        new i = TF2_GetClientActiveSlot( client );
        if ( i != -1 ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) return attribute[client][i];
        }}
    }
    
    return 0;
}
