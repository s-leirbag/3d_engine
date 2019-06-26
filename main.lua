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
    cam = {0, 0, 0}
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

    trianglesToRender = {}
    for k, tri in pairs(cube) do
        local triRotatedZ = {}
        local triRotatedZX = {}
        local triTranslated = {}

        -- rotate around z (TEMPORARY)
        triRotatedZ[1] = multiplyMatVect(tri[1], matRotZ)
        triRotatedZ[2] = multiplyMatVect(tri[2], matRotZ)
        triRotatedZ[3] = multiplyMatVect(tri[3], matRotZ)

        -- rotate around x (TEMPORARY)
        triRotatedZX[1] = multiplyMatVect(triRotatedZ[1], matRotX)
        triRotatedZX[2] = multiplyMatVect(triRotatedZ[2], matRotX)
        triRotatedZX[3] = multiplyMatVect(triRotatedZ[3], matRotX)

        -- push away from camera (TEMPORARY)
        triTranslated[1] = add(triRotatedZX[1], {0, 0, 8})
        triTranslated[2] = add(triRotatedZX[2], {0, 0, 8})
        triTranslated[3] = add(triRotatedZX[3], {0, 0, 8})

        -- draw if facing camera
        local unitNormal = unit(normal(triTranslated))
        local ray = subtract(triTranslated[1], cam)
        if dot(unitNormal, ray) < 0 then
            -- project from 3d to 2d (NEEDED)
            local triProjected = {}
            triProjected[1] = multiplyMatVect(triTranslated[1], matProj)
            triProjected[2] = multiplyMatVect(triTranslated[2], matProj)
            triProjected[3] = multiplyMatVect(triTranslated[3], matProj)

            -- shift from -1, 1 to 0, 2 (NEEDED)
            triProjected[1] = add(triProjected[1], {1, 1, 0})
            triProjected[2] = add(triProjected[2], {1, 1, 0})
            triProjected[3] = add(triProjected[3], {1, 1, 0})

            -- take coordinates out and scale (NEEDED)
            local triProjectedCoords = {}
            for k, vector in pairs(triProjected) do
                vector[1] = vector[1] / 2 * VIRTUAL_WIDTH
                vector[2] = vector[2] / 2 * VIRTUAL_HEIGHT
            end
            table.insert(trianglesToRender, triProjected)
        end 
    end

    -- painter's sort
    -- sort from 
    

    -- draw triangles (NEEDED)
    for k, triangle in ipairs(trianglesToRender) do
        local coords = {}
        for i, vector in ipairs(triangle) do
            table.insert(coords, vector[1])
            table.insert(coords, vector[2])
        end

        drawTriangle('line', coords, {0.5, 0, 0}, {1, 1, 1}, 1)
    end

    print(#trianglesToRender)

    push:finish()
end

function updateMouse(dt)
    mouseX, mouseY = love.mouse.getPosition()
    mouseX, mouseY = push:toGame(mouseX, mouseY)
end