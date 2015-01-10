require 'gosu'
require 'chipmunk'
require 'zorder'

class Item
  attr_accessor :shape, :itemType
  def initialize(parent, space)
    @itemType = [:invincibility, :life].sample
    @body = CP::StaticBody.new
    @hitbox = [CP::Vec2.new(-30.0, -30.0), CP::Vec2.new(-30.0, 30.0), CP::Vec2.new(30.0, 30.0), CP::Vec2.new(30.0, -30.0)]
    @shape = CP::Shape::Poly.new(@body, @hitbox, CP::Vec2.new(0.0, 0.0))
    @image = Gosu::Image.new(parent, 'media/Item.png', false)

    @shape.body.p = CP::Vec2.new(rand(SCREEN_WIDTH), rand(SCREEN_HEIGHT)) # position
    @shape.collision_type = :item

    @font = Gosu::Font.new(parent, 'media/fonts/Montserrat-Regular.ttf', 50)

    @itemGetInvun = 0
    @itemGetLife = 0

    space.add_shape(@shape)
  end

  def update
    @itemGetInvun -= 1 unless @itemGetInvun == 0
    @itemGetLife -= 1 unless @itemGetLife == 0
  end

  def draw
    @image.draw(@shape.body.p.x - 30, @shape.body.p.y - 30, ZOrder::ITEM)
  end

  def drawText
    @font.draw('Item Acquired: 1 UP', (SCREEN_WIDTH / 2) - 300, 600, ZOrder::FONT, 1, 1, Gosu::Color::YELLOW) unless @itemGetLife == 0
    @font.draw('Item Acquired: Invulnerability', (SCREEN_WIDTH / 2) - 300, 600, ZOrder::FONT, 1, 1, Gosu::Color::YELLOW) unless @itemGetInvun == 0
  end

  def apply(player)
    if @itemType == :life
      player.life += 1
      @itemGetLife = 180
    end
    if @itemType == :invincibility
      player.invulnTimer = 180
      @itemGetInvun = 180
    end
  end
end