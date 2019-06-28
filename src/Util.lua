function multiplyMatVect(v, m)
	local w = Vec3d()
	w.x = v.x * m[1][1] + v.y * m[1][2] + v.z * m[1][3] + m[1][4] -- assumes v[4] is 1
	w.y = v.x * m[2][1] + v.y * m[2][2] + v.z * m[2][3] + m[2][4]
	w.z = v.x * m[3][1] + v.y * m[3][2] + v.z * m[3][3] + m[3][4]
	q = v.x * m[4][1] + v.y * m[4][2] + v.z * m[4][3] + m[4][4]

	if q ~= 0 then
		w.x = w.x / q
		w.y = w.y / q
		w.z = w.z / q
	end

	return w
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

		drawLines(triCoords)
	end
end

function drawLines(coords)
    for i = 1, #coords / 2 - 1 do
        love.graphics.line(coords[i * 2 - 1], coords[i * 2], coords[i * 2 + 1], coords[i * 2 + 2])
    end
    love.graphics.line(coords[#coords - 1], coords[#coords], coords[1], coords[2])
end

function add(v, w)
    return Vec3d(v.x + w.x, v.y + w.y, v.z + w.z)
end

function subtract(v, w)
    return Vec3d(v.x - w.x, v.y - w.y, v.z - w.z)
end

function length(v)
    return math.sqrt(dot(v, v))
end

function dot(v, w)
    return v.x * w.x + v.y * w.y + v.z * w.z
end

function cross(v, w)
    return Vec3d(v.y * w.z - v.z * w.y, v.z * w.x - v.x * w.z, v.x * w.y - v.y * w.x)
end

function scale(scalar, v)
    return Vec3d(v.x * scalar, v.y * scalar, v.z * scalar)
end

function unit(v)
    return scale(1 / length(v), v)
end

function normal(tri)
    return cross(subtract(tri.p[2], tri.p[1]), subtract(tri.p[3], tri.p[1]))
end

function avg(m)	
	local sum = m[1]
	for i = 2, #m do
		sum = add(sum, m[i])
	end

	return scale(1 / #m, sum)
end

function loadFromObjFile(filename)
	filename = 'src/obj_files/' .. filename

	-- make sure file exists
	assert(fileExists(filename), 'file does not exist')

	local mesh = {}
	local verts = {}
	local fh = assert(io.open(filename, 'rb')) -- fh means file handle, an open file with a current position
	
	for line in fh:lines() do
		if line:sub(1, 1) == 'v' then
			local location = 2
			local x = line:sub(line:find('[%d-.]+', location))
			location = line:find('[%d-.]+', location)
			location = line:find(' ', location) + 1

			local y = line:sub(line:find('[%d-.]+', location))
			location = line:find('[%d-.]+', location)
			location = line:find(' ', location) + 1

			local z = line:sub(line:find('[%d-.]+', location))

			local v = Vec3d(x, y, z)
			table.insert(verts, v)
		elseif line:sub(1, 1) == 'f' then
			local location = 2
			local p1 = line:sub(line:find('[%d]+', location))
			location = line:find('[%d]+', location)
			location = line:find(' ', location) + 1

			local p2 = line:sub(line:find('[%d]+', location))
			location = line:find('[%d]+', location)
			location = line:find(' ', location) + 1

			local p3 = line:sub(line:find('[%d]+', location))

			print(p1 .. ", " .. p2 .. ", " .. p3)

			table.insert(mesh, Triangle({verts[p1 - 1], verts[p2 - 1], verts[p3 - 1]}))
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
-- print(w.x .. ", " .. w.y .. ", " .. w.z)