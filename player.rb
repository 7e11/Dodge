require 'gosu'
require 'chipmunk'
require 'zorder'
require 'utilities'

class Player
  attr_reader :shape #Shape is used for position/velocity characteristics of the player.
  attr_accessor :life, :invulnTimer
  def initialize(parent, space)
    @body = CP::Body.new(5, CP::INFINITY)
    @shape = CP::Shape::Circle.new(@body, 30, CP::Vec2.new(0.0, 0.0))
    @image = Gosu::Image.new(parent, 'media/Player2.png', false)
    @life = 5
    @invulnTimer = 0

    @shape.body.p = CP::Vec2.new(SCREEN_WIDTH/2, SCREEN_HEIGHT/2) # position
    @shape.collision_type = :player

    space.add_body(@body)
    space.add_shape(@shape)
  end

  def impulseRight
    @shape.body.apply_impulse((CP::Vec2.new(20.0, 0.0) * ((SCREEN_WIDTH/2))), CP::Vec2.new(0.0, 0.0))
  end

  def impulseLeft
    @shape.body.apply_impulse((CP::Vec2.new(-20.0, 0.0) * ((SCREEN_WIDTH/2))), CP::Vec2.new(0.0, 0.0))
  end

  def impulseUp
    @shape.body.apply_impulse((CP::Vec2.new(0.0, -20.0) * ((SCREEN_HEIGHT/2))), CP::Vec2.new(0.0, 0.0))
  end

  def impulseDown
    @shape.body.apply_impulse((CP::Vec2.new(0.0, 20.0) * ((SCREEN_HEIGHT/2))), CP::Vec2.new(0.0, 0.0))
  end

  def accelerateRight
    @shape.body.apply_force((CP::Vec2.new(30.0, 0.0) * ((SCREEN_WIDTH/2))), CP::Vec2.new(0.0, 0.0))
  end

  def accelerateLeft
    @shape.body.apply_force((CP::Vec2.new(-30.0, 0.0) * ((SCREEN_WIDTH/2))), CP::Vec2.new(0.0, 0.0))
  end

  def accelerateUp
    @shape.body.apply_force((CP::Vec2.new(0.0, -30.0) * ((SCREEN_HEIGHT/2))), CP::Vec2.new(0.0, 0.0))
  end

  def accelerateDown
    @shape.body.apply_force((CP::Vec2.new(0.0, 30.0) * ((SCREEN_HEIGHT/2))), CP::Vec2.new(0.0, 0.0))
  end

  def draw
    @image.draw(@shape.body.p.x - 30, @shape.body.p.y - 30, ZOrder::PLAYER)
  end

  def update
    @shape.body.reset_forces
    @invulnTimer -= 1 unless @invulnTimer == 0
  end

  def collide?(ball)
    if Utilities.collideWithGosu?(self, ball)
      true if @invulnTimer == 0
    end
  end
end