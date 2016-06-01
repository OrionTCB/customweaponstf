#pragma semicolon 1
// ====[ hi ok ]=======================================================
// ====[ INCLUDES ]====================================================
#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <sdkhooks>
#include <customweaponstf>
#include <customweaponstf_orionstock>
#include <time>
//#include <cw3-attributes>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_VERSION                "1.03"

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
    name           = "Custom Weapons: Orion's Attributes",
    author         = "Orion",
    description    = "Custom Weapons: Orion's Attributes.",
    version        = PLUGIN_VERSION,
    url            = "https://forums.alliedmods.net/showpost.php?p=2193855&postcount=254"
};

// ====[ VARIABLES ]===================================================
new bool:m_bHasAttribute[2049];

enum
{
    Handle:m_hBerserker_TimerDuration = 0,
    Handle:m_hDrainMetal_TimerDelay,
    Handle:m_hInfiniteAfterburn_TimerDuration,
    Handle:m_hLowBerserker_TimerDuration,
    Handle:m_hMarkVictimDamage_TimerDuration,
    Handle:m_hMCFRTD_TimerDelay,
    Handle:m_hPsycho_TimerDuration,
    Handle:m_hStealDamageA_TimerDuration,
    Handle:m_hStealDamageV_TimerDuration,
    Handle:m_hTimer
};
new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];
enum
{
    m_bBackstab_SuicideBlocker = 0,
    m_bBuffDeployed,
    m_bInfiniteAfterburnRessuply,
    m_bIsHeat,
    m_bIsHeatToo,
    m_bLastWasMiss,
    m_bBool
};
new bool:m_bBools[MAXPLAYERS + 1][m_bBool];
enum
{
    m_flPsychoRegenCharge = 0,
    m_flPyschoCharge,
    m_flDamageReceived,
    m_flFloat
};
new Float:m_flFloats[MAXPLAYERS + 1][m_flFloat];
enum
{
    m_iCombo = 0,
    m_iHeat,
    m_iHeatToo,
    m_iHotSauceType,
    m_iMarkVictimDamage,
    m_iMarkVictimDamageCount,
    m_iMissStack,
    m_iOPBackstab,
    m_iStealDamageAttacker,
    m_iStealDamageVictim,
    m_iAttackSpeed,
    m_iInteger
};
new m_iIntegers[MAXPLAYERS + 1][m_iInteger];

new bool:g_hPostInventory[MAXPLAYERS + 1]   = false;
new g_iLastButtons[MAXPLAYERS + 1]          = -1;
new g_iLastWeapon[MAXPLAYERS + 1]           = -1;
new g_pBurner[MAXPLAYERS + 1]               = -1;
new g_pMarker[MAXPLAYERS + 1]               = -1;
new Handle:g_hHudText_O;


    /* On Hit
     * ---------------------------------------------------------------------- */

new bool:m_bHotSauceOnHit_ATTRIBUTE[2049];
new Float:m_flHotSauceOnHit_Duration[2049]          = {0.0, ...};
new m_iHotSauceOnHit_Type[2049]                     = {0, ...};

new bool:m_bStunOnHit_ATTRIBUTE[2049];
new Float:m_flStunOnHit_Duration[2049]              = {0.0, ...};

new bool:m_bDrainUbercharge_ATTRIBUTE[2049];
new Float:m_flDrainUbercharge_Percentage[2049]      = {0.0, ...};

new bool:m_bMetalOnHit_ATTRIBUTE[2049];
new Float:m_flMetalOnHit_Amount[2049]               = {0.0, ...};

new bool:m_bUberchargeOnHit_ATTRIBUTE[2049];
new Float:m_flUberchargeOnHit_Amount[2049]          = {0.0, ...};

new bool:m_bRemoveBleeding_ATTRIBUTE[2049];

new bool:m_bAfterburnCLOSERANGE_ATTRIBUTE[2049];
new Float:m_flAfterburnCLOSERANGE_Duration[2049]    = {0.0, ...};
new Float:m_flAfterburnCLOSERANGE_Range[2049]       = {0.0, ...};

new bool:m_bBleedCLOSERANGE_ATTRIBUTE[2049];
new Float:m_flBleedCLOSERANGE_Duration[2049]        = {0.0, ...};
new Float:m_flBleedCLOSERANGE_Range[2049]           = {0.0, ...};

new bool:m_bMarkVictimDamage_ATTRIBUTE[2049];
new Float:m_flMarkVictimDamage_Damage[2049]         = {0.0, ...};
new Float:m_flMarkVictimDamage_Duration[2049]       = {0.0, ...};
new m_iMarkVictimDamage_MaximumDamageStack[2049]    = {0, ...};
new m_iMarkVictimDamage_MaximumVictim[2049]         = {0, ...};

new bool:m_bInfiniteAfterburn_ATTRIBUTE[2049];
new Float:m_flInfiniteAfterburn_Duration[2049]      = {0.0, ...};
new m_iInfiniteAfterburn_Ressuply[2049]             = {0, ...};

// - Share damage ( victim | attacker ).
// - The attacker deals 50% more damage BUT takes 33% more damage.
// - WHILE the victim deals -50% damage BUT takes -33% damage.
// - If the attacker dies from anything but himself(suicide), the victim will also die.
//new bool:m_bDeathPact_ATTRIBUTE[2049];
//new Float:m_flDeathPact_Share[2049]                                   = {0.0, ...};


    /* On Crit
     * ---------------------------------------------------------------------- */

new bool:m_bHotSauceOnCrit_ATTRIBUTE[2049];
new Float:m_flHotSauceOnCrit_Duration[2049]                 = {0.0, ...};
new m_iHotSauceOnCrit_Type[2049]                            = {0, ...};

new bool:m_bStunOnCrit_ATTRIBUTE[2049];
new Float:m_flStunOnCrit_Duration[2049]                     = {0.0, ...};

new bool:m_bDrainUberchargeOnCrit_ATTRIBUTE[2049];
new Float:m_flDrainUberchargeOnCrit_Percentage[2049]        = {0.0, ...};

new bool:m_bCritVsInvisiblePlayer_ATTRIBUTE[2049];

new bool:m_bCritVictimInMidAir_ATTRIBUTE[2049];

new bool:m_bCritVictimScared_ATTRIBUTE[2049];

new bool:m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[2049];

new bool:m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[2049];
new Float:m_flMinicritVsBurningCLOSERANGE_Range[2049]       = {0.0, ...};

new bool:m_bCritVsBurningCLOSERANGE_ATTRIBUTE[2049];
new Float:m_flCritVsBurningCLOSERANGE_Range[2049]           = {0.0, ...};

new bool:m_bCritVictimInWater_ATTRIBUTE[2049];


    /* On Attack
     * ---------------------------------------------------------------------- */

new bool:m_bDamageSelf_ATTRIBUTE[2049];
new m_iDamageSelf_Amount[2049]              = {0, ...};

new bool:m_bMetalPerShot_ATTRIBUTE[2049];
new Float:m_flMetalPerShot_Amount[2049]     = {0.0, ...};

new bool:m_bMCFRTD_ATTRIBUTE[2049];
new Float:m_flMCFRTD_AttackSpeed[2049]      = {0.0, ...};
new Float:m_flMCFRTD_OldAttackSpeed[2049]   = {0.0, ...};
new m_iMCFRTD_MaximumStack[2049]            = {0, ...};


    /* On Kill
     * ---------------------------------------------------------------------- */

new bool:m_bKillGib_ATTRIBUTE[2049];

new bool:m_bSpawnSkeletonOnKill_ATTRIBUTE[2049];
new Float:m_flSpawnSkeletonOnKill_BossChance[2049]      = {0.0, ...};
new Float:m_flSpawnSkeletonOnKill_Duration[2049]        = {0.0, ...};
new m_iSpawnSkeletonOnKill_Boss[2049]                   = {0, ...};

new bool:m_bAttackSpeedOnKill_ATTRIBUTE[2049];
new Float:m_flAttackSpeedOnKill_AttackSpeed[2049]       = {0.0, ...};
new Float:m_flAttackSpeedOnKill_OldAttackSpeed[2049]    = {0.0, ...};
new Float:m_flAttackSpeedOnKill_Removal[2049]           = {0.0, ...};
new m_iAttackSpeedOnKill_MaximumStack[2049]             = {0, ...};

new bool:m_bBANOnKillHit_ATTRIBUTE[2049];
new m_iBANOnKillHit_Duration[2049]                      = {0, ...};
new m_iBANOnKillHit_HitOrKill[2049]                     = {0, ...};
new m_iBANOnKillHit_KickOrBan[2049]                     = {0, ...};

new bool:m_bTeleportToVictimOnKill_ATTRIBUTE[2049];


    /* On Damage
     * ---------------------------------------------------------------------- */

new bool:m_bActualEnemyHealthToDamage_ATTRIBUTE[2049];
new Float:m_flActualEnemyHealthToDamage_Multiplier[2049]                = {0.0, ...};

new bool:m_bActualHealthToDamage_ATTRIBUTE[2049];
new Float:m_flActualHealthToDamage_Multiplier[2049]                     = {0.0, ...};

new bool:m_bMaximumEnemyHealthToDamage_ATTRIBUTE[2049];
new Float:m_flMaximumEnemyHealthToDamage_Multiplier[2049]               = {0.0, ...};

new bool:m_bMaximumHealthToDamage_ATTRIBUTE[2049];
new Float:m_flMaximumHealthToDamage_Multiplier[2049]                    = {0.0, ...};

new bool:m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[2049];
new Float:m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[2049]  = {0.0, ...};

new bool:m_bMissingEnemyHealthToDamage_ATTRIBUTE[2049];
new Float:m_flMissingEnemyHealthToDamage_Multiplier[2049]               = {0.0, ...};

new bool:m_bMissingHealthToDamage_ATTRIBUTE[2049];
new Float:m_flMissingHealthToDamage_Multiplier[2049]                    = {0.0, ...};

new bool:m_bDamageDoneIsSelfHurt_ATTRIBUTE[2049];
new Float:m_flDamageDoneIsSelfHurt_Multiplier[2049]                     = {0.0, ...};

new bool:m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[2049];
new Float:m_flDamageIfHealthHigherThanThreshold_BonusDamage[2049]       = {0.0, ...};
new Float:m_flDamageIfHealthHigherThanThreshold_Threshold[2049]         = {0.0, ...};

new bool:m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[2049];
new Float:m_flDamageIfHealthLowerThanThreshold_BonusDamage[2049]        = {0.0, ...};
new Float:m_flDamageIfHealthLowerThanThreshold_Threshold[2049]          = {0.0, ...};

new bool:m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[2049];
new Float:m_flDamageIfEnemyHealthHigherThanThreshold_BonusDamage[2049]  = {0.0, ...};
new Float:m_flDamageIfEnemyHealthHigherThanThreshold_Threshold[2049]    = {0.0, ...};

new bool:m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[2049];
new Float:m_flDamageIfEnemyHealthLowerThanThreshold_BonusDamage[2049]   = {0.0, ...};
new Float:m_flDamageIfEnemyHealthLowerThanThreshold_Threshold[2049]     = {0.0, ...};

new bool:m_bBackstabDamageModSubStun_ATTRIBUTE[2049];
new Float:m_flBackstabDamageModSubStun_Duration[2049]                   = {0.0, ...};
new Float:m_flBackstabDamageModSubStun_Multiplier[2049]                 = {0.0, ...};
new m_iBackstabDamageModSubStun_BlockSuicide[2049]                      = {0, ...};
new m_iBackstabDamageModSubStun_Security[2049]                          = {0, ...};

new bool:m_bCombo_ATTRIBUTE[2049];
new Float:m_flCombo_BonusDamage[2049]                                   = {0.0, ...};
new m_iCombo_Crit[2049]                                                 = {0, ...};
new m_iCombo_Hit[2049]                                                  = {0, ...};

new bool:m_bMovementSpeedToDamage_ATTRIBUTE[2049];
new Float:m_flMovementSpeedToDamage_Multiplier[2049]                    = {0.0, ...};

new bool:m_bMetalToDamage_ATTRIBUTE[2049];
new Float:m_flMetalToDamage_Multiplier[2049]                            = {0.0, ...};

new bool:m_bDamageWhenMetalRunsOut_ATTRIBUTE[2049];
new Float:m_flDamageWhenMetalRunsOut_Damage[2049]                       = {0.0, ...};

new bool:m_bMetalOnHitDamage_ATTRIBUTE[2049];
new Float:m_flMetalOnHitDamage_Multiplier[2049]                         = {0.0, ...};

new bool:m_bBonusDamageVsSapper_ATTRIBUTE[2049];
new Float:m_flBonusDamageVsSapper_Multiplier[2049]                      = {0.0, ...};

new bool:m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[2049];
new Float:m_flBonusDamageVSVictimInMidAir_Multiplier[2049]              = {0.0, ...};

new bool:m_bDamageClass_ATTRIBUTE[2049];
new Float:m_flDamageClass_Demoman[2049]                                 = {0.0, ...};
new Float:m_flDamageClass_Engineer[2049]                                = {0.0, ...};
new Float:m_flDamageClass_Heavy[2049]                                   = {0.0, ...};
new Float:m_flDamageClass_Medic[2049]                                   = {0.0, ...};
new Float:m_flDamageClass_Pyro[2049]                                    = {0.0, ...};
new Float:m_flDamageClass_Scout[2049]                                   = {0.0, ...};
new Float:m_flDamageClass_Sniper[2049]                                  = {0.0, ...};
new Float:m_flDamageClass_Soldier[2049]                                 = {0.0, ...};
new Float:m_flDamageClass_Spy[2049]                                     = {0.0, ...};

new bool:m_bBonusDamageVsVictimInWater_ATTRIBUTE[2049];
new Float:m_flBonusDamageVSVictimInWater_Multiplier[2049]               = {0.0, ...};

new bool:m_bAllDamageDoneMultiplier_ATTRIBUTE[2049];
new Float:m_flAllDamageDoneMultiplier_Multiplier[2049]                  = {0.0, ...};

new bool:m_bRandomDamage_ATTRIBUTE[2049];
new Float:m_flRandomDamage_Max[2049]                                    = {0.0, ...};
new Float:m_flRandomDamage_Min[2049]                                    = {0.0, ...};

new bool:m_bLaserWeaponDamageModifier_ATTRIBUTE[2049];
new Float:m_flLaserWeaponDamageModifier_Damage[2049]                    = {0.0, ...};

new bool:m_bStealDamage_ATTRIBUTE[2049];
new Float:m_flStealDamage_Duration[2049]                                = {0.0, ...};
new m_iStealDamage_Steal[2049]                                          = {0, ...};


    /* Heal
     * ---------------------------------------------------------------------- */

new bool:m_bHealthLifesteal_ATTRIBUTE[2049];
new Float:m_flHealthLifesteal_Multiplier[2049]                      = {0.0, ...};
new Float:m_flHealthLifesteal_OverHealBonusCap[2049]                = {0.0, ...};

new bool:m_bEnemyHealthLifesteal_ATTRIBUTE[2049];
new Float:m_flEnemyHealthLifesteal_Multiplier[2049]                 = {0.0, ...};
new Float:m_flEnemyHealthLifesteal_OverHealBonusCap[2049]           = {0.0, ...};

new bool:m_bMissingEnemyHealthLifesteal_ATTRIBUTE[2049];
new Float:m_flMissingEnemyHealthLifesteal_Multiplier[2049]          = {0.0, ...};
new Float:m_flMissingEnemyHealthLifesteal_OverHealBonusCap[2049]    = {0.0, ...};


    /* On Prethink
     * ---------------------------------------------------------------------- */

new bool:m_bMetalDrain_ATTRIBUTE[2049];
new Float:m_flMetalDrain_Amount[2049]                       = {0.0, ...};
new Float:m_flMetalDrain_Interval[2049]                     = {0.0, ...};
new m_iMetalDrain_PoA[2049]                     = {0, ...};

new bool:m_bBerserker_ATTRIBUTE[2049];
new Float:m_flBerserker_Duration[2049]                      = {0.0, ...};
new Float:m_flBerserker_Threshold[2049]                     = {0.0, ...};

new bool:m_bLowBerserker_ATTRIBUTE[2049];
new Float:m_flLowBerserker_Duration[2049]                   = {0.0, ...};
new Float:m_flLowBerserker_Threshold[2049]                  = {0.0, ...};
new m_iLowBerserker_Kill[2049]                              = {0, ...};

new bool:m_bHeatFireRate_ATTRIBUTE[2049];
new Float:m_flHeatFireRate_AttackSpeed[2049]                = {0.0, ...};
new Float:m_flHeatFireRate_Delay[2049]                      = {0.0, ...};
new Float:m_flHeatFireRate_OldAttackSpeed[2049]             = {0.0, ...};
new m_iHeatFireRate_MaximumStack[2049]                      = {0, ...};

new bool:m_bHeatDMGTaken_ATTRIBUTE[2049];
new Float:m_flHeatDMGTaken_Delay[2049]                      = {0.0, ...};
new Float:m_flHeatDMGTaken_DMG[2049]                        = {0.0, ...};
new m_iHeatDMGTaken_MaximumStack[2049]                      = {0, ...};

new bool:m_bHomingProjectile_ATTRIBUTE[2049];
new Float:m_flHomingProjectile_DetectRadius[2049]           = {0.0, ...};
new m_iHomingProjectile_Mode[2049]                          = {0, ...};
new m_iHomingProjectile_Type[2049]                          = {0, ...};

new bool:m_bDemoCharge_DamageReduction_ATTRIBUTE[2049];

new bool:m_bDemoCharge_HealthThreshold_ATTRIBUTE[2049];
new Float:m_flDemoCharge_HealthThreshold_Threshold[2049]    = {0.0, ...};
new m_iDemoCharge_HealthThreshold_Mode[2049]                = {0, ...};

new bool:m_bFragmentation_ATTRIBUTE[2049];
new Float:m_flFragmentation_Damage[2049]                    = {0.0, ...};
new Float:m_flFragmentation_Radius[2049]                    = {0.0, ...};
new m_iFragmentation_Amount[2049]                           = {0, ...};
new m_iFragmentation_Mode[2049]                             = {0, ...};

new bool:m_bDamageResistanceInvisible_ATTRIBUTE[2049];
new Float:m_flDamageResistanceInvisible_Multiplier[2049]    = {0.0, ...};

new bool:m_bSpyDetector_ATTRIBUTE[2049];
new Float:m_flSpyDetector_Radius[2049]                      = {0.0, ...};
new m_iSpyDetector_ActivePassive[2049]                      = {0, ...};
new m_iSpyDetector_Type[2049]                               = {0, ...};

new bool:m_bBuffStuff_ATTRIBUTE[2049];
new Float:m_flBuffStuff_Radius[2049]                        = {0.0, ...};
new m_iBuffStuff_ID2[2049]                                  = {0, ...};
new m_iBuffStuff_ID3[2049]                                  = {0, ...};
new m_iBuffStuff_ID4[2049]                                  = {0, ...};
new m_iBuffStuff_ID[2049]                                   = {0, ...};
new m_iBuffStuff_Mode[2049]                                 = {0, ...};

new bool:m_bCannotBeStunned_ATTRIBUTE[2049];
new m_iCannotBeStunned_Type[2049]                           = {0, ...};

new bool:m_bDisableUbercharge_ATTRIBUTE[2049];

new bool:m_bSetWeaponSwitch_ATTRIBUTE[2049];
new m_iSetWeaponSwith_Slot[2049]                            = {0, ...};

new bool:m_bBulletsPerShotBonusDynamic_ATTRIBUTE[2049];


    /* On Chance
     * ---------------------------------------------------------------------- */

new bool:m_bChanceOneShot_ATTRIBUTE[2049];
new Float:m_flChanceOneShot_Chance[2049]    = {0.0, ...};

new bool:m_bChanceIgnite_ATTRIBUTE[2049];
new Float:m_flChanceIgnite_Chance[2049]     = {0.0, ...};
new Float:m_flChanceIgnite_Duration[2049]   = {0.0, ...};

new bool:m_bChanceMadMilk_ATTRIBUTE[2049];
new Float:m_flChanceMadMilk_Chance[2049]    = {0.0, ...};
new Float:m_flChanceMadMilk_Duration[2049]  = {0.0, ...};

new bool:m_bChanceJarate_ATTRIBUTE[2049];
new Float:m_flChanceJarate_Chance[2049]     = {0.0, ...};
new Float:m_flChanceJarate_Duration[2049]   = {0.0, ...};

new bool:m_bChanceBleed_ATTRIBUTE[2049];
new Float:m_flChanceBleed_Chance[2049]      = {0.0, ...};
new Float:m_flChanceBleed_Duration[2049]    = {0.0, ...};


    /* On Damage Received
     * ---------------------------------------------------------------------- */

new bool:m_bDamageReceivedUnleashedDeath_ATTRIBUTE[2049];
new Float:m_flDamageReceivedUnleashedDeath_Percentage[2049]         = {0.0, ...};
new Float:m_flDamageReceivedUnleashedDeath_Radius[2049]             = {0.0, ...};
new m_iDamageReceivedUnleashedDeath_Backstab[2049]                  = {0, ...};
new m_iDamageReceivedUnleashedDeath_PoA[2049]           = {0, ...};

new bool:m_bReduceBackstabDamage_ATTRIBUTE[2049];
new Float:m_flReduceBackstabDamage_Percentage[2049]                 = {0.0, ...};
new m_iReduceBackstabDamage_ActOrMax[2049]                          = {0, ...};

new bool:m_bReduceHeadshotDamage_ATTRIBUTE[2049];
new Float:m_flReduceHeadshotDamage_Percentage[2049]                 = {0.0, ...};

new bool:m_bDamageResHealthMissing_ATTRIBUTE[2049];
new Float:m_flDamageResHealthMissing_ResPctPerMissingHpPct[2049]    = {0.0, ...};
new m_iDamageResHealthMissing_MaxStackOfMissingHpPct[2049]          = {0, ...};
new m_iDamageResHealthMissing_OverhealPenalty[2049]                 = {0, ...};


    /* To Activate
     * ---------------------------------------------------------------------- */

new bool:m_bPsycho_ATTRIBUTE[2049];
new Float:m_flPsycho_DamageBonus[2049]      = {0.0, ...};
new Float:m_flPsycho_DamageResistance[2049] = {0.0, ...};
new Float:m_flPsycho_Duration[2049]         = {0.0, ...};
new Float:m_flPsycho_RegenPct[2049]         = {0.0, ...};
new m_iPsycho_Melee[2049]                   = {0, ...};


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

    HookEvent( "deploy_buff_banner",         Event_BuffDeployed );
    HookEvent( "player_builtobject",         Event_BuiltObject );
    HookEvent( "player_changeclass",         Event_ChangeClass );
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
    else LogMessage( "Custom Weapons 2 ERROR : ORION : SDKHooks failed to load ! Is Sourcemod well installed ? Health based attributes won't work correctly." );

    AddCommandListener( m_cmdBackstab_SuicideBlocker, "explode" );
    AddCommandListener( m_cmdBackstab_SuicideBlocker, "joinclass" );
    AddCommandListener( m_cmdBackstab_SuicideBlocker, "jointeam" );
    AddCommandListener( m_cmdBackstab_SuicideBlocker, "kill" );
    AddCommandListener( m_cmdBackstab_SuicideBlocker, "spectate" );

    SetHudTextParams( 1.0, 0.6, 0.15, 255, 255, 255, 255 );  
    g_hHudText_O = CreateHudSynchronizer();
}

// ====[ ON CLIENT PUT IN SERVER ]=====================================
public OnClientPutInServer( m_iClient )
{
    SDKHook( m_iClient, SDKHook_OnTakeDamage,      OnTakeDamage );
    SDKHook( m_iClient, SDKHook_OnTakeDamageAlive, OnTakeDamageAlive );
    SDKHook( m_iClient, SDKHook_OnTakeDamagePost,  OnTakeDamagePost );
    SDKHook( m_iClient, SDKHook_PreThink,          OnClientPreThink );
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
            g_pBurner[i]     = -1;
            g_iLastWeapon[i] = -1;
            g_pMarker[i]     = -1;
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
    g_pBurner[m_iClient]     = -1;
    g_iLastWeapon[m_iClient] = -1;
    g_pMarker[m_iClient]     = -1;
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
            g_pBurner[i]     = -1;
            g_iLastWeapon[i] = -1;
            g_pMarker[i]     = -1;
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
            m_bBools[m_iClient][i]              = false;
        }
        for ( new i = 0; i < m_flFloat; i++ )
        {
            m_flFloats[m_iClient][i]            = 0.0;
        }
        for ( new i = 0; i < m_iInteger; i++ )
        {
            m_iIntegers[m_iClient][i]           = 0;
        }
        g_pBurner[m_iClient]     = -1;
        g_iLastWeapon[m_iClient] = -1;
        g_pMarker[m_iClient]     = -1;
    }

    return;
}

// ====[ COMMAND ]=====================================================
public Action:m_cmdBackstab_SuicideBlocker( m_iClient, const String:command[], args )
{
    if ( !IsPlayerAlive( m_iClient ) || !IsValidClient( m_iClient ) ) return Plugin_Continue;

    if ( m_bBools[m_iClient][m_bBackstab_SuicideBlocker] ) return Plugin_Handled;
    else return Plugin_Continue;
}

// ====[ EVENT: POST INVENTORY APPLICATION ]===========================
public Event_PostInventoryApplication( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "userid" ) );
    
    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) )
    {
        if ( m_hTimers[m_iClient][m_hBerserker_TimerDuration] != INVALID_HANDLE )
        {
            ClearTimer( m_hTimers[m_iClient][m_hBerserker_TimerDuration] );
            TF2_RemoveCondition( m_iClient, TFCond_CritOnFirstBlood );
            TF2_RemoveCondition( m_iClient, TFCond_SpeedBuffAlly );
            TF2_RemoveCondition( m_iClient, TFCond_Ubercharged );
        }
        if ( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] != INVALID_HANDLE )
        {
            ClearTimer( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] );
            TF2_RemoveCondition( m_iClient, TFCond_Buffed );
            TF2_RemoveCondition( m_iClient, TFCond_DefenseBuffed );
            TF2_RemoveCondition( m_iClient, TFCond_RegenBuffed );
            TF2_RemoveCondition( m_iClient, TFCond_SpeedBuffAlly );
        }
        if ( m_hTimers[m_iClient][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE && m_bBools[m_iClient][m_bInfiniteAfterburnRessuply] )
        {
            ClearTimer( m_hTimers[m_iClient][m_hInfiniteAfterburn_TimerDuration] );
            g_pBurner[m_iClient] = -1;
        }

        m_bBools[m_iClient][m_bIsHeat]              = false;
        m_bBools[m_iClient][m_bIsHeatToo]           = false;
        m_bBools[m_iClient][m_bLastWasMiss]         = false;
        m_iIntegers[m_iClient][m_iHeat]             = 0;
        m_iIntegers[m_iClient][m_iHeatToo]          = 0;
        m_iIntegers[m_iClient][m_iHotSauceType]     = 0;
        m_iIntegers[m_iClient][m_iMissStack]        = 0;

        if ( !g_hPostInventory[m_iClient] ) {
            CreateTimer( 0.02, m_tPostInventory, m_iClient );
            g_hPostInventory[m_iClient] = true;
        }
    }

    return;
}

// ====[ EVENT: BUILT OBJECT ]=========================================
public Event_BuiltObject( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iSapper = GetEventInt( m_hEvent, "index" );

    SDKHook( m_iSapper, SDKHook_OnTakeDamage, OnTakeDamage );
}

// ====[ EVENT: BUFF DEPLOYED ]========================================
public Event_BuffDeployed( Handle:m_hEvent, const String:m_strName[], bool:m_bDontBroadcast )
{
    new m_iClient = GetClientOfUserId( GetEventInt( m_hEvent, "buff_owner" ) );
    
    if ( IsValidClient( m_iClient ) && IsPlayerAlive( m_iClient ) )
    {
        if ( HasAttribute( m_iClient, _, m_bBuffStuff_ATTRIBUTE ) ) m_bBools[m_iClient][m_bBuffDeployed] = true;
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
        m_iButtons = ATTRIBUTE_ATTACKSPEEDONKILL( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_HEATDMGTAKEN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_HEATFIRERATE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_MCFRTD( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
    }
    CloseHandle( hArray );
    
    m_iSlot2 = -1;
    for ( m_iSlot2 = 0; m_iSlot2 <= 4; m_iSlot2++ ) // ALWAYS ACTIVE | PASSIVE STUFF HERE.
    {
        m_iButtons = ATTRIBUTE_BERSERKER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_BONUSDAMAGEVSSAPPER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_BUFFSTUFF( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DEMOCHARGE( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DEMOCHARGE_BLOCK( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_DISABLEUBER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_LOWBERSERKER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_METALDRAIN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_PSYCHO( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_REMOVESTUN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_SETWEAPONSWITCH( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = ATTRIBUTE_SPYDETECTOR( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = HUD_SHOWSYNCHUDTEXT( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

        m_iButtons = PRETHINK_AFTERBURN( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );
        m_iButtons = PRETHINK_STACKREMOVER( m_iClient, m_iButtons, m_iSlot2, m_iButtonsLast );

    }

    if ( m_iButtons != m_iButtons2 ) SetEntProp( m_iClient, Prop_Data, "m_nButtons", m_iButtons );    
    g_iLastButtons[m_iClient] = m_iButtons;
}

ATTRIBUTE_HEATFIRERATE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, true ) )
    {
        new Float:attack_speed = GetAttributeValueF( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_AttackSpeed, true );
        new Float:delay = GetAttributeValueF( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_Delay, true );
        new Float:old_as = GetAttributeValueF( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_OldAttackSpeed, true );

        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        new ammo = GetAmmo( m_iClient, TF2_GetClientActiveSlot( m_iClient ) );
        if ( ammo <= 0 ) m_iIntegers[m_iClient][m_iHeat] = 0;

        decl String:m_sWeapon[20];
        GetClientWeapon( m_iClient, m_sWeapon, sizeof( m_sWeapon ) );
        if ( m_iButtons & IN_ATTACK == IN_ATTACK || m_iButtons & IN_ATTACK2 == IN_ATTACK2 && StrEqual( m_sWeapon, "tf_weapon_minigun" ) ) // Thx FlaminSarge.
        {
            if ( !( m_bBools[m_iClient][m_bIsHeat] ) )
            {
                if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
                new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
                new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

                new Handle:m_hData01 = CreateDataPack();
                CreateDataTimer( delay, m_tHeatAttackSpeed_TimerDelay, m_hData01 );
                WritePackCell( m_hData01, m_iWeapon );
                WritePackCell( m_hData01, m_iClient );
                WritePackFloat( m_hData01, m_flAttackSpeed );
                m_bBools[m_iClient][m_bIsHeat] = true;
            }
        }
        else {
            TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            m_iIntegers[m_iClient][m_iHeat] = 0;
            m_bBools[m_iClient][m_bIsHeat] = false;
        }

        if ( m_iIntegers[m_iClient][m_iHeat] == 0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
        else {
            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
            new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
            new Float:fValue = attack_speed * m_iIntegers[m_iClient][m_iHeat];

            for ( new m_iSlot2 = 0; m_iSlot2 <= 2; m_iSlot2++ )
            {
                if ( HasAttribute( m_iClient, m_iSlot2, m_bHeatFireRate_ATTRIBUTE ) )
                {
                    TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as-fValue );

                    if ( m_iSlot2 == 0 || m_iSlot2 == 1 )
                    {
                        if ( m_flAttackSpeed < 0.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.0 );
                    }
                    else if ( m_iSlot2 == 2 )
                    {
                        if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Scout ) {
                            if ( m_flAttackSpeed < 0.392 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.392 );
                        } else if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Spy ) {
                            if ( m_flAttackSpeed < 0.001 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.001 );
                        } else {
                            if ( m_flAttackSpeed < 0.245 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.245 );
                        }
                    }
                }
            }
        }
        if ( !( m_bBools[m_iClient][m_bIsHeat] ) ) m_iIntegers[m_iClient][m_iHeat] = 0;
    }

    return m_iButtons;
}

ATTRIBUTE_HEATDMGTAKEN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
    {
        new Float:delay = GetAttributeValueF( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_Delay, true );

        new ammo = GetAmmo( m_iClient, TF2_GetClientActiveSlot( m_iClient ) );
        if ( ammo <= 0 ) m_iIntegers[m_iClient][m_iHeatToo] = 0;

        decl String:m_sWeapon[20];
        GetClientWeapon( m_iClient, m_sWeapon, sizeof( m_sWeapon ) );
        if ( m_iButtons & IN_ATTACK == IN_ATTACK || m_iButtons & IN_ATTACK2 == IN_ATTACK2 && StrEqual( m_sWeapon, "tf_weapon_minigun" ) ) // Thx FlaminSarge.
        {
            if ( !( m_bBools[m_iClient][m_bIsHeatToo] ) )
            {
                m_bBools[m_iClient][m_bIsHeatToo] = true;
                CreateTimer( delay, m_tHeatDMGTaken_TimerDelay, m_iClient );
            }
        } else {
            m_iIntegers[m_iClient][m_iHeatToo]  = 0;
            m_bBools[m_iClient][m_bIsHeatToo]   = false;
        }
        if ( !( m_bBools[m_iClient][m_bIsHeatToo] ) ) m_iIntegers[m_iClient][m_iHeatToo] = 0;
    }

    return m_iButtons;
}

ATTRIBUTE_ATTACKSPEEDONKILL( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE, true ) )
    {
        new Float:old_as = GetAttributeValueF( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_OldAttackSpeed, true );
        new Float:attack_speed = GetAttributeValueF( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_AttackSpeed, true );

        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

        if ( m_iIntegers[m_iClient][m_iAttackSpeed] == 0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
        else {
            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
            new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
            new Float:fValue = attack_speed * m_iIntegers[m_iClient][m_iAttackSpeed];

            for ( new m_iSlot2 = 0; m_iSlot2 <= 2; m_iSlot2++ )
            {
                if ( HasAttribute( m_iClient, m_iSlot2, m_bAttackSpeedOnKill_ATTRIBUTE ) )
                {
                    TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as-fValue );

                    if ( m_iSlot2 == 0 || m_iSlot2 == 1 )
                    {
                        if ( m_flAttackSpeed < 0.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.0 );
                    }
                    else if ( m_iSlot2 == 2 )
                    {
                        if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Scout ) {
                            if ( m_flAttackSpeed < 0.392 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.392 );
                        } else if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Spy ) {
                            if ( m_flAttackSpeed < 0.001 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.001 );
                        } else {
                            if ( m_flAttackSpeed < 0.245 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.245 );
                        }
                    }
                }
            }
        }
    }
    else if ( !HasAttribute( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE ) ) {
        if ( !g_hPostInventory[m_iClient] && IsPlayerAlive( m_iClient ) ) m_iIntegers[m_iClient][m_iAttackSpeed] = 0;
    }

    return m_iButtons;
}

ATTRIBUTE_MCFRTD( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bMCFRTD_ATTRIBUTE, true ) )
    {
        new Float:old_as = GetAttributeValueF( m_iClient, _, m_bMCFRTD_ATTRIBUTE, m_flMCFRTD_OldAttackSpeed, true );

        if ( !( m_bBools[m_iClient][m_bLastWasMiss] ) )
        {
            new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );

            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
            if ( m_iIntegers[m_iClient][m_iMissStack] <= 0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", old_as );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_BERSERKER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bBerserker_ATTRIBUTE ) )
    {
        new Float:threshold = GetAttributeValueF( m_iClient, _, m_bBerserker_ATTRIBUTE, m_flBerserker_Threshold );
        new Float:duration = GetAttributeValueF( m_iClient, _, m_bBerserker_ATTRIBUTE, m_flBerserker_Duration );

        if ( GetClientHealth( m_iClient ) <= TF2_GetClientMaxHealth( m_iClient ) * threshold )
        {
            if ( m_hTimers[m_iClient][m_hBerserker_TimerDuration] == INVALID_HANDLE )
            {
                TF2_AddCondition( m_iClient, TFCond_Ubercharged, duration );
                TF2_AddCondition( m_iClient, TFCond_CritOnFirstBlood, duration );
                TF2_AddCondition( m_iClient, TFCond_SpeedBuffAlly, duration );
                m_hTimers[m_iClient][m_hBerserker_TimerDuration] = CreateTimer( duration, m_tBerserker_TimerDuration, m_iClient );
            }
        }
        if ( GetClientHealth( m_iClient ) >= TF2_GetClientMaxHealth( m_iClient )*1.5 )
        {
            if ( m_hTimers[m_iClient][m_hBerserker_TimerDuration] != INVALID_HANDLE )
            {
                TF2_RemoveCondition( m_iClient, TFCond_Ubercharged );
                TF2_RemoveCondition( m_iClient, TFCond_CritOnFirstBlood );
                TF2_RemoveCondition( m_iClient, TFCond_SpeedBuffAlly );
                if ( m_hTimers[m_iClient][m_hBerserker_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hBerserker_TimerDuration] );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_LOWBERSERKER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bLowBerserker_ATTRIBUTE ) )
    {
        new Float:threshold = GetAttributeValueF( m_iClient, _, m_bLowBerserker_ATTRIBUTE, m_flLowBerserker_Threshold );
        new Float:duration = GetAttributeValueF( m_iClient, _, m_bLowBerserker_ATTRIBUTE, m_flLowBerserker_Duration );

        if ( GetClientHealth( m_iClient ) <= TF2_GetClientMaxHealth( m_iClient ) * threshold )
        {
            if ( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] == INVALID_HANDLE )
            {
                TF2_AddCondition( m_iClient, TFCond_Buffed, duration );
                TF2_AddCondition( m_iClient, TFCond_DefenseBuffed, duration );
                TF2_AddCondition( m_iClient, TFCond_RegenBuffed, duration );
                TF2_AddCondition( m_iClient, TFCond_SpeedBuffAlly, duration );
                m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] = CreateTimer( duration, m_tLowBerserker_TimerDuration, m_iClient );
            }
        }
        if ( GetClientHealth( m_iClient ) >= TF2_GetClientMaxHealth( m_iClient )*1.5 )
        {
            if ( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] != INVALID_HANDLE )
            {
                TF2_RemoveCondition( m_iClient, TFCond_Buffed );
                TF2_RemoveCondition( m_iClient, TFCond_DefenseBuffed );
                TF2_RemoveCondition( m_iClient, TFCond_RegenBuffed );
                TF2_RemoveCondition( m_iClient, TFCond_SpeedBuffAlly );
                if ( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] );
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_PSYCHO( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bPsycho_ATTRIBUTE ) )
    {
        new Float:duration = GetAttributeValueF( m_iClient, _, m_bPsycho_ATTRIBUTE, m_flPsycho_Duration );
        new melee = GetAttributeValueI( m_iClient, _, m_bPsycho_ATTRIBUTE, m_iPsycho_Melee );
        new Float:regen = GetAttributeValueF( m_iClient, _, m_bPsycho_ATTRIBUTE, m_flPsycho_RegenPct );

        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 || TF2_IsPlayerInCondition( m_iClient, TFCond_Taunting ) )
        {
            if ( m_flFloats[m_iClient][m_flPyschoCharge] == 100.0 && m_hTimers[m_iClient][m_hPsycho_TimerDuration] == INVALID_HANDLE )
            {
                m_hTimers[m_iClient][m_hPsycho_TimerDuration] = CreateTimer( duration, m_tPsycho_TimerDuration, m_iClient );
                FakeClientCommand( m_iClient, "taunt" );
                TF2_AddCondition( m_iClient, TFCond_MegaHeal, duration );
                TF2_AddCondition( m_iClient, TFCond_SpeedBuffAlly, duration );
                TF2_AddCondition( m_iClient, TFCond_TeleportedGlow, duration );
                TF2_AddCondition( m_iClient, TFCond_Sapped, duration );
                if ( melee == 1 ) {
                    TF2_AddCondition( m_iClient, TFCond_RestrictToMelee, duration );
                    TF2_SetClientSlot( m_iClient, 2 );
                }
                TF2_RemoveCondition( m_iClient, TFCond_Dazed );
                EmitSoundToClient( m_iClient, SOUND_TBASH );
            }
        }
        if ( m_hTimers[m_iClient][m_hPsycho_TimerDuration] != INVALID_HANDLE )
        {
            m_flFloats[m_iClient][m_flPyschoCharge] -= ( 0.303 / duration );

            if ( GetClientHealth( m_iClient ) < TF2_GetClientMaxHealth( m_iClient ) )
            {
                if ( regen != 0.0 )
                {
                    m_flFloats[m_iClient][m_flPsychoRegenCharge] += ( ( TF2_GetClientMaxHealth( m_iClient ) - GetClientHealth( m_iClient ) ) * regen * ( 0.0303 / duration ) );
                    if ( m_flFloats[m_iClient][m_flPsychoRegenCharge] >= 1.0 ) {
                        TF2_HealPlayer( m_iClient, m_flFloats[m_iClient][m_flPsychoRegenCharge] );
                        m_flFloats[m_iClient][m_flPsychoRegenCharge] = 0.0;
                    }
                }
                else SetEntityHealth( m_iClient, TF2_GetClientMaxHealth( m_iClient ) );
            }
        }

        if ( m_flFloats[m_iClient][m_flPyschoCharge] > 100.0 ) m_flFloats[m_iClient][m_flPyschoCharge] = 100.0;
        if ( m_flFloats[m_iClient][m_flPyschoCharge] < 0.0 ) m_flFloats[m_iClient][m_flPyschoCharge] = 0.0;
    }

    return m_iButtons;
}

ATTRIBUTE_METALDRAIN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bMetalDrain_ATTRIBUTE ) )
    {
        new mode = GetAttributeValueI( m_iClient, _, m_bMetalDrain_ATTRIBUTE, m_iMetalDrain_PoA );

        if ( m_hTimers[m_iClient][m_hDrainMetal_TimerDelay] == INVALID_HANDLE )
            if ( mode == 0 || HasAttribute( m_iClient, _, m_bMetalDrain_ATTRIBUTE, true ) && mode == 1 )
                m_hTimers[m_iClient][m_hDrainMetal_TimerDelay] = CreateTimer( GetAttributeValueF( m_iClient, _, m_bMetalDrain_ATTRIBUTE, m_flMetalDrain_Interval ), m_tDrainMetal_TimerInterval, m_iClient );
    }

    return m_iButtons;
}

ATTRIBUTE_DEMOCHARGE( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDemoCharge_DamageReduction_ATTRIBUTE ) ) {
        if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Charging ) ) TF2_AddCondition( m_iClient, TFCond_DefenseBuffMmmph, 0.5 );
    }

    return m_iButtons;
}

ATTRIBUTE_BONUSDAMAGEVSSAPPER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bBonusDamageVsSapper_ATTRIBUTE, true ) )
    {
        new m_iWeapon = TF2_GetClientActiveWeapon( m_iClient );
        TF2Attrib_RemoveByName( m_iWeapon, "dmg bonus vs buildings" );
    }

    return m_iButtons;
}

ATTRIBUTE_SPYDETECTOR( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bSpyDetector_ATTRIBUTE ) && GetAttributeValueI( m_iClient, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_ActivePassive ) == 0
      || HasAttribute( m_iClient, _, m_bSpyDetector_ATTRIBUTE, true ) && GetAttributeValueI( m_iClient, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_ActivePassive, true ) == 1 )
    {
        new Float:radius = GetAttributeValueF( m_iClient, _, m_bSpyDetector_ATTRIBUTE, m_flSpyDetector_Radius );
        new type = GetAttributeValueI( m_iClient, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_Type );

        for ( new i = 1 ; i <= MaxClients ; i++ )
        {
            if ( i != m_iClient && IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iClient ) )
            {
                new Float:m_flPos1[3], Float:m_flPos2[3];
                GetClientAbsOrigin( m_iClient, m_flPos1 );
                GetClientAbsOrigin( i, m_flPos2 );

                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                if ( distance < radius )
                {
                    if ( type == 1 ) TF2_RemoveCondition( i, TFCond_Cloaked );
                    if ( type == 2 ) TF2_RemoveCondition( i, TFCond_Disguised );
                    if ( type == 3 ) {
                        TF2_RemoveCondition( i, TFCond_Cloaked );
                        TF2_RemoveCondition( i, TFCond_Disguised );
                    }
                }
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DEMOCHARGE_BLOCK( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE ) )
    {
        new mode = GetAttributeValueI( m_iClient, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE, m_iDemoCharge_HealthThreshold_Mode );
        new Float:threshold = GetAttributeValueF( m_iClient, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE, m_flDemoCharge_HealthThreshold_Threshold );

        if ( m_iButtons & IN_ATTACK2 == IN_ATTACK2 )
        {
            if ( mode == 1 && GetClientHealth( m_iClient ) >= threshold || mode == 2 && GetClientHealth( m_iClient ) <= threshold )
            {
                m_iButtons &= ~IN_ATTACK2;
                return m_iButtons;
            }
        }
    }

    return m_iButtons;
}

ATTRIBUTE_REMOVESTUN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bCannotBeStunned_ATTRIBUTE ) )
    {
        new type = GetAttributeValueI( m_iClient, _, m_bCannotBeStunned_ATTRIBUTE, m_iCannotBeStunned_Type );

        if ( !( GetEntityMoveType( m_iClient ) & MOVETYPE_NONE ) )
        {
            if ( type == 1 && TF2_IsPlayerInCondition( m_iClient, TFCond_Dazed ) && GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) != TF_STUNFLAGS_GHOSTSCARE 
                || type == 2 && GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE
                || type == 3 && TF2_IsPlayerInCondition( m_iClient, TFCond_Dazed ) || type == 3 && GetEntProp( m_iClient, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE )
                TF2_RemoveCondition( m_iClient, TFCond_Dazed );
        }
    }

    return m_iButtons;
}

ATTRIBUTE_DISABLEUBER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bDisableUbercharge_ATTRIBUTE ) )
    {
        if ( TF2_GetClientUberLevel( m_iClient ) >= 99.0 ) TF2_SetClientUberLevel( m_iClient, 99.0 );
        // This is to avoid the attribute 'deal bonus dmg with ubercharge' to not being useless if you also have this.
    }

    return m_iButtons;
}

ATTRIBUTE_BUFFSTUFF( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bBuffStuff_ATTRIBUTE ) )
    {
        new Float:bonus_radius = GetAttributeValueF( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_flBuffStuff_Radius );
        new mode = GetAttributeValueI( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_Mode );
        new id = GetAttributeValueI( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID );
        new id2 = GetAttributeValueI( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID2 );
        new id3 = GetAttributeValueI( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID3 );
        new id4 = GetAttributeValueI( m_iClient, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID4 );

        if ( m_bBools[m_iClient][m_bBuffDeployed] )
        {
            for ( new i = 1 ; i <= MaxClients ; i++ )
            {
                if ( IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) == GetClientTeam( m_iClient ) )
                {
                    new Float:m_flPos1[3], Float:m_flPos2[3];
                    GetClientAbsOrigin( m_iClient, m_flPos1 );
                    GetClientAbsOrigin( i, m_flPos2 );

                    new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                    if ( distance < ( 450.0 * bonus_radius ) )
                    {
                        if ( mode == 1 )
                        {
                            if ( id != 0 ) TF2_AddCondition( i, TFCond:id, 0.1 );
                            if ( id2 != 0 ) TF2_AddCondition( i, TFCond:id2, 0.1 );
                            if ( id3 != 0 ) TF2_AddCondition( i, TFCond:id3, 0.1 );
                            if ( id4 != 0 ) TF2_AddCondition( i, TFCond:id4, 0.1 );
                        
                            if ( id != 16 && id2 != 16 && id3 != 16 && id4 != 16 ) TF2_RemoveCondition( i, TFCond_Buffed );
                            if ( id != 26 && id2 != 26 && id3 != 26 && id4 != 26 ) TF2_RemoveCondition( i, TFCond_DefenseBuffed );
                            if ( id != 29 && id2 != 29 && id3 != 29 && id4 != 29 ) TF2_RemoveCondition( i, TFCond_RegenBuffed );
                        }
                        else if ( mode == 2 )
                        {
                            if ( TF2_IsPlayerInCondition( m_iClient, TFCond_Buffed ) ) TF2_AddCondition( i, TFCond_Buffed, 0.1 );
                            else if ( TF2_IsPlayerInCondition( m_iClient, TFCond_DefenseBuffed ) ) TF2_AddCondition( i, TFCond_DefenseBuffed, 0.1 );
                            else if ( TF2_IsPlayerInCondition( m_iClient, TFCond_RegenBuffed ) ) TF2_AddCondition( i, TFCond_RegenBuffed, 0.1 );
                        }
                    }
                }
            }
        }
        if ( GetEntPropFloat( m_iClient, Prop_Send, "m_flRageMeter" ) == 0.0 ) m_bBools[m_iClient][m_bBuffDeployed] = false;
    }

    return m_iButtons;
}

ATTRIBUTE_SETWEAPONSWITCH( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bSetWeaponSwitch_ATTRIBUTE ) )
        TF2_SetClientSlot( m_iClient, GetAttributeValueI( m_iClient, _, m_bSetWeaponSwitch_ATTRIBUTE, m_iSetWeaponSwith_Slot ) );

    return m_iButtons;
}

PRETHINK_AFTERBURN( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( IsValidClient( m_iClient )
        && !( GetEntityFlags( m_iClient ) & FL_INWATER )
        && !TF2_IsPlayerInCondition( m_iClient, TFCond_OnFire )
        && TF2_GetPlayerClass( m_iClient ) != TFClass_Pyro
        && !HasInvulnerabilityCond( m_iClient )
        && g_pBurner[m_iClient] != -1 )
    {
        if ( HasAttribute( g_pBurner[m_iClient], _, m_bInfiniteAfterburn_ATTRIBUTE )
            && m_hTimers[m_iClient][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE )
            TF2_IgnitePlayer( m_iClient, g_pBurner[m_iClient] );
    }

    return m_iButtons;
}

PRETHINK_STACKREMOVER( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    if ( HasAttribute( m_iClient, _, m_bMarkVictimDamage_ATTRIBUTE ) ) {
        if ( m_iIntegers[m_iClient][m_iMarkVictimDamage] < 0 ) m_iIntegers[m_iClient][m_iMarkVictimDamage] = 0;
    }

    return m_iButtons;
}

HUD_SHOWSYNCHUDTEXT( m_iClient, &m_iButtons, &m_iSlot, &m_iButtonsLast )
{
    new String:m_strHUDAttackSpeedOnKill[64];
    new String:m_strHUDDamageReceivedUnleashedDeath[64];
    new String:m_strHUDDamageResHpMissing[64];
    new String:m_strHUDHeatDMGTaken[64];
    new String:m_strHUDHeatFireRate[64];
    new String:m_strHUDMissDecreasesFireRate[64];
    new String:m_strHUDPsycho[64];
    new String:m_strHUDSteal[64];

    if ( HasAttribute( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, true ) )
    {
        new max = GetAttributeValueI( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack, true );

        Format( m_strHUDHeatFireRate, sizeof( m_strHUDHeatFireRate ), "Heat %i/%i", m_iIntegers[m_iClient][m_iHeat], max );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
    {
        new max = GetAttributeValueI( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE, m_iHeatDMGTaken_MaximumStack, true );

        Format( m_strHUDHeatDMGTaken, sizeof( m_strHUDHeatDMGTaken ), "Heat %i/%i", m_iIntegers[m_iClient][m_iHeatToo], max );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE, true ) )
    {
        new max = GetAttributeValueI( m_iClient, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_iAttackSpeedOnKill_MaximumStack, true );

        if ( max >= 1024 ) {
            Format( m_strHUDAttackSpeedOnKill, sizeof( m_strHUDAttackSpeedOnKill ), "Kills %i", m_iIntegers[m_iClient][m_iAttackSpeed] );
        } else {
            Format( m_strHUDAttackSpeedOnKill, sizeof( m_strHUDAttackSpeedOnKill ), "Kills %i/%i", m_iIntegers[m_iClient][m_iAttackSpeed], max );
        }
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bMCFRTD_ATTRIBUTE, true ) )
    {
        new max = GetAttributeValueI( m_iClient, _, m_bMCFRTD_ATTRIBUTE, m_iMCFRTD_MaximumStack, true );

        if ( max >= 1024 ) {
            Format( m_strHUDMissDecreasesFireRate, sizeof( m_strHUDMissDecreasesFireRate ), "Miss %i", m_iIntegers[m_iClient][m_iMissStack] );
        } else {
            Format( m_strHUDMissDecreasesFireRate, sizeof( m_strHUDMissDecreasesFireRate ), "Miss %i/%i", m_iIntegers[m_iClient][m_iMissStack], max );
        }
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bPsycho_ATTRIBUTE ) ) {
        Format( m_strHUDPsycho, sizeof( m_strHUDPsycho ), "Rampage %.0f %", m_flFloats[m_iClient][m_flPyschoCharge] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) ) {
        Format( m_strHUDDamageReceivedUnleashedDeath, sizeof( m_strHUDDamageReceivedUnleashedDeath ), "Damage %i", m_flFloats[m_iClient][m_flDamageReceived] );
    }
//-//
    if ( HasAttribute( m_iClient, _, m_bDamageResHealthMissing_ATTRIBUTE ) )
    {
        new penalty = GetAttributeValueI( m_iClient, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_OverhealPenalty );
        new Float:resphp = GetAttributeValueF( m_iClient, _, m_bDamageResHealthMissing_ATTRIBUTE, m_flDamageResHealthMissing_ResPctPerMissingHpPct );
        new max = GetAttributeValueI( m_iClient, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct );

        new Float:m_flMHP = 1 - ( FloatDiv( GetClientHealth( m_iClient )+0.0, TF2_GetClientMaxHealth( m_iClient )+0.0 ) );
        if ( GetClientHealth( m_iClient ) > TF2_GetClientMaxHealth( m_iClient ) && penalty == 0 ) m_flMHP = 0.0;
        new Float:m_flResPct = resphp * m_flMHP;
        if ( m_flMHP * 100.0 > max ) m_flResPct = resphp * FloatDiv( max+0.0, 100.0 );

        Format( m_strHUDDamageResHpMissing, sizeof( m_strHUDDamageResHpMissing ), "Resistance %.0f%%", m_flResPct*100.0 );
    }
//-//
    if ( m_iIntegers[m_iClient][m_iStealDamageVictim] > 1 || m_iIntegers[m_iClient][m_iStealDamageAttacker] > 1 )
    {
        Format( m_strHUDSteal, sizeof( m_strHUDSteal ), "Damage Stolen %i", m_iIntegers[m_iClient][m_iStealDamageAttacker] - m_iIntegers[m_iClient][m_iStealDamageVictim] );
    }
//-//
    if ( IfDoNextTime2( m_iClient, e_flNextHUDUpdate, 0.1 ) ) // Thanks Chdata :D
    {
        ShowSyncHudText( m_iClient, g_hHudText_O, "%s \n%s \n%s \n%s \n%s \n%s \n%s \n%s", m_strHUDAttackSpeedOnKill,
                                                                                           m_strHUDDamageReceivedUnleashedDeath,
                                                                                           m_strHUDDamageResHpMissing,
                                                                                           m_strHUDHeatDMGTaken,
                                                                                           m_strHUDHeatFireRate,
                                                                                           m_strHUDMissDecreasesFireRate,
                                                                                           m_strHUDPsycho,
                                                                                           m_strHUDSteal );
    }
    
    return m_iButtons;
}

// ====[ ON ADD ATTRIBUTE ]============================================
public Action:CustomWeaponsTF_OnAddAttribute( m_iWeapon, m_iClient, const String:m_sAttribute[], const String:m_sPlugin[], const String:m_sValue[] )
{
    if ( !StrEqual( m_sPlugin, "orion" ) ) return Plugin_Continue;
    new Action:m_aAction;

    /* Hot Sauce On Hit
     *
     * ---------------------------------------------------------------------- */
    if ( StrEqual( m_sAttribute, "hotsauce on hit" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flHotSauceOnHit_Duration[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_iHotSauceOnHit_Type[m_iWeapon]        = StringToInt( m_sValues[1] );
        m_bHotSauceOnHit_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Hot Sauce On Crit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "hotsauce on crit" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flHotSauceOnCrit_Duration[m_iWeapon]  = StringToFloat( m_sValues[0] );
        m_iHotSauceOnCrit_Type[m_iWeapon]       = StringToInt( m_sValues[1] );
        m_bHotSauceOnCrit_ATTRIBUTE[m_iWeapon]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Stun On Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "stun on hit" ) )
    {
        m_flStunOnHit_Duration[m_iWeapon] = StringToFloat( m_sValue );
        m_bStunOnHit_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Stun On Crit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "stun on hitcrit" ) )
    {
        m_flStunOnCrit_Duration[m_iWeapon] = StringToFloat( m_sValue );
        m_bStunOnCrit_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Enemy Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "enemy hp to dmg" ) )
    {
        m_flActualEnemyHealthToDamage_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bActualEnemyHealthToDamage_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "hp to dmg" ) )
    {
        m_flActualHealthToDamage_Multiplier[m_iWeapon]  = StringToFloat( m_sValue );
        m_bActualHealthToDamage_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Maximum Enemy Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "max enemy hp to dmg" ) )
    {
        m_flMaximumEnemyHealthToDamage_Multiplier[m_iWeapon]    = StringToFloat( m_sValue );
        m_bMaximumEnemyHealthToDamage_ATTRIBUTE[m_iWeapon]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Maximum Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "max hp to dmg" ) )
    {
        m_flMaximumHealthToDamage_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bMaximumHealthToDamage_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Lifesteal From Health
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "health lifesteal" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flHealthLifesteal_Multiplier[m_iWeapon]       = StringToFloat( m_sValues[0] );
        m_flHealthLifesteal_OverHealBonusCap[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bHealthLifesteal_ATTRIBUTE[m_iWeapon]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Lifesteal From Enemy Health
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "enemy health lifesteal" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flEnemyHealthLifesteal_Multiplier[m_iWeapon]          = StringToFloat( m_sValues[0] );
        m_flEnemyHealthLifesteal_OverHealBonusCap[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_bEnemyHealthLifesteal_ATTRIBUTE[m_iWeapon]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Drain Übercharge
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "drain uber" ) )
    {
        m_flDrainUbercharge_Percentage[m_iWeapon]   = StringToFloat( m_sValue );
        m_bDrainUbercharge_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Drain Übercharge On Crit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "drain uber crit" ) )
    {
        m_flDrainUberchargeOnCrit_Percentage[m_iWeapon] = StringToFloat( m_sValue );
        m_bDrainUberchargeOnCrit_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Missing Enemy Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "missing enemy hp to dmg" ) )
    {
        m_flMissingEnemyHealthToDamage_Multiplier[m_iWeapon]    = StringToFloat( m_sValue );
        m_bMissingEnemyHealthToDamage_ATTRIBUTE[m_iWeapon]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Missing Enemy Health To Damage FLAMETHROWER
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "missing enemy hp to dmg FLAMETHROWER" ) )
    {
        m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[m_iWeapon]   = StringToFloat( m_sValue );
        m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Missing Health To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "missing hp to dmg" ) )
    {
        m_flMissingHealthToDamage_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bMissingHealthToDamage_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Lifesteal From Missing Enemy Health
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "missing enemy hp lifesteal" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flMissingEnemyHealthLifesteal_Multiplier[m_iWeapon]       = StringToFloat( m_sValues[0] );
        m_flMissingEnemyHealthLifesteal_OverHealBonusCap[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bMissingEnemyHealthLifesteal_ATTRIBUTE[m_iWeapon]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Done Is Selfhurt
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg done is selfhurt" ) )
    {
        m_flDamageDoneIsSelfHurt_Multiplier[m_iWeapon]  = StringToFloat( m_sValue );
        m_bDamageDoneIsSelfHurt_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus If Health Is Higher Than Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus if health higher than threshold" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flDamageIfHealthHigherThanThreshold_BonusDamage[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_flDamageIfHealthHigherThanThreshold_Threshold[m_iWeapon]      = StringToFloat( m_sValues[1] );
        m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[m_iWeapon]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus If Health Is Lower Than Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus if health lower than threshold" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flDamageIfHealthLowerThanThreshold_BonusDamage[m_iWeapon] = StringToFloat( m_sValues[0] );
        m_flDamageIfHealthLowerThanThreshold_Threshold[m_iWeapon]   = StringToFloat( m_sValues[1] );
        m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus If Enemy Health Is Higher Than Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus if enemy health higher than threshold" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flDamageIfEnemyHealthHigherThanThreshold_BonusDamage[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_flDamageIfEnemyHealthHigherThanThreshold_Threshold[m_iWeapon]     = StringToFloat( m_sValues[1] );
        m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[m_iWeapon]      = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus If Enemy Health Is Lower Than Health Threshold
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus if enemy health lower than threshold" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );
        
        m_flDamageIfEnemyHealthLowerThanThreshold_BonusDamage[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_flDamageIfEnemyHealthLowerThanThreshold_Threshold[m_iWeapon]      = StringToFloat( m_sValues[1] );
        m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[m_iWeapon]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Backstab Damage Modifier With A Stun
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "backstab damage modifier sub stun" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBackstabDamageModSubStun_Multiplier[m_iWeapon]  = StringToFloat( m_sValues[0] );
        m_flBackstabDamageModSubStun_Duration[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_iBackstabDamageModSubStun_Security[m_iWeapon]     = StringToInt( m_sValues[2] );
        m_iBackstabDamageModSubStun_BlockSuicide[m_iWeapon] = StringToInt( m_sValues[3] );
        m_bBackstabDamageModSubStun_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Self Upon Attacking
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "damage self" ) )
    {
        m_iDamageSelf_Amount[m_iWeapon]     = StringToInt( m_sValue );
        m_bDamageSelf_ATTRIBUTE[m_iWeapon]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Combo
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "combo" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flCombo_BonusDamage[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_iCombo_Hit[m_iWeapon]             = StringToInt( m_sValues[1] );
        m_iCombo_Crit[m_iWeapon]            = StringToInt( m_sValues[2] );
        m_bCombo_ATTRIBUTE[m_iWeapon]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Chance To Oneshot
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "chance to oneshot" ) )
    {
        m_flChanceOneShot_Chance[m_iWeapon]     = StringToFloat( m_sValue );
        m_bChanceOneShot_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Chance To Ignite
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "chance to ignite" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flChanceIgnite_Chance[m_iWeapon]      = StringToFloat( m_sValues[0] );
        m_flChanceIgnite_Duration[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_bChanceIgnite_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Movement Speed To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "movespeed to dmg" ) )
    {
        m_flMovementSpeedToDamage_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bMovementSpeedToDamage_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Taken Damage Nearby Enemies On Death
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg taken dmg nearby enemies on death" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDamageReceivedUnleashedDeath_Percentage[m_iWeapon]             = StringToFloat( m_sValues[0] );
        m_flDamageReceivedUnleashedDeath_Radius[m_iWeapon]                 = StringToFloat( m_sValues[1] );
        m_iDamageReceivedUnleashedDeath_PoA[m_iWeapon]         = StringToInt( m_sValues[2] );
        m_iDamageReceivedUnleashedDeath_Backstab[m_iWeapon]                = StringToInt( m_sValues[3] );
        m_bDamageReceivedUnleashedDeath_ATTRIBUTE[m_iWeapon]               = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal Drain
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal drain" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flMetalDrain_Amount[m_iWeapon]            = StringToFloat( m_sValues[0] );
        m_flMetalDrain_Interval[m_iWeapon]          = StringToFloat( m_sValues[1] );
        m_iMetalDrain_PoA[m_iWeapon]    = StringToInt( m_sValues[2] );
        m_bMetalDrain_ATTRIBUTE[m_iWeapon]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal To Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal to dmg" ) )
    {
        m_flMetalToDamage_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bMetalToDamage_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal Per Shot
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal per shot" ) )
    {
        m_flMetalPerShot_Amount[m_iWeapon]      = StringToFloat( m_sValue );
        m_bMetalPerShot_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal On Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal on hit" ) )
    {
        m_flMetalOnHit_Amount[m_iWeapon]    = StringToFloat( m_sValue );
        m_bMetalOnHit_ATTRIBUTE[m_iWeapon]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Metal On Hit Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "metal on hit damage" ) )
    {
        m_flMetalOnHitDamage_Multiplier[m_iWeapon]  = StringToFloat( m_sValue );
        m_bMetalOnHitDamage_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage When Metal Runs Out
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg when metal runs out" ) )
    {
        m_flDamageWhenMetalRunsOut_Damage[m_iWeapon]    = StringToFloat( m_sValue );
        m_bDamageWhenMetalRunsOut_ATTRIBUTE[m_iWeapon]  = true;
        m_aAction = Plugin_Handled;
    }
    /* Kill Will Gib
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "kill will gib" ) )
    {
        m_bKillGib_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Spawn Skeleton On Kill
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "spawn skeleton on kill" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flSpawnSkeletonOnKill_Duration[m_iWeapon]         = StringToFloat( m_sValues[0] );
        m_iSpawnSkeletonOnKill_Boss[m_iWeapon]              = StringToInt( m_sValues[1] );
        m_flSpawnSkeletonOnKill_BossChance[m_iWeapon]       = StringToFloat( m_sValues[2] );
        m_bSpawnSkeletonOnKill_ATTRIBUTE[m_iWeapon]         = true;
        m_aAction = Plugin_Handled;
    }
    /* Berserker Near Death
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "berserker near death" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBerserker_Threshold[m_iWeapon]  = StringToFloat( m_sValues[0] );
        m_flBerserker_Duration[m_iWeapon]   = StringToFloat( m_sValues[1] );
        m_bBerserker_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Low Berserker Near Death
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "low berserker near death" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flLowBerserker_Threshold[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_flLowBerserker_Duration[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_iLowBerserker_Kill[m_iWeapon]         = StringToInt( m_sValues[2] );
        m_bLowBerserker_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Psycho Rampage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "psycho rampage" ) )
    {
        new String:m_sValues[5][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flPsycho_DamageResistance[m_iWeapon]  = StringToFloat( m_sValues[0] );
        m_flPsycho_DamageBonus[m_iWeapon]       = StringToFloat( m_sValues[1] );
        m_flPsycho_Duration[m_iWeapon]          = StringToFloat( m_sValues[2] );
        m_flPsycho_RegenPct[m_iWeapon]          = StringToFloat( m_sValues[3] );
        m_iPsycho_Melee[m_iWeapon]              = StringToInt( m_sValues[4] );
        m_bPsycho_ATTRIBUTE[m_iWeapon]          = true;
        m_aAction = Plugin_Handled;
    }
    /* Heat Increases Fire Rate
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "heat increases fire rate" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flHeatFireRate_Delay[m_iWeapon]           = StringToFloat( m_sValues[0] );
        m_flHeatFireRate_AttackSpeed[m_iWeapon]     = StringToFloat( m_sValues[1] );
        m_iHeatFireRate_MaximumStack[m_iWeapon]     = StringToInt( m_sValues[2] );
        m_flHeatFireRate_OldAttackSpeed[m_iWeapon]  = StringToFloat( m_sValues[3] );
        m_bHeatFireRate_ATTRIBUTE[m_iWeapon]        = true;
        m_aAction = Plugin_Handled;
    }
    /* Remove Bleeding
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "remove bleeding" ) )
    {
        m_bRemoveBleeding_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Übercharge On Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "uber on hit" ) )
    {
        m_flUberchargeOnHit_Amount[m_iWeapon]   = StringToFloat( m_sValue );
        m_bUberchargeOnHit_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Taken While Invisible
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg taken while invis" ) )
    {
        m_flDamageResistanceInvisible_Multiplier[m_iWeapon] = StringToFloat( m_sValue );
        m_bDamageResistanceInvisible_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Homing Projectile
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "homproj" ) ) // Thanks Tylerst.
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flHomingProjectile_DetectRadius[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_iHomingProjectile_Mode[m_iWeapon]             = StringToInt( m_sValues[1] );
        m_iHomingProjectile_Type[m_iWeapon]             = StringToInt( m_sValues[2] );
        m_bHomingProjectile_ATTRIBUTE[m_iWeapon]        = true;
        m_aAction = Plugin_Handled;
    }
    /* Fragmentation Grenade
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "frag grenade attr" ) ) // Thanks Pelipoika
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iFragmentation_Amount[m_iWeapon]      = StringToInt( m_sValues[0] );
        m_flFragmentation_Damage[m_iWeapon]     = StringToFloat( m_sValues[1] );
        m_flFragmentation_Radius[m_iWeapon]     = StringToFloat( m_sValues[2] );
        m_iFragmentation_Mode[m_iWeapon]        = StringToInt( m_sValues[3] );
        m_bFragmentation_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Ignite At Close Range
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "ignite at CLOSE RANGE" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flAfterburnCLOSERANGE_Duration[m_iWeapon] = StringToFloat( m_sValues[0] );
        m_flAfterburnCLOSERANGE_Range[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_bAfterburnCLOSERANGE_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Attack Speed On Kill
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "fire rate bonus on kill" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flAttackSpeedOnKill_AttackSpeed[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_iAttackSpeedOnKill_MaximumStack[m_iWeapon]    = StringToInt( m_sValues[1] );
        m_flAttackSpeedOnKill_Removal[m_iWeapon]        = StringToFloat( m_sValues[2] );
        m_flAttackSpeedOnKill_OldAttackSpeed[m_iWeapon] = StringToFloat( m_sValues[3] );
        m_bAttackSpeedOnKill_ATTRIBUTE[m_iWeapon]       = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Resistance While Charging DEMOMAN
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "damage res while charging DEMO" ) )
    {
        m_bDemoCharge_DamageReduction_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Charge Only On Health Threshold DEMO
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "charge only on hp threshold DEMO" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDemoCharge_HealthThreshold_Threshold[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_iDemoCharge_HealthThreshold_Mode[m_iWeapon]         = StringToInt( m_sValues[1] );
        m_bDemoCharge_HealthThreshold_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical Hit Vs Invisible Players
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit vs invisible players" ) )
    {
        m_bCritVsInvisiblePlayer_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Mark Victim Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "mark victim dmg" ) )
    {
        new String:m_sValues[4][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flMarkVictimDamage_Damage[m_iWeapon]              = StringToFloat( m_sValues[0] );
        m_flMarkVictimDamage_Duration[m_iWeapon]            = StringToFloat( m_sValues[1] );
        m_iMarkVictimDamage_MaximumDamageStack[m_iWeapon]   = StringToInt( m_sValues[2] );
        m_iMarkVictimDamage_MaximumVictim[m_iWeapon]        = StringToInt( m_sValues[3] );
        m_bMarkVictimDamage_ATTRIBUTE[m_iWeapon]            = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus Vs Sappers
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus vs sappers" ) )
    {
        m_flBonusDamageVsSapper_Multiplier[m_iWeapon]   = StringToFloat( m_sValue );
        m_bBonusDamageVsSapper_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus Vs Airborne Players
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus vs airborne players" ) )
    {
        m_flBonusDamageVSVictimInMidAir_Multiplier[m_iWeapon]   = StringToFloat( m_sValue );
        m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical Hit Vs Airborne Players
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit vs airborne players" ) )
    {
        m_bCritVictimInMidAir_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Critical Hit Vs Scared Players
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit vs scared players" ) )
    {
        m_bCritVictimScared_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Spy Condition Remover
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "spy cond remover" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flSpyDetector_Radius[m_iWeapon]       = StringToFloat( m_sValues[0] );
        m_iSpyDetector_Type[m_iWeapon]          = StringToInt( m_sValues[1] );
        m_iSpyDetector_ActivePassive[m_iWeapon] = StringToInt( m_sValues[2] );
        m_bSpyDetector_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Bleed At Close Range
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "bleed at CLOSE RANGE" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flBleedCLOSERANGE_Duration[m_iWeapon] = StringToFloat( m_sValues[0] );
        m_flBleedCLOSERANGE_Range[m_iWeapon]    = StringToFloat( m_sValues[1] );
        m_bBleedCLOSERANGE_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Banner Extender
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "buff_item extender" ) )
    {
        new String:m_sValues[6][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iBuffStuff_ID[m_iWeapon]          = StringToInt( m_sValues[0] );
        m_iBuffStuff_ID2[m_iWeapon]         = StringToInt( m_sValues[1] );
        m_iBuffStuff_ID3[m_iWeapon]         = StringToInt( m_sValues[2] );
        m_iBuffStuff_ID4[m_iWeapon]         = StringToInt( m_sValues[3] );
        m_flBuffStuff_Radius[m_iWeapon]     = StringToFloat( m_sValues[4] );
        m_iBuffStuff_Mode[m_iWeapon]        = StringToInt( m_sValues[5] );
        m_bBuffStuff_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Miss Decreases Fire Rate
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "miss decreases fire rate" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flMCFRTD_AttackSpeed[m_iWeapon]       = StringToFloat( m_sValues[0] );
        m_iMCFRTD_MaximumStack[m_iWeapon]       = StringToInt( m_sValues[1] );
        m_flMCFRTD_OldAttackSpeed[m_iWeapon]    = StringToFloat( m_sValues[2] );
        m_bMCFRTD_ATTRIBUTE[m_iWeapon]          = true;
        m_aAction = Plugin_Handled;
    }
    /* MiniCrit Vs Invisible Players
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "minicrit vs invisible players" ) )
    {
        m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* MiniCrit Vs Burning Players At Close Range
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "minicrit vs burning players CLOSERANGE" ) )
    {
        m_flMinicritVsBurningCLOSERANGE_Range[m_iWeapon]    = StringToFloat( m_sValue );
        m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Crit Vs Burning Players At Close Range
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit vs burning players CLOSERANGE" ) )
    {
        m_flCritVsBurningCLOSERANGE_Range[m_iWeapon]    = StringToFloat( m_sValue );
        m_bCritVsBurningCLOSERANGE_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Class
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg class" ) )
    {
        new String:m_sValues[9][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDamageClass_Scout[m_iWeapon]    = StringToFloat( m_sValues[0] );
        m_flDamageClass_Soldier[m_iWeapon]  = StringToFloat( m_sValues[1] );
        m_flDamageClass_Pyro[m_iWeapon]     = StringToFloat( m_sValues[2] );
        m_flDamageClass_Demoman[m_iWeapon]  = StringToFloat( m_sValues[3] );
        m_flDamageClass_Heavy[m_iWeapon]    = StringToFloat( m_sValues[4] );
        m_flDamageClass_Engineer[m_iWeapon] = StringToFloat( m_sValues[5] );
        m_flDamageClass_Medic[m_iWeapon]    = StringToFloat( m_sValues[6] );
        m_flDamageClass_Sniper[m_iWeapon]   = StringToFloat( m_sValues[7] );
        m_flDamageClass_Spy[m_iWeapon]      = StringToFloat( m_sValues[8] );
        m_bDamageClass_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Infinite Afterburn
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "infinite afterburn" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flInfiniteAfterburn_Duration[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_iInfiniteAfterburn_Ressuply[m_iWeapon]    = StringToInt( m_sValues[1] );
        m_bInfiniteAfterburn_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Kick-Ban On Kill-Hit
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "kickban on killhit" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iBANOnKillHit_Duration[m_iWeapon]         = StringToInt( m_sValues[0] );
        m_iBANOnKillHit_HitOrKill[m_iWeapon]        = StringToInt( m_sValues[1] );
        m_iBANOnKillHit_KickOrBan[m_iWeapon]        = StringToInt( m_sValues[2] );
        m_bBANOnKillHit_ATTRIBUTE[m_iWeapon]        = true;
        m_aAction = Plugin_Handled;
    }
    /* Cannot Be Stunned
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "cannot be stunned" ) )
    {
        m_iCannotBeStunned_Type[m_iWeapon]      = StringToInt( m_sValue );
        m_bCannotBeStunned_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Disable Übercharge
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "disable ubercharge" ) )
    {
        m_bDisableUbercharge_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Taken From Backstab Reduced
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg taken from backstab reduced" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flReduceBackstabDamage_Percentage[m_iWeapon]  = StringToFloat( m_sValues[0] );
        m_iReduceBackstabDamage_ActOrMax[m_iWeapon]     = StringToInt( m_sValues[1] );
        m_bReduceBackstabDamage_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Taken From Headshot Reduced
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg taken from headshot reduced" ) )
    {
        m_flReduceHeadshotDamage_Percentage[m_iWeapon]  = StringToFloat( m_sValue );
        m_bReduceHeadshotDamage_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Bonus Vs Players In Water
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg bonus vs players in water" ) )
    {
        m_flBonusDamageVSVictimInWater_Multiplier[m_iWeapon]   = StringToFloat( m_sValue );
        m_bBonusDamageVsVictimInWater_ATTRIBUTE[m_iWeapon]     = true;
        m_aAction = Plugin_Handled;
    }
    /* Crit Vs Players In Water
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "crit vs players in water" ) )
    {
        m_bCritVictimInWater_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* All Damage Done Multiplier
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "all dmg done multiplier" ) )
    {
        m_flAllDamageDoneMultiplier_Multiplier[m_iWeapon]  = StringToFloat( m_sValue );
        m_bAllDamageDoneMultiplier_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Damage Resistance Based On Health Missing
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "dmg resist health missing" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flDamageResHealthMissing_ResPctPerMissingHpPct[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_iDamageResHealthMissing_MaxStackOfMissingHpPct[m_iWeapon]   = StringToInt( m_sValues[1] );
        m_iDamageResHealthMissing_OverhealPenalty[m_iWeapon]          = StringToInt( m_sValues[2] );
        m_bDamageResHealthMissing_ATTRIBUTE[m_iWeapon]                = true;
        m_aAction = Plugin_Handled;
    }
    /* Random Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "random dmg" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flRandomDamage_Min[m_iWeapon]         = StringToFloat( m_sValues[0] );
        m_flRandomDamage_Max[m_iWeapon]         = StringToFloat( m_sValues[1] );
        m_bRandomDamage_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Laser Damage Penalty
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "laser dmg penalty" ) )
    {
        m_flLaserWeaponDamageModifier_Damage[m_iWeapon]     = StringToFloat( m_sValue );
        m_bLaserWeaponDamageModifier_ATTRIBUTE[m_iWeapon]   = true;
        m_aAction = Plugin_Handled;
    }
    /* Steal Damage
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "steal dmg" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_iStealDamage_Steal[m_iWeapon]     = StringToInt( m_sValues[0] );
        m_flStealDamage_Duration[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bStealDamage_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Set Weapon Slot
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "set weapon slot" ) )
    {
        m_iSetWeaponSwith_Slot[m_iWeapon]       = StringToInt( m_sValue );
        m_bSetWeaponSwitch_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Chance To Mad Milk
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "chance to mad milk" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flChanceMadMilk_Chance[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_flChanceMadMilk_Duration[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bChanceMadMilk_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Chance To Jarate
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "chance to jarate" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flChanceJarate_Chance[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_flChanceJarate_Duration[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bChanceJarate_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Chance To Bleed
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "chance to bleed" ) )
    {
        new String:m_sValues[2][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flChanceBleed_Chance[m_iWeapon]   = StringToFloat( m_sValues[0] );
        m_flChanceBleed_Duration[m_iWeapon] = StringToFloat( m_sValues[1] );
        m_bChanceBleed_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Heat Increases Damage Taken
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "heat increases dmg taken" ) )
    {
        new String:m_sValues[3][10];
        ExplodeString( m_sValue, " ", m_sValues, sizeof( m_sValues ), sizeof( m_sValues[] ) );

        m_flHeatDMGTaken_Delay[m_iWeapon]       = StringToFloat( m_sValues[0] );
        m_flHeatDMGTaken_DMG[m_iWeapon]         = StringToFloat( m_sValues[1] );
        m_iHeatDMGTaken_MaximumStack[m_iWeapon] = StringToInt( m_sValues[2] );
        m_bHeatDMGTaken_ATTRIBUTE[m_iWeapon]    = true;
        m_aAction = Plugin_Handled;
    }
    /* Bullets Per Shot Bonus Dynamic
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "bullets per shot bonus dynamic" ) )
    {
        m_bBulletsPerShotBonusDynamic_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }
    /* Teleport To Victim On Kill
     *
     * ---------------------------------------------------------------------- */
    else if ( StrEqual( m_sAttribute, "tp to victim on kill" ) )
    {
        m_bTeleportToVictimOnKill_ATTRIBUTE[m_iWeapon] = true;
        m_aAction = Plugin_Handled;
    }



    if ( !m_bHasAttribute[m_iWeapon] ) m_bHasAttribute[m_iWeapon] = bool:m_aAction;
    return m_aAction;
}

// ====[ ON TAKE DAMAGE ]==============================================
public Action:OnTakeDamage( m_iVictim, &m_iAttacker, &m_iInflictor, &Float:m_flDamage, &m_iType, &m_iWeapon, Float:m_flForce[3], Float:m_flPosition[3], m_iCustom )
{
    new Action:m_aAction;

    if ( m_flDamage >= 1.0 )
    {
        if ( IsValidClient( m_iVictim ) )
        {
            if ( HasAttribute( m_iVictim, _, m_bPsycho_ATTRIBUTE ) && m_hTimers[m_iVictim][m_hPsycho_TimerDuration] != INVALID_HANDLE && GetAttributeValueF( m_iVictim, _, m_bPsycho_ATTRIBUTE, m_flPsycho_DamageResistance ) <= 0.0 )
                m_flDamage = 0.0;
        //-//
            if ( HasAttribute( m_iVictim, _, m_bDamageResistanceInvisible_ATTRIBUTE ) && TF2_IsPlayerInCondition( m_iVictim, TFCond_Cloaked ) && GetAttributeValueF( m_iVictim, _, m_bDamageResistanceInvisible_ATTRIBUTE, m_flDamageResistanceInvisible_Multiplier ) <= 0.0 )
                m_flDamage = 0.0;
        //-//
            if ( HasAttribute( m_iVictim, _, m_bMarkVictimDamage_ATTRIBUTE ) && IsValidClient( m_iAttacker ) && m_hTimers[m_iAttacker][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE && ( GetAttributeValueF( m_iVictim, _, m_bMarkVictimDamage_ATTRIBUTE, m_flMarkVictimDamage_Damage ) * m_iIntegers[m_iAttacker][m_iMarkVictimDamageCount] ) >= 1.0 )
                m_flDamage = 0.0;
        //-//
            if ( HasAttribute( m_iVictim, _, m_bReduceBackstabDamage_ATTRIBUTE ) && m_iCustom == TF_CUSTOM_BACKSTAB && GetAttributeValueF( m_iVictim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_flReduceBackstabDamage_Percentage ) <= 0.0 )
                m_flDamage = 0.0;
        //-//
            if ( HasAttribute( m_iVictim, _, m_bReduceHeadshotDamage_ATTRIBUTE ) && GetAttributeValueF( m_iVictim, _, m_bReduceHeadshotDamage_ATTRIBUTE, m_flReduceHeadshotDamage_Percentage ) <= 0.0 ) {
                if ( m_iCustom == TF_CUSTOM_HEADSHOT || m_iCustom == TF_CUSTOM_HEADSHOT_DECAPITATION )
                    m_flDamage = 0.0;
            }
        //-//
            if ( HasAttribute( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE ) && GetAttributeValueF( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_flDamageResHealthMissing_ResPctPerMissingHpPct ) * (1 - FloatDiv( GetClientHealth( m_iVictim )+0.0, TF2_GetClientMaxHealth( m_iVictim )+0.0 ) ) >= 1.0 )
                m_flDamage = 0.0;
        //-//
            if ( HasAttribute( m_iVictim, _, m_bHeatDMGTaken_ATTRIBUTE, true ) && m_iIntegers[m_iVictim][m_iHeatToo] * GetAttributeValueF( m_iVictim, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_DMG, true ) )
                m_flDamage = 0.0;
        }

        if ( m_flDamage >= 1.0 )
        {
            if ( IsValidClient( m_iAttacker ) )
            {
                if ( IsValidClient( m_iVictim )
                    && !HasInvulnerabilityCond( m_iVictim )
                    && m_iAttacker != m_iVictim )
                {
                    if ( m_iWeapon != -1 )
                    {
                        g_iLastWeapon[m_iAttacker] = m_iWeapon;
                        if ( m_bHasAttribute[m_iWeapon] )
                        {

                            /* Mutiplies and Divides.
                             *
                             * -------------------------------------------------- */
                            if ( m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iAttacker ) <= m_flDamageIfHealthLowerThanThreshold_Threshold[m_iWeapon] * TF2_GetClientMaxHealth( m_iAttacker ) )
                                    m_flDamage *= m_flDamageIfHealthLowerThanThreshold_BonusDamage[m_iWeapon];
                            }
                        //-//
                            if ( m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iAttacker ) >= m_flDamageIfHealthHigherThanThreshold_Threshold[m_iWeapon] * TF2_GetClientMaxHealth( m_iAttacker ) )
                                    m_flDamage *= m_flDamageIfHealthHigherThanThreshold_BonusDamage[m_iWeapon];
                            }
                        //-//
                            if ( m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iVictim ) <= m_flDamageIfEnemyHealthLowerThanThreshold_Threshold[m_iWeapon] * TF2_GetClientMaxHealth( m_iVictim ) )
                                    m_flDamage *= m_flDamageIfEnemyHealthLowerThanThreshold_BonusDamage[m_iWeapon];
                            }
                        //-//
                            if ( m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iVictim ) >= m_flDamageIfEnemyHealthHigherThanThreshold_Threshold[m_iWeapon] * TF2_GetClientMaxHealth( m_iVictim ) )
                                    m_flDamage *= m_flDamageIfEnemyHealthHigherThanThreshold_BonusDamage[m_iWeapon];
                            }
                        //-//
                            if ( m_bDamageWhenMetalRunsOut_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( TF2_GetClientMetal( m_iAttacker ) <= 0 )
                                    m_flDamage *= m_flDamageWhenMetalRunsOut_Damage[m_iWeapon];
                            }
                        //-//
                            if ( m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( !( GetEntityFlags( m_iVictim ) & FL_ONGROUND ) && !( GetEntityFlags( m_iVictim ) & FL_INWATER ) )
                                    m_flDamage *= m_flBonusDamageVSVictimInMidAir_Multiplier[m_iWeapon];
                            }
                        //-//
                            if ( m_bDamageClass_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Scout )     m_flDamage *= m_flDamageClass_Scout[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Soldier )   m_flDamage *= m_flDamageClass_Soldier[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Pyro )      m_flDamage *= m_flDamageClass_Pyro[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_DemoMan )   m_flDamage *= m_flDamageClass_Demoman[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Heavy )     m_flDamage *= m_flDamageClass_Heavy[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Engineer )  m_flDamage *= m_flDamageClass_Engineer[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Medic )     m_flDamage *= m_flDamageClass_Medic[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Sniper )    m_flDamage *= m_flDamageClass_Sniper[m_iWeapon];
                                if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Spy )       m_flDamage *= m_flDamageClass_Spy[m_iWeapon];
                            }
                        //-//
                            if ( m_bPsycho_ATTRIBUTE[m_iWeapon] && m_hTimers[m_iAttacker][m_hPsycho_TimerDuration] != INVALID_HANDLE ) {
                                m_flDamage *= m_flPsycho_DamageBonus[m_iWeapon];
                            }
                        //-//
                            if ( m_bBonusDamageVsVictimInWater_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetEntityFlags( m_iVictim ) & FL_INWATER )
                                    m_flDamage *= m_flBonusDamageVSVictimInWater_Multiplier[m_iWeapon];
                            }
                        //-//
                            if ( m_bRandomDamage_ATTRIBUTE[m_iWeapon] ) {
                                m_flDamage *= GetRandomFloat( m_flRandomDamage_Min[m_iWeapon], m_flRandomDamage_Max[m_iWeapon] );
                            }
                        //-//
                            if ( m_bLaserWeaponDamageModifier_ATTRIBUTE[m_iWeapon] && m_iType & TF_DMG_LASER ) {
                                m_flDamage *= m_flLaserWeaponDamageModifier_Damage[m_iWeapon];
                            }
                            
                            /* Adds and Subtracts.
                             *
                             * -------------------------------------------------- */
                            if ( m_bCombo_ATTRIBUTE[m_iWeapon] )
                            {
                                m_iIntegers[m_iVictim][m_iCombo]++;

                                if ( m_iIntegers[m_iVictim][m_iCombo] >= m_iCombo_Hit[m_iWeapon] ) 
                                {
                                    if ( m_flCombo_BonusDamage[m_iWeapon] <= 10.0 ) m_flDamage *= m_flCombo_BonusDamage[m_iWeapon];
                                    else m_flDamage += m_flCombo_BonusDamage[m_iWeapon];
                                    if ( m_iCombo_Crit[m_iWeapon] == 1 ) m_iType = TF_DMG_CRIT|m_iType;
                                    m_iIntegers[m_iVictim][m_iCombo] = 0;
                                }
                            }
                        //-//
                            if ( m_bActualEnemyHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:m_flBonus = GetClientHealth( m_iVictim ) * m_flActualEnemyHealthToDamage_Multiplier[m_iWeapon];
                                m_flDamage += m_flBonus;
                            }
                        //-//
                            if ( m_bActualHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:m_flBonus = GetClientHealth( m_iAttacker ) * m_flActualHealthToDamage_Multiplier[m_iWeapon];
                                m_flDamage += m_flBonus;
                            }
                        //-//
                            if ( m_bMaximumEnemyHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:m_flBonus = TF2_GetClientMaxHealth( m_iVictim ) * m_flMaximumEnemyHealthToDamage_Multiplier[m_iWeapon];
                                m_flDamage += m_flBonus;
                            }
                        //-//
                            if ( m_bMaximumHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:m_flBonus = TF2_GetClientMaxHealth( m_iAttacker ) * m_flMaximumHealthToDamage_Multiplier[m_iWeapon];
                                m_flDamage += m_flBonus;
                            }
                        //-//
                            if ( m_bMissingHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iAttacker ) < TF2_GetClientMaxHealth( m_iAttacker ) )
                                    m_flDamage += ( ( TF2_GetClientMaxHealth( m_iAttacker ) - GetClientHealth( m_iAttacker ) ) * m_flMissingHealthToDamage_Multiplier[m_iWeapon] );
                            }
                        //-//
                            if ( m_bMissingEnemyHealthToDamage_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( GetClientHealth( m_iVictim ) < TF2_GetClientMaxHealth( m_iVictim ) )
                                    m_flDamage += ( ( TF2_GetClientMaxHealth( m_iVictim ) - GetClientHealth( m_iVictim ) ) * m_flMissingEnemyHealthToDamage_Multiplier[m_iWeapon] );
                            }
                        //-//
                            if ( m_bMovementSpeedToDamage_ATTRIBUTE[m_iWeapon] ) {
                                m_flDamage += ( GetClientMovementSpeed( m_iAttacker ) * m_flMovementSpeedToDamage_Multiplier[m_iWeapon] );
                            }
                        //-//
                            if ( m_bMetalToDamage_ATTRIBUTE[m_iWeapon] ) {
                                m_flDamage += ( TF2_GetClientMetal( m_iAttacker ) * m_flMetalToDamage_Multiplier[m_iWeapon] );
                            }
                        //-//
                            if ( m_bStealDamage_ATTRIBUTE[m_iWeapon] ) {
                                m_flDamage += m_iIntegers[m_iAttacker][m_iStealDamageAttacker];
                            }
                            
                            /* Sets.
                             *
                             * -------------------------------------------------- */
                            if ( m_bBackstabDamageModSubStun_ATTRIBUTE[m_iWeapon] && m_iCustom == TF_CUSTOM_BACKSTAB )
                            {
                                if ( TF2_GetPlayerClass( m_iAttacker ) == TFClass_Spy )
                                {
                                    new Float:duration = m_flBackstabDamageModSubStun_Duration[m_iWeapon];

                                    m_flDamage = RoundToCeil( ( TF2_GetClientMaxHealth( m_iVictim ) < GetClientHealth( m_iVictim ) ? GetClientHealth( m_iVictim ) : TF2_GetClientMaxHealth( m_iVictim ) ) * m_flBackstabDamageModSubStun_Multiplier[m_iWeapon] ) / 3.0;

                                    if ( duration != 0.0 )
                                    {
                                        if ( m_iBackstabDamageModSubStun_BlockSuicide[m_iWeapon] == 1 ) m_bBools[m_iVictim][m_bBackstab_SuicideBlocker] = true;
             
                                        new Float:m_flDuration;
                                        if ( m_iIntegers[m_iVictim][m_iOPBackstab] != 0 ) m_flDuration = duration / ( 2*m_iIntegers[m_iVictim][m_iOPBackstab] );
                                        else m_flDuration = duration;

                                        if ( m_iBackstabDamageModSubStun_Security[m_iWeapon] == 1 ) {

                                            if ( m_flDuration >= 10.0 ) m_iIntegers[m_iVictim][m_iOPBackstab]++;
                                        }
                                        TF2_StunPlayer( m_iVictim, m_flDuration, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iAttacker );

                                        EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 0.375 );
                                        EmitSoundToClient( m_iVictim, SOUND_TBASH, _, _, _, _, 0.75 );
                                    }
                                }
                            }
                        //-//
                            if ( m_bChanceOneShot_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( m_flChanceOneShot_Chance[m_iWeapon] >= GetRandomFloat( 0.0, 1.0 ) )
                                {
                                    m_flDamage = GetClientHealth( m_iVictim ) * 8.0;
                                    m_iType = TF_DMG_CRIT|m_iType;
                                }
                            }
                        //-//
                            if ( m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:mult = m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[m_iWeapon];

                                if ( GetClientHealth( m_iVictim ) >= ( TF2_GetClientMaxHealth( m_iVictim ) - ( 1 / mult ) ) )
                                {
                                    new Float:m_flHPDiff = ( GetClientHealth( m_iVictim ) - ( TF2_GetClientMaxHealth( m_iVictim ) - ( 1 / mult ) ) ) / 22.5; //22.5 particle/s
                                    if ( m_flHPDiff < 1.0 ) m_flHPDiff = 1.0;

                                    if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Pyro ) m_flDamage = m_flHPDiff * 2;
                                    else m_flDamage = m_flHPDiff;
                                } else {
                                    if ( TF2_GetPlayerClass( m_iVictim ) == TFClass_Pyro ) m_flDamage = ( ( TF2_GetClientMaxHealth( m_iVictim ) - GetClientHealth( m_iVictim ) ) * mult ) * 2;
                                    else m_flDamage = ( ( TF2_GetClientMaxHealth( m_iVictim ) - GetClientHealth( m_iVictim ) ) * mult );
                                }
                            }
                            
                            /* Critical.
                             *
                             * -------------------------------------------------- */
                            if ( m_bCritVsInvisiblePlayer_ATTRIBUTE[m_iWeapon] && !( m_iType & TF_DMG_CRIT ) )
                            {
                                if ( TF2_IsPlayerInCondition( m_iVictim, TFCond_Cloaked ) ||
                                    TF2_IsPlayerInCondition( m_iVictim, TFCond_CloakFlicker ) ||
                                    TF2_IsPlayerInCondition( m_iVictim, TFCond_Stealthed ) ||
                                    TF2_IsPlayerInCondition( m_iVictim, TFCond_StealthedUserBuffFade ) )
                                    m_iType = TF_DMG_CRIT|m_iType;
                            }
                        //-//
                            if ( m_bCritVictimInMidAir_ATTRIBUTE[m_iWeapon] && !( m_iType & TF_DMG_CRIT ) )
                            {
                                if ( !( GetEntityFlags( m_iVictim ) & FL_ONGROUND ) && !( GetEntityFlags( m_iVictim ) & FL_INWATER ) )
                                    m_iType = TF_DMG_CRIT|m_iType;
                            }
                        //-//
                            if ( m_bCritVictimScared_ATTRIBUTE[m_iWeapon] && !( m_iType & TF_DMG_CRIT ) )
                            {
                                if ( GetEntProp( m_iVictim, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE )
                                    m_iType = TF_DMG_CRIT|m_iType;
                            }
                        //-//
                            if ( m_bCritVictimInWater_ATTRIBUTE[m_iWeapon] && !( m_iType & TF_DMG_CRIT ) )
                            {
                                if ( GetEntityFlags( m_iVictim ) & FL_INWATER ) m_iType = TF_DMG_CRIT|m_iType;
                            }
                        //-//
                            if ( m_bCritVsBurningCLOSERANGE_ATTRIBUTE[m_iWeapon] && !( m_iType & TF_DMG_CRIT ) )
                            {
                                new Float:m_flPos1[3], Float:m_flPos2[3];
                                GetClientAbsOrigin( m_iAttacker, m_flPos1 );
                                GetClientAbsOrigin( m_iVictim, m_flPos2 );

                                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                                if ( distance <= m_flCritVsBurningCLOSERANGE_Range[m_iWeapon] )
                                {
                                    if ( TF2_IsPlayerInCondition( m_iVictim, TFCond_OnFire ) ) m_iType = TF_DMG_CRIT|m_iType;
                                }
                            }
                        //-//
                            if ( m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[m_iWeapon] )
                            {
                                new Float:m_flPos1[3], Float:m_flPos2[3];
                                GetClientAbsOrigin( m_iAttacker, m_flPos1 );
                                GetClientAbsOrigin( m_iVictim, m_flPos2 );

                                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                                if ( distance <= m_flMinicritVsBurningCLOSERANGE_Range[m_iWeapon] )
                                {
                                    if ( TF2_IsPlayerInCondition( m_iVictim, TFCond_OnFire ) ) TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                                }
                            }
                        //-//
                            if ( m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[m_iWeapon] )
                            {
                                if ( TF2_IsPlayerInCondition( m_iVictim, TFCond_Cloaked ) || TF2_IsPlayerInCondition( m_iVictim, TFCond_CloakFlicker ) ||
                                    TF2_IsPlayerInCondition( m_iVictim, TFCond_Stealthed ) || TF2_IsPlayerInCondition( m_iVictim, TFCond_StealthedUserBuffFade ) )
                                    TF2_AddCondition( m_iAttacker, TFCond_Buffed, 0.01 );
                            }
                        }
                        if ( m_iIntegers[m_iAttacker][m_iStealDamageVictim] >= 1 ) m_flDamage -= m_iIntegers[m_iAttacker][m_iStealDamageVictim];
                    }
                    
                    /* All damage done multiplier.
                     *
                     * ---------------------------------------------------------- */
                    if ( HasAttribute( m_iAttacker, _, m_bAllDamageDoneMultiplier_ATTRIBUTE ) ) {
                        m_flDamage *= GetAttributeValueF( m_iAttacker, _, m_bAllDamageDoneMultiplier_ATTRIBUTE, m_flAllDamageDoneMultiplier_Multiplier );
                    }
                }

                if ( HasAttribute( m_iAttacker, _, m_bBonusDamageVsSapper_ATTRIBUTE, true ) )
                {
                    decl String:m_sNetClass[32];
                    GetEntityNetClass( m_iVictim, m_sNetClass, sizeof( m_sNetClass ) );

                    if ( StrEqual( m_sNetClass, "CObjectSapper" ) ) TF2Attrib_SetByName( m_iWeapon, "dmg bonus vs buildings", GetAttributeValueF( m_iAttacker, _, m_bBonusDamageVsSapper_ATTRIBUTE, m_flBonusDamageVsSapper_Multiplier, true ) );
                }
            }

            if ( IsValidClient( m_iVictim ) )
            {
                if ( HasAttribute( m_iVictim, _, m_bPsycho_ATTRIBUTE ) && m_hTimers[m_iVictim][m_hPsycho_TimerDuration] != INVALID_HANDLE )
                    m_flDamage *= GetAttributeValueF( m_iVictim, _, m_bPsycho_ATTRIBUTE, m_flPsycho_DamageResistance );
            //-//
                if ( HasAttribute( m_iVictim, _, m_bDamageResistanceInvisible_ATTRIBUTE ) && TF2_IsPlayerInCondition( m_iVictim, TFCond_Cloaked ) )
                    m_flDamage *= GetAttributeValueF( m_iVictim, _, m_bDamageResistanceInvisible_ATTRIBUTE, m_flDamageResistanceInvisible_Multiplier );
            //-//
                if ( HasAttribute( m_iVictim, _, m_bMarkVictimDamage_ATTRIBUTE ) && IsValidClient( m_iAttacker ) && m_hTimers[m_iAttacker][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
                {
                    new Float:m_flAdd = GetAttributeValueF( m_iVictim, _, m_bMarkVictimDamage_ATTRIBUTE, m_flMarkVictimDamage_Damage ) * m_iIntegers[m_iAttacker][m_iMarkVictimDamageCount];
                    m_flDamage *= ( 1-m_flAdd );
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bReduceHeadshotDamage_ATTRIBUTE ) )
                {
                    if ( m_iCustom == TF_CUSTOM_HEADSHOT || m_iCustom == TF_CUSTOM_HEADSHOT_DECAPITATION )
                        m_flDamage *= GetAttributeValueF( m_iVictim, _, m_bReduceHeadshotDamage_ATTRIBUTE, m_flReduceHeadshotDamage_Percentage );
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bReduceBackstabDamage_ATTRIBUTE ) && m_iCustom == TF_CUSTOM_BACKSTAB )
                {
                    new actmax = GetAttributeValueI( m_iVictim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_iReduceBackstabDamage_ActOrMax );
                    new Float:pct = GetAttributeValueF( m_iVictim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_flReduceBackstabDamage_Percentage );

                    m_flDamage = ( ( actmax > 1 ? TF2_GetClientMaxHealth( m_iVictim ) : GetClientHealth( m_iVictim ) ) * 2.0 ) * pct;
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE ) )
                {
                    new overheal = GetAttributeValueI( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_OverhealPenalty );
                    new Float:res = GetAttributeValueF( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_flDamageResHealthMissing_ResPctPerMissingHpPct );
                    new stack = GetAttributeValueI( m_iVictim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct );

                    new Float:m_flMHP = 1-( FloatDiv( GetClientHealth( m_iVictim )+0.0, TF2_GetClientMaxHealth( m_iVictim )+0.0 ) );
                    if ( GetClientHealth( m_iVictim ) > TF2_GetClientMaxHealth( m_iVictim ) && overheal == 0 ) m_flMHP = 0.0;

                    new Float:m_flResPct = res * m_flMHP;
                    if ( m_flMHP * 100.0 > stack ) m_flResPct = res * FloatDiv( stack+0.0, 100.0 );
                    m_flDamage *= ( 1-m_flResPct );
                }
            //-//
                if ( HasAttribute( m_iVictim, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
                    m_flDamage *= ( 1+( m_iIntegers[m_iVictim][m_iHeatToo] * GetAttributeValueF( m_iVictim, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_DMG, true ) ) );
            }
        }
    }
    if ( m_flDamage < 0.0 ) m_flDamage == 0.0;

    m_aAction = Plugin_Changed;
    return m_aAction;
}

// ====[ ON TAKE DAMAGE ALIVE ]========================================
public Action:OnTakeDamageAlive( m_iVictim, &m_iAttacker, &m_iInflictor, &Float:m_flDamage, &m_iType, &m_iWeapon, Float:m_flForce[3], Float:m_flPosition[3], m_iCustom )
{
    new Action:m_aAction;

    if ( m_flDamage >= 1.0
        && IsValidClient( m_iAttacker )
        && IsValidClient( m_iVictim )
        && !HasInvulnerabilityCond( m_iVictim ) )
    {
        if ( m_iVictim != m_iAttacker )
        {
            if ( m_iType & TF_DMG_BLEED == TF_DMG_BLEED && m_iIntegers[m_iVictim][m_iHotSauceType] != 0 && TF2_IsPlayerInCondition( m_iVictim, TFCond_Bleeding ) && TF2_IsPlayerInCondition( m_iVictim, TFCond_Milked ) )
                TF2_HealPlayer( m_iAttacker, m_flDamage, 0.6666666667, true );

            if ( HasAttribute( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
            {
                new active    = GetAttributeValueI( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_iDamageReceivedUnleashedDeath_PoA );
                new Float:pct = GetAttributeValueF( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_flDamageReceivedUnleashedDeath_Percentage );

                if ( GetAttributeValueI( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_iDamageReceivedUnleashedDeath_Backstab ) != 1 && m_iCustom != TF_CUSTOM_BACKSTAB )
                {
                    if ( active == 0 || HasAttribute( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, true ) && active == 1 )
                        m_flFloats[m_iVictim][m_flDamageReceived] += ( m_flDamage * pct );

                    for ( new particles = 0 ; particles < 20.0 * ( 1.1-( FloatDiv( ( GetClientHealth( m_iVictim ) < TF2_GetClientMaxHealth( m_iVictim ) ? GetClientHealth( m_iVictim ) : TF2_GetClientMaxHealth( m_iVictim ) )+0.0, TF2_GetClientMaxHealth( m_iVictim )+0.0 ) ) ) ; particles++ )
                    {
                        new Float:w[3];
                        w[0] += GetRandomFloat( -20.0, 20.0 );
                        w[1] += GetRandomFloat( -20.0, 20.0 );
                        w[2] += GetRandomFloat( 5.0, 70.0 );
                        AttachParticle( m_iVictim, "sapper_sentry1_fx", m_flDamage / 10.0, w, w );
                    }
                }
            }
        }

        if ( m_iWeapon != -1
            && m_bHasAttribute[m_iWeapon] )
        {
            if ( m_bHotSauceOnHit_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_iIntegers[m_iVictim][m_iHotSauceType] != 0 )
                {
                    new type = m_iHotSauceOnHit_Type[m_iWeapon];

                    new Handle:m_hData01 = CreateDataPack();
                    CreateDataTimer( 0.01, m_tHotSauce_TimerDuration, m_hData01 );
                    WritePackFloat( m_hData01, m_flHotSauceOnHit_Duration[m_iWeapon] );
                    WritePackCell( m_hData01, m_iVictim );
                    WritePackCell( m_hData01, m_iAttacker );
                    WritePackCell( m_hData01, type );
                    m_iIntegers[m_iVictim][m_iHotSauceType] = type;
                }
            }
        //-//
            if ( m_bStunOnHit_ATTRIBUTE[m_iWeapon] )
            {
                TF2_StunPlayer( m_iVictim, m_flStunOnHit_Duration[m_iWeapon], 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iAttacker );
                EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 0.4 );
                EmitSoundToClient( m_iVictim, SOUND_TBASH, _, _, _, _, 0.75 );
            }
        //-//
            if ( m_bAfterburnCLOSERANGE_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iVictim ) != TFClass_Pyro && m_flDamage >= 1.0 )
            {
                new Float:duration = m_flAfterburnCLOSERANGE_Duration[m_iWeapon];
                if ( duration <= 0.0 ) duration = 1.0;

                new Float:m_flPos1[3], Float:m_flPos2[3];
                GetClientAbsOrigin( m_iAttacker, m_flPos1 );
                GetClientAbsOrigin( m_iVictim, m_flPos2 );

                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                if ( distance < m_flAfterburnCLOSERANGE_Range[m_iWeapon] )
                {
                    if ( !TF2Attrib_GetByName( m_iWeapon, "Set DamageType Ignite" ) ) {
                        TF2Attrib_SetByName( m_iWeapon, "Set DamageType Ignite", 1.0 );
                        if ( duration > 1.0 ) { // If higher than 1 (10 seconds)
                            if ( !TF2Attrib_GetByName( m_iWeapon, "weapon burn time increased" ) ) TF2Attrib_SetByName( m_iWeapon, "weapon burn time increased", duration );
                        } else if ( duration < 1.0 ) { // If lower than 1 (10 seconds)
                            if ( !TF2Attrib_GetByName( m_iWeapon, "weapon burn time decreased" ) ) TF2Attrib_SetByName( m_iWeapon, "weapon burn time decreased", duration );
                        }
                        
                    }
                }
                else TF2Attrib_RemoveByName( m_iWeapon, "Set DamageType Ignite" );
            }
        //-//
            if ( m_bBleedCLOSERANGE_ATTRIBUTE[m_iWeapon] )
            {
                new Float:m_flPos1[3], Float:m_flPos2[3];
                GetClientAbsOrigin( m_iAttacker, m_flPos1 );
                GetClientAbsOrigin( m_iVictim, m_flPos2 );

                new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                if ( distance < m_flBleedCLOSERANGE_Range[m_iWeapon] )
                {
                    TF2_RemoveCondition( m_iVictim, TFCond_Bleeding );
                    TF2_MakeBleed( m_iVictim, m_iAttacker, m_flBleedCLOSERANGE_Duration[m_iWeapon] );
                }
            }
        //-//
            if ( m_bChanceIgnite_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iVictim ) != TFClass_Pyro )
            {
                new Float:duration = m_flChanceIgnite_Duration[m_iWeapon];
                if ( duration <= 0.0 ) duration = 1.0;

                if ( m_flChanceIgnite_Chance[m_iWeapon] >= GetRandomFloat( 0.0, 1.0 ) )
                {
                    if ( !TF2Attrib_GetByName( m_iWeapon, "Set DamageType Ignite" ) )
                    {
                        TF2Attrib_SetByName( m_iWeapon, "Set DamageType Ignite", 1.0 );
                        if ( duration > 1.0 ) if ( !TF2Attrib_GetByName( m_iWeapon, "weapon burn time increased" ) ) TF2Attrib_SetByName( m_iWeapon, "weapon burn time increased", duration );
                        else if ( duration < 1.0 ) if ( !TF2Attrib_GetByName( m_iWeapon, "weapon burn time decreased" ) ) TF2Attrib_SetByName( m_iWeapon, "weapon burn time decreased", duration );
                    }
                }
                else TF2Attrib_RemoveByName( m_iWeapon, "Set DamageType Ignite" );
            }
        //-//
            if ( m_bChanceMadMilk_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_flChanceMadMilk_Chance[m_iWeapon] >= GetRandomFloat( 0.0, 1.0 ) )
                    TF2_AddCondition( m_iVictim, TFCond_Milked, m_flChanceMadMilk_Duration[m_iWeapon] );
            }
        //-//
            if ( m_bChanceJarate_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_flChanceJarate_Chance[m_iWeapon] >= GetRandomFloat( 0.0, 1.0 ) ) 
                    TF2_AddCondition( m_iVictim, TFCond_Jarated, m_flChanceJarate_Duration[m_iWeapon] );
            }
        //-//
            if ( m_bChanceBleed_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_flChanceBleed_Chance[m_iWeapon] >= GetRandomFloat( 0.0, 1.0 ) )
                    TF2_MakeBleed( m_iVictim, m_iAttacker, m_flChanceBleed_Duration[m_iWeapon] );
            }
        //-//
            if ( m_bRemoveBleeding_ATTRIBUTE[m_iWeapon] )
                TF2_RemoveCondition( m_iVictim, TFCond_Bleeding );
        //-//
            if ( m_bInfiniteAfterburn_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iVictim ) != TFClass_Pyro )
            {
                if ( m_hTimers[m_iVictim][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iVictim][m_hInfiniteAfterburn_TimerDuration] );
                if ( m_hTimers[m_iVictim][m_hInfiniteAfterburn_TimerDuration] == INVALID_HANDLE )
                {
                    TF2_IgnitePlayer( m_iVictim, m_iAttacker );
                    g_pBurner[m_iVictim] = m_iAttacker;
                    if ( m_iInfiniteAfterburn_Ressuply[m_iWeapon] == 1 ) m_bBools[m_iVictim][m_bInfiniteAfterburnRessuply] = true;
                    m_hTimers[m_iVictim][m_hInfiniteAfterburn_TimerDuration] = CreateTimer( m_flInfiniteAfterburn_Duration[m_iWeapon], m_tInfiniteAfterburn_TimerDuration, m_iVictim );
                }
            }
        //-//
            if ( m_bBANOnKillHit_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_iBANOnKillHit_HitOrKill[m_iWeapon] == 1 ) {
                    if ( m_iBANOnKillHit_KickOrBan[m_iWeapon] == 1 ) KickClient( m_iVictim, "Your ass just got kicked by the mighty custom's power !" );
                    else if ( m_iBANOnKillHit_KickOrBan[m_iWeapon] == 2 ) BanClient( m_iVictim, m_iBANOnKillHit_Duration[m_iWeapon], BANFLAG_AUTHID, "Custom", "Your ass just got banned by the mighty custom's power !", "Custom" );
                }
            }
        //-//
            if ( m_bDamageDoneIsSelfHurt_ATTRIBUTE[m_iWeapon] )
                DealDamage( m_iAttacker, RoundToFloor( m_flDamage * m_flDamageDoneIsSelfHurt_Multiplier[m_iWeapon] / ( m_iType & TF_DMG_CRIT ? 3.0 : 1.0 ) ), m_iWeapon, m_iType|TF_DMG_PREVENT_PHYSICS_FORCE );

            if ( m_iVictim != m_iAttacker )
            {
                if ( m_bDrainUbercharge_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iVictim ) == TFClass_Medic && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Medic )
                {
                    new Float:pct = m_flDrainUbercharge_Percentage[m_iWeapon];
                    new Float:m_flAttackerUbercharge = TF2_GetClientUberLevel( m_iAttacker );
                    new Float:m_flVictimUbercharge = TF2_GetClientUberLevel( m_iVictim );

                    if ( m_flVictimUbercharge > 0.0 && m_flAttackerUbercharge < 100.0 )
                    {
                        if ( m_flVictimUbercharge >= ( pct * 100.0 ) )
                        {
                            if ( m_flAttackerUbercharge > ( 100.0 - ( pct * 100.0 ) ) )
                            {
                                m_flVictimUbercharge -= ( 100.0 - m_flAttackerUbercharge );
                                TF2_SetClientUberLevel( m_iVictim, m_flVictimUbercharge );

                                TF2_SetClientUberLevel( m_iAttacker, 100.0 );
                            } else {
                                m_flAttackerUbercharge += ( pct * 100.0 );
                                TF2_SetClientUberLevel( m_iAttacker, m_flAttackerUbercharge );

                                m_flVictimUbercharge -= ( pct * 100.0 );
                                TF2_SetClientUberLevel( m_iVictim, m_flVictimUbercharge );
                            }
                        } else {
                            TF2_SetClientUberLevel( m_iVictim, 0.0 );
                            TF2_SetClientUberLevel( m_iAttacker, ( m_flAttackerUbercharge + m_flVictimUbercharge ) );
                        }
                    }
                }
            //-//
                if ( m_bUberchargeOnHit_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Medic )
                    TF2_SetClientUberLevel( m_iAttacker, TF2_GetClientUberLevel( m_iAttacker ) + m_flUberchargeOnHit_Amount[m_iWeapon] );
            //-//
                if ( m_bMetalOnHit_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Engineer )
                {
                    new Float:metal = m_flMetalOnHit_Amount[m_iWeapon];
                    new metal_p     = TF2_GetClientMetal( m_iAttacker );
                    new metal_n     = RoundToFloor( metal_p + ( metal < 1.0 ? metal_p * metal : metal ) );

                    TF2_SetClientMetal( m_iAttacker, metal_n );
                }
            //-//
                if ( m_bMarkVictimDamage_ATTRIBUTE[m_iWeapon] )
                {
                    new maxvictim = m_iMarkVictimDamage_MaximumVictim[m_iWeapon];
                    new maxstack = m_iMarkVictimDamage_MaximumDamageStack[m_iWeapon];
                    g_pMarker[m_iVictim] = m_iAttacker;

                    if ( m_hTimers[m_iVictim][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
                    {
                        ClearTimer( m_hTimers[m_iVictim][m_hMarkVictimDamage_TimerDuration] );
                        m_iIntegers[m_iAttacker][m_iMarkVictimDamage]--;
                    }
                    if ( m_hTimers[m_iAttacker][m_hMarkVictimDamage_TimerDuration] == INVALID_HANDLE && m_iIntegers[m_iAttacker][m_iMarkVictimDamage] < maxvictim )
                    {
                        m_iIntegers[m_iAttacker][m_iMarkVictimDamage]++;
                        if ( m_iIntegers[m_iVictim][m_iMarkVictimDamageCount] < maxstack ) m_iIntegers[m_iVictim][m_iMarkVictimDamageCount]++;

                        new Handle:m_hData01 = CreateDataPack();
                        m_hTimers[m_iVictim][m_hMarkVictimDamage_TimerDuration] = CreateDataTimer( m_flMarkVictimDamage_Duration[m_iWeapon], m_tMarkVictimDamage_TimerDuration, m_hData01 );
                        WritePackCell( m_hData01, m_iVictim );
                        WritePackCell( m_hData01, m_iAttacker );
                    }
                    if ( m_iIntegers[m_iAttacker][m_iMarkVictimDamage] > maxvictim ) m_iIntegers[m_iAttacker][m_iMarkVictimDamage] = maxvictim;
                    if ( m_iIntegers[m_iVictim][m_iMarkVictimDamageCount] > maxstack ) m_iIntegers[m_iVictim][m_iMarkVictimDamageCount] = maxstack;
                }
            //-//
                if ( m_bHealthLifesteal_ATTRIBUTE[m_iWeapon] )
                    TF2_HealPlayer( m_iAttacker, GetClientHealth( m_iAttacker ) * m_flHealthLifesteal_Multiplier[m_iWeapon], m_flHealthLifesteal_OverHealBonusCap[m_iWeapon], true );
            //-//
                if ( m_bEnemyHealthLifesteal_ATTRIBUTE[m_iWeapon] )
                    TF2_HealPlayer( m_iAttacker, GetClientHealth( m_iVictim ) * m_flEnemyHealthLifesteal_Multiplier[m_iWeapon], m_flEnemyHealthLifesteal_OverHealBonusCap[m_iWeapon], true );
            //-//
                if ( m_bMissingEnemyHealthLifesteal_ATTRIBUTE[m_iWeapon] )
                {
                    if ( GetClientHealth( m_iVictim ) < TF2_GetClientMaxHealth( m_iVictim ) )
                        TF2_HealPlayer( m_iAttacker, ( TF2_GetClientMaxHealth( m_iVictim ) - GetClientHealth( m_iVictim ) ) * m_flMissingEnemyHealthLifesteal_Multiplier[m_iWeapon], m_flMissingEnemyHealthLifesteal_OverHealBonusCap[m_iWeapon], true );
                }
            //-//
                if ( m_bMCFRTD_ATTRIBUTE[m_iWeapon] ) {
                    if ( m_hTimers[m_iAttacker][m_hMCFRTD_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iAttacker][m_hMCFRTD_TimerDelay] );
                }
            //-//
                if ( m_bPsycho_ATTRIBUTE[m_iWeapon] )
                {
                    if ( m_flFloats[m_iAttacker][m_flPyschoCharge] < 100.0 && m_hTimers[m_iAttacker][m_hPsycho_TimerDuration] == INVALID_HANDLE )
                    {
                        new Float:m_flCharge = ( 2 * m_flDamage * ( 1.1 - FloatDiv( GetClientHealth( m_iAttacker )+0.0, TF2_GetClientMaxHealth( m_iAttacker )+0.0 ) ) ) * m_flPsycho_DamageResistance[m_iWeapon];
                        if ( m_flCharge < 1.0 ) m_flCharge = 1.0;
                        m_flFloats[m_iAttacker][m_flPyschoCharge] += m_flCharge;
                    }
                }
            //-//
                if ( m_bMetalOnHitDamage_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Engineer )
                    TF2_SetClientMetal( m_iAttacker, RoundToFloor( TF2_GetClientMetal( m_iAttacker ) + ( m_flDamage * m_flMetalOnHitDamage_Multiplier[m_iWeapon] ) ) );
            //-//
                if ( m_bStealDamage_ATTRIBUTE[m_iWeapon] )
                {
                    if ( m_hTimers[m_iAttacker][m_hStealDamageA_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iAttacker][m_hStealDamageA_TimerDuration] );
                    if ( m_hTimers[m_iAttacker][m_hStealDamageA_TimerDuration] == INVALID_HANDLE )
                    {
                        m_iIntegers[m_iAttacker][m_iStealDamageAttacker] += m_iStealDamage_Steal[m_iWeapon];
                        m_hTimers[m_iAttacker][m_hStealDamageA_TimerDuration] = CreateTimer( m_flStealDamage_Duration[m_iWeapon], m_tStealDamageAttacker, m_iAttacker );
                    }
                    if ( m_hTimers[m_iVictim][m_hStealDamageV_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iVictim][m_hStealDamageV_TimerDuration] );
                    if ( m_hTimers[m_iVictim][m_hStealDamageV_TimerDuration] == INVALID_HANDLE )
                    {
                        m_iIntegers[m_iVictim][m_iStealDamageVictim] += m_iStealDamage_Steal[m_iWeapon];
                        m_hTimers[m_iVictim][m_hStealDamageV_TimerDuration] = CreateTimer( m_flStealDamage_Duration[m_iWeapon], m_tStealDamageVictim, m_iVictim );
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
public OnTakeDamagePost( m_iVictim, m_iAttacker, m_iInflictor, Float:m_flDamage, m_iType, m_iWeapon, const Float:m_flForce[3], const Float:m_flPosition[3] )
{
    if ( m_flDamage >= 1.0
        && IsValidClient( m_iAttacker )
        && IsValidClient( m_iVictim )
        && !HasInvulnerabilityCond( m_iVictim )
        && m_iWeapon != -1
        && m_bHasAttribute[m_iWeapon] )
    {
        if ( m_iType & TF_DMG_CRIT || IsCritBoosted( m_iAttacker ) )
        {
            if ( m_bStunOnCrit_ATTRIBUTE[m_iWeapon] )
            {
                TF2_StunPlayer( m_iVictim, m_flStunOnCrit_Duration[m_iWeapon], 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, m_iAttacker );
                EmitSoundToClient( m_iAttacker, SOUND_TBASH, _, _, _, _, 0.25 );
                EmitSoundToClient( m_iVictim, SOUND_TBASH, _, _, _, _, 0.75 );
            }
        //-//
            if ( m_bHotSauceOnCrit_ATTRIBUTE[m_iWeapon] )
            {
                if ( m_iIntegers[m_iVictim][m_iHotSauceType] != 0 )
                {
                    new type = m_iHotSauceOnCrit_Type[m_iWeapon];

                    new Handle:m_hData01 = CreateDataPack();
                    CreateDataTimer( 0.01, m_tHotSauce_TimerDuration, m_hData01 );
                    WritePackFloat( m_hData01, m_flHotSauceOnCrit_Duration[m_iWeapon] );
                    WritePackCell( m_hData01, m_iVictim );
                    WritePackCell( m_hData01, m_iAttacker );
                    WritePackCell( m_hData01, type );
                    m_iIntegers[m_iVictim][m_iHotSauceType] = type;
                }
            }

            if ( m_iVictim != m_iAttacker )
            {
                if ( m_bDrainUberchargeOnCrit_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iVictim ) == TFClass_Medic && TF2_GetPlayerClass( m_iAttacker ) == TFClass_Medic )
                {
                    new Float:pct = m_flDrainUberchargeOnCrit_Percentage[m_iWeapon];
                    new Float:m_flAttackerUbercharge = TF2_GetClientUberLevel( m_iAttacker );
                    new Float:m_flVictimUbercharge = TF2_GetClientUberLevel( m_iVictim );

                    if ( m_flVictimUbercharge > 0.0 && m_flAttackerUbercharge < 100.0 )
                    {
                        if ( m_flVictimUbercharge >= ( pct * 100.0 ) )
                        {
                            if ( m_flAttackerUbercharge > ( 100.0 - ( pct * 100.0 ) ) )
                            {
                                m_flVictimUbercharge -= ( 100.0 - m_flAttackerUbercharge );
                                TF2_SetClientUberLevel( m_iVictim, m_flVictimUbercharge );

                                TF2_SetClientUberLevel( m_iAttacker, 100.0 );
                            } else {
                                m_flAttackerUbercharge += ( pct * 100.0 );
                                TF2_SetClientUberLevel( m_iAttacker, m_flAttackerUbercharge );

                                m_flVictimUbercharge -= ( pct * 100.0 );
                                TF2_SetClientUberLevel( m_iVictim, m_flVictimUbercharge );
                            }
                        } else {
                            TF2_SetClientUberLevel( m_iVictim, 0.0 );
                            TF2_SetClientUberLevel( m_iAttacker, ( m_flAttackerUbercharge + m_flVictimUbercharge ) );
                        }
                    }
                }
            }
        }
    }
    if ( m_flDamage < 0.0 ) m_flDamage = 0.0;

    return;
}

// ====[ CALC IS ATTACK CRITICAL ]=====================================
public Action:TF2_CalcIsAttackCritical( m_iClient, m_iWeapon, String:m_strName[], &bool:m_bResult )
{
    if ( IsValidClient( m_iClient )
        && IsPlayerAlive( m_iClient )
        && m_iWeapon != -1
        && m_bHasAttribute[m_iWeapon] )
    {
        if ( m_bDamageSelf_ATTRIBUTE[m_iWeapon] )
            DealDamage( m_iClient, m_iDamageSelf_Amount[m_iWeapon], m_iClient, TF_DMG_PREVENT_PHYSICS_FORCE|HL_DMG_GENERIC );
    //-//
        if ( m_bMetalPerShot_ATTRIBUTE[m_iWeapon] && TF2_GetPlayerClass( m_iClient ) == TFClass_Engineer )
        {
            new Float:metal = m_flMetalPerShot_Amount[m_iWeapon];
            new metal_p      = TF2_GetClientMetal( m_iClient );
            new metal_n     = RoundToFloor( metal_p + ( metal < 1.0 ? metal_p * metal : metal ) );

            TF2_SetClientMetal( m_iClient, metal_n );
        }
    //-//
        if ( m_bMCFRTD_ATTRIBUTE[m_iWeapon] )
        {
            if ( m_iIntegers[m_iClient][m_iMissStack] < m_iMCFRTD_MaximumStack[m_iWeapon] )
            {
                if ( m_hTimers[m_iClient][m_hMCFRTD_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[m_iClient][m_hMCFRTD_TimerDelay] );
                else {
                    new Handle:m_hData03 = CreateDataPack();
                    WritePackCell( m_hData03, m_iClient );
                    WritePackCell( m_hData03, m_iWeapon );
                    m_hTimers[m_iClient][m_hMCFRTD_TimerDelay] = CreateTimer( 0.0, m_tMCFRTD_Timer, m_hData03 );
                
                    m_bBools[m_iClient][m_bLastWasMiss] = false;
                }
            }
        }
    //-//
        if ( m_bBulletsPerShotBonusDynamic_ATTRIBUTE[m_iWeapon] )
            TF2Attrib_SetByName( m_iWeapon, "bullets per shot bonus", GetEntProp( m_iWeapon, Prop_Data, "m_iClip1" )+0.0 );
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
            if ( HasAttribute( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
                CreateTimer( 0.03, m_tDamageReceivedUnleashedDeath_TimerDelay, m_iVictim ); // AVOID PROBLEMS.
        //-//
            if ( HasAttribute( m_iVictim, _, m_bAttackSpeedOnKill_ATTRIBUTE ) )
            {
                if ( GetAttributeValueF( m_iVictim, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_Removal ) < 1.0 )
                    m_iIntegers[m_iVictim][m_iAttackSpeed] = RoundToFloor( m_iIntegers[m_iVictim][m_iAttackSpeed] * GetAttributeValueF( m_iVictim, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_Removal ) );
            }

            if ( m_hTimers[m_iVictim][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
            {
                if ( m_iIntegers[g_pMarker[m_iVictim]][m_iMarkVictimDamage] > 0 && GetClientTeam( g_pMarker[m_iVictim] ) != GetClientTeam( m_iVictim ) && HasAttribute( g_pMarker[m_iVictim], _, m_bMarkVictimDamage_ATTRIBUTE ) )
                    m_iIntegers[g_pMarker[m_iVictim]][m_iMarkVictimDamage]--;
            }
            for ( new i = 0; i < m_hTimer; i++ )
            {
                ClearTimer( m_hTimers[m_iVictim][i] );
            }
            for ( new i = 0; i < m_bBool; i++ )
            {
                m_bBools[m_iVictim][i]      = false;
            }
            for ( new i = 0; i < m_flFloat-1; i++ )
            {
                m_flFloats[m_iVictim][i]    = 0.0;
            }
            for ( new i = 0; i < m_iInteger-1; i++ )
            {
                m_iIntegers[m_iVictim][i]   = 0;
            }
            g_pBurner[m_iVictim] = -1;
            g_pMarker[m_iVictim] = -1;
        }

        if ( IsValidClient( m_iKiller )
            && m_iKiller != m_iVictim )
        {
            new m_iWeapon = g_iLastWeapon[m_iKiller];
            if ( m_iWeapon != -1 && m_bHasAttribute[m_iWeapon] )
            {
                if ( m_bKillGib_ATTRIBUTE[m_iWeapon] )
                {
                    new Float:fClientOrigin[3];
                    GetClientAbsOrigin( m_iVictim, fClientOrigin );

                    new ragdoll = CreateEntityByName( "tf_ragdoll" );
                    if ( IsValidEdict( ragdoll ) )
                    {
                        SetEntPropVector( ragdoll, Prop_Send, "m_vecRagdollOrigin", fClientOrigin );
                        SetEntProp( ragdoll, Prop_Send, "m_iPlayerIndex", m_iVictim );
                        SetEntPropVector( ragdoll, Prop_Send, "m_vecForce", NULL_VECTOR );
                        SetEntPropVector( ragdoll, Prop_Send, "m_vecRagdollVelocity", NULL_VECTOR );
                        SetEntProp( ragdoll, Prop_Send, "m_bGib", 1 );

                        DispatchSpawn( ragdoll );

                        CreateTimer( 0.1, RemoveBody, m_iVictim );
                        CreateTimer( 15.0, TF2_RemoveGibs, ragdoll );
                    }
                }
            //-//
                if ( m_bSpawnSkeletonOnKill_ATTRIBUTE[m_iWeapon] )
                {
                    new boss = m_iSpawnSkeletonOnKill_Boss[m_iWeapon];
                    new Float:duration = m_flSpawnSkeletonOnKill_Duration[m_iWeapon];

                    if ( ( boss == 0 ? 0.0 : m_flSpawnSkeletonOnKill_BossChance[m_iWeapon] ) >= GetRandomFloat( 0.0, 1.0 ) )
                    {
                        if ( boss == 1 ) SpawnThing( "headless_hatman", duration * 10.0, m_iVictim );
                        if ( boss == 2 ) SpawnThing( "tf_zombie_spawner", 0.0, m_iVictim );
                        if ( boss == 3 && TF2_GetPlayerClass( m_iVictim ) == TFClass_DemoMan ) SpawnThing( "eyeball_boss", duration * 10.0, m_iVictim );
                    }
                    else SpawnThing( "tf_zombie", duration, m_iVictim, GetClientTeam( m_iKiller ) );
                }
            //-//
                if ( m_bAttackSpeedOnKill_ATTRIBUTE[m_iWeapon] )
                {
                    new max = m_iAttackSpeedOnKill_MaximumStack[m_iWeapon];

                    m_iIntegers[m_iKiller][m_iAttackSpeed]++;
                    if ( m_iIntegers[m_iKiller][m_iAttackSpeed] > max ) m_iIntegers[m_iKiller][m_iAttackSpeed] = max;
                }
            //-//
                if ( m_bBANOnKillHit_ATTRIBUTE[m_iWeapon] )
                {
                    new kickban = m_iBANOnKillHit_KickOrBan[m_iWeapon];

                    if ( m_iBANOnKillHit_HitOrKill[m_iWeapon] == 2 )
                    {
                        if ( kickban == 1 ) KickClient( m_iVictim, "Your ass just got kicked by the mighty custom power !" );
                        else if ( kickban == 2 ) {
                            if ( !IsFakeClient( m_iVictim ) ) BanClient( m_iVictim, m_iBANOnKillHit_Duration[m_iWeapon], BANFLAG_AUTHID, "Custom", "Your ass just got banned by the mighty custom power !", "Custom" );
                        }
                    }
                }
            //-//
                if ( m_bTeleportToVictimOnKill_ATTRIBUTE[m_iWeapon] )
                {
                    if ( TF2_GetPlayerClass( m_iKiller ) != TFClass_Engineer && TF2_GetPlayerClass( m_iKiller ) != TFClass_Medic && TF2_GetPlayerClass( m_iKiller ) != TFClass_Sniper && !m_bFeignDeath )
                    {
                        new Float:m_flPos[3];
                        GetClientAbsOrigin( m_iVictim, m_flPos );

                        TeleportEntity( m_iKiller, m_flPos, NULL_VECTOR, NULL_VECTOR );
                    }
                }
            }
        }
    }
    return Plugin_Continue;
}

// ====[ ON CONDITION REMOVED ]========================================
public TF2_OnConditionRemoved( m_iClient, TFCond:condition )
{
    if ( IsValidClient( m_iClient ) )
    {
        if ( m_iIntegers[m_iClient][m_iHotSauceType] != 0 )
        {
            new type = m_iIntegers[m_iClient][m_iHotSauceType];

            if ( type == 1 || type == 4 || type == 5 || type == 7 )
                if ( condition == TFCond_Milked ) m_iIntegers[m_iClient][m_iHotSauceType] = 0;
            if ( type == 2 || type == 4 || type == 6 || type == 7 )
                if ( condition == TFCond_Jarated ) m_iIntegers[m_iClient][m_iHotSauceType] = 0;
            if ( type == 3 || type == 5 || type == 6 || type == 7 )
                if ( condition == TFCond_Bleeding ) m_iIntegers[m_iClient][m_iHotSauceType] = 0;
        }
        if ( m_bBools[m_iClient][m_bBackstab_SuicideBlocker] )
        {
            if ( condition == TFCond_Dazed ) m_bBools[m_iClient][m_bBackstab_SuicideBlocker] = false;
        }
        if ( m_hTimers[m_iClient][m_hInfiniteAfterburn_TimerDuration] == INVALID_HANDLE )
        {
            if ( condition == TFCond_OnFire ) g_pBurner[m_iClient] = -1;
        }
    }
}

// ====[ ON GAME FRAME ]===============================================
public OnGameFrame()
{
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( HasAttribute( i, _, m_bHomingProjectile_ATTRIBUTE ) )
        {
            new Float:radius = GetAttributeValueF( i, _, m_bHomingProjectile_ATTRIBUTE, m_flHomingProjectile_DetectRadius );
            new mode = GetAttributeValueI( i, _, m_bHomingProjectile_ATTRIBUTE, m_iHomingProjectile_Mode );
            new type = GetAttributeValueI( i, _, m_bHomingProjectile_ATTRIBUTE, m_iHomingProjectile_Type );

            SetHomingProjectile( i, "tf_projectile_energy_ball", radius, mode, type );
            SetHomingProjectile( i, "tf_projectile_rocket", radius, mode, type );
            SetHomingProjectile( i, "tf_projectile_healing_bolt", radius, mode, type );
            SetHomingProjectile( i, "tf_projectile_flare", radius, mode, type );
            SetHomingProjectile( i, "tf_projectile_arrow", radius, mode, type );
        }
    }
}

// ====[ ON ENTITY DESTROYED ]=========================================
public OnEntityDestroyed( m_iEntity )
{
    if ( m_iEntity <= 0 || m_iEntity > 2048 ) return;
    if ( m_bHasAttribute[m_iEntity] ) // I use this, so it doesn't call on every ENTITY destroyed, just custom weapons.
    {
        m_bHasAttribute[m_iEntity]  = false;


        /* On Hit
         * ---------------------------------------------------------------------- */

        m_bHotSauceOnHit_ATTRIBUTE[m_iEntity]               = false;
        m_flHotSauceOnHit_Duration[m_iEntity]               = 0.0;
        m_iHotSauceOnHit_Type[m_iEntity]                    = 0;

        m_bStunOnHit_ATTRIBUTE[m_iEntity]                   = false;
        m_flStunOnHit_Duration[m_iEntity]                   = 0.0;

        m_bDrainUbercharge_ATTRIBUTE[m_iEntity]             = false;
        m_flDrainUbercharge_Percentage[m_iEntity]           = 0.0;

        m_bMetalOnHit_ATTRIBUTE[m_iEntity]                  = false;
        m_flMetalOnHit_Amount[m_iEntity]                    = 0.0;

        m_bUberchargeOnHit_ATTRIBUTE[m_iEntity]             = false;
        m_flUberchargeOnHit_Amount[m_iEntity]               = 0.0;

        m_bRemoveBleeding_ATTRIBUTE[m_iEntity]              = false;

        m_bAfterburnCLOSERANGE_ATTRIBUTE[m_iEntity]         = false;
        m_flAfterburnCLOSERANGE_Duration[m_iEntity]         = 0.0;
        m_flAfterburnCLOSERANGE_Range[m_iEntity]            = 0.0;

        m_bBleedCLOSERANGE_ATTRIBUTE[m_iEntity]             = false;
        m_flBleedCLOSERANGE_Duration[m_iEntity]             = 0.0;
        m_flBleedCLOSERANGE_Range[m_iEntity]                = 0.0;

        m_bMarkVictimDamage_ATTRIBUTE[m_iEntity]            = false;
        m_flMarkVictimDamage_Duration[m_iEntity]            = 0.0;
        m_flMarkVictimDamage_Damage[m_iEntity]              = 0.0;
        m_iMarkVictimDamage_MaximumVictim[m_iEntity]        = 0;
        m_iMarkVictimDamage_MaximumDamageStack[m_iEntity]   = 0;

        m_bInfiniteAfterburn_ATTRIBUTE[m_iEntity]           = false;
        m_flInfiniteAfterburn_Duration[m_iEntity]           = 0.0;
        m_iInfiniteAfterburn_Ressuply[m_iEntity]            = 0;

        //m_bDeathPact_ATTRIBUTE[m_iEntity]                 = false;
        //m_flDeathPact_Share[m_iEntity]                    = 0.0;


        /* On Crit
         * ---------------------------------------------------------------------- */

        m_bHotSauceOnCrit_ATTRIBUTE[m_iEntity]              = false;
        m_flHotSauceOnCrit_Duration[m_iEntity]              = 0.0;
        m_iHotSauceOnCrit_Type[m_iEntity]                   = 0;

        m_bStunOnCrit_ATTRIBUTE[m_iEntity]                  = false;
        m_flStunOnCrit_Duration[m_iEntity]                  = 0.0;

        m_bDrainUberchargeOnCrit_ATTRIBUTE[m_iEntity]       = false;
        m_flDrainUberchargeOnCrit_Percentage[m_iEntity]     = 0.0;

        m_bCritVsInvisiblePlayer_ATTRIBUTE[m_iEntity]       = false;

        m_bCritVictimInMidAir_ATTRIBUTE[m_iEntity]          = false;

        m_bCritVictimScared_ATTRIBUTE[m_iEntity]            = false;

        m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[m_iEntity]   = false;

        m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[m_iEntity] = false;
        m_flMinicritVsBurningCLOSERANGE_Range[m_iEntity]    = 0.0;

        m_bCritVsBurningCLOSERANGE_ATTRIBUTE[m_iEntity]     = false;
        m_flCritVsBurningCLOSERANGE_Range[m_iEntity]        = 0.0;

        m_bCritVictimInWater_ATTRIBUTE[m_iEntity]           = false;


        /* On Attack
         * ---------------------------------------------------------------------- */

        m_bDamageSelf_ATTRIBUTE[m_iEntity]      = false;
        m_iDamageSelf_Amount[m_iEntity]         = 0;

        m_bMetalPerShot_ATTRIBUTE[m_iEntity]    = false;
        m_flMetalPerShot_Amount[m_iEntity]      = 0.0;

        m_bMCFRTD_ATTRIBUTE[m_iEntity]          = false;
        m_flMCFRTD_AttackSpeed[m_iEntity]       = 0.0;
        m_flMCFRTD_OldAttackSpeed[m_iEntity]    = 0.0;
        m_iMCFRTD_MaximumStack[m_iEntity]       = 0;


        /* On Kill
         * ---------------------------------------------------------------------- */

        m_bKillGib_ATTRIBUTE[m_iEntity]                 = false;

        m_bSpawnSkeletonOnKill_ATTRIBUTE[m_iEntity]     = false;
        m_flSpawnSkeletonOnKill_Duration[m_iEntity]     = 0.0;
        m_iSpawnSkeletonOnKill_Boss[m_iEntity]          = 0;
        m_flSpawnSkeletonOnKill_BossChance[m_iEntity]   = 0.0;

        m_bAttackSpeedOnKill_ATTRIBUTE[m_iEntity]       = false;
        m_flAttackSpeedOnKill_AttackSpeed[m_iEntity]    = 0.0;
        m_flAttackSpeedOnKill_Removal[m_iEntity]        = 0.0;
        m_flAttackSpeedOnKill_OldAttackSpeed[m_iEntity] = 0.0;
        m_iAttackSpeedOnKill_MaximumStack[m_iEntity]    = 0;

        m_bBANOnKillHit_ATTRIBUTE[m_iEntity]            = false;
        m_iBANOnKillHit_Duration[m_iEntity]             = 0;
        m_iBANOnKillHit_HitOrKill[m_iEntity]            = 0;
        m_iBANOnKillHit_KickOrBan[m_iEntity]            = 0;

        m_bTeleportToVictimOnKill_ATTRIBUTE[m_iEntity]  = false;


        /* On Damage
         * ---------------------------------------------------------------------- */

        m_bActualEnemyHealthToDamage_ATTRIBUTE[m_iEntity]                   = false;
        m_flActualEnemyHealthToDamage_Multiplier[m_iEntity]                 = 0.0;

        m_bActualHealthToDamage_ATTRIBUTE[m_iEntity]                        = false;
        m_flActualHealthToDamage_Multiplier[m_iEntity]                      = 0.0;

        m_bMaximumEnemyHealthToDamage_ATTRIBUTE[m_iEntity]                  = false;
        m_flMaximumEnemyHealthToDamage_Multiplier[m_iEntity]                = 0.0;

        m_bMaximumHealthToDamage_ATTRIBUTE[m_iEntity]                       = false;
        m_flMaximumHealthToDamage_Multiplier[m_iEntity]                     = 0.0;

        m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[m_iEntity]     = false;
        m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[m_iEntity]   = 0.0;

        m_bMissingEnemyHealthToDamage_ATTRIBUTE[m_iEntity]                  = false;
        m_flMissingEnemyHealthToDamage_Multiplier[m_iEntity]                = 0.0;

        m_bMissingHealthToDamage_ATTRIBUTE[m_iEntity]                       = false;
        m_flMissingHealthToDamage_Multiplier[m_iEntity]                     = 0.0;

        m_bDamageDoneIsSelfHurt_ATTRIBUTE[m_iEntity]                        = false;
        m_flDamageDoneIsSelfHurt_Multiplier[m_iEntity]                      = 0.0;

        m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[m_iEntity]           = false;
        m_flDamageIfHealthHigherThanThreshold_BonusDamage[m_iEntity]        = 0.0;
        m_flDamageIfHealthHigherThanThreshold_Threshold[m_iEntity]          = 0.0;

        m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[m_iEntity]            = false;
        m_flDamageIfHealthLowerThanThreshold_BonusDamage[m_iEntity]         = 0.0;
        m_flDamageIfHealthLowerThanThreshold_Threshold[m_iEntity]           = 0.0;

        m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[m_iEntity]      = false;
        m_flDamageIfEnemyHealthHigherThanThreshold_BonusDamage[m_iEntity]   = 0.0;
        m_flDamageIfEnemyHealthHigherThanThreshold_Threshold[m_iEntity]     = 0.0;

        m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[m_iEntity]       = false;
        m_flDamageIfEnemyHealthLowerThanThreshold_BonusDamage[m_iEntity]    = 0.0;
        m_flDamageIfEnemyHealthLowerThanThreshold_Threshold[m_iEntity]      = 0.0;

        m_bBackstabDamageModSubStun_ATTRIBUTE[m_iEntity]                    = false;
        m_flBackstabDamageModSubStun_Multiplier[m_iEntity]                  = 0.0;
        m_flBackstabDamageModSubStun_Duration[m_iEntity]                    = 0.0;
        m_iBackstabDamageModSubStun_Security[m_iEntity]                     = 0;
        m_iBackstabDamageModSubStun_BlockSuicide[m_iEntity]                 = 0;

        m_bCombo_ATTRIBUTE[m_iEntity]                                       = false;
        m_flCombo_BonusDamage[m_iEntity]                                    = 0.0;
        m_iCombo_Hit[m_iEntity]                                             = 0;
        m_iCombo_Crit[m_iEntity]                                            = 0;

        m_bMovementSpeedToDamage_ATTRIBUTE[m_iEntity]                       = false;
        m_flMovementSpeedToDamage_Multiplier[m_iEntity]                     = 0.0;

        m_bMetalToDamage_ATTRIBUTE[m_iEntity]                               = false;
        m_flMetalToDamage_Multiplier[m_iEntity]                             = 0.0;

        m_bDamageWhenMetalRunsOut_ATTRIBUTE[m_iEntity]                      = false;
        m_flDamageWhenMetalRunsOut_Damage[m_iEntity]                        = 0.0;

        m_bMetalOnHitDamage_ATTRIBUTE[m_iEntity]                            = false;
        m_flMetalOnHitDamage_Multiplier[m_iEntity]                          = 0.0;

        m_bBonusDamageVsSapper_ATTRIBUTE[m_iEntity]                         = false;
        m_flBonusDamageVsSapper_Multiplier[m_iEntity]                       = 0.0;

        m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[m_iEntity]                 = false;
        m_flBonusDamageVSVictimInMidAir_Multiplier[m_iEntity]               = 0.0;

        m_bDamageClass_ATTRIBUTE[m_iEntity]                                 = false;
        m_flDamageClass_Scout[m_iEntity]                                    = 0.0;
        m_flDamageClass_Soldier[m_iEntity]                                  = 0.0;
        m_flDamageClass_Pyro[m_iEntity]                                     = 0.0;
        m_flDamageClass_Demoman[m_iEntity]                                  = 0.0;
        m_flDamageClass_Heavy[m_iEntity]                                    = 0.0;
        m_flDamageClass_Engineer[m_iEntity]                                 = 0.0;
        m_flDamageClass_Medic[m_iEntity]                                    = 0.0;
        m_flDamageClass_Sniper[m_iEntity]                                   = 0.0;
        m_flDamageClass_Spy[m_iEntity]                                      = 0.0;

        m_bBonusDamageVsVictimInWater_ATTRIBUTE[m_iEntity]                  = false;
        m_flBonusDamageVSVictimInWater_Multiplier[m_iEntity]                = 0.0;

        m_bAllDamageDoneMultiplier_ATTRIBUTE[m_iEntity]                     = false;
        m_flAllDamageDoneMultiplier_Multiplier[m_iEntity]                   = 0.0;

        m_bRandomDamage_ATTRIBUTE[m_iEntity]                                = false;
        m_flRandomDamage_Min[m_iEntity]                                     = 0.0;
        m_flRandomDamage_Max[m_iEntity]                                     = 0.0;

        m_bLaserWeaponDamageModifier_ATTRIBUTE[m_iEntity]                   = false;
        m_flLaserWeaponDamageModifier_Damage[m_iEntity]                     = 0.0;

        m_bStealDamage_ATTRIBUTE[m_iEntity]                                 = false;
        m_iStealDamage_Steal[m_iEntity]                                     = 0;
        m_flStealDamage_Duration[m_iEntity]                                 = 0.0;


        /* Heal
         * ---------------------------------------------------------------------- */

        m_bHealthLifesteal_ATTRIBUTE[m_iEntity]                     = false;
        m_flHealthLifesteal_Multiplier[m_iEntity]                   = 0.0;
        m_flHealthLifesteal_OverHealBonusCap[m_iEntity]             = 0.0;

        m_bEnemyHealthLifesteal_ATTRIBUTE[m_iEntity]                = false;
        m_flEnemyHealthLifesteal_Multiplier[m_iEntity]              = 0.0;
        m_flEnemyHealthLifesteal_OverHealBonusCap[m_iEntity]        = 0.0;

        m_bMissingEnemyHealthLifesteal_ATTRIBUTE[m_iEntity]         = false;
        m_flMissingEnemyHealthLifesteal_Multiplier[m_iEntity]       = 0.0;
        m_flMissingEnemyHealthLifesteal_OverHealBonusCap[m_iEntity] = 0.0;


        /* On Prethink
         * ---------------------------------------------------------------------- */

        m_bMetalDrain_ATTRIBUTE[m_iEntity]                  = false;
        m_flMetalDrain_Amount[m_iEntity]                    = 0.0;
        m_flMetalDrain_Interval[m_iEntity]                  = 0.0;
        m_iMetalDrain_PoA[m_iEntity]            = 0;

        m_bBerserker_ATTRIBUTE[m_iEntity]                   = false;
        m_flBerserker_Duration[m_iEntity]                   = 0.0;
        m_flBerserker_Threshold[m_iEntity]                  = 0.0;

        m_bLowBerserker_ATTRIBUTE[m_iEntity]                = false;
        m_flLowBerserker_Duration[m_iEntity]                = 0.0;
        m_flLowBerserker_Threshold[m_iEntity]               = 0.0;
        m_iLowBerserker_Kill[m_iEntity]                     = 0;

        m_bHeatFireRate_ATTRIBUTE[m_iEntity]                = false;
        m_flHeatFireRate_AttackSpeed[m_iEntity]             = 0.0;
        m_flHeatFireRate_Delay[m_iEntity]                   = 0.0;
        m_flHeatFireRate_OldAttackSpeed[m_iEntity]          = 0.0;
        m_iHeatFireRate_MaximumStack[m_iEntity]             = 0;

        m_bHeatDMGTaken_ATTRIBUTE[m_iEntity]                = false;
        m_flHeatDMGTaken_DMG[m_iEntity]                     = 0.0;
        m_flHeatDMGTaken_Delay[m_iEntity]                   = 0.0;
        m_iHeatDMGTaken_MaximumStack[m_iEntity]             = 0;

        m_bHomingProjectile_ATTRIBUTE[m_iEntity]            = false;
        m_flHomingProjectile_DetectRadius[m_iEntity]        = 0.0;
        m_iHomingProjectile_Mode[m_iEntity]                 = 0;
        m_iHomingProjectile_Type[m_iEntity]                 = 0;

        m_bDemoCharge_DamageReduction_ATTRIBUTE[m_iEntity]  = false;

        m_bDemoCharge_HealthThreshold_ATTRIBUTE[m_iEntity]  = false;
        m_flDemoCharge_HealthThreshold_Threshold[m_iEntity] = 0.0;
        m_iDemoCharge_HealthThreshold_Mode[m_iEntity]       = 0;

        m_bFragmentation_ATTRIBUTE[m_iEntity]               = false;
        m_flFragmentation_Damage[m_iEntity]                 = 0.0;
        m_flFragmentation_Radius[m_iEntity]                 = 0.0;
        m_iFragmentation_Mode[m_iEntity]                    = 0;
        m_iFragmentation_Amount[m_iEntity]                  = 0;

        m_bDamageResistanceInvisible_ATTRIBUTE[m_iEntity]   = false;
        m_flDamageResistanceInvisible_Multiplier[m_iEntity] = 0.0;

        m_bSpyDetector_ATTRIBUTE[m_iEntity]                 = false;
        m_flSpyDetector_Radius[m_iEntity]                   = 0.0;
        m_iSpyDetector_Type[m_iEntity]                      = 0;
        m_iSpyDetector_ActivePassive[m_iEntity]             = 0;

        m_bBuffStuff_ATTRIBUTE[m_iEntity]                   = false;
        m_iBuffStuff_ID[m_iEntity]                          = 0;
        m_iBuffStuff_ID2[m_iEntity]                         = 0;
        m_iBuffStuff_ID3[m_iEntity]                         = 0;
        m_iBuffStuff_ID4[m_iEntity]                         = 0;
        m_flBuffStuff_Radius[m_iEntity]                     = 0.0;
        m_iBuffStuff_Mode[m_iEntity]                        = 0;

        m_bCannotBeStunned_ATTRIBUTE[m_iEntity]             = false;
        m_iCannotBeStunned_Type[m_iEntity]                  = 0;

        m_bDisableUbercharge_ATTRIBUTE[m_iEntity]           = false;

        m_bSetWeaponSwitch_ATTRIBUTE[m_iEntity]             = false;
        m_iSetWeaponSwith_Slot[m_iEntity]                   = 0;

        m_bBulletsPerShotBonusDynamic_ATTRIBUTE[m_iEntity]  = false;


        /* On Chance
         * ---------------------------------------------------------------------- */

        m_bChanceOneShot_ATTRIBUTE[m_iEntity]   = false;
        m_flChanceOneShot_Chance[m_iEntity]     = 0.0;

        m_bChanceIgnite_ATTRIBUTE[m_iEntity]    = false;
        m_flChanceIgnite_Chance[m_iEntity]      = 0.0;
        m_flChanceIgnite_Duration[m_iEntity]    = 0.0;

        m_bChanceMadMilk_ATTRIBUTE[m_iEntity]   = false;
        m_flChanceMadMilk_Chance[m_iEntity]     = 0.0;
        m_flChanceMadMilk_Duration[m_iEntity]   = 0.0;

        m_bChanceJarate_ATTRIBUTE[m_iEntity]    = false;
        m_flChanceJarate_Chance[m_iEntity]      = 0.0;
        m_flChanceJarate_Duration[m_iEntity]    = 0.0;

        m_bChanceBleed_ATTRIBUTE[m_iEntity]     = false;
        m_flChanceBleed_Chance[m_iEntity]       = 0.0;
        m_flChanceBleed_Duration[m_iEntity]     = 0.0;


        /* On Damage Received
         * ---------------------------------------------------------------------- */

        m_bDamageReceivedUnleashedDeath_ATTRIBUTE[m_iEntity]        = false;
        m_flDamageReceivedUnleashedDeath_Percentage[m_iEntity]      = 0.0;
        m_flDamageReceivedUnleashedDeath_Radius[m_iEntity]          = 0.0;
        m_iDamageReceivedUnleashedDeath_PoA[m_iEntity]  = 0;
        m_iDamageReceivedUnleashedDeath_Backstab[m_iEntity]         = 0;

        m_bReduceBackstabDamage_ATTRIBUTE[m_iEntity]                = false;
        m_flReduceBackstabDamage_Percentage[m_iEntity]              = 0.0;
        m_iReduceBackstabDamage_ActOrMax[m_iEntity]                 = 0;

        m_bReduceHeadshotDamage_ATTRIBUTE[m_iEntity]                = false;
        m_flReduceHeadshotDamage_Percentage[m_iEntity]              = 0.0;

        m_bDamageResHealthMissing_ATTRIBUTE[m_iEntity]              = false;
        m_flDamageResHealthMissing_ResPctPerMissingHpPct[m_iEntity] = 0.0;
        m_iDamageResHealthMissing_MaxStackOfMissingHpPct[m_iEntity] = 0;
        m_iDamageResHealthMissing_OverhealPenalty[m_iEntity]        = 0;


        /* To Activate
         * ---------------------------------------------------------------------- */

        m_bPsycho_ATTRIBUTE[m_iEntity]          = false;
        m_flPsycho_Duration[m_iEntity]          = 0.0;
        m_flPsycho_DamageResistance[m_iEntity]  = 0.0;
        m_flPsycho_DamageBonus[m_iEntity]       = 0.0;
        m_flPsycho_RegenPct[m_iEntity]          = 0.0;
        m_iPsycho_Melee[m_iEntity]              = 0;
    }



    if ( IsValidEdict( m_iEntity ) ) // Thanks Pelipoika
    {
        new String:m_sClassName[32];
        GetEdictClassname( m_iEntity, m_sClassName, sizeof( m_sClassName ) );
        if ( StrEqual( m_sClassName, "tf_projectile_pipe_remote" ) )
        {
            new m_iEnt = EntRefToEntIndex( m_iEntity );
            decl String:m_sClass[32]; 

            if ( m_iEnt > 0 && m_iEnt > MaxClients && IsValidEntity( m_iEnt ) && GetEntityClassname( m_iEnt, m_sClass, sizeof( m_sClass ) ) )
            {
                if ( StrEqual( m_sClass, "tf_projectile_pipe_remote" ) && GetEntProp( m_iEnt, Prop_Send, "m_iType" ) != 2 )
                {
                    new m_iOwner = GetEntPropEnt( m_iEnt, Prop_Send, "m_hThrower" );

                    if ( IsValidClient( m_iOwner ) && TF2_GetPlayerClass( m_iOwner ) == TFClass_DemoMan )
                    {    
                        if ( HasAttribute( m_iOwner, _, m_bFragmentation_ATTRIBUTE ) )
                        {
                            new amount = GetAttributeValueI( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_iFragmentation_Amount );
                            new mode = GetAttributeValueI( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_iFragmentation_Mode );
                            new Float:dmg = GetAttributeValueF( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_flFragmentation_Damage );
                            new Float:radius = GetAttributeValueF( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_flFragmentation_Radius );

                            new bool:IsCrit = false;
                            if ( GetEntProp( m_iEnt, Prop_Send, "m_bCritical" ) ) IsCrit = true;
                            if ( GetEntProp( m_iEnt, Prop_Send, "m_bTouched" ) && mode == 1 ) {
                                SpawnBombz( m_iOwner, EntIndexToEntRef( m_iEnt ), IsCrit, amount, dmg, radius );
                            }
                            else if ( mode == 0 ) {
                                SpawnBombz( m_iOwner, EntIndexToEntRef( m_iEnt ), IsCrit, amount, dmg, radius );
                            }
                        }
                    }
                }
            }
        }
        if ( StrEqual( m_sClassName, "tf_projectile_rocket" ) )
        {
            new m_iEnt = EntRefToEntIndex( m_iEntity );
            decl String:m_sClass[32]; 

            if ( m_iEnt > 0 && m_iEnt > MaxClients && IsValidEntity( m_iEnt ) && GetEntityClassname( m_iEnt, m_sClass, sizeof( m_sClass ) ) )
            {
                if ( StrEqual( m_sClass, "tf_projectile_rocket" ) )
                {
                    new m_iOwner = GetEntPropEnt( m_iEnt, Prop_Send, "m_hOwnerEntity" );

                    if ( IsValidClient( m_iOwner ) && TF2_GetPlayerClass( m_iOwner ) == TFClass_Soldier )
                    {   
                        if ( HasAttribute( m_iOwner, _, m_bFragmentation_ATTRIBUTE ) )
                        {
                            new bool:IsCrit = false;
                            if ( GetEntProp( m_iEnt, Prop_Send, "m_bCritical" ) ) IsCrit = true;
                            if ( GetAttributeValueI( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_iFragmentation_Mode ) == 2 )
                                SpawnBombz( m_iOwner, EntIndexToEntRef( m_iEnt ), IsCrit, GetAttributeValueI( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_iFragmentation_Amount ), GetAttributeValueF( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_flFragmentation_Damage ), GetAttributeValueF( m_iOwner, _, m_bFragmentation_ATTRIBUTE, m_flFragmentation_Radius ) );
                        }
                    }
                }
            }
        }
    }
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
public Action:m_tDrainMetal_TimerInterval( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bMetalDrain_ATTRIBUTE ) )
    {
        new Float:metal  = GetAttributeValueF( m_iClient, _, m_bMetalDrain_ATTRIBUTE, m_flMetalDrain_Amount );
        new metal_p      = TF2_GetClientMetal( m_iClient );
        new metal_n     = RoundToFloor( metal_p + ( metal < 1.0 ? metal_p * metal : metal ) );

        if ( GetAttributeValueI( m_iClient, _, m_bMetalDrain_ATTRIBUTE, m_iMetalDrain_PoA ) == 1 && !HasAttribute( m_iClient, _, m_bMetalDrain_ATTRIBUTE, true ) )
        {
            m_hTimers[m_iClient][m_hDrainMetal_TimerDelay] = INVALID_HANDLE;
            return Plugin_Stop;
        }
        if ( TF2_GetPlayerClass( m_iClient ) == TFClass_Engineer )
            TF2_SetClientMetal( m_iClient, metal_n );
    }

    m_hTimers[m_iClient][m_hDrainMetal_TimerDelay] = INVALID_HANDLE;
    return Plugin_Stop;
}
public Action:m_tHotSauce_TimerDuration( Handle:timer, any:m_hData01 )
{
    ResetPack( m_hData01 );

    new m_iVictim, m_iAttacker, Float:duration, type;
    duration = ReadPackFloat( m_hData01 );
    m_iVictim = ReadPackCell( m_hData01 );
    m_iAttacker = ReadPackCell( m_hData01 );
    type = ReadPackCell( m_hData01 );

    if ( IsValidClient( m_iAttacker ) && IsValidClient( m_iVictim ) ) {
        if ( HasAttribute( m_iAttacker, _, m_bHotSauceOnHit_ATTRIBUTE ) || HasAttribute( m_iAttacker, _, m_bHotSauceOnCrit_ATTRIBUTE ) )
        {
            if ( type == 1 || type == 4 || type == 5 || type == 7 ) TF2_AddCondition( m_iVictim, TFCond_Milked, duration, m_iAttacker );
            if ( type == 2 || type == 4 || type == 6 || type == 7 ) TF2_AddCondition( m_iVictim, TFCond_Jarated, duration, m_iAttacker );
            if ( type == 3 || type == 5 || type == 6 || type == 7 ) TF2_MakeBleed( m_iVictim, m_iAttacker, duration );
        }
    }
}
public Action:m_tSpawnSkeletonOnKill_TimerDuration( Handle:timer, any:m_iEnt )
{
    if ( IsValidEntity( m_iEnt ) ) AcceptEntityInput( m_iEnt, "Kill" );
}
public Action:m_tBerserker_TimerDuration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bBerserker_ATTRIBUTE ) )
    {
        TF2_RemoveCondition( m_iClient, TFCond_Ubercharged );
        DealDamage( m_iClient, 1000000000, m_iClient, TF_DMG_CRIT|TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
    }

    m_hTimers[m_iClient][m_hBerserker_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tLowBerserker_TimerDuration( Handle:timer, any:m_iClient )
{
    if ( HasAttribute( m_iClient, _, m_bLowBerserker_ATTRIBUTE ) && GetAttributeValueI( m_iClient, _, m_bLowBerserker_ATTRIBUTE, m_iLowBerserker_Kill ) > 0 )
    {
        TF2_RemoveCondition( m_iClient, TFCond_Ubercharged );
        DealDamage( m_iClient, 1000000000, m_iClient, TF_DMG_CRIT|TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
    }

    m_hTimers[m_iClient][m_hLowBerserker_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tPsycho_TimerDuration( Handle:timer, any:m_iClient )
{
    m_hTimers[m_iClient][m_hPsycho_TimerDuration] = INVALID_HANDLE;
    m_flFloats[m_iClient][m_flPsychoRegenCharge] = 0.0;//You never know.™
}
public Action:m_tDamageReceivedUnleashedDeath_TimerDelay( Handle:timer, any:m_iVictim )
{
    if ( HasAttribute( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
    {
        new Float:radius = GetAttributeValueF( m_iVictim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_flDamageReceivedUnleashedDeath_Radius );
        AttachParticle( m_iVictim, "mvm_soldier_shockwave", 1.5 );

        new Float:m_flPos1[3];
        GetClientEyePosition( m_iVictim, m_flPos1 );

        for ( new i = 1 ; i <= MaxClients ; i++ )
        {
            if ( i != m_iVictim && IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( m_iVictim ) )
            {
                if ( !HasInvulnerabilityCond( i ) )
                {
                    new Float:m_flPos2[3];
                    GetClientEyePosition( i, m_flPos2 );

                    new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
                    new Float:final_radius = radius + ( m_flFloats[m_iVictim][m_flDamageReceived] * 0.2 );
                    if ( distance < final_radius )
                    {
                        decl Handle:m_hSee;
                        ( m_hSee = INVALID_HANDLE );

                        m_hSee = TR_TraceRayFilterEx( m_flPos1, m_flPos2, MASK_SOLID, RayType_EndPoint, TraceFilterPlayer, m_iVictim );
                        if ( m_hSee != INVALID_HANDLE )
                        {
                            if ( !TR_DidHit( m_hSee ) )
                            {
                                // Limit the minimum damage to 50%
                                // Begin the reduction at 73.0 HU.
                                new Float:dmg_reduction = 1.0;
                                if ( distance > 73.0 )
                                    dmg_reduction = ( m_flFloats[m_iVictim][m_flDamageReceived] * ( final_radius - ( ( distance - 73.0 ) * 0.5 ) ) / final_radius ) / m_flFloats[m_iVictim][m_flDamageReceived];

                                DealDamage( i, RoundToFloor( m_flFloats[m_iVictim][m_flDamageReceived] * dmg_reduction ), m_iVictim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL, "pumpkindeath" );
                            }
                        }

                        CloseHandle( m_hSee );
                    }
                }
            }
        }
        m_flFloats[m_iVictim][m_flDamageReceived] = 0.0;
    }
}
public Action:m_tHeatAttackSpeed_TimerDelay( Handle:timer, any:m_hData01 )
{
    ResetPack( m_hData01 );

    new m_iWeapon, m_iClient;
    new Float:m_flAttackSpeed;
    m_iWeapon = ReadPackCell( m_hData01 );
    m_iClient = ReadPackCell( m_hData01 );
    m_flAttackSpeed = ReadPackFloat( m_hData01 );

    if ( m_iWeapon != -1 && IsValidEdict( m_iWeapon ) && IsValidClient( m_iClient ) ) {
        if ( HasAttribute( m_iClient, _, m_bHeatFireRate_ATTRIBUTE ) )
        {
            if ( m_iIntegers[m_iClient][m_iHeat] >= GetAttributeValueI( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack ) ) {
                m_iIntegers[m_iClient][m_iHeat] = GetAttributeValueI( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack );
            } else {
                m_iIntegers[m_iClient][m_iHeat]++;
                TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", m_flAttackSpeed - GetAttributeValueF( m_iClient, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_AttackSpeed ) );
            }
        }
    }
    m_bBools[m_iClient][m_bIsHeat] = false;
}
public Action:m_tHeatDMGTaken_TimerDelay( Handle:timer, any:m_iClient )
{
    if ( IsValidClient( m_iClient ) ) {
        if ( HasAttribute( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE ) )
        {
            new max = GetAttributeValueI( m_iClient, _, m_bHeatDMGTaken_ATTRIBUTE, m_iHeatDMGTaken_MaximumStack );
            if ( m_iIntegers[m_iClient][m_iHeatToo] >= max ) {
                m_iIntegers[m_iClient][m_iHeatToo] = max;
            }
            else m_iIntegers[m_iClient][m_iHeatToo]++;
        }
        m_bBools[m_iClient][m_bIsHeatToo] = false;
    }
}
public Action:m_tMarkVictimDamage_TimerDuration( Handle:timer, any:m_hData01 )
{
    ResetPack( m_hData01 );

    new m_iVictim, m_iAttacker;
    m_iVictim = ReadPackCell( m_hData01 );
    m_iAttacker = ReadPackCell( m_hData01 );

    if ( IsValidClient( m_iVictim ) && IsValidClient( m_iAttacker ) )
    {
        m_iIntegers[m_iAttacker][m_iMarkVictimDamage]--;
        m_iIntegers[m_iVictim][m_iMarkVictimDamageCount] = 0;
        g_pMarker[m_iVictim] = -1;

        m_hTimers[m_iVictim][m_hMarkVictimDamage_TimerDuration] = INVALID_HANDLE;
    }

}
public Action:m_tMCFRTD_Timer( Handle:timer, Handle:m_hData03 )
{
    ResetPack( m_hData03 );

    new m_iClient, m_iWeapon;
    m_iClient = ReadPackCell( m_hData03 );
    m_iWeapon = ReadPackCell( m_hData03 );
    
    if ( HasAttribute( m_iClient, _, m_bMCFRTD_ATTRIBUTE ) )
    {
        if ( m_iWeapon != -1 && IsValidEdict( m_iWeapon ) && IsValidClient( m_iClient ) )
        {
            m_bBools[m_iClient][m_bLastWasMiss] = true;

            if ( !( TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", m_flMCFRTD_OldAttackSpeed[m_iWeapon] );
            new Address:m_aAttribute = TF2Attrib_GetByName( m_iWeapon, "fire rate bonus" );
            new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

            TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", m_flAttackSpeed + GetAttributeValueF( m_iClient, _, m_bMCFRTD_ATTRIBUTE, m_flMCFRTD_AttackSpeed ) );
            m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

            if ( m_flAttackSpeed <= 0.0 ) TF2Attrib_SetByName( m_iWeapon, "fire rate bonus", 0.0 );
            
            m_iIntegers[m_iClient][m_iMissStack]++;
        }
    }

    m_hTimers[m_iClient][m_hMCFRTD_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tInfiniteAfterburn_TimerDuration( Handle:timer, any:m_iVictim )
{
    TF2_RemoveCondition( m_iVictim, TFCond_OnFire );
    m_bBools[m_iVictim][m_bInfiniteAfterburnRessuply] = false;
    g_pBurner[m_iVictim] = -1;

    m_hTimers[m_iVictim][m_hInfiniteAfterburn_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tStealDamageAttacker( Handle:timer, any:m_iAttacker )
{
    m_iIntegers[m_iAttacker][m_iStealDamageAttacker] = 0;
    m_hTimers[m_iAttacker][m_hStealDamageA_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tStealDamageVictim( Handle:timer, any:m_iVictim )
{
    m_iIntegers[m_iVictim][m_iStealDamageVictim] = 0;
    m_hTimers[m_iVictim][m_hStealDamageV_TimerDuration] = INVALID_HANDLE;
}
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
bool:HasAttribute( client, slot = -1, const attribute[] = m_bHasAttribute, bool:active = false )
{
    if ( !IsValidClient( client ) ) return false;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            new weapon = GetPlayerWeaponSlot( client, i );
            if ( weapon != -1 ) {
                if ( m_bHasAttribute[weapon] ) {
                    if ( attribute[weapon] ) {
                        if ( slot == -1 || slot == i ) return true;
        }}}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return false;

        new weapon = TF2_GetClientActiveWeapon( client );
        if ( weapon != -1 ) {
            if ( m_bHasAttribute[weapon] ) {
                if ( attribute[weapon] ) return true;
        }}
    }
    
    return false;
}
Float:GetAttributeValueF( client, slot = -1, const bool:baseAttribute[], const Float:attribute[], bool:active = false )
{
    if ( !IsValidClient( client ) ) return 0.0;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            new weapon = GetPlayerWeaponSlot( client, i );
            if ( weapon != -1 ) {
                if ( m_bHasAttribute[weapon] ) {
                    if ( baseAttribute[weapon] ) {
                        if ( slot == -1 || slot == i ) return attribute[weapon];
        }}}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return 0.0;

        new weapon = TF2_GetClientActiveWeapon( client );
        if ( weapon != -1 ) {
            if ( m_bHasAttribute[weapon] ) {
                if ( baseAttribute[weapon] ) return attribute[weapon];
        }}
    }
    
    return 0.0;
}
GetAttributeValueI( client, slot = -1, const bool:baseAttribute[], const attribute[], bool:active = false )
{
    if ( !IsValidClient( client ) ) return 0;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            new weapon = GetPlayerWeaponSlot( client, i );
            if ( weapon != -1 ) {
                if ( m_bHasAttribute[weapon] ) {
                    if ( baseAttribute[weapon] ) {
                        if ( slot == -1 || slot == i ) return attribute[weapon];
        }}}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return 0;

        new weapon = TF2_GetClientActiveWeapon( client );
        if ( weapon != -1 ) {
            if ( m_bHasAttribute[weapon] ) {
                if ( baseAttribute[weapon] ) return attribute[weapon];
        }}
    }
    
    return 0;
}
