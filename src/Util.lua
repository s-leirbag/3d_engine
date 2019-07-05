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

function matrix_pointAt(pos, target, up)
	-- calculate new forward direction
	local newForward = vector_unit(vector_subtract(target, pos)) --  literally just lookDir?

	-- calculate new up direction
	local newUp = vector_unit(vector_subtract(up, vector_scale(vector_dot(up, newForward), newForward))) -- scaling lookDir by its y component since up is Vec3d(0, 1, 0) then subtracting it from up and normalizing it?

	-- calculate new right direction
	local newRight = vector_cross(newUp, newForward)

	return {
		{newRight.x, newUp.x, newForward.x, pos.x},
		{newRight.y, newUp.y, newForward.y, pos.y},
		{newRight.z, newUp.z, newForward.z, pos.z},
		{0, 0, 0, 1}
	}
end

-- only works for rotation/translation matrices
function matrix_quickInverse(m)
	return {
		{m[1][1], m[2][1], m[3][1], -vector_dot(Vec3d(m[1][4], m[2][4], m[3][4]), Vec3d(m[1][1], m[2][1], m[3][1]))},		--	-(m[1][4] * m[1][1] + m[2][4] * m[2][1] + m[3][4] * m[3][1])},
		{m[1][2], m[2][2], m[3][2], -vector_dot(Vec3d(m[1][4], m[2][4], m[3][4]), Vec3d(m[1][2], m[2][2], m[3][2]))},		--	-(m[1][4] * m[1][2] + m[2][4] * m[2][2] + m[3][4] * m[3][2])},
		{m[1][3], m[2][3], m[3][3], -vector_dot(Vec3d(m[1][4], m[2][4], m[3][4]), Vec3d(m[1][3], m[2][3], m[3][3]))},		--	-(m[1][4] * m[1][3] + m[2][4] * m[2][3] + m[3][4] * m[3][3])},
		{0, 0, 0, 1}
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

function vector_intersectPlane(plane_point, plane_normal, lineStart, lineEnd)
	plane_normal = vector_unit(plane_normal)
	local plane_dot = -vector_dot(plane_normal, plane_point)
	local ad = vector_dot(lineStart, plane_normal)
	local bd = vector_dot(lineEnd, plane_normal)
	local t = (-plane_dot - ad) / (bd - ad)
	local lineStartToEnd = vector_subtract(lineEnd, lineStart)
	local lineToIntersect = vector_scale(t, lineStartToEnd)
	return vector_add(lineStart, lineToIntersect), t
end

-- uses signed distance between point and plane
-- to classify triangle's points as inside or outside
-- (normal must be facing inside)
-- then return table of clipped triangles
function triangle_clipAgainstPlane(plane_point, plane_normal, tri)
	plane_normal = vector_unit(plane_normal) -- make sure plane normal is normal

	dist = function(point)
		normal = vector_unit(point)
		-- find component of point and plane_point lying on plane_normal, then subtract them to get the dist
		return vector_dot(plane_normal, point) - vector_dot(plane_normal, plane_point)
	end

	local inside_points = {}
	local outside_points = {}
	local inside_tex = {}
	local outside_tex = {}

	local d1 = dist(tri.p[1])
	local d2 = dist(tri.p[2])
	local d3 = dist(tri.p[3])

	if d1 >= 0 then table.insert(inside_points, tri.p[1]); table.insert(inside_tex, tri.t[1]) else table.insert(outside_points, tri.p[1]); table.insert(outside_tex, tri.t[1]) end
	if d2 >= 0 then table.insert(inside_points, tri.p[2]); table.insert(inside_tex, tri.t[2]) else table.insert(outside_points, tri.p[2]); table.insert(outside_tex, tri.t[2]) end
	if d3 >= 0 then table.insert(inside_points, tri.p[3]); table.insert(inside_tex, tri.t[3]) else table.insert(outside_points, tri.p[3]); table.insert(outside_tex, tri.t[3]) end

	if #inside_points == 0 then
		return {}
	elseif #inside_points == 3 then
		return {tri}
	elseif #inside_points == 1 then
		local triClipped = Triangle()
		triClipped.color[4] = tri.color[4]

		local t = 0
		triClipped.p[1] = inside_points[1]
		triClipped.t[1] = inside_tex[1]

		triClipped.p[2], t = vector_intersectPlane(plane_point, plane_normal, inside_points[1], outside_points[1])
		triClipped.t[2].u = inside_tex[1].u * (1 - t) + outside_tex[1].u * t
		triClipped.t[2].v = inside_tex[1].v * (1 - t) + outside_tex[1].v * t
		triClipped.t[2].w = inside_tex[1].w * (1 - t) + outside_tex[1].w * t

		triClipped.p[3], t = vector_intersectPlane(plane_point, plane_normal, inside_points[1], outside_points[2])
		triClipped.t[3].u = inside_tex[1].u * (1 - t) + outside_tex[2].u * t
		triClipped.t[3].v = inside_tex[1].v * (1 - t) + outside_tex[2].v * t
		triClipped.t[3].w = inside_tex[1].w * (1 - t) + outside_tex[2].w * t

		return {triClipped}
	-- #inside_points is 2
	else
		local triClipped1 = Triangle()
		local triClipped2 = Triangle()
		triClipped1.color[4] = tri.color[4]
		triClipped2.color[4] = tri.color[4]

		local t = 0
		triClipped1.p[1] = inside_points[1]
		triClipped1.t[1] = inside_tex[1]

		triClipped1.p[2] = inside_points[2]
		triClipped1.t[2] = inside_tex[2]

		triClipped1.p[3] = vector_intersectPlane(plane_point, plane_normal, inside_points[1], outside_points[1])
		triClipped1.t[3].u = inside_tex[1].u * (1 - t) + outside_tex[1].u * t
		triClipped1.t[3].v = inside_tex[1].v * (1 - t) + outside_tex[1].v * t
		triClipped1.t[3].w = inside_tex[1].w * (1 - t) + outside_tex[1].w * t

		triClipped2.p[1] = inside_points[2]
		triClipped2.t[1] = inside_tex[2]

		triClipped2.p[2] = triClipped1.p[3] -- ?? is this counter clockwise??? don't think it matters tho
		triClipped2.t[2] = triClipped1.t[3]

		triClipped2.p[3] = vector_intersectPlane(plane_point, plane_normal, inside_points[2], outside_points[1])
		triClipped2.t[3].u = inside_tex[2].u * (1 - t) + outside_tex[1].u * t
		triClipped2.t[3].v = inside_tex[2].v * (1 - t) + outside_tex[1].v * t
		triClipped2.t[3].w = inside_tex[2].w * (1 - t) + outside_tex[1].w * t

		return {triClipped1, triClipped2}
	end
end

function texturedTriangle(x1, y1, u1, v1,
	x2, y2, u2, v2,
	x3, y3, u3, v3,
	texFilename)

	texFilename = 'src/models/textures/' .. texFilename
	-- make sure file exists
	assert(fileExists(texFilename), 'file does not exist')

	local texData = love.image.newImageData(texFilename)
	love.graphics.setPointSize(1)

	if y2 < y1 then
		y1, y2 = swap(y1, y2)
		x1, x2 = swap(x1, x2)
		u1, u2 = swap(u1, u2)
		v1, v2 = swap(v1, v2)
	end
	if y3 < y1 then
		y1, y3 = swap(y1, y3)
		x1, x3 = swap(x1, x3)
		u1, u3 = swap(u1, u3)
		v1, v3 = swap(v1, v3)
	end
	if y3 < y2 then
		y2, y3 = swap(y2, y3)
		x2, x3 = swap(x2, x3)
		u2, u3 = swap(u2, u3)
		v2, v3 = swap(v2, v3)
	end

	local dy1 = math.floor(y2 - y1)
	local dx1 = math.floor(x2 - x1)
	local dv1 = math.floor(v2 - v1)
	local du1 = math.floor(u2 - u1)

	local dy2 = math.floor(y3 - y1)
	local dx2 = math.floor(x3 - x1)
	local dv2 = math.floor(v3 - v1)
	local du2 = math.floor(u3 - u1)

	local aStepX, bStepX
	local stepU1, stepV1
	local stepU2, stepV2

	if dy1 ~= 0 then aStepX = dx1 / math.abs(dy1) end
	if dy2 ~= 0 then bStepX = dx2 / math.abs(dy2) end

	if dy1 ~= 0 then stepU1 = du1 / math.abs(dy1) end
	if dy1 ~= 0 then stepV1 = dv1 / math.abs(dy1) end

	if dy2 ~= 0 then stepU2 = du2 / math.abs(dy2) end
	if dy2 ~= 0 then stepV2 = dv2 / math.abs(dy2) end

	if dy1 ~= 0 then
		for y = y1, y2 do
			local ax = x1 + (y - y1) * aStepX
			local bx = x1 + (y - y1) * bStepX
			local texStartU = u1 + (y - y1) * stepU1
			local texStartV = v1 + (y - y1) * stepV1
			local texEndU = u1 + (y - y1) * stepU2
			local texEndV = v1 + (y - y1) * stepV2

			if ax > bx then
				ax, bx = swap(ax, bx)
				texStartU, texEndU = swap(texStartU, texEndU)
				texStartV, texEndV = swap(texStartV, texEndV)
			end

			local texU = texStartU
			local texV = texStartV

			local tStep = 1 / (bx - ax)
			local t = 0

			for x = ax, bx do
				texU = texStartU * (1 - t) + texEndU * t
				texV = texStartV * (1 - t) + texEndV * t
				print()
				print('v1: ' .. v1 .. ', dv1: ' .. dv1 .. ', stepV1: ' .. stepV1)
				print("texStartU: " .. texStartU .. ", texEndU: " .. texEndU)
				print("texStartV: " .. texStartV .. ", texEndV: " .. texEndV)
				print("t: " .. t .. ", texU: " .. texU .. ", texV: " .. texV)

				love.graphics.setColor(texData:getPixel(texU, texV))
				love.graphics.points(x, y)

				t = t + tStep
			end
		end
	end

	local dy1 = math.floor(y3 - y2)
	local dx1 = math.floor(x3 - x2)
	local dv1 = math.floor(v3 - v2)
	local du1 = math.floor(u3 - u2)

	if dy1 ~= 0 then aStepX = dx1 / math.abs(dy1) end
	if dy2 ~= 0 then bStepX = dx2 / math.abs(dy2) end

	if dy1 ~= 0 then stepU1 = du1 / math.abs(dy1) end
	if dy1 ~= 0 then stepV1 = dv1 / math.abs(dy1) end

	if dy1 ~= 0 then
		for y = y2, y3 do
			local ax = x2 + (y - y2) * aStepX
			local bx = x1 + (y - y1) * bStepX
			local texStartU = u2 + (y - y2) * stepU1
			local texStartV = v2 + (y - y2) * stepV1
			local texEndU = u1 + (y - y1) * stepU2
			local texEndV = v1 + (y - y1) * stepV2

			if ax > bx then
				ax, bx = swap(ax, bx)
				texStartU, texEndU = swap(texStartU, texEndU)
				texStartV, texEndV = swap(texStartV, texEndV)
			end

			local texU = texStartU
			local texV = texStartV

			local tStep = 1 / (bx - ax)
			local t = 0

			for x = ax, bx do
				texU = texStartU * (1 - t) + texEndU * t
				texV = texStartV * (1 - t) + texEndV * t

				love.graphics.setColor(texData:getPixel(texU, texV))
				love.graphics.points(x, y)

				t = t + tStep
			end
		end
	end
end

function loadFromObjFile(filename)
	filename = 'src/models/obj_files/' .. filename

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

function swap(a, b)
	local buffer = a
	a = b
	b = buffer

	return a, b
end

-- DEBUGGING

-- print(v.x .. ", " .. v.y .. ", " .. v.z)