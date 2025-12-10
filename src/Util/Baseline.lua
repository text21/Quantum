local Baseline = {}

local store = setmetatable({}, { __mode = "k" })

local function getBag(instance)
	local bag = store[instance]
	if not bag then
		bag = {}
		store[instance] = bag
	end
	return bag
end

function Baseline.Capture(instance, properties)
	local bag = getBag(instance)
	for _, prop in ipairs(properties) do
		local ok, value = pcall(function()
			return instance[prop]
		end)
		if ok then
			bag[prop] = value
		end
	end
	return bag
end

function Baseline.Get(instance, prop)
	local bag = store[instance]
	if not bag then
		return nil
	end
	return bag[prop]
end

return Baseline