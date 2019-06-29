function matrix_multiplyVector(m, v)
	local u = Vec3d()
	u.x = v.x * m[1][1] + v.y * m[1][2] + v.z * m[1][3] + v.w * m[1][4]
	u.y = v.x * m[2][1] + v.y * m[2][2] + v.z * m[2][3] + v.w * m[2][4]
	u.z = v.x * m[3][1] + v.y * m[3][2] + v.z * m[3][3] + v.w * m[3][4]
	u.w = v.x * m[4][1] + v.y * m[4][2] + v.z * m[4][3] + v.w * m[4][4]
	return u
end

function matrix_multiplyMatrix(a, b)
	local matrix = {}
	for r = 1, 4 do
		matrix[r] = {}
		for c = 1, 4 do
			matrix[r][c] = b[r][1] * a[1][c] + b[r][2] * a[2][c] + b[r][3] * a[3][c] + b[r][4] * a[4][c]
		end
	end
	return matrix
end

function matrix_makeIdentity()
	return {
		{1, 0, 0, 0},
		{0, 1, 0, 0},
		{0, 0, 1, 0},
		{0, 0, 0, 1},
	}
end

function matrix_makeRotationX(angle)
	return {
	    {1, 0, 0, 0},
	    {0, math.cos(math.rad(angle)), -math.sin(math.rad(angle)), 0},
	    {0, math.sin(math.rad(angle)), math.cos(math.rad(angle)), 0},
	    {0, 0, 0, 1}
	}
end

function matrix_makeRotationY(angle)
	return {
	    {math.cos(math.rad(angle)), 0, math.sin(math.rad(angle)), 0},
	    {0, 1, 0, 0},
	    {-math.sin(math.rad(angle)), 0, math.cos(math.rad(angle)), 0},
	    {0, 0, 0, 1}
	}
end

function matrix_makeRotationZ(angle)
	return {
        {math.cos(math.rad(theta)), -math.sin(math.rad(theta)), 0, 0},
        {math.sin(math.rad(theta)), math.cos(math.rad(theta)), 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }
end

function matrix_makeTranslation(x, y, z)
	return {
        {1, 0, 0, x},
        {0, 1, 0, y},
        {0, 0, 1, z},
        {0, 0, 0, 1}
    }
end

function matrix_makeProjection(fov, aspectRatio, near, far)
	local fovRad = 1 / math.tan(math.rad(fov / 2))
	return {
		{aspectRatio * fovRad, 0, 0, 0},
		{0, fovRad, 0, 0},
		{0, 0, far / (far - near), (-far * near) / (far - near)},
		{0, 0, 1, 0}
	}
end

function matrix_print(m)
	print('matrix = {')
	for r = 1, #m - 1 do
		local str = '   {'
		for c = 1, #m[r] - 1 do
			str = str .. m[r][c] .. ', '
		end
		str = str .. m[r][#m[r]] .. "},"

		print(str)
	end

	local str = '   {'
	for c = 1, #m[#m] - 1 do
		str = str .. m[#m][c] .. ', '
	end
	str = str .. m[#m][#m[#m]] .. "}"
	
	print(str)
	print('}')
end

function drawTriangle(mode, triCoords, color, outlineColor, thickness)
	if mode == 'fill' or mode == 'all' then
		if color then
			if color[4] then
				love.graphics.setColor(color[1], color[2], color[3], color[4])
			else
				love.graphics.setColor(color[1], color[2], color[3], 1)
			end
		else
			love.graphics.setColor(1, 1, 1, 1)
		end

		love.graphics.polygon('fill', triCoords)
	end

	if mode == 'all' or mode == 'line' then
		if outlineColor then
			if outlineColor[4] then
				love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3], outlineColor[4])
			else
				love.graphics.setColor(outlineColor[1], outlineColor[2], outlineColor[3])
			end
		else
			love.graphics.setColor(0, 1, 0, 1)
		end
		
		if thickness then
			love.graphics.setLineWidth(thickness)
		else
			love.graphics.setLineWidth(1)
		end

		love.graphics.setLineStyle('rough')
		love.graphics.setLineJoin('none')
		love.graphics.polygon('line', triCoords) -- alternative: drawLines(triCoords)
	end
end

-- NOT USED
-- function drawLines(coords)
--     for i = 1, #coords / 2 - 1 do
--         love.graphics.line(coords[i * 2 - 1], coords[i * 2], coords[i * 2 + 1], coords[i * 2 + 2])
--     end
--     love.graphics.line(coords[#coords - 1], coords[#coords], coords[1], coords[2])
-- end

function vector_add(v, w)
    return Vec3d(v.x + w.x, v.y + w.y, v.z + w.z)
end

function vector_subtract(v, w)
    return Vec3d(v.x - w.x, v.y - w.y, v.z - w.z)
end

function vector_length(v)
    return math.sqrt(vector_dot(v, v))
end

function vector_dot(v, w)
    return v.x * w.x + v.y * w.y + v.z * w.z
end

function vector_cross(v, w)
    return Vec3d(v.y * w.z - v.z * w.y, v.z * w.x - v.x * w.z, v.x * w.y - v.y * w.x)
end

function vector_scale(scalar, v)
    return Vec3d(v.x * scalar, v.y * scalar, v.z * scalar)
end

function vector_unit(v)
    return vector_scale(1 / vector_length(v), v)
end

function vector_normal(tri)
    return vector_cross(vector_subtract(tri.p[2], tri.p[1]), vector_subtract(tri.p[3], tri.p[1]))
end

function vector_avg(m)	
	local sum = m[1]
	for i = 2, #m do
		sum = vector_add(sum, m[i])
	end
	return vector_scale(1 / #m, sum)
end

function vector_print(v)
	if v.w then
		print('{' .. v.x .. ', ' .. v.y .. ', ' .. v.z .. ', ' .. v.w .. '}')
	else
		print('{' .. v.x .. ', ' .. v.y .. ', ' .. v.z)
	end
end

function loadFromObjFile(filename)
	filename = 'src/obj_files/' .. filename

	-- make sure file exists
	assert(fileExists(filename), 'file does not exist')

	local mesh = {}
	local verts = {}
	local fh = assert(io.open(filename, 'rb')) -- fh means file handle, an open file with a current position
	
	for line in fh:lines() do
		if line:sub(1, 2) == 'v ' then
			local location = 3
			local x = line:sub(line:find('[%d-.]+', location))
			location = line:find('[%d-.]+', location)
			location = line:find(' ', location) + 1

			local y = line:sub(line:find('[%d-.]+', location))
			location = line:find('[%d-.]+', location)
			location = line:find(' ', location) + 1

			local z = line:sub(line:find('[%d-.]+', location))

			local v = Vec3d(x, y, z)
			table.insert(verts, v)
		elseif line:sub(1, 2) == 'f '  then
			local location = 3
			local p1 = tonumber(line:sub(line:find('[%d]+', location)))
			location = line:find('[%d]+', location)
			location = line:find(' ', location) + 1

			local p2 = tonumber(line:sub(line:find('[%d]+', location)))
			location = line:find('[%d]+', location)
			location = line:find(' ', location) + 1

			local p3 = tonumber(line:sub(line:find('[%d]+', location)))

			table.insert(mesh, Triangle({verts[p1], verts[p2], verts[p3]}))
		end
	end

	return mesh
end

function fileExists(path)
  local file = io.open(path, "rb")
  if file then file:close() end
  return file ~= nil
end

function readall(filename)
  local fh = assert(io.open(filename, "rb")) -- The mode string may also have a b at the end, which is needed in some systems to open the file in binary mode. This string is exactly what is used in the standard C function fopen.
  local contents = assert(fh:read("a")) -- "a" in Lua 5.3; "*a" in Lua 5.1 and 5.2
  fh:close()
  return contents
end

-- DEBUGGING

-- print(v.x .. ", " .. v.y .. ", " .. v.z)