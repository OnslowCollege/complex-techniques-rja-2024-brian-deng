extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/StartButton.grab_focus()
	#var title = Label.new()
	#title.text = "Poker Game"
	#title.modulate = Color.GHOST_WHITE
	#title.horizontal_alignment = 1
	#title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	#add_child(title)
	
	$title.text = "Poker Game"
	$title.size.x 
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/poker_game.tscn")


func _on_option_button_pressed():
	get_tree().change_scene_to_file("res://Scenes/options.tscn")

#var simultaneous_scene = preload("res://Scenes/tutorial.tscn").instantiate()
func _on_tutorial_button_pressed():
	#get_tree().root.add_child(simultaneous_scene)
#	get_tree().change_scene("res://Scenes/tutorial.tscn")
	get_tree().change_scene_to_file("res://Scenes/tutorial.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
