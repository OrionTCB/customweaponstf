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
#include <customweaponstf_orionstock>
#include <time>

// ====[ CONSTANTS ]===================================================
#define PLUGIN_VERSION	"1.04"

// ====[ PLUGIN ]======================================================
public Plugin:myinfo =
{
	name		= "Custom Weapons: Orion's Attributes",
	author		= "Orion",
	description	= "Custom Weapons: Orion's Attributes.",
	version		= PLUGIN_VERSION,
	url		= "https://forums.alliedmods.net/showpost.php?p=2193855&postcount=254"
};

// ====[ VARIABLES ]===================================================
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
	Handle:m_hStunlock_TimerDelay,
	Handle:m_hHeatFireRate_TimerDelay,
	Handle:m_hHeatDamage_TimerDelay,
	Handle:m_hDamageChargeThing_Enabled,
	Handle:m_hTimer
};
new Handle:m_hTimers[MAXPLAYERS + 1][m_hTimer];
enum
{
	m_bBackstab_SuicideBlocker = 0,
	m_bStealPct,
	m_bBuff_Deployed,
	m_bInfiniteAfterburn_Ressuply,
	m_bDamageChargeThing_Enable,
	m_bLastWasMiss,
	m_bBool
};
new bool:m_bBools[MAXPLAYERS + 1][m_bBool];
enum
{
	m_flPsychoRegenCharge = 0,
	m_flStealDamageAttacker,
	m_flStealDamageVictim,
	m_flPyschoCharge,
	damageCharge,
	damageReceived,
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
	m_iAttackSpeed,
	m_iInteger
};
new m_iIntegers[MAXPLAYERS + 1][m_iInteger];

new bool:g_hPostInventory[MAXPLAYERS + 1]= false;
new g_iLastButtons[MAXPLAYERS + 1]		= -1;
new g_iLastWeapon[MAXPLAYERS + 1]		= -1;
new g_pBurner[MAXPLAYERS + 1]			= -1;
new g_pMarker[MAXPLAYERS + 1]			= -1;
new Handle:g_hHudText_O;


	/* On Hit
	 * ---------------------------------------------------------------------- */

new bool:m_bHotSauceOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHotSauceOnHit_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHotSauceOnHit_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bStunOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStunOnHit_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iStunOnHit_StunLock[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDrainUbercharge_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDrainUbercharge_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMetalOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMetalOnHit_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bUberchargeOnHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flUberchargeOnHit_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bRemoveBleeding_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bAfterburnCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAfterburnCLOSERANGE_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAfterburnCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBleedCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBleedCLOSERANGE_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBleedCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMarkVictimDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMarkVictimDamage_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMarkVictimDamage_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMarkVictimDamage_MaximumDamageStack[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMarkVictimDamage_MaximumVictim[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bInfiniteAfterburn_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flInfiniteAfterburn_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iInfiniteAfterburn_Ressuply[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Crit
	 * ---------------------------------------------------------------------- */

new bool:m_bHotSauceOnCrit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHotSauceOnCrit_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHotSauceOnCrit_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bStunOnCrit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStunOnCrit_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iStunOnCrit_StunLock[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDrainUberchargeOnCrit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDrainUberchargeOnCrit_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritVsInvisiblePlayer_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritVictimInMidAir_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritVictimScared_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMinicritVsBurningCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritVsBurningCLOSERANGE_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCritVsBurningCLOSERANGE_Range[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCritVictimInWater_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Attack
	 * ---------------------------------------------------------------------- */

new bool:m_bDamageSelf_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageSelf_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMetalPerShot_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMetalPerShot_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMCFRTD_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMCFRTD_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMCFRTD_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMCFRTD_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Kill
	 * ---------------------------------------------------------------------- */

new bool:m_bKillGib_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bSpawnSkeletonOnKill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSpawnSkeletonOnKill_BossChance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSpawnSkeletonOnKill_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iSpawnSkeletonOnKill_Boss[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bAttackSpeedOnKill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAttackSpeedOnKill_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAttackSpeedOnKill_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAttackSpeedOnKill_Removal[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iAttackSpeedOnKill_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBANOnKillHit_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBANOnKillHit_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBANOnKillHit_HitOrKill[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBANOnKillHit_KickOrBan[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bTeleportToVictimOnKill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bScareOnKill_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flScareOnKill_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flScareOnKill_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iScareOnKill_StunLock[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Damage
	 * ---------------------------------------------------------------------- */

new bool:m_bActualEnemyHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flActualEnemyHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bActualHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flActualHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMaximumEnemyHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMaximumEnemyHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMaximumHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMaximumHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMissingEnemyHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissingEnemyHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMissingHealthToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissingHealthToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageDoneIsSelfHurt_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageDoneIsSelfHurt_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfHealthHigherThanThreshold_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfHealthHigherThanThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfHealthLowerThanThreshold_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfHealthLowerThanThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfEnemyHealthHigherThanThreshold_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfEnemyHealthHigherThanThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfEnemyHealthLowerThanThreshold_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageIfEnemyHealthLowerThanThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBackstabDamageModSubStun_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBackstabDamageModSubStun_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBackstabDamageModSubStun_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBackstabDamageModSubStun_BlockSuicide[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBackstabDamageModSubStun_Security[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBackstabDamageModSubStun_StunLock[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCombo_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flCombo_BonusDamage[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iCombo_Crit[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iCombo_Hit[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMovementSpeedToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMovementSpeedToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMetalToDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMetalToDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageWhenMetalRunsOut_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageWhenMetalRunsOut_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMetalOnHitDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMetalOnHitDamage_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBonusDamageVsSapper_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonusDamageVsSapper_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonusDamageVSVictimInMidAir_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageClass_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Demoman[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Engineer[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Heavy[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Medic[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Pyro[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Scout[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Sniper[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Soldier[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageClass_Spy[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBonusDamageVsVictimInWater_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBonusDamageVSVictimInWater_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bAllDamageDoneMultiplier_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flAllDamageDoneMultiplier_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bRandomDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRandomDamage_Max[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flRandomDamage_Min[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bLaserWeaponDamageModifier_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLaserWeaponDamageModifier_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bStealDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStealDamage_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flStealDamage_Steal[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iStealDamage_Pct[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageChargeThing_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageChargeThing_Charge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageChargeThing_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageChargeThing_DeCharge[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageChargeThing_DamageSelf[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* Heal
	 * ---------------------------------------------------------------------- */

new bool:m_bHealthLifesteal_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHealthLifesteal_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHealthLifesteal_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bEnemyHealthLifesteal_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnemyHealthLifesteal_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flEnemyHealthLifesteal_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bMissingEnemyHealthLifesteal_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissingEnemyHealthLifesteal_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMissingEnemyHealthLifesteal_OverHealBonusCap[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Prethink
	 * ---------------------------------------------------------------------- */

new bool:m_bMetalDrain_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMetalDrain_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flMetalDrain_Interval[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iMetalDrain_PoA[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBerserker_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBerserker_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBerserker_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bLowBerserker_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLowBerserker_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flLowBerserker_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iLowBerserker_Kill[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bHeatFireRate_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHeatFireRate_AttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHeatFireRate_Delay[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHeatFireRate_OldAttackSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHeatFireRate_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bHeatDMGTaken_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHeatDMGTaken_Delay[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHeatDMGTaken_DMG[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHeatDMGTaken_MaximumStack[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bHomingProjectile_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flHomingProjectile_DetectRadius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHomingProjectile_Mode[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iHomingProjectile_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDemoCharge_DamageReduction_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDemoCharge_HealthThreshold_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flDemoCharge_HealthThreshold_Threshold[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDemoCharge_HealthThreshold_Mode[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bFragmentation_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFragmentation_Damage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flFragmentation_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iFragmentation_Amount[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iFragmentation_Mode[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageResistanceInvisible_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageResistanceInvisible_Multiplier[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bSpyDetector_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flSpyDetector_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iSpyDetector_ActivePassive[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iSpyDetector_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBuffStuff_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flBuffStuff_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBuffStuff_ID2[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBuffStuff_ID3[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBuffStuff_ID4[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBuffStuff_ID[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iBuffStuff_Mode[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bCannotBeStunned_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iCannotBeStunned_Type[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDisableUbercharge_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bSetWeaponSwitch_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iSetWeaponSwith_Slot[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bBulletsPerShotBonusDynamic_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Chance
	 * ---------------------------------------------------------------------- */

new bool:m_bChanceOneShot_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceOneShot_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bChanceIgnite_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceIgnite_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceIgnite_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bChanceMadMilk_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceMadMilk_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceMadMilk_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bChanceJarate_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceJarate_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceJarate_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bChanceBleed_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceBleed_Chance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flChanceBleed_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iChanceBleed_Stack[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* On Damage Received
	 * ---------------------------------------------------------------------- */

new bool:m_bDamageReceivedUnleashedDeath_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageReceivedUnleashedDeath_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageReceivedUnleashedDeath_Radius[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageReceivedUnleashedDeath_Backstab[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageReceivedUnleashedDeath_PoA[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bReduceBackstabDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flReduceBackstabDamage_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iReduceBackstabDamage_ActOrMax[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bReduceHeadshotDamage_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flReduceHeadshotDamage_Percentage[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:m_bDamageResHealthMissing_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:damageResHealthMissing_ResPctPerMissingHpPct[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageResHealthMissing_MaxStackOfMissingHpPct[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageResHealthMissing_OverhealPenalty[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iDamageResHealthMissing_Active[MAXPLAYERS + 1][MAXSLOTS + 1];


	/* To Activate
	 * ---------------------------------------------------------------------- */

new bool:m_bPsycho_ATTRIBUTE[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPsycho_DamageBonus[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPsycho_DamageResistance[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPsycho_Duration[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:m_flPsycho_RegenPct[MAXPLAYERS + 1][MAXSLOTS + 1];
new m_iPsycho_Melee[MAXPLAYERS + 1][MAXSLOTS + 1];


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

	HookEvent( "deploy_buff_banner",		 Event_BuffDeployed );
	HookEvent( "player_builtobject",		 Event_BuiltObject );
	HookEvent( "player_changeclass",		 Event_ChangeClass );
	HookEvent( "post_inventory_application", Event_PostInventoryApplication );

	HookEvent( "player_death",		Event_Death,		EventHookMode_Pre );
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
public OnClientPutInServer( client )
{
	SDKHook( client, SDKHook_OnTakeDamage,		OnTakeDamage );
	SDKHook( client, SDKHook_OnTakeDamageAlive,	OnTakeDamageAlive );
	SDKHook( client, SDKHook_PreThink,			OnClientPreThink );
}

// ====[ ON PLUGIN END ]===============================================
public OnPluginEnd()
{
	for ( new i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ) )
		{
			for ( new e = 0; e < m_hTimer; e++ )	ClearTimer( m_hTimers[i][e] );
			for ( new e = 0; e < m_bBool; e++ )	m_bBools[i][e]		= false;
			for ( new e = 0; e < m_flFloat; e++ )	m_flFloats[i][e]		= 0.0;
			for ( new e = 0; e < m_iInteger; e++ )	m_iIntegers[i][e]	= 0;
			for ( new e = 0; e <= 4; e++ )		CW3_OnWeaponRemoved( e, i );

			g_pBurner[i]		= -1;
			g_iLastWeapon[i]	= -1;
			g_pMarker[i]		= -1;
		}
	}
}

// ====[ ON CLIENT DISCONNECT ]========================================
public OnClientDisconnect( client )
{
	for ( new i = 0; i < m_hTimer; i++ )	ClearTimer( m_hTimers[client][i] );
	for ( new i = 0; i < m_bBool; i++ )	m_bBools[client][i]	= false;
	for ( new i = 0; i < m_flFloat; i++ )	m_flFloats[client][i]	= 0.0;
	for ( new i = 0; i < m_iInteger; i++ )	m_iIntegers[client][i]	= 0;
	for ( new i = 0; i <= 4; i++ )		CW3_OnWeaponRemoved( i, client );

	g_pBurner[client]	= -1;
	g_iLastWeapon[client]	= -1;
	g_pMarker[client]	= -1;
}

// ====[ EVENT: ON ROUND RESTART ]=====================================
public Event_OnRoundRestart( Handle:event, const String:name[], bool:broadcast )
{
	for ( new i = 1; i <= MaxClients; i++ )
	{
		if ( IsClientInGame( i ) )
		{
			for ( new e = 0; e < m_hTimer; e++ )	ClearTimer( m_hTimers[i][e] );
			for ( new e = 0; e < m_bBool; e++ )	m_bBools[i][e]		= false;
			for ( new e = 0; e < m_flFloat; e++ )	m_flFloats[i][e]		= 0.0;
			for ( new e = 0; e < m_iInteger; e++ )	m_iIntegers[i][e]	= 0;
			for ( new e = 0; e <= 4; e++ )		CW3_OnWeaponRemoved( e, i );

			g_pBurner[i]		= -1;
			g_iLastWeapon[i]	= -1;
			g_pMarker[i]		= -1;
		}
	}
}

// ====[ EVENT: CHANGE CLASS ]=========================================
public Event_ChangeClass( Handle:event, const String:name[], bool:broadcast )
{
	new client = GetClientOfUserId( GetEventInt( event, "userid" ) );
	
	if ( IsValidClient( client ) && IsPlayerAlive( client ) )
	{
		for ( new i = 0; i < m_hTimer; i++ )	ClearTimer( m_hTimers[client][i] );
		for ( new i = 0; i < m_bBool; i++ )	m_bBools[client][i]	= false;
		for ( new i = 0; i < m_flFloat; i++ )	m_flFloats[client][i]	= 0.0;
		for ( new i = 0; i < m_iInteger; i++ )	m_iIntegers[client][i]	= 0;
		for ( new i = 0; i <= 4; i++ )		CW3_OnWeaponRemoved( i, client );

		g_pBurner[client]	= -1;
		g_iLastWeapon[client]	= -1;
		g_pMarker[client]	= -1;
	}

	return;
}

// ====[ COMMAND ]=====================================================
public Action:m_cmdBackstab_SuicideBlocker( client, const String:command[], args )
{
	if ( !IsPlayerAlive( client ) || !IsValidClient( client ) ) return Plugin_Continue;

	if ( m_bBools[client][m_bBackstab_SuicideBlocker] ) return Plugin_Handled;
	else return Plugin_Continue;
}

// ====[ EVENT: POST INVENTORY APPLICATION ]===========================
public Event_PostInventoryApplication( Handle:event, const String:name[], bool:broadcast )
{
	new client = GetClientOfUserId( GetEventInt( event, "userid" ) );
	
	if ( IsValidClient( client ) && IsPlayerAlive( client ) )
	{
		if ( m_hTimers[client][m_hBerserker_TimerDuration] != INVALID_HANDLE )
		{
			ClearTimer( m_hTimers[client][m_hBerserker_TimerDuration] );
			TF2_RemoveCondition( client, TFCond_CritOnFirstBlood );
			TF2_RemoveCondition( client, TFCond_SpeedBuffAlly );
			TF2_RemoveCondition( client, TFCond_Ubercharged );
		}
		if ( m_hTimers[client][m_hLowBerserker_TimerDuration] != INVALID_HANDLE )
		{
			ClearTimer( m_hTimers[client][m_hLowBerserker_TimerDuration] );
			TF2_RemoveCondition( client, TFCond_Buffed );
			TF2_RemoveCondition( client, TFCond_DefenseBuffed );
			TF2_RemoveCondition( client, TFCond_RegenBuffed );
			TF2_RemoveCondition( client, TFCond_SpeedBuffAlly );
		}
		if ( m_hTimers[client][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE && m_bBools[client][m_bInfiniteAfterburn_Ressuply] )
		{
			ClearTimer( m_hTimers[client][m_hInfiniteAfterburn_TimerDuration] );
			m_bBools[client][m_bInfiniteAfterburn_Ressuply] = false;
			g_pBurner[client] = -1;
		}
		if ( m_hTimers[client][m_hHeatFireRate_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[client][m_hHeatFireRate_TimerDelay] );
		if ( m_hTimers[client][m_hHeatDamage_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[client][m_hHeatDamage_TimerDelay] );

		m_bBools[client][m_bLastWasMiss]		 = false;
		m_iIntegers[client][m_iHeat]			 = 0;
		m_iIntegers[client][m_iHeatToo]		= 0;
		m_iIntegers[client][m_iHotSauceType]	 = 0;
		m_iIntegers[client][m_iMissStack]		= 0;

		if ( !g_hPostInventory[client] ) {
			CreateTimer( 0.02, m_tPostInventory, client );
			g_hPostInventory[client] = true;
		}
	}

	return;
}

// ====[ EVENT: BUILT OBJECT ]=========================================
public Event_BuiltObject( Handle:event, const String:name[], bool:broadcast )
{
	new m_iSapper = GetEventInt( event, "index" );

	SDKHook( m_iSapper, SDKHook_OnTakeDamage, OnTakeDamage );
}

// ====[ EVENT: BUFF DEPLOYED ]========================================
public Event_BuffDeployed( Handle:event, const String:name[], bool:broadcast )
{
	new client = GetClientOfUserId( GetEventInt( event, "buff_owner" ) );
	
	if ( IsValidClient( client ) && IsPlayerAlive( client ) )
	{
		if ( HasAttribute( client, _, m_bBuffStuff_ATTRIBUTE ) ) m_bBools[client][m_bBuff_Deployed] = true;
	}

	return;
}

// ====[ ON CLIENT PRETHINK ]==========================================
public OnClientPreThink( client )
{
	OnPreThink( client );
}
public OnPreThink( client )
{
	if ( !IsValidClient( client ) ) return;
	if ( !IsPlayerAlive( client ) ) return;
	
	new buttons_last = g_iLastButtons[client];
	new buttons = GetClientButtons( client );
	new m_iButtons2 = buttons;
	
	new Handle:hArray = CreateArray();
	new slot = TF2_GetClientActiveSlot( client );
	if ( slot >= 0 ) PushArrayCell( hArray, slot );
	PushArrayCell( hArray, 4 );
	
	new m_iSlot2;
	for ( new i = 0; i < GetArraySize( hArray ); i++ ) // ACTIVE STUFF HERE.
	{
		m_iSlot2 = GetArrayCell( hArray, i );
		buttons = ATTRIBUTE_ATTACKSPEEDONKILL( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_HEATDMGTAKEN( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_HEATFIRERATE( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_MCFRTD( client, buttons, m_iSlot2, buttons_last );
	}
	CloseHandle( hArray );
	
	m_iSlot2 = -1;
	for ( m_iSlot2 = 0; m_iSlot2 <= 4; m_iSlot2++ ) // ALWAYS ACTIVE | PASSIVE STUFF HERE.
	{
		buttons = ATTRIBUTE_BERSERKER( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_BONUSDAMAGEVSSAPPER( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_BUFFSTUFF( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_DEMOCHARGE( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_DEMOCHARGE_BLOCK( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_DISABLEUBER( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_LOWBERSERKER( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_METALDRAIN( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_PSYCHO( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_REMOVESTUN( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_SETWEAPONSWITCH( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_SPYDETECTOR( client, buttons, m_iSlot2, buttons_last );
		buttons = ATTRIBUTE_CHARGEDAMAGETHING( client, buttons, m_iSlot2, buttons_last );

		buttons = HUD_SHOWSYNCHUDTEXT( client, buttons, m_iSlot2, buttons_last );

		buttons = PRETHINK_AFTERBURN( client, buttons, m_iSlot2, buttons_last );
		buttons = PRETHINK_STACKREMOVER( client, buttons, m_iSlot2, buttons_last );

	}

	if ( buttons != m_iButtons2 ) SetEntProp( client, Prop_Data, "m_nButtons", buttons );	
	g_iLastButtons[client] = buttons;
}

ATTRIBUTE_HEATFIRERATE( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bHeatFireRate_ATTRIBUTE ) )
	{
		if ( HasAttribute( client, _, m_bHeatFireRate_ATTRIBUTE, true ) )
		{
			new Float:delay = GetAttributeValueF( client, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_Delay, true );
			new Float:old_as = GetAttributeValueF( client, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_OldAttackSpeed, true );

			new weapon = TF2_GetClientActiveWeapon( client );
			new ammo_l = GetClipAmmo( client, TF2_GetClientActiveSlot( client ) );
			new ammo_c = GetCarriedAmmo( client, TF2_GetClientActiveSlot( client ) );

			if ( !( TF2Attrib_GetByName( weapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( weapon, "fire rate bonus", old_as );
			new Address:m_aAttribute = TF2Attrib_GetByName( weapon, "fire rate bonus" );
			new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

			decl String:m_sWeapon[20];
			GetClientWeapon( client, m_sWeapon, sizeof( m_sWeapon ) );
			if ( !GetEntProp( weapon, Prop_Data, "m_bInReload" ) && ammo_l > 0 && !StrEqual( m_sWeapon, "tf_weapon_minigun" )
				|| ammo_c > 0 && StrEqual( m_sWeapon, "tf_weapon_minigun" ) )
			{
				if ( buttons & IN_ATTACK == IN_ATTACK || buttons & IN_ATTACK2 == IN_ATTACK2 && StrEqual( m_sWeapon, "tf_weapon_minigun" ) ) // Thx FlaminSarge.
				{
					if ( m_hTimers[client][m_hHeatFireRate_TimerDelay] == INVALID_HANDLE )
					{
						new Handle:m_hData01 = CreateDataPack();
						m_hTimers[client][m_hHeatFireRate_TimerDelay] = CreateDataTimer( delay, m_tHeatAttackSpeed_TimerDelay, m_hData01 );
						WritePackCell( m_hData01, weapon );
						WritePackCell( m_hData01, client );
						WritePackFloat( m_hData01, m_flAttackSpeed );
					}
				}
				else {
					if ( m_hTimers[client][m_hHeatFireRate_TimerDelay] != INVALID_HANDLE )
						ClearTimer( m_hTimers[client][m_hHeatFireRate_TimerDelay] );
				}
			}
			else {
				if ( m_hTimers[client][m_hHeatFireRate_TimerDelay] != INVALID_HANDLE )
					ClearTimer( m_hTimers[client][m_hHeatFireRate_TimerDelay] );
			}

			for ( new i = 0 ; i <= 2 ; i++ ) {
				if ( HasAttribute( client, i, m_bHeatFireRate_ATTRIBUTE ) ) AttackSpeedLimit( client, weapon, i, m_flAttackSpeed );
			}

			if ( m_hTimers[client][m_hHeatFireRate_TimerDelay] == INVALID_HANDLE )
			{
				m_iIntegers[client][m_iHeat] = 0;
				if ( m_iIntegers[client][m_iHeat] == 0 ) TF2Attrib_SetByName( weapon, "fire rate bonus", old_as );
			}
		}
	}

	return buttons;
}

ATTRIBUTE_HEATDMGTAKEN( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bHeatDMGTaken_ATTRIBUTE ) )
	{
		if ( HasAttribute( client, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
		{
			new Float:delay = GetAttributeValueF( client, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_Delay, true );

			new ammo = GetCarriedAmmo( client, TF2_GetClientActiveSlot( client ) );
			if ( ammo <= 0 ) m_iIntegers[client][m_iHeatToo] = 0;

			if ( GetEntProp( TF2_GetClientActiveWeapon( client ), Prop_Data, "m_bInReload") )
				ClearTimer( m_hTimers[client][m_hHeatDamage_TimerDelay] );

			decl String:m_sWeapon[20];
			GetClientWeapon( client, m_sWeapon, sizeof( m_sWeapon ) );
			if ( buttons & IN_ATTACK == IN_ATTACK || buttons & IN_ATTACK2 == IN_ATTACK2 && StrEqual( m_sWeapon, "tf_weapon_minigun" ) ) // Thx FlaminSarge.
			{
				if ( m_hTimers[client][m_hHeatDamage_TimerDelay] == INVALID_HANDLE )
					m_hTimers[client][m_hHeatDamage_TimerDelay] = CreateTimer( delay, m_tHeatDMGTaken_TimerDelay, client );
			} 
			else m_iIntegers[client][m_iHeatToo] = 0;
		}
		if ( m_hTimers[client][m_hHeatDamage_TimerDelay] == INVALID_HANDLE ) m_iIntegers[client][m_iHeatToo] = 0;
	}

	return buttons;
}

ATTRIBUTE_ATTACKSPEEDONKILL( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bAttackSpeedOnKill_ATTRIBUTE, true ) )
	{
		new Float:old_as = GetAttributeValueF( client, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_OldAttackSpeed, true );
		new Float:attack_speed = GetAttributeValueF( client, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_AttackSpeed, true );

		new weapon = TF2_GetClientActiveWeapon( client );

		if ( m_iIntegers[client][m_iAttackSpeed] == 0 ) TF2Attrib_SetByName( weapon, "fire rate bonus", old_as );
		else {
			if ( !( TF2Attrib_GetByName( weapon, "fire rate bonus" ) ) ) TF2Attrib_SetByName( weapon, "fire rate bonus", old_as );
			new Address:m_aAttribute = TF2Attrib_GetByName( weapon, "fire rate bonus" );
			new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );
			new Float:fValue = attack_speed * m_iIntegers[client][m_iAttackSpeed];

			for ( new i = 0 ; i <= 2 ; i++ ) {
				if ( HasAttribute( client, i, m_bAttackSpeedOnKill_ATTRIBUTE ) ) {
					TF2Attrib_SetByName( weapon, "fire rate bonus", old_as-fValue );
					AttackSpeedLimit( client, weapon, i, m_flAttackSpeed );
				}
			}
		}
	}

	return buttons;
}

ATTRIBUTE_MCFRTD( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bMCFRTD_ATTRIBUTE, true ) )
	{
		new Float:old_as = GetAttributeValueF( client, _, m_bMCFRTD_ATTRIBUTE, m_flMCFRTD_OldAttackSpeed, true );

		if ( !( m_bBools[client][m_bLastWasMiss] ) )
		{
			new weapon = TF2_GetClientActiveWeapon( client );

			if ( !( TF2Attrib_GetByName( weapon, "fire rate penalty" ) ) ) TF2Attrib_SetByName( weapon, "fire rate penalty", old_as );
			if ( m_iIntegers[client][m_iMissStack] <= 0 ) TF2Attrib_SetByName( weapon, "fire rate penalty", old_as );
		}
	}

	return buttons;
}

ATTRIBUTE_BERSERKER( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bBerserker_ATTRIBUTE ) )
	{
		new Float:threshold = GetAttributeValueF( client, _, m_bBerserker_ATTRIBUTE, m_flBerserker_Threshold );
		new Float:duration = GetAttributeValueF( client, _, m_bBerserker_ATTRIBUTE, m_flBerserker_Duration );

		if ( GetClientHealth( client ) <= TF2_GetClientMaxHealth( client ) * threshold )
		{
			if ( m_hTimers[client][m_hBerserker_TimerDuration] == INVALID_HANDLE )
			{
				TF2_AddCondition( client, TFCond_Ubercharged, duration );
				TF2_AddCondition( client, TFCond_CritOnFirstBlood, duration );
				TF2_AddCondition( client, TFCond_SpeedBuffAlly, duration );
				m_hTimers[client][m_hBerserker_TimerDuration] = CreateTimer( duration, m_tBerserker_TimerDuration, client );
			}
		}
		if ( GetClientHealth( client ) >= TF2_GetClientMaxHealth( client )*1.5 )
		{
			if ( m_hTimers[client][m_hBerserker_TimerDuration] != INVALID_HANDLE )
			{
				TF2_RemoveCondition( client, TFCond_Ubercharged );
				TF2_RemoveCondition( client, TFCond_CritOnFirstBlood );
				TF2_RemoveCondition( client, TFCond_SpeedBuffAlly );
				if ( m_hTimers[client][m_hBerserker_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[client][m_hBerserker_TimerDuration] );
			}
		}
	}

	return buttons;
}

ATTRIBUTE_LOWBERSERKER( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bLowBerserker_ATTRIBUTE ) )
	{
		new Float:threshold = GetAttributeValueF( client, _, m_bLowBerserker_ATTRIBUTE, m_flLowBerserker_Threshold );
		new Float:duration = GetAttributeValueF( client, _, m_bLowBerserker_ATTRIBUTE, m_flLowBerserker_Duration );

		if ( GetClientHealth( client ) <= TF2_GetClientMaxHealth( client ) * threshold )
		{
			if ( m_hTimers[client][m_hLowBerserker_TimerDuration] == INVALID_HANDLE )
			{
				TF2_AddCondition( client, TFCond_Buffed, duration );
				TF2_AddCondition( client, TFCond_DefenseBuffed, duration );
				TF2_AddCondition( client, TFCond_RegenBuffed, duration );
				TF2_AddCondition( client, TFCond_SpeedBuffAlly, duration );
				m_hTimers[client][m_hLowBerserker_TimerDuration] = CreateTimer( duration, m_tLowBerserker_TimerDuration, client );
			}
		}
		if ( GetClientHealth( client ) >= TF2_GetClientMaxHealth( client )*1.5 )
		{
			if ( m_hTimers[client][m_hLowBerserker_TimerDuration] != INVALID_HANDLE )
			{
				TF2_RemoveCondition( client, TFCond_Buffed );
				TF2_RemoveCondition( client, TFCond_DefenseBuffed );
				TF2_RemoveCondition( client, TFCond_RegenBuffed );
				TF2_RemoveCondition( client, TFCond_SpeedBuffAlly );
				if ( m_hTimers[client][m_hLowBerserker_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[client][m_hLowBerserker_TimerDuration] );
			}
		}
	}

	return buttons;
}

ATTRIBUTE_PSYCHO( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bPsycho_ATTRIBUTE ) )
	{
		new Float:duration = GetAttributeValueF( client, _, m_bPsycho_ATTRIBUTE, m_flPsycho_Duration );
		new melee = GetAttributeValueI( client, _, m_bPsycho_ATTRIBUTE, m_iPsycho_Melee );
		new Float:regen = GetAttributeValueF( client, _, m_bPsycho_ATTRIBUTE, m_flPsycho_RegenPct );

		if ( HasAttribute( client, _, m_bPsycho_ATTRIBUTE ) )
		{
			if ( TF2_IsPlayerInCondition( client, TFCond_Taunting ) )
			{
				if ( m_flFloats[client][m_flPyschoCharge] == 100.0 && m_hTimers[client][m_hPsycho_TimerDuration] == INVALID_HANDLE )
				{
					m_hTimers[client][m_hPsycho_TimerDuration] = CreateTimer( duration, m_tPsycho_TimerDuration, client );
					FakeClientCommand( client, "taunt" );
					TF2_AddCondition( client, TFCond_MegaHeal, duration );
					TF2_AddCondition( client, TFCond_SpeedBuffAlly, duration );
					TF2_AddCondition( client, TFCond_TeleportedGlow, duration );
					TF2_AddCondition( client, TFCond_Sapped, duration );
					if ( melee == 1 ) {
						TF2_AddCondition( client, TFCond_RestrictToMelee, duration );
						TF2_SetClientSlot( client, 2 );
					}
					TF2_RemoveCondition( client, TFCond_Dazed );
					EmitSoundToClient( client, SOUND_TBASH );
				}
			}
		}
		if ( m_hTimers[client][m_hPsycho_TimerDuration] != INVALID_HANDLE )
		{
			m_flFloats[client][m_flPyschoCharge] -= ( 0.303 / duration );

			if ( GetClientHealth( client ) < TF2_GetClientMaxHealth( client ) )
			{
				if ( regen != 0.0 )
				{
					m_flFloats[client][m_flPsychoRegenCharge] += ( ( TF2_GetClientMaxHealth( client ) - GetClientHealth( client ) ) * regen * ( 0.0303 / duration ) );
					if ( m_flFloats[client][m_flPsychoRegenCharge] >= 1.0 ) {
						TF2_HealPlayer( client, m_flFloats[client][m_flPsychoRegenCharge] );
						m_flFloats[client][m_flPsychoRegenCharge] = 0.0;
					}
				}
				else SetEntityHealth( client, TF2_GetClientMaxHealth( client ) );
			}
		}

		if ( m_flFloats[client][m_flPyschoCharge] > 100.0 ) m_flFloats[client][m_flPyschoCharge] = 100.0;
		if ( m_flFloats[client][m_flPyschoCharge] < 0.0 ) m_flFloats[client][m_flPyschoCharge] = 0.0;
	}

	return buttons;
}

ATTRIBUTE_METALDRAIN( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bMetalDrain_ATTRIBUTE ) )
	{
		new mode = GetAttributeValueI( client, _, m_bMetalDrain_ATTRIBUTE, m_iMetalDrain_PoA );

		if ( m_hTimers[client][m_hDrainMetal_TimerDelay] == INVALID_HANDLE )
			if ( mode == 0 || HasAttribute( client, _, m_bMetalDrain_ATTRIBUTE, true ) && mode == 1 )
				m_hTimers[client][m_hDrainMetal_TimerDelay] = CreateTimer( GetAttributeValueF( client, _, m_bMetalDrain_ATTRIBUTE, m_flMetalDrain_Interval ), m_tDrainMetal_TimerInterval, client );
	}

	return buttons;
}

ATTRIBUTE_DEMOCHARGE( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bDemoCharge_DamageReduction_ATTRIBUTE ) ) {
		if ( TF2_IsPlayerInCondition( client, TFCond_Charging ) ) TF2_AddCondition( client, TFCond_DefenseBuffMmmph, 0.5 );
	}

	return buttons;
}

ATTRIBUTE_BONUSDAMAGEVSSAPPER( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bBonusDamageVsSapper_ATTRIBUTE, true ) )
	{
		new weapon = TF2_GetClientActiveWeapon( client );
		TF2Attrib_RemoveByName( weapon, "dmg bonus vs buildings" );
	}

	return buttons;
}

ATTRIBUTE_SPYDETECTOR( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bSpyDetector_ATTRIBUTE ) && GetAttributeValueI( client, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_ActivePassive ) == 0
	|| HasAttribute( client, _, m_bSpyDetector_ATTRIBUTE, true ) && GetAttributeValueI( client, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_ActivePassive, true ) == 1 )
	{
		new Float:radius = GetAttributeValueF( client, _, m_bSpyDetector_ATTRIBUTE, m_flSpyDetector_Radius );
		new type = GetAttributeValueI( client, _, m_bSpyDetector_ATTRIBUTE, m_iSpyDetector_Type );

		for ( new i = 1; i <= MaxClients; i++ )
		{
			if ( i != client && IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( client ) )
			{
				new Float:m_flPos1[3], Float:m_flPos2[3];
				GetClientAbsOrigin( client, m_flPos1 );
				GetClientAbsOrigin( i, m_flPos2 );

				new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
				if ( distance <= radius )
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

	return buttons;
}

ATTRIBUTE_DEMOCHARGE_BLOCK( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE ) )
	{
		new mode = GetAttributeValueI( client, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE, m_iDemoCharge_HealthThreshold_Mode );
		new Float:threshold = GetAttributeValueF( client, _, m_bDemoCharge_HealthThreshold_ATTRIBUTE, m_flDemoCharge_HealthThreshold_Threshold );

		if ( buttons & IN_ATTACK2 == IN_ATTACK2 )
		{
			if ( mode == 1 && GetClientHealth( client ) >= ( threshold * TF2_GetClientMaxHealth( client ) ) || mode == 2 && GetClientHealth( client ) <= ( threshold * TF2_GetClientMaxHealth( client ) ) )
			{
				buttons &= ~IN_ATTACK2;
				return buttons;
			}
		}
	}

	return buttons;
}

ATTRIBUTE_REMOVESTUN( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bCannotBeStunned_ATTRIBUTE ) )
	{
		new type = GetAttributeValueI( client, _, m_bCannotBeStunned_ATTRIBUTE, m_iCannotBeStunned_Type );

		if ( !( GetEntityMoveType( client ) & MOVETYPE_NONE ) )
		{
			if ( type == 1 && TF2_IsPlayerInCondition( client, TFCond_Dazed ) && GetEntProp( client, Prop_Send, "m_iStunFlags" ) != TF_STUNFLAGS_GHOSTSCARE 
				|| type == 2 && GetEntProp( client, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE
				|| type == 3 && TF2_IsPlayerInCondition( client, TFCond_Dazed ) || type == 3 && GetEntProp( client, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE )
				TF2_RemoveCondition( client, TFCond_Dazed );
		}
	}

	return buttons;
}

ATTRIBUTE_DISABLEUBER( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bDisableUbercharge_ATTRIBUTE ) )
	{
		if ( TF2_GetClientUberLevel( client ) >= 99.0 ) TF2_SetClientUberLevel( client, 99.0 );
		// This is to avoid the attribute 'deal bonus dmg with ubercharge' to not being useless if you also have this.
	}

	return buttons;
}

ATTRIBUTE_BUFFSTUFF( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bBuffStuff_ATTRIBUTE ) )
	{
		new Float:bonus_radius = GetAttributeValueF( client, _, m_bBuffStuff_ATTRIBUTE, m_flBuffStuff_Radius );
		new mode = GetAttributeValueI( client, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_Mode );
		new id = GetAttributeValueI( client, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID );
		new id2 = GetAttributeValueI( client, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID2 );
		new id3 = GetAttributeValueI( client, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID3 );
		new id4 = GetAttributeValueI( client, _, m_bBuffStuff_ATTRIBUTE, m_iBuffStuff_ID4 );

		if ( m_bBools[client][m_bBuff_Deployed] )
		{
			for ( new i = 1; i <= MaxClients; i++ )
			{
				if ( IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) == GetClientTeam( client ) )
				{
					new Float:m_flPos1[3], Float:m_flPos2[3];
					GetClientAbsOrigin( client, m_flPos1 );
					GetClientAbsOrigin( i, m_flPos2 );

					new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
					if ( distance <= ( 450.0 * bonus_radius ) )
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
							if ( id == 1 /*TF2_IsPlayerInCondition( client, TFCond_Buffed )*/ ) TF2_AddCondition( i, TFCond_Buffed, 0.25 );
							else if ( id == 2 /*TF2_IsPlayerInCondition( client, TFCond_DefenseBuffed )*/ ) TF2_AddCondition( i, TFCond_DefenseBuffed, 0.25 );
							else if ( id == 3 /*TF2_IsPlayerInCondition( client, TFCond_RegenBuffed )*/ ) TF2_AddCondition( i, TFCond_RegenBuffed, 0.25 );
						}
					}
				}
			}
		}
		if ( GetEntPropFloat( client, Prop_Send, "m_flRageMeter" ) < 1.0 )
			m_bBools[client][m_bBuff_Deployed] = false;
	}

	return buttons;
}

ATTRIBUTE_SETWEAPONSWITCH( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bSetWeaponSwitch_ATTRIBUTE ) )
		TF2_SetClientSlot( client, GetAttributeValueI( client, _, m_bSetWeaponSwitch_ATTRIBUTE, m_iSetWeaponSwith_Slot ) );

	return buttons;
}

ATTRIBUTE_CHARGEDAMAGETHING( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bDamageChargeThing_ATTRIBUTE ) )
	{
		if ( HasAttribute( client, _, m_bDamageChargeThing_ATTRIBUTE, true ) && buttons & IN_ATTACK2 == IN_ATTACK2 )
		{
			if ( m_hTimers[client][m_hDamageChargeThing_Enabled] == INVALID_HANDLE )
			{
				if ( m_bBools[client][m_bDamageChargeThing_Enable] ) {
					m_bBools[client][m_bDamageChargeThing_Enable] = false;
					EmitSoundToClient( client, SOUND_NOTREADY );
					m_hTimers[client][m_hDamageChargeThing_Enabled] = CreateTimer( 1.0, m_tChargeDamageThing, client );
				} else {
					m_bBools[client][m_bDamageChargeThing_Enable] = true;
					EmitSoundToClient( client, SOUND_READY );
					m_hTimers[client][m_hDamageChargeThing_Enabled] = CreateTimer( 1.0, m_tChargeDamageThing, client );
				}
			}
		}
	}

	return buttons;
}

PRETHINK_AFTERBURN( client, &buttons, &slot, &buttons_last )
{
	if ( IsValidClient( client )
		&& !( GetEntityFlags( client ) & FL_INWATER )
		&& !TF2_IsPlayerInCondition( client, TFCond_OnFire )
		&& TF2_GetPlayerClass( client ) != TFClass_Pyro
		&& !HasInvulnerabilityCond( client )
		&& g_pBurner[client] != -1 )
	{
		if ( HasAttribute( g_pBurner[client], _, m_bInfiniteAfterburn_ATTRIBUTE )
			&& m_hTimers[client][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE )
			TF2_IgnitePlayer( client, g_pBurner[client] );
	}

	return buttons;
}

PRETHINK_STACKREMOVER( client, &buttons, &slot, &buttons_last )
{
	if ( HasAttribute( client, _, m_bMarkVictimDamage_ATTRIBUTE ) ) {
		if ( m_iIntegers[client][m_iMarkVictimDamage] < 0 ) m_iIntegers[client][m_iMarkVictimDamage] = 0;
	}
	if ( !HasAttribute( client, _, m_bMarkVictimDamage_ATTRIBUTE ) ) {
		if ( !g_hPostInventory[client] && IsPlayerAlive( client ) ) m_iIntegers[client][m_iMarkVictimDamage] = 0;
	}
	if ( !HasAttribute( client, _, m_bAttackSpeedOnKill_ATTRIBUTE ) ) {
		if ( !g_hPostInventory[client] && IsPlayerAlive( client ) ) m_iIntegers[client][m_iAttackSpeed] = 0;
	}

	return buttons;
}

HUD_SHOWSYNCHUDTEXT( client, &buttons, &slot, &buttons_last )
{
	new String:m_strHUDAttackSpeedOnKill[17];
	new String:m_strHUDDamageReceivedUnleashedDeath[17];
	new String:m_strHUDDamageResHpMissing[25];
	new String:m_strHUDHeatDMGTaken[17];
	new String:m_strHUDHeatFireRate[17];
	new String:m_strHUDMissDecreasesFireRate[17];
	new String:m_strHUDPsycho[17];
	new String:m_strHUDSteal[25];
	new String:m_strHUDDamageChargeThing[17];

	if ( HasAttribute( client, _, m_bHeatFireRate_ATTRIBUTE, true ) )
	{
		new max = GetAttributeValueI( client, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack, true );

		Format( m_strHUDHeatFireRate, sizeof( m_strHUDHeatFireRate ), "Heat: %i/%i", m_iIntegers[client][m_iHeat], max );
	}
//-//
	if ( HasAttribute( client, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
	{
		new max = GetAttributeValueI( client, _, m_bHeatDMGTaken_ATTRIBUTE, m_iHeatDMGTaken_MaximumStack, true );

		Format( m_strHUDHeatDMGTaken, sizeof( m_strHUDHeatDMGTaken ), "Heat: %i/%i", m_iIntegers[client][m_iHeatToo], max );
	}
//-//
	if ( HasAttribute( client, _, m_bAttackSpeedOnKill_ATTRIBUTE, true ) )
	{
		new max = GetAttributeValueI( client, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_iAttackSpeedOnKill_MaximumStack, true );

		if ( max >= 1024 ) {
			Format( m_strHUDAttackSpeedOnKill, sizeof( m_strHUDAttackSpeedOnKill ), "Kills: %i", m_iIntegers[client][m_iAttackSpeed] );
		} else {
			Format( m_strHUDAttackSpeedOnKill, sizeof( m_strHUDAttackSpeedOnKill ), "Kills: %i/%i", m_iIntegers[client][m_iAttackSpeed], max );
		}
	}
//-//
	if ( HasAttribute( client, _, m_bMCFRTD_ATTRIBUTE, true ) )
	{
		new max = GetAttributeValueI( client, _, m_bMCFRTD_ATTRIBUTE, m_iMCFRTD_MaximumStack, true );

		if ( max >= 1024 ) {
			Format( m_strHUDMissDecreasesFireRate, sizeof( m_strHUDMissDecreasesFireRate ), "Miss: %i", m_iIntegers[client][m_iMissStack] );
		} else {
			Format( m_strHUDMissDecreasesFireRate, sizeof( m_strHUDMissDecreasesFireRate ), "Miss: %i/%i", m_iIntegers[client][m_iMissStack], max );
		}
	}
//-//
	if ( HasAttribute( client, _, m_bPsycho_ATTRIBUTE ) )
		Format( m_strHUDPsycho, sizeof( m_strHUDPsycho ), "Rampage: %.0f%%", m_flFloats[client][m_flPyschoCharge] );
//-//
	if ( HasAttribute( client, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
		Format( m_strHUDDamageReceivedUnleashedDeath, sizeof( m_strHUDDamageReceivedUnleashedDeath ), "Damage: %.0f", m_flFloats[client][damageReceived] );
//-//
	if ( HasAttribute( client, _, m_bDamageResHealthMissing_ATTRIBUTE ) )
	{
		if ( GetAttributeValueI( client, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_Active ) == 1 && HasAttribute( client, _, m_bDamageResHealthMissing_ATTRIBUTE, true )
			|| GetAttributeValueI( client, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_Active ) == 0 )
		{
			new penalty = GetAttributeValueI( client, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_OverhealPenalty );
			new Float:resphp = GetAttributeValueF( client, _, m_bDamageResHealthMissing_ATTRIBUTE, damageResHealthMissing_ResPctPerMissingHpPct );
			new max = GetAttributeValueI( client, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct );

			new Float:m_flMHP = 1 - ( FloatDiv( GetClientHealth( client )+0.0, TF2_GetClientMaxHealth( client )+0.0 ) );
			if ( GetClientHealth( client ) > TF2_GetClientMaxHealth( client ) && penalty == 0 ) m_flMHP = 0.0;
			new Float:m_flResPct = resphp * m_flMHP;
			if ( m_flMHP * 100.0 > max ) m_flResPct = resphp * FloatDiv( max+0.0, 100.0 );

			Format( m_strHUDDamageResHpMissing, sizeof( m_strHUDDamageResHpMissing ), "Resistance: %.0f%%", m_flResPct*100.0 );
		}
	}
//-//
	if ( m_bBools[client][m_bStealPct] == true ) {
		if ( m_flFloats[client][m_flStealDamageVictim] != 0.0 || m_flFloats[client][m_flStealDamageAttacker] != 0.0 )
			Format( m_strHUDSteal, sizeof( m_strHUDSteal ), "Damage Stolen: %.0f%%", m_flFloats[client][m_flStealDamageAttacker] - m_flFloats[client][m_flStealDamageVictim] );
	} else {
		if ( m_flFloats[client][m_flStealDamageVictim] != 0.0 || m_flFloats[client][m_flStealDamageAttacker] != 0.0 )
			Format( m_strHUDSteal, sizeof( m_strHUDSteal ), "Damage Stolen: %i", m_flFloats[client][m_flStealDamageAttacker] - m_flFloats[client][m_flStealDamageVictim] );
	}
//-//
	if ( HasAttribute( client, _, m_bDamageChargeThing_ATTRIBUTE ) )
	{
		new String:m_sState[7];
		( m_bBools[client][m_bDamageChargeThing_Enable] ? Format( m_sState, sizeof( m_sState ), " [ON]", m_sState ) : Format( m_sState, sizeof( m_sState ), " [OFF]", m_sState ) );

		Format( m_strHUDDamageChargeThing, sizeof( m_strHUDDamageChargeThing ), "Charge: %.0f%%%s", m_flFloats[client][damageCharge], m_sState );
	}
//-//
	if ( IfDoNextTime2( client, e_flNextHUDUpdate, 0.1 ) ) // Thanks Chdata :D
	{
		ShowSyncHudText( client, g_hHudText_O, "%s \n%s \n%s \n%s \n%s \n%s \n%s \n%s \n%s", m_strHUDAttackSpeedOnKill,
																								m_strHUDDamageReceivedUnleashedDeath,
																								m_strHUDDamageResHpMissing,
																								m_strHUDHeatDMGTaken,
																								m_strHUDHeatFireRate,
																								m_strHUDMissDecreasesFireRate,
																								m_strHUDPsycho,
																								m_strHUDSteal,
																								m_strHUDDamageChargeThing );
	}
	
	return buttons;
}

// ====[ ON ADD ATTRIBUTE ]============================================
public Action:CW3_OnAddAttribute( slot, client, const String:attribute[], const String:plugin[], const String:value[], bool:active )
{
	if ( !StrEqual( plugin, "orion" ) ) return Plugin_Continue;
	new Action:apply;

	/* Hot Sauce On Hit
	 *
	 * ---------------------------------------------------------------------- */
	if ( StrEqual( attribute, "hotsauce on hit" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flHotSauceOnHit_Duration[client][slot]= StringToFloat( values[0] );
		m_iHotSauceOnHit_Type[client][slot]		= StringToInt( values[1] );
		m_bHotSauceOnHit_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Hot Sauce On Crit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "hotsauce on crit" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flHotSauceOnCrit_Duration[client][slot]= StringToFloat( values[0] );
		m_iHotSauceOnCrit_Type[client][slot]	= StringToInt( values[1] );
		m_bHotSauceOnCrit_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Stun On Hit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "stun on hit" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flStunOnHit_Duration[client][slot] = StringToFloat( values[0] );
		m_iStunOnHit_StunLock[client][slot]= StringToInt( values[1] );
		m_bStunOnHit_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Stun On Crit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "stun on hitcrit" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flStunOnCrit_Duration[client][slot] = StringToFloat( values[0] );
		m_iStunOnCrit_StunLock[client][slot]= StringToInt( values[1] );
		m_bStunOnCrit_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Enemy Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "enemy hp to dmg" ) )
	{
		m_flActualEnemyHealthToDamage_Multiplier[client][slot] = StringToFloat( value );
		m_bActualEnemyHealthToDamage_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "hp to dmg" ) )
	{
		m_flActualHealthToDamage_Multiplier[client][slot]= StringToFloat( value );
		m_bActualHealthToDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Maximum Enemy Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "max enemy hp to dmg" ) )
	{
		m_flMaximumEnemyHealthToDamage_Multiplier[client][slot]	= StringToFloat( value );
		m_bMaximumEnemyHealthToDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Maximum Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "max hp to dmg" ) )
	{
		m_flMaximumHealthToDamage_Multiplier[client][slot] = StringToFloat( value );
		m_bMaximumHealthToDamage_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Lifesteal From Health
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "health lifesteal" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		m_flHealthLifesteal_Multiplier[client][slot]	= StringToFloat( values[0] );
		m_flHealthLifesteal_OverHealBonusCap[client][slot] = StringToFloat( values[1] );
		m_bHealthLifesteal_ATTRIBUTE[client][slot]		 = true;
		apply = Plugin_Handled;
	}
	/* Lifesteal From Enemy Health
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "enemy health lifesteal" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		m_flEnemyHealthLifesteal_Multiplier[client][slot]		= StringToFloat( values[0] );
		m_flEnemyHealthLifesteal_OverHealBonusCap[client][slot]	= StringToFloat( values[1] );
		m_bEnemyHealthLifesteal_ATTRIBUTE[client][slot]			= true;
		apply = Plugin_Handled;
	}
	/* Drain Übercharge
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "drain uber" ) )
	{
		m_flDrainUbercharge_Percentage[client][slot]= StringToFloat( value );
		m_bDrainUbercharge_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Drain Übercharge On Crit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "drain uber crit" ) )
	{
		m_flDrainUberchargeOnCrit_Percentage[client][slot] = StringToFloat( value );
		m_bDrainUberchargeOnCrit_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Missing Enemy Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "missing enemy hp to dmg" ) )
	{
		m_flMissingEnemyHealthToDamage_Multiplier[client][slot]	= StringToFloat( value );
		m_bMissingEnemyHealthToDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Missing Enemy Health To Damage FLAMETHROWER
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "missing enemy hp to dmg FLAMETHROWER" ) )
	{
		m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[client][slot]= StringToFloat( value );
		m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Missing Health To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "missing hp to dmg" ) )
	{
		m_flMissingHealthToDamage_Multiplier[client][slot] = StringToFloat( value );
		m_bMissingHealthToDamage_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Lifesteal From Missing Enemy Health
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "missing enemy hp lifesteal" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		m_flMissingEnemyHealthLifesteal_Multiplier[client][slot]	= StringToFloat( values[0] );
		m_flMissingEnemyHealthLifesteal_OverHealBonusCap[client][slot] = StringToFloat( values[1] );
		m_bMissingEnemyHealthLifesteal_ATTRIBUTE[client][slot]		 = true;
		apply = Plugin_Handled;
	}
	/* Damage Done Is Selfhurt
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg done is selfhurt" ) )
	{
		damageDoneIsSelfHurt_Multiplier[client][slot]= StringToFloat( value );
		m_bDamageDoneIsSelfHurt_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus If Health Is Higher Than Health Threshold
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus if health higher than threshold" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		damageIfHealthHigherThanThreshold_BonusDamage[client][slot]	= StringToFloat( values[0] );
		damageIfHealthHigherThanThreshold_Threshold[client][slot]	= StringToFloat( values[1] );
		m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus If Health Is Lower Than Health Threshold
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus if health lower than threshold" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		damageIfHealthLowerThanThreshold_BonusDamage[client][slot] = StringToFloat( values[0] );
		damageIfHealthLowerThanThreshold_Threshold[client][slot]= StringToFloat( values[1] );
		m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus If Enemy Health Is Higher Than Health Threshold
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus if enemy health higher than threshold" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		damageIfEnemyHealthHigherThanThreshold_BonusDamage[client][slot]= StringToFloat( values[0] );
		damageIfEnemyHealthHigherThanThreshold_Threshold[client][slot]	 = StringToFloat( values[1] );
		m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus If Enemy Health Is Lower Than Health Threshold
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus if enemy health lower than threshold" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
		
		damageIfEnemyHealthLowerThanThreshold_BonusDamage[client][slot]	= StringToFloat( values[0] );
		damageIfEnemyHealthLowerThanThreshold_Threshold[client][slot]	= StringToFloat( values[1] );
		m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Backstab Damage Modifier With A Stun
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "backstab damage modifier sub stun" ) )
	{
		new String:values[5][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flBackstabDamageModSubStun_Multiplier[client][slot]= StringToFloat( values[0] );
		m_flBackstabDamageModSubStun_Duration[client][slot]	= StringToFloat( values[1] );
		m_iBackstabDamageModSubStun_Security[client][slot]	 = StringToInt( values[2] );
		m_iBackstabDamageModSubStun_BlockSuicide[client][slot] = StringToInt( values[3] );
		m_iBackstabDamageModSubStun_StunLock[client][slot]	 = StringToInt( values[4] );
		m_bBackstabDamageModSubStun_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Self Upon Attacking
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "damage self" ) )
	{
		m_iDamageSelf_Amount[client][slot]	 = StringToInt( value );
		m_bDamageSelf_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Combo
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "combo" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flCombo_BonusDamage[client][slot]	= StringToFloat( values[0] );
		m_iCombo_Hit[client][slot]			 = StringToInt( values[1] );
		m_iCombo_Crit[client][slot]			= StringToInt( values[2] );
		m_bCombo_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Chance To Oneshot
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "chance to oneshot" ) )
	{
		m_flChanceOneShot_Chance[client][slot]	 = StringToFloat( value );
		m_bChanceOneShot_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Chance To Ignite
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "chance to ignite" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flChanceIgnite_Chance[client][slot]	= StringToFloat( values[0] );
		m_flChanceIgnite_Duration[client][slot]	= StringToFloat( values[1] );
		m_bChanceIgnite_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Movement Speed To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "movespeed to dmg" ) )
	{
		m_flMovementSpeedToDamage_Multiplier[client][slot] = StringToFloat( value );
		m_bMovementSpeedToDamage_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Damage Taken Damage Nearby Enemies On Death
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg taken dmg nearby enemies on death" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		damageReceivedUnleashedDeath_Percentage[client][slot] = StringToFloat( values[0] );
		damageReceivedUnleashedDeath_Radius[client][slot]	 = StringToFloat( values[1] );
		m_iDamageReceivedUnleashedDeath_PoA[client][slot]		 = StringToInt( values[2] );
		m_iDamageReceivedUnleashedDeath_Backstab[client][slot]	= StringToInt( values[3] );
		m_bDamageReceivedUnleashedDeath_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Metal Drain
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "metal drain" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_iMetalDrain_Amount[client][slot]	= StringToInt( values[0] );
		m_flMetalDrain_Interval[client][slot] = StringToFloat( values[1] );
		m_iMetalDrain_PoA[client][slot]	= StringToInt( values[2] );
		m_bMetalDrain_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* Metal To Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "metal to dmg" ) )
	{
		m_flMetalToDamage_Multiplier[client][slot] = StringToFloat( value );
		m_bMetalToDamage_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Metal Per Shot
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "metal per shot" ) )
	{
		m_iMetalPerShot_Amount[client][slot]	= StringToInt( value );
		m_bMetalPerShot_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Metal On Hit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "metal on hit" ) )
	{
		m_iMetalOnHit_Amount[client][slot]	 = StringToInt( value );
		m_bMetalOnHit_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Metal On Hit Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "metal on hit damage" ) )
	{
		m_flMetalOnHitDamage_Multiplier[client][slot]= StringToFloat( value );
		m_bMetalOnHitDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage When Metal Runs Out
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg when metal runs out" ) )
	{
		damageWhenMetalRunsOut_Damage[client][slot]	= StringToFloat( value );
		m_bDamageWhenMetalRunsOut_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Kill Will Gib
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "kill will gib" ) )
	{
		m_bKillGib_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Spawn Skeleton On Kill
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "spawn skeleton on kill" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flSpawnSkeletonOnKill_Duration[client][slot]		 = StringToFloat( values[0] );
		m_iSpawnSkeletonOnKill_Boss[client][slot]			= StringToInt( values[1] );
		m_flSpawnSkeletonOnKill_BossChance[client][slot]	= StringToFloat( values[2] );
		m_bSpawnSkeletonOnKill_ATTRIBUTE[client][slot]		 = true;
		apply = Plugin_Handled;
	}
	/* Berserker Near Death
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "berserker near death" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flBerserker_Threshold[client][slot]= StringToFloat( values[0] );
		m_flBerserker_Duration[client][slot]= StringToFloat( values[1] );
		m_bBerserker_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Low Berserker Near Death
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "low berserker near death" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flLowBerserker_Threshold[client][slot]= StringToFloat( values[0] );
		m_flLowBerserker_Duration[client][slot]	= StringToFloat( values[1] );
		m_iLowBerserker_Kill[client][slot]		 = StringToInt( values[2] );
		m_bLowBerserker_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Psycho Rampage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "psycho rampage" ) )
	{
		new String:values[5][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flPsycho_DamageResistance[client][slot]= StringToFloat( values[0] );
		m_flPsycho_DamageBonus[client][slot]	= StringToFloat( values[1] );
		m_flPsycho_Duration[client][slot]		= StringToFloat( values[2] );
		m_flPsycho_RegenPct[client][slot]		= StringToFloat( values[3] );
		m_iPsycho_Melee[client][slot]			= StringToInt( values[4] );
		m_bPsycho_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* Heat Increases Fire Rate
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "heat increases fire rate" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flHeatFireRate_Delay[client][slot]		= StringToFloat( values[0] );
		m_flHeatFireRate_AttackSpeed[client][slot]	 = StringToFloat( values[1] );
		m_iHeatFireRate_MaximumStack[client][slot]	 = StringToInt( values[2] );
		m_flHeatFireRate_OldAttackSpeed[client][slot]= StringToFloat( values[3] );
		m_bHeatFireRate_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* Remove Bleeding
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "remove bleeding" ) )
	{
		m_bRemoveBleeding_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Übercharge On Hit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "uber on hit" ) )
	{
		m_flUberchargeOnHit_Amount[client][slot]= StringToFloat( value );
		m_bUberchargeOnHit_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Damage Taken While Invisible
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg taken while invis" ) )
	{
		damageResistanceInvisible_Multiplier[client][slot] = StringToFloat( value );
		m_bDamageResistanceInvisible_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Homing Projectile
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "homproj" ) ) // Thanks Tylerst.
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flHomingProjectile_DetectRadius[client][slot]	= StringToFloat( values[0] );
		m_iHomingProjectile_Mode[client][slot]			 = StringToInt( values[1] );
		m_iHomingProjectile_Type[client][slot]			 = StringToInt( values[2] );
		m_bHomingProjectile_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* Fragmentation Grenade
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "frag grenade attr" ) ) // Thanks Pelipoika
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_iFragmentation_Amount[client][slot]	= StringToInt( values[0] );
		m_flFragmentation_Damage[client][slot]	 = StringToFloat( values[1] );
		m_flFragmentation_Radius[client][slot]	 = StringToFloat( values[2] );
		m_iFragmentation_Mode[client][slot]		= StringToInt( values[3] );
		m_bFragmentation_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Ignite At Close Range
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "ignite at CLOSE RANGE" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flAfterburnCLOSERANGE_Duration[client][slot] = StringToFloat( values[0] );
		m_flAfterburnCLOSERANGE_Range[client][slot]	= StringToFloat( values[1] );
		m_bAfterburnCLOSERANGE_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Attack Speed On Kill
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "fire rate bonus on kill" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flAttackSpeedOnKill_AttackSpeed[client][slot]	= StringToFloat( values[0] );
		m_iAttackSpeedOnKill_MaximumStack[client][slot]	= StringToInt( values[1] );
		m_flAttackSpeedOnKill_Removal[client][slot]		= StringToFloat( values[2] );
		m_flAttackSpeedOnKill_OldAttackSpeed[client][slot] = StringToFloat( values[3] );
		m_bAttackSpeedOnKill_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Resistance While Charging DEMOMAN
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "damage res while charging DEMO" ) )
	{
		m_bDemoCharge_DamageReduction_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Charge Only On Health Threshold DEMO
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "charge only on hp threshold DEMO" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flDemoCharge_HealthThreshold_Threshold[client][slot]= StringToFloat( values[0] );
		m_iDemoCharge_HealthThreshold_Mode[client][slot]		 = StringToInt( values[1] );
		m_bDemoCharge_HealthThreshold_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Critical Hit Vs Invisible Players
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "crit vs invisible players" ) )
	{
		m_bCritVsInvisiblePlayer_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Mark Victim Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "mark victim dmg" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flMarkVictimDamage_Damage[client][slot]			= StringToFloat( values[0] );
		m_flMarkVictimDamage_Duration[client][slot]			= StringToFloat( values[1] );
		m_iMarkVictimDamage_MaximumDamageStack[client][slot]= StringToInt( values[2] );
		m_iMarkVictimDamage_MaximumVictim[client][slot]		= StringToInt( values[3] );
		m_bMarkVictimDamage_ATTRIBUTE[client][slot]			= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus Vs Sappers
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus vs sappers" ) )
	{
		m_flBonusDamageVsSapper_Multiplier[client][slot]= StringToFloat( value );
		m_bBonusDamageVsSapper_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus Vs Airborne Players
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus vs airborne players" ) )
	{
		m_flBonusDamageVSVictimInMidAir_Multiplier[client][slot]= StringToFloat( value );
		m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Critical Hit Vs Airborne Players
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "crit vs airborne players" ) )
	{
		m_bCritVictimInMidAir_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Critical Hit Vs Scared Players
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "crit vs scared players" ) )
	{
		m_bCritVictimScared_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Spy Condition Remover
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "spy cond remover" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flSpyDetector_Radius[client][slot]	= StringToFloat( values[0] );
		m_iSpyDetector_Type[client][slot]		= StringToInt( values[1] );
		m_iSpyDetector_ActivePassive[client][slot] = StringToInt( values[2] );
		m_bSpyDetector_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Bleed At Close Range
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "bleed at CLOSE RANGE" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flBleedCLOSERANGE_Duration[client][slot] = StringToFloat( values[0] );
		m_flBleedCLOSERANGE_Range[client][slot]	= StringToFloat( values[1] );
		m_bBleedCLOSERANGE_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Banner Extender
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "buff_item extender" ) )
	{
		new String:values[6][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_iBuffStuff_ID[client][slot]		= StringToInt( values[0] );
		m_iBuffStuff_ID2[client][slot]		 = StringToInt( values[1] );
		m_iBuffStuff_ID3[client][slot]		 = StringToInt( values[2] );
		m_iBuffStuff_ID4[client][slot]		 = StringToInt( values[3] );
		m_flBuffStuff_Radius[client][slot]	 = StringToFloat( values[4] );
		m_iBuffStuff_Mode[client][slot]		= StringToInt( values[5] );
		m_bBuffStuff_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Miss Decreases Fire Rate
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "miss decreases fire rate" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flMCFRTD_AttackSpeed[client][slot]	= StringToFloat( values[0] );
		m_iMCFRTD_MaximumStack[client][slot]	= StringToInt( values[1] );
		m_flMCFRTD_OldAttackSpeed[client][slot]	= StringToFloat( values[2] );
		m_bMCFRTD_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* MiniCrit Vs Invisible Players
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "minicrit vs invisible players" ) )
	{
		m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* MiniCrit Vs Burning Players At Close Range
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "minicrit vs burning players CLOSERANGE" ) )
	{
		m_flMinicritVsBurningCLOSERANGE_Range[client][slot]	= StringToFloat( value );
		m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Crit Vs Burning Players At Close Range
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "crit vs burning players CLOSERANGE" ) )
	{
		m_flCritVsBurningCLOSERANGE_Range[client][slot]	= StringToFloat( value );
		m_bCritVsBurningCLOSERANGE_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Damage Class
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg class" ) )
	{
		new String:values[9][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		damageClass_Scout[client][slot]	= StringToFloat( values[0] );
		damageClass_Soldier[client][slot]= StringToFloat( values[1] );
		damageClass_Pyro[client][slot]	 = StringToFloat( values[2] );
		damageClass_Demoman[client][slot]= StringToFloat( values[3] );
		damageClass_Heavy[client][slot]	= StringToFloat( values[4] );
		damageClass_Engineer[client][slot] = StringToFloat( values[5] );
		damageClass_Medic[client][slot]	= StringToFloat( values[6] );
		damageClass_Sniper[client][slot]= StringToFloat( values[7] );
		damageClass_Spy[client][slot]	= StringToFloat( values[8] );
		m_bDamageClass_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Infinite Afterburn
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "infinite afterburn" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flInfiniteAfterburn_Duration[client][slot]= StringToFloat( values[0] );
		m_iInfiniteAfterburn_Ressuply[client][slot]	= StringToInt( values[1] );
		m_bInfiniteAfterburn_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Kick-Ban On Kill-Hit
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "kickban on killhit" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_iBANOnKillHit_Duration[client][slot]		 = StringToInt( values[0] );
		m_iBANOnKillHit_HitOrKill[client][slot]		= StringToInt( values[1] );
		m_iBANOnKillHit_KickOrBan[client][slot]		= StringToInt( values[2] );
		m_bBANOnKillHit_ATTRIBUTE[client][slot]		= true;
		apply = Plugin_Handled;
	}
	/* Cannot Be Stunned
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "cannot be stunned" ) )
	{
		m_iCannotBeStunned_Type[client][slot]	= StringToInt( value );
		m_bCannotBeStunned_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Disable Übercharge
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "disable ubercharge" ) )
	{
		m_bDisableUbercharge_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Damage Taken From Backstab Reduced
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg taken from backstab reduced" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flReduceBackstabDamage_Percentage[client][slot]= StringToFloat( values[0] );
		m_iReduceBackstabDamage_ActOrMax[client][slot]	 = StringToInt( values[1] );
		m_bReduceBackstabDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Taken From Headshot Reduced
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg taken from headshot reduced" ) )
	{
		m_flReduceHeadshotDamage_Percentage[client][slot]= StringToFloat( value );
		m_bReduceHeadshotDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Bonus Vs Players In Water
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg bonus vs players in water" ) )
	{
		m_flBonusDamageVSVictimInWater_Multiplier[client][slot]= StringToFloat( value );
		m_bBonusDamageVsVictimInWater_ATTRIBUTE[client][slot]	 = true;
		apply = Plugin_Handled;
	}
	/* Crit Vs Players In Water
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "crit vs players in water" ) )
	{
		m_bCritVictimInWater_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* All Damage Done Multiplier
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "all dmg done multiplier" ) )
	{
		m_flAllDamageDoneMultiplier_Multiplier[client][slot]= StringToFloat( value );
		m_bAllDamageDoneMultiplier_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Resistance Based On Health Missing
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg resist health missing" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		damageResHealthMissing_ResPctPerMissingHpPct[client][slot]	= StringToFloat( values[0] );
		m_iDamageResHealthMissing_MaxStackOfMissingHpPct[client][slot]	= StringToInt( values[1] );
		m_iDamageResHealthMissing_OverhealPenalty[client][slot]		= StringToInt( values[2] );
		m_iDamageResHealthMissing_Active[client][slot]			= StringToInt( values[3] );
		m_bDamageResHealthMissing_ATTRIBUTE[client][slot]			= true;
		apply = Plugin_Handled;
	}
	/* Random Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "random dmg" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flRandomDamage_Min[client][slot]		 = StringToFloat( values[0] );
		m_flRandomDamage_Max[client][slot]		 = StringToFloat( values[1] );
		m_bRandomDamage_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Laser Damage Penalty
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "laser dmg penalty" ) )
	{
		m_flLaserWeaponDamageModifier_Damage[client][slot]	 = StringToFloat( value );
		m_bLaserWeaponDamageModifier_ATTRIBUTE[client][slot]= true;
		apply = Plugin_Handled;
	}
	/* Steal Damage
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "steal dmg" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flStealDamage_Steal[client][slot]	= StringToFloat( values[0] );
		m_flStealDamage_Duration[client][slot] = StringToFloat( values[1] );
		m_iStealDamage_Pct[client][slot] 		 = StringToInt( values[2] );
		m_bStealDamage_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Set Weapon Slot
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "set weapon slot" ) )
	{
		m_iSetWeaponSwith_Slot[client][slot]	= StringToInt( value );
		m_bSetWeaponSwitch_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Chance To Mad Milk
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "chance to mad milk" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flChanceMadMilk_Chance[client][slot]= StringToFloat( values[0] );
		m_flChanceMadMilk_Duration[client][slot] = StringToFloat( values[1] );
		m_bChanceMadMilk_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Chance To Jarate
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "chance to jarate" ) )
	{
		new String:values[2][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flChanceJarate_Chance[client][slot]= StringToFloat( values[0] );
		m_flChanceJarate_Duration[client][slot] = StringToFloat( values[1] );
		m_bChanceJarate_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Chance To Bleed
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "chance to bleed" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flChanceBleed_Chance[client][slot]= StringToFloat( values[0] );
		m_flChanceBleed_Duration[client][slot] = StringToFloat( values[1] );
		m_iChanceBleed_Stack[client][slot]	 = StringToInt( values[2] );
		m_bChanceBleed_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Heat Increases Damage Taken
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "heat increases dmg taken" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flHeatDMGTaken_Delay[client][slot]	= StringToFloat( values[0] );
		m_flHeatDMGTaken_DMG[client][slot]		 = StringToFloat( values[1] );
		m_iHeatDMGTaken_MaximumStack[client][slot] = StringToInt( values[2] );
		m_bHeatDMGTaken_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Bullets Per Shot Bonus Dynamic
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "bullets per shot bonus dynamic" ) )
	{
		m_bBulletsPerShotBonusDynamic_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Teleport To Victim On Kill
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "tp to victim on kill" ) )
	{
		m_bTeleportToVictimOnKill_ATTRIBUTE[client][slot] = true;
		apply = Plugin_Handled;
	}
	/* Scare On Kill
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "scare on kill" ) )
	{
		new String:values[3][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		m_flScareOnKill_Duration[client][slot]	= StringToFloat( values[0] );
		m_flScareOnKill_Radius[client][slot]	= StringToFloat( values[1] );
		m_iScareOnKill_StunLock[client][slot]	 = StringToInt( values[2] );
		m_bScareOnKill_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}
	/* Damage Charge Thing
	 *
	 * ---------------------------------------------------------------------- */
	else if ( StrEqual( attribute, "dmg charge thing" ) )
	{
		new String:values[4][10];
		ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

		damageChargeThing_Charge[client][slot]		= StringToFloat( values[0] );
		damageChargeThing_Damage[client][slot]		= StringToFloat( values[1] );
		damageChargeThing_DeCharge[client][slot]	= StringToFloat( values[2] );
		damageChargeThing_DamageSelf[client][slot]	= StringToFloat( values[3] );
		m_bDamageChargeThing_ATTRIBUTE[client][slot]	= true;
		apply = Plugin_Handled;
	}

	if ( !m_bHasAttribute[client][slot] ) m_bHasAttribute[client][slot] = bool:apply;
	return apply;
}
// ====[ ON WEAPON REMOVED ]===========================================
public CW3_OnWeaponRemoved( slot, client )
{
	if ( IsValidClient( client ) )
	{
		if ( m_bHasAttribute[client][slot] )
		{
			new weapon = GetPlayerWeaponSlot( client, slot );
			m_bHasAttribute[client][slot] = false;


			/* On Hit
			 * ---------------------------------------------------------------------- */

			m_bHotSauceOnHit_ATTRIBUTE[client][slot]			= false;
			m_flHotSauceOnHit_Duration[client][slot]			= 0.0;
			m_iHotSauceOnHit_Type[client][slot]					= 0;

			m_bStunOnHit_ATTRIBUTE[client][slot]				= false;
			m_flStunOnHit_Duration[client][slot]				= 0.0;
			m_iStunOnHit_StunLock[client][slot]					= 0;

			m_bDrainUbercharge_ATTRIBUTE[client][slot]			 = false;
			m_flDrainUbercharge_Percentage[client][slot]		= 0.0;

			m_bMetalOnHit_ATTRIBUTE[client][slot]				= false;
			m_iMetalOnHit_Amount[client][slot]					 = 0;

			m_bUberchargeOnHit_ATTRIBUTE[client][slot]			 = false;
			m_flUberchargeOnHit_Amount[client][slot]			= 0.0;

			m_bRemoveBleeding_ATTRIBUTE[client][slot]			= false;

			if ( m_bAfterburnCLOSERANGE_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "Set DamageType Ignite" );
				TF2Attrib_RemoveByName( weapon, "weapon burn time increased" );
				TF2Attrib_RemoveByName( weapon, "weapon burn time reduced" );
			}
			m_bAfterburnCLOSERANGE_ATTRIBUTE[client][slot]		 = false;
			m_flAfterburnCLOSERANGE_Duration[client][slot]		 = 0.0;
			m_flAfterburnCLOSERANGE_Range[client][slot]			= 0.0;

			m_bBleedCLOSERANGE_ATTRIBUTE[client][slot]			 = false;
			m_flBleedCLOSERANGE_Duration[client][slot]			 = 0.0;
			m_flBleedCLOSERANGE_Range[client][slot]				= 0.0;

			m_bMarkVictimDamage_ATTRIBUTE[client][slot]			= false;
			m_flMarkVictimDamage_Duration[client][slot]			= 0.0;
			m_flMarkVictimDamage_Damage[client][slot]			= 0.0;
			m_iMarkVictimDamage_MaximumVictim[client][slot]		= 0;
			m_iMarkVictimDamage_MaximumDamageStack[client][slot]= 0;

			m_bInfiniteAfterburn_ATTRIBUTE[client][slot]		= false;
			m_flInfiniteAfterburn_Duration[client][slot]		= 0.0;
			m_iInfiniteAfterburn_Ressuply[client][slot]			= 0;

			//m_bDeathPact_ATTRIBUTE[client][slot]				 = false;
			//m_flDeathPact_Share[client][slot]					= 0.0;


			/* On Crit
			 * ---------------------------------------------------------------------- */

			m_bHotSauceOnCrit_ATTRIBUTE[client][slot]			= false;
			m_flHotSauceOnCrit_Duration[client][slot]			= 0.0;
			m_iHotSauceOnCrit_Type[client][slot]				= 0;

			m_bStunOnCrit_ATTRIBUTE[client][slot]				= false;
			m_flStunOnCrit_Duration[client][slot]				= 0.0;
			m_iStunOnCrit_StunLock[client][slot]				= 0;

			m_bDrainUberchargeOnCrit_ATTRIBUTE[client][slot]	= false;
			m_flDrainUberchargeOnCrit_Percentage[client][slot]	 = 0.0;

			m_bCritVsInvisiblePlayer_ATTRIBUTE[client][slot]	= false;

			m_bCritVictimInMidAir_ATTRIBUTE[client][slot]		= false;

			m_bCritVictimScared_ATTRIBUTE[client][slot]			= false;

			m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[client][slot]= false;

			m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[client][slot] = false;
			m_flMinicritVsBurningCLOSERANGE_Range[client][slot]	= 0.0;

			m_bCritVsBurningCLOSERANGE_ATTRIBUTE[client][slot]	 = false;
			m_flCritVsBurningCLOSERANGE_Range[client][slot]		= 0.0;

			m_bCritVictimInWater_ATTRIBUTE[client][slot]		= false;


			/* On Attack
			 * ---------------------------------------------------------------------- */

			m_bDamageSelf_ATTRIBUTE[client][slot]	= false;
			m_iDamageSelf_Amount[client][slot]		 = 0;

			m_bMetalPerShot_ATTRIBUTE[client][slot]	= false;
			m_iMetalPerShot_Amount[client][slot]	= 0;

			if ( m_bMCFRTD_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "fire rate penalty" );
			}
			m_bMCFRTD_ATTRIBUTE[client][slot]		= false;
			m_flMCFRTD_AttackSpeed[client][slot]	= 0.0;
			m_flMCFRTD_OldAttackSpeed[client][slot]	= 0.0;
			m_iMCFRTD_MaximumStack[client][slot]	= 0;


			/* On Kill
			 * ---------------------------------------------------------------------- */

			m_bKillGib_ATTRIBUTE[client][slot]				 = false;

			m_bSpawnSkeletonOnKill_ATTRIBUTE[client][slot]	 = false;
			m_flSpawnSkeletonOnKill_Duration[client][slot]	 = 0.0;
			m_iSpawnSkeletonOnKill_Boss[client][slot]		= 0;
			m_flSpawnSkeletonOnKill_BossChance[client][slot]= 0.0;

			if ( m_bAttackSpeedOnKill_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "fire rate bonus" );
			}
			m_bAttackSpeedOnKill_ATTRIBUTE[client][slot]	= false;
			m_flAttackSpeedOnKill_AttackSpeed[client][slot]	= 0.0;
			m_flAttackSpeedOnKill_Removal[client][slot]		= 0.0;
			m_flAttackSpeedOnKill_OldAttackSpeed[client][slot] = 0.0;
			m_iAttackSpeedOnKill_MaximumStack[client][slot]	= 0;

			m_bBANOnKillHit_ATTRIBUTE[client][slot]			= false;
			m_iBANOnKillHit_Duration[client][slot]			 = 0;
			m_iBANOnKillHit_HitOrKill[client][slot]			= 0;
			m_iBANOnKillHit_KickOrBan[client][slot]			= 0;

			m_bTeleportToVictimOnKill_ATTRIBUTE[client][slot]= false;

			m_bScareOnKill_ATTRIBUTE[client][slot]			 = true;
			m_flScareOnKill_Duration[client][slot]			 = 0.0;
			m_flScareOnKill_Radius[client][slot]			= 0.0;
			m_iScareOnKill_StunLock[client][slot]			= 0;




			/* On Damage
			 * ---------------------------------------------------------------------- */

			m_bActualEnemyHealthToDamage_ATTRIBUTE[client][slot]				= false;
			m_flActualEnemyHealthToDamage_Multiplier[client][slot]				 = 0.0;

			m_bActualHealthToDamage_ATTRIBUTE[client][slot]						= false;
			m_flActualHealthToDamage_Multiplier[client][slot]					= 0.0;

			m_bMaximumEnemyHealthToDamage_ATTRIBUTE[client][slot]				= false;
			m_flMaximumEnemyHealthToDamage_Multiplier[client][slot]				= 0.0;

			m_bMaximumHealthToDamage_ATTRIBUTE[client][slot]					= false;
			m_flMaximumHealthToDamage_Multiplier[client][slot]					 = 0.0;

			m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[client][slot]	 = false;
			m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[client][slot]= 0.0;

			m_bMissingEnemyHealthToDamage_ATTRIBUTE[client][slot]				= false;
			m_flMissingEnemyHealthToDamage_Multiplier[client][slot]				= 0.0;

			m_bMissingHealthToDamage_ATTRIBUTE[client][slot]					= false;
			m_flMissingHealthToDamage_Multiplier[client][slot]					 = 0.0;

			m_bDamageDoneIsSelfHurt_ATTRIBUTE[client][slot]						= false;
			damageDoneIsSelfHurt_Multiplier[client][slot]					= 0.0;

			m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[client][slot]		= false;
			damageIfHealthHigherThanThreshold_BonusDamage[client][slot]		= 0.0;
			damageIfHealthHigherThanThreshold_Threshold[client][slot]		= 0.0;

			m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[client][slot]			= false;
			damageIfHealthLowerThanThreshold_BonusDamage[client][slot]		 = 0.0;
			damageIfHealthLowerThanThreshold_Threshold[client][slot]		= 0.0;

			m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[client][slot]	= false;
			damageIfEnemyHealthHigherThanThreshold_BonusDamage[client][slot]= 0.0;
			damageIfEnemyHealthHigherThanThreshold_Threshold[client][slot]	 = 0.0;

			m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[client][slot]	= false;
			damageIfEnemyHealthLowerThanThreshold_BonusDamage[client][slot]	= 0.0;
			damageIfEnemyHealthLowerThanThreshold_Threshold[client][slot]	= 0.0;

			m_bBackstabDamageModSubStun_ATTRIBUTE[client][slot]					= false;
			m_flBackstabDamageModSubStun_Multiplier[client][slot]				= 0.0;
			m_flBackstabDamageModSubStun_Duration[client][slot]					= 0.0;
			m_iBackstabDamageModSubStun_Security[client][slot]					 = 0;
			m_iBackstabDamageModSubStun_BlockSuicide[client][slot]				 = 0;
			m_iBackstabDamageModSubStun_StunLock[client][slot]					 = 0;

			m_bCombo_ATTRIBUTE[client][slot]									= false;
			m_flCombo_BonusDamage[client][slot]									= 0.0;
			m_iCombo_Hit[client][slot]											 = 0;
			m_iCombo_Crit[client][slot]											= 0;

			m_bMovementSpeedToDamage_ATTRIBUTE[client][slot]					= false;
			m_flMovementSpeedToDamage_Multiplier[client][slot]					 = 0.0;

			m_bMetalToDamage_ATTRIBUTE[client][slot]							= false;
			m_flMetalToDamage_Multiplier[client][slot]							 = 0.0;

			m_bDamageWhenMetalRunsOut_ATTRIBUTE[client][slot]					= false;
			damageWhenMetalRunsOut_Damage[client][slot]						= 0.0;

			m_bMetalOnHitDamage_ATTRIBUTE[client][slot]							= false;
			m_flMetalOnHitDamage_Multiplier[client][slot]						= 0.0;

			if ( m_bBonusDamageVsSapper_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "dmg penalty vs buildings" );
			}
			m_bBonusDamageVsSapper_ATTRIBUTE[client][slot]						 = false;
			m_flBonusDamageVsSapper_Multiplier[client][slot]					= 0.0;

			m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[client][slot]				 = false;
			m_flBonusDamageVSVictimInMidAir_Multiplier[client][slot]			= 0.0;

			m_bDamageClass_ATTRIBUTE[client][slot]								 = false;
			damageClass_Scout[client][slot]									= 0.0;
			damageClass_Soldier[client][slot]								= 0.0;
			damageClass_Pyro[client][slot]									 = 0.0;
			damageClass_Demoman[client][slot]								= 0.0;
			damageClass_Heavy[client][slot]									= 0.0;
			damageClass_Engineer[client][slot]								 = 0.0;
			damageClass_Medic[client][slot]									= 0.0;
			damageClass_Sniper[client][slot]								= 0.0;
			damageClass_Spy[client][slot]									= 0.0;

			m_bBonusDamageVsVictimInWater_ATTRIBUTE[client][slot]				= false;
			m_flBonusDamageVSVictimInWater_Multiplier[client][slot]				= 0.0;

			m_bAllDamageDoneMultiplier_ATTRIBUTE[client][slot]					 = false;
			m_flAllDamageDoneMultiplier_Multiplier[client][slot]				= 0.0;

			m_bRandomDamage_ATTRIBUTE[client][slot]								= false;
			m_flRandomDamage_Min[client][slot]									 = 0.0;
			m_flRandomDamage_Max[client][slot]									 = 0.0;

			m_bLaserWeaponDamageModifier_ATTRIBUTE[client][slot]				= false;
			m_flLaserWeaponDamageModifier_Damage[client][slot]					 = 0.0;

			m_bStealDamage_ATTRIBUTE[client][slot]								 = false;
			m_flStealDamage_Steal[client][slot]									= 0.0;
			m_flStealDamage_Duration[client][slot]								 = 0.0;
			m_iStealDamage_Pct[client][slot]										 = 0;

			m_bDamageChargeThing_ATTRIBUTE[client][slot]						= false;
			damageChargeThing_Charge[client][slot]							 = 0.0;
			damageChargeThing_Damage[client][slot]							 = 0.0;
			damageChargeThing_DeCharge[client][slot]						= 0.0;
			damageChargeThing_DamageSelf[client][slot]						 = 0.0;


			/* Heal
			 * ---------------------------------------------------------------------- */

			m_bHealthLifesteal_ATTRIBUTE[client][slot]					 = false;
			m_flHealthLifesteal_Multiplier[client][slot]				= 0.0;
			m_flHealthLifesteal_OverHealBonusCap[client][slot]			 = 0.0;

			m_bEnemyHealthLifesteal_ATTRIBUTE[client][slot]				= false;
			m_flEnemyHealthLifesteal_Multiplier[client][slot]			= 0.0;
			m_flEnemyHealthLifesteal_OverHealBonusCap[client][slot]		= 0.0;

			m_bMissingEnemyHealthLifesteal_ATTRIBUTE[client][slot]		 = false;
			m_flMissingEnemyHealthLifesteal_Multiplier[client][slot]	= 0.0;
			m_flMissingEnemyHealthLifesteal_OverHealBonusCap[client][slot] = 0.0;


			/* On Prethink
			 * ---------------------------------------------------------------------- */

			m_bMetalDrain_ATTRIBUTE[client][slot]				= false;
			m_iMetalDrain_Amount[client][slot]					 = 0;
			m_flMetalDrain_Interval[client][slot]				= 0.0;
			m_iMetalDrain_PoA[client][slot]						= 0;

			m_bBerserker_ATTRIBUTE[client][slot]				= false;
			m_flBerserker_Duration[client][slot]				= 0.0;
			m_flBerserker_Threshold[client][slot]				= 0.0;

			m_bLowBerserker_ATTRIBUTE[client][slot]				= false;
			m_flLowBerserker_Duration[client][slot]				= 0.0;
			m_flLowBerserker_Threshold[client][slot]			= 0.0;
			m_iLowBerserker_Kill[client][slot]					 = 0;

			if ( m_bHeatFireRate_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "fire rate bonus" );
			}
			m_bHeatFireRate_ATTRIBUTE[client][slot]				= false;
			m_flHeatFireRate_AttackSpeed[client][slot]			 = 0.0;
			m_flHeatFireRate_Delay[client][slot]				= 0.0;
			m_flHeatFireRate_OldAttackSpeed[client][slot]		= 0.0;
			m_iHeatFireRate_MaximumStack[client][slot]			 = 0;

			m_bHeatDMGTaken_ATTRIBUTE[client][slot]				= false;
			m_flHeatDMGTaken_DMG[client][slot]					 = 0.0;
			m_flHeatDMGTaken_Delay[client][slot]				= 0.0;
			m_iHeatDMGTaken_MaximumStack[client][slot]			 = 0;

			m_bHomingProjectile_ATTRIBUTE[client][slot]			= false;
			m_flHomingProjectile_DetectRadius[client][slot]		= 0.0;
			m_iHomingProjectile_Mode[client][slot]				 = 0;
			m_iHomingProjectile_Type[client][slot]				 = 0;

			m_bDemoCharge_DamageReduction_ATTRIBUTE[client][slot]= false;

			m_bDemoCharge_HealthThreshold_ATTRIBUTE[client][slot]= false;
			m_flDemoCharge_HealthThreshold_Threshold[client][slot] = 0.0;
			m_iDemoCharge_HealthThreshold_Mode[client][slot]	= 0;

			m_bFragmentation_ATTRIBUTE[client][slot]			= false;
			m_flFragmentation_Damage[client][slot]				 = 0.0;
			m_flFragmentation_Radius[client][slot]				 = 0.0;
			m_iFragmentation_Mode[client][slot]					= 0;
			m_iFragmentation_Amount[client][slot]				= 0;

			m_bDamageResistanceInvisible_ATTRIBUTE[client][slot]= false;
			damageResistanceInvisible_Multiplier[client][slot] = 0.0;

			m_bSpyDetector_ATTRIBUTE[client][slot]				 = false;
			m_flSpyDetector_Radius[client][slot]				= 0.0;
			m_iSpyDetector_Type[client][slot]					= 0;
			m_iSpyDetector_ActivePassive[client][slot]			 = 0;

			m_bBuffStuff_ATTRIBUTE[client][slot]				= false;
			m_iBuffStuff_ID[client][slot]						= 0;
			m_iBuffStuff_ID2[client][slot]						 = 0;
			m_iBuffStuff_ID3[client][slot]						 = 0;
			m_iBuffStuff_ID4[client][slot]						 = 0;
			m_flBuffStuff_Radius[client][slot]					 = 0.0;
			m_iBuffStuff_Mode[client][slot]						= 0;

			m_bCannotBeStunned_ATTRIBUTE[client][slot]			 = false;
			m_iCannotBeStunned_Type[client][slot]				= 0;

			m_bDisableUbercharge_ATTRIBUTE[client][slot]		= false;

			m_bSetWeaponSwitch_ATTRIBUTE[client][slot]			 = false;
			m_iSetWeaponSwith_Slot[client][slot]				= 0;

			if ( m_bBulletsPerShotBonusDynamic_ATTRIBUTE[client][slot] && IsValidEdict( weapon ) && IsValidEntity( weapon ) )
			{
				TF2Attrib_RemoveByName( weapon, "bullets per shot bonus" );
			}
			m_bBulletsPerShotBonusDynamic_ATTRIBUTE[client][slot]= false;


			/* On Chance
			 * ---------------------------------------------------------------------- */

			m_bChanceOneShot_ATTRIBUTE[client][slot]= false;
			m_flChanceOneShot_Chance[client][slot]	 = 0.0;

			m_bChanceIgnite_ATTRIBUTE[client][slot]	= false;
			m_flChanceIgnite_Chance[client][slot]	= 0.0;
			m_flChanceIgnite_Duration[client][slot]	= 0.0;

			m_bChanceMadMilk_ATTRIBUTE[client][slot]= false;
			m_flChanceMadMilk_Chance[client][slot]	 = 0.0;
			m_flChanceMadMilk_Duration[client][slot]= 0.0;

			m_bChanceJarate_ATTRIBUTE[client][slot]	= false;
			m_flChanceJarate_Chance[client][slot]	= 0.0;
			m_flChanceJarate_Duration[client][slot]	= 0.0;

			m_bChanceBleed_ATTRIBUTE[client][slot]	 = false;
			m_flChanceBleed_Chance[client][slot]	= 0.0;
			m_flChanceBleed_Duration[client][slot]	 = 0.0;
			m_iChanceBleed_Stack[client][slot]		 = 0;


			/* On Damage Received
			 * ---------------------------------------------------------------------- */

			m_bDamageReceivedUnleashedDeath_ATTRIBUTE[client][slot]		= false;
			damageReceivedUnleashedDeath_Percentage[client][slot]	= 0.0;
			damageReceivedUnleashedDeath_Radius[client][slot]		= 0.0;
			m_iDamageReceivedUnleashedDeath_PoA[client][slot]			= 0;
			m_iDamageReceivedUnleashedDeath_Backstab[client][slot]		 = 0;

			m_bReduceBackstabDamage_ATTRIBUTE[client][slot]				= false;
			m_flReduceBackstabDamage_Percentage[client][slot]			= 0.0;
			m_iReduceBackstabDamage_ActOrMax[client][slot]				 = 0;

			m_bReduceHeadshotDamage_ATTRIBUTE[client][slot]				= false;
			m_flReduceHeadshotDamage_Percentage[client][slot]			= 0.0;

			m_bDamageResHealthMissing_ATTRIBUTE[client][slot]			= false;
			damageResHealthMissing_ResPctPerMissingHpPct[client][slot] = 0.0;
			m_iDamageResHealthMissing_MaxStackOfMissingHpPct[client][slot] = 0;
			m_iDamageResHealthMissing_OverhealPenalty[client][slot]		= 0;
			m_iDamageResHealthMissing_Active[client][slot]			= 0;


			/* To Activate
			 * ---------------------------------------------------------------------- */

			m_bPsycho_ATTRIBUTE[client][slot]		= false;
			m_flPsycho_Duration[client][slot]		= 0.0;
			m_flPsycho_DamageResistance[client][slot]= 0.0;
			m_flPsycho_DamageBonus[client][slot]	= 0.0;
			m_flPsycho_RegenPct[client][slot]		= 0.0;
			m_iPsycho_Melee[client][slot]			= 0;
		}
	}
}

// ====[ ON TAKE DAMAGE ]==============================================
public Action:OnTakeDamage( victim, &attacker, &inflictor, &Float:damage, &damage_type, &weapon, Float:damage_force[3], Float:damage_pos[3], damage_custom )
{
	new Action:apply;

	if ( damage >= 1.0 )
	{
		if ( IsValidClient( victim ) )
		{
			if ( HasAttribute( victim, _, m_bPsycho_ATTRIBUTE ) && m_hTimers[victim][m_hPsycho_TimerDuration] != INVALID_HANDLE && GetAttributeValueF( victim, _, m_bPsycho_ATTRIBUTE, m_flPsycho_DamageResistance ) <= 0.0 )
				damage = 0.0;
		//-//
			if ( HasAttribute( victim, _, m_bDamageResistanceInvisible_ATTRIBUTE ) && TF2_IsPlayerInCondition( victim, TFCond_Cloaked ) && GetAttributeValueF( victim, _, m_bDamageResistanceInvisible_ATTRIBUTE, damageResistanceInvisible_Multiplier ) <= 0.0 )
				damage = 0.0;
		//-//
			if ( HasAttribute( victim, _, m_bMarkVictimDamage_ATTRIBUTE ) && IsValidClient( attacker ) && m_hTimers[attacker][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE && ( GetAttributeValueF( victim, _, m_bMarkVictimDamage_ATTRIBUTE, m_flMarkVictimDamage_Damage ) * m_iIntegers[attacker][m_iMarkVictimDamageCount] ) >= 1.0 )
				damage = 0.0;
		//-//
			if ( HasAttribute( victim, _, m_bReduceBackstabDamage_ATTRIBUTE ) && damage_custom == TF_CUSTOM_BACKSTAB && GetAttributeValueF( victim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_flReduceBackstabDamage_Percentage ) <= 0.0 )
				damage = 0.0;
		//-//
			if ( HasAttribute( victim, _, m_bReduceHeadshotDamage_ATTRIBUTE ) && GetAttributeValueF( victim, _, m_bReduceHeadshotDamage_ATTRIBUTE, m_flReduceHeadshotDamage_Percentage ) <= 0.0 ) {
				if ( damage_custom == TF_CUSTOM_HEADSHOT || damage_custom == TF_CUSTOM_HEADSHOT_DECAPITATION )
					damage = 0.0;
			}
		//-//
			if ( HasAttribute( victim, _, m_bDamageResHealthMissing_ATTRIBUTE ) && GetAttributeValueF( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, damageResHealthMissing_ResPctPerMissingHpPct ) * ( GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct ) + 0.0 < ( 1.0 - FloatDiv( GetClientHealth( victim ) + 0.0, TF2_GetClientMaxHealth( victim ) + 0.0 ) ) * 100.0 ? GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct ) + 0.0 : ( 1.0 - FloatDiv( GetClientHealth( victim ) + 0.0, TF2_GetClientMaxHealth( victim ) + 0.0 ) ) * 100.0 ) >= 100 )
				damage = 0.0;
		//-//
			if ( HasAttribute( victim, _, m_bHeatDMGTaken_ATTRIBUTE, true ) && 1 + ( m_iIntegers[victim][m_iHeatToo] * GetAttributeValueF( victim, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_DMG, true ) ) <= 0.0 )
				damage = 0.0;
		}

		if ( damage >= 1.0 )
		{
			if ( IsValidClient( attacker ) )
			{
				if ( IsValidClient( victim )
					&& !HasInvulnerabilityCond( victim )
					&& attacker != victim
					&& GetClientTeam( attacker ) != GetClientTeam (victim ) )
				{
					if ( weapon != -1 )
					{
						new slot = TF2_GetWeaponSlot( attacker, weapon );
						g_iLastWeapon[attacker] = weapon;
						if ( slot != -1 && m_bHasAttribute[attacker][slot] )
						{

							/* Mutiplies and Divides.
							 *
							 * -------------------------------------------------- */
							if ( m_bDamageIfHealthLowerThanThreshold_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( attacker ) <= damageIfHealthLowerThanThreshold_Threshold[attacker][slot] * TF2_GetClientMaxHealth( attacker ) )
									damage *= damageIfHealthLowerThanThreshold_BonusDamage[attacker][slot];
							}
						//-//
							if ( m_bDamageIfHealthHigherThanThreshold_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( attacker ) >= damageIfHealthHigherThanThreshold_Threshold[attacker][slot] * TF2_GetClientMaxHealth( attacker ) )
									damage *= damageIfHealthHigherThanThreshold_BonusDamage[attacker][slot];
							}
						//-//
							if ( m_bDamageIfEnemyHealthLowerThanThreshold_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( victim ) <= damageIfEnemyHealthLowerThanThreshold_Threshold[attacker][slot] * TF2_GetClientMaxHealth( victim ) )
									damage *= damageIfEnemyHealthLowerThanThreshold_BonusDamage[attacker][slot];
							}
						//-//
							if ( m_bDamageIfEnemyHealthHigherThanThreshold_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( victim ) >= damageIfEnemyHealthHigherThanThreshold_Threshold[attacker][slot] * TF2_GetClientMaxHealth( victim ) )
									damage *= damageIfEnemyHealthHigherThanThreshold_BonusDamage[attacker][slot];
							}
						//-//
							if ( m_bDamageWhenMetalRunsOut_ATTRIBUTE[attacker][slot] )
							{
								if ( TF2_GetClientMetal( attacker ) <= 0 )
									damage *= damageWhenMetalRunsOut_Damage[attacker][slot];
							}
						//-//
							if ( m_bBonusDamageVsVictimInMidAir_ATTRIBUTE[attacker][slot] )
							{
								if ( !( GetEntityFlags( victim ) & FL_ONGROUND ) && !( GetEntityFlags( victim ) & FL_INWATER ) )
									damage *= m_flBonusDamageVSVictimInMidAir_Multiplier[attacker][slot];
							}
						//-//
							if ( m_bDamageClass_ATTRIBUTE[attacker][slot] )
							{
								if ( TF2_GetPlayerClass( victim ) == TFClass_Scout )	 damage *= damageClass_Scout[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Soldier )damage *= damageClass_Soldier[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Pyro )	damage *= damageClass_Pyro[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_DemoMan )damage *= damageClass_Demoman[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Heavy )	 damage *= damageClass_Heavy[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Engineer )damage *= damageClass_Engineer[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Medic )	 damage *= damageClass_Medic[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Sniper )	damage *= damageClass_Sniper[attacker][slot];
								if ( TF2_GetPlayerClass( victim ) == TFClass_Spy )	damage *= damageClass_Spy[attacker][slot];
							}
						//-//
							if ( m_bPsycho_ATTRIBUTE[attacker][slot] && m_hTimers[attacker][m_hPsycho_TimerDuration] != INVALID_HANDLE ) {
								damage *= m_flPsycho_DamageBonus[attacker][slot];
							}
						//-//
							if ( m_bBonusDamageVsVictimInWater_ATTRIBUTE[attacker][slot] )
							{
								if ( GetEntityFlags( victim ) & FL_INWATER )
									damage *= m_flBonusDamageVSVictimInWater_Multiplier[attacker][slot];
							}
						//-//
							if ( m_bRandomDamage_ATTRIBUTE[attacker][slot] ) {
								damage *= GetRandomFloat( m_flRandomDamage_Min[attacker][slot], m_flRandomDamage_Max[attacker][slot] );
							}
						//-//
							if ( m_bLaserWeaponDamageModifier_ATTRIBUTE[attacker][slot] && damage_type & TF_DMG_LASER ) {
								damage *= m_flLaserWeaponDamageModifier_Damage[attacker][slot];
							}
							
							/* Adds and Subtracts.
							 *
							 * -------------------------------------------------- */
							if ( m_bCombo_ATTRIBUTE[attacker][slot] )
							{
								m_iIntegers[victim][m_iCombo]++;

								if ( m_iIntegers[victim][m_iCombo] >= m_iCombo_Hit[attacker][slot] ) 
								{
									if ( m_flCombo_BonusDamage[attacker][slot] <= 10.0 ) damage *= m_flCombo_BonusDamage[attacker][slot];
									else damage += m_flCombo_BonusDamage[attacker][slot];
									if ( m_iCombo_Crit[attacker][slot] == 1 ) damage_type = TF_DMG_CRIT|damage_type;
									m_iIntegers[victim][m_iCombo] = 0;
								}
							}
						//-//
							if ( m_bActualEnemyHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								new Float:m_flBonus = GetClientHealth( victim ) * m_flActualEnemyHealthToDamage_Multiplier[attacker][slot];
								damage += m_flBonus;
							}
						//-//
							if ( m_bActualHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								new Float:m_flBonus = GetClientHealth( attacker ) * m_flActualHealthToDamage_Multiplier[attacker][slot];
								damage += m_flBonus;
							}
						//-//
							if ( m_bMaximumEnemyHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								new Float:m_flBonus = TF2_GetClientMaxHealth( victim ) * m_flMaximumEnemyHealthToDamage_Multiplier[attacker][slot];
								damage += m_flBonus;
							}
						//-//
							if ( m_bMaximumHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								new Float:m_flBonus = TF2_GetClientMaxHealth( attacker ) * m_flMaximumHealthToDamage_Multiplier[attacker][slot];
								damage += m_flBonus;
							}
						//-//
							if ( m_bMissingHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( attacker ) < TF2_GetClientMaxHealth( attacker ) )
									damage += ( ( TF2_GetClientMaxHealth( attacker ) - GetClientHealth( attacker ) ) * m_flMissingHealthToDamage_Multiplier[attacker][slot] );
							}
						//-//
							if ( m_bMissingEnemyHealthToDamage_ATTRIBUTE[attacker][slot] )
							{
								if ( GetClientHealth( victim ) < TF2_GetClientMaxHealth( victim ) )
									damage += ( ( TF2_GetClientMaxHealth( victim ) - GetClientHealth( victim ) ) * m_flMissingEnemyHealthToDamage_Multiplier[attacker][slot] );
							}
						//-//
							if ( m_bMovementSpeedToDamage_ATTRIBUTE[attacker][slot] ) {
								damage += ( GetClientMovementSpeed( attacker ) * m_flMovementSpeedToDamage_Multiplier[attacker][slot] );
							}
						//-//
							if ( m_bMetalToDamage_ATTRIBUTE[attacker][slot] ) {
								damage += ( TF2_GetClientMetal( attacker ) * m_flMetalToDamage_Multiplier[attacker][slot] );
							}
						//-//
							if ( m_bStealDamage_ATTRIBUTE[attacker][slot] ) {
								if ( m_flFloats[attacker][m_flStealDamageAttacker] )
								{
									if ( m_bBools[attacker][m_bStealPct] == true )
										damage *= ( 1 + m_flFloats[attacker][m_flStealDamageAttacker] );
									else
										damage += m_flFloats[attacker][m_flStealDamageAttacker];
								}
							}
						//-//
							if ( m_bDamageChargeThing_ATTRIBUTE[attacker][slot] )
							{
								if ( m_bBools[attacker][m_bDamageChargeThing_Enable] )
								{
									new Float:old_charge = m_flFloats[attacker][damageCharge];
									new Float:diff;

									m_flFloats[attacker][damageCharge] -= damageChargeThing_DeCharge[attacker][slot];
									if ( m_flFloats[attacker][damageCharge] < 0.0 ) m_flFloats[attacker][damageCharge] = 0.0;
									diff = old_charge - m_flFloats[attacker][damageCharge];

									DealDamage( attacker, RoundToFloor( damageChargeThing_DamageSelf[attacker][slot] * diff ), attacker, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
									damage += ( diff * damageChargeThing_Damage[attacker][slot] );
								}
							}

							/* Sets.
							 *
							 * -------------------------------------------------- */
							if ( m_bBackstabDamageModSubStun_ATTRIBUTE[attacker][slot] && damage_custom == TF_CUSTOM_BACKSTAB )
							{
								if ( TF2_GetPlayerClass( attacker ) == TFClass_Spy )
								{
									new Float:duration = m_flBackstabDamageModSubStun_Duration[attacker][slot];

									damage = RoundToCeil( ( TF2_GetClientMaxHealth( victim ) < GetClientHealth( victim ) ? GetClientHealth( victim ) : TF2_GetClientMaxHealth( victim ) ) * m_flBackstabDamageModSubStun_Multiplier[attacker][slot] ) / 3.0;

									if ( duration != 0.0 )
									{
										if ( m_hTimers[victim][m_hStunlock_TimerDelay] == INVALID_HANDLE )
										{
											if ( m_iBackstabDamageModSubStun_StunLock[attacker][slot] == 1 ) m_hTimers[victim][m_hStunlock_TimerDelay] = CreateTimer( duration * 2.0, m_tStunLock, victim );
											if ( m_iBackstabDamageModSubStun_BlockSuicide[attacker][slot] == 1 ) m_bBools[victim][m_bBackstab_SuicideBlocker] = true;
				 
											new Float:m_flDuration;
											if ( m_iIntegers[victim][m_iOPBackstab] != 0 ) m_flDuration = duration / ( 2*m_iIntegers[victim][m_iOPBackstab] );
											else m_flDuration = duration;

											if ( m_iBackstabDamageModSubStun_Security[attacker][slot] == 1 ) {

												if ( m_flDuration >= 10.0 ) m_iIntegers[victim][m_iOPBackstab]++;
											}
											TF2_StunPlayer( victim, m_flDuration, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker );

											EmitSoundToClient( attacker, SOUND_TBASH, _, _, _, _, 0.375 );
											EmitSoundToClient( victim, SOUND_TBASH, _, _, _, _, 0.75 );
										}
									}
								}
							}
						//-//
							if ( m_bChanceOneShot_ATTRIBUTE[attacker][slot] )
							{
								if ( m_flChanceOneShot_Chance[attacker][slot] >= GetRandomFloat( 0.0, 1.0 ) )
								{
									damage = GetClientHealth( victim ) * 8.0;
									damage_type = TF_DMG_CRIT|damage_type;
								}
							}
						//-//
							if ( m_bMissingEnemyHealthToDamage_FLAMETHROWER_ATTRIBUTE[attacker][slot] )
							{
								new Float:mult = m_flMissingEnemyHealthToDamage_FLAMETHROWER_Multiplier[attacker][slot];

								if ( GetClientHealth( victim ) >= ( TF2_GetClientMaxHealth( victim ) - ( 1 / mult ) ) )
								{
									new Float:m_flHPDiff = ( GetClientHealth( victim ) - ( TF2_GetClientMaxHealth( victim ) - ( 1 / mult ) ) ) / 22.5; //22.5 particle/s
									if ( m_flHPDiff < 1.0 ) m_flHPDiff = 1.0;

									if ( TF2_GetPlayerClass( victim ) == TFClass_Pyro ) damage = m_flHPDiff * 2;
									else damage = m_flHPDiff;
								} else {
									if ( TF2_GetPlayerClass( victim ) == TFClass_Pyro ) damage = ( ( TF2_GetClientMaxHealth( victim ) - GetClientHealth( victim ) ) * mult ) * 2;
									else damage = ( ( TF2_GetClientMaxHealth( victim ) - GetClientHealth( victim ) ) * mult );
								}
							}
							
							/* Critical.
							 *
							 * -------------------------------------------------- */
							if ( m_bCritVsInvisiblePlayer_ATTRIBUTE[attacker][slot] && !( damage_type & TF_DMG_CRIT ) )
							{
								if ( TF2_IsPlayerInCondition( victim, TFCond_Cloaked ) ||
									TF2_IsPlayerInCondition( victim, TFCond_CloakFlicker ) ||
									TF2_IsPlayerInCondition( victim, TFCond_Stealthed ) ||
									TF2_IsPlayerInCondition( victim, TFCond_StealthedUserBuffFade ) )
									damage_type = TF_DMG_CRIT|damage_type;
							}
						//-//
							if ( m_bCritVictimInMidAir_ATTRIBUTE[attacker][slot] && !( damage_type & TF_DMG_CRIT ) )
							{
								if ( !( GetEntityFlags( victim ) & FL_ONGROUND ) && !( GetEntityFlags( victim ) & FL_INWATER ) )
									damage_type = TF_DMG_CRIT|damage_type;
							}
						//-//
							if ( m_bCritVictimScared_ATTRIBUTE[attacker][slot] && !( damage_type & TF_DMG_CRIT ) )
							{
								if ( GetEntProp( victim, Prop_Send, "m_iStunFlags" ) == TF_STUNFLAGS_GHOSTSCARE )
									damage_type = TF_DMG_CRIT|damage_type;
							}
						//-//
							if ( m_bCritVictimInWater_ATTRIBUTE[attacker][slot] && !( damage_type & TF_DMG_CRIT ) )
							{
								if ( GetEntityFlags( victim ) & FL_INWATER ) damage_type = TF_DMG_CRIT|damage_type;
							}
						//-//
							if ( m_bCritVsBurningCLOSERANGE_ATTRIBUTE[attacker][slot] && !( damage_type & TF_DMG_CRIT ) )
							{
								new Float:m_flPos1[3], Float:m_flPos2[3];
								GetClientAbsOrigin( attacker, m_flPos1 );
								GetClientAbsOrigin( victim, m_flPos2 );

								new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
								if ( distance <= m_flCritVsBurningCLOSERANGE_Range[attacker][slot] )
								{
									if ( TF2_IsPlayerInCondition( victim, TFCond_OnFire ) ) damage_type = TF_DMG_CRIT|damage_type;
								}
							}
						//-//
							if ( m_bMinicritVsBurningCLOSERANGE_ATTRIBUTE[attacker][slot] )
							{
								new Float:m_flPos1[3], Float:m_flPos2[3];
								GetClientAbsOrigin( attacker, m_flPos1 );
								GetClientAbsOrigin( victim, m_flPos2 );

								new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
								if ( distance <= m_flMinicritVsBurningCLOSERANGE_Range[attacker][slot] )
								{
									if ( TF2_IsPlayerInCondition( victim, TFCond_OnFire ) ) TF2_AddCondition( attacker, TFCond_Buffed, 0.01 );
								}
							}
						//-//
							if ( m_bMiniCritVsInvisiblePlayer_ATTRIBUTE[attacker][slot] )
							{
								if ( TF2_IsPlayerInCondition( victim, TFCond_Cloaked ) || TF2_IsPlayerInCondition( victim, TFCond_CloakFlicker ) ||
									TF2_IsPlayerInCondition( victim, TFCond_Stealthed ) || TF2_IsPlayerInCondition( victim, TFCond_StealthedUserBuffFade ) )
									TF2_AddCondition( attacker, TFCond_Buffed, 0.01 );
							}
						}
						if ( m_flFloats[attacker][m_flStealDamageVictim] != 0.0 )
						{
							if ( m_bBools[attacker][m_bStealPct] == true )
								damage /= ( 1 + m_flFloats[attacker][m_flStealDamageVictim] );
							else
								damage -= m_flFloats[attacker][m_flStealDamageVictim];
						}
					}
					
					/* All damage done multiplier.
					 *
					 * ---------------------------------------------------------- */
					if ( HasAttribute( attacker, _, m_bAllDamageDoneMultiplier_ATTRIBUTE ) ) {
						damage *= GetAttributeValueF( attacker, _, m_bAllDamageDoneMultiplier_ATTRIBUTE, m_flAllDamageDoneMultiplier_Multiplier );
					}
				}

				if ( HasAttribute( attacker, _, m_bBonusDamageVsSapper_ATTRIBUTE, true ) )
				{
					decl String:m_sNetClass[32];
					GetEntityNetClass( victim, m_sNetClass, sizeof( m_sNetClass ) );

					if ( StrEqual( m_sNetClass, "CObjectSapper" ) ) TF2Attrib_SetByName( weapon, "dmg bonus vs buildings", GetAttributeValueF( attacker, _, m_bBonusDamageVsSapper_ATTRIBUTE, m_flBonusDamageVsSapper_Multiplier, true ) );
				}
			}

			if ( IsValidClient( victim ) )
			{
				if ( HasAttribute( victim, _, m_bPsycho_ATTRIBUTE ) && m_hTimers[victim][m_hPsycho_TimerDuration] != INVALID_HANDLE )
					damage *= GetAttributeValueF( victim, _, m_bPsycho_ATTRIBUTE, m_flPsycho_DamageResistance );
			//-//
				if ( HasAttribute( victim, _, m_bDamageResistanceInvisible_ATTRIBUTE ) && TF2_IsPlayerInCondition( victim, TFCond_Cloaked ) )
					damage *= GetAttributeValueF( victim, _, m_bDamageResistanceInvisible_ATTRIBUTE, damageResistanceInvisible_Multiplier );
			//-//
				if ( HasAttribute( victim, _, m_bMarkVictimDamage_ATTRIBUTE ) && IsValidClient( attacker ) && m_hTimers[attacker][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
				{
					new Float:m_flAdd = GetAttributeValueF( victim, _, m_bMarkVictimDamage_ATTRIBUTE, m_flMarkVictimDamage_Damage ) * m_iIntegers[attacker][m_iMarkVictimDamageCount];
					damage *= ( 1-m_flAdd );
				}
			//-//
				if ( HasAttribute( victim, _, m_bReduceHeadshotDamage_ATTRIBUTE ) )
				{
					if ( damage_custom == TF_CUSTOM_HEADSHOT || damage_custom == TF_CUSTOM_HEADSHOT_DECAPITATION )
						damage *= GetAttributeValueF( victim, _, m_bReduceHeadshotDamage_ATTRIBUTE, m_flReduceHeadshotDamage_Percentage );
				}
			//-//
				if ( HasAttribute( victim, _, m_bReduceBackstabDamage_ATTRIBUTE ) && damage_custom == TF_CUSTOM_BACKSTAB )
				{
					new actmax = GetAttributeValueI( victim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_iReduceBackstabDamage_ActOrMax );
					new Float:pct = GetAttributeValueF( victim, _, m_bReduceBackstabDamage_ATTRIBUTE, m_flReduceBackstabDamage_Percentage );

					damage = ( ( actmax > 1 ? TF2_GetClientMaxHealth( victim ) : GetClientHealth( victim ) ) * 2.0 ) * pct;
				}
			//-//
				if ( HasAttribute( victim, _, m_bDamageResHealthMissing_ATTRIBUTE ) )
				{
					if ( GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_Active ) == 1 && HasAttribute( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, true )
						|| GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_Active ) == 0 )
					{
						new overheal = GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_OverhealPenalty );
						new Float:res = GetAttributeValueF( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, damageResHealthMissing_ResPctPerMissingHpPct );
						new stack = GetAttributeValueI( victim, _, m_bDamageResHealthMissing_ATTRIBUTE, m_iDamageResHealthMissing_MaxStackOfMissingHpPct );

						new Float:m_flMHP = 1-( FloatDiv( GetClientHealth( victim )+0.0, TF2_GetClientMaxHealth( victim )+0.0 ) );
						if ( GetClientHealth( victim ) > TF2_GetClientMaxHealth( victim ) && overheal == 0 ) m_flMHP = 0.0;

						new Float:m_flResPct = res * m_flMHP;
						if ( m_flMHP * 100.0 > stack ) m_flResPct = res * FloatDiv( stack+0.0, 100.0 );
						damage *= ( 1-m_flResPct );
					}
				}
			//-//
				if ( HasAttribute( victim, _, m_bHeatDMGTaken_ATTRIBUTE, true ) )
					damage *= ( 1 + ( m_iIntegers[victim][m_iHeatToo] * GetAttributeValueF( victim, _, m_bHeatDMGTaken_ATTRIBUTE, m_flHeatDMGTaken_DMG, true ) ) );
			}
		}
	}
	if ( damage < 0.0 ) damage == 0.0;

	apply = Plugin_Changed;
	return apply;
}

// ====[ ON TAKE DAMAGE ALIVE ]========================================
public Action:OnTakeDamageAlive( victim, &attacker, &inflictor, &Float:damage, &damage_type, &weapon, Float:damage_force[3], Float:damage_pos[3], damage_custom )
{
	new Action:apply;

	if ( damage >= 1.0
		&& IsValidClient( attacker ) )
	{
		if ( IsValidClient( victim )
			&& !HasInvulnerabilityCond( victim ) )
		{
			if ( victim != attacker )
			{
				if ( damage_type & TF_DMG_BLEED == TF_DMG_BLEED && m_iIntegers[victim][m_iHotSauceType] != 0 && TF2_IsPlayerInCondition( victim, TFCond_Bleeding ) && TF2_IsPlayerInCondition( victim, TFCond_Milked ) )
					TF2_HealPlayer( attacker, damage, 0.6666666667, true );

				if ( HasAttribute( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
				{
					new active	= GetAttributeValueI( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_iDamageReceivedUnleashedDeath_PoA );
					new Float:pct = GetAttributeValueF( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, damageReceivedUnleashedDeath_Percentage );
					new backstab= GetAttributeValueI( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, m_iDamageReceivedUnleashedDeath_Backstab );

					if ( backstab == 0 || backstab == 1 && damage_custom != TF_CUSTOM_BACKSTAB)
					{
						if ( active == 0 || HasAttribute( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, true ) && active == 1 )
						{
							new Float:damage_t = damage * pct;
							m_flFloats[victim][damageReceived] += damage_t;

							for ( new particles = 0; particles < ( 25.0 > damage_t / 4.0 ? damage_t / 4.0 : 25.0 ) ; particles++ )
							{
								new Float:w[3];
								new Float:rnd_t = GetRandomFloat( damage_t / 30.0, damage_t / 15.0 );
								if ( rnd_t < 1.0 ) rnd_t = 1.0;
								if ( rnd_t > 4.0 ) rnd_t = 4.0;

								w[0] += GetRandomFloat( -20.0, 20.0 );
								w[1] += GetRandomFloat( -20.0, 20.0 );
								w[2] += GetRandomFloat( 5.0, 70.0 );
								AttachParticle( victim, "sapper_sentry1_fx", rnd_t, w, w );
							}
						}
					}
				}
			}

			if ( weapon != -1 )
			{
				new slot = TF2_GetWeaponSlot( attacker, weapon );
				if ( slot != -1 && m_bHasAttribute[attacker][slot] )
				{
					if ( damage_type & TF_DMG_CRIT || IsCritBoosted( attacker ) )
					{
						if ( m_bStunOnCrit_ATTRIBUTE[attacker][slot] )
						{
							if ( m_hTimers[victim][m_hStunlock_TimerDelay] == INVALID_HANDLE )
							{
								new Float:duration = m_flStunOnCrit_Duration[attacker][slot];
								if ( m_iStunOnCrit_StunLock[attacker][slot] == 1 ) m_hTimers[victim][m_hStunlock_TimerDelay] = CreateTimer( duration * 2.0, m_tStunLock, victim );
										
								TF2_StunPlayer( victim, duration, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker );
								EmitSoundToClient( attacker, SOUND_TBASH, _, _, _, _, 0.25 );
								EmitSoundToClient( victim, SOUND_TBASH, _, _, _, _, 0.75 );
							}
						}
					//-//
						if ( m_bHotSauceOnCrit_ATTRIBUTE[attacker][slot] )
						{
							new type = m_iHotSauceOnCrit_Type[attacker][slot];

							if ( m_iIntegers[victim][m_iHotSauceType] != type )
							{
								new Handle:m_hData01 = CreateDataPack();
								CreateDataTimer( 0.01, m_tHotSauce_TimerDuration, m_hData01 );
								WritePackFloat( m_hData01, m_flHotSauceOnCrit_Duration[attacker][slot] );
								WritePackCell( m_hData01, victim );
								WritePackCell( m_hData01, attacker );
								WritePackCell( m_hData01, type );
								m_iIntegers[victim][m_iHotSauceType] = type;
							}
						}
					}
					if ( m_bHotSauceOnHit_ATTRIBUTE[attacker][slot] )
					{
						new type = m_iHotSauceOnHit_Type[attacker][slot];

						if ( m_iIntegers[victim][m_iHotSauceType] != type )
						{
							new Handle:m_hData01 = CreateDataPack();
							CreateDataTimer( 0.01, m_tHotSauce_TimerDuration, m_hData01 );
							WritePackFloat( m_hData01, m_flHotSauceOnHit_Duration[attacker][slot] );
							WritePackCell( m_hData01, victim );
							WritePackCell( m_hData01, attacker );
							WritePackCell( m_hData01, type );
							m_iIntegers[victim][m_iHotSauceType] = type;
						}
					}
				//-//
					if ( m_bStunOnHit_ATTRIBUTE[attacker][slot] )
					{
						if ( m_hTimers[victim][m_hStunlock_TimerDelay] == INVALID_HANDLE )
						{
							new Float:duration = m_flStunOnHit_Duration[attacker][slot];
							if ( m_iStunOnHit_StunLock[attacker][slot] == 1 ) m_hTimers[victim][m_hStunlock_TimerDelay] = CreateTimer( duration * 2.0, m_tStunLock, victim );
							
							TF2_StunPlayer( victim, duration, 1.0, TF_STUNFLAG_BONKSTUCK|TF_STUNFLAG_NOSOUNDOREFFECT, attacker );
							EmitSoundToClient( attacker, SOUND_TBASH, _, _, _, _, 0.4 );
							EmitSoundToClient( victim, SOUND_TBASH, _, _, _, _, 0.75 );
						}
					}
				//-//
					if ( m_bAfterburnCLOSERANGE_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( victim ) != TFClass_Pyro )
					{
						new Float:duration = m_flAfterburnCLOSERANGE_Duration[attacker][slot];
						if ( duration <= 0.0 ) duration = 1.0;

						new Float:m_flPos1[3], Float:m_flPos2[3];
						GetClientAbsOrigin( attacker, m_flPos1 );
						GetClientAbsOrigin( victim, m_flPos2 );

						new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
						if ( distance <= m_flAfterburnCLOSERANGE_Range[attacker][slot] )
						{
							if ( !TF2Attrib_GetByName( weapon, "Set DamageType Ignite" ) ) {
								TF2Attrib_SetByName( weapon, "Set DamageType Ignite", 1.0 );
								if ( duration > 1.0 ) { // If higher than 1 (10 seconds)
									if ( !TF2Attrib_GetByName( weapon, "weapon burn time increased" ) ) TF2Attrib_SetByName( weapon, "weapon burn time increased", duration );
								} else if ( duration < 1.0 ) { // If lower than 1 (10 seconds)
									if ( !TF2Attrib_GetByName( weapon, "weapon burn time reduced" ) ) TF2Attrib_SetByName( weapon, "weapon burn time reduced", duration );
								}
							}
						}
						else TF2Attrib_RemoveByName( weapon, "Set DamageType Ignite" );
					}
				//-//
					if ( m_bBleedCLOSERANGE_ATTRIBUTE[attacker][slot] )
					{
						new Float:m_flPos1[3], Float:m_flPos2[3];
						GetClientAbsOrigin( attacker, m_flPos1 );
						GetClientAbsOrigin( victim, m_flPos2 );

						new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
						if ( distance <= m_flBleedCLOSERANGE_Range[attacker][slot] )
						{
							TF2_RemoveCondition( victim, TFCond_Bleeding );
							TF2_MakeBleed( victim, attacker, m_flBleedCLOSERANGE_Duration[attacker][slot] );
						}
					}
				//-//
					if ( m_bChanceIgnite_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( victim ) != TFClass_Pyro )
					{
						new Float:duration = m_flChanceIgnite_Duration[attacker][slot];
						if ( duration <= 0.0 ) duration = 1.0;

						if ( m_flChanceIgnite_Chance[attacker][slot] >= GetRandomFloat( 0.0, 1.0 ) )
						{
							if ( !TF2Attrib_GetByName( weapon, "Set DamageType Ignite" ) ) {
								TF2Attrib_SetByName( weapon, "Set DamageType Ignite", 1.0 );
								if ( duration > 1.0 ) { // If higher than 1 (10 seconds)
									if ( !TF2Attrib_GetByName( weapon, "weapon burn time increased" ) ) TF2Attrib_SetByName( weapon, "weapon burn time increased", duration );
								} else if ( duration < 1.0 ) { // If lower than 1 (10 seconds)
									if ( !TF2Attrib_GetByName( weapon, "weapon burn time reduced" ) ) TF2Attrib_SetByName( weapon, "weapon burn time reduced", duration );
								}
							}
						}
						else TF2Attrib_RemoveByName( weapon, "Set DamageType Ignite" );
					}
				//-//
					if ( m_bChanceMadMilk_ATTRIBUTE[attacker][slot] )
					{
						if ( m_flChanceMadMilk_Chance[attacker][slot] >= GetRandomFloat( 0.0, 1.0 ) )
							TF2_AddCondition( victim, TFCond_Milked, m_flChanceMadMilk_Duration[attacker][slot] );
					}
				//-//
					if ( m_bChanceJarate_ATTRIBUTE[attacker][slot] )
					{
						if ( m_flChanceJarate_Chance[attacker][slot] >= GetRandomFloat( 0.0, 1.0 ) ) 
							TF2_AddCondition( victim, TFCond_Jarated, m_flChanceJarate_Duration[attacker][slot] );
					}
				//-//
					if ( m_bChanceBleed_ATTRIBUTE[attacker][slot] )
					{
						new stack = m_iChanceBleed_Stack[attacker][slot];
						new Float:duration = m_flChanceBleed_Duration[attacker][slot];
						if ( m_flChanceBleed_Chance[attacker][slot] >= GetRandomFloat( 0.0, 1.0 ) )
						{
							if ( !TF2_IsPlayerInCondition( victim, TFCond_Bleeding ) && stack == 0
							|| stack == 1 )
								TF2_MakeBleed( victim, attacker, duration );
						}
					}
				//-//
					if ( m_bRemoveBleeding_ATTRIBUTE[attacker][slot] )
						TF2_RemoveCondition( victim, TFCond_Bleeding );
				//-//
					if ( m_bInfiniteAfterburn_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( victim ) != TFClass_Pyro )
					{
						if ( m_hTimers[victim][m_hInfiniteAfterburn_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[victim][m_hInfiniteAfterburn_TimerDuration] );
						if ( m_hTimers[victim][m_hInfiniteAfterburn_TimerDuration] == INVALID_HANDLE )
						{
							TF2_IgnitePlayer( victim, attacker );
							g_pBurner[victim] = attacker;
							if ( m_iInfiniteAfterburn_Ressuply[attacker][slot] == 1 ) m_bBools[victim][m_bInfiniteAfterburn_Ressuply] = true;
							m_hTimers[victim][m_hInfiniteAfterburn_TimerDuration] = CreateTimer( m_flInfiniteAfterburn_Duration[attacker][slot], m_tInfiniteAfterburn_TimerDuration, victim );
						}
					}
				//-//
					if ( m_bBANOnKillHit_ATTRIBUTE[attacker][slot] )
					{
						if ( m_iBANOnKillHit_HitOrKill[attacker][slot] == 1 ) {
							if ( m_iBANOnKillHit_KickOrBan[attacker][slot] == 1 ) KickClient( victim, "Your ass just got kicked by the mighty power of a custom weapon !" );
							else if ( m_iBANOnKillHit_KickOrBan[attacker][slot] == 2 ) BanClient( victim, m_iBANOnKillHit_Duration[attacker][slot], BANFLAG_AUTHID, "Custom", "Your ass just got banned by the mighty power of a custom weapon !", "Custom" );
						}
					}
				//-//
					if ( m_bDamageDoneIsSelfHurt_ATTRIBUTE[attacker][slot] )
						DealDamage( attacker, RoundToFloor( damage * damageDoneIsSelfHurt_Multiplier[attacker][slot] / ( damage_type & TF_DMG_CRIT ? 3.0 : 1.0 ) ), weapon, damage_type|TF_DMG_PREVENT_PHYSICS_FORCE );

					if ( victim != attacker )
					{
						if ( damage_type & TF_DMG_CRIT || IsCritBoosted( attacker ) )
						{
							if ( m_bDrainUberchargeOnCrit_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( victim ) == TFClass_Medic && TF2_GetPlayerClass( attacker ) == TFClass_Medic )
							{
								new Float:pct = m_flDrainUberchargeOnCrit_Percentage[attacker][slot];
								new Float:m_flAttackerUbercharge = TF2_GetClientUberLevel( attacker );
								new Float:m_flVictimUbercharge = TF2_GetClientUberLevel( victim );

								if ( m_flVictimUbercharge > 0.0 && m_flAttackerUbercharge < 100.0 )
								{
									if ( m_flVictimUbercharge >= ( pct * 100.0 ) )
									{
										if ( m_flAttackerUbercharge > ( 100.0 - ( pct * 100.0 ) ) )
										{
											m_flVictimUbercharge -= ( 100.0 - m_flAttackerUbercharge );
											TF2_SetClientUberLevel( victim, m_flVictimUbercharge );

											TF2_SetClientUberLevel( attacker, 100.0 );
										} else {
											m_flAttackerUbercharge += ( pct * 100.0 );
											TF2_SetClientUberLevel( attacker, m_flAttackerUbercharge );

											m_flVictimUbercharge -= ( pct * 100.0 );
											TF2_SetClientUberLevel( victim, m_flVictimUbercharge );
										}
									} else {
										TF2_SetClientUberLevel( victim, 0.0 );
										TF2_SetClientUberLevel( attacker, ( m_flAttackerUbercharge + m_flVictimUbercharge ) );
									}
								}
							}
						}
						if ( m_bDrainUbercharge_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( victim ) == TFClass_Medic && TF2_GetPlayerClass( attacker ) == TFClass_Medic )
						{
							new Float:pct = m_flDrainUbercharge_Percentage[attacker][slot];
							new Float:m_flAttackerUbercharge = TF2_GetClientUberLevel( attacker );
							new Float:m_flVictimUbercharge = TF2_GetClientUberLevel( victim );

							if ( m_flVictimUbercharge > 0.0 && m_flAttackerUbercharge < 100.0 )
							{
								if ( m_flVictimUbercharge >= ( pct * 100.0 ) )
								{
									if ( m_flAttackerUbercharge > ( 100.0 - ( pct * 100.0 ) ) )
									{
										m_flVictimUbercharge -= ( 100.0 - m_flAttackerUbercharge );
										TF2_SetClientUberLevel( victim, m_flVictimUbercharge );

										TF2_SetClientUberLevel( attacker, 100.0 );
									} else {
										m_flAttackerUbercharge += ( pct * 100.0 );
										TF2_SetClientUberLevel( attacker, m_flAttackerUbercharge );

										m_flVictimUbercharge -= ( pct * 100.0 );
										TF2_SetClientUberLevel( victim, m_flVictimUbercharge );
									}
								} else {
									TF2_SetClientUberLevel( victim, 0.0 );
									TF2_SetClientUberLevel( attacker, ( m_flAttackerUbercharge + m_flVictimUbercharge ) );
								}
							}
						}
					//-//
						if ( m_bUberchargeOnHit_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( attacker ) == TFClass_Medic )
							TF2_SetClientUberLevel( attacker, TF2_GetClientUberLevel( attacker ) + m_flUberchargeOnHit_Amount[attacker][slot] );
					//-//
						if ( m_bMetalOnHit_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( attacker ) == TFClass_Engineer )
							TF2_SetClientMetal( attacker, TF2_GetClientMetal( attacker ) + m_iMetalOnHit_Amount[attacker][slot] );
					//-//
						if ( m_bMarkVictimDamage_ATTRIBUTE[attacker][slot] )
						{
							new maxvictim = m_iMarkVictimDamage_MaximumVictim[attacker][slot];
							new maxstack = m_iMarkVictimDamage_MaximumDamageStack[attacker][slot];
							g_pMarker[victim] = attacker;

							if ( m_hTimers[victim][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
							{
								ClearTimer( m_hTimers[victim][m_hMarkVictimDamage_TimerDuration] );
								m_iIntegers[attacker][m_iMarkVictimDamage]--;
							}
							if ( m_hTimers[attacker][m_hMarkVictimDamage_TimerDuration] == INVALID_HANDLE && m_iIntegers[attacker][m_iMarkVictimDamage] < maxvictim )
							{
								m_iIntegers[attacker][m_iMarkVictimDamage]++;
								if ( m_iIntegers[victim][m_iMarkVictimDamageCount] < maxstack ) m_iIntegers[victim][m_iMarkVictimDamageCount]++;

								new Handle:m_hData01 = CreateDataPack();
								m_hTimers[victim][m_hMarkVictimDamage_TimerDuration] = CreateDataTimer( m_flMarkVictimDamage_Duration[attacker][slot], m_tMarkVictimDamage_TimerDuration, m_hData01 );
								WritePackCell( m_hData01, victim );
								WritePackCell( m_hData01, attacker );
							}
							if ( m_iIntegers[attacker][m_iMarkVictimDamage] > maxvictim ) m_iIntegers[attacker][m_iMarkVictimDamage] = maxvictim;
							if ( m_iIntegers[victim][m_iMarkVictimDamageCount] > maxstack ) m_iIntegers[victim][m_iMarkVictimDamageCount] = maxstack;
						}
					//-//
						if ( m_bHealthLifesteal_ATTRIBUTE[attacker][slot] )
							TF2_HealPlayer( attacker, GetClientHealth( attacker ) * m_flHealthLifesteal_Multiplier[attacker][slot], m_flHealthLifesteal_OverHealBonusCap[attacker][slot], true );
					//-//
						if ( m_bEnemyHealthLifesteal_ATTRIBUTE[attacker][slot] )
							TF2_HealPlayer( attacker, GetClientHealth( victim ) * m_flEnemyHealthLifesteal_Multiplier[attacker][slot], m_flEnemyHealthLifesteal_OverHealBonusCap[attacker][slot], true );
					//-//
						if ( m_bMissingEnemyHealthLifesteal_ATTRIBUTE[attacker][slot] )
						{
							if ( GetClientHealth( victim ) < TF2_GetClientMaxHealth( victim ) )
								TF2_HealPlayer( attacker, ( TF2_GetClientMaxHealth( victim ) - GetClientHealth( victim ) ) * m_flMissingEnemyHealthLifesteal_Multiplier[attacker][slot], m_flMissingEnemyHealthLifesteal_OverHealBonusCap[attacker][slot], true );
						}
					//-//
						if ( m_bMCFRTD_ATTRIBUTE[attacker][slot] ) {
							if ( m_hTimers[attacker][m_hMCFRTD_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[attacker][m_hMCFRTD_TimerDelay] );
						}
					//-//
						if ( m_bPsycho_ATTRIBUTE[attacker][slot] )
						{
							if ( m_flFloats[attacker][m_flPyschoCharge] < 100.0 && m_hTimers[attacker][m_hPsycho_TimerDuration] == INVALID_HANDLE )
							{
								new Float:m_flCharge = ( 2 * damage * ( 1.1 - FloatDiv( GetClientHealth( attacker )+0.0, TF2_GetClientMaxHealth( attacker )+0.0 ) ) ) * m_flPsycho_DamageResistance[attacker][slot];
								if ( m_flCharge < 1.0 ) m_flCharge = 1.0;
								m_flFloats[attacker][m_flPyschoCharge] += m_flCharge;
							}
						}
					//-//
						if ( m_bMetalOnHitDamage_ATTRIBUTE[attacker][slot] && TF2_GetPlayerClass( attacker ) == TFClass_Engineer )
							TF2_SetClientMetal( attacker, RoundToFloor( TF2_GetClientMetal( attacker ) + ( damage * m_flMetalOnHitDamage_Multiplier[attacker][slot] ) ) );
					//-//
						if ( m_bStealDamage_ATTRIBUTE[attacker][slot] )
						{
							if ( m_hTimers[attacker][m_hStealDamageA_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[attacker][m_hStealDamageA_TimerDuration] );
							if ( m_hTimers[attacker][m_hStealDamageA_TimerDuration] == INVALID_HANDLE )
							{
								m_flFloats[attacker][m_flStealDamageAttacker] += m_flStealDamage_Steal[attacker][slot];
								if ( m_iStealDamage_Pct[attacker][slot] == 1 ) m_bBools[attacker][m_bStealPct] = true;
								else m_bBools[attacker][m_bStealPct] = false;
								m_hTimers[attacker][m_hStealDamageA_TimerDuration] = CreateTimer( m_flStealDamage_Duration[attacker][slot], m_tStealDamageAttacker, attacker );
							}
							if ( m_hTimers[victim][m_hStealDamageV_TimerDuration] != INVALID_HANDLE ) ClearTimer( m_hTimers[victim][m_hStealDamageV_TimerDuration] );
							if ( m_hTimers[victim][m_hStealDamageV_TimerDuration] == INVALID_HANDLE )
							{
								m_flFloats[victim][m_flStealDamageVictim] += m_flStealDamage_Steal[attacker][slot];
								if ( m_iStealDamage_Pct[attacker][slot] == 1 ) m_bBools[victim][m_bStealPct] = true;
								else m_bBools[victim][m_bStealPct] = false;
								m_hTimers[victim][m_hStealDamageV_TimerDuration] = CreateTimer( m_flStealDamage_Duration[attacker][slot], m_tStealDamageVictim, victim );
							}
						}
					//-//
						if ( m_bDamageChargeThing_ATTRIBUTE[attacker][slot] )
						{
							if ( !m_bBools[attacker][m_bDamageChargeThing_Enable] ) 
							{
								m_flFloats[attacker][damageCharge] += ( damage * damageChargeThing_Charge[attacker][slot] );
								if ( m_flFloats[attacker][damageCharge] > 100.0 ) m_flFloats[attacker][damageCharge] = 100.0;
							}
						}
					}
				}
			}
		}
	}
	if ( damage < 0.0 ) damage = 0.0;

	apply = Plugin_Changed;
	return apply;
}

// ====[ CALC IS ATTACK CRITICAL ]=====================================
public Action:TF2_CalcIsAttackCritical( client, weapon, String:name[], &bool:m_bResult )
{
	if ( IsValidClient( client )
		&& IsPlayerAlive( client )
		&& weapon != -1 )
	{
		new slot = TF2_GetWeaponSlot( client, weapon );
		if ( slot != -1 && m_bHasAttribute[client][slot] )
		{
			if ( m_bDamageSelf_ATTRIBUTE[client][slot] )
				DealDamage( client, m_iDamageSelf_Amount[client][slot], client, TF_DMG_PREVENT_PHYSICS_FORCE|HL_DMG_GENERIC );
		//-//
			if ( m_bMetalPerShot_ATTRIBUTE[client][slot] && TF2_GetPlayerClass( client ) == TFClass_Engineer )
				TF2_SetClientMetal( client, TF2_GetClientMetal( client ) + m_iMetalPerShot_Amount[client][slot] );
		//-//
			if ( m_bMCFRTD_ATTRIBUTE[client][slot] )
			{
				if ( m_iIntegers[client][m_iMissStack] < m_iMCFRTD_MaximumStack[client][slot] )
				{
					if ( m_hTimers[client][m_hMCFRTD_TimerDelay] != INVALID_HANDLE ) ClearTimer( m_hTimers[client][m_hMCFRTD_TimerDelay] );
					else {
						new Handle:m_hData03 = CreateDataPack();
						WritePackCell( m_hData03, client );
						WritePackCell( m_hData03, weapon );
						m_hTimers[client][m_hMCFRTD_TimerDelay] = CreateTimer( 0.0, m_tMCFRTD_Timer, m_hData03 );
					
						m_bBools[client][m_bLastWasMiss] = false;
					}
				}
			}
		//-//
			if ( m_bBulletsPerShotBonusDynamic_ATTRIBUTE[client][slot] )
				TF2Attrib_SetByName( weapon, "bullets per shot bonus", GetClipAmmo( client, TF2_GetWeaponSlot( client, weapon ) )+0.0 );
		}
	}
	return Plugin_Continue;
}

// ====[ EVENT: ON DEATH ]=============================================
public Action:Event_Death( Handle:event, const String:name[], bool:broadcast )
{
	new victim = GetClientOfUserId( GetEventInt( event, "userid" ) );
	new killer = GetClientOfUserId( GetEventInt( event, "attacker" ) );
	new bool:feign = bool:( GetEventInt( event, "death_flags" ) & TF_DEATHFLAG_DEADRINGER );

	if ( IsValidClient( victim ) )
	{
		if ( victim && !feign )
		{
			if ( HasAttribute( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
				CreateTimer( 0.03, m_tDamageReceivedUnleashedDeath_TimerDelay, victim ); // AVOID PROBLEMS.
		//-//
			if ( HasAttribute( victim, _, m_bAttackSpeedOnKill_ATTRIBUTE ) )
			{
				if ( GetAttributeValueF( victim, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_Removal ) < 1.0 )
					m_iIntegers[victim][m_iAttackSpeed] = RoundToFloor( m_iIntegers[victim][m_iAttackSpeed] * GetAttributeValueF( victim, _, m_bAttackSpeedOnKill_ATTRIBUTE, m_flAttackSpeedOnKill_Removal ) );
			}

			if ( m_hTimers[victim][m_hMarkVictimDamage_TimerDuration] != INVALID_HANDLE )
			{
				if ( m_iIntegers[g_pMarker[victim]][m_iMarkVictimDamage] > 0 && GetClientTeam( g_pMarker[victim] ) != GetClientTeam( victim ) && HasAttribute( g_pMarker[victim], _, m_bMarkVictimDamage_ATTRIBUTE ) )
					m_iIntegers[g_pMarker[victim]][m_iMarkVictimDamage]--;
			}
			for ( new i = 0; i < m_hTimer; i++ )
			{
				ClearTimer( m_hTimers[victim][i] );
			}
			for ( new i = 0; i < m_bBool; i++ )
			{
				m_bBools[victim][i]	= false;
			}
			for ( new i = 0; i < m_flFloat-1; i++ )
			{
				m_flFloats[victim][i]	= 0.0;
			}
			for ( new i = 0; i < m_iInteger-1; i++ )
			{
				m_iIntegers[victim][i]= 0;
			}
			g_pBurner[victim] = -1;
			g_pMarker[victim] = -1;
		}

		if ( IsValidClient( killer )
			&& killer != victim )
		{
			if ( g_iLastWeapon[killer] != -1 ) 
			{
				new weapon = g_iLastWeapon[killer];
				if ( weapon != -1 )
				{
					new slot = TF2_GetWeaponSlot( killer, weapon );
					if ( slot != -1 && m_bHasAttribute[killer][slot] )
					{
						if ( m_bKillGib_ATTRIBUTE[killer][slot] )
						{
							new Float:fClientOrigin[3];
							GetClientAbsOrigin( victim, fClientOrigin );

							new ragdoll = CreateEntityByName( "tf_ragdoll" );
							if ( IsValidEdict( ragdoll ) )
							{
								SetEntPropVector( ragdoll, Prop_Send, "m_vecRagdollOrigin", fClientOrigin );
								SetEntProp( ragdoll, Prop_Send, "m_iPlayerIndex", victim );
								SetEntPropVector( ragdoll, Prop_Send, "m_vecForce", NULL_VECTOR );
								SetEntPropVector( ragdoll, Prop_Send, "m_vecRagdollVelocity", NULL_VECTOR );
								SetEntProp( ragdoll, Prop_Send, "m_bGib", 1 );

								DispatchSpawn( ragdoll );

								CreateTimer( 0.1, RemoveBody, victim );
								CreateTimer( 15.0, TF2_RemoveGibs, ragdoll );
							}
						}
					//-//
						if ( m_bSpawnSkeletonOnKill_ATTRIBUTE[killer][slot] )
						{
							new boss = m_iSpawnSkeletonOnKill_Boss[killer][slot];
							new Float:duration = m_flSpawnSkeletonOnKill_Duration[killer][slot];

							if ( ( boss == 0 ? 0.0 : m_flSpawnSkeletonOnKill_BossChance[killer][slot] ) >= GetRandomFloat( 0.0, 1.0 ) )
							{
								if ( boss == 1 ) SpawnThing( "headless_hatman", duration * 10.0, victim );
								if ( boss == 2 ) SpawnThing( "tf_zombie_spawner", 0.0, victim );
								if ( boss == 3 && TF2_GetPlayerClass( victim ) == TFClass_DemoMan ) SpawnThing( "eyeball_boss", duration * 10.0, victim );
							}
							else SpawnThing( "tf_zombie", duration, victim, GetClientTeam( killer ) );
						}
					//-//
						if ( m_bAttackSpeedOnKill_ATTRIBUTE[killer][slot] )
						{
							new max = m_iAttackSpeedOnKill_MaximumStack[killer][slot];

							m_iIntegers[killer][m_iAttackSpeed]++;
							if ( m_iIntegers[killer][m_iAttackSpeed] > max ) m_iIntegers[killer][m_iAttackSpeed] = max;
						}
					//-//
						if ( m_bBANOnKillHit_ATTRIBUTE[killer][slot] )
						{
							new kickban = m_iBANOnKillHit_KickOrBan[killer][slot];

							if ( m_iBANOnKillHit_HitOrKill[killer][slot] == 2 )
							{
								if ( kickban == 1 ) KickClient( victim, "Your ass just got kicked by the mighty custom power !" );
								else if ( kickban == 2 ) {
									if ( !IsFakeClient( victim ) ) BanClient( victim, m_iBANOnKillHit_Duration[killer][slot], BANFLAG_AUTHID, "Custom", "Your ass just got banned by the mighty custom power !", "Custom" );
								}
							}
						}
					//-//
						if ( m_bTeleportToVictimOnKill_ATTRIBUTE[killer][slot] )
						{
							if ( TF2_GetPlayerClass( killer ) != TFClass_Engineer && TF2_GetPlayerClass( killer ) != TFClass_Medic && TF2_GetPlayerClass( killer ) != TFClass_Sniper && !feign )
							{
								new Float:m_flPos[3];
								GetClientAbsOrigin( victim, m_flPos );

								TeleportEntity( killer, m_flPos, NULL_VECTOR, NULL_VECTOR );
							}
						}
					//-//
						if ( m_bScareOnKill_ATTRIBUTE[killer][slot] )
						{
							new Float:m_flPos1[3];
							GetClientAbsOrigin( victim, m_flPos1 );

							new Float:radius = m_flScareOnKill_Radius[killer][slot];
							new Float:duration = m_flScareOnKill_Duration[killer][slot];

							for ( new i = 1 ; i <= MaxClients ; i++ )
							{
								if ( i != killer && i != victim && IsClientInGame( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( killer ) )
								{
									if ( !HasInvulnerabilityCond( i ) )
									{
										new Float:m_flPos2[3];
										GetClientAbsOrigin( i, m_flPos2 );

										new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
										if ( distance <= radius )
										{
											if ( m_hTimers[i][m_hStunlock_TimerDelay] == INVALID_HANDLE )
											{
												if ( m_iScareOnKill_StunLock[killer][slot] == 1 ) m_hTimers[i][m_hStunlock_TimerDelay] = CreateTimer( duration * 2.0, m_tStunLock, i );
													
												new Float:stun_reduction = 1.0;
												if ( distance >= 73.0 )
													stun_reduction = ( duration * ( radius - ( ( distance - 73.0 ) * 0.66 ) ) / radius ) / duration;

												TF2_StunPlayer( i, duration * stun_reduction, 1.0, TF_STUNFLAGS_GHOSTSCARE, killer );
											}
										}
									}
								}
							}
						}
					}
				}
			}
		}
	}
	return Plugin_Continue;
}

// ====[ ON CONDITION REMOVED ]========================================
public TF2_OnConditionRemoved( client, TFCond:condition )
{
	if ( IsValidClient( client ) )
	{
		if ( m_iIntegers[client][m_iHotSauceType] != 0 )
		{
			new type = m_iIntegers[client][m_iHotSauceType];

			if ( type == 1 || type == 4 || type == 5 || type == 7 )
				if ( condition == TFCond_Milked ) m_iIntegers[client][m_iHotSauceType] = 0;
			if ( type == 2 || type == 4 || type == 6 || type == 7 )
				if ( condition == TFCond_Jarated ) m_iIntegers[client][m_iHotSauceType] = 0;
			if ( type == 3 || type == 5 || type == 6 || type == 7 )
				if ( condition == TFCond_Bleeding ) m_iIntegers[client][m_iHotSauceType] = 0;
		}
		if ( m_bBools[client][m_bBackstab_SuicideBlocker] )
		{
			if ( condition == TFCond_Dazed ) m_bBools[client][m_bBackstab_SuicideBlocker] = false;
		}
		if ( m_hTimers[client][m_hInfiniteAfterburn_TimerDuration] == INVALID_HANDLE )
		{
			if ( condition == TFCond_OnFire ) g_pBurner[client] = -1;
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

			if ( HasAttribute( i, 0, m_bHomingProjectile_ATTRIBUTE ) )
			{
				SetHomingProjectile( i, "tf_projectile_energy_ball", radius, mode, type );
				SetHomingProjectile( i, "tf_projectile_rocket",	radius, mode, type );
				SetHomingProjectile( i, "tf_projectile_healing_bolt", radius, mode, type );
				SetHomingProjectile( i, "tf_projectile_arrow",	radius, mode, type );
			}
			if ( HasAttribute( i, 1, m_bHomingProjectile_ATTRIBUTE ) && TF2_GetPlayerClass( i ) == TFClass_Pyro )
				SetHomingProjectile( i, "tf_projectile_flare", radius, mode, type );
		}
	}
}

// ====[ ON ENTITY DESTROYED ]=========================================
public OnEntityDestroyed( m_iEntity )
{
	if ( m_iEntity <= 0 || m_iEntity > 2048 ) return;

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
				if ( StrEqual( m_sClass, "tf_projectile_pipe_remote" ) && GetEntProp( m_iEnt, Prop_Send, "damage_type" ) != 2 )
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
							// I don't think I will ever remove this, idk why, it has been here for so long.
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
public Action:m_tDrainMetal_TimerInterval( Handle:timer, any:client )
{
	if ( HasAttribute( client, _, m_bMetalDrain_ATTRIBUTE ) )
	{
		if ( GetAttributeValueI( client, _, m_bMetalDrain_ATTRIBUTE, m_iMetalDrain_PoA ) == 1 && !HasAttribute( client, _, m_bMetalDrain_ATTRIBUTE, true ) )
		{
			m_hTimers[client][m_hDrainMetal_TimerDelay] = INVALID_HANDLE;
			return Plugin_Stop;
		}
		if ( TF2_GetPlayerClass( client ) == TFClass_Engineer )
			TF2_SetClientMetal( client, TF2_GetClientMetal( client ) + GetAttributeValueI( client, _, m_bMetalDrain_ATTRIBUTE, m_iMetalDrain_Amount ) );
	}

	m_hTimers[client][m_hDrainMetal_TimerDelay] = INVALID_HANDLE;
	return Plugin_Stop;
}
public Action:m_tHotSauce_TimerDuration( Handle:timer, any:m_hData01 )
{
	ResetPack( m_hData01 );

	new victim, attacker, Float:duration, type;
	duration = ReadPackFloat( m_hData01 );
	victim = ReadPackCell( m_hData01 );
	attacker = ReadPackCell( m_hData01 );
	type = ReadPackCell( m_hData01 );

	if ( IsValidClient( attacker ) && IsValidClient( victim ) ) {
		if ( HasAttribute( attacker, _, m_bHotSauceOnHit_ATTRIBUTE ) || HasAttribute( attacker, _, m_bHotSauceOnCrit_ATTRIBUTE ) )
		{
			if ( type == 1 || type == 4 || type == 5 || type == 7 ) TF2_AddCondition( victim, TFCond_Milked, duration, attacker );
			if ( type == 2 || type == 4 || type == 6 || type == 7 ) TF2_AddCondition( victim, TFCond_Jarated, duration, attacker );
			if ( type == 3 || type == 5 || type == 6 || type == 7 ) TF2_MakeBleed( victim, attacker, duration );
		}
	}
}
public Action:m_tSpawnSkeletonOnKill_TimerDuration( Handle:timer, any:m_iEnt )
{
	if ( IsValidEntity( m_iEnt ) ) AcceptEntityInput( m_iEnt, "Kill" );
}
public Action:m_tBerserker_TimerDuration( Handle:timer, any:client )
{
	if ( HasAttribute( client, _, m_bBerserker_ATTRIBUTE ) )
	{
		TF2_RemoveCondition( client, TFCond_Ubercharged );
		DealDamage( client, 1000000000, client, TF_DMG_CRIT|TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
	}

	m_hTimers[client][m_hBerserker_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tLowBerserker_TimerDuration( Handle:timer, any:client )
{
	if ( HasAttribute( client, _, m_bLowBerserker_ATTRIBUTE ) && GetAttributeValueI( client, _, m_bLowBerserker_ATTRIBUTE, m_iLowBerserker_Kill ) > 0 )
	{
		TF2_RemoveCondition( client, TFCond_Ubercharged );
		DealDamage( client, 1000000000, client, TF_DMG_CRIT|TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL );
	}

	m_hTimers[client][m_hLowBerserker_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tPsycho_TimerDuration( Handle:timer, any:client )
{
	m_hTimers[client][m_hPsycho_TimerDuration] = INVALID_HANDLE;
	m_flFloats[client][m_flPsychoRegenCharge] = 0.0;
	m_flFloats[client][m_flPyschoCharge] = 0.0;
}
public Action:m_tDamageReceivedUnleashedDeath_TimerDelay( Handle:timer, any:victim )
{
	if ( HasAttribute( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE ) )
	{
		new Float:radius = GetAttributeValueF( victim, _, m_bDamageReceivedUnleashedDeath_ATTRIBUTE, damageReceivedUnleashedDeath_Radius );
		AttachParticle( victim, "mvm_soldier_shockwave", 1.5 );

		new Float:m_flPos1[3];
		GetClientEyePosition( victim, m_flPos1 );

		for ( new i = 1; i <= MaxClients; i++ )
		{
			if ( i != victim && IsValidClient( i ) && IsPlayerAlive( i ) && GetClientTeam( i ) != GetClientTeam( victim ) )
			{
				if ( !HasInvulnerabilityCond( i ) )
				{
					new Float:m_flPos2[3];
					GetClientEyePosition( i, m_flPos2 );

					new Float:distance = GetVectorDistance( m_flPos1, m_flPos2 );
					new Float:final_radius = radius + ( m_flFloats[victim][damageReceived] * 0.2 );
					if ( distance <= final_radius )
					{
						decl Handle:m_hSee;
						( m_hSee = INVALID_HANDLE );

						m_hSee = TR_TraceRayFilterEx( m_flPos1, m_flPos2, MASK_SOLID, RayType_EndPoint, TraceFilterPlayer, victim );
						if ( m_hSee != INVALID_HANDLE )
						{
							if ( !TR_DidHit( m_hSee ) )
							{
								// Limit the minimum damage to 50%
								// Begin the reduction at 73.0 HU.
								new Float:dmg_reduction = 1.0;
								if ( distance >= 73.0 )
									dmg_reduction = ( m_flFloats[victim][damageReceived] * ( final_radius - ( ( distance - 73.0 ) * 0.66 ) ) / final_radius ) / m_flFloats[victim][damageReceived];

								DealDamage( i, RoundToFloor( m_flFloats[victim][damageReceived] * dmg_reduction ), victim, TF_DMG_PREVENT_PHYSICS_FORCE|DOTA_DMG_BLADEMAIL, "pumpkindeath" );
							}
						}

						CloseHandle( m_hSee );
					}
				}
			}
		}
		m_flFloats[victim][damageReceived] = 0.0;
	}
}
public Action:m_tHeatAttackSpeed_TimerDelay( Handle:timer, any:m_hData01 )
{
	ResetPack( m_hData01 );

	new weapon, client;
	new Float:m_flAttackSpeed;
	weapon = ReadPackCell( m_hData01 );
	client = ReadPackCell( m_hData01 );
	m_flAttackSpeed = ReadPackFloat( m_hData01 );

	if ( weapon != -1 && IsValidEdict( weapon ) && IsValidClient( client ) )
	{
		if ( HasAttribute( client, _, m_bHeatFireRate_ATTRIBUTE ) )
		{
			if ( m_iIntegers[client][m_iHeat] >= GetAttributeValueI( client, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack ) ) {
				m_iIntegers[client][m_iHeat] = GetAttributeValueI( client, _, m_bHeatFireRate_ATTRIBUTE, m_iHeatFireRate_MaximumStack );
			} else {
				m_iIntegers[client][m_iHeat]++;
				TF2Attrib_SetByName( weapon, "fire rate bonus", m_flAttackSpeed - GetAttributeValueF( client, _, m_bHeatFireRate_ATTRIBUTE, m_flHeatFireRate_AttackSpeed ) );
			}
		}
	}
	m_hTimers[client][m_hHeatFireRate_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tHeatDMGTaken_TimerDelay( Handle:timer, any:client )
{
	if ( IsValidClient( client ) ) {
		if ( HasAttribute( client, _, m_bHeatDMGTaken_ATTRIBUTE ) )
		{
			new max = GetAttributeValueI( client, _, m_bHeatDMGTaken_ATTRIBUTE, m_iHeatDMGTaken_MaximumStack );
			if ( m_iIntegers[client][m_iHeatToo] >= max ) {
				m_iIntegers[client][m_iHeatToo] = max;
			}
			else m_iIntegers[client][m_iHeatToo]++;
		}
	}
	m_hTimers[client][m_hHeatDamage_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tMarkVictimDamage_TimerDuration( Handle:timer, any:m_hData01 )
{
	ResetPack( m_hData01 );

	new victim, attacker;
	victim = ReadPackCell( m_hData01 );
	attacker = ReadPackCell( m_hData01 );

	if ( IsValidClient( victim ) && IsValidClient( attacker ) )
	{
		m_iIntegers[attacker][m_iMarkVictimDamage]--;
		m_iIntegers[victim][m_iMarkVictimDamageCount] = 0;
		g_pMarker[victim] = -1;

		m_hTimers[victim][m_hMarkVictimDamage_TimerDuration] = INVALID_HANDLE;
	}

}
public Action:m_tMCFRTD_Timer( Handle:timer, Handle:m_hData03 )
{
	ResetPack( m_hData03 );

	new client, weapon;
	client = ReadPackCell( m_hData03 );
	weapon = ReadPackCell( m_hData03 );
	
	if ( HasAttribute( client, _, m_bMCFRTD_ATTRIBUTE ) )
	{
		if ( weapon != -1 && IsValidEdict( weapon ) && IsValidClient( client ) )
		{
			m_bBools[client][m_bLastWasMiss] = true;

			if ( !( TF2Attrib_GetByName( weapon, "fire rate penalty" ) ) ) TF2Attrib_SetByName( weapon, "fire rate penalty",GetAttributeValueF( client, _, m_bMCFRTD_ATTRIBUTE, m_flMCFRTD_OldAttackSpeed ) );
			new Address:m_aAttribute = TF2Attrib_GetByName( weapon, "fire rate penalty" );
			new Float:m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

			TF2Attrib_SetByName( weapon, "fire rate penalty", m_flAttackSpeed + GetAttributeValueF( client, _, m_bMCFRTD_ATTRIBUTE, m_flMCFRTD_AttackSpeed ) );
			m_flAttackSpeed = TF2Attrib_GetValue( m_aAttribute );

			if ( m_flAttackSpeed <= 0.0 ) TF2Attrib_SetByName( weapon, "fire rate penalty", 0.0 );

			m_iIntegers[client][m_iMissStack]++;
		}
	}

	m_hTimers[client][m_hMCFRTD_TimerDelay] = INVALID_HANDLE;
}
public Action:m_tInfiniteAfterburn_TimerDuration( Handle:timer, any:victim )
{
	TF2_RemoveCondition( victim, TFCond_OnFire );
	m_bBools[victim][m_bInfiniteAfterburn_Ressuply] = false;
	g_pBurner[victim] = -1;

	m_hTimers[victim][m_hInfiniteAfterburn_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tStealDamageAttacker( Handle:timer, any:attacker )
{
	m_flFloats[attacker][m_flStealDamageAttacker] = 0.0;
	m_hTimers[attacker][m_hStealDamageA_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tStealDamageVictim( Handle:timer, any:victim )
{
	m_flFloats[victim][m_flStealDamageVictim] = 0.0;
	m_hTimers[victim][m_hStealDamageV_TimerDuration] = INVALID_HANDLE;
}
public Action:m_tStunLock( Handle:timer, any:victim ) m_hTimers[victim][m_hStunlock_TimerDelay] = INVALID_HANDLE;
public Action:m_tChargeDamageThing( Handle:timer, any:client ) m_hTimers[client][m_hDamageChargeThing_Enabled] = INVALID_HANDLE;
// Super Timer
public Action:m_tPostInventory( Handle:timer, any:client ) g_hPostInventory[client] = false;