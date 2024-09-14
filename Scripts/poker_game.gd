extends Node2D

var files: Array = []
var cards: Dictionary = {}
var sorted_files = Array()
var suited: Array = []
var suits: Array = ["clubs", "spades", "hearts", "diamonds"] 
var counter: int = 1
const card_path: String = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"
var fold_pressed: bool = false
var started: bool = false
var show_hand: bool = false
var player_hand: Array = []
var sprites: Array = []
var awaited: bool = false
var player_bet: Array = []
var balance: int = 1000
var slider_value: int = 0
var slider_used: bool = false
var chip_betting: bool = false
var community_cards: Array = []

# putting the hands into an array for easy access
var hands = ["Royal Flush", "Straight Flush", "Four of a Kind", "Full House", 
	"Flush", "Straight", "Three of a Kind", "Two Pair", "Pair", "High Card"]

func separate_int(list_of_strings) -> Array:
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
	print(card_nums)
	return card_nums


func if_straight(list1: Array, list2: Array) -> bool:
	# Combine both lists, treat `1` as both `1` and `14`
	var combined = (list1 + list2)
	var unique_combined = []
	for item in combined:
		if item not in unique_combined: 
			unique_combined.append(item)
	# If `1` exists, treat it as both `1` and `14`
	if 1 in unique_combined:
		unique_combined.append(14)
	# Sort the combined list
	unique_combined.sort()
	var count = 0
	for i in range(len(unique_combined)): pass
	for i in range(unique_combined.size()):
		# Skip if the current number is outside the valid range
		if unique_combined[i] < 1 or unique_combined[i] > 14: continue
		# Check for consecutive numbers
		if i > 0:
			# If the current number is `14`, ensure it doesn't connect with `1`
			if unique_combined[i] == 14 and unique_combined[i - 1] == 1: continue
			# Check for standard consecutive numbers
			if unique_combined[i] == unique_combined[i - 1] + 1:
				count += 1
				# If we have counted 5 consecutive numbers, return true
				if count == 4:  return true # 4 gaps = 5 consecutive numbers
			# Reset count if the sequence is broken
			else: count = 0
		# Start counting from the first element
		else: count = 1  
	print(unique_combined)
	return false


func rating_hand(p_hand):
	var connected  = false
	var suited = false
	# For the community cards and converting to suits and number
	var card_id = {}
	var suit = ""
	for card in community_cards:
		if card <= 13:
			suit = "clubs"
			card_id[card] = ("%s %d" % [suit, card])
			print(card_id[card])
		elif 13 < card and card <= 26:
			suit = "diamonds"
			card_id[card] = ("%s %d" % [suit, card-13])
			print(card_id[card])
		elif 26 < card and card <= 39:
			suit = "hearts"
			card_id[card] = ("%s %d" % [suit, card-26])
			print(card_id[card])
		elif 39 < card and card <= 52:
			suit = "spades"
			card_id[card] = ("%s %d" % [suit, card-39])
			print(card_id[card])

	var player_int_list = separate_int(p_hand).map(func(s): return int(s))
	var com_int_list = separate_int(card_id.values()).map(func(s): return int(s))
	print(len(files))
	
	if if_straight(player_int_list,com_int_list):
		print("hey")

	#var max = 0
	#if (com_int_list.max()) > (player_int_list.max()):
		#max = (com_int_list.max())
	#else: 
		#max = (player_int_list.max())
#
	#var min = 0
	#if (com_int_list.min()) > (player_int_list.min()):
		#min = (com_int_list.min())
	#else: 
		#min = (player_int_list.min())
	#print(max, min)
	

func card_img(card, pos, replace):
	var sprite = Sprite2D.new()
	var texture = load(card_path + str(card))
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = Vector2(0.85, 0.85)
	sprites.append(sprite)
	$".".add_child(sprite)

# reads cards from assets file and puts in array
func list_files_in_directory(path):
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
	# Turning nodes not used yet invisible 
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
	if started:
		if fold_pressed:
			$Dealing.visible = false
			$action_bg.visible = false
			started = false
			fold_pressed = false
			show_hand = false
			player_hand.clear()
			for sprite in sprites:
				if is_instance_valid(sprite):
					sprite.queue_free()
					
					
			$Button.visible = true
	if show_hand:
		card_img(player_hand[0], 
			$Dealing/player_left.position, $Dealing/player_left)
		card_img(player_hand[1], 
			$Dealing/player_right.position, $Dealing/player_right)

	# Chip betting code for the betting text and balance
	if chip_betting:
		var bet_total = 0
		for num in player_bet:
			bet_total += num
		$Table2/bg/your_bet.text = ("Bet: %s" % [bet_total])
		$Table2/balance_bg/balance.text = ("Balance: %s" % [balance])

	# Slider code
	if slider_used:
		$Betting_slider/HSlider.max_value = balance
		$Table2/bg/your_bet.text = ("Bet: %s" % [slider_value])

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func _on_fold_pressed():
	if awaited:
		fold_pressed = true
		awaited = false

func _on_button_pressed():
	for i in range(0, 5):
		community_cards.append(randi_range(1, len(files)))
		print(community_cards[i])
		files.erase(files[i])
	started = true
	$Button.visible = false
	$action_bg.visible = true
	var rand_num = randi_range(1, 52)

	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")
	player_hand.append(files[randi_range(0, len(files))])
	player_hand.append(files[randi_range(0, len(files))])
	files.erase(player_hand[0])
	files.erase(player_hand[1])
	print(player_hand[0])
	print(player_hand[1])

	rating_hand(player_hand)

	await $Dealing/Dealing2.animation_finished
	$Table2/bg.visible = true
	show_hand = true
	awaited = true

func _on_bet_pressed():
	if awaited:
		$action_bg.visible = false
		$Betting.visible = true
		$Betting/settings.visible = true 
		chip_betting = true

func _on_settings_pressed():
	$Betting_slider.visible = true
	$Betting.visible = false

func _on_back_pressed():
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
	$action_bg.visible = true
	chip_betting = false


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
