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

    matProj = matrix_makeProjection(FOV, VIRTUAL_HEIGHT / VIRTUAL_WIDTH, 0.1, 1000)
    theta = 0
    camera = Vec3d(0, 0, 0)
    lookDir = Vec3d()
    light = Vec3d(0, 0, -1)
end

function love.update(dt)
    updateMouse()

    matRotZ = matrix_makeRotationZ(theta * 0.5)
    matRotX = matrix_makeRotationX(theta)
    matTrans = matrix_makeTranslation(0, 0, 15)
    matWorld = matrix_makeIdentity()
    matWorld = matrix_multiplyMatrix(matRotX, matRotZ)
    matWorld = matrix_multiplyMatrix(matWorld, matTrans)

    lookDir = Vec3d(0, 0, 1)
    up = Vec3d(0, 1, 0)
    target = vector_add(camera, lookDir)
    matCamera = matrix_pointAt(camera, target, up) -- target not needed? just use lookDir?
    matView = matrix_quickInverse(matCamera)

    love.keyboard.keysPressed = {}

    Timer.update(dt)
end

function love.draw()
    push:start()

    local trianglesToRender = {}
    for k, tri in pairs(axis) do
        local triTransformed = Triangle()
        local triViewed = Triangle()
        local triProjected = Triangle()

        -- transform
        triTransformed.p[1] = matrix_multiplyVector(matWorld, tri.p[1])
        triTransformed.p[2] = matrix_multiplyVector(matWorld, tri.p[2])
        triTransformed.p[3] = matrix_multiplyVector(matWorld, tri.p[3])

        -- draw if facing camera
        local unitNormal = vector_unit(vector_normal(triTransformed))
        local ray = vector_subtract(triTransformed.p[1], camera)
        if vector_dot(unitNormal, ray) < 0 then
            -- light
            local unitLight = vector_unit(light)
            triProjected.shade = vector_dot(unitLight, unitNormal)

            -- transform to view space
            triViewed.p[1] = matrix_multiplyVector(matView, triTransformed.p[1])
            triViewed.p[2] = matrix_multiplyVector(matView, triTransformed.p[2])
            triViewed.p[3] = matrix_multiplyVector(matView, triTransformed.p[3])

            -- project from 3d to 2d (NEEDED)
            triProjected.p[1] = matrix_multiplyVector(matProj, triViewed.p[1])
            triProjected.p[2] = matrix_multiplyVector(matProj, triViewed.p[2])
            triProjected.p[3] = matrix_multiplyVector(matProj, triViewed.p[3])
            triProjected.p[1] = vector_scale(1 / triProjected.p[1].w, triProjected.p[1])
            triProjected.p[2] = vector_scale(1 / triProjected.p[2].w, triProjected.p[2])
            triProjected.p[3] = vector_scale(1 / triProjected.p[3].w, triProjected.p[3])

            -- shift from -1, 1 to 0, 2 (NEEDED)
            local offsetView = Vec3d(1, 1, 0)
            triProjected.p[1] = vector_add(triProjected.p[1], offsetView)
            triProjected.p[2] = vector_add(triProjected.p[2], offsetView)
            triProjected.p[3] = vector_add(triProjected.p[3], offsetView)

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

        love.graphics.setBlendMode('replace', 'alphamultiply')
        drawTriangle('all', coords, {1, 1, 1, triangle.shade}, nil, 1)
    end

    displayInfo(10, 10)

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

function displayInfo(x, y, color)
    love.graphics.setFont(smallFont)
    love.graphics.setColor(color or {0, 1, 0, 1})
    love.graphics.print('FPS: ' .. tostring(love.timer.getFPS()), x, y)
    love.graphics.print('Time: ' .. tostring(love.timer.getTime()), x, y + 10)
    love.graphics.print('BlendMode: ' .. tostring(love.graphics.getBlendMode()), x, y + 20)
    love.graphics.print('LineStyle: ' .. tostring(love.graphics.getLineStyle()), x, y + 30)
    love.graphics.print('LineJoin: ' .. tostring(love.graphics.getLineJoin()), x, y + 40)
end