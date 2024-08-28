extends Control

# Creates arrow for proper explanation of the tutorial message/ action buttons
# 
# Parameters:
#  - start (Vector2): The starting position of the arrow.
#  - end (Vector2): The ending position of the arrow, where the arrowhead will be placed.
#  - width (float): The width of the arrow's line, and the size basis for the arrowhead.
# 
func arrow_change(start: Vector2, end: Vector2, width: float):
	# Making arrow base or the line.
	$arrow/Line.clear_points()
	$arrow/Line.add_point(start)
	$arrow/Line.add_point(end)
	$arrow/Line.width = width
	
	# Setting vars for proper arrow head orientation and size
	var direction = (end - start).normalized()
	var perpendicular = Vector2(-direction.y, direction.x) * (width * 2)
	var arrowhead_base_left = end + perpendicular
	var arrowhead_base_right = end - perpendicular 
	
	# Making polygon/ arrow head
	var points = PackedVector2Array()
	points.append(end + direction * (width * 4)) # Tip of the arrow
	points.append(arrowhead_base_left) # Left base
	points.append(arrowhead_base_right)   # Right base
	
	# Setting polygon
	$arrow/head.polygon = points
	# To ensure the polygon positioned correctly
	$arrow/head.position = Vector2(0,0) 

# prevent errors for more button presses
var button_presses = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	arrow_change($Fold_text.position + (Vector2(200, 60)), 
		$Button_bg.position - Vector2(-170, 30), 10)
	
# label defined here so can be altered properly
var tutorial_text: Label = null

func _on_next_button_pressed():
	# Tutorial text for betting button
	if button_presses == 1:
		# removes previous labels
		$Fold_text.visible = false
		
		# creates new label on first button press
		tutorial_text = Label.new()
		tutorial_text.set_name("Hand3")
		tutorial_text.text = "
		Bet means to bet an amount of money into 
		the pot(money you can win). When betting 
		or raising(when someone else has bet and 
		then you bet a higher amount) the other 
		players have to call to continue playing 
		for the pot."

		# changing font size of tutorial
		tutorial_text.add_theme_font_size_override("font_size",20)
		
		# positioning of label and putting text on screen
		$".".add_child(tutorial_text)
		tutorial_text.position = Vector2(650,640)
		
		# Arrow
		arrow_change($Fold_text.position + (Vector2(200, 80)), 
			$Button_bg.position - Vector2(-390, 50), 10)
		
		# Makes so that only first button press does the label
		button_presses += 1

	# Tutorial text for the check button
	elif button_presses == 2:
		tutorial_text.text = "
		Check is when no one has bet so you also
		choose to not bet."
		tutorial_text.position = Vector2(650,715)
		
		# Arrow
		arrow_change($Fold_text.position + (Vector2(300, 80)), 
			$Button_bg.position - Vector2(-600, 50), 10)

		button_presses += 1

	# Tutorial text for the call button
	elif button_presses == 3:
		tutorial_text.text = "
		Call is when someone has bet an amount and
		you bet the same amount
		"
		tutorial_text.position = Vector2(640,715)
		
		# Arrow
		arrow_change($Fold_text.position + (Vector2(400, 80)), 
			$Button_bg.position - Vector2(-800, 50), 10)
		button_presses += 1
		
	# For final press which leads back to main screen
	elif button_presses == 4:
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
