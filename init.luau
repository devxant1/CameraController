local RunService = game:GetService("RunService")

local Features = script:WaitForChild("Features")
local ScreenShake = require(Features.ScreenShake)

local State = require(script.State)
local Utility = require(script.Utility)
local Types = require(script.Types)

local Modes = {
	Default = require(script.Modes.Default),
	TestMode = require(script.Modes.TestMode)
}

local CameraController = {
	Enabled = false,
	Mode = "Default" -- "Default", "Free", "Fixed", "Orbital", "Cinematic"
}

function CameraController:Enable()
	if CameraController.Enabled then return end
	
	Modes[CameraController.Mode].Init()
	
	RunService:BindToRenderStep("CCR", Enum.RenderPriority.Camera.Value + 1, RenderStep)
	
	State:Set("Rendering", true)
	
	CameraController.Enabled = true
end

function CameraController:Disable()
	if not CameraController.Enabled then return end
	
	State:Set("Rendering", false)
	
	RunService:UnbindFromRenderStep("CCR")
	
	CameraController.Enabled = false
end

function CameraController:SetMode(Mode: Types.Mode, ModeTransitionParameters)
	if CameraController.Mode == Mode then return end
	
	ModeTransitionParameters = ModeTransitionParameters or {}
	
	State:Update({
		ModeTransitionAlpha = ModeTransitionParameters.TransitionAlpha or 0,
		ModeTransitionSpeed = ModeTransitionParameters.TransitionSpeed or 1,
		ModeTransitionCFrame = ModeTransitionParameters.TransitionCFrame or State:Get("Camera").CFrame
	})
	
	Modes[CameraController.Mode].Destroy()
	Modes[Mode].Init()
	
	CameraController.Mode = Mode
end

function RenderStep(DeltaTime)
	DeltaTime = math.min(DeltaTime, 0.1)
	
	local ShakeCFrame = ScreenShake:Update(DeltaTime)
	local GameplayCFrame = Modes[CameraController.Mode].Render(DeltaTime)

	if State:Get("ModeTransitionAlpha") < 1 then
		State:Set("ModeTransitionAlpha", math.min(State:Get("ModeTransitionAlpha") + Utility.ExpDecay(State:Get("ModeTransitionSpeed"), DeltaTime), 1))
	end
	
	if State:Get("ModeTransitionAlpha") < 0.999 and State:Get("ModeTransitionCFrame") then
		GameplayCFrame = State:Get("ModeTransitionCFrame"):Lerp(GameplayCFrame, State:Get("ModeTransitionAlpha"))
	end
	
	if ShakeCFrame ~= CFrame.identity then
		GameplayCFrame *= ShakeCFrame
	end
	
	workspace.CurrentCamera.CFrame = GameplayCFrame * ShakeCFrame
end

CameraController:Enable()

return CameraController