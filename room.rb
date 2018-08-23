require_relative "item"
require_relative "enemy"

class Room
  attr_accessor :item, :enemy, :container
  attr_reader :name
  @@tiles = {}
  
  def initialize(name, desc, x, y, item: [], enemy: [], container: [])
    @@tiles[[x, y]] = self
    @name = name
    @desc = desc
    @x = x
    @y = y
    @item = item
    @enemy = enemy
    @container = container
  end
  
  def self.tiles
    @@tiles
  end
  
  def self.tiles=(tiles)
    @@tiles = tiles
  end
  
  def self.find(x, y)
    @@tiles[[x, y]]
  end
  
  def self.info(x, y)
    if @@tiles[[x, y]]
      @@tiles[[x, y]].info
    else
      "[#{x}, #{y}]에는 방이 없습니다."
    end
  end
  
  def info
    res = "< #{@name} > [#{@x}, #{@y}] : #{@desc}"
    res += "\n" + josa(@item.map(&:name).join(", "), "가") + " 놓여 있습니다." unless @item.empty?
    res += "\n" + josa(@enemy.map(&:name).join(", "), "가") + " 당신을 노려보고 있습니다." unless @enemy.empty?
    res += "\n" + josa(@container.map(&:name).join(", "), "가") + " 놓여 있습니다." unless @container.empty?
    res += "\n" + "이곳에는 아무 것도 없습니다." if @item.empty? and @enemy.empty? and @container.empty?
    open_direc =  []
    open_direc << "동쪽" if @@tiles[[@x+1, @y]]
    open_direc << "남쪽" if @@tiles[[@x,@y+1]]
    open_direc << "서쪽" if @@tiles[[@x-1, @y]]
    open_direc << "북쪽" if @@tiles[[@x,@y-1]]
    res += "\n" + josa(open_direc.join(", "), "로") + " 갈 수 있습니다."
    
    res
  end
  
end

def initialize_map
  startingRoom = Room.new("시작의 방", josa(@chara.name, "가") + " 깨어난 곳입니다.", 0, 0, item: [WoodenSword.new, WoodenKey.new])
  spiderRoom = Room.new("거미줄이 쳐진 방", "끈적합니다.", 0, 1, enemy: [GiantSpider.new], container: [WoodenChest.new(key: WoodenKey, item: [Coin.new(50)])])
  emptyRoom = Room.new("빈 방", "휑한 방입니다.", 1, 0)
end
