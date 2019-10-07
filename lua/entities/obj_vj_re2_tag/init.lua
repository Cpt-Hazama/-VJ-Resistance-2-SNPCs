AddCSLuaFile("shared.lua")
include("shared.lua")
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/
ENT.Model = {"models/weapons/w_missile_launch.mdl"} -- The models it should spawn with | Picks a random one from the table
ENT.DoesRadiusDamage = true -- Should it do a blast damage when it hits something?
ENT.RadiusDamageRadius = 5 -- How far the damage go? The farther away it's from its enemy, the less damage it will do | Counted in world units
ENT.RadiusDamage = 5 -- How much damage should it deal? Remember this is a radius damage, therefore it will do less damage the farther away the entity is from its enemy
ENT.RadiusDamageUseRealisticRadius = true -- Should the damage decrease the farther away the enemy is from the position that the projectile hit?
ENT.RadiusDamageType = DMG_BULLET -- Damage type
ENT.RadiusDamageUseForce = true -- Should it push props and ragdolls?
ENT.RadiusDamageForceTowardsPhysics = 300 -- How much force should it deal to props?
ENT.RadiusDamageForceTowardsRagdolls = 300 -- How much force should it deal to ragdolls?
-- ENT.DecalTbl_DeathDecals = {"fadingscorch"}
-- ENT.SoundTbl_OnCollide = {"weapons/airboat/airboat_gun_energy1.wav"}
ENT.CreateColor = Color(255,160,0,225)
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:CustomOnInitialize()
	self:SetMaterial("models/effects/vol_light001.mdl")
	self:DrawShadow(false)
	self:SetNoDraw(true)
	self:SetColor(self.CreateColor)
	
	-- util.SpriteTrail(self, 0, Color(255,160,0,255), false, 15, 15, 0.2, 1/(10+1)*0.5, "VJ_Base/sprites/vj_trial1.vmt") //cable/redlaser.vmt
	util.SpriteTrail(self,6,Color(255,160,0,255),true,2,2,0.1,1/(6+6)*0.8,"VJ_Base/sprites/vj_trial1.vmt")
	
	local eyeglow2 = ents.Create("env_sprite")
	eyeglow2:SetKeyValue("model","vj_base/sprites/vj_glow1.vmt")
	eyeglow2:SetKeyValue("scale","0.06")
	eyeglow2:SetKeyValue("rendermode","5")
	eyeglow2:SetKeyValue("rendercolor","255 160 0 225")
	eyeglow2:SetKeyValue("spawnflags","1") -- If animated
	eyeglow2:SetPos(self:GetPos())
	eyeglow2:SetParent(self)
	//eyeglow2:Fire("SetParentAttachment","eye2",0)
	eyeglow2:Spawn()
	eyeglow2:Activate()
	self:DeleteOnRemove(eyeglow2)

	self.StartLight1 = ents.Create("light_dynamic")
	self.StartLight1:SetKeyValue("brightness", "0.05")
	self.StartLight1:SetKeyValue("distance", "20")
	self.StartLight1:SetLocalPos(self:GetPos())
	self.StartLight1:SetLocalAngles( self:GetAngles() )
	self.StartLight1:Fire("Color", "255 160 0 255")
	self.StartLight1:SetParent(self)
	self.StartLight1:Spawn()
	self.StartLight1:Activate()
	self.StartLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(self.StartLight1)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function ENT:DeathEffects(data,phys)
	local effectdata = EffectData()
	effectdata:SetOrigin(data.HitPos)
	util.Effect("AR2Impact", effectdata)
end
/*-----------------------------------------------
	*** Copyright (c) 2012-2016 by DrVrej, All rights reserved. ***
	No parts of this code or any of its contents may be reproduced, copied, modified or adapted,
	without the prior written consent of the author, unless otherwise indicated for stand-alone materials.
-----------------------------------------------*/