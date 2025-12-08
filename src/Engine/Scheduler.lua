local RunService = game:GetService("RunService")

local Scheduler = {}
Scheduler.__index = Scheduler

function Scheduler.new(stepCallback: (number) -> (), mode: string?)
	local self = setmetatable({}, Scheduler)

	self._callback = stepCallback
	self._mode = mode or "Heartbeat"
	self._timeScale = 1
	self._connection = nil

	return self
end

function Scheduler:SetTimeScale(scale: number)
	self._timeScale = scale or 1
end

function Scheduler:Start()
	if self._connection then
		return
	end

	local signal
	if self._mode == "RenderStepped" then
		signal = RunService.RenderStepped
	else
		signal = RunService.Heartbeat
	end

	self._connection = signal:Connect(function(dt)
		local scaled = dt * self._timeScale
		if scaled > 0 then
			self._callback(scaled)
		end
	end)
end

function Scheduler:Stop()
	if self._connection then
		self._connection:Disconnect()
		self._connection = nil
	end
end

function Scheduler:Destroy()
	self:Stop()
end

return Scheduler
