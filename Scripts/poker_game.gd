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

## This constant is for the path to the cards
const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"

var winner: String = ""

var show_hand: bool = false
var show_com_cards: Dictionary = {"flop": false, "turn": false, "river": false}

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
var finalised_bet: Array = []
var action_on: int = 1

# putting the hands into an array for easy access
var hands = {"Royal Flush": 10, "Straight Flush": 9, "Four of a Kind": 8, 
	"Full House": 7, "Flush": 6, "Straight": 5, "Three of a Kind": 4, 
	"Two Pair": 3, "Pair": 2, "High Card": 1}

func separate_int(list_of_strings: Array) -> Array:
	var card_nums = []
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
	var bot_action = [1,2,4,5]
	var pocket_pair = false
	# If action on player then returns nothing
	if action_on not in bot_action:
		return null
	# Checking if the action is on a bot
	if action_on in bot_action:
		# if action on player 5 it shows bot 4 cause player is num 3
		if action_on == 4 or action_on == 5:
			action_on -= 1
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
		if action_int_numeric[0] == action_int_numeric[1]:
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


func bot_play():
	pass


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
	
	#var count = 1
	#for file in files:
		#var split = file.split("-")
		#var num_index = split.find(("%s.png" % [count]))
		#print(num_index)
		#if count <= 13:
			#if "clubs" in split and (("%s.png" % [count]) in split):
				#sorted_files.append(files[num_index])
				#count += 1
			#else: continue
	#print(sorted_files)
		
		#for x in range(1, 14):
			#if ("-" + str(x) + ".png") in file:
				#sorted_files.append(file)
			#if x != counter: continue
			#if counter > 14: counter += 1


	#var count: int = 1
	#var suit = ""
	#for file in files:
		#if count <= 13:
			#suit = "clubs"
			#if ((str(suit) in file) and (str(count) in file)):
				#cards["%s %d" % [suit, count]] = file
				#print("Added to dictionary: ", cards["%s %d" % [suit, count]])
		#elif 13 < count and count <= 26:
			#suit = "diamonds"
			#if ((str(suit) in file) and (str(count-13) in file)):
				#cards["%s %d" % [suit, count-13]] = file
				#print("Added to dictionary: ", cards["%s %d" % [suit, count-13]])
		#elif 26 < count and count <= 39:
			#suit = "hearts"
			#if ((str(suit) in file) and (str(count-26) in file)):
				#cards["%s %d" % [suit, count-26]] = file
				#print("Added to dictionary: ", cards["%s %d" % [suit, count-26]])
		#elif 39 < count and count <= 52:
			#suit = "spades"
			#if ((str(suit) in file) and (str(count-39) in file)):
				#cards["%s %d" % [suit, count-39]] = file
				#print("Added to dictionary: ", cards["%s %d" % [suit, count-39]])
		## Print the generated strings for debugging
		##print("Generated suit: ", suit)
		##print("Generated count string: ", "-%d.png" % [count])
		#count += 1
	#print(cards)
	#var counter: int = 1
	#var cards = {}  # Initialize the cards dictionary
	#var suits = ["clubs", "diamonds", "hearts", "spades"]  # List of suits
	#for file in files:
		#var suit_index = ((counter - 1) / 13)  # Determine the suit index based on count
		#if suit_index < suits.size():
			#var suity = suits[suit_index]
			#var rank = counter - suit_index * 13  # Determine the rank within the suit
			#if (suity in file) and (str(rank) in file):
				#cards["%s %d" % [suity, rank]] = file
				#print("Added to dictionary: ", cards["%s %d" % [suity, rank]])
	#print(cards)


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
	
	if show_com_cards["flop"]:
		card_img(community_cards[0], $Flop/card.position)
		card_img(community_cards[1], $Flop/card2.position)
		card_img(community_cards[2], $Flop/card3.position)
	if show_com_cards["turn"]:
		card_img(community_cards[3], $Turn/card.position)
	if show_com_cards["river"]:
		card_img(community_cards[4], $River/card.position)

	# Chip betting code for the betting text and balance
	if chip_betting:
		var bet_total = 0
		for num in player_bet:
			bet_total += num
		$Table2/bg/your_bet.text = ("Bet: %s" % [bet_total])
		$Table2/balance_bg/balance.text = ("Balance: %s" % [balance])

	# Slider code and updates the ui with the correct values and sets max
	if slider_used:
		$Betting_slider/HSlider.max_value = balance
		$Table2/bg/your_bet.text = ("Bet: %s" % [slider_value])

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

	print(winner)
	print(str(preflop_action(1)) + "value")
	# Waits for the animation to finish before revealing cards
	await $Dealing/Dealing2.animation_finished
	$Table2/bg.visible = true
	show_hand = true
	awaited = true

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
	var bet_total = 0
	for num in player_bet:
		bet_total += num
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


func _on_done_pressed() -> void:
	$Betting.visible = false
	$action_bg.visible = false
	chip_betting = false
	var bet_total = 0
	for num in player_bet:
		bet_total += num
	finalised_bet.append(bet_total)


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
