extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


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
		var hand3 = Label.new()
		hand3.set_name("Hand3")
		hand3.text = "This specific hand can be matched with the 5 community
			cards "

		# positioning of label
		var window_x = get_viewport().size[0]
		var window_y = get_viewport().size[1]
		var hand3_length = hand3.get_rect().size
		print(hand3_length)
		hand3.position = Vector2((window_x/2),(window_y/2+100))
		$".".add_child(hand3)
		
		# Makes so that only first button press does anything
		button_presses += 1
	
	
