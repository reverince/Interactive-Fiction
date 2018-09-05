
require_relative "item"

class Player
  MAX_HP = 100
  attr_accessor :name, :x, :y, :lvl, :str, :acu, :evs, :def, :hp, :weapon, :inv
  
  def initialize(name)
    @name = name
    @x = @y = 0
    @lvl = 1
    @str = 10
    @acu = 10
    @evs = 10
    @def = 10
    @hp = MAX_HP
    @weapon = nil
    @inv = [Coin.new(500)]
  end
  
  def info
    res = "Level #{@lvl} < #{@name} >\nSTR: #{@str} / ACU: #{@acu} / EVS: #{@evs} / DEF: #{@def}\nHP: ["
    (@hp/10).times do res += "*" end
    (10-@hp/10).times do res += "." end
    res += "]"
    res += "\n무기: #{@weapon.name} [ATK: #{@weapon.atk}]" if @weapon
    
    res
  end
  
  def inventory
    !@inv.empty? ? ( "가방에는 " + josa(@inv.map(&:name).join(", "), "가") + " 있습니다." ) : ( "가방이 비었습니다." )
  end
  
  def get_item(item)
    @inv << item
  end
  
  def drop_item(idx)
    @inv.delete_at(idx)
  end
  
  def equip_item(idx)
    if @inv[idx].is_a? Weapon
      if @weapon.nil?
        puts "* " + josa(@inv[idx].name, "를") + " 장착했어요."
      else
        puts "* #{@weapon.name} 대신에 " + josa(@inv[idx].name, "를") + " 장착했어요."
        @inv << @weapon
      end
      @weapon = @inv[idx]
      @inv.delete_at(idx)
    else
      puts "* " + josa(@inv[idx].name, "는") + " 장착할 수 없어요."
    end
  end
  
  def unequip_item(name)
    if @weapon
      if @weapon.name == name
        puts "* " + josa(@weapon.name, "를") + " 장착 해제했어요."
        @inv << @weapon
        @weapon = nil
      end
    end
  end
  
  def room
    Room.find(@x, @y)
  end
  
  def position
    Room.info(@x, @y)
  end
  
end
