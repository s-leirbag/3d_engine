Triangle = Class{}

function Triangle:init(p, t, color)
	self.p = p or {} -- holds 3 vec3ds for positioning -- maybe put in Vec3d()s like in line below
	self.t = t or {Vec2d(), Vec2d(), Vec2d()} -- holds 3 vec2ds for texturing
	self.color = color or {1, 1, 1, 1}
end