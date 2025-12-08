local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")

local Signal = require(Packages.Signal)

return function(engine)
	local TweenService = {}
	TweenService.__index = TweenService

	local Tween = {}
	Tween.__index = Tween

	function Tween.new(instance: Instance, tweenInfo: TweenInfo, goal: { [string]: any }, engineRef)
		local self = setmetatable({}, Tween)

		self.Instance = instance
		self.TweenInfo = tweenInfo
		self.Goal = goal
		self._engine = engineRef

		self._motors = {}
		self._playing = false
		self._cancelled = false

		self.Completed = Signal.new()

		return self
	end

	function Tween:_createMotors()
		local duration = self.TweenInfo.Time
		if duration <= 0 then
			duration = 0.2
		end

		local stiffness = 20 / duration
		local damping = 2

		local activeCount = 0

		for property, target in pairs(self.Goal) do
			local motor = self._engine:Spring(self.Instance, property, {
				target = target,
				stiffness = stiffness,
				damping = damping,
			})
			activeCount += 1

			motor:OnComplete(function()
				activeCount -= 1
				if activeCount <= 0 and not self._cancelled then
					self.Completed:Fire(self)
				end
			end)

			table.insert(self._motors, motor)
		end
	end

	function Tween:Play()
		if self._playing then
			return
		end
		self._playing = true
		self._cancelled = false
		self:_createMotors()
	end

	function Tween:Cancel()
		if not self._playing then
			return
		end
		self._cancelled = true
		for _, motor in ipairs(self._motors) do
			motor:Stop()
		end
		self._motors = {}
	end

	function Tween:Destroy()
		for _, motor in ipairs(self._motors) do
			motor:Destroy()
		end
		self._motors = {}
		self.Completed:Destroy()
	end

	function TweenService:Create(instance: Instance, tweenInfo: TweenInfo, goal: { [string]: any })
		return Tween.new(instance, tweenInfo, goal, engine)
	end

	return TweenService
end
