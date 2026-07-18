local Utility = {}

Utility.ExpDecay = function(Speed: number, DeltaTime: number): number
	if not Speed or not DeltaTime then return 0 end
	return 1 - math.exp(-Speed * DeltaTime)
end

return Utility