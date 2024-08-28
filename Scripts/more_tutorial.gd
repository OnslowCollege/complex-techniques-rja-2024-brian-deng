extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# prevent errors for more button presses
var button_presses = 1
# label defined here so can be altered properly
var handtext: Label = null

func _on_next_pressed():
	if button_presses == 1:
		# removes previous labels
		$Community.queue_free()
		$Hand2.queue_free()
		
		# creates new label on first button press
		handtext = Label.new()
		handtext.set_name("Hand3")
		handtext.text = "This specific hand can be matched with the 5 community
			cards. In particular this hand gives 9 pair and 10 high.
			This is done by swapping the 9 in your hand for the lowest
			card in the community cards which is the 3. Then seeing if
			your 10 can be swapped which it can with the 8."
		handtext.add_theme_font_size_override("font_size",20)
		
		# Changing opacity of cards
		$"river/4_spades".modulate.a = 0.5
		$"river/8_spades".modulate.a = 0.5
		
		# positioning of label
		$".".add_child(handtext)
		var window_x = get_viewport().size[0]
		var window_y = get_viewport().size[1]
		var handtext_length = handtext.get_rect().size[0]
		handtext.position = Vector2((window_x/2-handtext_length/2+50),(window_y/2+120))
			# Makes so that only first button press does the label
		button_presses += 1
		
	elif button_presses == 2:
		# Removes the label on the second button press
		if handtext != null:
			handtext.queue_free()
			handtext = null
		button_presses += 1
		get_tree().change_scene_to_file("res://Scenes/Info/action_tutorial.tscn")

