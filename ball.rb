require 'gosu'
require 'chipmunk'
require 'zorder'

  class Ball
    attr_reader :speed, :x, :y #Shape is used for position/velocity characteristics of the player.
    def initialize(parent)
      @window = parent
      @speed = rand(20) - 10
      @direction = [:vertical, :horizontal].sample
      @image = Gosu::Image.new(@window, 'media/ball.png', false)

      if @direction == :vertical
        @y = SCREEN_HEIGHT/2
        @x = rand(SCREEN_WIDTH)
      elsif @direction == :horizontal
        @y = rand(SCREEN_HEIGHT)
        @x = SCREEN_WIDTH/2
      end
    end
    def update
      wrap
      if @direction == :vertical
        @y = @y + @speed
      elsif @direction == :horizontal
        @x = @x + @speed
      end
    end

    def draw
      @image.draw(@x, @y, ZOrder::BALL)
    end

    def wrap
      @x = @x % SCREEN_WIDTH
      @y = @y % SCREEN_HEIGHT
    end #Used for wrapping around the screen
  end