Triangle = Class{}

function Triangle:init(p)
	self.p = p or {} -- holds 3 vec3ds
	self.shade = 1
end