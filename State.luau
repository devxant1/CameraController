local UserInputService = game:GetService("UserInputService")
local UserGameSettings = UserSettings():GetService("UserGameSettings")

local Packages = script.Parent.Packages
local Signal = require(Packages.Signal)

local State = {
	Camera = nil,
	Character = nil,
	RootPart = nil,
	Humanoid = nil,
	ModeTransitionAlpha = 1,
	ModeTransitionSpeed = 0.4,
	FOV = 70,
	Mode = "Default",
	ProcessInputs = true,
	Rendering = false,
}

State.NIL = newproxy(false)
State.OnChange = Signal()

local StateDefaults = table.freeze(table.clone(State))

function State:Get(Name: string)
	return State[Name] ~= nil and State[Name] or StateDefaults[Name]
end

function State:Set(Name: string, Value: any)
	local OldValue = State[Name]
	State[Name] = Value
	State.OnChange:Fire(Name, State[Name], OldValue)
end

function State:Update(Values: {[string]: any})
	for Name, Value in pairs(Values) do
		local OldValue = State[Name]
		State[Name] = Value ~= State.NIL and Value or nil
		State.OnChange:Fire(Name, State[Name], OldValue)
	end
end

function State:Clear()
	table.clear(State)
end

do
	local Camera = workspace.CurrentCamera
	State:Update({
		Camera = Camera,
		ModeTransitionCFrame = Camera.CFrame
	})
	
	local function SubjectUpdated()
		local Humanoid = Camera.CameraSubject
		if not Humanoid then return end
		
		local Character = Humanoid.Parent

		State:Update({
			Character = Character,
			RootPart = Character:WaitForChild("HumanoidRootPart"),
			Humanoid = Humanoid,
		})
	end
	
	Camera:GetPropertyChangedSignal("CameraSubject"):Connect(SubjectUpdated)
	
	SubjectUpdated()
	
	do
		UserInputService.InputChanged:Connect(function(Input, GameProcessedEvent)
			if GameProcessedEvent then return end
			if not State:Get("Rendering") then return end
			if not State:Get("ProcessInputs") then return end
			
			if Input.UserInputType == Enum.UserInputType.MouseMovement then
				print(Input.Delta)
			end
		end)
	end
end

return State