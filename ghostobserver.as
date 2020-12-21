array<CBaseEntity@> aryAnimation(32);
const string szGhostModel = "models/booghost.mdl";
const string szClassName = "camera_ghost";

void PluginInit()
{
	g_Module.ScriptInfo.SetAuthor( "DrAbc" );
	g_Module.ScriptInfo.SetContactInfo( "No Not me, maybe someone else" );

	g_Hooks.RegisterHook(Hooks::Player::PlayerEnteredObserver, @PlayerEnteredObserver);
	g_Hooks.RegisterHook(Hooks::Player::PlayerLeftObserver, @PlayerLeftObserver);
}

void MapInit()
{
	g_CustomEntityFuncs.RegisterCustomEntity( "CObserverGhost", szClassName );
	g_Game.PrecacheOther( szClassName );
}

class CObserverGhost : ScriptBaseAnimating
{
	void SetAnim( int animIndex ) 
	{
		self.pev.sequence = animIndex;
		self.pev.frame = 0;
		self.ResetSequenceInfo();
	}

	void Spawn()
	{
		if(self.pev.owner is null)
		{
			g_EntityFuncs.Remove(self);
			return;
		}

		Precache();

		self.pev.movetype = MOVETYPE_FOLLOW;
		self.pev.solid = SOLID_NOT;
		self.pev.colormap = self.pev.owner.vars.colormap;
		self.pev.rendermode = kRenderTransAdd;
		self.pev.renderamt = 80;
		//@self.pev.aiment = self.pev.owner;
		self.pev.model = szGhostModel;

		g_EntityFuncs.SetModel(self, self.pev.model);

		SetAnim(0);

		self.pev.nextthink = g_Engine.time + 0.1;
	}

	void Precache()
	{
		g_Game.PrecacheModel( szGhostModel );
		g_Game.PrecacheGeneric( szGhostModel );
	}

	void Think()
	{
		self.pev.angles = self.pev.owner.vars.angles;
		self.pev.origin = self.pev.owner.vars.origin;
		self.StudioFrameAdvance();
		self.pev.nextthink = g_Engine.time + 0.1;
	}
}

HookReturnCode PlayerEnteredObserver( CBasePlayer@ pPlayer )
{
	@aryAnimation[pPlayer.entindex()] = @g_EntityFuncs.Create( szClassName, pPlayer.pev.origin, pPlayer.pev.angles, false, pPlayer.edict() );
	return HOOK_HANDLED;
}

HookReturnCode PlayerLeftObserver( CBasePlayer@ pPlayer )
{
	aryAnimation[pPlayer.entindex()].SUB_Remove();
	return HOOK_HANDLED;
}
