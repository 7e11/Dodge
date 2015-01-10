module Utilities
  #This takes the difference between
  def self.collideWithGosu?(player, ball)
    dist = Gosu::distance(player.shape.body.p.x - 15, player.shape.body.p.y - 15, ball.x, ball.y)
    #Player Radius: 30
    #ball radius: 15
    dist < 45
  end
end