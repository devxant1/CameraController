local UserInputService = game:GetService("UserInputService")

local Types = require(script.Parent.Parent.Types)
local State = require(script.Parent.Parent.State) :: Types.State

local Default = {}
Default.Config = {}
Default.Init = function()
	State.Camera.CameraType = Enum.CameraType.Custom
	--UserInputService.MouseBehavior = Enum.MouseBehavior.LockCenter
end
Default.Destroy = function()

end
Default.Render = function(DeltaTime: number)
	return State.Camera.CFrame
end

return Default
