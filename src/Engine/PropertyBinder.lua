local PropertyBinder = {}
PropertyBinder.__index = PropertyBinder

function PropertyBinder.new(instance: Instance, property: string)
	local self = setmetatable({}, PropertyBinder)
	self._instance = instance
	self._property = property
	return self
end

function PropertyBinder:Get()
	return self._instance[self._property]
end

function PropertyBinder:Set(value: any)
	self._instance[self._property] = value
end

return PropertyBinder
