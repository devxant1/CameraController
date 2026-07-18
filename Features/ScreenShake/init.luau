local ScreenShake = {}
local ShakeInstance = require(script.ShakeInstance)
local ShakeState = require(script.ShakeState)
local ShakePresets = require(script.ShakePresets)

local ShakeInstanceCache: { ShakeInstance.ShakeInstance } = {}

function ScreenShake:ShakeOnce(Parameters)
	if not Parameters then
		Parameters = {}
	else
		if typeof(Parameters) == "string" then
			Parameters = ShakePresets[Parameters]
		end
	end
	
	local CreatedInstance = ShakeInstance.new(Parameters)
	
	table.insert(ShakeInstanceCache, CreatedInstance)
	return CreatedInstance
end

function ScreenShake:ShakeSustain(Parameters)
	if not Parameters then
		Parameters = {}
	else
		if typeof(Parameters) == "string" then
			Parameters = ShakePresets[Parameters]
		end
	end
	
	local CreatedInstance = ShakeInstance.new(Parameters)
	CreatedInstance.Sustained = true
	CreatedInstance.DeleteOnInactive = false
	CreatedInstance.State = ShakeState.Sustained
	CreatedInstance.CurrentFadeTime = 1
	
	table.insert(ShakeInstanceCache, CreatedInstance)
	return CreatedInstance
end

function ScreenShake:StopSustained(FadeOutTime: number?)
	for _, CachedInstance in ShakeInstanceCache do
		if CachedInstance.Sustained and CachedInstance:IsActive() then
			CachedInstance:StartFadeOut(FadeOutTime)
		end
	end
end

function ScreenShake:StopAll(FadeOutTime: number?)
	if FadeOutTime and FadeOutTime > 0 then
		for _, CachedInstance in ShakeInstanceCache do
			if CachedInstance:IsActive() then
				CachedInstance:StartFadeOut(FadeOutTime)
			end
		end
	else
		table.clear(ShakeInstanceCache)
	end
end

function ScreenShake:GetActiveCount(): number
	local Count = 0
	
	for _, CachedInstance in ShakeInstanceCache do
		if CachedInstance:IsActive() then
			Count += 1
		end
	end
	
	return Count
end

function ScreenShake:Update(DeltaTime: number): CFrame
	if #ShakeInstanceCache == 0 then
		return CFrame.identity
	end

	local TotalPositionX, TotalPositionY, TotalPositionZ = 0, 0, 0
	local TotalRotationX, TotalRotationY, TotalRotationZ = 0, 0, 0

	local Index = 1
	while Index <= #ShakeInstanceCache do
		local CachedInstance = ShakeInstanceCache[Index]

		if not CachedInstance:IsActive() then
			if CachedInstance.DeleteOnInactive then
				ShakeInstanceCache[Index] = ShakeInstanceCache[#ShakeInstanceCache]
				ShakeInstanceCache[#ShakeInstanceCache] = nil
			else
				Index += 1
			end
		else
			local Position, Rotation = CachedInstance:UpdateShake(DeltaTime)
			TotalPositionX += Position.X
			TotalPositionY += Position.Y
			TotalPositionZ += Position.Z
			TotalRotationX += Rotation.X
			TotalRotationY += Rotation.Y
			TotalRotationZ += Rotation.Z
			Index += 1
		end
	end

	if TotalPositionX == 0 and TotalPositionY == 0 and TotalPositionZ == 0 and TotalRotationX == 0 and TotalRotationY == 0 and TotalRotationZ == 0 then
		return CFrame.identity
	end

	return CFrame.new(TotalPositionX, TotalPositionY, TotalPositionZ) * CFrame.Angles(math.rad(TotalRotationX), math.rad(TotalRotationY), math.rad(TotalRotationZ))
end

return ScreenShake
