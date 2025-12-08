local SpringMotor = require(script.Parent.SpringMotor)

local ValueMotor = {}
ValueMotor.__index = ValueMotor

function ValueMotor.new(initialValue: any, config)
	local motor = SpringMotor.new(initialValue, config or {})
	if config and config.onStep then
		motor:OnStep(config.onStep)
	end
	return motor
end

return ValueMotor
