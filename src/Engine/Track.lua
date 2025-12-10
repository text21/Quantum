local Track = {}
Track.__index = Track

local registry = setmetatable({}, { __mode = "k" })

local function getBucket(instance)
	local bucket = registry[instance]
	if not bucket then
		bucket = {}
		registry[instance] = bucket
	end
	return bucket
end

function Track.forInstance(instance, trackName)
	assert(typeof(instance) == "Instance", "Track.forInstance: instance must be an Instance")
	assert(type(trackName) == "string", "Track.forInstance: trackName must be a string")

	local bucket = getBucket(instance)
	local t = bucket[trackName]
	if t then
		return t
	end

	t = setmetatable({
		_instance = instance,
		_name = trackName,
		_currentTask = nil,
		_cancelToken = nil,
	}, Track)

	bucket[trackName] = t
	return t
end

function Track:GetName()
	return self._name
end

function Track:GetInstance()
	return self._instance
end

function Track:_stopCurrent()
	if self._cancelToken then
		self._cancelToken.cancelled = true
		self._cancelToken = nil
	end
	self._currentTask = nil
end

function Track:Play(sequence)
	if not sequence or type(sequence._run) ~= "function" then
		error("Track:Play expects a Sequence")
	end

	self:_stopCurrent()

	local token = { cancelled = false }
	self._cancelToken = token

	self._currentTask = task.spawn(function()
		sequence:_run(token)
		if self._cancelToken == token then
			self._cancelToken = nil
			self._currentTask = nil
		end
	end)
end

function Track:Stop()
	self:_stopCurrent()
end

function Track:IsPlaying()
	return self._currentTask ~= nil and self._cancelToken ~= nil
end

return Track