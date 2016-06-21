#pragma semicolon 1
#include <sourcemod>
#include <sdktools>
#include <tf2_stocks>
#include <tf2items>
#include <tf2attributes>
#include <sdkhooks>
#include <cw3-attributes>
//#include <customweaponstf>
#include <customweaponstf_orionstock>

#define PLUGIN_VERSION "1.0"

public Plugin:myinfo = {
    name = "Custom Weapons: Nergal's Attributes",
    author = "Nergal / Assyrian",
    description = "Custom Weapons: Nergal's Attributes",
    version = PLUGIN_VERSION,
    url = "https://forums.alliedmods.net/showthread.php?t=236242"
};

new g_iLastButtons[MAXPLAYERS + 1] = -1;
new bool:m_bHasAttribute[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:NoDamageFallOff[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:NoDamageFallOffMaxDist[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:NoDamageFallOffMinDist[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:NoDamageRampUp[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:NoDamageRampUpMinDist[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:ReduceAmmoOnHit[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ReduceAmmoOnHitVal[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:AmmoFromWrench[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:AmmoFromWrenchAmount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:ShootsMultiRockets[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ShootsMultiRocketsSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ShootsMultiRocketsRandomness[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ShootsMultiRocketsDMG[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ShootsMultiRocketsRadius[MAXPLAYERS + 1][MAXSLOTS + 1];
new ShootsMultiRocketsAmount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:MeleeDmgResist[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:MeleeDmgResistAmount[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:ReverseDamageFallOff[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:ReverseDamageFallOffDist[MAXPLAYERS + 1][MAXSLOTS + 1];

new bool:EngineerHaulSpeed[MAXPLAYERS + 1][MAXSLOTS + 1];
new Float:EngineerHaulSpeedAmount[MAXPLAYERS + 1][MAXSLOTS + 1];

new AmmoTable[MAXPLAYERS + 1][6];

public OnPluginStart( )
{
    for ( new i = 1; i <= MaxClients; i++ )
    {
        if ( IsClientInGame( i ) )
        {
            OnClientPutInServer( i );
        }
    }
    HookEvent( "player_spawn", Event_Spawn );
}
public OnClientPutInServer( client )
{
    SDKHook( client, SDKHook_TraceAttack,  TraceAttack );
    SDKHook( client, SDKHook_OnTakeDamage, OnTakeDamage );
    SDKHook( client, SDKHook_PreThink,     OnPreThink );
}
public OnClientPreThink( client )
{
    OnPreThink( client );
}
public OnPreThink( client )
{
    if ( !IsValidClient( client ) ) return;
    if ( !IsPlayerAlive( client ) ) return;
    
    new last_button = g_iLastButtons[client];
    new buttons = GetClientButtons( client );
    new buttons2 = buttons;
    
    new slot2;
    slot2 = -1;
    for ( slot2 = 0; slot2 <= 4; slot2++ ) // ALWAYS ACTIVE | PASSIVE STUFF HERE.
    {
        buttons = ATTRIBUTE_HAULSPEED( client, buttons, slot2, last_button );
    }

    if ( buttons != buttons2 ) SetEntProp( client, Prop_Data, "m_nButtons", buttons );    
    g_iLastButtons[client] = buttons;
}

ATTRIBUTE_HAULSPEED( client, &buttons, &slot2, &last_button )
{
    if ( HasAttribute( client, _, EngineerHaulSpeed ) )
    {
        if ( TF2_GetPlayerClass( client ) == TFClass_Engineer && GetEntProp( client, Prop_Send, "m_bCarryingObject" ) )
        {
            //new Float:fSpeed = GetAttributeValue( client, _, EngineerHaulSpeed, EngineerHaulSpeedAmount )*225.0;
            //SetEntPropFloat( client, Prop_Data, "m_flMaxspeed", RoundToFloor( fSpeed ) );
        }
    }

    return buttons;
}
public Action:CW3_OnAddAttribute( slot, client, const String:attrib[], const String:plugin[], const String:value[], bool:active )
{
    if ( !StrEqual( plugin, "nergalpak" ) ) return Plugin_Continue;
    new Action:action;

    if ( StrEqual( attrib, "no damage falloff" ) )
    {
        new String:values[2][10];
        ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );

        NoDamageFallOffMaxDist[client][slot]    = StringToFloat( values[0] );
        NoDamageFallOffMinDist[client][slot]    = StringToFloat( values[1] );
        NoDamageFallOff[client][slot]           = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "no damage rampup" ) )
    {
        NoDamageRampUpMinDist[client][slot] = StringToFloat( value );
        NoDamageRampUp[client][slot]        = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "reduce victim ammo on hit" ) )
    {
        ReduceAmmoOnHitVal[client][slot]    =  StringToFloat( value );
        ReduceAmmoOnHit[client][slot]       = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "ammo from wrench" ) )
    {
        AmmoFromWrenchAmount[client][slot]  = StringToFloat( value );
        AmmoFromWrench[client][slot]        = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "shoots multirockets" ) )
    {
        new String:values[5][10];
        ExplodeString( value, " ", values, sizeof( values ), sizeof( values[] ) );
        
        ShootsMultiRocketsAmount[client][slot]      = StringToInt( value[0] );
        ShootsMultiRocketsDMG[client][slot]         = StringToFloat( values[1] );
        ShootsMultiRocketsSpeed[client][slot]       = StringToFloat( values[2] );
        ShootsMultiRocketsRandomness[client][slot]  = StringToFloat( values[3] );
        ShootsMultiRocketsRadius[client][slot]      = StringToFloat( values[4] );
        ShootsMultiRockets[client][slot]            = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "damage from melee" ) )
    {
        MeleeDmgResistAmount[client][slot]    = StringToFloat( value );
        MeleeDmgResist[client][slot]          = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "reverse damage falloff" ) )
    {
        ReverseDamageFallOffDist[client][slot]  = StringToFloat( value );
        ReverseDamageFallOff[client][slot]      = true;
        action = Plugin_Handled;
    }
    else if ( StrEqual( attrib, "engie haul speed" ) )
    {
        EngineerHaulSpeedAmount[client][slot]   = StringToFloat( value );
        EngineerHaulSpeed[client][slot]         = true;
        action = Plugin_Handled;
    }
    if ( !m_bHasAttribute[client][slot] ) m_bHasAttribute[client][slot] = bool:action;
    return action;
}
public CW3_OnWeaponRemoved( slot, client )
{
    if ( IsValidClient( client ) )
    {
        if ( m_bHasAttribute[client][slot] )
        {
            m_bHasAttribute[client][slot] = false;

            NoDamageFallOff[client][slot]           = false;
            NoDamageFallOffMaxDist[client][slot]    = 0.0;
            NoDamageFallOffMinDist[client][slot]    = 0.0;

            NoDamageRampUp[client][slot]        = false;
            NoDamageRampUpMinDist[client][slot] = 0.0;

            ReduceAmmoOnHit[client][slot]       = false;
            ReduceAmmoOnHitVal[client][slot]    = 0.0;

            AmmoFromWrench[client][slot]        = false;
            AmmoFromWrenchAmount[client][slot]  = 0.0;

            ShootsMultiRockets[client][slot]            = false;
            ShootsMultiRocketsSpeed[client][slot]       = 0.0;
            ShootsMultiRocketsRandomness[client][slot]  = 0.0;
            ShootsMultiRocketsDMG[client][slot]         = 0.0;
            ShootsMultiRocketsRadius[client][slot]      = 0.0;
            ShootsMultiRocketsAmount[client][slot]      = 0;

            MeleeDmgResist[client][slot]        = false;
            MeleeDmgResistAmount[client][slot]  = 0.0;

            ReverseDamageFallOff[client][slot]      = false;
            ReverseDamageFallOffDist[client][slot]  = 0.0;

            EngineerHaulSpeed[client][slot]         = false;
            EngineerHaulSpeedAmount[client][slot]   = 0.0;
        }
    }
}

public Action:TraceAttack( victim, &attacker, &inflictor, &Float:damage, &type, &ammotype, hitbox, hitgroup )
{
    if ( damage >= 1.0
        && IsValidClient( victim )
        && IsValidClient( attacker )
        && !HasInvulnerabilityCond( victim )
        && attacker != victim )
    {
        new weapon = TF2_GetClientActiveWeapon( attacker );
        if ( weapon != -1 )
        {
            new slot = TF2_GetWeaponSlot( attacker, weapon );
            if ( slot != -1 && m_bHasAttribute[attacker][slot] )
            {
                new iCurrentMetal = TF2_GetClientMetal( attacker );
                new Float:percent = AmmoFromWrenchAmount[attacker][slot] - 1.0;
                new OnHitAmmo;

                new pool[2];
                pool[0] = GetAmmo( victim, 0, 1 );
                pool[1] = GetAmmo( victim, 1, 1 );

                new String:clname[64];
                if ( IsValidEdict( weapon ) ) GetEdictClassname( weapon, clname, sizeof( clname ) );
                
                if ( StrEqual( clname, "tf_weapon_wrench", false ) || StrEqual( clname, "tf_weapon_robot_arm", false ) )
                {
                    for ( new i = 0; i <= 1; i++ )
                    {
                        if ( pool[i] < AmmoTable[victim][i] )
                        {
                            OnHitAmmo = RoundFloat( percent * ( AmmoTable[victim][i] ) );
                            OnHitAmmo = ( iCurrentMetal < OnHitAmmo ) ? iCurrentMetal : OnHitAmmo;
                            OnHitAmmo = ( AmmoTable[victim][i] - pool[i] < OnHitAmmo ) ? AmmoTable[victim][i] - pool[i] : OnHitAmmo;
                            SetAmmo( victim, i, GetAmmo( victim, i, 1 ) + OnHitAmmo );
                        }
                    }
                    new iNewMetal = iCurrentMetal - ( OnHitAmmo/2 ); 
                    TF2_SetClientMetal( attacker, iNewMetal );
                }
            }
            else return Plugin_Continue;
        }
        else return Plugin_Continue;
    }
    return Plugin_Continue;
}
public Action:OnTakeDamage( victim, &attacker, &inflictor, &Float:damage, &type, &weapon, Float:damageForce[3], Float:damagePosition[3] )
{
    new Action:action;

    if ( damage >= 1.0
        && IsValidClient( victim )
        && IsValidClient( attacker )
        && !HasInvulnerabilityCond( victim )
        && attacker != victim )
    {
        if ( HasAttribute( victim, _, MeleeDmgResist ) && weapon != -1 && weapon == GetPlayerWeaponSlot( attacker, TFWeaponSlot_Melee ) && GetAttributeValue( victim, _, MeleeDmgResist, MeleeDmgResistAmount ) <= 0.0 ) {
            damage = 0.0;
        }

        if ( damage >= 1.0 )
        {
            if ( weapon != -1 )
            {
                new slot = TF2_GetWeaponSlot( attacker, weapon );
                if ( slot != -1 && m_bHasAttribute[attacker][slot] )
                {
                    decl Float:Pos[3];
                    decl Float:Pos2[3];
                    GetEntPropVector( attacker, Prop_Send, "m_vecOrigin", Pos );
                    GetEntPropVector( victim, Prop_Send, "m_vecOrigin", Pos2 );
                    new Float:dist = GetVectorDistance( Pos, Pos2, false );
                    new Float:min = 512.0;

                    if ( NoDamageFallOff[attacker][slot] && !( type & TF_DMG_CRIT ) ) {
                        if ( dist >= min )
                            damage *= ( dist/min );
                    }
                    if ( NoDamageRampUp[attacker][slot] && !( type & TF_DMG_CRIT ) ) {
                        if ( dist <= min )
                            damage *= ( dist/min );
                    }
                    if ( ReverseDamageFallOff[attacker][slot] )
                    {
                        dist = ( dist > ReverseDamageFallOffDist[attacker][slot] ) ? ReverseDamageFallOffDist[attacker][slot] : dist;
                        dist *= 0.003;
                        damage *= dist;
                    }
                    if ( ReduceAmmoOnHit[attacker][slot] )
                    {
                        new wepcache[2];

                        wepcache[0] = GetAmmo( victim, 0, 1 );
                        wepcache[1] = GetAmmo( victim, 1, 1 );    
                        for ( new g = 0; g <= 1; g++ )
                        {
                            new gunlaws = RoundFloat( wepcache[g]*( ReduceAmmoOnHitVal[attacker][slot]/1.0 ) );
                            new ammoe = ( wepcache[g]-gunlaws < 1 ) ? 0 : wepcache[g]-gunlaws;
                            SetAmmo( victim, g, ammoe );
                        }
                    }
                }
            }
        }

        if ( HasAttribute( victim, _, MeleeDmgResist ) ) {
            if ( weapon == GetPlayerWeaponSlot( attacker, TFWeaponSlot_Melee ) )
                damage *= GetAttributeValue( victim, _, MeleeDmgResist, MeleeDmgResistAmount );
        }
    }
    if ( damage < 0.0 ) damage == 0.0;

    action = Plugin_Changed;
    return action;
}

public Action:TF2_CalcIsAttackCritical( client, weapon, String:weaponname[], &bool:Crit )
{
    if ( IsValidClient( client )
        && IsPlayerAlive( client )
        && weapon != -1 )
    {
        new slot = TF2_GetWeaponSlot( client, weapon );
        if ( slot != -1 && m_bHasAttribute[client][slot] )
        {
            if ( ShootsMultiRockets[client][slot] )
            {
                new Float:vAngles[3],
                    Float:vAngles2[3],
                    Float:vPosition[3],
                    Float:vPosition2[3],
                    Float:Random = ShootsMultiRocketsRandomness[client][slot];
        
                GetClientEyeAngles( client, vAngles2 );
                GetClientEyePosition( client, vPosition2 );

                vPosition[0] = vPosition2[0];
                vPosition[1] = vPosition2[1];
                vPosition[2] = vPosition2[2];

                new Float:Random2 = Random*-1.0;
                new counter = 0;
                for ( new i = 0; i < ShootsMultiRocketsAmount[client][slot]; i++ )
                {
                    vAngles[0] = vAngles2[0] + GetRandomFloat( Random2,Random );
                    vAngles[1] = vAngles2[1] + GetRandomFloat( Random2,Random );
                    // avoid unwanted collision
                    new i2 = i%4;
                    switch( i2 )
                    {
                        case 0:
                        {
                            counter++;
                            vPosition[0] = vPosition2[0] + counter;
                        }
                        case 1: vPosition[1] = vPosition2[1] + counter;
                        case 2: vPosition[0] = vPosition2[0] - counter;
                        case 3: vPosition[1] = vPosition2[1] - counter;
                    }
                    fireProjectile( vPosition, vAngles, 1100.0*ShootsMultiRocketsSpeed[client][slot], 90.0*ShootsMultiRocketsDMG[client][slot], 146.0*ShootsMultiRocketsRadius[client][slot], GetClientTeam( client ), client, Crit );
                }
            }
        }
    }
    return Plugin_Continue;
}
fireProjectile( Float:vPosition[3], Float:vAngles[3] = NULL_VECTOR, Float:flSpeed = 1100.0, Float:flDamage = 90.0, Float:flRadius = 146.0, iTeam, client, bool:Crit )
{
    new String:strClassname[32] = "";
    new String:strEntname[32] = "";

    strClassname = "CTFProjectile_Rocket";
    strEntname = "tf_projectile_rocket";

    new iRocket = CreateEntityByName( strEntname );
    
    if( !IsValidEntity( iRocket ) )
        return -1;
    
    decl Float:vVelocity[3];
    decl Float:vBuffer[3];
    
    GetAngleVectors( vAngles, vBuffer, NULL_VECTOR, NULL_VECTOR );
    
    vVelocity[0] = vBuffer[0]*flSpeed;
    vVelocity[1] = vBuffer[1]*flSpeed;
    vVelocity[2] = vBuffer[2]*flSpeed;
    
    SetEntPropEnt( iRocket, Prop_Send, "m_hOwnerEntity", client );
    SetEntProp( iRocket,    Prop_Send, "m_iTeamNum",     iTeam, 1 );
    SetEntData( iRocket, FindSendPropOffs( strClassname, "m_nSkin" ), ( iTeam-2 ), 1, true );

    SetEntDataFloat( iRocket, FindSendPropOffs( strClassname, "m_iDeflected" ) + 4, flDamage, true ); // set damage
    if ( Crit ) SetEntProp( iRocket, Prop_Send, "m_bCritical", true );
    TeleportEntity( iRocket, vPosition, vAngles, vVelocity );

    SetVariantInt( iTeam );
    AcceptEntityInput( iRocket, "TeamNum", -1, -1, 0 );
    SetVariantInt( iTeam );
    AcceptEntityInput( iRocket, "SetTeam", -1, -1, 0 ); 
    
    DispatchSpawn( iRocket );
    
    return iRocket;
}
public Action:Event_Spawn( Handle:event, const String:name[], bool:dontBroadcast )
{
    new client = GetClientOfUserId( GetEventInt( event, "userid" ) );
    if ( IsValidClient( client ) )
    {
        for ( new i = 0; i < 5; i++ )
        {
            AmmoTable[client][i] = GetAmmo( client, i, 1 );
        }
    }
    return Plugin_Continue;
}


bool:HasAttribute( client, slot = -1, const attrib[][] = m_bHasAttribute, bool:active = false )
{
    if ( !IsValidClient( client ) ) return false;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( attrib[client][i] ) {
                    if ( slot == -1 || slot == i ) return true;
        }}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return false;

        new i = TF2_GetClientActiveSlot( client );
        if ( i != -1 ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( attrib[client][i] ) return true;
        }}
    }
    
    return false;
}
Float:GetAttributeValue( client, slot = -1, const bool:baseAttribute[][], const Float:attrib[][], bool:active = false )
{
    if ( !IsValidClient( client ) ) return 0.0;
    
    if ( !active ) {
        for ( new i = 0; i <= 4; i++ ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) {
                    if ( slot == -1 || slot == i ) return attrib[client][i];
        }}}
    }
    if ( active ) {
        if ( !IsPlayerAlive( client ) ) return 0.0;

        new i = TF2_GetClientActiveSlot( client );
        if ( i != -1 ) {
            if ( m_bHasAttribute[client][i] ) {
                if ( baseAttribute[client][i] ) return attrib[client][i];
        }}
    }
    
    return 0.0;
}