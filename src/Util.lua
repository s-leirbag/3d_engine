function multiplyMatVect(v, m)
	local w = {}
	w[1] = v[1] * m[1][1] + v[2] * m[1][2] + v[3] * m[1][3] + m[1][4] -- assumes v[4] is 1
	w[2] = v[1] * m[2][1] + v[2] * m[2][2] + v[3] * m[2][3] + m[2][4]
	w[3] = v[1] * m[3][1] + v[2] * m[3][2] + v[3] * m[3][3] + m[3][4]
	q = v[1] * m[4][1] + v[2] * m[4][2] + v[3] * m[4][3] + m[4][4]

	if q ~= 0 then
		w[1] = w[1] / q
		w[2] = w[2] / q
		w[3] = w[3] / q
	end

	return w
end

function drawTriangle(mode, triCoords, color, outlineColor, thickness)
	if mode == 'fill' or mode == 'all' then
		if color then
			love.graphics.setColor(color[1], color[2], color[3])
		end

		love.graphics.polygon('fill', triCoords)
	end

	if mode == 'all' or mode == 'line' then
		if outlineColor then
			love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3])
		end
		
		if thickness then
			love.graphics.setLineWidth(thickness)
		end

		drawLines(triCoords)
	end
end

function coordsOut(tri)
    local coords = {}
    for k, vector in ipairs(tri) do
        for i, coord in pairs(vector) do
            table.insert(coords, coord)
        end
    end

    return coords
end

function drawLines(coords)
    for i = 1, #coords / 2 - 1 do
        love.graphics.line(coords[i * 2 - 1], coords[i * 2], coords[i * 2 + 1], coords[i * 2 + 2])
    end
    love.graphics.line(coords[#coords - 1], coords[#coords], coords[1], coords[2])
end

function add(v, w)
    assert(#v == #w, "vectors must be the same length")

    local sum = {}
    for i = 1, #v do 
        sum[i] = v[i] + w[i]
    end

    return sum
end

function subtract(v, w)
    assert(#v == #w, "vectors must be the same length")

    local difference = {}
    for i = 1, #v do 
        difference[i] = v[i] - w[i]
    end

    return difference
end

function length(v)
    return math.sqrt(dot(v, v))
end

function dot(v, w)
    assert(#v == #w, "vectors must be the same length")

    local dp = 0
    for i = 1, #v do
        dp = dp + v[i] * w[i]
    end

    return dp
end

function cross(v, w)
    local vx, vy, vz = v[1], v[2], v[3]
    local wx, wy, wz = w[1], w[2], w[3]

    return {vy * wz - vz * wy, vz * wx - vx * wz, vx * wy - vy * wx}
end

function scale(scalar, v)
    local scaled = {}
    for i = 1, #v do 
        scaled[i] = v[i] * scalar
    end

    return scaled
end

function unit(v)
    return scale(1 / length(v), v)
end

function normal(tri)
    return cross(subtract(tri[2], tri[1]), subtract(tri[3], tri[1]))
end

function avg(m)
	local vLen = #m[1]
	for k, vector in pairs(m) do
		assert(#vector == vLen, "vectors must be the same length")
	end
	
	local sum = m[1]
	for i = 2, #m do
		sum = add(sum, m[i])
	end

	return scale(1 / #m, sum)
end