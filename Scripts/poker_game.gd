extends Node2D

var files = []
var cards = {}
var sorted_files = Array()
var suited = []
var suits = ["clubs", "spades", "hearts", "diamonds"] 
var counter = 1
const card_path = "res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"
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
	$Dealing.visible = false
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	$Button_bg.visible = false
	(list_files_in_directory(card_path))
	for i in range(len(files)-1, -1, -1):
		var file = files[i]
		if ("clubs" in file or "hearts" in file or 
			"spades" in file or "diamonds" in file):
			continue
		else:
			files.remove_at(i) 
	for file in files:
		for x in range(1, 14):
			if ("-" + str(x) + ".png") in file:
				sorted_files.append(file)
			if x != counter: continue
			if counter > 14: counter += 1
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
	pass

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

func card_img(card, pos, replace):
	var sprite = Sprite2D.new()
	var texture = load(card_path + str(card))
	sprite.texture = texture
	sprite.position = pos
	sprite.scale = Vector2(0.85, 0.85)
	$".".add_child(sprite)

func _on_button_pressed():
	$Button_bg.visible = true
	var rand_num = randi_range(1, 52)
	while true:
		$Dealing.visible = true
		$Dealing/Dealing2.play("Dealing")
		var player_card_left = files[randi_range(0, 51)]
		var player_card_right = files[randi_range(0, 51)]
		print(player_card_left)
		print(player_card_right)
		await $Dealing/Dealing2.animation_finished
		card_img(player_card_left, 
			$Dealing/player_left.position, $Dealing/player_left)
		card_img(player_card_right, 
			$Dealing/player_right.position, $Dealing/player_right)
		if $Button_bg/buttons/Fold.pressed:
			print("okk")
			
			$Dealing.visible = false
			break
		break
	print("ok")

func _on_dealing_2_animation_finished(anim_name):
	pass
