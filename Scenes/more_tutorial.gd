extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

# prevent errors for more button presses
var button_presses = 0
func _on_next_pressed():
	if button_presses == 0:
		# removes previous labels
		$Community.queue_free()
		$Hand2.queue_free()
		
		# creates new label on first button press
		var handtext = Label.new()
		handtext.set_name("Hand3")
		handtext.text = "This specific hand can be matched with the 5 community
			cards. In particular this hand gives 9 pair and 10 high.
			This is done by swapping the 9 in your hand for the lowest
			card in the community cards which is the 3. Then seeing if
			your 10 can be swapped which it can with the 8."
		handtext.add_theme_font_size_override("",20)

		# positioning of label
		var window_x = get_viewport().size[0]
		var window_y = get_viewport().size[1]
		var handtext_length = handtext.get_rect().size
		print(handtext_length)
		handtext.position = Vector2((window_x/2),(window_y/2+100))
		$".".add_child(handtext)
		
		# Makes so that only first button press does anything
		button_presses += 1
	
	
