require 'chipmunk'
require 'gosu'
require 'player'
require 'ball'
require 'item'
require 'zorder'
require 'utilities'
require 'space'

SCREEN_WIDTH = 1280
SCREEN_HEIGHT = 720
DELTA_TIME = (1.0/60.0) #Gotta have that 60fps goodness!

class Game < Gosu::Window
  def initialize
    #Create the window.
    super(SCREEN_WIDTH, SCREEN_HEIGHT, false)
    self.caption = 'Dodge'

    #Setup Background
    @background = Gosu::Image.new(self, 'media/GameBackground2.png', true)
    @instruction = Gosu::Image.new(self, 'media/Instructions.png', true)
    @lifeImage = Gosu::Image.new(self, 'media/Player2.png', false)
    @superImage = Gosu::Image.new(self, 'media/endLayover.png', false)


    #Setup Frame Counter
    @scoreFont = Gosu::Font.new(self, 'media/fonts/Montserrat-Regular.ttf', 100)
    @lifeCounter = Gosu::Font.new(self, 'media/fonts/Montserrat-Regular.ttf', 40)

    #Setup the space.
    @space = CP::Space.new
    @space.initDodge
    #Borderss
    draw_border(0.0, 0.0, SCREEN_WIDTH, 0.0, :topBorder)
    draw_border(0.0, 0.0, 0.0, SCREEN_HEIGHT, :leftBorder)
    draw_border(SCREEN_WIDTH, SCREEN_HEIGHT, SCREEN_WIDTH, 0.0, :rightBorder)
    draw_border(SCREEN_WIDTH, SCREEN_HEIGHT, 0.0, SCREEN_HEIGHT, :bottomBorder)

    #init sound
    @soundtrack = Gosu::Song.new(self, 'media/Matduke-RockTheHouse_Edited_.ogg')
    @scream = Gosu::Sample.new(self, 'media/Wilhelm.wav')

    #Create the Player Physics
    @player = Player.new(self, @space)
    @hardmode = false

    #create balls
    @balls = []
    @ballSpawns = 0
    @ballSpawnTime = (60)

    #create Items
    @currentItem = Item.new(self, @space)
    @space.itemExists = true

    #set endgame logic
    @win = nil
    @endChecked = false
  end

  def draw_border(x_from, y_from, x_to, y_to, collision)
    border_shape = CP::Shape::Segment.new(CP::StaticBody.new, CP::Vec2.new(x_from, y_from), CP::Vec2.new(x_to, y_to), 1.0)
    border_shape.e = 0.2 #elasticity. 1.0 is none
    border_shape.u = 0.1 #frction coeficient, 0.1 is like metal on metal.
    border_shape.collision_type = collision
    @space.add_shape(border_shape)
  end

  def spawn_ball
    @balls.push(Ball.new(self))
  end

  def update
    @win = false if @player.life == 0
    @win = true if (Gosu::milliseconds / 1000) == 60
    endGameCheck if @endChecked == false
    if (Gosu::milliseconds / 1000 == 5) && !(@soundtrack.playing?)
      @soundtrack.play
    end
    if (((Gosu::milliseconds / 1000) % 5) == 0) && !@space.itemExists
      @currentItem = Item.new(self, @space)
      @space.itemExists = true
    end
    check_hard_mode
    if @space.itemCollision
      @space.remove_shape(@currentItem.shape)
      @space.itemExists = false
      @space.itemCollision = false
      @currentItem.apply(@player)
    end
    collision_check
    @player.update
    @currentItem.update
    @balls.each {|ball| ball.update}
    #@currentItem.update
    @ballSpawnTime -= 1
    if @ballSpawnTime == 0
      @ballSpawnTime = 60 unless @hardmode
      @ballSpawnTime = 40 if @hardmode
      spawn_ball
    end
    process_input
    @space.update(self)
    @space.step(DELTA_TIME)
  end

  def collision_check
    @balls.each do |ball|
      if @player.collide?(ball)
        @player.life -= 1
        @player.invulnTimer = 120
        @scream.play
      end
    end
  end

  def draw
    @background.draw(0,0,ZOrder::BACKGROUND)
    @instruction.draw(0,0,ZOrder::INSTRUCTION) if (Gosu::milliseconds / 1000) < 5
    @lifeImage.draw(0,0,ZOrder::BALL)
    @scoreFont.draw((Gosu::milliseconds / 10) / 100.0, SCREEN_WIDTH / 2 - 50, 40, ZOrder::FONT, 1, 1, Gosu::Color::YELLOW)
    @lifeCounter.draw('x' << @player.life.to_s, 10, 10, ZOrder::FONT, 1, 1, Gosu::Color::YELLOW)
    @player.draw if (@player.invulnTimer % 2) == 0
    @balls.each { |ball| ball.draw }
    @currentItem.draw if @space.itemExists
    @currentItem.drawText
    @superImage.draw(0,0,9) if @win == true || @win == false
    @scoreFont.draw('YOU WIN', (SCREEN_WIDTH / 2) - 200, (SCREEN_HEIGHT / 2) - 50, 10, 1, 1, Gosu::Color::GREEN) if @win == true
    @scoreFont.draw('YOU LOSE', (SCREEN_WIDTH / 2) - 200, (SCREEN_HEIGHT / 2 - 50), 10, 1, 1, Gosu::Color::RED) if @win == false
  end

  def button_down(id)
    if id == Gosu::KbEscape
      close  # exit on press of escape key
    end
  end

  def process_input
    if (button_down? Gosu::KbLeft)
      @space.impulseLeft ? @player.impulseLeft : @player.accelerateLeft
    end
    if (button_down? Gosu::KbRight)
      @space.impulseRight ? @player.impulseRight : @player.accelerateRight
    end
    if (button_down? Gosu::KbUp)
      @space.impulseUp ? @player.impulseUp : @player.accelerateUp
    end
    if (button_down? Gosu::KbDown)
      @space.impulseDown ? @player.impulseDown : @player.accelerateDown
    end
  end

  def check_hard_mode
    if (@player.shape.body.v.x * (@player.shape.body.v.y + 1)) <= 1
      @hardmode = true
    else
      @hardmode = false
    end
  end

  def endGameCheck
    if @win == true || @win == false
      @soundtrack.stop
      @player.invulnTimer = 9999
      @space.remove_shape(@player.shape)
      @space.remove_body(@player.shape.body)
      @endChecked = true
    end
    #if @win == true
    #  Gosu::Song.new(self, 'media/Applause.ogg').play
    #elsif @win == false
    #  Gosu::Song.new(self, 'media/NO.ogg').play
    #end
  end
end
