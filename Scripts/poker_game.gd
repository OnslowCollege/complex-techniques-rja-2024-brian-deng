extends Node2D

var files: Array = []
var cards_per_game = files
var player_hand: Array = []
var bot_hands: Dictionary = {}
var bot_hand_ratings: Dictionary = {}
var community_cards: Dictionary = {}
var com_cards = []

const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"

var winner: String = ""
var high_card: int = 0

var show_hand: bool = false
var show_com_cards: Dictionary = {"flop": false, "turn": false, "river": false}
var round_of_betting = {"preflop": false, "flop": false, "turn": false, "river": false}
var show_winner = false

var cards: Dictionary = {}
var sorted_files = Array()
var suited: Array = []
var suits: Array = ["clubs", "spades", "hearts", "diamonds"] 
var counter: int = 1
var fold_pressed: bool = false
var started: bool = false
var sprites: Array = []
var awaited: bool = false

var player_bet: Array = []
var balance: int = 1000
var slider_value: int = 0
var slider_used: bool = false
var chip_betting: bool = false
var finalised_bet: Dictionary = {"preflop": [], "flop": [], "turn": [], "river": []}
var action_on: int = 1
var all_in: bool = false
var bot_betting = []
const min_bot_bet = 20
var max_bot_bet = balance/2 
var pot = 0
var all_bets = {"preflop": [], "flop": [], "turn": [], "river": []}
var past_player_bet_total: int = 0

var hands = {"Royal Flush": 10, "Straight Flush": 9, "Four of a Kind": 8, 
	"Full House": 7, "Flush": 6, "Straight": 5, "Three of a Kind": 4, 
	"Two Pair": 3, "Pair": 2, "High Card": 1}

var raise_count_bot = {1: 0, 2: 0, 3: 0, 4: 0}
var bot_betting_per = {1: [], 2: [], 3: [], 4: []}

func initialize_game():
	$Betting.visible = false
	$Betting/settings.visible = false
	$Dealing.visible = false
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$action_bg.visible = false
	$Table2/bg.visible = false
	
	list_files_in_directory(card_path)
	$Table2/balance_bg/balance.text = "Balance: %s" % balance

func separate_int(list_of_strings: Array) -> Array:
	var card_nums = []
	if list_of_strings == ["", ""]:
		return []
	for item in list_of_strings:
		var num_list = []
		var double_digit = []
		var string_split = item.split("-")
		if ".png" in string_split[-1]:
			var png_split = Array(string_split[-1].split(""))
			var png_slice = png_split.slice(-4)
			for i in png_slice:
				(png_split).erase(i)
			num_list = png_split
		else:
			num_list = string_split[-1]
		for char in num_list:
			if char == "0":
				double_digit.append(char)
			elif int(char):
				double_digit.append(char)
		if len(double_digit) >= 2:
			card_nums.append(("%s%s" % [double_digit[0], double_digit[1]]))
		elif len(double_digit) == 0:
			pass
		else:
			card_nums.append(double_digit[0])
	print(str(card_nums) + "nums")
	return card_nums

func if_straight(list1: Array, list2: Array) -> Variant:
	var combined = (list1 + list2)
	var unique_combined = []
	for item in combined:
		if item not in unique_combined: 
			unique_combined.append(item)
	if 1 in unique_combined: unique_combined.append(14)
	unique_combined.sort()
	
	var count = 0
	var straight = []
	for num in range(len(unique_combined)-1, -1, -1): 
		if unique_combined[num] < 1 or unique_combined[num] > 14: continue
		if unique_combined[num] == 14 and unique_combined[num - 1] == 1: continue
		if int(unique_combined[num]) - 1 == unique_combined[num - 1]:
			count += 1
			straight.append(num)
			if count == 4: 
				return straight
		else: 
			count = 0
			straight.clear()
	print(str(unique_combined) + "unique")
	return false

func if_flush(p_hand: Array, community_cards: Array) -> bool:
	var player_suits = []
	var community_suits = []
	for suit in suits:
		for card in p_hand:
			if suit in card:
				player_suits.append(suit)
		for card in community_cards:
			if suit in card:
				community_suits.append(suit)
	var total_suits = player_suits + community_suits
	print(str(total_suits) + "total_suits")
	for suit in total_suits:
		var suit_count = total_suits.count(suit)
		if suit_count == 5:
			return true
	return false

func of_a_kind(player_list: Array, community_list: Array) -> String:
	var total_list = player_list + community_list
	var num_duplicates = []
	
	for num in range(0, 15):
		var dup_count = total_list.count(num)
		if dup_count >= 2:
			num_duplicates.append(dup_count)
	if len(num_duplicates) >= 3:
		num_duplicates.sort()
		num_duplicates.pop_front()
	if 4 in num_duplicates:
		return "Four of a Kind"
	elif num_duplicates.count(3) >= 1:
		if num_duplicates.count(3) >= 2:
			return "Full House"
		elif num_duplicates.count(3) == 1 and num_duplicates.count(2) >= 1 :
			return "Full House"
		elif num_duplicates.count(3) == 1:
			return "Three of a Kind"
	elif num_duplicates.count(2) == 2:
		return "Two Pair"
	elif num_duplicates.count(2) == 1:
		return "Pair"
	else:
		return "High Card"
	return ("")

func rating_hand(p_hand: Array, round: Dictionary) -> Dictionary:
	var card_id = {}
	var suit = ""
	for card in round.values():
		var card_squared = []
		card_squared.append(card)
		var card_int = separate_int(card_squared)
		var split = card.split("-")
		var key = int(card_int[0])
		suit = split[1]

		if suit ==  "clubs":
			card_id[key] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "diamonds":
			card_id[key + 13] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "hearts":
			card_id[key + 26] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "spades":
			card_id[key + 39] = ("%s %s" % [suit, card_int[0]])
		
	print(str(card_id) + "card_id")

	var player_int_list = separate_int(p_hand).map(func(s): return int(s))
	var com_int_list = separate_int(card_id.values()).map(func(s): return int(s))

	var straight  = false
	var flush = false 
	var straight_nums = if_straight(player_int_list,com_int_list)
	if not straight_nums: 
		pass
	else: 
		straight = true
	if if_flush(p_hand, card_id.values()):
		flush = true

	var hand_value = 0
	var high_card = (player_int_list + com_int_list).max()
	if straight and flush and (straight_nums.max() == 14):
		hand_value = hands["Royal Flush"]
	elif straight and flush and (straight_nums.max() != 14):
		hand_value = hands["Straight Flush"]
	elif flush:
		hand_value = hands["Flush"]
	elif straight:
		hand_value = hands["Straight"]
	elif of_a_kind(player_int_list, com_int_list) != "":
		hand_value = hands[of_a_kind(player_int_list, com_int_list)]
	else:
		hand_value = hands["High Card"]
	return {"value": hand_value, "high_card": high_card}

func preflop_action(action_on) -> Variant:
	var action_to_take = ""
	var action_value = 0
	var final_value = []
	var bot_action = [1,2,3,4]
	var pocket_pair = false
	if action_on not in bot_action:
		return null
	if action_on in bot_action:
		var hand = bot_hands[action_on]
		var action_int = separate_int(hand).map(func(s): return int(s))
		print(action_int)
		print(";ll")
		action_int.sort()
		if 1 in action_int:
			action_int[0] = int(action_int[0]) + 13
		var action_int_numeric = []
		for action in action_int:
			action_int_numeric.append(int(action))
		print(action_int_numeric)
		print(";oo")
		if action_int_numeric.size() == 0:
			return "fold"
		elif action_int_numeric[0] == action_int_numeric[1]:
			pocket_pair = true
			if action_int_numeric[0] >= 12:
				action_value = 10
			elif action_int_numeric[0] == 11:
				action_value = 9
			elif action_int_numeric[0] <= 10 and action_int_numeric[0] >= 7:
				action_value = 7
			elif action_int_numeric[0] <= 6 and action_int_numeric[0] >= 4:
				action_value = 6
			elif action_int_numeric[0] <= 3:
				action_value = 4
			final_value.append(action_value)
		var hand_int_total = 0
		for num in range(0,2):
			hand_int_total += int(action_int[num])
		if hand_int_total >= 23:
			action_value = 9
		elif hand_int_total <= 22 and hand_int_total >= 20:
			action_value = 8
		elif hand_int_total <= 19 and hand_int_total >= 15:
			action_value = 7
		elif hand_int_total <= 14 and hand_int_total >= 11:
			action_value = 5
		elif hand_int_total <= 11:
			action_value = 2
		final_value.append(action_value)
	final_value = final_value.max()
	if final_value <= 4:
		action_to_take = "fold"
	elif final_value >= 5 and final_value <=7:
		action_to_take = "call"
	elif final_value >= 8:
		action_to_take = "raise"
	return action_to_take


func arrow_change(start: Vector2, end: Vector2, width: float):
	# Making arrow base or the line.
	$arrow/Line.clear_points()
	$arrow/Line.add_point(start)
	$arrow/Line.add_point(end)
	$arrow/Line.width = width
	
	# Setting vars for proper arrow head orientation and size
	var direction = (end - start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x) * (width * 2)
	var arrowhead_base_left = end + perpendicular
	var arrowhead_base_right = end - perpendicular 
	
	# Making polygon/ arrow head
	var points = PackedVector2Array()
	points.append(end + direction * (width * 4)) # Tip of the arrow
	points.append(arrowhead_base_left) # Left base
	points.append(arrowhead_base_right)   # Right base
	
	# Setting polygon
	$arrow/head.polygon = points
	# To ensure the polygon positioned correctly
	$arrow/head.position = Vector2(0,0) 


func update_action_pointer():
	var positions = {
		0: Vector2(400, 550),  # Player position
		1: Vector2(200, 300),  # Bot 1 position
		2: Vector2(400, 100),  # Bot 2 position
		3: Vector2(600, 300),  # Bot 3 position
		4: Vector2(400, 550)   # Back to player position
	}
	arrow_change(positions[action_on], (positions[action_on] - Vector2(100, 100)), 10)
	$arrow.visible = true


func start_betting_round(stage):
	round_of_betting[stage] = true
	action_on = 1
	update_action_pointer()
	if action_on == 1:
		awaited = true
		$action_bg.visible = true
	else:
		bot_play(action_on)


func get_current_stage():
	for stage in ["preflop", "flop", "turn", "river"]:
		if round_of_betting[stage]:
			return stage
	return "preflop"


func bot_play(action_on):
	var text_node = get_node_or_null("Bot%s/action" % [action_on])
	if text_node == null:
		print("Error: Bot%s/action node not found" % [action_on])
		return

	var current_stage = get_current_stage()
	var action = decide_bot_action(action_on, current_stage)
	
	match action:
		"check":
			handle_check(action_on, text_node, current_stage)
		"call":
			handle_call(action_on, text_node, current_stage)
		"raise":
			handle_raise(action_on, text_node, raise_count_bot[action_on], current_stage)
		"fold":
			handle_fold(action_on, text_node)

	update_betting_totals(action_on)
	update_ui(action_on, text_node)
	
	await get_tree().create_timer(1.0).timeout
	next_player()


func next_player():
	action_on = (action_on % 4) + 1
	update_action_pointer()
	
	if action_on == 1:
		awaited = true
		$action_bg.visible = true
	else:
		bot_play(action_on)


func decide_bot_action(action_on, stage):
	if stage == "preflop":
		return preflop_action(action_on)
	else:
		var community_cards_count = 3 if stage == "flop" else 4 if stage == "turn" else 5
		var current_community_cards = {}
		for i in range(community_cards_count):
			current_community_cards[i] = community_cards.values()[i]
		
		var hand_rating = rating_hand(bot_hands[action_on], current_community_cards)
		return decide_postflop_action(hand_rating.value, stage)


func handle_preflop_betting(action_on, text_node, raise_count, current_stage):
	if bot_hands[action_on] == ["", ""]:
		return

	var action = preflop_action(action_on)
	match action:
		"call":
			handle_call(action_on, text_node, current_stage)
		"raise":
			handle_raise(action_on, text_node, raise_count, current_stage)
		"fold":
			handle_fold(action_on, text_node)

func handle_postflop_betting(action_on, text_node, stage):
	var community_cards_count = 3 if stage == "flop" else 4 if stage == "turn" else 5
	var current_community_cards = {}
	for i in range(community_cards_count):
		current_community_cards[i] = community_cards.values()[i]
	
	var hand_rating = rating_hand(bot_hands[action_on], current_community_cards)
	var action = decide_postflop_action(hand_rating.value, stage)
	
	match action:
		"check":
			handle_check(action_on, text_node, stage)
		"call":
			handle_call(action_on, text_node, stage)
		"raise":
			handle_raise(action_on, text_node, raise_count_bot[action_on], stage)
		"fold":
			handle_fold(action_on, text_node)

func decide_postflop_action(hand_rating, stage):
	var action_threshold = 5 if stage == "flop" else 6 if stage == "turn" else 7
	if hand_rating >= action_threshold:
		return "raise" if randf() > 0.5 else "call"
	elif hand_rating >= action_threshold - 2:
		return "call" if randf() > 0.3 else "check"
	else:
		return "fold" if randf() > 0.7 else "check"

func handle_check(action_on, text_node, stage):
	text_node.text = "Bot%s: check" % [action_on]
	all_bets[stage].append(0)
	bot_betting_per[action_on].append(0)

func handle_call(action_on, text_node, stage):
	var bet_amount = all_bets[stage].max() if not all_bets[stage].is_empty() else 20
	all_bets[stage].append(bet_amount)
	bot_betting_per[action_on].append(bet_amount)
	text_node.text = "Bot%s: call %s" % [action_on, bet_amount]

func handle_fold(action_on, text_node):
	bot_hands[action_on] = ["", ""]
	text_node.text = "Bot%s: fold" % [action_on]

func handle_raise(action_on, text_node, raise_count, stage):
	if raise_count < 2:
		var raise_amount = calculate_raise_amount(action_on, stage)
		all_bets[stage].append(raise_amount)
		bot_betting_per[action_on].append(raise_amount)
		text_node.text = "Bot%s: raise to %s" % [action_on, raise_amount]
		raise_count_bot[action_on] += 1
	else:
		handle_call(action_on, text_node, stage)

func calculate_raise_amount(action_on, stage):
	var current_bet = all_bets[stage].max() if not all_bets[stage].is_empty() else 0
	var raise_factor = randi() % 3 + 2  # Raise between 2x and 4x the current bet
	var raise_amount = current_bet * raise_factor
	raise_amount = min(raise_amount, balance)
	return max(raise_amount, 20)  # Ensure minimum bet of 20

func update_betting_totals(action_on):
	if not bot_betting_per[action_on].is_empty():
		var total = sum_array(bot_betting_per[action_on])
		bot_betting_per[action_on] = [total]

func update_ui(action_on, text_node):
	text_node.add_theme_font_size_override("font_size", 30)
	get_node("Bot%s" % [action_on]).visible = true

func sum_array(array):
	var total = 0
	for num in array:
		total += num
	return total

func _on_call_pressed():
	if not awaited:
		return

	var current_stage = get_current_stage()
	var highest_bet = all_bets[current_stage].max() if all_bets[current_stage] else 0
	var call_amount = highest_bet - past_player_bet_total

	if call_amount > balance:
		call_amount = balance
		all_in = true

	finalised_bet[current_stage].append(call_amount)
	all_bets[current_stage].append(highest_bet)
	balance -= call_amount
	past_player_bet_total += call_amount

	$Table2/balance_bg/balance.text = "Balance: %s" % balance
	$Table2/bg/your_bet.text = "Bet: %s" % highest_bet

	awaited = false
	$action_bg.visible = false

	await get_tree().create_timer(1.0).timeout
	continue_betting(current_stage)

func continue_betting(current_stage):
	if check_betting_round_complete(current_stage):
		end_betting_round(current_stage)
	else:
		next_player()

func check_betting_round_complete(current_stage):
	var bets = all_bets[current_stage]
	return bets.size() >= 4 and bets.all(func(bet): return bet == bets.max())

func end_betting_round(current_stage):
	pot += sum_array(all_bets[current_stage])
	round_of_betting[current_stage] = false
	all_bets[current_stage].clear()
	past_player_bet_total = 0

	match current_stage:
		"preflop":
			show_flop()
		"flop":
			show_turn()
		"turn":
			show_river()
		"river":
			determine_winner()

func start_new_betting_round():
	bot_play(action_on)

func sum(list: Array) -> Variant:
	var total = 0
	for num in list:
		total += num
	return total

func card_img(card: String, pos: Vector2):
	var sprite = Sprite2D.new()
	var texture = load(card_path + str(card))
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = Vector2(0.85, 0.85)
	sprites.append(sprite)
	$".".add_child(sprite)

func list_files_in_directory(path: String):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file: String = dir.get_next()
		if file == "":
			break
		elif ".import" in file:
			continue
		elif not file.begins_with("."):
			files.append(file)
	dir.list_dir_end()
	return files

func _ready():
	initialize_game()
	$Betting.visible = false
	$Betting/settings.visible = false
	$Dealing.visible = false
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$action_bg.visible = false
	$Table2/bg.visible = false
	
	(list_files_in_directory(card_path))
	for i in range(len(files)-1, -1, -1):
		var file = files[i]
		if ("clubs" in file or "hearts" in file or 
			"spades" in file or "diamonds" in file):
			continue
		else:
			files.remove_at(i)

	$Table2/balance_bg/balance.text = ("Balance: %s" % [balance])

func _process(delta):
	if started:
		if fold_pressed:
			reset_game()

		update_card_images()
		update_betting_ui()
		update_balance_and_pot()
		# $PastBetLabel.text = "Past bet: %d" % past_player_bet_total


func update_card_images():
	for sprite in sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	sprites.clear()

	if show_hand:
		card_img(player_hand[0], $Dealing/player_left.position)
		card_img(player_hand[1], $Dealing/player_right.position)

	if show_com_cards["flop"]:
		card_img(community_cards.values()[0], $Flop/card.position)
		card_img(community_cards.values()[1], $Flop/card2.position)
		card_img(community_cards.values()[2], $Flop/card3.position)
	if show_com_cards["turn"]:
		card_img(community_cards.values()[3], $Turn/card.position)
	if show_com_cards["river"]:
		card_img(community_cards.values()[4], $River/card.position)

func update_betting_ui():
	if chip_betting:
		var bet_total = sum(player_bet)
		$Table2/bg/your_bet.text = "Bet: %s" % bet_total

	if slider_used:
		$Betting_slider/HSlider.max_value = balance
		$Table2/bg/your_bet.text = "Bet: %s" % slider_value

func update_balance_and_pot():
	$Table2/balance_bg/balance.text = "Balance: %s" % balance
	$Table2/pot/pot.text = "Pot: %s" % pot

	var total_bet = 0
	for i in finalised_bet.values():
		total_bet += sum(i)
	if balance == total_bet:
		all_in = true

func reset_game():
	$Dealing.visible = false
	$action_bg.visible = false
	started = false
	fold_pressed = false
	show_hand = false
	player_hand.clear()
	for sprite in sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	sprites.clear()
	$Button.visible = true

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_fold_pressed():
	if awaited:
		fold_pressed = true
		awaited = false
		cards_per_game = files
		print(cards_per_game)
		print(files)
		$Bot4.visible = false
		$Bot3.visible = false
		$Bot2.visible = false
		$Bot1.visible = false

func _on_button_pressed():
	player_hand = []
	bot_hands = {}
	bot_hand_ratings = {}
	community_cards = {}
	cards_per_game = files.duplicate()
	winner = ""
	show_hand = false
	show_com_cards = {"flop": false, "turn": false, "river": false}
	round_of_betting = {"preflop": false, "flop": false, "turn": false, "river": false}
	show_winner = false
	finalised_bet = {"preflop": [], "flop": [], "turn": [], "river": []}
	all_bets = {"preflop": [], "flop": [], "turn": [], "river": []}
	pot = 0
	raise_count_bot = {1: 0, 2: 0, 3: 0, 4: 0}
	bot_betting_per = {1: [], 2: [], 3: [], 4: []}
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$Table2/bg.visible = false
	$Table2/pot.visible = false
	for sprite in sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	sprites.clear()

	started = true
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")

	for i in range(0, 5):
		var rand_card = (randi_range(0, len(cards_per_game) - 1))
		community_cards[rand_card] = (cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])
		print(community_cards[rand_card])

	for i in range(0, 2):
		var rand_card = randi_range(0, len(cards_per_game)-1)
		player_hand.append(cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])

	for num in range(0, 4):
		var bot_list = []
		for i in range(0, 2):
			var rand_card = randi_range(0, len(cards_per_game)-1)
			bot_list.append(cards_per_game[rand_card])
			cards_per_game.erase(cards_per_game[rand_card])
		bot_hands[num + 1] = bot_list
	print(bot_hands)
	print(community_cards)
	print(player_hand)
	print(rating_hand(player_hand, community_cards))
	preflop_action(1)
	
	await $Dealing/Dealing2.animation_finished
	round_of_betting["preflop"] = true
	$Table2/bg.visible = true
	$Table2/pot.visible = true
	show_hand = true
	awaited = true
	preflop_action(1)
	preflop_action(2)

func _on_bet_pressed():
	if awaited:
		$action_bg.visible = false
		$Betting.visible = true
		$Betting/settings.visible = true 
		chip_betting = true
		player_bet = []

func _on_settings_pressed():
	$Betting_slider.visible = true
	$Betting.visible = false

func _on_back_pressed():
	$action_bg.visible = true
	$Betting.visible = false
	$Betting/settings.visible = false 
	chip_betting = false

func betting(bet):
	var bet_total = sum(player_bet)
	if (bet_total + bet) <= balance:
		player_bet.append(bet)

func five_hundred_on__pressed() -> void:
	betting(500)

func hundred_on__pressed() -> void:
	betting(100)

func fifty_on__pressed() -> void:
	betting(50)

func twenty_on__pressed() -> void:
	betting(20)

func ten_on__pressed() -> void:
	betting(10)

func _on_undo_pressed() -> void:
	player_bet.pop_back()

func _on_done_pressed() -> void:
	var current_stage = "preflop"
	for stage in ["preflop", "flop", "turn", "river"]:
		if round_of_betting[stage]:
			current_stage = stage
			break

	$Betting.visible = false
	$action_bg.visible = false
	chip_betting = false

	var bet_total = sum(player_bet)
	finalised_bet[current_stage].append(bet_total)
	all_bets[current_stage].append(bet_total)
	player_bet.clear()
	balance -= bet_total

	bot_play(3)
	bot_play(4)

	$Betting.visible = true
	$action_bg.visible = true

	if all_bets[current_stage].size() >= 5 and sum(all_bets[current_stage]) / len(all_bets[current_stage]) == all_bets[current_stage].max():
		pot += sum(all_bets[current_stage])
		round_of_betting[current_stage] = false
		awaited = false

		match current_stage:
			"preflop":
				round_of_betting["flop"] = true
				$Flop.visible = true
				$Flop/Flopping.play("Flop")
				await $Flop/Flopping.animation_finished
				show_com_cards["flop"] = true
			"flop":
				round_of_betting["turn"] = true
				$Turn.visible = true
				$Turn/Turning.play("Turn")
				await $Turn/Turning.animation_finished
				show_com_cards["turn"] = true
			"turn":
				round_of_betting["river"] = true
				$River.visible = true
				$River/Rivering.play("River")
				await $River/Rivering.animation_finished
				show_com_cards["river"] = true
				determine_winner()
			"river":
				show_winner = true
				update_balance_after_winner()
	awaited = true
	bot_play(1)
	bot_play(2)

func update_balance_after_winner():
	if winner == "Player":
		balance += pot
	pot = 0
	$Table2/balance_bg/balance.text = "Balance: %s" % balance
	$Table2/pot/pot.text = "Pot: %s" % pot

func _on_h_slider_value_changed(value: float) -> void:
	slider_value = $Betting_slider/HSlider.value
	slider_used = true
	chip_betting = false

func _on_back_slider_pressed() -> void:
	$Betting_slider.visible = false
	$Betting.visible = true
	chip_betting = true
	slider_used = false

func _on_undo_slider_pressed() -> void:
	slider_value = 0
	$Betting_slider/HSlider.value = 0

func _on_check_pressed():
	if not awaited:
		return

	var current_stage = get_current_stage()

	if all_bets[current_stage].size() != 0 and all_bets[current_stage].max() > 0:
		$action_bg/buttons/Check.disabled = true
		return

	all_bets[current_stage].append(0)
	finalised_bet[current_stage].append(0)
	
	awaited = false
	$action_bg.visible = false

	await get_tree().create_timer(1.0).timeout
	continue_betting(current_stage)


func show_flop():
	round_of_betting["flop"] = true
	$Flop.visible = true
	$Flop/Flopping.play("Flop")
	await $Flop/Flopping.animation_finished
	show_com_cards["flop"] = true
	start_betting_round("flop")

func show_turn():
	round_of_betting["turn"] = true
	$Turn.visible = true
	$Turn/Turning.play("Turn")
	await $Turn/Turning.animation_finished
	show_com_cards["turn"] = true
	start_betting_round("turn")

func show_river():
	round_of_betting["river"] = true
	$River.visible = true
	$River/Rivering.play("River")
	await $River/Rivering.animation_finished
	show_com_cards["river"] = true
	start_betting_round("river")

func determine_winner():
	var all_hands = {}
	for i in range(1, 5):
		if bot_hands[i] != ["", ""]:
			all_hands[i] = rating_hand(bot_hands[i], community_cards)
	all_hands["player"] = rating_hand(player_hand, community_cards)

	var max_rating = 0
	var winners = []
	for key in all_hands:
		if all_hands[key]["value"] > max_rating:
			max_rating = all_hands[key]["value"]
			winners = [key]
		elif all_hands[key]["value"] == max_rating:
			winners.append(key)

	if winners.size() > 1:
		winners = resolve_tie(winners, all_hands)

	update_balance_after_win(winners)
	display_winner(winners)


func resolve_tie(winners, all_hands):
	var highest_card = -1
	var final_winners = []

	for winner in winners:
		if all_hands[winner]["high_card"] > highest_card:
			highest_card = all_hands[winner]["high_card"]
			final_winners = [winner]
		elif all_hands[winner]["high_card"] == highest_card:
			final_winners.append(winner)

	return final_winners

func update_balance_after_win(winners):
	var win_amount = pot / winners.size()
	for winner in winners:
		if winner == "player":
			balance += win_amount
		else:
			# Update bot balance if needed
			pass

	pot = 0
	$Table2/balance_bg/balance.text = "Balance: %s" % balance
	$Table2/pot/pot.text = "Pot: 0"

func display_winner(winners):
	var winner_text = "Winner(s): "
	for winner in winners:
		winner_text += "Player" if winner == "player" else "Bot %s" % winner
		winner_text += ", "
	winner_text = winner_text.trim_suffix(", ")

	var winner_label = Label.new()
	winner_label.text = winner_text
	winner_label.add_theme_font_size_override("font_size", 24)
	winner_label.position = Vector2(400, 300)
	add_child(winner_label)

	await get_tree().create_timer(3.0).timeout
	winner_label.queue_free()
	reset_game()
