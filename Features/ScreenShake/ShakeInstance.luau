local ShakeState = require(script.Parent.ShakeState)

local ShakeInstance = {}
ShakeInstance.__index = ShakeInstance

export type ShakeInstance = typeof(setmetatable({} :: {}, ShakeInstance))

function ShakeInstance.new(Parameters): ShakeInstance
	Parameters = Parameters or {}
	
	local self = setmetatable({
		Magnitude = Parameters.Magnitude or 1,
		Roughness = Parameters.Roughness or 1,
		PositionInfluence = Parameters.PositionInfluence or Vector3.new(0.15, 0.15, 0.15),
		RotationInfluence = Parameters.RotationInfluence or Vector3.new(1, 1, 1),
		FadeInTime = Parameters.FadeInTime or 0,
		FadeOutTime = Parameters.FadeOutTime or 0,
		CurrentFadeTime = Parameters.CurrentFadeTime or ((Parameters.FadeInTime and Parameters.FadeInTime > 0) and 0 or 1),
		RoughnessMod = Parameters.RoughnessMod or 1,
		MagnitudeMod = Parameters.MagnitudeMod or 1,
		
		Tick = math.random() * 100,
		Seed = math.random(0, 2^16),
		State = Parameters.State or ((Parameters.FadeInTime and Parameters.FadeInTime > 0) and ShakeState.FadingIn or ShakeState.Sustained),
		DeleteOnInactive = Parameters.DeleteOnInactive or true,
		Sustained = false,
	}, ShakeInstance)
	
	return self
end

function ShakeInstance:GetState(): number
	return self.State
end

function ShakeInstance:IsActive(): boolean
	return self.State ~= ShakeState.Inactive
end

function ShakeInstance:IsSustained(): boolean
	return self.Sustained
end

function ShakeInstance:SetRoughnessMod(Mod: number)
	self.RoughnessMod = Mod or 1
end

function ShakeInstance:SetMagnitudeMod(Mod: number)
	self.MagnitudeMod = Mod or 1
end

function ShakeInstance:StartFadeOut(FadeOutTime: number?)
	if self.State == ShakeState.Inactive then return end
	
	self.FadeOutTime = FadeOutTime or self.FadeOutTime
	self.State = ShakeState.FadingOut
	self.CurrentFadeTime = 1
end

function ShakeInstance:UpdateState(DeltaTime: number): number
	if self.State == ShakeState.Sustained then
		return 1
	elseif self.State == ShakeState.FadingIn then
		self.CurrentFadeTime = self.FadeInTime > 0 and math.min(1, self.CurrentFadeTime + DeltaTime / self.FadeInTime) or 1

		if self.CurrentFadeTime >= 1 then
			self.State = self.Sustained and ShakeState.Sustained or ShakeState.FadingOut
		end

		return self.CurrentFadeTime
	elseif self.State == ShakeState.FadingOut then
		self.CurrentFadeTime = self.FadeOutTime > 0 and math.max(0, self.CurrentFadeTime - DeltaTime / self.FadeOutTime) or 0

		if self.CurrentFadeTime <= 0 then
			self.State = ShakeState.Inactive
		end

		return self.CurrentFadeTime
	end

	return 0
end

function ShakeInstance:UpdateShake(DeltaTime: number): (Vector3, Vector3)
	local Envelope = self:UpdateState(DeltaTime)
	if Envelope <= 0 then
		return Vector3.zero, Vector3.zero
	end

	local Magnitude = self.Magnitude * self.MagnitudeMod * Envelope
	local Roughness = self.Roughness * self.RoughnessMod
	
	self.Tick += DeltaTime * Roughness

	local Tick = self.Tick
	local Seed = self.Seed

	local NoiseX = math.noise(Tick, Seed * 0.1, 0) * 2 + math.noise(Tick * 2.3, Seed * 0.3, Seed * 0.7) * 0.5
	local NoiseY = math.noise(Seed * 0.1, Tick, 0) * 2 + math.noise(Seed * 0.3, Tick * 2.3, Seed * 0.7) * 0.5
	local NoiseZ = math.noise(0, Seed * 0.1, Tick) * 2 + math.noise(Seed * 0.7, Seed * 0.3, Tick * 2.3) * 0.5

	local PositionInfluence = self.PositionInfluence
	local RotationInfluence = self.RotationInfluence
	
	return Vector3.new(
		NoiseX * Magnitude * PositionInfluence.X,
		NoiseY * Magnitude * PositionInfluence.Y,
		NoiseZ * Magnitude * PositionInfluence.Z
	), Vector3.new(
		NoiseX * Magnitude * RotationInfluence.X,
		NoiseY * Magnitude * RotationInfluence.Y,
		NoiseZ * Magnitude * RotationInfluence.Z
	)
end

return ShakeInstance :: typeof(ShakeInstance)