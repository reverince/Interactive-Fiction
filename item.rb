#require 'active_support/inflector' # pluralize
GOLD_UNIT = "원"

class Item
  attr_reader :name, :desc, :value
  
  def initialize(name, desc, value=nil)
    @name = name
    @desc = desc
    @value = value
  end
  
  def info
    "< #{@name} > : #{@desc}"
  end
  
end

class Container
  attr_reader :name, :desc, :key, :item, :open
  
  def initialize(name, desc, open=false, key: nil, item: [])
    @name = name
    @desc = desc
    @key = key
    @item = item
    @open = open
  end
  
  def info
    res = "< #{@name} > : #{@desc}"
    res += "\n닫혀 있어요." if !@open
    res += "\n안에는" + josa(@item.map(&:name).join(", "),"가") + " 들어 있어요." if @open and @item.any?
    res += "\n안에는 아무 것도 없어요." if @open and @item.empty?
    
    res
  end
  
  def inspect
    if @open
      if @item
        puts "* 안에는 " + josa(@item.map(&:name).join(", "), "가") + " 들어 있어요."
      else
        puts "* 안에는 아무 것도 없어요."
      end
    else
      puts "* " + josa(@name, "는") + " 닫혀 있어요."
    end
  end
  
  def try_open
    if @open
      puts "* " + josa(@name, "는") + " 이미 열려 있어요."
    else
      if @key
        puts "* " + josa(@name, "는") + " 잠겨 있어요."
      else
        puts "* " + josa(@name, "를") + " 열었어요."
        @open = true
        inspect
      end
    end
  end
  
  def try_unlock(key)
    if @key
      if key.is_a? @key
        puts "* " + "#{@name}의 잠금을 풀었어요!"
        @key = nil
      else
        puts "* " + josa(key.name, "는") + " #{@name}에 맞지 않는 것 같아요."
      end
    else
      puts "* " + josa(@name, "는") + " 잠겨 있지 않아요."
    end
  end
  
end

class Key
  attr_reader :name, :desc
  
  def initialize(name, desc)
    @name = name
    @desc = desc
  end
  
  def info
    "< #{@name} > : #{@desc}"
  end
  
end

class Weapon < Item
  attr_reader :atk
  
  def initialize(name, desc, value: nil, atk:)
    super(name, desc, value)
    @atk = atk
  end
  def info
    super + " [무기] [ATK: #{@atk}]"
  end
  
end


# 상자 목록

class WoodenChest < Container
  
  def initialize(key: nil, item: [])
    super("나무상자", "나무로 된 상자입니다.", key: key, item: item)
  end
  
end

class WoodenKey < Key
  
  def initialize
    super("나무열쇠", "나무로 된 열쇠입니다. 세게 돌리지 않는 게 좋을 것 같네요.")
  end
  
end


# 아이템 목록

class Coin < Item
  
  def initialize(value)
    super("#{value}원", "#{value}원짜리 동전입니다.", value)
  end
  
end

class WoodenSword < Weapon
  
  def initialize
    super("목검", "나무로 만든 검입니다.", value: 500, atk: 5)
  end
  
end

class SpiderLeg < Item
  
  def initialize
    super("거미다리", "이런 게 필요할까...")
  end
  
end
