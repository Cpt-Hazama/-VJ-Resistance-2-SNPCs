if (!file.Exists("autorun/vj_base_autorun.lua","LUA")) then return end
---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Base 						= "weapon_vj_base"
SWEP.PrintName					= "Bullseye"
SWEP.Author 					= "Cpt. Hazama"
SWEP.Contact					= "http://steamcommunity.com/groups/vrejgaming"
SWEP.Purpose					= "This weapon is made for Players and NPCs"
SWEP.Instructions				= "Controls are like a regular weapon."
-- SWEP.Category					= "VJ Resistance"
	-- Client Settings ---------------------------------------------------------------------------------------------------------------------------------------------
if (CLIENT) then
SWEP.Slot						= 2 -- Which weapon slot you want your SWEP to be in? (1 2 3 4 5 6) 
SWEP.SlotPos					= 4 -- Which part of that slot do you want the SWEP to be in? (1 2 3 4 5 6)
SWEP.UseHands					= true
end
	-- NPC Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.NPC_NextPrimaryFire 		= 0.09 -- Next time it can use primary fire
SWEP.MadeForNPCsOnly 			= true
	-- Main Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.ViewModel					= "models/weapons/cstrike/c_rif_famas.mdl"
SWEP.WorldModel					= "models/weapons/w_irifle.mdl"
SWEP.HoldType 					= "ar2"
SWEP.Spawnable					= false
SWEP.AdminSpawnable				= false
	-- Primary Fire ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Primary.Damage				= 5 -- Damage
SWEP.Secondary.PlayerDamage		= 2 -- Put 1 to make it the same as above
SWEP.Primary.Force				= 5 -- Force applied on the object the bullet hits
SWEP.Primary.NumberOfShots		= 1 -- How many shots per attack?
SWEP.Primary.ClipSize			= 70 -- Max amount of bullets per clip
SWEP.Primary.DefaultClip		= 280 -- How much ammo do you get when you first pick up the weapon?
SWEP.Primary.Recoil				= 0.6 -- How much recoil does the player get?
SWEP.Primary.Cone				= 7 -- How accurate is the bullet? (Players)
SWEP.Primary.Delay				= 0.09 -- Time until it can shoot again
SWEP.Primary.Tracer				= 1
SWEP.Primary.TakeAmmo			= 1 -- How much ammo should it take on each shot?
SWEP.Primary.Automatic			= true -- Is it automatic?
SWEP.Primary.Ammo				= "AR2" -- Ammo type
SWEP.Primary.Sound				= "vj_re2/weapons/bullseye_fire.wav"
SWEP.Primary.HasDistantSound	= false -- Does it have a distant sound when the gun is shot?
SWEP.Primary.DisableBulletCode	= true -- The bullet won't spawn, this can be used when creating a projectile-based weapon
	-- Deployment Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.DelayOnDeploy 				= 1 -- Time until it can shoot again after deploying the weapon
	-- Reload Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.Reload_TimeUntilAmmoIsSet	= 1.6 -- Time until ammo is set to the weapon
-- SWEP.AnimTbl_Reload				= {ACT_VM_PRIMARYATTACK}
SWEP.Reload_TimeUntilFinished	= 1.7 -- How much time until the player can play idle animation, shoot, etc.
	-- Idle Settings ---------------------------------------------------------------------------------------------------------------------------------------------
SWEP.HasIdleAnimation			= true -- Does it have a idle animation?
SWEP.AnimTbl_Idle				= {ACT_VM_IDLE}
SWEP.NextIdle_Deploy			= 0.5 -- How much time until it plays the idle animation after the weapon gets deployed
SWEP.NextIdle_PrimaryAttack		= 0.02 -- How much time until it plays the idle animation after attacking(Primary)
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:CustomOnPrimaryAttack_BeforeShoot()
if (CLIENT) then return end
	local SpawnBlaserRod = ents.Create("obj_vj_re2_tag")
	local OwnerPos = self.Owner:GetShootPos()
	local OwnerAng = self.Owner:GetAimVector():Angle()
	OwnerPos = OwnerPos + OwnerAng:Forward()*-33 + OwnerAng:Up()*-4 + OwnerAng:Right()*6
	if self.Owner:IsPlayer() then SpawnBlaserRod:SetPos(OwnerPos) else SpawnBlaserRod:SetPos(self:GetAttachment(self:LookupAttachment("muzzle")).Pos) end
	if self.Owner:IsPlayer() then SpawnBlaserRod:SetAngles(OwnerAng) else SpawnBlaserRod:SetAngles(self.Owner:GetAngles()) end
	SpawnBlaserRod:SetOwner(self.Owner)
	SpawnBlaserRod:Activate()
	SpawnBlaserRod:Spawn()
	
	local phy = SpawnBlaserRod:GetPhysicsObject()
	if phy:IsValid() then
		if self.Owner:IsPlayer() then
		phy:ApplyForceCenter(self.Owner:GetAimVector() * 2500) else //200000
		phy:ApplyForceCenter((self.Owner:GetEnemy():GetPos() - self.Owner:GetPos() + self.Owner:GetEnemy():GetUp()*math.random(-20,20) + self.Owner:GetEnemy():GetRight()*math.random(-20,20)):GetNormal() * 2500)
		end
	end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPC_ServerNextFire()
	if (CLIENT) then return end
	if !self:IsValid() && !IsValid(self.Owner) && !self.Owner:IsValid() && !self.Owner:IsNPC() then return end
	if self:IsValid() && IsValid(self.Owner) && self.Owner:IsValid() && self.Owner:IsNPC() && self.Owner:GetActivity() == nil then return end
	self:RunWorldModelThink()
	self:CustomOnThink()
	self:CustomOnNPC_ServerThink()
	if self.Owner.HasDoneReloadAnimation == false && self.AlreadyPlayedNPCReloadSound == false && (VJ_IsCurrentAnimation(self.Owner,self.CurrentAnim_WeaponReload) or VJ_IsCurrentAnimation(self.Owner,self.CurrentAnim_ReloadBehindCover) or VJ_IsCurrentAnimation(self.Owner,self.NPC_ReloadAnimationTbl) or VJ_IsCurrentAnimation(self.Owner,self.NPC_ReloadAnimationTbl_Custom)) then
		self.Owner.NextThrowGrenadeT = self.Owner.NextThrowGrenadeT + 2
		self.Owner.HasDoneReloadAnimation = true
		self:CustomOnNPC_Reload()
		self.AlreadyPlayedNPCReloadSound = true
		if self.NPC_HasReloadSound == true then VJ_EmitSound(self.Owner,self.NPC_ReloadSound,self.NPC_ReloadSoundLevel) end
		timer.Simple(3,function() if IsValid(self) then self.AlreadyPlayedNPCReloadSound = false end end)
	end

	-- local function FireCode()
		-- self:NPCShoot_PrimaryExtra(ShootPos,ShootDir)
		-- hook.Remove("Think", self)
	-- end
	-- local function FireCode2()
		-- self:NPCShoot_PrimaryExtra(ShootPos,ShootDir)
		-- hook.Remove("Think", self)
	-- end
	local function FireCode()
		timer.Simple(0.1, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		timer.Simple(0.2, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		timer.Simple(0.3, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		timer.Simple(0.4, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		timer.Simple(0.5, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		-- timer.Simple(0.6, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		-- timer.Simple(0.7, function() if IsValid(self) then self:NPCShoot_PrimaryExtra(ShootPos,ShootDir) end end)
		self:NPCShoot_Primary(ShootPos,ShootDir)
		hook.Remove("Think", self)
		timer.Simple(1, function() hook.Add("Think",self,self.NPC_ServerNextFire) end)
	end
	if self:NPCAbleToShoot() == true then FireCode() end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:NPCShoot_PrimaryExtra(ShootPos,ShootDir)
	//self:SetClip1(self:Clip1() -1)
	if (!self:IsValid()) or (!self.Owner:IsValid()) then return end
	if (!self.Owner:GetEnemy()) then return end
	if (!self.Owner:GetEnemy():Visible(self.Owner)) then return end
	if self.Owner.IsVJBaseSNPC == true then
		self.Owner.Weapon_TimeSinceLastShot = 0
		self.Owner.NextWeaponAttackAimPoseParametersReset = CurTime() + 1
		self.Owner:WeaponAimPoseParameters()
	end
	-- timer.Simple(self.NPC_TimeUntilFire,function()
	-- if IsValid(self) && IsValid(self.Owner) then
		self:PrimaryAttack()
		-- end
	-- end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttack(ShootPos,ShootDir)
	//if self.Owner:KeyDown(IN_RELOAD) then return end
	//self.Owner:SetFOV( 45, 0.3 )
	self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	if self.Reloading == true then return end
	if self.Owner:IsNPC() && self.Owner:GetEnemy() == nil then return end
	if self.Owner:IsPlayer() && self.Primary.AllowFireInWater == false && self.Owner:WaterLevel() == 3 && self.Reloading == false then 
	self.Weapon:EmitSound(Sound(self.DryFireSound),50,math.random(90,100)) return end
	if (!self:CanPrimaryAttack()) then return end
	if self:Clip1() <= 0 && self.Reloading == false then
	self.Weapon:EmitSound(Sound(self.DryFireSound),50,math.random(90,100)) return end
	self:CustomOnPrimaryAttack_BeforeShoot()
	if (SERVER) then
		sound.Play(Sound(self.Primary.Sound),self:GetPos(),95,math.random(90,100))
		if self.Primary.HasDistantSound == true then
		sound.Play(Sound(self.Primary.DistantSound),self:GetPos(),self.Primary.DistantSoundLevel,math.random(self.Primary.DistantSoundPitch1,self.Primary.DistantSoundPitch2),self.Primary.DistantSoundVolume)
		end
	end
	//self.Weapon:EmitSound(Sound(self.Primary.Sound),80,self.Primary.SoundPitch)
	if self.Primary.DisableBulletCode == false then
	local bullet = {}
		bullet.Num = self.Primary.NumberOfShots
		bullet.Src = self.Owner:GetShootPos()
		bullet.Dir = self.Owner:GetAimVector()
			/*bullet.Callback = function(attacker, tr, dmginfo)
			local laserhit = EffectData()
			laserhit:SetOrigin(tr.HitPos)
			laserhit:SetNormal(tr.HitNormal)
			laserhit:SetScale(80)
			util.Effect("VJ_Small_Explosion1", laserhit)
			
			bullet.Callback = function(attacker, tr, dmginfo)
			local laserhit = EffectData()
			laserhit:SetOrigin(tr.HitPos)
			laserhit:SetNormal(tr.HitNormal)
			laserhit:SetScale(25)
			util.Effect("AR2Impact", laserhit)
			end*/
			//tr.HitPos:Ignite(8,0)
			//return true end
		if self.Owner:IsPlayer() then
			bullet.Spread = Vector((self.Primary.Cone /60)/4,(self.Primary.Cone /60)/4,0)
		end
		bullet.Tracer = self.Primary.Tracer
		bullet.TracerName = self.Primary.TracerType
		bullet.Force = self.Primary.Force
		if self.Owner:IsPlayer() then
			if self.Primary.UseNegativePlayerDamage == true then
			bullet.Damage = self.Primary.Damage -self.Primary.PlayerDamage else
			bullet.Damage = self.Primary.Damage *self.Primary.PlayerDamage end
		else
			bullet.Damage = self.Primary.Damage
		end
		bullet.AmmoType = self.Primary.Ammo
	self.Owner:FireBullets(bullet)
	else
	if self.Owner:IsNPC() && self.Owner.IsVJBaseSNPC == true then
		self.Owner.Weapon_ShotsSinceLastReload = self.Owner.Weapon_ShotsSinceLastReload + 1
		end
	end
	if GetConVarNumber("vj_wep_nomuszzleflash") == 0 then
	self.Owner:MuzzleFlash() end
	self:PrimaryAttackEffects()
	if self.Owner:IsPlayer() then
	self:ShootEffects("ToolTracer")
	self.Weapon:SendWeaponAnim(VJ_PICKRANDOMTABLE(self.AnimTbl_PrimaryFire))
	self.Owner:SetAnimation(PLAYER_ATTACK1)
	self.Owner:ViewPunch(Angle(-self.Primary.Recoil,0,0)) end
	if !self.Owner:IsNPC() then
		self:TakePrimaryAmmo(self.Primary.TakeAmmo)
	end
	self:CustomOnPrimaryAttack_AfterShoot()
	//self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
	timer.Simple(self.NextIdle_PrimaryAttack,function() if self:IsValid() then self:DoIdleAnimation() end end)
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:PrimaryAttackEffects()
	/*local vjeffectmuz = EffectData()
	vjeffectmuz:SetOrigin(self.Owner:GetShootPos())
	vjeffectmuz:SetEntity(self.Weapon)
	vjeffectmuz:SetStart(self.Owner:GetShootPos())
	vjeffectmuz:SetNormal(self.Owner:GetAimVector())
	vjeffectmuz:SetAttachment(1)
	vjeffectmuz:SetMagnitude(0)
	util.Effect("VJ_Weapon_RifleMuzzle1",vjeffectmuz)*/
	
	/*if GetConVarNumber("vj_wep_nobulletshells") == 0 then
	if !self.Owner:IsPlayer() then
	local vjeffect = EffectData()
	vjeffect:SetEntity(self.Weapon)
	vjeffect:SetOrigin(self.Owner:GetShootPos())
	vjeffect:SetNormal(self.Owner:GetAimVector())
	vjeffect:SetAttachment(1)
	util.Effect("VJ_Weapon_RifleShell1",vjeffect) end
	end*/

	if (SERVER) then
	if GetConVarNumber("vj_wep_nomuszzleflash") == 0 then
	local FireLight1 = ents.Create("light_dynamic")
	FireLight1:SetKeyValue("brightness", "2")
	if self.Owner:IsPlayer() then
	FireLight1:SetKeyValue("distance", "150") else FireLight1:SetKeyValue("distance", "150") end
	FireLight1:SetLocalPos(self.Owner:GetShootPos() +self:GetForward()*40 + self:GetUp()*-40)
	FireLight1:SetLocalAngles(self:GetAngles())
	FireLight1:Fire("Color", "255 160 0 255")
	FireLight1:SetParent(self)
	FireLight1:Spawn()
	FireLight1:Activate()
	FireLight1:Fire("TurnOn", "", 0)
	self:DeleteOnRemove(FireLight1)
	timer.Simple(0.07,function() if self:IsValid() then FireLight1:Remove() end end)
	end
 end
end
---------------------------------------------------------------------------------------------------------------------------------------------
function SWEP:FireAnimationEvent(pos,ang,event,options)
	/*local vjeffect = EffectData()
	vjeffect:SetEntity(self.Weapon)
	vjeffect:SetOrigin(self.Owner:GetShootPos())
	vjeffect:SetNormal(self.Owner:GetAimVector())
	vjeffect:SetAttachment(2)
	util.Effect("VJ_Weapon_RifleShell1",vjeffect)*/
	
	//print(event)
	/*if GetConVarNumber("vj_wep_nomuszzleflash") == 1 then
	if event == 5001 then 
		return true end 
	end
	
	if GetConVarNumber("vj_wep_nobulletshells") == 1 then
	if event == 20 then 
		return true end 
	end*/
end