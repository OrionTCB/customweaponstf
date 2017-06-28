#define TF_MAX_PLAYERS 34  // Replace this with MAXPLAYERS+1 if not TF2

// These two enums have to be placed before all code that uses them.
enum e_flNext // These are single stand-alone "timers"
{
    e_flNextVoice = 0,
    e_flNextBossTaunt,
    e_flNextAllowBossSuicide,
    e_flNextAllowOtherSpawnTele,
    e_flNextTrample,
    e_flNextMissile
}

enum e_flNext2 // Give an individual timer for every player
{
    e_flNextHeavySound = 0,
    e_flNextFlashTrigger,
    e_flNextBrassShieldSfx,
    e_flNextExplosiveShotgunSfx,
	e_flNextHUDUpdate
}

// Stuff past here can be anywhere below the enums above.

stock static Float:g_flNext[e_flNext];
stock static Float:g_flNext2[e_flNext2][TF_MAX_PLAYERS];

// Start of singular NextTime functions

stock bool:IsNextTime(iIndex, Float:flAdditional = 0.0)
{
    return (GetEngineTime() >= g_flNext[iIndex]+flAdditional);
}

stock SetNextTime(iIndex, Float:flTime, bool:bAbsolute = false)
{
    g_flNext[iIndex] = bAbsolute ? flTime : GetEngineTime() + flTime;
}

stock Float:GetTimeTilNextTime(iIndex, bool:bNonNegative = true)
{
    return bNonNegative ? fmax(g_flNext[iIndex] - GetEngineTime(), 0.0) : (g_flNext[iIndex] - GetEngineTime());
}

stock GetSecsTilNextTime(iIndex, bool:bNonNegative = true)
{
    return RoundToFloor(GetTimeTilNextTime(iIndex, bNonNegative));
}

/*
    If next time occurs, we also add time on for when it is next allowed.
*/
stock bool:IfDoNextTime(iIndex, Float:flThenAdd)
{
    if (IsNextTime(iIndex))
    {
        SetNextTime(iIndex, flThenAdd);
        return true;
    }
    return false;
}

// Start of plural NextTime functions for every player

stock bool:IsNextTime2(iClient, iIndex, Float:flAdditional = 0.0)
{
    return (GetEngineTime() >= g_flNext2[iIndex][iClient]+flAdditional);
}

stock SetNextTime2(iClient, iIndex, Float:flTime, bool:bAbsolute = false)
{
    g_flNext2[iIndex][iClient] = bAbsolute ? flTime : GetEngineTime() + flTime;
}

stock Float:GetTimeTilNextTime2(iClient, iIndex, bool:bNonNegative = true)
{
    return bNonNegative ? fmax(g_flNext2[iIndex][iClient] - GetEngineTime(), 0.0) : (g_flNext2[iIndex][iClient] - GetEngineTime());
}

stock GetSecsTilNextTime2(iClient, iIndex, bool:bNonNegative = true)
{
    return RoundToFloor(GetTimeTilNextTime2(iClient, iIndex, bNonNegative));
}

/*
    If next time occurs, we also add time on for when it is next allowed.
*/
stock bool:IfDoNextTime2(iClient, iIndex, Float:flThenAdd)
{
    if (IsNextTime2(iClient, iIndex))
    {
        SetNextTime2(iClient, iIndex, flThenAdd);
        return true;
    }
    return false;
}  