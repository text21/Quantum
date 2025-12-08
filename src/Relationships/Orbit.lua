local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Packages = ReplicatedStorage:WaitForChild("Packages")
local Trove = require(Packages.Trove)

local Orbit = {}
Orbit.__index = Orbit

local TWO_PI = math.pi * 2

local function isGui(instance: Instance)
	return instance:IsA("GuiObject")
end

local function isPart(instance: Instance)
	return instance:IsA("BasePart")
end

local function getCenterPosition2D(gui: GuiObject)
	return gui.Position
end

local function computeGuiTarget(center: GuiObject, radius: number, angle: number)
	local dx = math.cos(angle) * radius
	local dy = math.sin(angle) * radius
	return center.Position + UDim2.fromOffset(dx, dy)
end

local function compute3DTarget(part: BasePart, radius: number, angle: number, plane: string)
	local center = part.Position
	if plane == "YZ" then
		local dy = math.cos(angle) * radius
		local dz = math.sin(angle) * radius
		return CFrame.new(center) * CFrame.new(0, dy, dz)
	elseif plane == "XY" then
		local dx = math.cos(angle) * radius
		local dy = math.sin(angle) * radius
		return CFrame.new(center) * CFrame.new(dx, dy, 0)
	else
		local dx = math.cos(angle) * radius
		local dz = math.sin(angle) * radius
		return CFrame.new(center) * CFrame.new(dx, 0, dz)
	end
end

function Orbit.new(engine, config)
	local self = setmetatable({}, Orbit)

	self._engine = engine
	self._trove = Trove.new()
	self._destroyed = false

	self._center = config.center
	self._items = config.items or {}
	self._radius = config.radius or 64
	self._speed = config.angularSpeed or math.rad(90)
	self._layout = config.layout or "even"
	self._plane = config.plane or "XZ"
	self._offsetAngle = config.offsetAngle or 0

	self._angles = {}
	self._motors = {}

	local count = #self._items
	for i, item in ipairs(self._items) do
		local angle = self._offsetAngle
		if self._layout == "even" and count > 0 then
			angle = angle + (TWO_PI * (i - 1) / count)
		end
		self._angles[i] = angle

		local target
		if isGui(self._center) and isGui(item) then
			target = computeGuiTarget(self._center, self._radius, angle)
		elseif isPart(self._center) and isPart(item) then
			target = compute3DTarget(self._center, self._radius, angle, self._plane)
		end

		if target ~= nil then
			local property = isGui(item) and "Position" or "CFrame"
			local motor = engine:Spring(item, property, {
				target = target,
				stiffness = (config.spring and config.spring.stiffness) or 16,
				damping = (config.spring and config.spring.damping) or 2,
			})
			self._motors[i] = motor
		end
	end

	return self
end

function Orbit:SetRadius(radius: number)
	self._radius = radius
end

function Orbit:SetSpeed(speed: number)
	self._speed = speed
end

function Orbit:SetItems(items: { Instance })
	self._items = items
end

function Orbit:Pause()
	self._paused = true
end

function Orbit:Resume()
	self._paused = false
end

function Orbit:Step(dt: number)
	if self._destroyed or self._paused then
		return
	end

	for i, item in ipairs(self._items) do
		local motor = self._motors[i]
		if motor then
			local angle = self._angles[i] + self._speed * dt
			self._angles[i] = angle

			local target
			if isGui(self._center) and isGui(item) then
				target = computeGuiTarget(self._center, self._radius, angle)
			elseif isPart(self._center) and isPart(item) then
				target = compute3DTarget(self._center, self._radius, angle, self._plane)
			end

			if target ~= nil then
				motor:SetTarget(target)
			end
		end
	end
end

function Orbit:Destroy()
	if self._destroyed then
		return
	end
	self._destroyed = true

	for _, motor in pairs(self._motors) do
		motor:Destroy()
	end
	self._motors = {}

	self._trove:Destroy()
end

return Orbit
