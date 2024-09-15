extends Node2D
## This node is the main functionality of the game
##
## This script can play the game including, animation, actions, cards, checking 
## the cards value and winning

var files: Array = []
var cards_per_game = files
var player_hand: Array = []
var bot_hands: Dictionary = {}
var hand_ratings: Dictionary = {}
var community_cards: Array = []

## This constant is for the path to the cards
const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"

var winner: String = ""

var cards: Dictionary = {}
var sorted_files = Array()
var suited: Array = []
var suits: Array = ["clubs", "spades", "hearts", "diamonds"] 
var counter: int = 1
var fold_pressed: bool = false
var started: bool = false
var show_hand: bool = false
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
		var double_digit = []
		# Finds the numbers in the hand dealt
		var string_split = item.split("")
		for char in string_split:
			if char >= '0' and char <= '9':
				double_digit.append(char)
		if len(double_digit) >= 2:
			card_nums.append(("%s%s" % [double_digit[0], double_digit[1]]))
		else:
			card_nums.append(double_digit[0])
	print(str(card_nums) + "nums")
	return card_nums


func if_straight(list1: Array, list2: Array) -> Variant:
	# Combine both lists, treat `1` as both `1` and `14`
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
	for num in range(0, 13):
		var dup_count = total_list.count(num)
		if dup_count >= 2:
			num_duplicates.append(dup_count)
	# From here it labels the duplicate for the hands
	# Check for Four of a Kind
	if 4 in num_duplicates:
		return "Four of a Kind"    
	# Check for Full House: one triple and one pair
	elif (3 in num_duplicates) and (2 in num_duplicates):
		return "Full House"
	# Check for Three of a Kind (but not Full )
	elif 3 in num_duplicates:
		return "Three of a Kind"
	# Check for Two Pair (i.e., exactly two 2's in num_duplicates)
	elif num_duplicates.count(2) >= 2:
		return "Two Pair"
	# Check for One Pair
	elif 2 in num_duplicates:
		return "Pair"
	return ("")


func rating_hand(p_hand: Array) -> int:
	# For the community cards and converting to suits and number
	var card_id = {}
	var suit = ""
	for card in community_cards:
		if card <= 13:
			suit = "clubs"
			card_id[card] = ("%s %d" % [suit, card])
		elif 13 < card and card <= 26:
			suit = "diamonds"
			card_id[card] = ("%s %d" % [suit, card-13])
		elif 26 < card and card <= 39:
			suit = "hearts"
			card_id[card] = ("%s %d" % [suit, card-26])
		elif 39 < card and card <= 52:
			suit = "spades"
			card_id[card] = ("%s %d" % [suit, card-39])
	print(card_id)

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
	
	#for file in files:
		#for x in range(1, 14):
			#if ("-" + str(x) + ".png") in file:
				#sorted_files.append(file)
			#if x != counter: continue
			#if counter > 14: counter += 1
	#print(sorted_files)

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
	hand_ratings = {}
	community_cards = []
	cards_per_game = files
	winner = ""

	# Updating booleans, visiblity, and starting dealing animation
	started = true
	$Button.visible = false
	$action_bg.visible = true
	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")

	# Deals the community cards and removes them from list so no repeats
	for i in range(0, 5):
		community_cards.append(randi_range(1, len(cards_per_game)))
		print(community_cards[i])
		cards_per_game.erase(cards_per_game[i])

	# Deals the player cards and removes them from list so no repeats
	for i in range(0, 2):
		player_hand.append(cards_per_game[randi_range(0, len(cards_per_game)-1)])
		cards_per_game.erase(player_hand[i])
		print(player_hand[i])

	# Deals the bot cards and removes them from list so no repeats
	for num in range(0, 4):
		var bot_list = []
		# for the individual bot deals 2 cards
		for i in range(0, 2):
			bot_list.append(cards_per_game[randi_range(0, len(cards_per_game)-1)])
			cards_per_game.erase(bot_list[i])
		# adds the list of the cards to corresponding bot
		bot_hands[num + 1] = bot_list
	print(bot_hands)
	
	# Adds to hand rating dict the ratings of hands corresponding to the bot
	for i in len(bot_hands.keys()):
		hand_ratings[i + 1] = rating_hand(bot_hands[i + 1])
	# Player hand rating in separate var
	var p_hand_rating: int = rating_hand(player_hand)
	print(hand_ratings)
	print(p_hand_rating)
	
	if hand_ratings.values().max() <= p_hand_rating:
		winner = "Player"
	elif hand_ratings.values().max() == p_hand_rating:
		winner = "High Card"
	else:
		winner = "Bot"
	print(winner)

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
