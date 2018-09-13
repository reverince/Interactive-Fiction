require_relative "item"

class Enemy
  attr_accessor :str, :acu, :evs, :hp
  attr_reader :name, :desc, :hostile, :drop
  
  def initialize(name, desc, str, acu, evs, hp, hostile=false, drop: [])
    @name = name
    @desc = desc
    @str = str
    @acu = acu
    @evs = evs
    @hp = hp
    @hostile = hostile
    @drop = drop
  end
  
  def info
    "< #{@name} > : #{@desc}"
  end
  
  def drop_item(room)
    puts "* " + josa(@name, "가") + " " + josa(@drop.map(&:name).join(", "), "를") + " 떨어뜨렸어요!"
    @drop.each { |item| room.item << item }
    @drop = []
  end
  
end

class GiantSpider < Enemy
  
  def initialize
    super("거대 거미", "징그럽습니다.", str=30, acu=10, evs=5, hp=50, true, drop: [SpiderLeg.new])
  end
  
end

class Skeleton < Enemy
  
  def initialize
    super("스켈레톤", "금방이라도 부서질 것 같지만 어떻게든 붙어 있습니다.", 50, 5, 1, 100, true)
  end
  
end
