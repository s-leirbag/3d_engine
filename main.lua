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
    light = Vec3d(0, 1, -1)
    yaw = 0
end

function love.update(dt)
    updateMouse()

    if love.keyboard.isDown('space') then
        camera.y = camera.y - 8 * dt
    end
    if love.keyboard.isDown('lshift') then
        camera.y = camera.y + 8 * dt
    end

    right = vector_scale(8 * dt, matrix_multiplyVector(matrix_makeRotationY(90), lookDir))
    if love.keyboard.isDown('a') then
        camera = vector_subtract(camera, right)
    end
    if love.keyboard.isDown('d') then
        camera = vector_add(camera, right)
    end

    forward = vector_scale(8 * dt, lookDir)
    if love.keyboard.isDown('w') then
        camera = vector_add(camera, forward)
    end
    if love.keyboard.isDown('s') then
        camera = vector_subtract(camera, forward)
    end

    if love.keyboard.isDown('left') then
        yaw = yaw - 50 * dt
    end
    if love.keyboard.isDown('right') then
        yaw = yaw + 50 * dt
    end

    -- matRotZ = matrix_makeRotationZ(theta * 0.5)
    -- matRotX = matrix_makeRotationX(theta)
    matTrans = matrix_makeTranslation(0, 0, 15)
    matWorld = matrix_makeIdentity()
    -- matWorld = matrix_multiplyMatrix(matRotX, matRotZ)
    matWorld = matrix_multiplyMatrix(matWorld, matTrans)

    up = Vec3d(0, 1, 0)
    target = Vec3d(0, 0, 1)
    matCameraRot = matrix_makeRotationY(yaw)
    lookDir = matrix_multiplyVector(matCameraRot, target)
    target = vector_add(camera, lookDir)
    matCamera = matrix_pointAt(camera, target, up) -- target not needed? just use lookDir?
    matView = matrix_quickInverse(matCamera)

    love.keyboard.keysPressed = {}

    Timer.update(dt)
end

function love.draw()
    push:start()

    local trianglesToRender = {}
    for k, tri in pairs(mountains) do
        local triTransformed = Triangle()
        local triViewed = Triangle()

        -- transform (NEEDED)
        triTransformed.p[1] = matrix_multiplyVector(matWorld, tri.p[1])
        triTransformed.p[2] = matrix_multiplyVector(matWorld, tri.p[2])
        triTransformed.p[3] = matrix_multiplyVector(matWorld, tri.p[3])

        -- draw if facing camera (NEEDED)
        local unitNormal = vector_unit(vector_normal(triTransformed))
        local ray = vector_subtract(triTransformed.p[1], camera)
        if vector_dot(unitNormal, ray) < 0 then
            -- light (may be changed later)
            local unitLight = vector_unit(light)
            triTransformed.color[4] = vector_dot(unitLight, unitNormal)

            -- transform to view space (NEEDED)
            triViewed.p[1] = matrix_multiplyVector(matView, triTransformed.p[1])
            triViewed.p[2] = matrix_multiplyVector(matView, triTransformed.p[2])
            triViewed.p[3] = matrix_multiplyVector(matView, triTransformed.p[3])
            triViewed.color = triTransformed.color

            -- clip triangle against Znear plane (NEEDED)
            clippedTriangles = triangle_clipAgainstPlane(Vec3d(0, 0, 0.1), Vec3d(0, 0, 1), triViewed)

            for k, triClipped in pairs(clippedTriangles) do
                local triProjected = Triangle()
                triProjected.color = triClipped.color
                -- project from 3d to 2d (NEEDED)
                triProjected.p[1] = matrix_multiplyVector(matProj, triClipped.p[1])
                triProjected.p[2] = matrix_multiplyVector(matProj, triClipped.p[2])
                triProjected.p[3] = matrix_multiplyVector(matProj, triClipped.p[3])
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
    end

    -- sort from farthest to closest (NEEDED)
    table.sort(trianglesToRender, function(a, b)
        local aCenterZ = (a.p[1].z + a.p[2].z + a.p[3].z) / 3
        local bCenterZ = (b.p[1].z + b.p[2].z + b.p[3].z) / 3

        return aCenterZ > bCenterZ
    end)

    -- clip triangles against the 4 planes of the viewing frustum (NEEDED)
    love.graphics.setBlendMode('replace', 'alphamultiply')
    for k, triToRender in ipairs(trianglesToRender) do
        local triangles = {}
        table.insert(triangles, triToRender)
        local numNewTriangles = 0

        for s = 1, 4 do
            while numNewTriangles > 0 do
                -- take triangle from front of queue
                local test = triangles[1]
                table.remove(triangles, 1)
                numNewTriangles = numNewTriangles - 1

                -- clip against screen planes
                local clippedTriangles
                if s == 1 then
                    -- top
                    clippedTriangles = triangle_clipAgainstPlane(Vec3d(0, 0, 0), Vec3d(0, 1, 0), test)
                elseif s == 2 then
                    -- bottom
                    clippedTriangles = triangle_clipAgainstPlane(Vec3d(0, VIRTUAL_HEIGHT, 0), Vec3d(0, -1, 0), test) -- do VIRTUAL_HEIGHT - 1 instead?
                elseif s == 3 then
                    --left
                    clippedTriangles = triangle_clipAgainstPlane(Vec3d(0, 0, 0), Vec3d(1, 0, 0), test)
                -- s is 4
                else
                    -- right
                    clippedTriangles = triangle_clipAgainstPlane(Vec3d(VIRTUAL_WIDTH, 0, 0), Vec3d(-1, 0, 0), test)
                end

                for n, triClipped in pairs(clippedTriangles) do
                    table.insert(triangles, triClipped)
                end
            end
            numNewTriangles = #triangles
        end

        -- render triangles (NEEDED)
        for i, tri in pairs(triangles) do
            local coords = {}
            for p = 1, 3 do
                table.insert(coords, tri.p[p].x)
                table.insert(coords, tri.p[p].y)
            end
            drawTriangle('fill', coords, tri.color, nil, 1)
        end
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
    -- love.graphics.print('Time: ' .. tostring(love.timer.getTime()), x, y + 10)
    -- love.graphics.print('BlendMode: ' .. tostring(love.graphics.getBlendMode()), x, y + 20)
    -- love.graphics.print('LineStyle: ' .. tostring(love.graphics.getLineStyle()), x, y + 30)
    -- love.graphics.print('LineJoin: ' .. tostring(love.graphics.getLineJoin()), x, y + 40)
end