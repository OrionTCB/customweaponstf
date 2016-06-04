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
    name           = "Custom Weapons: Dota 2 Attributes",
    author         = "Orion",
    description    = "Custom Weapons: Dota 2 Attributes",
    version        = PLUGIN_VERSION,
    url            = "https://forums.alliedmods.net/showpost.php?p=2193855&postcount=254"
};

// ====[ VARIABLES ]===================================================
new bool:m_bHasAttribute[MAXPLAYERS + 1][MAXSLOTS + 1];

enum
{
    Handle:m_hDesolator_TimerDuration = 0,
    Handle:m_hDuel_TimerCooldown,
    Handle:m_hDuel_TimerDuration,
    Handle:m_hDuel_TimerEnable,
    Handle:m_hEnchantTotem_TimerCooldown,
    Handle:m_hEnchantTotem_TimerDuration,
    Handle:m_hEnrage_TimerCooldown,
    Handle:m_hEnrage_TimerDuration,
    Handle:m_hFurySwipes_TimerDuration,
    Handle:m_hInnerVitality_TimerCooldown,
    Handle:m_hInnerVitality_TimerDuration,
    Handle:m_hJinada_TimerCooldown,
    Handle:m_hOverPower_TimerCooldown,
    Handle:m_hOverPower_TimerDuration,
    Handle:m_hRadiance_MissLinger,
    Handle:m_hRadiance_TimerInterval,
    Handle:m_hTimer
};
new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];
enum
{
    m_bDuel_ReadyForIt = 0,
    m_bIsFervor_On,
    m_bRadiance_SubAbilityActive,
    m_bIsDuel_On,
    m_bBool
};
new bool:m_bBools[MAXPLAYERS + 1][m_bBool];
enum
{
    m_flDesolator_DamageAmplification = 0,
    m_flDuel_Bonus,
    m_flEvasionChance_AW2,
    /*m_flPRD_StackBad,*/
    m_flRadiance_SubAbilityChance,
    m_flFloat
};
new Float:m_flFloats[MAXPLAYERS + 1][m_flFloat];
enum
{
    m_iFervor_Stack = 0,
    m_iFurySwipe_Stack,
    m_iOverpower_RemainingHit,
    m_iNecromastery_Souls,
    m_iBloodstone_Charge,
    /*m_iPRD_Stack,*/
    m_iInteger
};
new m_iIntegers[MAXPLAYERS + 1][m_iInteger];

new bool:g_hPostInventory[MAXPLAYERS + 1]               = false;
new g_iLastButtons[MAXPLAYERS+1]                        = -1;
new g_iLastWeapon[MAXPLAYERS + 1]                       = -1;
new g_pDuelist[MAXPLAYERS + 1]                          = -1;
new Handle:g_hHudText_D2;


    /* On Hit
     * ---------------------------------------------------------------------- */

new bool:m_bJinada_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flJinada_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flJinada_DamageMultiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bTrueStrike_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bFervor_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFervor_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFervor_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iFervor_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDuel_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDuel_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDuel_DamageBonus[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDuel_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Attack
     * ---------------------------------------------------------------------- */

new bool:m_bStaticField_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStaticField_DamagePct[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStaticField_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Kill
     * ---------------------------------------------------------------------- */

new bool:m_bNecromastery_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flNecromastery_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flNecromastery_Removal[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iNecromastery_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iNecromastery_PoA[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBloodbath_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodbath_Heal[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodbath_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Damage
     * ---------------------------------------------------------------------- */

new bool:m_bKillAtLowHealthPointsThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flKillAtLowHealthPointsThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bKillAtHighHealthPointsThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flKillAtHighHealthPointsThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bFurySwipes_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFurySwipes_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFurySwipes_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iFurySwipes_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bLifesteal_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLifesteal_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLifesteal_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bLifestealOnCrit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLifestealOnCrit_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLifestealOnCrit_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDesolator_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDesolator_DamageAmp[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDesolator_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Prethink
     * ---------------------------------------------------------------------- */

new bool:m_bRadiance_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRadiance_Interval[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRadiance_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iRadiance_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bRadiance_SubAbility_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRadiance_SubAbility_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Chance
     * ---------------------------------------------------------------------- */

new bool:m_bBash_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBash_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBash_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBash_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bEvasion_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEvasion_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bEvasionAW2_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEvasionAW2_Add[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEvasionAW2_Removal[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iEvasionAW2_Melee[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iEvasionAW2_PoA[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Damage Received
     * ---------------------------------------------------------------------- */

new bool:m_bBladeMail_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBladeMail_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCraggyExterior_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCraggyExterior_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCraggyExterior_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCraggyExterior_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iCraggyExterior_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDispersion_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDispersion_MaxDamage[MAXPLAYERS + 1][MAXSLOTS + 1]; 
new Float:m_flDispersion_MaxRadius[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDispersion_MinRadius[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bReturn_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flReturn_Damage[MAXPLAYERS + 1][MAXSLOTS + 1]; 
new m_iReturn_BaseDamage[MAXPLAYERS + 1][MAXSLOTS + 1]; 

new bool:m_bBlockDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBlockDamage_Block[MAXPLAYERS + 1][MAXSLOTS + 1]; 
new Float:m_flBlockDamage_Chance[MAXPLAYERS + 1][MAXSLOTS + 1]; 


    /* To Activate
     * ---------------------------------------------------------------------- */

new bool:m_bEnchantTotem_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnchantTotem_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnchantTotem_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnchantTotem_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bOverPower_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flOverPower_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flOverPower_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flOverPower_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flOverPower_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iOverPower_Hit[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bEnrage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnrage_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnrage_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnrage_FurySwipeMultiplier[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnrage_Resistance[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bInnerVitality_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_BaseRegen[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_Cooldown[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_HealthHealAbove[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_HealthHealBelow[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInnerVitality_HealthThreshold[MAXPLAYERS + 1][MAXSLOTS + 1];


    /* On Death
     * ---------------------------------------------------------------------- */

new bool:m_bLastWill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iLastWill_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBloodstone_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBloodstone_BaseCharge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodstone_RegenPerCharge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodstone_BaseHeal[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodstone_HealPerCharge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodstone_HealRadius[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBloodstone_ChargeRadius[MAXPLAYERS + 1][MAXSLOTS + 1];


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
    else LogMessage( "Custom Weapons 2 ERROR : DOTA 2 : SDKHooks failed to load ! Is Sourcemod well installed ? Health based attributes won't work correctly." );

    SetHudTextParams( 1.0, 0.4, 0.15, 255, 255, 255, 255 );  
    g_hHudText_D2 = CreateHudSynchronizer();
}

// ====[ ON CLIENT PUT IN SERVER ]=====================================
public OnClientPutInServer( m_iClient )
{
    SDKHook( m_iClient, SDKHook_OnTakeDamage, OnTakeDamage );
    SDKHook( m_iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive );
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
            g_iLastWeapon[i] = -1;
            g_pDuelist[i] = -1;
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
    for ( new i = 0; i < m_bBool; i++ )
    {
        m_bBools[m_iClient][i]      = false;
    }
    for ( new i = 0; i < m_flFloat; i++ )
    {
        m_flFloats[m_iClient][i]    = 0.0;
    }
    for ( new i = 0; i < m_iInteger; i++ )
    {
        m_iIntegers[m_iClient][i]   = 0;
    }
    g_iLastWeapon[m_iClient] = -1;
    g_pDuelist[m_iClient] = -1;
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
            g_iLastWeapon[i] = -1;
            g_pDuelist[i] = -1;
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
        g_iLastWeapon[m_iClient] = -1;
        g_pDuelist[m_iClient] = -1;
    }

    return;
}

// ====[ EVENT: POST INVENTORY APPLICATION ]===========================
public Event_PostInventoryApplication( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );
    
    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) )
    {
        if ( m_hTimers[m_iClient][m_hEnchantTotem_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hEnchantTotem_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Enchant Totem is ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }
        if ( m_hTimers[m_iClient][m_hJinada_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hJinada_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Jinada is ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }
        if ( m_hTimers[m_iClient][m_hOverPower_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hOverPower_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Overpower ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }
        if ( m_hTimers[m_iClient][m_hEnrage_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hEnrage_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Enrage is ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }
        if ( m_hTimers[m_iClient][m_hInnerVitality_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hInnerVitality_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Inner Vitality is ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }
        if ( m_hTimers[m_iClient][m_hDuel_TimerCooldown] != INVALID_HANDLE ) {
            ClearTimer( m_hTimers[m_iClient][m_hDuel_TimerCooldown] );
            PrintHintText( m_iClient, "Custom: Duel is ready." );
            EmitSoundToClient( m_iClient, SOUND_READY );
        }

        if ( !g_hPostInventory[m_iClient] ) {
            CreateTimer( 0.02, m_tPostInventory, m_iClient );
            g_hPostInventory[m_iClient] = true;
        }
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
        m_iButtons = ATTRIBUTE_ENCHANTTOTEM( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_ENRAGE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_FERVOR( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_INNERVITALITY( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_OVERPOWER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
    }
    CloseHandle( hArray );
    
    m_iSlot2 = -1;
    
    for ( m_iSlot2 = 0; m_iSlot2 <= 4; m_iSlot2++ ) // ALWAYS ACTIVE | PASSIVE STUFF HERE.
    {
        m_iButtons = ATTRIBUTE_DUEL( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_RADIANCE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_RADIANCEMISS( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_BLOODSTONE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = HUD_SHOWSYNCHUDTEXT( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = PRETHINK_STACKREMOVER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
    }

    if ( m_iButtons != m_iButtons2 ) SetEntProp( m_iClient, Prop_Data, "m_nButtons", m_iButtons );    
    g_iLastButtons[m_iClient] = m_iButtons;
}

ATTRIBUTE_OVERPOWER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bOverPower_ATTRIBUTE, true ) )
    {
        new Float:old_as = GetAttributeValueF( m_iClient, _, m_bOverPower_ATTRIBUTE, m_flOverPower_OldAttackSpeed, true );
        new hit = GetAttributeValueI( m_iClient, _, m_bOverPower_ATTRIBUTE, m_iOverPower_Hit, true );
        new Float:dur = GetAttributeValueF( m_iClient, _, m_bOverPower_ATTRIBUTE, m_flOverPower_Duration, true );

        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
        new Float:m_flAttackSpeed;
        new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
        if ( m_aAttribute != Address_Null ) {
            m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
        }
        
        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( m_hTimers[m_iClient][m_hOverPower_TimerCooldown] == INVALID_HANDLE )
            {
                m_hTimers[m_iClient][m_hOverPower_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bOverPower_ATTRIBUTE, m_flOverPower_Cooldown, true ), m_tOverPower_Cooldown, m_iClient );
                if ( m_hTimers[m_iClient][m_hOverPower_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hOverPower_TimerDuration] );
                else m_hTimers[m_iClient][m_hOverPower_TimerDuration] = CreateTimer( dur, m_tOverPower_Duration, m_iClient );
                EmitSoundToClient( m_iClient, SOUND_RADIANCE );

                TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as - GetAttributeValueF( m_iClient, _, m_bOverPower_ATTRIBUTE, m_flOverPower_AttackSpeed, true ) );

                m_iIntegers[m_iClient][m_iOverpower_RemainingHit] = hit;
                PrintHintText( m_iClient, "Custom: Fire rate increased ! Lasts for %.2f seconds or %i hits.", dur, hit );
            }
        }
        if ( m_hTimers[m_iClient][m_hOverPower_TimerDuration] != INVALID_HANDLE ) // When active
        {
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

            if ( m_iIntegers[m_iClient][m_iOverpower_RemainingHit] <= 0 )
            {
                ClearTimer( m_hTimers[m_iClient][m_hOverPower_TimerDuration] );
                TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_FERVOR( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bFervor_ATTRIBUTE, true ) )
    {
        new Float:old_as = GetAttributeValueF( m_iClient, _, m_bFervor_ATTRIBUTE, m_flFervor_OldAttackSpeed, true );

        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        if ( m_iIntegers[m_iClient][m_iFervor_Stack] <= 0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
        else {
            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            new Float:m_flAttackSpeed;
            new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
            if ( m_aAttribute != Address_Null ) {
                m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
            }
            
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
        }
    }
    else if ( !HasAttribute( m_iClient, _, m_bFervor_ATTRIBUTE ) ) {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) m_iIntegers[m_iClient][m_iFervor_Stack] = 0;
    }

    return m_iButtons;
}

ATTRIBUTE_ENCHANTTOTEM( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bEnchantTotem_ATTRIBUTE, true ) )
    {
        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( m_hTimers[m_iClient][m_hEnchantTotem_TimerCooldown] == INVALID_HANDLE )
            {
                new Float:duration = GetAttributeValueF( m_iClient, _, m_bEnchantTotem_ATTRIBUTE, m_flEnchantTotem_Duration, true );

                m_hTimers[m_iClient][m_hEnchantTotem_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bEnchantTotem_ATTRIBUTE, m_flEnchantTotem_Cooldown, true ), m_tEnchantTotem, m_iClient );
                if ( m_hTimers[m_iClient][m_hEnchantTotem_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hEnchantTotem_TimerDuration] );
                else m_hTimers[m_iClient][m_hEnchantTotem_TimerDuration] = CreateTimer( duration, m_tEnchantTotem_Duration, m_iClient );
                EmitSoundToClient( m_iClient, SOUND_RADIANCE );

                PrintHintText( m_iClient, "Custom: Next attack damage increased by ×%.2f. Lasts for %.2f seconds or until damaging an enemy.", GetAttributeValueF( m_iClient, _, m_bEnchantTotem_ATTRIBUTE, m_flEnchantTotem_BonusDamage, true ), duration );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_ENRAGE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bEnrage_ATTRIBUTE, true ) )
    {
        if ( m_iButtons & IN_RELOAD == IN_RELOAD )
        {
            if ( m_hTimers[m_iClient][m_hEnrage_TimerCooldown] == INVALID_HANDLE && HasAttribute( m_iClient, _, m_bFurySwipes_ATTRIBUTE ) )
            {
                new Float:duration = GetAttributeValueF( m_iClient, _, m_bEnrage_ATTRIBUTE, m_flEnrage_Duration, true );

                m_hTimers[m_iClient][m_hEnrage_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bEnrage_ATTRIBUTE, m_flEnrage_Cooldown, true ), m_tEnrage_Cooldown, m_iClient );
                if ( m_hTimers[m_iClient][m_hEnrage_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hEnrage_TimerDuration] );
                else m_hTimers[m_iClient][m_hEnrage_TimerDuration] = CreateTimer( duration, m_tEnrage_Duration, m_iClient );
                EmitSoundToClient( m_iClient, SOUND_RADIANCE );
                
                TF2_AddCondition( m_iClient, TFCond_MegaHeal, duration );                                                           // Fancy effects.
                TF2_AddCondition( m_iClient, TFCond_TeleportedGlow, duration );                                                     // Fancy effects.
                TF2_AddCondition( m_iClient, TFCond_Teleporting, duration );                                                        // Fancy effects.
                TF2_RemoveBadCondition( m_iClient, true );

                PrintHintText( m_iClient, "Custom: Enrage is now active, Fury Swipes damage increased by %.3f. Lasts for %.2f seconds", GetAttributeValueF( m_iClient, _, m_bEnrage_ATTRIBUTE, m_flEnrage_FurySwipeMultiplier, true ), duration );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_RADIANCE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bRadiance_ATTRIBUTE ) ) {
        if ( m_hTimers[m_iClient][m_hRadiance_TimerInterval] == INVALID_HANDLE ) {
            m_hTimers[m_iClient][m_hRadiance_TimerInterval] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bRadiance_ATTRIBUTE, m_flRadiance_Interval ), m_tRadiance, m_iClient );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_RADIANCEMISS( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bRadiance_SubAbility_ATTRIBUTE ) && HasAttribute( m_iClient, _, m_bRadiance_ATTRIBUTE ) )
    {
        new Float:m_flPos1[3];
        GetClientAbsOrigin( m_iClient, m_flPos1 );
        new m_iTeam = GetClientTeam( m_iClient );
                            
        for ( new i = 1; i <= MaxClients; i++ )
        {
            if ( i != m_iClient && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != m_iTeam )
            {
                new Float:m_flPos2[3];
                GetClientAbsOrigin( i, m_flPos2 );
                                    
                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                if ( distance <= GetAttributeValueF( m_iClient, _, m_bRadiance_ATTRIBUTE, m_flRadiance_Radius ) )
                {
                    // Create a timer that lingers 0.5 to repeatedly remove the miss debuff.
                    if ( m_hTimers[i][m_hRadiance_MissLinger] == INVALID_HANDLE ) CreateTimer( 0.5, m_tRadiance_SubAbility_MissLinger, i );

                    m_bBools[i][m_bRadiance_SubAbilityActive] = true;
                    m_flFloats[i][m_flRadiance_SubAbilityChance] = GetAttributeValueF( m_iClient, _, m_bRadiance_SubAbility_ATTRIBUTE, m_flRadiance_SubAbility_Chance );
                }
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_INNERVITALITY( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bInnerVitality_ATTRIBUTE ) ) {

        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( m_hTimers[m_iClient][m_hInnerVitality_TimerCooldown] == INVALID_HANDLE )
            {
                new Float:duration = GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_Duration );

                if ( m_hTimers[m_iClient][m_hInnerVitality_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hInnerVitality_TimerDuration] );
                else m_hTimers[m_iClient][m_hInnerVitality_TimerDuration] = CreateTimer( duration, m_tInnerVitality_Duration, m_iClient );
                m_hTimers[m_iClient][m_hInnerVitality_TimerCooldown] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_Cooldown ), m_tInnerVitality_Cooldown, m_iClient );

                TF2_AddCondition( m_iClient, TFCond_MegaHeal, 1.0 );                                                                                                                                               // Fancy effects.
                TF2_AddCondition( m_iClient, TFCond_TeleportedGlow, duration );                                                     // Fancy effects.
                TF2_AddCondition( m_iClient, TFCond_Teleporting, duration );                                                        // Fancy effects.
                TF2_AddCondition( m_iClient, TFCond_Healing, duration );                                                        // Fancy effects.
                EmitSoundToClient( m_iClient, SOUND_RADIANCE );
            }
        }
        if ( m_hTimers[m_iClient][m_hInnerVitality_TimerDuration] != INVALID_HANDLE )
        {
            if ( GetClientHealth( m_iClient ) < TF2_GetClientMaxHealth( m_iClient ) )
            {
                static Float:m_flRegenCharge[MAXPLAYERS + 1] = 0.0;
                m_flRegenCharge[m_iClient] += ( ( ( GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_BaseRegen )/12.0 ) + ( TF2_GetClientMaxHealth( m_iClient ) * ( GetClientHealth( m_iClient ) > TF2_GetClientMaxHealth( m_iClient )*GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_HealthThreshold ) ? GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_HealthHealAbove ) : GetAttributeValueF( m_iClient, _, m_bInnerVitality_ATTRIBUTE, m_flInnerVitality_HealthHealBelow ) ) ) ) * 0.0303 );
                if ( m_flRegenCharge[m_iClient] >= 1.0 ) {
                    TF2_HealPlayer( m_iClient, m_flRegenCharge[m_iClient], 0.667 );
                    m_flRegenCharge[m_iClient] = 0.0;
                }
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DUEL( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDuel_ATTRIBUTE ) )
    {
        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( m_hTimers[m_iClient][m_hDuel_TimerCooldown] == INVALID_HANDLE
                && m_hTimers[m_iClient][m_hDuel_TimerDuration] == INVALID_HANDLE
                && m_hTimers[m_iClient][m_hDuel_TimerEnable] == INVALID_HANDLE )
            {
                if ( m_bBools[m_iClient][m_bDuel_ReadyForIt] ) {
                    m_bBools[m_iClient][m_bDuel_ReadyForIt] = false;
                    EmitSoundToClient( m_iClient, SOUND_NOTREADY );
                    m_hTimers[m_iClient][m_hDuel_TimerEnable] = CreateTimer( 1.0, m_tDuel_Enable, m_iClient );// +2 hours.
                } else {
                    m_bBools[m_iClient][m_bDuel_ReadyForIt] = true;
                    EmitSoundToClient( m_iClient, SOUND_READY );
                    m_hTimers[m_iClient][m_hDuel_TimerEnable] = CreateTimer( 1.0, m_tDuel_Enable, m_iClient );// +2 hours.
                }
            }
        }
        if ( m_hTimers[m_iClient][m_hDuel_TimerDuration] != INVALID_HANDLE && IsValidClient( g_pDuelist[m_iClient] ) && IsPlayerAlive( g_pDuelist[m_iClient] ) && m_bBools[g_pDuelist[m_iClient]][m_bIsDuel_On] )
        {
            new Float:duration = GetAttributeValueF( m_iClient, _, m_bDuel_ATTRIBUTE, m_flDuel_Duration );

            new m_iWeaponA = TF2_GetClientActiveWeapon( m_iClient );
            SetEntPropFloat( m_iWeaponA, Prop_Send, "m_flNextSecondaryAttack", GetGameTime()+duration );
            new m_iWeaponV = TF2_GetClientActiveWeapon( g_pDuelist[m_iClient] );
            SetEntPropFloat( m_iWeaponV, Prop_Send, "m_flNextSecondaryAttack", GetGameTime()+duration );

            new Float:m_flPos1[3];
            GetClientEyePosition( m_iClient, m_flPos1 );
            new Float:m_flPos2[3];
            GetClientEyePosition( g_pDuelist[m_iClient], m_flPos2 );
            new Float:m_flCam1[3], Float:m_flCam2[3];

            GetVectorAnglesTwoPoints( m_flPos1, m_flPos2, m_flCam1 );
            GetVectorAnglesTwoPoints( m_flPos2, m_flPos1, m_flCam2 );

            TeleportEntity( m_iClient, NULL_VECTOR, m_flCam1, NULL_VECTOR );
            TeleportEntity( g_pDuelist[m_iClient], NULL_VECTOR, m_flCam2, NULL_VECTOR );

            if ( m_iButtons & IN_BACK ) m_iButtons &= ~IN_BACK;
        }
        else if ( m_hTimers[m_iClient][m_hDuel_TimerDuration] == INVALID_HANDLE && IsValidClient( g_pDuelist[m_iClient] ) )
        {
            m_bBools[g_pDuelist[m_iClient]][m_bIsDuel_On] = false;
            g_pDuelist[m_iClient] = -1;
        }
    }

    return m_iButtons;
}

ATTRIBUTE_BLOODSTONE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bBloodstone_ATTRIBUTE ) )
    {
        if ( m_iIntegers[m_iClient][m_iBloodstone_Charge] <= 0 ) m_iIntegers[m_iClient][m_iBloodstone_Charge] = GetAttributeValueI( m_iClient, _, m_bBloodstone_ATTRIBUTE, m_iBloodstone_BaseCharge );

        TF2Attrib_SetByName( m_iClient, "health regen", 0.0+m_iIntegers[m_iClient][m_iBloodstone_Charge] * GetAttributeValueF( m_iClient, _, m_bBloodstone_ATTRIBUTE, m_flBloodstone_RegenPerCharge ) );
    }

    return m_iButtons;
}

PRETHINK_STACKREMOVER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( !HasAttribute( m_iClient, _, m_bNecromastery_ATTRIBUTE ) ) {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) m_iIntegers[m_iClient][m_iNecromastery_Souls] = 0;
    }
    if ( !HasAttribute( m_iClient, _, m_bEvasionAW2_ATTRIBUTE ) ) {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) m_flFloats[m_iClient][m_flEvasionChance_AW2] = 0.0;
    }
    if ( !HasAttribute( m_iClient, _, m_bBloodstone_ATTRIBUTE ) ) {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) TF2Attrib_RemoveByName( m_iClient, "health regen" ); 
    }

    return m_iButtons;
}
HUD_SHOWSYNCHUDTEXT( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    new String:m_strHUDNecromastery[42];
    new String:m_strHUDFervor[42];
    new String:m_strHUDEvasionOnHit[42];
    new String:m_strHUDOverPower[42];
    new String:m_strHUDDuel[42];
    new String:m_strHUDBloodstone[42];

    if ( HasAttribute( m_iClient, _, m_bNecromastery_ATTRIBUTE, true ) ) {
        if ( GetAttributeValueI( m_iClient, _, m_bNecromastery_ATTRIBUTE, m_iNecromastery_MaximumStack, true ) >= 1024 ) {
            Format( m_strHUDNecromastery, sizeof( m_strHUDNecromastery ), "Kills %i", m_iIntegers[m_iClient][m_iNecromastery_Souls] );
        } else {
            Format( m_strHUDNecromastery, sizeof( m_strHUDNecromastery ), "Kills %i/%i", m_iIntegers[m_iClient][m_iNecromastery_Souls], GetAttributeValueI( m_iClient, _, m_bNecromastery_ATTRIBUTE, m_iNecromastery_MaximumStack, true ) );
        }
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bFervor_ATTRIBUTE, true ) )
    {
        Format( m_strHUDFervor, sizeof( m_strHUDFervor ), "Fervor %i/%i", m_iIntegers[m_iClient][m_iFervor_Stack], GetAttributeValueI( m_iClient, _, m_bFervor_ATTRIBUTE, m_iFervor_MaximumStack, true ) );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bOverPower_ATTRIBUTE, true ) && m_iIntegers[m_iClient][m_iOverpower_RemainingHit] >= 1 )
    {
        Format( m_strHUDOverPower, sizeof( m_strHUDOverPower ), "Remaining Hits %i", m_iIntegers[m_iClient][m_iOverpower_RemainingHit] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bEvasionAW2_ATTRIBUTE ) && GetAttributeValueI( m_iClient, _, m_bEvasionAW2_ATTRIBUTE, m_iEvasionAW2_PoA ) == 0
        || HasAttribute( m_iClient, _, m_bEvasionAW2_ATTRIBUTE, true ) && GetAttributeValueI( m_iClient, _, m_bEvasionAW2_ATTRIBUTE, m_iEvasionAW2_PoA ) == 1 )
    {
        Format( m_strHUDEvasionOnHit, sizeof( m_strHUDEvasionOnHit ), "Evasion %.0f%%", m_flFloats[m_iClient][m_flEvasionChance_AW2] * 100.0 );
    }
//-//
    if ( m_flFloats[m_iClient][m_flDuel_Bonus] >= 1.0 ) {
        Format( m_strHUDDuel, sizeof( m_strHUDDuel ), "Duel %.0f", m_flFloats[m_iClient][m_flDuel_Bonus] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bBloodstone_ATTRIBUTE ) )
    {
        Format( m_strHUDBloodstone, sizeof( m_strHUDBloodstone ), "Bloodpact %i", m_iIntegers[m_iClient][m_iBloodstone_Charge] );
    }
//-//
    if ( IfDoNextTime2( m_iClient, e_flNextHUDUpdate, 0.1 ) ) // Thanks Chdata :D
    {
        ShowSyncHudText( m_iClient, g_hHudText_D2, "%s \n%s \n%s \n%s \n%s \n%s", m_strHUDEvasionOnHit,
                                                                                  m_strHUDNecromastery,
                                                                                  m_strHUDFervor,
                                                                                  m_strHUDOverPower,
                                                                                  m_strHUDDuel,
                                                                                  m_strHUDBloodstone );
    }
    
    return m_iButtons;
}

// ====[ ON ADD ATTRIBUTE ]============================================
public Action:CW3_OnAddAttribute( m_iSlot, m_iClient, const String:m_sAttribute[], const String:m_sPlugin[], const String:m_sValue[], bool:m_bActive )
{
    if ( !StrEqual( m_sPlugin, "dota2" ) ) return Plugin_Continue;
    new Action:m_aAction;

    /* Bash
     *
     * ---------------------------------------------------------------------- */
    if ( StrEqual( m_sAttribute, "bash" ) ) 
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBash_Chance[m_iClient][m_iSlot]              = StringToFloat( m_sValues[0] );
        m_flBash_Duration[m_iClient][m_iSlot]            = StringToFloat( m_sValues[1] );
        m_flBash_BonusDamage[m_iClient][m_iSlot]         = StringToFloat( m_sValues[2] );
        m_bBash_ATTRIBUTE[m_iClient][m_iSlot]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Blade Mail
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "blade mail" ) )
    {
        m_flBladeMail_Multiplier[m_iClient][m_iSlot]     = StringToFloat( m_sValue );
        m_bBladeMail_ATTRIBUTE[m_iClient][m_iSlot]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Craggy Exterior
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "craggy exterior" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flCraggyExterior_Chance[m_iClient][m_iSlot]    = StringToFloat( m_sValues[0] );
        m_iCraggyExterior_Damage[m_iClient][m_iSlot]     = StringToInt( m_sValues[1] );
        m_flCraggyExterior_Radius[m_iClient][m_iSlot]    = StringToFloat( m_sValues[2] );
        m_flCraggyExterior_Duration[m_iClient][m_iSlot]  = StringToFloat( m_sValues[3] );
        m_bCraggyExterior_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Enchant Totem
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "enchant totem" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flEnchantTotem_BonusDamage[m_iClient][m_iSlot] = StringToFloat( m_sValues[0] );
        m_flEnchantTotem_Duration[m_iClient][m_iSlot]    = StringToFloat( m_sValues[1] );
        m_flEnchantTotem_Cooldown[m_iClient][m_iSlot]    = StringToFloat( m_sValues[2] );
        m_bEnchantTotem_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Evasion
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "evasion" ) )
    {
        m_flEvasion_Chance[m_iClient][m_iSlot]           = StringToFloat( m_sValue );
        m_bEvasion_ATTRIBUTE[m_iClient][m_iSlot]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Evasiveness On Hit AW2
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "evasiveness on hit" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flEvasionAW2_Add[m_iClient][m_iSlot]       = StringToFloat( m_sValues[0] );
        m_flEvasionAW2_Removal[m_iClient][m_iSlot]   = StringToFloat( m_sValues[1] );
        m_iEvasionAW2_Melee[m_iClient][m_iSlot]      = StringToInt( m_sValues[2] );
        m_iEvasionAW2_PoA[m_iClient][m_iSlot]        = StringToInt( m_sValues[3] );
        m_bEvasionAW2_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Fervor
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "fervor" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flFervor_AttackSpeed[m_iClient][m_iSlot]           = StringToFloat( m_sValues[0] );
        m_iFervor_MaximumStack[m_iClient][m_iSlot]           = StringToInt( m_sValues[1] );
        m_flFervor_OldAttackSpeed[m_iClient][m_iSlot]        = StringToFloat( m_sValues[2] );
        m_bFervor_ATTRIBUTE[m_iClient][m_iSlot]              = true;
        m_aAction = Plugin_Handled;
    }
    /* Fury Swipe
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "fury swipe" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flFurySwipes_BonusDamage[m_iClient][m_iSlot]       = StringToFloat( m_sValues[0] );
        m_iFurySwipes_MaximumStack[m_iClient][m_iSlot]       = StringToInt( m_sValues[1] );
        m_flFurySwipes_Duration[m_iClient][m_iSlot]          = StringToFloat( m_sValues[2] );
        m_bFurySwipes_ATTRIBUTE[m_iClient][m_iSlot]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Jinada
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "jinada attr" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flJinada_DamageMultiplier[m_iClient][m_iSlot]      = StringToFloat( m_sValues[0] );
        m_flJinada_Cooldown[m_iClient][m_iSlot]              = StringToFloat( m_sValues[1] );
        m_bJinada_ATTRIBUTE[m_iClient][m_iSlot]              = true;
        m_aAction = Plugin_Handled;
    }
    /* Kill At High Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "kill at high hp threshold" ) )
    {
        m_flKillAtHighHealthPointsThreshold_Threshold[m_iClient][m_iSlot]    = StringToFloat( m_sValue );
        m_bKillAtHighHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Kill At Low Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "kill at low hp threshold" ) )
    {
        m_flKillAtLowHealthPointsThreshold_Threshold[m_iClient][m_iSlot] = StringToFloat( m_sValue );
        m_bKillAtLowHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Last Will
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "last will" ) )
    {
        m_iLastWill_Damage[m_iClient][m_iSlot]               = StringToInt( m_sValue );
        m_bLastWill_ATTRIBUTE[m_iClient][m_iSlot]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Lifesteal
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "lifesteal" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flLifesteal_Percentage[m_iClient][m_iSlot]         = StringToFloat( m_sValues[0] );
        m_flLifesteal_OverHealBonusCap[m_iClient][m_iSlot]   = StringToFloat( m_sValues[1] );
        m_bLifesteal_ATTRIBUTE[m_iClient][m_iSlot]           = true;
        m_aAction = Plugin_Handled;
    }
    /* Lifesteal On Crit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "lifesteal crit" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flLifestealOnCrit_Percentage[m_iClient][m_iSlot]       = StringToFloat( m_sValues[0] );
        m_flLifestealOnCrit_OverHealBonusCap[m_iClient][m_iSlot] = StringToFloat( m_sValues[1] );
        m_bLifestealOnCrit_ATTRIBUTE[m_iClient][m_iSlot]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Necromastery
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "necromastery" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flNecromastery_BonusDamage[m_iClient][m_iSlot]         = StringToFloat( m_sValues[0] );
        m_iNecromastery_MaximumStack[m_iClient][m_iSlot]         = StringToInt( m_sValues[1] );
        m_flNecromastery_Removal[m_iClient][m_iSlot]             = StringToFloat( m_sValues[2] );
        m_iNecromastery_PoA[m_iClient][m_iSlot]      = StringToInt( m_sValues[3] );
        m_bNecromastery_ATTRIBUTE[m_iClient][m_iSlot]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Overpower
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "overpower" ) )
    {
        new String:m_sValues[5][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flOverPower_AttackSpeed[m_iClient][m_iSlot]            = StringToFloat( m_sValues[0] );
        m_flOverPower_Duration[m_iClient][m_iSlot]               = StringToFloat( m_sValues[1] );
        m_iOverPower_Hit[m_iClient][m_iSlot]                     = StringToInt( m_sValues[2] );
        m_flOverPower_Cooldown[m_iClient][m_iSlot]               = StringToFloat( m_sValues[3] );
        m_flOverPower_OldAttackSpeed[m_iClient][m_iSlot]         = StringToFloat( m_sValues[4] );
        m_bOverPower_ATTRIBUTE[m_iClient][m_iSlot]               = true;
        m_aAction = Plugin_Handled;
    }
    /* Radiance
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "radiance attr" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iRadiance_Damage[m_iClient][m_iSlot]                   = StringToInt( m_sValues[0] );
        m_flRadiance_Radius[m_iClient][m_iSlot]                  = StringToFloat( m_sValues[1] );
        m_flRadiance_Interval[m_iClient][m_iSlot]                = StringToFloat( m_sValues[2] );
        m_bRadiance_ATTRIBUTE[m_iClient][m_iSlot]                = true;
        m_aAction = Plugin_Handled;
    }
    /* Radiance Evasion
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "SUB_ATTR radiance evasion" ) )
    {
        m_flRadiance_SubAbility_Chance[m_iClient][m_iSlot]       = StringToFloat( m_sValue );
        m_bRadiance_SubAbility_ATTRIBUTE[m_iClient][m_iSlot]     = true;
        m_aAction = Plugin_Handled;
    }
    /* True Strike
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "true strike" ) )
    {
        m_bTrueStrike_ATTRIBUTE[m_iClient][m_iSlot]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Desolator
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "desolator attr" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDesolator_DamageAmp[m_iClient][m_iSlot]              = StringToFloat( m_sValues[0] );
        m_flDesolator_Duration[m_iClient][m_iSlot]               = StringToFloat( m_sValues[1] );
        m_bDesolator_ATTRIBUTE[m_iClient][m_iSlot]               = true;
        m_aAction = Plugin_Handled;
    }
    /* Dispersion
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dispersion attr" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDispersion_MaxDamage[m_iClient][m_iSlot]             = StringToFloat( m_sValues[0] );
        m_flDispersion_MaxRadius[m_iClient][m_iSlot]             = StringToFloat( m_sValues[1] );
        m_flDispersion_MinRadius[m_iClient][m_iSlot]             = StringToFloat( m_sValues[2] );
        m_bDispersion_ATTRIBUTE[m_iClient][m_iSlot]              = true;
        m_aAction = Plugin_Handled;
    }
    /* Return
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "return attr" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iReturn_BaseDamage[m_iClient][m_iSlot]     = StringToInt( m_sValues[0] );
        m_flReturn_Damage[m_iClient][m_iSlot]        = StringToFloat( m_sValues[1] );
        m_bReturn_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Static Field
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "static field attr" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flStaticField_DamagePct[m_iClient][m_iSlot]     = StringToFloat( m_sValues[0] );
        m_flStaticField_Radius[m_iClient][m_iSlot]        = StringToFloat( m_sValues[1] );
        m_bStaticField_ATTRIBUTE[m_iClient][m_iSlot]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Bloodbath
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "bloodbath" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBloodbath_Heal[m_iClient][m_iSlot]       = StringToFloat( m_sValues[0] );
        m_flBloodbath_Radius[m_iClient][m_iSlot]     = StringToFloat( m_sValues[1] );
        m_bBloodbath_ATTRIBUTE[m_iClient][m_iSlot]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Enrage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "enrage" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flEnrage_FurySwipeMultiplier[m_iClient][m_iSlot]   = StringToFloat( m_sValues[0] );
        m_flEnrage_Resistance[m_iClient][m_iSlot]            = StringToFloat( m_sValues[1] );
        m_flEnrage_Duration[m_iClient][m_iSlot]              = StringToFloat( m_sValues[2] );
        m_flEnrage_Cooldown[m_iClient][m_iSlot]              = StringToFloat( m_sValues[3] );
        m_bEnrage_ATTRIBUTE[m_iClient][m_iSlot]              = true;
        m_aAction = Plugin_Handled;
    }
    /* Inner Vitality
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "inner vitality" ) )
    {
        new String:m_sValues[6][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flInnerVitality_BaseRegen[m_iClient][m_iSlot]          = StringToFloat( m_sValues[0] );
        m_flInnerVitality_HealthHealAbove[m_iClient][m_iSlot]    = StringToFloat( m_sValues[1] );
        m_flInnerVitality_HealthHealBelow[m_iClient][m_iSlot]    = StringToFloat( m_sValues[2] );
        m_flInnerVitality_HealthThreshold[m_iClient][m_iSlot]    = StringToFloat( m_sValues[3] );
        m_flInnerVitality_Duration[m_iClient][m_iSlot]           = StringToFloat( m_sValues[4] );
        m_flInnerVitality_Cooldown[m_iClient][m_iSlot]           = StringToFloat( m_sValues[5] );
        m_bInnerVitality_ATTRIBUTE[m_iClient][m_iSlot]           = true;
        m_aAction = Plugin_Handled;
    }
    /* Block Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "block damage" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBlockDamage_Block[m_iClient][m_iSlot]    = StringToFloat( m_sValues[0] );
        m_flBlockDamage_Chance[m_iClient][m_iSlot]   = StringToFloat( m_sValues[1] );
        m_bBlockDamage_ATTRIBUTE[m_iClient][m_iSlot] = true;
        m_aAction = Plugin_Handled;
    }
    /* Duel
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "duel" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDuel_DamageBonus[m_iClient][m_iSlot] = StringToFloat( m_sValues[0] );
        m_flDuel_Duration[m_iClient][m_iSlot]    = StringToFloat( m_sValues[1] );
        m_flDuel_Cooldown[m_iClient][m_iSlot]    = StringToFloat( m_sValues[2] );
        m_bDuel_ATTRIBUTE[m_iClient][m_iSlot]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Bloodstone
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "bloodstone" ) )
    {
        new String:m_sValues[6][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iBloodstone_BaseCharge[m_iClient][m_iSlot]        = StringToInt( m_sValues[0] );
        m_flBloodstone_RegenPerCharge[m_iClient][m_iSlot]   = StringToFloat( m_sValues[1] );
        m_flBloodstone_BaseHeal[m_iClient][m_iSlot]         = StringToFloat( m_sValues[2] );
        m_flBloodstone_HealPerCharge[m_iClient][m_iSlot]    = StringToFloat( m_sValues[3] );
        m_flBloodstone_HealRadius[m_iClient][m_iSlot]       = StringToFloat( m_sValues[4] );
        m_flBloodstone_ChargeRadius[m_iClient][m_iSlot]     = StringToFloat( m_sValues[5] );
        m_bBloodstone_ATTRIBUTE[m_iClient][m_iSlot]         = true;
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

            m_bJinada_ATTRIBUTE[m_iClient][m_iSlot]          = false;
            m_flJinada_Cooldown[m_iClient][m_iSlot]          = 0.0;
            m_flJinada_DamageMultiplier[m_iClient][m_iSlot]  = 0.0;

            m_bTrueStrike_ATTRIBUTE[m_iClient][m_iSlot]      = false;

            m_bFervor_ATTRIBUTE[m_iClient][m_iSlot]          = false;
            m_flFervor_AttackSpeed[m_iClient][m_iSlot]       = 0.0;
            m_flFervor_OldAttackSpeed[m_iClient][m_iSlot]    = 0.0;
            m_iFervor_MaximumStack[m_iClient][m_iSlot]       = 0;

            m_bDuel_ATTRIBUTE[m_iClient][m_iSlot]            = false;
            m_flDuel_Cooldown[m_iClient][m_iSlot]            = 0.0;
            m_flDuel_DamageBonus[m_iClient][m_iSlot]         = 0.0;
            m_flDuel_Duration[m_iClient][m_iSlot]            = 0.0;


            /* On Attack
             * ---------------------------------------------------------------------- */

            m_bStaticField_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flStaticField_DamagePct[m_iClient][m_iSlot]    = 0.0;
            m_flStaticField_Radius[m_iClient][m_iSlot]       = 0.0;


            /* On Kill
             * ---------------------------------------------------------------------- */

            m_bNecromastery_ATTRIBUTE[m_iClient][m_iSlot]        = false;
            m_flNecromastery_BonusDamage[m_iClient][m_iSlot]     = 0.0;
            m_flNecromastery_Removal[m_iClient][m_iSlot]         = 0.0;
            m_iNecromastery_MaximumStack[m_iClient][m_iSlot]     = 0;
            m_iNecromastery_PoA[m_iClient][m_iSlot]  = 0;

            m_bBloodbath_ATTRIBUTE[m_iClient][m_iSlot]           = false;
            m_flBloodbath_Heal[m_iClient][m_iSlot]               = 0.0;
            m_flBloodbath_Radius[m_iClient][m_iSlot]             = 0.0;


            /* On Damage
             * ---------------------------------------------------------------------- */

            m_bKillAtLowHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flKillAtLowHealthPointsThreshold_Threshold[m_iClient][m_iSlot]     = 0.0;

            m_bKillAtHighHealthPointsThreshold_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flKillAtHighHealthPointsThreshold_Threshold[m_iClient][m_iSlot]    = 0.0;

            m_bFurySwipes_ATTRIBUTE[m_iClient][m_iSlot]                          = false;
            m_flFurySwipes_BonusDamage[m_iClient][m_iSlot]                       = 0.0;
            m_flFurySwipes_Duration[m_iClient][m_iSlot]                          = 0.0;
            m_iFurySwipes_MaximumStack[m_iClient][m_iSlot]                       = 0;

            m_bLifesteal_ATTRIBUTE[m_iClient][m_iSlot]                           = false;
            m_flLifesteal_OverHealBonusCap[m_iClient][m_iSlot]                   = 0.0;
            m_flLifesteal_Percentage[m_iClient][m_iSlot]                         = 0.0;

            m_bLifestealOnCrit_ATTRIBUTE[m_iClient][m_iSlot]                     = false;
            m_flLifestealOnCrit_OverHealBonusCap[m_iClient][m_iSlot]             = 0.0;
            m_flLifestealOnCrit_Percentage[m_iClient][m_iSlot]                   = 0.0;

            m_bDesolator_ATTRIBUTE[m_iClient][m_iSlot]                           = false;
            m_flDesolator_DamageAmp[m_iClient][m_iSlot]                          = 0.0;
            m_flDesolator_Duration[m_iClient][m_iSlot]                           = 0.0;


            /* On Prethink
             * ---------------------------------------------------------------------- */

            m_bRadiance_ATTRIBUTE[m_iClient][m_iSlot]            = false;
            m_flRadiance_Interval[m_iClient][m_iSlot]            = 0.0;
            m_flRadiance_Radius[m_iClient][m_iSlot]              = 0.0;
            m_iRadiance_Damage[m_iClient][m_iSlot]               = 0;

            m_bRadiance_SubAbility_ATTRIBUTE[m_iClient][m_iSlot] = false;
            m_flRadiance_SubAbility_Chance[m_iClient][m_iSlot]   = 0.0;


            /* On Chance
             * ---------------------------------------------------------------------- */

            m_bBash_ATTRIBUTE[m_iClient][m_iSlot]                    = false;
            m_flBash_BonusDamage[m_iClient][m_iSlot]                 = 0.0;
            m_flBash_Chance[m_iClient][m_iSlot]                      = 0.0;
            m_flBash_Duration[m_iClient][m_iSlot]                    = 0.0;

            m_bEvasion_ATTRIBUTE[m_iClient][m_iSlot]                 = false;
            m_flEvasion_Chance[m_iClient][m_iSlot]                   = 0.0;

            m_bEvasionAW2_ATTRIBUTE[m_iClient][m_iSlot]        = false;
            m_flEvasionAW2_Add[m_iClient][m_iSlot]             = 0.0;
            m_flEvasionAW2_Removal[m_iClient][m_iSlot]         = 0.0;
            m_iEvasionAW2_Melee[m_iClient][m_iSlot]            = 0;
            m_iEvasionAW2_PoA[m_iClient][m_iSlot]  = 0;


            /* On Damage Received
             * ---------------------------------------------------------------------- */

            m_bBladeMail_ATTRIBUTE[m_iClient][m_iSlot]       = false;
            m_flBladeMail_Multiplier[m_iClient][m_iSlot]     = 0.0;

            m_bCraggyExterior_ATTRIBUTE[m_iClient][m_iSlot]  = false;
            m_flCraggyExterior_Chance[m_iClient][m_iSlot]    = 0.0;
            m_flCraggyExterior_Duration[m_iClient][m_iSlot]  = 0.0;
            m_flCraggyExterior_Radius[m_iClient][m_iSlot]    = 0.0;
            m_iCraggyExterior_Damage[m_iClient][m_iSlot]     = 0;

            m_bDispersion_ATTRIBUTE[m_iClient][m_iSlot]      = false;
            m_flDispersion_MaxDamage[m_iClient][m_iSlot]     = 0.0; 
            m_flDispersion_MaxRadius[m_iClient][m_iSlot]     = 0.0;
            m_flDispersion_MinRadius[m_iClient][m_iSlot]     = 0.0;

            m_bReturn_ATTRIBUTE[m_iClient][m_iSlot]          = false;
            m_flReturn_Damage[m_iClient][m_iSlot]            = 0.0; 
            m_iReturn_BaseDamage[m_iClient][m_iSlot]         = 0; 

            m_bBlockDamage_ATTRIBUTE[m_iClient][m_iSlot]     = false;
            m_flBlockDamage_Block[m_iClient][m_iSlot]        = 0.0; 
            m_flBlockDamage_Chance[m_iClient][m_iSlot]       = 0.0; 


            /* To Activate
             * ---------------------------------------------------------------------- */

            m_bEnchantTotem_ATTRIBUTE[m_iClient][m_iSlot]            = false;
            m_flEnchantTotem_BonusDamage[m_iClient][m_iSlot]         = 0.0;
            m_flEnchantTotem_Cooldown[m_iClient][m_iSlot]            = 0.0;
            m_flEnchantTotem_Duration[m_iClient][m_iSlot]            = 0.0;

            m_bOverPower_ATTRIBUTE[m_iClient][m_iSlot]               = false;
            m_flOverPower_AttackSpeed[m_iClient][m_iSlot]            = 0.0;
            m_flOverPower_Cooldown[m_iClient][m_iSlot]               = 0.0;
            m_flOverPower_Duration[m_iClient][m_iSlot]               = 0.0;
            m_flOverPower_OldAttackSpeed[m_iClient][m_iSlot]         = 0.0;
            m_iOverPower_Hit[m_iClient][m_iSlot]                     = 0;

            m_bEnrage_ATTRIBUTE[m_iClient][m_iSlot]                  = false;
            m_flEnrage_Cooldown[m_iClient][m_iSlot]                  = 0.0;
            m_flEnrage_Duration[m_iClient][m_iSlot]                  = 0.0;
            m_flEnrage_FurySwipeMultiplier[m_iClient][m_iSlot]       = 0.0;
            m_flEnrage_Resistance[m_iClient][m_iSlot]                = 0.0;

            m_bInnerVitality_ATTRIBUTE[m_iClient][m_iSlot]           = false;
            m_flInnerVitality_BaseRegen[m_iClient][m_iSlot]          = 0.0;
            m_flInnerVitality_Cooldown[m_iClient][m_iSlot]           = 0.0;
            m_flInnerVitality_Duration[m_iClient][m_iSlot]           = 0.0;
            m_flInnerVitality_HealthHealAbove[m_iClient][m_iSlot]    = 0.0;
            m_flInnerVitality_HealthHealBelow[m_iClient][m_iSlot]    = 0.0;
            m_flInnerVitality_HealthThreshold[m_iClient][m_iSlot]    = 0.0;


            /* On Death
             * ---------------------------------------------------------------------- */

            m_bLastWill_ATTRIBUTE[m_iClient][m_iSlot]    = false;
            m_iLastWill_Damage[m_iClient][m_iSlot]       = 0;

            m_bBloodstone_ATTRIBUTE[m_iClient][m_iSlot]         = false;
            m_iBloodstone_BaseCharge[m_iClient][m_iSlot]        = 0;
            m_flBloodstone_RegenPerCharge[m_iClient][m_iSlot]   = 0.0;
            m_flBloodstone_BaseHeal[m_iClient][m_iSlot]         = 0.0;
            m_flBloodstone_HealPerCharge[m_iClient][m_iSlot]    = 0.0;
            m_flBloodstone_HealRadius[m_iClient][m_iSlot]       = 0.0;
            m_flBloodstone_ChargeRadius[m_iClient][m_iSlot]     = 0.0;
        }
    }
}

// ====[ ON TAKE DAMAGE ]==============================================
public Action:OnTakeDamage( m_iVictim, &m_iAttacker, &m_iInflictor, &Float:m_flDamage, &m_iType, &m_iWeapon, Float:m_iForce[3], Float:m_iPosition[3], m_iCustom )
{
    new Action:m_aAction;

    if ( m_flDamage >= 1.0
        && IsValidClient( m_iVictim )
        && !HasInvulnerabilityCond( m_iVictim ) )
    {
        if ( IsValidClient( m_iAttacker )
            && m_iAttacker != m_iVictim )
        {
            if ( HasAttribute( m_iVictim, _, m_bEvasion_ATTRIBUTE ) || HasAttribute( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE ) || m_bBools[m_iAttacker][m_bRadiance_SubAbilityActive] )
            {
                if ( !( m_iType & DOTA_DMG_BLADEMAIL )
                    && !( m_iType & DOTA_DMG_DISPERSION )
                    && !( m_iType & DOTA_DMG_OTHER )
                    && !HasInvulnerabilityCond( m_iVictim ) )
                {
                    new Float:evasion = ( 1 - GetAttributeValueF( m_iVictim, _, m_bEvasion_ATTRIBUTE, m_flEvasion_Chance ) ) * ( 1 - m_flFloats[m_iAttacker][m_flRadiance_SubAbilityChance] );

                    if ( HasAttribute( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE ) ) // It's not in MOREAW2 because I want True Strike to kill it.
                    {
                        new eaw2 = GetAttributeValueI( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE, m_iEvasionAW2_PoA );

                        if ( eaw2 == 0 || HasAttribute( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE, true ) && eaw2 == 1 )
                            evasion *= ( 1 - m_flFloats[m_iVictim][m_flEvasionChance_AW2] );

                        if ( m_iWeapon != GetPlayerWeaponSlot( m_iAttacker, TFWeaponSlot_Melee ) || m_iWeapon == GetPlayerWeaponSlot( m_iAttacker, TFWeaponSlot_Melee ) && GetAttributeValueI( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE, m_iEvasionAW2_Melee ) == 1 )
                            m_flFloats[m_iVictim][m_flEvasionChance_AW2] -= GetAttributeValueF( m_iVictim, _, m_bEvasionAW2_ATTRIBUTE, m_flEvasionAW2_Removal );
                        if ( m_flFloats[m_iVictim][m_flEvasionChance_AW2] < 0.0 ) m_flFloats[m_iVictim][m_flEvasionChance_AW2] = 0.0;
                    }

                    evasion = 1 - evasion;
                    if ( evasion >= GetRandomFloat( 0.0, 1.0 ) )
                    {
                        if ( m_iWeapon == -1 || !( m_bTrueStrike_ATTRIBUTE[m_iAttacker][TF2_GetWeaponSlot( m_iAttacker, m_iWeapon )] ) ) {
                            m_flDamage = 0.0;
                            ShowText( m_iVictim, "miss_text" );
                        }
                    }
                }
            }
            /*
            if ( m_hTimers[m_iAttacker][m_hDuel_TimerDuration] != INVALID_HANDLE && m_bBools[m_iVictim][m_bIsDuel_On] == false ) m_flDamage = 0.0;
            if ( m_hTimers[m_iVictim][m_hDuel_TimerDuration] != INVALID_HANDLE && m_bBools[m_iAttacker][m_bIsDuel_On] == false ) m_flDamage = 0.0;
            */
            if ( m_flDamage >= 1.0 )
            {
                if ( m_iWeapon != -1 )
                {
                    new m_iSlot = TF2_GetWeaponSlot( m_iAttacker, m_iWeapon );
                    g_iLastWeapon[m_iAttacker] = m_iWeapon;
                    if ( m_iSlot != -1 && m_bHasAttribute[m_iAttacker][m_iSlot] )
                    {

                        /* Apply Enchant Totem : Increases damage before the others modifiers.
                         *
                         * -------------------------------------------------- */
                        if ( m_bEnchantTotem_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( m_hTimers[m_iAttacker][m_hEnchantTotem_TimerDuration] != INVALID_HANDLE )
                            {
                                ClearTimer( m_hTimers[m_iAttacker][m_hEnchantTotem_TimerDuration] );
                                m_flDamage *= m_flEnchantTotem_BonusDamage[m_iAttacker][m_iSlot];
                            }
                        }

                        /* Add raw damage.
                         *
                         * -------------------------------------------------- */
                        if ( m_bNecromastery_ATTRIBUTE[m_iAttacker][m_iSlot] )
                            m_flDamage += ( m_iIntegers[m_iAttacker][m_iNecromastery_Souls] * m_flNecromastery_BonusDamage[m_iAttacker][m_iSlot] );

                        /* Apply Jinda : Increases damage and set to crit.
                         *
                         * -------------------------------------------------- */
                        if ( m_bJinada_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( m_hTimers[m_iAttacker][m_hJinada_TimerCooldown] == INVALID_HANDLE )
                            {
                                m_hTimers[m_iAttacker][m_hJinada_TimerCooldown] = CreateTimer( m_flJinada_Cooldown[m_iAttacker][m_iSlot], m_tJinada, m_iAttacker );

                                m_iType = TF_DMG_CRIT|m_iType;
                                m_flDamage *= m_flJinada_DamageMultiplier[m_iAttacker][m_iSlot];

                                EmitSoundToClient( m_iAttacker, SOUND_RADIANCE, _, _, _, _, 1.0 );
                                EmitSoundToClient( m_iVictim, SOUND_RADIANCE, _, _, _, _, 1.0 );
                                if ( m_flJinada_Cooldown[m_iAttacker][m_iSlot] != 0.0 ) PrintHintText( m_iAttacker, "Now in cooldown for %.2f seconds", m_flJinada_Cooldown[m_iAttacker][m_iSlot] );
                            }
                        }

                        /* Add raw damage that CANNOT be critical boosted.
                         *
                         * -------------------------------------------------- */
                        if ( m_bFurySwipes_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( m_hTimers[m_iVictim][m_hFurySwipes_TimerDuration] != INVALID_HANDLE )
                            {
                                ClearTimer( m_hTimers[m_iVictim][m_hFurySwipes_TimerDuration] );
                            }
                            if ( m_hTimers[m_iVictim][m_hFurySwipes_TimerDuration] == INVALID_HANDLE && m_iIntegers[m_iVictim][m_iFurySwipe_Stack] < m_iFurySwipes_MaximumStack[m_iAttacker][m_iSlot] )
                            {
                                m_iIntegers[m_iVictim][m_iFurySwipe_Stack]++;
                                m_hTimers[m_iVictim][m_hFurySwipes_TimerDuration] = CreateTimer( m_flFurySwipes_Duration[m_iAttacker][m_iSlot], m_tFurySwipes, m_iVictim );
                            }

                            new Float:m_flEnrage = 1.0;
                            if ( m_bEnrage_ATTRIBUTE[m_iAttacker][m_iSlot] && m_hTimers[m_iAttacker][m_hEnrage_TimerDuration] != INVALID_HANDLE ) m_flEnrage = m_flEnrage_FurySwipeMultiplier[m_iAttacker][m_iSlot];

                            m_flDamage += ( ( ( m_iIntegers[m_iVictim][m_iFurySwipe_Stack] * m_flFurySwipes_BonusDamage[m_iAttacker][m_iSlot] ) * m_flEnrage ) / ( m_iType & TF_DMG_CRIT ? 3.0 : 1.0 ) );
                        }
                    //-//
                        if ( m_bBash_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            // Bash uses Pseudo-Random Distribution, unlike any other chance based attributes. My PRD is really BAD, WC3's PRD is the real one but I can't find it.
                            // - PRD decreases the base chance set on your weapon by 8.125% + X.
                            // - Not proccing the bash will increase the chance for the next attack by X.
                            static m_iPRD_Stack[MAXPLAYERS + 1];
                            static Float:m_flPRD_StackBad[MAXPLAYERS + 1];

                            if ( m_iPRD_Stack[m_iAttacker] < 1 ) m_iPRD_Stack[m_iAttacker] = 1;
                            if ( m_flPRD_StackBad[m_iAttacker] > 0.8 ) m_flPRD_StackBad[m_iAttacker] = 0.8;

                            new Float:m_flBashChanceReduced = ( m_flBash_Chance[m_iAttacker][m_iSlot] * 0.941008 );
                            new Float:m_flBadPRDChance = ( ( ( m_flBashChanceReduced * ( 1.0 + ( m_flBashChanceReduced * 8.0 ) ) ) / 8.0 ) * ( m_iPRD_Stack[m_iAttacker] - m_flPRD_StackBad[m_iAttacker] ) );   // ◄ X
                                
                            if ( m_flBadPRDChance >= GetRandomFloat( 0.0, 1.0 ) )
                            {
                                m_iPRD_Stack[m_iAttacker] = 1;
                                m_flPRD_StackBad[m_iAttacker] += 0.1;

                                if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) ) m_flDamage += ( m_flBash_BonusDamage[m_iAttacker][m_iSlot] / 3.0 );
                                else m_flDamage += m_flBash_BonusDamage[m_iAttacker][m_iSlot];

                                if ( m_flBash_Duration[m_iAttacker][m_iSlot] != 0.0 ) {
                                    if ( m_flBash_Duration[m_iAttacker][m_iSlot] < 0.5 && !HasInvulnerabilityCond( m_iVictim ) ) { // Low stun duration shouldn't pierce Übercharge.
                                        TF2_StunPlayer( m_iVictim, m_flBash_Duration[m_iAttacker][m_iSlot], 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iAttacker );
                                    }
                                    else if ( m_flBash_Duration[m_iAttacker][m_iSlot] >= 0.5 ) TF2_StunPlayer( m_iVictim, m_flBash_Duration[m_iAttacker][m_iSlot], 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iAttacker );
                                }

                                EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 1.0 ); // t
                                EmitSoundToClient( m_iVictim, SOUND_TBASH, _, _, _, _, 1.0 );
                            }
                            else {
                                m_iPRD_Stack[m_iAttacker]++;
                                m_flPRD_StackBad[m_iAttacker] = 0.0;
                            }
                        }

                        /* Sets.
                         *
                         * -------------------------------------------------- */
                        if ( m_bKillAtHighHealthPointsThreshold_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( GetClientHealth( m_iVictim ) >= ( m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] >= 10.0 ? m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] : TF2_GetClientMaxHealth( m_iVictim ) * m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] ) ) {
                                TF2_RemoveCondition( m_iVictim, TFCond_Ubercharged );
                                m_flDamage = 1000000000.0;
                                m_iType = m_iType|TF_DMG_CRIT;
                            }
                        }
                    //-//
                        if ( m_bKillAtLowHealthPointsThreshold_ATTRIBUTE[m_iAttacker][m_iSlot] )
                        {
                            if ( GetClientHealth( m_iVictim ) <= ( m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] >= 1.0 ? m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] : TF2_GetClientMaxHealth( m_iVictim ) * m_flKillAtHighHealthPointsThreshold_Threshold[m_iAttacker][m_iSlot] ) ) {
                                TF2_RemoveCondition( m_iVictim, TFCond_Ubercharged );
                                m_flDamage = 1000000000.0;
                                m_iType = m_iType|TF_DMG_CRIT;
                            }
                        }
                    }
                }

                /* Blade Mail, reflect damage before damage manipulation and damage reduction, which in tf2 means : damage randomness and distance stuff.
                 *
                 * -------------------------------------------------- */
                if ( HasAttribute( m_iVictim, _, m_bBladeMail_ATTRIBUTE ) && !( m_iType & DOTA_DMG_BLADEMAIL ) ) // Doesn't proc on itself, bad idea.
                {
                    EmitSoundToClient( m_iAttacker, SOUND_REFLECT, _, _, _, _, 0.3, 40 );
                    EmitSoundToClient( m_iVictim, SOUND_REFLECT, _, _, _, _, 0.3, 40 );

                    DealDamage( m_iAttacker, RoundToFloor( m_flDamage * GetAttributeValueF( m_iVictim, _, m_bBladeMail_ATTRIBUTE, m_flBladeMail_Multiplier ) ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL|( m_iType & TF_DMG_BULLET ? HL_DMG_GENERIC : m_iType ), "mannpower_reflect" );
                    if ( TF2_GetPlayerClass( m_iAttacker ) == TFClass_Pyro ) TF2_RemoveCondition( m_iAttacker, TFCond_OnFire );
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bReturn_ATTRIBUTE ) && !( m_iType & DOTA_DMG_BLADEMAIL ) && !( m_iType & DOTA_DMG_DISPERSION ) && !( m_iType & DOTA_DMG_OTHER ) )
                {
                    new dmg = GetAttributeValueI( m_iVictim, _, m_bReturn_ATTRIBUTE, m_iReturn_BaseDamage ) + RoundToFloor( ( TF2_GetClientMaxHealth( m_iVictim ) / 12.0 ) * GetAttributeValueF( m_iVictim, _, m_bReturn_ATTRIBUTE, m_flReturn_Damage ) );
                    DealDamage( m_iAttacker, ( m_iType & TF_DMG_FIRE ? RoundToFloor( dmg / 3.33333333334 ) : dmg ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_OTHER, "mannpower_supernova" );
                    //SDKHooks_TakeDamage( m_iAttacker, m_iVictim, m_iVictim, ( m_iType & TF_DMG_FIRE ? dmg / 3.33333333334 : float( dmg ) ), TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_OTHER );
                    EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 1.0 );
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bCraggyExterior_ATTRIBUTE ) && !( m_iType & DOTA_DMG_BLADEMAIL ) && !( m_iType & DOTA_DMG_DISPERSION ) && !( m_iType & DOTA_DMG_OTHER ) )
                {
                    new Float:m_flPos1[3], Float:m_flPos2[3];
                    GetClientAbsOrigin( m_iAttacker, m_flPos2 );
                    GetClientAbsOrigin( m_iVictim, m_flPos1 );

                    new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                    if ( distance < GetAttributeValueF( m_iVictim, _, m_bCraggyExterior_ATTRIBUTE, m_flCraggyExterior_Radius ) )
                    {
                        if ( GetAttributeValueF( m_iVictim, _, m_bCraggyExterior_ATTRIBUTE, m_flCraggyExterior_Chance ) >= GetRandomFloat( 0.0, 1.0 ) )
                        {
                            new dmg = GetAttributeValueI( m_iVictim, _, m_bCraggyExterior_ATTRIBUTE, m_iCraggyExterior_Damage );
                            new Float:dur = GetAttributeValueF( m_iVictim, _, m_bCraggyExterior_ATTRIBUTE, m_flCraggyExterior_Duration );
                            DealDamage( m_iAttacker, ( m_iType & TF_DMG_FIRE ? RoundToFloor( dmg / 3.33333333334 ) : dmg ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_OTHER, "mannpower_supernova" );
 
                            if ( dur != 0.0 ) {
                                TF2_StunPlayer( m_iAttacker, dur, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iVictim );
                                PrintHintText( m_iAttacker, "Stunned for %.2f seconds", dur );
                            }

                            EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 1.0 );
                        }
                    }
                }

                if ( m_flFloats[m_iAttacker][m_flDuel_Bonus] >= 1.0 )
                    m_flDamage += m_flFloats[m_iAttacker][m_flDuel_Bonus];
            }
        }

        /* Dispersion, reflect and reduce damage before damage manipulation and damage reduction, which in tf2 means : damage randomness and distance stuff.
         *
         * -------------------------------------------------- */
        if ( HasAttribute( m_iVictim, _, m_bDispersion_ATTRIBUTE ) )
        {
            if ( !( m_iType & DOTA_DMG_BLADEMAIL ) && !( m_iType & DOTA_DMG_DISPERSION ) )
            {
                for ( new i = 1; i <= MaxClients; i++ )
                {
                    if ( i != m_iVictim && IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iVictim ) )
                    {
                        new Float:m_flPos1[3];
                        GetClientAbsOrigin( m_iVictim, m_flPos1 );
                        new Float:m_flPos2[3];
                        GetClientAbsOrigin( i, m_flPos2 );

                        new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                        if ( distance < GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxRadius ) )
                        {
                            if ( IsValidClient( m_iAttacker ) && GetClientTeam( m_iAttacker ) == GetClientTeam( m_iVictim ) && m_iAttacker != m_iVictim ) m_flDamage = 0.0;
                            // Why this ? Because grenades, stickies and rockets( ? ) actually DOES damage to their allies ( NO FRIENDLY FIRE ), I noticed this while testing Dispersion near enemies, I 'took' 100 damages from a friendly demoman and it reflected 100 damage to the enemies.

                            if ( m_flDamage >= 1.0 )
                            {
                                new Float:m_flReflect;

                                if ( distance <= ( GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxRadius ) * GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MinRadius ) ) )
                                    m_flReflect = m_flDamage * GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxDamage );
                                else {
                                    new Float:m_flDiff = GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxRadius ) - distance;
                                    new Float:m_flDiv = m_flDiff / ( GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxRadius ) * ( 1 - GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MinRadius ) ) );
                                    m_flReflect = m_flDamage * ( m_flDiv * GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxDamage ) );
                                }
                                //if ( m_iType & TF_DMG_CRIT ) m_flReflect /= 3.0;
                                if ( m_flReflect < 0.0 ) m_flReflect = 0.0;
                                DealDamage( i, RoundToFloor( m_flReflect ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_DISPERSION|( m_iType & TF_DMG_BULLET ? HL_DMG_GENERIC : m_iType ), "mannpower_reflect" );
                                EmitSoundToClient( m_iVictim, SOUND_REFLECT, _, _, _, _, 0.3, 40 );
                            }
                        }
                    }
                }
            }
            m_flDamage *= ( 1.0 - GetAttributeValueF( m_iVictim, _, m_bDispersion_ATTRIBUTE, m_flDispersion_MaxDamage ) );
        }
    //-//
        if ( HasAttribute( m_iVictim, _, m_bEnrage_ATTRIBUTE ) && m_hTimers[m_iVictim][m_hEnrage_TimerDuration] != INVALID_HANDLE )
            m_flDamage *= GetAttributeValueF( m_iVictim, _, m_bEnrage_ATTRIBUTE, m_flEnrage_Resistance );

        if ( IsValidClient( m_iAttacker )
            && m_iAttacker != m_iVictim
            && m_flDamage >= 1.0 )
        {

            /* Desolator, increases player's damage.
             *
             * -------------------------------------------------- */
            if ( m_hTimers[m_iVictim][m_hDesolator_TimerDuration] != INVALID_HANDLE )
                m_flDamage *= m_flFloats[m_iVictim][m_flDesolator_DamageAmplification];

            /* Block Damage, decreases player's damage.
             *
             * -------------------------------------------------- */
            if ( HasAttribute( m_iVictim, _, m_bBlockDamage_ATTRIBUTE ) && !( m_iType & DOTA_DMG_BLADEMAIL ) && !( m_iType & DOTA_DMG_DISPERSION ) && !( m_iType & DOTA_DMG_OTHER ) )
            {
                if ( GetAttributeValueF( m_iVictim, _, m_bBlockDamage_ATTRIBUTE, m_flBlockDamage_Chance ) >= GetRandomFloat( 0.0, 1.0 ) )
                    m_flDamage -= GetAttributeValueF( m_iVictim, _, m_bBlockDamage_ATTRIBUTE, m_flBlockDamage_Block );
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
        && IsValidClient( m_iVictim )
        && IsValidClient( m_iAttacker )
        && m_iAttacker != m_iVictim
        && m_iWeapon != -1 )
    {
        new m_iSlot = TF2_GetWeaponSlot( m_iAttacker, m_iWeapon );
        if ( m_iSlot != -1 && m_bHasAttribute[m_iAttacker][m_iSlot] )
        {
            if ( m_bLifesteal_ATTRIBUTE[m_iAttacker][m_iSlot] )
                TF2_HealPlayer( m_iAttacker, m_flDamage * m_flLifesteal_Percentage[m_iAttacker][m_iSlot], m_flLifesteal_OverHealBonusCap[m_iAttacker][m_iSlot], true );
        //-//
            if ( m_bLifestealOnCrit_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) )
                    TF2_HealPlayer( m_iAttacker, m_flDamage * m_flLifestealOnCrit_Percentage[m_iAttacker][m_iSlot], m_flLifestealOnCrit_OverHealBonusCap[m_iAttacker][m_iSlot], true );
            }
        //-//
            if ( m_bOverPower_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                if ( m_iIntegers[m_iAttacker][m_iOverpower_RemainingHit] > 0 )
                    m_iIntegers[m_iAttacker][m_iOverpower_RemainingHit]--;
            }
        //-//
            if ( m_bFervor_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                new m_iWeapon3 = TF2_GetClientActiveWeapon( m_iAttacker );

                if ( !( TF2Attrib_GetByName( m_iWeapon3, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon3, "fire rate bonus", m_flFervor_OldAttackSpeed[m_iAttacker][m_iSlot] );
                new Float:m_flAttackSpeed;
                new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon3, "fire rate bonus" );
                if ( m_aAttribute != Address_Null ) {
                    m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
                }
                new Float:m_flValue = m_flFervor_AttackSpeed[m_iAttacker][m_iSlot];

                if ( m_bBools[m_iVictim][m_bIsFervor_On] )
                {
                    if ( m_iIntegers[m_iAttacker][m_iFervor_Stack] >= 1 )
                    {
                        m_iIntegers[m_iAttacker][m_iFervor_Stack]++;

                        if ( m_iIntegers[m_iAttacker][m_iFervor_Stack] > m_iFervor_MaximumStack[m_iAttacker][m_iSlot] )
                        {
                            m_iIntegers[m_iAttacker][m_iFervor_Stack] = m_iFervor_MaximumStack[m_iAttacker][m_iSlot];
                        }
                        else {
                            if ( HasAttribute( m_iAttacker, _, m_bFervor_ATTRIBUTE, true ) )
                            {
                                TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", m_flAttackSpeed-m_flValue );
                            }
                        }
                    } else {
                        m_iIntegers[m_iAttacker][m_iFervor_Stack] = 1;
                        TF2Attrib_SetByName( m_iWeapon3, "fire rate bonus", m_flAttackSpeed-m_flValue );
                    }
                } else {
                    static m_iOldVictim;
                    //for ( new i = 1; i <= MaxClients; i++ ) m_bBools[i][m_bIsFervor_On] = false;
                    if ( IsValidClient( m_iOldVictim ) && m_iOldVictim != m_iVictim ) m_bBools[m_iOldVictim][m_bIsFervor_On] = false;

                    m_bBools[m_iVictim][m_bIsFervor_On] = true;
                    m_iIntegers[m_iAttacker][m_iFervor_Stack] = 1;
                    TF2Attrib_SetByName( m_iWeapon3, "fire rate bonus", m_flFervor_OldAttackSpeed[m_iAttacker][m_iSlot] );
                    m_iOldVictim = m_iVictim;
                }
            }
        //-//
            if ( m_bEvasionAW2_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                if ( m_flFloats[m_iAttacker][m_flEvasionChance_AW2] < 1.0 )
                {
                    m_flFloats[m_iAttacker][m_flEvasionChance_AW2] += m_flEvasionAW2_Add[m_iAttacker][m_iSlot];
                    if ( m_flFloats[m_iAttacker][m_flEvasionChance_AW2] > 1.0 ) m_flFloats[m_iAttacker][m_flEvasionChance_AW2] = 1.0;
                }
            }
        //-//
            if ( m_bDuel_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                if ( m_hTimers[m_iAttacker][m_hDuel_TimerCooldown] == INVALID_HANDLE && m_bBools[m_iAttacker][m_bDuel_ReadyForIt] )
                {
                    m_hTimers[m_iAttacker][m_hDuel_TimerCooldown] = CreateTimer( m_flDuel_Cooldown[m_iAttacker][m_iSlot], m_tDuel_Cooldown, m_iAttacker );

                    if ( m_hTimers[m_iAttacker][m_hDuel_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iAttacker][m_hDuel_TimerDuration] );
                    if ( m_hTimers[m_iAttacker][m_hDuel_TimerDuration] == INVALID_HANDLE ) {
                        m_hTimers[m_iAttacker][m_hDuel_TimerDuration] = CreateTimer( m_flDuel_Duration[m_iAttacker][m_iSlot], m_tDuel_Duration, m_iAttacker );
                    }

                    g_pDuelist[m_iAttacker] = m_iVictim;
                    m_bBools[m_iAttacker][m_bDuel_ReadyForIt] = false;
                    m_bBools[m_iVictim][m_bIsDuel_On] = true;

                    new Float:flPos1[3];
                    GetClientEyePosition( m_iAttacker, flPos1 );
                    new Float:flPos2[3];
                    GetClientEyePosition( m_iVictim, flPos2 );

                    AttachParticle( m_iAttacker, ( GetClientTeam( m_iAttacker ) == 2 ? "duel_red" : "duel_blue" ), 3.0, flPos1 );
                    AttachParticle( m_iVictim, ( GetClientTeam( m_iVictim ) == 2 ? "duel_red" : "duel_blue" ), 3.0, flPos2 );
                }
            }
        //-//
            if ( m_bDesolator_ATTRIBUTE[m_iAttacker][m_iSlot] )
            {
                m_flFloats[m_iVictim][m_flDesolator_DamageAmplification] = m_flDesolator_DamageAmp[m_iAttacker][m_iSlot];

                if ( m_hTimers[m_iVictim][m_hDesolator_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iVictim][m_hDesolator_TimerDuration] );
                if ( m_hTimers[m_iVictim][m_hDesolator_TimerDuration] == INVALID_HANDLE ) {
                    m_hTimers[m_iVictim][m_hDesolator_TimerDuration] = CreateTimer( m_flDesolator_Duration[m_iAttacker][m_iSlot], m_tDesolator, m_iVictim );
                }
            }
        }
    }
    if ( m_flDamage < 0.0 ) m_flDamage = 0.0;

    m_aAction = Plugin_Changed;
    return m_aAction;
}

// ====[ CALC IS ATTACK CRITICAL ]=====================================
public Action:TF2_CalcIsAttackCritical( m_iClient, m_iWeapon, String:m_strName[], &bool:m_bResult )
{
    if ( IsValidClient( m_iClient )
        && IsPlayerAlive( m_iClient ) )
    {
        if ( HasAttribute( m_iClient, _, m_bStaticField_ATTRIBUTE ) )
        {
            for ( new i = 1; i <= MaxClients; i++ )
            {
                if ( i != m_iClient && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iClient ) )
                {
                    new Float:m_flPos1[3];
                    GetClientAbsOrigin( m_iClient, m_flPos1 );
                    new Float:m_flPos2[3];
                    GetClientAbsOrigin( i, m_flPos2 );
                   
                    new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                    if ( distance <= GetAttributeValueF( m_iClient, _, m_bStaticField_ATTRIBUTE, m_flStaticField_Radius ) )
                    {
                        new m_iDamage = RoundToFloor( GetAttributeValueF( m_iClient, _, m_bStaticField_ATTRIBUTE, m_flStaticField_DamagePct ) * GetClientHealth( i ) );
                        DealDamage( i, ( m_iDamage > 0 ? m_iDamage : 1 ), m_iClient, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_OTHER );
                    }
                }
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
    new bool:m_bFeignDeath = bool:( GetEventInt( m_hEvent, "death_flags" ) & TF_DEATHFLAG_DEADRINGER );

    if ( IsValidClient( m_iVictim ) )
    {
        if ( m_iVictim && !m_bFeignDeath )
        {
            if ( HasAttribute( m_iVictim, _, m_bLastWill_ATTRIBUTE ) ) {
                if ( IsValidClient( m_iKiller ) && m_iVictim != m_iKiller ) DealDamage( m_iKiller, GetAttributeValueI( m_iVictim, _, m_bLastWill_ATTRIBUTE, m_iLastWill_Damage ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
            }
        //-//
            if ( HasAttribute( m_iVictim, _, m_bNecromastery_ATTRIBUTE ) )
            {
                if ( GetAttributeValueF( m_iVictim, _, m_bNecromastery_ATTRIBUTE, m_flNecromastery_Removal ) < 1.0 && m_iIntegers[m_iVictim][m_iNecromastery_Souls] > 1 ) {
                    m_iIntegers[m_iVictim][m_iNecromastery_Souls] = RoundToCeil( m_iIntegers[m_iVictim][m_iNecromastery_Souls] * GetAttributeValueF( m_iVictim, _, m_bNecromastery_ATTRIBUTE, m_flNecromastery_Removal ) );
                }
            }
        //-//
            if ( HasAttribute( m_iVictim, _, m_bDuel_ATTRIBUTE ) ) // If the victim is the one having the attribute = The DUELIST won.
            {
                if ( m_hTimers[m_iVictim][m_hDuel_TimerDuration] != INVALID_HANDLE && IsValidClient( m_iKiller ) && m_bBools[m_iKiller][m_bIsDuel_On] )
                {
                    m_flFloats[m_iKiller][m_flDuel_Bonus] += GetAttributeValueF( m_iVictim, _, m_bDuel_ATTRIBUTE, m_flDuel_DamageBonus );
                    g_pDuelist[m_iVictim] = -1;
                    // Here, g_pDuelist[m_iVictim] IS THE KILLER.
                    // And, m_iVictim IS THE VICTIM.
                }
            }
        //-//
            if ( HasAttribute( m_iVictim, _, m_bBloodstone_ATTRIBUTE ) )
            {
                for ( new i = 1; i <= MaxClients; i++ ) // Checks every client.
                {
                    if ( IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) == GetClientTeam( m_iVictim ) )
                    {
                        new Float:m_flPos1[3];
                        GetClientAbsOrigin( m_iVictim, m_flPos1 );
                        new Float:m_flPos2[3];
                        GetClientAbsOrigin( i, m_flPos2 );

                        new Float:m_flHealed = GetAttributeValueF( m_iVictim, _, m_bBloodstone_ATTRIBUTE, m_flBloodstone_BaseHeal ) + ( 0.0+m_iIntegers[m_iVictim][m_iBloodstone_Charge] * GetAttributeValueF( m_iVictim, _, m_bBloodstone_ATTRIBUTE, m_flBloodstone_HealPerCharge ) );

                        new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                        if ( distance <= GetAttributeValueF( m_iVictim, _, m_bBloodstone_ATTRIBUTE, m_flBloodstone_HealRadius ) )
                            TF2_HealPlayer( i, m_flHealed, 0.66666666666666667, true );
                    }
                }
                m_iIntegers[m_iVictim][m_iBloodstone_Charge] = RoundToCeil( m_iIntegers[m_iVictim][m_iBloodstone_Charge] / 2.0 );
            }
        //-//
            for ( new i = 1; i <= MaxClients; i++ ) // Checks every client.
            {
                if ( IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iVictim ) && i != m_iKiller )
                {
                    new Float:m_flPos1[3];
                    GetClientAbsOrigin( m_iVictim, m_flPos1 );
                    new Float:m_flPos2[3];
                    GetClientAbsOrigin( i, m_flPos2 );
                    new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );

                    if ( HasAttribute( i, _, m_bBloodbath_ATTRIBUTE ) )
                    {
                        new Float:m_flHealed = 0.0+TF2_GetClientMaxHealth( m_iVictim ) * GetAttributeValueF( i, _, m_bBloodbath_ATTRIBUTE, m_flBloodbath_Heal );
                                            
                        if ( distance <= GetAttributeValueF( i, _, m_bBloodbath_ATTRIBUTE, m_flBloodbath_Radius )  )
                            TF2_HealPlayer( i, m_flHealed, 0.66666666666666667, true );
                    }
                    if ( HasAttribute( i, _, m_bBloodstone_ATTRIBUTE ) )
                    {
                        if ( distance <= GetAttributeValueF( i, _, m_bBloodstone_ATTRIBUTE, m_flBloodstone_ChargeRadius ) )
                            m_iIntegers[i][m_iBloodstone_Charge]++;
                    }
                }
            }
        //-//
            for ( new i = 0; i < m_hTimer; i++ )
            {
                ClearTimer( m_hTimers[m_iVictim][i] );
            }
            for ( new i = 0; i < m_bBool-1; i++ )
            {
                m_bBools[m_iVictim][i] = false;
            }
            for ( new i = 0; i < m_flFloat-1; i++ )
            {
                m_flFloats[m_iVictim][i] = 0.0;             //DON'T remove duel bonus.
            }
            for ( new i = 0; i < m_iInteger-2; i++ )
            {
                m_iIntegers[m_iVictim][i] = 0;
            }
        }
        if ( m_iKiller != m_iVictim )
        {
            if ( IsValidClient( m_iKiller ) )
            {
                new m_iWeapon = -1;
                new m_iSlot = -1;
                if ( g_iLastWeapon[m_iKiller] != -1 ) {
                    m_iWeapon = g_iLastWeapon[m_iKiller];
                    if ( m_iWeapon != -1 ) m_iSlot = TF2_GetWeaponSlot( m_iKiller, m_iWeapon );
                }
                if ( HasAttribute( m_iKiller, _, m_bNecromastery_ATTRIBUTE ) )
                {
                    new act = GetAttributeValueI( m_iKiller, _, m_bNecromastery_ATTRIBUTE, m_iNecromastery_PoA );
                    new max_souls = GetAttributeValueI( m_iKiller, _, m_bNecromastery_ATTRIBUTE, m_iNecromastery_MaximumStack );
                    if ( act == 0
                      || m_iWeapon != -1 && m_iSlot != -1 && m_bHasAttribute[m_iKiller][m_iSlot] && m_bNecromastery_ATTRIBUTE[m_iKiller][m_iSlot] && act == 1 )
                    {
                        m_iIntegers[m_iKiller][m_iNecromastery_Souls]++;
                        if ( m_iIntegers[m_iKiller][m_iNecromastery_Souls] > max_souls ) m_iIntegers[m_iKiller][m_iNecromastery_Souls] = max_souls;
                    }
                }
            //-//
                if ( HasAttribute( m_iKiller, _, m_bBloodbath_ATTRIBUTE ) )
                {
                    new Float:m_flHealed = 0.0+TF2_GetClientMaxHealth( m_iVictim ) * GetAttributeValueF( m_iKiller, _, m_bBloodbath_ATTRIBUTE, m_flBloodbath_Heal );
                    TF2_HealPlayer( m_iKiller, m_flHealed, _, true );
                }
            //-//
                if ( HasAttribute( m_iKiller, _, m_bDuel_ATTRIBUTE ) )
                {
                    if ( m_hTimers[m_iKiller][m_hDuel_TimerDuration] != INVALID_HANDLE && m_bBools[m_iVictim][m_bIsDuel_On] )
                    {
                        m_flFloats[m_iKiller][m_flDuel_Bonus] += GetAttributeValueF( m_iKiller, _, m_bDuel_ATTRIBUTE, m_flDuel_DamageBonus );
                        ClearTimer( m_hTimers[m_iKiller][m_hDuel_TimerDuration] );
                        m_bBools[m_iVictim][m_bIsDuel_On] = false;
                        g_pDuelist[m_iKiller] = -1;
                        // Here, g_pDuelist[m_iKiller] IS THE VICTIM.
                        // And, m_iKiller IS THE KILLER.
                    }
                }
            //-//
                if ( HasAttribute( m_iKiller, _, m_bBloodstone_ATTRIBUTE ) )
                    m_iIntegers[m_iKiller][m_iBloodstone_Charge]++;
            }
        }
    }
    return Plugin_Continue;
}

// ====[ ON ENTITY CREATED ]===========================================
public OnEntityCreated( m_iEntity, const String:m_strClassname[] ) // Thanks 11530 for Projectile Particles.
{
    if ( IsValidEntity( m_iEntity ) && IsValidEdict( m_iEntity ) )
        SDKHook( m_iEntity, SDKHook_Spawn, OnEntitySpawned );
}

// ====[ ON ENTITY SPAWNED ]===========================================
public OnEntitySpawned( m_iEntity )
{
    new m_iClient = GetEntPropEnt( m_iEntity, Prop_Data, "m_hOwnerEntity" );

    if ( IsValidClient( m_iClient ) && HasAttribute( m_iClient, _, m_bDesolator_ATTRIBUTE, true ) )
        AddParticle( m_iClient, m_iEntity, PARTICLE_DESOLATOR, 5 );
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
public Action:m_tRadiance( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bRadiance_ATTRIBUTE ) )
    {
        if ( IsValidClient( m_iClient ) )
        {
            new Float:m_flPos1[3];
            GetClientEyePosition( m_iClient, m_flPos1 );
            m_flPos1[2] -= 30.0;

            for ( new i = 1; i <= MaxClients; i++ )
            {
                if ( i != m_iClient && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iClient ) )
                {
                    if ( !HasInvulnerabilityCond( i ) )
                    {
                        new Float:m_flPos2[3];
                        GetClientEyePosition( i, m_flPos2 );
                        m_flPos2[2] -= 30.0;
                        
                        new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                        if ( distance <= GetAttributeValueF( m_iClient, _, m_bRadiance_ATTRIBUTE, m_flRadiance_Radius ) )
                        {
                            decl Handle:m_hSee;
                            ( m_hSee = INVALID_HANDLE );

                            m_hSee = TR_TraceRayFilterEx( m_flPos1, m_flPos2, MASK_SOLID, RayType_EndPoint, TraceFilterPlayer, m_iClient );
                            if ( m_hSee != INVALID_HANDLE )
                            {
                                if ( !TR_DidHit( m_hSee ) )
                                {
                                    DealDamage( i, GetAttributeValueI( m_iClient, _, m_bRadiance_ATTRIBUTE, m_iRadiance_Damage ), m_iClient, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_OTHER, "firedeath" );
                                    if ( !TF2_IsPlayerInCondition( i, TFCond_Cloaked ) && !TF2_IsPlayerInCondition( i, TFCond_Disguised ) )
                                    {
                                        EmitSoundToClient( m_iClient, SOUND_RADIANCE, _, _, _, _, 0.05, 10 );
                                        EmitSoundToClient( i, SOUND_RADIANCE, _, _, _, _, 0.1, 10 );
                                    }
                                    else EmitSoundToClient( i, SOUND_RADIANCE, _, _, _, _, 0.2, 10 );
                                }
                            }

                            CloseHandle( m_hSee );
                        }
                    }
                }
            }
        }
    }
    m_hTimers[m_iClient][m_hRadiance_TimerInterval] = INVALID_HANDLE;
}
public Action:m_tRadiance_SubAbility_MissLinger( Handle:timer, any:m_iClient )
{
    m_bBools[m_iClient][m_bRadiance_SubAbilityActive] = false;
    m_flFloats[m_iClient][m_flRadiance_SubAbilityChance] = 0.0;
    m_hTimers[m_iClient][m_hRadiance_MissLinger] = INVALID_HANDLE;
}
public Action:m_tEnchantTotem( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bEnchantTotem_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Enchant Totem is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hEnchantTotem_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tEnchantTotem_Duration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bEnchantTotem_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Bonus damage lost." );
        EmitSoundToClient( m_iClient, SOUND_NOTREADY );
    }

    m_hTimers[m_iClient][m_hEnchantTotem_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tJinada( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bJinada_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Jinada is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hJinada_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tOverPower_Duration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bOverPower_ATTRIBUTE ) )
    {
        for ( new slot = 0; slot <= 2; slot++ )
        {
            if ( HasAttribute( m_iClient, slot, m_bOverPower_ATTRIBUTE ) ) {
                TF2Attrib_SetByName( GetPlayerWeaponSlot( m_iClient, slot ), "fire rate bonus", GetAttributeValueF( m_iClient, _, m_bOverPower_ATTRIBUTE, m_flOverPower_OldAttackSpeed ) );
            }
        }
        PrintHintText( m_iClient, "Custom: Fire rate bonus lost." );
        EmitSoundToClient( m_iClient, SOUND_NOTREADY );
    }

    m_iIntegers[m_iClient][m_iOverpower_RemainingHit] = 0;
    m_hTimers[m_iClient][m_hOverPower_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tOverPower_Cooldown( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bOverPower_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Overpower is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hOverPower_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tEnrage_Cooldown( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bEnrage_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Enrage is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hEnrage_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tEnrage_Duration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bEnrage_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Enrage ended." );
        EmitSoundToClient( m_iClient, SOUND_NOTREADY );
    }

    m_hTimers[m_iClient][m_hEnrage_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tInnerVitality_Cooldown( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bInnerVitality_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Inner Vitality is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hInnerVitality_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tInnerVitality_Duration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bInnerVitality_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Inner Vitality ended." );
        EmitSoundToClient( m_iClient, SOUND_NOTREADY );
    }

    m_hTimers[m_iClient][m_hInnerVitality_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tFurySwipes( Handle:timer, any:m_iVictim )
{
    m_iIntegers[m_iVictim][m_iFurySwipe_Stack] = 0;
    m_hTimers[m_iVictim][m_hFurySwipes_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tDesolator( Handle:timer, any:m_iVictim )
{
    m_flFloats[m_iVictim][m_flDesolator_DamageAmplification] = 1.0;
    m_hTimers[m_iVictim][m_hDesolator_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tDuel_Cooldown( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bDuel_ATTRIBUTE ) && IsPlayerAlive( m_iClient ) )
    {
        PrintHintText( m_iClient, "Custom: Duel is ready." );
        EmitSoundToClient( m_iClient, SOUND_READY );
    }

    m_hTimers[m_iClient][m_hDuel_TimerCooldown] = INVALID_HANDLE;
}
public Action:m_tDuel_Duration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bDuel_ATTRIBUTE ) )
    {
        if ( IsPlayerAlive( m_iClient ) ) {
            PrintHintText( m_iClient, "Custom: Duel done." );
            EmitSoundToClient( m_iClient, SOUND_NOTREADY );
        }
        m_bBools[g_pDuelist[m_iClient]][m_bIsDuel_On] = false;
        g_pDuelist[m_iClient] = -1;
    }

    m_hTimers[m_iClient][m_hDuel_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tDuel_Enable( Handle:timer, any:m_iClient )
{
    m_hTimers[m_iClient][m_hDuel_TimerEnable] = INVALID_HANDLE;
}
// Super timer.
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
