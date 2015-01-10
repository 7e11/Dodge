class CP::Space
  attr_accessor :impulseDown, :impulseUp, :impulseRight, :impulseLeft, :gravChange, :itemExists, :itemCollision
    def initDodge
    self.damping = 0.01                                       #Apply some ambient friction to the space.
    self.gravity = CP::Vec2.new(0.0, (9.81 * SCREEN_HEIGHT/2))#Gravity for the simulation

    #Collision Functions for the player and the border
    self.add_collision_func(:player, :bottomBorder) do
      @impulseUp = true
      @gravChange = true
    end

    self.add_collision_func(:player, :topBorder) do
      @impulseDown = true
      @gravChange = true
    end

    self.add_collision_func(:player, :leftBorder) do
      @impulseRight = true
      @gravChange = true
    end

    self.add_collision_func(:player, :rightBorder) do
      @impulseLeft = true
      @gravChange = true
    end

    #collision fuctions for the player and the item
    self.add_collision_func(:player, :item) do
      @itemCollision = true
    end
  end

  def update(window)
    if (window.button_down? Gosu::KbW) && @gravChange
      self.gravity = CP::Vec2.new(0.0, (-9.81 * SCREEN_HEIGHT/2))
    elsif (window.button_down? Gosu::KbS) && @gravChange
      self.gravity = CP::Vec2.new(0.0, (9.81 * SCREEN_HEIGHT/2))
    elsif (window.button_down? Gosu::KbD) && @gravChange
      self.gravity = CP::Vec2.new((9.81 * SCREEN_WIDTH/2), 0.0)
    elsif (window.button_down? Gosu::KbA) && @gravChange
      self.gravity = CP::Vec2.new((-9.81 * SCREEN_WIDTH/2), 0.0)
    end
    @impulseDown, @impulseLeft, @impulseRight, @impulseUp, @gravChange = false, false, false, false, false
  end
end