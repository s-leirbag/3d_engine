ship = loadFromObjFile('ship.obj')
teapot = loadFromObjFile('teapot.obj')
axis = loadFromObjFile('axis.obj')
mountains = loadFromObjFile('mountains.obj')
umbreon_low_poly = loadFromObjFile('UmbreonLowPoly.obj')
umbreon_high_poly = loadFromObjFile('UmbreonHighPoly.obj')

cube = {
	-- SOUTH
	Triangle({Vec3d(0, 0, 0),	Vec3d(0, 1, 0),		Vec3d(1, 1, 0)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(0, 0, 0),	Vec3d(1, 1, 0),		Vec3d(1, 0, 0)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)}),

	-- EAST
	Triangle({Vec3d(1, 0, 0),	Vec3d(1, 1, 0),		Vec3d(1, 1, 1)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(1, 0, 0),	Vec3d(1, 1, 1),		Vec3d(1, 0, 1)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)}),

	-- NORTH
	Triangle({Vec3d(1, 0, 1),	Vec3d(1, 1, 1),		Vec3d(0, 1, 1)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(1, 0, 1),	Vec3d(0, 1, 1),		Vec3d(0, 0, 1)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)}),

	-- WEST
	Triangle({Vec3d(0, 0, 1),	Vec3d(0, 1, 1),		Vec3d(0, 1, 0)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(0, 0, 1),	Vec3d(0, 1, 0),		Vec3d(0, 0, 0)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)}),

	-- TOP
	Triangle({Vec3d(0, 1, 0),	Vec3d(0, 1, 1),		Vec3d(1, 1, 1)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(0, 1, 0),	Vec3d(1, 1, 1),		Vec3d(1, 1, 0)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)}),

	-- BOTTOM
	Triangle({Vec3d(1, 0, 1),	Vec3d(0, 0, 1),		Vec3d(0, 0, 0)}, {Vec2d(0, 1), Vec2d(0, 0), Vec2d(1, 0)}),
	Triangle({Vec3d(1, 0, 1),	Vec3d(0, 0, 0),		Vec3d(1, 0, 0)}, {Vec2d(0, 1), Vec2d(1, 0), Vec2d(1, 1)})
}

-- for testing depth sort
stack = {
	-- LAYER 3
	Triangle({Vec3d(0, 0, 2),	Vec3d(0, 1, 2),		Vec3d(1, 1, 2)}),
	Triangle({Vec3d(0, 0, 2),	Vec3d(1, 1, 2),		Vec3d(1, 0, 2)}),

	-- LAYER 1
	Triangle({Vec3d(0, 0, 0),	Vec3d(0, 1, 0),		Vec3d(1, 1, 0)}),
	Triangle({Vec3d(0, 0, 0),	Vec3d(1, 1, 0),		Vec3d(1, 0, 0)}),

	-- LAYER 2
	Triangle({Vec3d(0, 0, 1),	Vec3d(0, 1, 1),		Vec3d(1, 1, 1)}),
	Triangle({Vec3d(0, 0, 1),	Vec3d(1, 1, 1),		Vec3d(1, 0, 1)}),

	-- LAYER 4
	Triangle({Vec3d(0, 0, 3),	Vec3d(0, 1, 3),		Vec3d(1, 1, 3)}),
	Triangle({Vec3d(0, 0, 3),	Vec3d(1, 1, 3),		Vec3d(1, 0, 3)}),
}