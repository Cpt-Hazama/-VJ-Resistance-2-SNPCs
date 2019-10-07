AddCSLuaFile("shared.lua")
include('shared.lua')
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/vj_re2/hybrid1.mdl","models/vj_re2/hybrid2.mdl"} -- Leave empty if using more than one model
ENT.StartHealth = 80
ENT.MoveType = MOVETYPE_STEP
ENT.HullType = HULL_HUMAN
ENT.HullSizeNormal = true -- set to false to cancel out the self:SetHullSizeNormal()
---------------------------------------------------------------------------------------------------------------------------------------------
ENT.VJ_NPC_Class = {"CLASS_CHIMERA"}
ENT.Bleeds = true -- Does the SNPC bleed? (Blood decal, particle and etc.)
ENT.BloodParticle = "blood_impact_red_01" -- Particle that the SNPC spawns when it's damaged
ENT.BloodDecal = "Blood" -- (Red = Blood) (Yellow Blood = YellowBlood) | Leave blank for none
ENT.HasFootStepSound = true -- Should the SNPC make a footstep sound when it's moving?
ENT.HasMeleeAttack = true -- Should the SNPC have a melee attack?
ENT.AnimTbl_MeleeAttack = {"grenThrow"} -- Melee Attack Animations
ENT.MeleeAttackDistance = 30 -- How close does it have to be until it attacks?
ENT.MeleeAttackDamageDistance = 70 -- How far does the damage go?
ENT.TimeUntilMeleeAttackDamage = 0.7 -- This counted in seconds | This calculates the time until it hits something
ENT.NextAnyAttackTime_Melee = 0.35 -- How much time until it can use a attack again? | Counted in Seconds
ENT.MeleeAttackDamage = 20
ENT.FootStepTimeRun = 0.4 -- Next foot step sound when it is running
ENT.FootStepTimeWalk = 0.5 -- Next foot step sound when it is walking
ENT.SquadName = "vj_chimera" -- Squad name, console error will happen if two groups that are enemy and try to squad!
ENT.HasGrenadeAttack = true -- Should the SNPC have a grenade attack?
ENT.GrenadeAttackFussTime = 5 -- Time until the grenade explodes
ENT.GrenadeAttackEntity = "obj_vj_re2_blacklash" -- The entity that the SNPC throws | Half Life 2 Grenade: "npc_grenade_frag"
ENT.GrenadeAttackModel = "models/vj_re2/w_hopwire.mdl" -- The model for the grenade entity
ENT.AnimTbl_GrenadeAttack = {"grenDrop"}
ENT.HasCallForHelpAnimation = true -- if true, it will play the call for help animation
ENT.AnimTbl_CallForHelp = {ACT_SIGNAL_FORWARD} -- Call For Help Animations
	-- ====== Flinching Code ====== --
ENT.Flinches = 1 -- 0 = No Flinch | 1 = Flinches at any damage | 2 = Flinches only from certain damages
ENT.FlinchingChance = 12 -- chance of it flinching from 1 to x | 1 will make it always flinch
ENT.FlinchingSchedules = {SCHED_FLINCH_PHYSICS} -- If self.FlinchUseACT is false the it uses this | Common: SCHED_BIG_FLINCH, SCHED_SMALL_FLINCH, SCHED_FLINCH_PHYSICS
	-- ====== Sound File Paths ====== --
-- Leave blank if you don't want any sounds to play
ENT.SoundTbl_FootStep = {"player/footsteps/metal1.wav","player/footsteps/metal2.wav","player/footsteps/metal3.wav","player/footsteps/metal4.wav"}
ENT.SoundTbl_Alert = {"vj_re2/deep_yell.wav"}
ENT.SoundTbl_CombatIdle = {"vj_re2/deep_yell.wav"}
ENT.SoundTbl_Pain = {"vj_re2/yell01.wav","vj_re2/yell02.wav"}
ENT.SoundTbl_Death = {"vj_re2/deep_yell.wav"}
ENT.SoundTbl_MeleeAttack = {"npc/zombie/claw_strike1.wav","npc/zombie/claw_strike2.wav","npc/zombie/claw_strike3.wav"}
	-- ====== Sound Levels ====== --
-- EmitSound is from 0 to 511 | CreateSound is from 0 to 180
-- More Information: https://developer.valvesoftware.com/wiki/Soundscripts#SoundLevel_Flags
ENT.CombatIdleSoundLevel = 90
ENT.AlertSoundLevel = 90
ENT.PainSoundLevel = 90
ENT.DeathSoundLevel = 90
	-- ====== Sound Pitch ====== --
-- Higher number = Higher pitch | Lower number = Lower pitch
-- Highest number is 254
-- ENT.CombatIdleSoundPitch1 = 60
-- ENT.CombatIdleSoundPitch2 = 75
-- ENT.AlertSoundPitch1 = 60
-- ENT.AlertSoundPitch2 = 75
-- ENT.PainSoundPitch1 = 60
-- ENT.PainSoundPitch2 = 75
-- ENT.DeathSoundPitch1 = 60
-- ENT.DeathSoundPitch2 = 75
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomInitialize()
	if self:GetModel() == "models/vj_re2/hybrid1.mdl" then
		self:SetSkin(math.random(0,11))
		self:SetBodygroup(0,math.random(0,3))
		self:SetBodygroup(1,math.random(0,1))
	else
		self:SetSkin(math.random(0,8))
		self:SetBodygroup(1,math.random(0,1))
		self:SetBodygroup(2,math.random(0,1))
		self:SetBodygroup(3,math.random(0,1))
		self:SetBodygroup(4,math.random(0,1))
		self:SetBodygroup(5,math.random(0,1))
		self:SetBodygroup(6,math.random(0,1))
		self:SetBodygroup(7,math.random(0,1))
	end
	if self:GetBodygroup(1) == 0 then
		self.GlowLight = ents.Create("light_dynamic")
		self.GlowLight:SetKeyValue("_light","255 160 0 225")
		self.GlowLight:SetKeyValue("brightness","2")
		self.GlowLight:SetKeyValue("distance","80")
		self.GlowLight:SetKeyValue("style","0")
		self.GlowLight:SetPos(self:GetPos() +self:OBBCenter() +Vector(0,0,18))
		self.GlowLight:SetParent(self)
		-- self.GlowLight:Fire("SetParentAttachment","head")
		self.GlowLight:Spawn()
		self.GlowLight:Activate()
		self.GlowLight:Fire("TurnOn","",0)
		self.GlowLight:DeleteOnRemove(self)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnThink()
	self.AnimTbl_Walk = {self:GetSequenceActivity(self:LookupSequence("WalkEasy_all"))}
	if self.GlowLight != nil then
		self.GlowLight:SetPos(self:GetPos() +self:OBBCenter() +Vector(0,0,18))
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnTakeDamage_OnBleed(dmginfo,hitgroup)
	if (dmginfo:IsBulletDamage()) then
		local attacker = dmginfo:GetAttacker()
		local trace = {}
		trace.start = attacker:GetShootPos()
		trace.endpos = trace.start +((dmginfo:GetDamagePosition() -trace.start) *2)  
		trace.mask = MASK_SHOT
		trace.filter = attacker
		local tr = util.TraceLine(trace)
		hitgroup = tr.HitGroup
		self:EmitSound("physics/metal/metal_solid_impact_bullet" .. math.random(1,4) .. ".wav",70)
		dmginfo:ScaleDamage(0.75)
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnKilled(dmginfo,hitgroup)
	if self:GetBodygroup(1) == 0 then
		-- if (dmginfo:IsBulletDamage()) then
			ParticleEffect("vj_explosion2",self:GetPos() +self:OBBCenter(),Angle(0,0,0),nil)
			util.BlastDamage(self,self,self:GetPos(),500,40)
			util.ScreenShake(self:GetPos(),100,200,0.6,500)
		-- end
	end
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2015 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/