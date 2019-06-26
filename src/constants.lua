WINDOW_WIDTH = 1024
WINDOW_HEIGHT = 640

VIRTUAL_WIDTH = 512
VIRTUAL_HEIGHT = 320

ASPECT_RATIO = VIRTUAL_HEIGHT / VIRTUAL_WIDTH

FOV = 90
local fovRad = 1 / math.tan(math.rad(FOV / 2))

local near = 0.1 -- make this 0???
local far = 1000
matProj = {
	{ASPECT_RATIO * fovRad, 0, 0, 0},
	{0, fovRad, 0, 0},
	{0, 0, far / (far - near), (-far * near) / (far - near)},
	{0, 0, 1, 0}
}