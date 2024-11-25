extends Node2D
## This node is the main functionality of the game
##
## This script can play the game including, animation, actions, cards, checking 
## the cards value and winning

var files: Array = []
var cards_per_game = files
var player_hand: Array = []
var bot_hands: Dictionary = {}
var bot_hand_ratings: Dictionary = {}
var community_cards: Dictionary = {}
var com_cards = []


## This constant is for the path to the cards
const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"

var winner: String = ""

var show_hand: bool = false
var show_com_cards: Dictionary = {"flop": false, "turn": false, "river": false}
var round_of_betting = {"flop": false, "turn": false, "river": false, "preflop": false}
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

# putting the hands into an array for easy access
var hands = {"Royal Flush": 10, "Straight Flush": 9, "Four of a Kind": 8, 
	"Full House": 7, "Flush": 6, "Straight": 5, "Three of a Kind": 4, 
	"Two Pair": 3, "Pair": 2, "High Card": 1}

func separate_int(list_of_strings: Array) -> Array:
	var card_nums = []
	if list_of_strings == ["", ""]:
		return []
	for item in list_of_strings:
		var num_list = []
		var double_digit = []
		# Finds the numbers in the hand dealt
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
	# Combine both lists
	var combined = (list1 + list2)
	var unique_combined = []
	for item in combined:
		if item not in unique_combined: 
			unique_combined.append(item)
	# If `1` exists, treat it as both `1` and `14`
	if 1 in unique_combined: unique_combined.append(14)
	# Sort the combined list
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
			count = 0  # Reset the count if they are not equal
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
	#print(p_hand)
	#print(player_suits)
	#print(community_cards)
	#print(community_suits)
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
	
	# Loops and checks for duplicates of the cards
	for num in range(0, 15):
		var dup_count = total_list.count(num)
		if dup_count >= 2:
			num_duplicates.append(dup_count)
	# Sorts in ascending order and removes the lowest/first
	if len(num_duplicates) >= 3:
		num_duplicates.sort()
		num_duplicates.pop_front()
	# Check for Four of a Kind
	if 4 in num_duplicates:
		return "Four of a Kind"
	# Check for Full House or Three of a Kind
	elif num_duplicates.count(3) >= 1:
		if num_duplicates.count(3) >= 2:
			return "Full House"
		elif num_duplicates.count(3) == 1 and num_duplicates.count(2) >= 1 :
			return "Full House"
		elif num_duplicates.count(3) == 1:
			return "Three of a Kind"
	# Check for Two Pair (exactly two pairs)
	elif num_duplicates.count(2) == 2:
		return "Two Pair"
	# Check for One Pair
	elif num_duplicates.count(2) == 1:
		return "Pair"
	else:
		return "High Card"
	return ("")


func rating_hand(p_hand: Array, round: Dictionary) -> int:
	# For the community cards and converting to suits and number
	var card_id = {}
	var suit = ""
	#var round_int = separate_int(round)  # Assuming this returns an array of card numbers
	for card in round.values():
		var card_squared = []
		card_squared.append(card)
		var card_int = separate_int(card_squared)
		var split = card.split("-")
		var key = int(card_int[0])
		suit = split[1]

		var card_number = int(card)  # Convert card to integer once for efficiency
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
	print(str(len(cards_per_game))+ "len")

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
	var high_card = 0
	# print(hands)
	if straight and flush and (straight_nums.max() == 14):
		hand_value = hands["Royal Flush"]
	elif straight and flush and (straight_nums.max() != 14):
		hand_value = hands["Straight Flush"]
	elif flush:
		hand_value = hands["Flush"]
	elif straight:
		hand_value = hands["Straight"]
	elif true:
		if of_a_kind(player_int_list, com_int_list) != "":
			hand_value = hands[of_a_kind(player_int_list, com_int_list)]
	else:
		var total_list = player_int_list + com_int_list
		high_card = total_list.max()
		hand_value = hands["High Card"]
	print(str(hand_value) + "value")
	return hand_value


func preflop_action(action_on) -> Variant:
	var action_to_take = ""
	var action_value = 0
	var final_value = []
	var bot_action = [1,2,3,4]
	var pocket_pair = false
	# If action on player then returns nothing
	if action_on not in bot_action:
		return null
	# Checking if the action is on a bot
	if action_on in bot_action:
		var hand = bot_hands[action_on]
		var action_int = separate_int(hand)
		# If ace in cards then adds 13 to become 14 above King's 13.
		action_int.sort()
		if 1 in action_int:
			action_int[0] = int(action_int[0]) + 13
		# Ensuring the list is int
		var action_int_numeric = []
		for action in action_int:
			action_int_numeric.append(int(action))
		# For pocket pairs
		if action_int_numeric.size() == 0:
			return "fold"
		elif action_int_numeric[0] == action_int_numeric[1]:
			pocket_pair = true
			if action_int_numeric[0] >= 12: ## Invalid operands 'String' and 'int' in operator '>='.
				action_value = 10
			elif action_int_numeric[0] == 11:
				action_value = 9
			elif action_int_numeric[0] <= 10 and action_int_numeric[0] >= 7:
				action_value = 7
			elif action_int_numeric[0] <= 6 and action_int_numeric[0] >= 4:
				action_value = 6
			elif action_int_numeric[0] <= 3:
				action_value = 4
			# Adds final action value to see later
			final_value.append(action_value)
		# for the non-pocket pairs
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
		# Adds final action value to see later
		final_value.append(action_value)
	# sees biggest final value and uses that to make actions
	final_value = final_value.max()
	if final_value <= 4:
		action_to_take = "fold"
	elif final_value >= 5 and final_value <=7:
		action_to_take = "call"
	elif final_value >= 8:
		action_to_take = "raise"
	return action_to_take


var raise_count_bot = {1: 0, 2: 0, 3: 0, 4: 0}
var bot_betting_per = {1: [], 2: [], 3: [], 4: []}

func bot_play(action_on):
	var text_node = get_node_or_null("Bot%s/action" % [action_on])
	if text_node == null:
		print("Error: Bot%s/action node not found" % [action_on])
		return

	var max_bot_bet = balance / 2
	var raise_count = raise_count_bot[action_on]

	if round_of_betting["preflop"]:
		handle_preflop_betting(action_on, text_node, raise_count)
		for i in (finalised_bet["preflop"]):
			all_bets["preflop"].append(i)
	else:
		handle_postflop_betting(action_on, text_node)

	update_betting_totals(action_on)
	update_ui(action_on, text_node)

func handle_preflop_betting(action_on, text_node, raise_count):
	if bot_hands[action_on] == ["", ""]:
		return

	var action = preflop_action(action_on)
	match action:
		"call":
			handle_call(action_on, text_node)
		"raise":
			handle_raise(action_on, text_node, raise_count)
		"fold":
			handle_fold(action_on, text_node)

func handle_call(action_on, text_node):
	var bet_amount = 20 if all_bets["preflop"].is_empty() else all_bets["preflop"].max()
	all_bets["preflop"].append(bet_amount)
	bot_betting_per[action_on].append(bet_amount)
	text_node.text = "Bot%s: %s %s" % [action_on, "bet" if bet_amount == 20 else "call", bet_amount]

func handle_raise(action_on, text_node, raise_count):
	if raise_count == 0:
		var raise_amount = calculate_raise_amount(action_on)
		all_bets["preflop"].append(raise_amount)
		bot_betting_per[action_on].append(raise_amount)
		text_node.text = "Bot%s: raise to %s" % [action_on, raise_amount]
	elif raise_count == 1:
		handle_call(action_on, text_node)
	raise_count_bot[action_on] += 1

func calculate_raise_amount(action_on):
	var current_bet = all_bets["preflop"].max() if not all_bets["preflop"].is_empty() else 0
	var raise_factor = randi() % 6 + 1
	var raise_amount = current_bet * raise_factor
	raise_amount = min(raise_amount, balance)
	return max(raise_amount, 20)  # Ensure minimum bet of 20

func handle_fold(action_on, text_node):
	bot_hands[action_on] = ["", ""]
	text_node.text = "Bot%s: fold" % [action_on]

func handle_postflop_betting(action_on, text_node):
	var stage = "flop" if show_com_cards["flop"] else "turn" if show_com_cards["turn"] else "river"
	var community_cards_count = 3 if stage == "flop" else 4 if stage == "turn" else 5
	var current_community_cards = {}
	for i in range(community_cards_count):
		current_community_cards[i] = (community_cards.values()[i])
	
	var hand_rating = rating_hand(bot_hands[action_on], current_community_cards)
	# Implement postflop betting logic based on hand_rating

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

# reads cards from assets file and puts in array
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


# Called when the node enters the scene tree for the first time.
func _ready():
	# Turning nodes not used yet to invisible 
	$Betting.visible = false
	$Betting/settings.visible = false
	$Dealing.visible = false
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$action_bg.visible = false
	$Table2/bg.visible = false
	
	# filters the cards read from file and removes non card strings
	(list_files_in_directory(card_path))
	for i in range(len(files)-1, -1, -1):
		var file = files[i]
		if ("clubs" in file or "hearts" in file or 
			"spades" in file or "diamonds" in file):
			continue
		else:
			files.remove_at(i)

	# sets the starting balance
	$Table2/balance_bg/balance.text = ("Balance: %s" % [balance])
	
	#var sorted_cards = sort_cards(files)
	#print(sorted_cards)

	#print(of_a_kind([10, 10], [10, 1, 1,6,7])) 
	#print(of_a_kind([2, 2], [3, 5, 5,8,8])) 
	#print(of_a_kind([1, 1], [1, 2, 3,7,8]))  
	#print(of_a_kind([3, 3], [3, 2, 2,2,6])) 
	#print(of_a_kind([1, 1], [3, 4, 5,6,7])) 
	#print(of_a_kind([1, 1], [1, 1, 3,3,3]))  


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# For the fold button and resets the game incl the bools and visibility
	if started:
		if fold_pressed:
			$Dealing.visible = false
			$action_bg.visible = false
			started = false
			fold_pressed = false
			show_hand = false
			player_hand.clear()
			# removes the images of the player cards
			for sprite in sprites:
				if is_instance_valid(sprite):
					sprite.queue_free()
			$Button.visible = true
	# for when to show the hands
	if show_hand:
		card_img(player_hand[0], $Dealing/player_left.position)
		card_img(player_hand[1], $Dealing/player_right.position)
	com_cards = []
	for i in community_cards.values():
		com_cards.append(i)
	if show_com_cards["flop"]:
		card_img(com_cards[0], $Flop/card.position)
		card_img(com_cards[1], $Flop/card2.position)
		card_img(com_cards[2], $Flop/card3.position)
	if show_com_cards["turn"]:
		card_img(com_cards[3], $Turn/card.position)
	if show_com_cards["river"]:
		card_img(com_cards[4], $River/card.position)

	# Chip betting code for the betting text and balance
	if chip_betting:
		var bet_total = sum(player_bet)
		$Table2/bg/your_bet.text = ("Bet: %s" % [bet_total])

	# Slider code and updates the ui with the correct values and sets max
	if slider_used:
		$Betting_slider/HSlider.max_value = balance
		$Table2/bg/your_bet.text = ("Bet: %s" % [slider_value])
	
	$Table2/balance_bg/balance.text = ("Bet: %s" % [balance])
	var total = 0
	for i in finalised_bet.values():
		total += sum(i)
	if balance == total:
		all_in = true
		
	$Table2/pot/pot.text = ("Pot: %s" % [pot])

## For when menu button pressed and returns to menu
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

## Start button and starts the game and everything involved
func _on_button_pressed():
	# Clears the list for the next round
	player_hand = []
	bot_hands = {}
	bot_hand_ratings = {}
	community_cards = {}
	cards_per_game = files.duplicate()
	winner = ""

	# Updating booleans, visiblity, and starting dealing animation
	started = true
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")

	# Deals the community cards and removes them from list so no repeats
	for i in range(0, 5):
		var rand_card = (randi_range(0, len(cards_per_game) - 1))
		community_cards[rand_card] = (cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])
		print(community_cards[rand_card])

	# Deals the player cards and removes them from list so no repeats
	for i in range(0, 2):
		var rand_card = randi_range(0, len(cards_per_game)-1)
		player_hand.append(cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])

	# Deals the bot cards and removes them from list so no repeats
	for num in range(0, 4):
		var bot_list = []
		# for the individual bot deals 2 cards
		for i in range(0, 2):
			var rand_card = randi_range(0, len(cards_per_game)-1)
			bot_list.append(cards_per_game[rand_card])
			cards_per_game.erase(cards_per_game[rand_card])
		# adds the list of the cards to corresponding bot
		bot_hands[num + 1] = bot_list
	print(bot_hands)
	print(community_cards)
	print(player_hand)
	
	# Waits for the animation to finish before revealing cards
	await $Dealing/Dealing2.animation_finished
	round_of_betting["preflop"] = true
	$Table2/bg.visible = true
	$Table2/pot.visible = true
	show_hand = true
	awaited = true
	bot_play(1)
	bot_play(2)

func _on_bet_pressed():
	# For when the bet button pressed and only when the animation is finished
	if awaited:
		# changes the visibility to show the betting bar
		$action_bg.visible = false
		$Betting.visible = true
		$Betting/settings.visible = true 
		chip_betting = true
		player_bet = []

func _on_settings_pressed():
	# Changes visibility and shows the slider betting bar
	$Betting_slider.visible = true
	$Betting.visible = false

func _on_back_pressed():
	# changes visibility and goes back to the chip betting from slider
	$action_bg.visible = true
	$Betting.visible = false
	$Betting/settings.visible = false 
	chip_betting = false

func betting(bet):
	var bet_total = sum(player_bet)
	if (bet_total + bet) > balance:
		pass
	else:
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

var count = 0
func _on_done_pressed() -> void:
	if round_of_betting["preflop"]:
		$Betting.visible = false
		$action_bg.visible = false
		chip_betting = false
		var bet_total = sum(player_bet)
		finalised_bet["preflop"].append(bet_total)
		player_bet.clear()
		balance -= bet_total
		bot_play(3)
		bot_play(4)
		bot_play(1)
		bot_play(2)
		$Betting.visible = true
		$action_bg.visible = true
		if sum(all_bets["preflop"])/len(all_bets["preflop"]) == all_bets["preflop"].max():
			pot = sum(all_bets["preflop"])
			print(all_bets["preflop"])
			round_of_betting["preflop"] = false
			round_of_betting["flop"] = true
			$Betting.visible = false
			$action_bg.visible = false
			awaited = false
			count += 1
	if round_of_betting["flop"] and count == 1:
		count = 2
		$Flop.visible = true
		$Flop/Flopping.play("Flop")
		await $Flop/Flopping.animation_finished
		bot_play(1)
		bot_play(2)
		awaited = true
		show_com_cards["flop"] = true
		$Betting.visible = true
		$action_bg.visible = true
		if all_bets["flop"].size() != 0:
			if sum(all_bets["flop"])/len(all_bets["flop"]) == all_bets["flop"].max():
				pot += sum(all_bets["flop"])
				round_of_betting["flop"] = false
				round_of_betting["turn"] = true
				$Betting.visible = false
				$action_bg.visible = false
				awaited = false
				count += 1
	if round_of_betting["turn"] and count == 3:
		count = 4
		$Turn.visible = true
		$Turn/Turning.play("Turn")
		await $Turn/Turning.animation_finished
		awaited = true
		show_com_cards["turn"] = true
		$Betting.visible = true
		$action_bg.visible = true
		if sum(all_bets["turn"])/len(all_bets["turn"]) == all_bets["turn"].max():
			pot += sum(all_bets["turn"])
			round_of_betting["turn"] = false
			round_of_betting["river"] = true
			$Betting.visible = false
			$action_bg.visible = false
			awaited = false
			count += 1
	if round_of_betting["river"] and count == 5:
		# Adds to hand rating dict the ratings of hands corresponding to the bot
		for i in len(bot_hands.keys()):
			bot_hand_ratings[i + 1] = rating_hand(bot_hands[i + 1], community_cards)
		# Player hand rating in separate var
		var p_hand_rating: int = rating_hand(player_hand, community_cards)
		print(bot_hand_ratings)
		print(p_hand_rating)
		
		# for winner overall
		if bot_hand_ratings.values().max() <= p_hand_rating:
			winner = "Player"
		elif bot_hand_ratings.values().max() == p_hand_rating:
			winner = "High Card"
		else:
			winner = "Bot"
		show_winner = true


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


func _on_check_pressed() -> void:
	var key_needed = 0
	for key in round_of_betting.keys():
		if round_of_betting[key]:
			key_needed = key
	if all_bets[key_needed].size() != 0:
		$action_bg/buttons/Check.disabled = true


func _on_call_pressed() -> void:
	pass # Replace with function body.
	








































extends Node2D
## This node is the main functionality of the game
##
## This script can play the game including, animation, actions, cards, checking 
## the cards value and winning

var files: Array = []
var cards_per_game = files
var player_hand: Array = []
var bot_hands: Dictionary = {}
var bot_hand_ratings: Dictionary = {}
var community_cards: Dictionary = {}
var com_cards = []


## This constant is for the path to the cards
const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"

var winner: String = ""

var show_hand: bool = false
var show_com_cards: Dictionary = {"flop": false, "turn": false, "river": false}
var round_of_betting = {"flop": false, "turn": false, "river": false, "preflop": false}
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

# putting the hands into an array for easy access
var hands = {"Royal Flush": 10, "Straight Flush": 9, "Four of a Kind": 8, 
	"Full House": 7, "Flush": 6, "Straight": 5, "Three of a Kind": 4, 
	"Two Pair": 3, "Pair": 2, "High Card": 1}

func separate_int(list_of_strings: Array) -> Array:
	var card_nums = []
	if list_of_strings == ["", ""]:
		return []
	for item in list_of_strings:
		var num_list = []
		var double_digit = []
		# Finds the numbers in the hand dealt
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
	# Combine both lists
	var combined = (list1 + list2)
	var unique_combined = []
	for item in combined:
		if item not in unique_combined: 
			unique_combined.append(item)
	# If `1` exists, treat it as both `1` and `14`
	if 1 in unique_combined: unique_combined.append(14)
	# Sort the combined list
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
			count = 0  # Reset the count if they are not equal
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
	#print(p_hand)
	#print(player_suits)
	#print(community_cards)
	#print(community_suits)
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
	
	# Loops and checks for duplicates of the cards
	for num in range(0, 15):
		var dup_count = total_list.count(num)
		if dup_count >= 2:
			num_duplicates.append(dup_count)
	# Sorts in ascending order and removes the lowest/first
	if len(num_duplicates) >= 3:
		num_duplicates.sort()
		num_duplicates.pop_front()
	# Check for Four of a Kind
	if 4 in num_duplicates:
		return "Four of a Kind"
	# Check for Full House or Three of a Kind
	elif num_duplicates.count(3) >= 1:
		if num_duplicates.count(3) >= 2:
			return "Full House"
		elif num_duplicates.count(3) == 1 and num_duplicates.count(2) >= 1 :
			return "Full House"
		elif num_duplicates.count(3) == 1:
			return "Three of a Kind"
	# Check for Two Pair (exactly two pairs)
	elif num_duplicates.count(2) == 2:
		return "Two Pair"
	# Check for One Pair
	elif num_duplicates.count(2) == 1:
		return "Pair"
	else:
		return "High Card"
	return ("")


func rating_hand(p_hand: Array, round: Dictionary) -> int:
	# For the community cards and converting to suits and number
	var card_id = {}
	var suit = ""
	#var round_int = separate_int(round)  # Assuming this returns an array of card numbers
	for card in round.values():
		var card_squared = []
		card_squared.append(card)
		var card_int = separate_int(card_squared)
		var split = card.split("-")
		var key = int(card_int[0])
		suit = split[1]

		var card_number = int(card)  # Convert card to integer once for efficiency
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
	print(str(len(cards_per_game))+ "len")

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
	var high_card = 0
	# print(hands)
	if straight and flush and (straight_nums.max() == 14):
		hand_value = hands["Royal Flush"]
	elif straight and flush and (straight_nums.max() != 14):
		hand_value = hands["Straight Flush"]
	elif flush:
		hand_value = hands["Flush"]
	elif straight:
		hand_value = hands["Straight"]
	elif true:
		if of_a_kind(player_int_list, com_int_list) != "":
			hand_value = hands[of_a_kind(player_int_list, com_int_list)]
	else:
		var total_list = player_int_list + com_int_list
		high_card = total_list.max()
		hand_value = hands["High Card"]
	print(str(hand_value) + "value")
	return hand_value


func preflop_action(action_on) -> Variant:
	var action_to_take = ""
	var action_value = 0
	var final_value = []
	var bot_action = [1,2,3,4]
	var pocket_pair = false
	# If action on player then returns nothing
	if action_on not in bot_action:
		return null
	# Checking if the action is on a bot
	if action_on in bot_action:
		var hand = bot_hands[action_on]
		var action_int = separate_int(hand)
		# If ace in cards then adds 13 to become 14 above King's 13.
		action_int.sort()
		if 1 in action_int:
			action_int[0] = int(action_int[0]) + 13
		# Ensuring the list is int
		var action_int_numeric = []
		for action in action_int:
			action_int_numeric.append(int(action))
		# For pocket pairs
		if action_int_numeric.size() == 0:
			return "fold"
		elif action_int_numeric[0] == action_int_numeric[1]:
			pocket_pair = true
			if action_int_numeric[0] >= 12: ## Invalid operands 'String' and 'int' in operator '>='.
				action_value = 10
			elif action_int_numeric[0] == 11:
				action_value = 9
			elif action_int_numeric[0] <= 10 and action_int_numeric[0] >= 7:
				action_value = 7
			elif action_int_numeric[0] <= 6 and action_int_numeric[0] >= 4:
				action_value = 6
			elif action_int_numeric[0] <= 3:
				action_value = 4
			# Adds final action value to see later
			final_value.append(action_value)
		# for the non-pocket pairs
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
		# Adds final action value to see later
		final_value.append(action_value)
	# sees biggest final value and uses that to make actions
	final_value = final_value.max()
	if final_value <= 4:
		action_to_take = "fold"
	elif final_value >= 5 and final_value <=7:
		action_to_take = "call"
	elif final_value >= 8:
		action_to_take = "raise"
	return action_to_take


var raise_count_bot = {1: 0, 2: 0, 3: 0, 4: 0}
var bot_betting_per = {1: [], 2: [], 3: [], 4: []}

func bot_play(action_on):
	var text_node = get_node_or_null("Bot%s/action" % [action_on])
	if text_node == null:
		print("Error: Bot%s/action node not found" % [action_on])
		return

	var max_bot_bet = balance / 2
	var raise_count = raise_count_bot[action_on]

	var current_stage = "preflop"
	for stage in ["preflop", "flop", "turn", "river"]:
		if round_of_betting[stage]:
			current_stage = stage
			break

	if current_stage == "preflop":
		handle_preflop_betting(action_on, text_node, raise_count, current_stage)
	else:
		handle_postflop_betting(action_on, text_node, current_stage)

	update_betting_totals(action_on)
	update_ui(action_on, text_node)

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
	var action = decide_postflop_action(hand_rating, stage)
	
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

# reads cards from assets file and puts in array
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


# Called when the node enters the scene tree for the first time.
func _ready():
	# Turning nodes not used yet to invisible 
	$Betting.visible = false
	$Betting/settings.visible = false
	$Dealing.visible = false
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$action_bg.visible = false
	$Table2/bg.visible = false
	
	# filters the cards read from file and removes non card strings
	(list_files_in_directory(card_path))
	for i in range(len(files)-1, -1, -1):
		var file = files[i]
		if ("clubs" in file or "hearts" in file or 
			"spades" in file or "diamonds" in file):
			continue
		else:
			files.remove_at(i)

	# sets the starting balance
	$Table2/balance_bg/balance.text = ("Balance: %s" % [balance])
	
	#var sorted_cards = sort_cards(files)
	#print(sorted_cards)

	#print(of_a_kind([10, 10], [10, 1, 1,6,7])) 
	#print(of_a_kind([2, 2], [3, 5, 5,8,8])) 
	#print(of_a_kind([1, 1], [1, 2, 3,7,8]))  
	#print(of_a_kind([3, 3], [3, 2, 2,2,6])) 
	#print(of_a_kind([1, 1], [3, 4, 5,6,7])) 
	#print(of_a_kind([1, 1], [1, 1, 3,3,3]))  


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	# For the fold button and resets the game incl the bools and visibility
	if started:
		if fold_pressed:
			reset_game()

		update_card_images()
		update_betting_ui()
		update_balance_and_pot()

func update_card_images():
	# Remove all existing card sprites
	for sprite in sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	sprites.clear()

	# Show player hand
	if show_hand:
		card_img(player_hand[0], $Dealing/player_left.position)
		card_img(player_hand[1], $Dealing/player_right.position)

	# Show community cards
	if show_com_cards["flop"]:
		card_img(community_cards[0], $Flop/card.position)
		card_img(community_cards[1], $Flop/card2.position)
		card_img(community_cards[2], $Flop/card3.position)
	if show_com_cards["turn"]:
		card_img(community_cards[3], $Turn/card.position)
	if show_com_cards["river"]:
		card_img(community_cards[4], $River/card.position)

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

## For when menu button pressed and returns to menu
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

## Start button and starts the game and everything involved
func _on_button_pressed():
	# Clears the list for the next round
	player_hand = []
	bot_hands = {}
	bot_hand_ratings = {}
	community_cards = {}
	cards_per_game = files.duplicate()
	winner = ""
	# Reset all game variables
	player_hand.clear()
	bot_hands.clear()
	bot_hand_ratings.clear()
	community_cards.clear()
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
	# Reset UI elements
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$Table2/bg.visible = false
	$Table2/pot.visible = false
	# Remove all card sprites
	for sprite in sprites:
		if is_instance_valid(sprite):
			sprite.queue_free()
	sprites.clear()

	# Updating booleans, visiblity, and starting dealing animation
	started = true
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")

	# Deals the community cards and removes them from list so no repeats
	for i in range(0, 5):
		var rand_card = (randi_range(0, len(cards_per_game) - 1))
		community_cards[rand_card] = (cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])
		print(community_cards[rand_card])

	# Deals the player cards and removes them from list so no repeats
	for i in range(0, 2):
		var rand_card = randi_range(0, len(cards_per_game)-1)
		player_hand.append(cards_per_game[rand_card])
		cards_per_game.erase(cards_per_game[rand_card])

	# Deals the bot cards and removes them from list so no repeats
	for num in range(0, 4):
		var bot_list = []
		# for the individual bot deals 2 cards
		for i in range(0, 2):
			var rand_card = randi_range(0, len(cards_per_game)-1)
			bot_list.append(cards_per_game[rand_card])
			cards_per_game.erase(cards_per_game[rand_card])
		# adds the list of the cards to corresponding bot
		bot_hands[num + 1] = bot_list
	print(bot_hands)
	print(community_cards)
	print(player_hand)
	
	# Waits for the animation to finish before revealing cards
	await $Dealing/Dealing2.animation_finished
	round_of_betting["preflop"] = true
	$Table2/bg.visible = true
	$Table2/pot.visible = true
	show_hand = true
	awaited = true
	bot_play(1)
	bot_play(2)

func _on_bet_pressed():
	# For when the bet button pressed and only when the animation is finished
	if awaited:
		# changes the visibility to show the betting bar
		$action_bg.visible = false
		$Betting.visible = true
		$Betting/settings.visible = true 
		chip_betting = true
		player_bet = []

func _on_settings_pressed():
	# Changes visibility and shows the slider betting bar
	$Betting_slider.visible = true
	$Betting.visible = false

func _on_back_pressed():
	# changes visibility and goes back to the chip betting from slider
	$action_bg.visible = true
	$Betting.visible = false
	$Betting/settings.visible = false 
	chip_betting = false

func betting(bet):
	var bet_total = sum(player_bet)
	if (bet_total + bet) > balance:
		pass
	else:
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

var count = 0
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

	for bot in range(1, 5):
		bot_play(bot)

	$Betting.visible = true
	$action_bg.visible = true

	if all_bets[current_stage].size() >= 5 and sum(all_bets[current_stage]) / len(all_bets[current_stage]) == all_bets[current_stage].max():
		pot += sum(all_bets[current_stage])
		round_of_betting[current_stage] = false
		awaited = false

		match current_stage:
			"preflop":
				round_of_betting["preflop"] = true
			"flop":
				round_of_betting["flop"] = true
				round_of_betting["preflop"] = false
				$Flop.visible = true
				$Flop/Flopping.play("Flop")
				await $Flop/Flopping.animation_finished
				show_com_cards["flop"] = true
			"turn":
				round_of_betting["turn"] = true
				round_of_betting["flop"] = false
				$Turn.visible = true
				$Turn/Turning.play("Turn")
				await $Turn/Turning.animation_finished
				show_com_cards["turn"] = true
			"river":
				round_of_betting["river"] = true
				round_of_betting["turn"] = false
				$River.visible = true
				$River/Rivering.play("River")
				await $River/Rivering.animation_finished
				show_com_cards["river"] = true
				determine_winner()
	awaited = true

func determine_winner():
	for i in len(bot_hands.keys()):
		bot_hand_ratings[i + 1] = rating_hand(bot_hands[i + 1], community_cards)
	var p_hand_rating = rating_hand(player_hand, community_cards)
	
	if bot_hand_ratings.values().max() <= p_hand_rating:
		winner = "Player"
	elif bot_hand_ratings.values().max() == p_hand_rating:
		winner = "High Card"
	else:
		winner = "Bot"
	show_winner = true


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


func _on_check_pressed() -> void:
	var key_needed = 0
	for key in round_of_betting.keys():
		if round_of_betting[key]:
			key_needed = key
	if all_bets[key_needed].size() != 0:
		$action_bg/buttons/Check.disabled = true


func _on_call_pressed() -> void:
	pass # Replace with function body.



























func determine_winner():
	for i in len(bot_hands.keys()):
		var rating = rating_hand(bot_hands[i + 1], community_cards)
		bot_hand_ratings[i + 1] = rating
	var p_hand_rating = rating_hand(player_hand, community_cards)
	
	var highest_value = p_hand_rating.value
	var highest_high_card = p_hand_rating.high_card
	winner = "Player"
	
	for bot in bot_hand_ratings:
		if bot_hand_ratings[bot].value > highest_value:
			highest_value = bot_hand_ratings[bot].value
			highest_high_card = bot_hand_ratings[bot].high_card
			winner = "Bot " + str(bot)
		elif bot_hand_ratings[bot].value == highest_value:
			if bot_hand_ratings[bot].high_card > highest_high_card:
				highest_high_card = bot_hand_ratings[bot].high_card
				winner = "Bot " + str(bot)
	
	show_winner = true
