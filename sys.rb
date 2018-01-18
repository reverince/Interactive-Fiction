require 'base64'
require_relative "josa"
require_relative "player"
require_relative "room"
SAVE_FILE_NAME = "save"
TOMB_FILE_NAME = "tomb"

EAST = 0
SOUTH = 1
WEST = 2
NORTH = 3

# 시스템 구현

def input
	while true
		ipt = gets
		if ipt.valid_encoding?
			break
		else
			print "미안하지만 다시 입력해 주세요. >>"
		end
	end
	ipt.chop.upcase
end
def no_command
	"* 그런 명령어는 없어요."
end
def typing(str) #한 글자씩 출력
	str.chars.each { |c| print c; sleep(1)}
	puts ""
end

# 시스템 커맨드

def load_file
	begin
		f = File.read(SAVE_FILE_NAME).split('|')
		@chara = Marshal.load(Base64.decode64(f[0]))
		@map.tiles = Marshal.load(Base64.decode64(f[1]))
		@chara and @map ? ( puts "* 데이터를 불러왔어요!" ) : ( raise StandardError "[DEBUG] 저장 파일이 손상되었습니다." )
	rescue Errno::ENOENT
		puts "! 저장 파일을 찾을 수 없어요."
	end
end
def save_file
	f = File.open(SAVE_FILE_NAME, "w")
	f.puts Base64.encode64(Marshal.dump(@chara))
	f.write "|"
	f.puts Base64.encode64(Marshal.dump(@map.tiles))
	f.close
	puts "* 데이터를 저장했어요!"
end
def delete_save_file
	begin
		File.delete(SAVE_FILE_NAME)
	rescue Errno::ENOENT
		puts "* 저장한 적 없이 죽으셨군요."
	end
end
def load_tomb_file
	begin
		f = File.read(TOMB_FILE_NAME).split('|')
		f.each { |c| puts "- - - - - - - - - - - - - - - - - - - -\n"; puts c }
		puts "- - - - - - - - - - - - - - - - - - - -\n"
	rescue Errno::ENOENT
		puts "! 묘지 파일을 찾을 수 없어요."
	end
end
def save_tomb_file(will)
	f = File.open(TOMB_FILE_NAME, "a")
	f.puts "[RIP] #{@chara.name}, 여기에 잠들다."
	f.puts "Level: #{@chara.lvl}"
	f.puts josa(@chara.weapon.name, "를") + " 손에 쥐고 죽었다." if @chara.weapon
	f.puts "유언: #{will}"
	f.write "|"
	f.close
	puts "* #{@chara.name}의 데이터가 묘지 파일에 저장되었습니다..."
end

def quit_game
	print "저장되지 않은 데이터는 사라져요. 계속할까요? (Q네/S저장/아니요) >>"
	case (ipt = gets.chop.upcase)
		when /^[QY]$/, /^네/
			puts "* 종료합니다."
			exit(0)
		when "S", /^저장/
			save_file
			puts "* 종료합니다."
			exit(0)
	end
end

def game_over
	puts "\n\t- - - - - - - - - - - - - - - - - - - -\n\t\t* 우린 망했습니다...\n\t- - - - - - - - - - - - - - - - - - - -\n"
	puts josa(@chara.name, "는") + " #{@chara.room.name}에서 싸늘한 시체로 발견되었습니다..."
	puts "죽어버린 " + @chara.info
	puts @chara.inventory
	print "유언 >>"
	while true
		will = input
		break unless will.include? "|" # '|' 입력 불가.
	end
	save_tomb_file(will)
	delete_save_file
	exit(0)
end

# 일반 커맨드

def ipt_look(ipt) # 가방, 방, 컨테이너, 무기 조사
	case ipt
		when /^나를/
			puts "* 괜찮아 보이네요."
		when /^방을/, /^여[기길]/
			puts @chara.position
	else
		found = false
		idx_inv = @chara.inv.map(&:name).index(target = ipt.split(/[을를]/)[0]) if @chara.inv
		idx_room = @chara.room.item.map(&:name).index(target) if @chara.room.item
		idx_container = @chara.room.container.map(&:name).index(target) if @chara.room.container
		if idx_inv
			puts @chara.inv[idx_inv].info
			found = true
		elsif idx_room
			puts @chara.room.item[idx_room].info
			found = true
		elsif idx_container
			puts @chara.room.container[idx_container].info
			found = true
		end
		if @chara.room.container and !found # 컨테이너 안 아이템 조사
			items_in_container = []
			@chara.room.container.find_all{|c| c.open}.each{|c| c.item.each{|i| items_in_container << i}}
			idx_item_in_container = items_in_container.map(&:name).index(target) if !items_in_container.empty?
			if idx_item_in_container
				puts items_in_container[idx_item_in_container].info
				found = true
			end
		end
		if @chara.weapon and @chara.weapon.name == target and !found
			puts @chara.weapon.info + " [장비중]"
			found = true
		end
		puts "* 그런 물건을 찾지 못했어요." unless found
	end
end

def move(direc)
	case direc
		when EAST
			x_dest, y_dest = @chara.x + 1, @chara.y
		when SOUTH
			x_dest, y_dest = @chara.x, @chara.y + 1
		when WEST
			x_dest, y_dest = @chara.x - 1, @chara.y
		when NORTH
			x_dest, y_dest = @chara.x, @chara.y - 1
	end
	if Room.find(x_dest, y_dest)
		@chara.x, @chara.y = x_dest, y_dest
		puts @chara.position
		sleep(1)
		if @chara.room.enemy
			idx_enemy = @chara.room.enemy.map(&:hostile).index(true)
			if idx_enemy
				battle(@chara.room.enemy[idx_enemy])
			end
		end
	else
		puts "* 그쪽은 막혀 있어요."
	end
end
def ipt_move(ipt)
	case ipt
		when "ME", /^동쪽/
			move(EAST)
		when "MS", /^남쪽/
			move(SOUTH)
		when "MW", /^서쪽/
			move(WEST)
		when "MN", /^북쪽/
			move(NORTH)
	else
		puts "* 어느 쪽으로 가실 건가요?"
	end
end

def ipt_get(ipt)
	case ipt
		when /^나[를]/
			puts "* 네?"
		when /^방[을]/, /^여[기길]/
			puts "* 농담이죠?"
	else
		found = false
		target = ipt.split(/[을를]/)[0]
		if @chara.room.item
			if ( idx_item = @chara.room.item.map(&:name).index(target) )
				puts josa(target, "를") + " 주웠어요."
				@chara.get_item(@chara.room.item[idx_item])
				@chara.room.item.delete_at(idx_item)
				found = true
			end
		end
		if @chara.room.container
			if ( idx_item = @chara.room.container.map(&:name).index(target) )
				puts josa(target, "는") + " 주울 수 없어요."
				found = true
			else # 컨테이너 탐색
				idx_containers_items = {}
				@chara.room.container.each_with_index{|c, i| idx_c_i[i] = c.item.map(&:name).index(target) if c.open && c.item }
				idx_containers_items.compact!
				unless idx_containers_items.empty?
					idx_container = idx_containers_items.keys[0]
					idx_item = idx_containers_items.values[0]
					@chara.get_item(@chara.room.container[idx_container].item[idx_item])
					@chara.room.container[idx_container].item.delete_at(idx_item)
					puts josa(target, "를") + " 주웠어요."
					found = true
				end
			end
		end
		if !@chara.room.item && !@chara.room.container
			puts "* 이 방에는 주울 물건이 없어요."
			found = true
		end
		puts "* 그런 물건을 찾지 못했어요." unless found
	end
end

def ipt_drop(ipt)
	case ipt
		when /^나를/
			puts "* 힘내세요."
		when /^방을/, /^여[기길]/
			puts "* 농담이죠?"
	else
		if @chara.inv
			if ( idx_item = @chara.inv.map(&:name).index(target = ipt.split(/[을를]/)[0]) )
				puts josa(target, "를") + " 버렸어요."
				@chara.room.item << @chara.inv[idx_item]
				@chara.drop_item(idx_item)
			else
				puts "* 무엇을 버리실 건가요?"
			end
		else
			puts "* 버릴 물건이 없어요."
		end
	end
end

def ipt_equip(ipt)
	case ipt
		when /^나를/
			puts "* 허?"
		when /^방을/, /^여[기길]/
			puts "* 농담이죠?"
	else
		if @chara.inv
			if ( idx_item = @chara.inv.map(&:name).index(target = ipt.split(/[을를]/)[0]) )
				@chara.equip_item(idx_item)
			else
				puts "* 무엇을 장착하실 건가요?"
			end
		else
			puts "* 장착할 물건이 없어요."
		end
	end
end
def ipt_unequip(ipt)
	case ipt
		when /^나를/
			puts "* 뗄래야 뗄 수 없네요."
		when /^방을/, /^여[기길]/
			puts "* 농담이죠?"
	else
		if @chara.weapon
			if @chara.weapon.name == ( target = ipt.split(/[을를]/)[0] )
				@chara.unequip_item(target)
			else
				puts "* 무엇을 장착 해제하실 건가요?"
			end
		else
			puts "* 아무 것도 장착하고 있지 않아요."
		end
	end
end

def ipt_open(ipt)
	case ipt
		when /^나를/
			puts "* 시적이네요."
		when /^방을/, /^여[기길]/
			puts "* 감금당한 상태는 아니에요."
		when /^([가-힣]+)[로] +([가-힣]+)[을를]/, /^([가-힣]+)[을를] +([가-힣]+)[로]/
			if (/^([가-힣]+)[로] +([가-힣]+)[을를]/).match? ipt
				key = $1
				target = $2
			elsif (/^([가-힣]+)[을를] +([가-힣]+)[로]/).match? ipt
				key = $2
				target = $1
			end
			if target.is_a? String
				target = target.split(/[을를]/)[0].strip
			end
			if @chara.inv
				if ( idx_key = @chara.inv.map(&:name).index(key) )
					if @chara.room.container
						if ( idx_container = @chara.room.container.map(&:name).index(target) )
							@chara.room.container[idx_container].try_unlock(@chara.inv[idx_key])
						else
							puts "* 그런 상자가 없어요."
						end
					else
						puts "* 이 방에는 상자가 없어요."
					end
				else
					puts "* 그런 열쇠는 가지고 있지 않아요."
				end
			else
				puts "* 그런 열쇠는 가지고 있지 않아요."
			end
	else
		if @chara.room.container
			if ( idx = @chara.room.container.map(&:name).index(target = ipt.split(/[을를]/)[0]) )
				@chara.room.container[idx].try_open
			else
				puts "* 무엇을 여실 건가요?"
			end
		else
			puts "* 여기엔 상자가 없어요."
		end
	end
end

# 전투 구현
NORMAL = 0
EVADING = 1
GUARDING = 2

EVADING_MUL = 1.5
GUARDING_MUL = 2
RANDO_RANGE = 20
def rando(n, r)
	rand( ((n - n/r.to_f).to_i) .. ((n + n/r.to_f).to_i) ).to_i
end

def player_hit(enemy, mul=1)
	rando(enemy.acu, RANDO_RANGE) - rando(@chara.evs * mul, RANDO_RANGE) > 0 ? true : false 
end
def enemy_hit(enemy)
	rando(@chara.acu, RANDO_RANGE) - rando(enemy.evs, RANDO_RANGE) > 0 ? true : false 
end
def player_damage
	@chara.weapon ? rando(@chara.str + @chara.weapon.atk, RANDO_RANGE) : rando(@chara.str, RANDO_RANGE)
end
def enemy_damage(enemy, mul=1)
	[rando(enemy.str, RANDO_RANGE) - rando(@chara.def * mul, RANDO_RANGE), 0].max
end
def player_attack(enemy)
	puts "* 당신이 " + josa(enemy.name, "를") + " 공격합니다!"
	sleep(1)
	if enemy_hit(enemy)
		dmg = player_damage
		puts "* #{enemy.name}에게 #{dmg}의 데미지!"
		enemy.hp -= dmg
	else
		puts "* 당신의 공격이 빗나갔습니다!"
	end
end
def enemy_attack(enemy, player_status)
	puts "* " + josa(enemy.name, "가") + " 당신을 공격합니다!"
	sleep(1)
	case player_status
		when NORMAL
			if player_hit(enemy)
				puts "* #{dmg = enemy_damage(enemy)}의 데미지!"
				@chara.hp -= dmg
				puts "* #{@chara.name}의 체력이 #{@chara.hp} 남았어요!" if @chara.hp > 0
				sleep(1)
			else
				puts "* #{enemy.name}의 공격을 피했습니다!"
			end
		when EVADING
			if player_hit(enemy, EVADING_MUL)
				puts "* #{dmg = enemy_damage(enemy)}의 데미지!"
				@chara.hp -= dmg
				puts "* #{@chara.name}의 체력이 #{@chara.hp} 남았어요!" if @chara.hp > 0
				sleep(1)
			else
				puts "* #{enemy.name}의 공격을 피했습니다!"
			end
		when GUARDING
			dmg = enemy_damage(enemy, GUARDING_MUL)
			if dmg > 0
				puts "* #{@chara.name}에게 #{dmg}의 데미지!"
				@chara.hp -= dmg
				sleep(1)
				puts "* #{@chara.name}의 체력이 #{@chara.hp} 남았어요!" if @chara.hp > 0
			else
				puts "* 공격을 막아냈습니다!"
			end
	end
end
def battle(enemy)
	puts "* 야생의 " + josa(enemy.name, "가") + " 나타났다!"
	sleep(1)
	while @chara.hp > 0 and enemy.hp > 0 # 전투 루프
		player_status = NORMAL
		print "어떻게 하시겠어요? (A공격/S회피/D방어) >>"
		case (ipt = input)
			when "A", /^공격/
				player_attack(enemy)
				sleep(1)
				puts "* #{enemy.name}의 체력이 #{enemy.hp} 남았어요!" if enemy.hp > 0
			when "S", /^회?피/
				puts "* " + josa(@chara.name, "는") + " 피할 준비를 합니다!"
				player_status = EVADING
			when "D", /^방어/, /^막/
				player_status = GUARDING
			puts "* " + josa(@chara.name, "가") + " 방어 자세를 취합니다!"
		else
			puts "* " + josa(@chara.name, "가") + " 주춤거립니다!"
		end	
		break if enemy.hp <= 0
		sleep(1)
		enemy_attack(enemy, player_status)
		sleep(1)
	end
	if @chara.hp <= 0
		game_over
	elsif enemy.hp <= 0
		puts "\n* " + josa(enemy.name, "를") + " 물리쳤어요! 오-예."
		enemy.drop_item(@chara.room)
		@chara.room.enemy.delete(enemy)
	end
end
