Triangle = Class{}

function Triangle:init(p, color)
	self.p = p or {} -- holds 3 vec3ds
	self.color = color or {1, 1, 1, 1}
end