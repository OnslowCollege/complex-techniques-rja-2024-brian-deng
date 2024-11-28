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

# load the script for checking the value of a poker hand
var hand_value = preload("res://Scripts/poker_value_card.gd")








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
