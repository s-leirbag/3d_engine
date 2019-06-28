love.graphics.setDefaultFilter('nearest', 'nearest')
require 'src/Dependencies'

function love.load()
    love.window.setTitle('3D Engine')
    math.randomseed(os.time())
    push:setupScreen(VIRTUAL_WIDTH, VIRTUAL_HEIGHT, WINDOW_WIDTH, WINDOW_HEIGHT, {
        vsync = false,
        fullscreen = false,
        resizable = true
    })

    love.keyboard.keysPressed = {}

    theta = 0
    cam = Vec3d(0, 0, 0)
    light = Vec3d(0, 0, -1)

    ship = loadFromObjFile('VideoShip.obj')
end

function love.update(dt)
    updateMouse()

    theta = theta + dt * 50

    matRotZ = {
        {math.cos(math.rad(theta)), -math.sin(math.rad(theta)), 0, 0},
        {math.sin(math.rad(theta)), math.cos(math.rad(theta)), 0, 0},
        {0, 0, 1, 0},
        {0, 0, 0, 1}
    }

    matRotX = {
        {1, 0, 0, 0},
        {0, math.cos(math.rad(theta)), -math.sin(math.rad(theta)), 0},
        {0, math.sin(math.rad(theta)), math.cos(math.rad(theta)), 0},
        {0, 0, 0, 1}
    }

    love.keyboard.keysPressed = {}

    Timer.update(dt)
end

function love.draw()
    push:start()

    local trianglesToRender = {}
    for k, tri in pairs(ship) do
        local triRotatedZ = Triangle()
        local triRotatedZX = Triangle()
        local triTranslated = Triangle()
        local triProjected = Triangle()

        -- rotate around z (TEMPORARY)
        triRotatedZ.p[1] = multiplyMatVect(tri.p[1], matRotZ)
        triRotatedZ.p[2] = multiplyMatVect(tri.p[2], matRotZ)
        triRotatedZ.p[3] = multiplyMatVect(tri.p[3], matRotZ)

        -- rotate around x (TEMPORARY)
        triRotatedZX.p[1] = multiplyMatVect(triRotatedZ.p[1], matRotX)
        triRotatedZX.p[2] = multiplyMatVect(triRotatedZ.p[2], matRotX)
        triRotatedZX.p[3] = multiplyMatVect(triRotatedZ.p[3], matRotX)

        -- push away from camera (TEMPORARY)
        triTranslated.p[1] = add(triRotatedZX.p[1], Vec3d(0, 0, 3))
        triTranslated.p[2] = add(triRotatedZX.p[2], Vec3d(0, 0, 3))
        triTranslated.p[3] = add(triRotatedZX.p[3], Vec3d(0, 0, 3))

        -- draw if facing camera
        local unitNormal = unit(normal(triTranslated))
        local ray = subtract(triTranslated.p[1], cam)
        if dot(unitNormal, ray) < 0 then
            -- light
            local unitLight = unit(light)
            triProjected.shade = dot(unitLight, unitNormal)

            -- project from 3d to 2d (NEEDED)
            triProjected.p[1] = multiplyMatVect(triTranslated.p[1], matProj)
            triProjected.p[2] = multiplyMatVect(triTranslated.p[2], matProj)
            triProjected.p[3] = multiplyMatVect(triTranslated.p[3], matProj)

            -- shift from -1, 1 to 0, 2 (NEEDED)
            triProjected.p[1] = add(triProjected.p[1], Vec3d(1, 1, 0))
            triProjected.p[2] = add(triProjected.p[2], Vec3d(1, 1, 0))
            triProjected.p[3] = add(triProjected.p[3], Vec3d(1, 1, 0))

            -- take coordinates out and scale (NEEDED)
            local triProjectedCoords = {}
            for i = 1, 3 do
                triProjected.p[i].x = triProjected.p[i].x / 2 * VIRTUAL_WIDTH
                triProjected.p[i].y = triProjected.p[i].y / 2 * VIRTUAL_HEIGHT
            end
            table.insert(trianglesToRender, triProjected)
        end 
    end

    -- sort from farthest to closest (NEEDED)
    table.sort(trianglesToRender, function(a, b)
        local aCenterZ = (a.p[1].z + a.p[2].z + a.p[3].z) / 3
        local bCenterZ = (b.p[1].z + b.p[2].z + b.p[3].z) / 3

        return aCenterZ > bCenterZ
    end)

    -- draw triangles (NEEDED)
    for k, triangle in ipairs(trianglesToRender) do
        local coords = {}
        for i = 1, 3 do
            table.insert(coords, triangle.p[i].x)
            table.insert(coords, triangle.p[i].y)
        end

        -- make identical triangle but all black first to clear?
        drawTriangle('all', coords, {0, 0, 0, 1}, {0, 0, 0, 1}, 1)
        drawTriangle('all', coords, {1, 1, 1, triangle.shade}, nil, 1)
    end

    push:finish()
end

function love.resize(w, h)
    push:resize(w, h)
end

function love.keypressed(key)
    love.keyboard.keysPressed[key] = true
end

function love.keyboard.wasPressed(key)
    if love.keyboard.keysPressed[key] then
        return true
    else
        return false
    end
end

function updateMouse(dt)
    mouseX, mouseY = love.mouse.getPosition()
    mouseX, mouseY = push:toGame(mouseX, mouseY)
end

-- DEBUGGING

-- print(v.x .. ", " .. v.y .. ", " .. v.z)