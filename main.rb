$LOAD_PATH << File.dirname(__FILE__) #This is used to avoid requireing file areas

require 'rubygems'
require 'gosu'
require 'game'

Game.new.show