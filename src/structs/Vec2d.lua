Vec2d = Class{}

function Vec2d:init(u, v, w)
	self.u = u or 0
	self.v = v or 0
	self.w = w or 1
end