extends Node2D

var files = []
var cards = {}
var sorted_files = Array()
var suited = []
var suits = ["clubs", "spades", "hearts", "diamonds"] 
var counter = 1
const card_path = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"
var fold_pressed = false
var started = false
var show_hand = false
var player_hand = []
var sprites: Array = []
var awaited = false
var player_bet = []
var balance = 1000
var slider_value = 0
var slider_used = false
var chip_betting = false
## but the dir list into another list to sort with suits sorted

func list_files_in_directory(path):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
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
			print("okk")
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

func card_img(card, pos, replace):
	var sprite = Sprite2D.new()
	var texture = load(card_path + str(card))
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = Vector2(0.85, 0.85)
	sprites.append(sprite)
	$".".add_child(sprite)

func _on_button_pressed():
	started = true
	$Button.visible = false
	$action_bg.visible = true
	var rand_num = randi_range(1, 52)
	#while true:
	$Dealing.visible = true
	$Dealing/Dealing2.play("Dealing")
	player_hand.append(files[randi_range(0, 51)])
	player_hand.append(files[randi_range(0, 51)])
	print(player_hand[0])
	print(player_hand[1])
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
