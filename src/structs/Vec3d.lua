Vec3d = Class{}

function Vec3d:init(x, y, z, w)
	self.x = x or 0
	self.y = y or 0
	self.z = z or 0
	self.w = w or 1
end