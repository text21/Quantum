local MathUtils = {}

function MathUtils.toVector(value: any): { number }
	local t = typeof(value)
	if t == "number" then
		return { value }
	elseif t == "Vector2" then
		return { value.X, value.Y }
	elseif t == "Vector3" then
		return { value.X, value.Y, value.Z }
	elseif t == "UDim2" then
		return { value.X.Scale, value.X.Offset, value.Y.Scale, value.Y.Offset }
	elseif t == "Color3" then
		return { value.R, value.G, value.B }
	elseif t == "CFrame" then
		local comps = { value:GetComponents() }
		return comps
	else
		error(("MathUtils.toVector: Unsupported type %s"):format(t))
	end
end

function MathUtils.fromVector(vec: { number }, template: any): any
	local t = typeof(template)
	if t == "number" then
		return vec[1]
	elseif t == "Vector2" then
		return Vector2.new(vec[1], vec[2])
	elseif t == "Vector3" then
		return Vector3.new(vec[1], vec[2], vec[3])
	elseif t == "UDim2" then
		return UDim2.new(vec[1], vec[2], vec[3], vec[4])
	elseif t == "Color3" then
		return Color3.new(vec[1], vec[2], vec[3])
	elseif t == "CFrame" then
		return CFrame.new(table.unpack(vec))
	else
		error(("MathUtils.fromVector: Unsupported type %s"):format(t))
	end
end

function MathUtils.zeroLike(vec: { number }): { number }
	local out = table.create(#vec)
	for i = 1, #vec do
		out[i] = 0
	end
	return out
end

function MathUtils.cloneVector(vec: { number }): { number }
	local out = table.create(#vec)
	for i = 1, #vec do
		out[i] = vec[i]
	end
	return out
end

function MathUtils.lengthSquared(vec: { number }): number
	local s = 0
	for i = 1, #vec do
		local v = vec[i]
		s += v * v
	end
	return s
end

function MathUtils.distanceSquared(a: { number }, b: { number }): number
	local s = 0
	for i = 1, #a do
		local d = a[i] - b[i]
		s += d * d
	end
	return s
end

function MathUtils.add(a: any, b: any): any
	local ta = typeof(a)
	if ta == "number" then
		return a + b
	elseif ta == "Vector2" then
		return a + b
	elseif ta == "Vector3" then
		return a + b
	elseif ta == "UDim2" then
		return a + b
	elseif ta == "CFrame" then
		return a * b
	else
		error(("MathUtils.add: Unsupported type %s"):format(ta))
	end
end

function MathUtils.sub(a: any, b: any): any
	local ta = typeof(a)
	if ta == "number" then
		return a - b
	elseif ta == "Vector2" then
		return a - b
	elseif ta == "Vector3" then
		return a - b
	elseif ta == "UDim2" then
		return UDim2.new(
			a.X.Scale - b.X.Scale,
			a.X.Offset - b.X.Offset,
			a.Y.Scale - b.Y.Scale,
			a.Y.Offset - b.Y.Offset
		)
	elseif ta == "CFrame" then
		error("MathUtils.sub: Not supported for CFrame")
	else
		error(("MathUtils.sub: Unsupported type %s"):format(ta))
	end
end

function MathUtils.zeroVectorLike(value: any): any
	local t = typeof(value)
	if t == "number" then
		return 0
	elseif t == "Vector2" then
		return Vector2.new(0, 0)
	elseif t == "Vector3" then
		return Vector3.new(0, 0, 0)
	elseif t == "UDim2" then
		return UDim2.new(0, 0, 0, 0)
	else
		error(("MathUtils.zeroVectorLike: Unsupported type %s"):format(t))
	end
end

return MathUtils
