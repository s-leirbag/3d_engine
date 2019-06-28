Class = require 'lib/class'
push = require 'lib/push'
Timer = require 'lib/knife.timer'

require 'src/structs/Vec3d'
require 'src/structs/Triangle'
require 'src/Util'
require 'src/constants'
require 'src/shapes'
require 'src/StateMachine'

smallFont = love.graphics.newFont('fonts/font.ttf', 8)
largeFont = love.graphics.newFont('fonts/font.ttf', 16)
scoreFont = love.graphics.newFont('fonts/font.ttf', 32)
love.graphics.setFont(smallFont)