require_relative "sys"

while !@chara
	@map = Room
	print "N 처음부터 / L 불러오기 / T 묘지 / Q 종료 >> "
	case (ipt = input)
		when "N", /^처음/, /^새/
			print "이름을 입력해 주세요. >> "
			name = input
			@chara = Player.new(name)
			initialize_map
		when "L", /^로드/, /^불러/
			load_file
		when "T", /^묘지/
			load_tomb_file
		when "Q", /^종료/
			quit_game
	else
		puts no_command
	end
end

puts "\n* 어서오세요, #{@chara.name}님."
sleep(0.5)
puts @chara.position

loop do
	sleep(0.5)
	print "\n(도움 H) 어떻게 하시겠어요? >> "
	case (ipt = input)
		when "H", /^도움/, /^명령/
			puts "명령어로는 [S저장, C정보, I가방, W위치, Q종료, 본다/살핀다, 간다/이동, 줍는다/버린다, (~로 ~를) 연다]가 있습니다."
		when "S", /^저장/, /^기록/
			save_file
		when "C", /^정보/, /^상태/
			puts @chara.info
		when "I", /^가방/
			puts @chara.inventory
		when "W", /^위치/
			puts @chara.position
		when /^L/, /본다([!.]*)$/, /살핀다([!.]*)$/
			ipt_look(ipt)
		when /^M/, /간다([!.]*)$/, /이동(한다)*([!.]*)$/
			ipt_move(ipt)
		when /^G/, /줍는다([!.]*)$/
			ipt_get(ipt)
		when /^D/, /버린다([!.]*)$/
			ipt_drop(ipt)
		when /^E/, /장착한다([!.]*)$/, /낀다([!.]*)$/
			ipt_equip(ipt)
		when /^U/, /장착 해제한다([!.]*)$/, /벗는다([!.]*)$/
			ipt_unequip(ipt)
		when /^O/, /연다([!.]*)$/
			ipt_open(ipt)
		when "Q", /^종료/
			quit_game
	else
		puts no_command
	end
end
