extends Control

func arrow(start_point: Vector2, end_point: Vector2, color: Color, width: float):
	# Create the Line2D for the arrow shaft
	var arrow_line = Line2D.new()
	arrow_line.width = width
	arrow_line.default_color = color
	
	# Points for the shaft (start and end of the arrow)
	arrow_line.add_point(start_point)
	arrow_line.add_point(end_point)
	
	# Add the Line2D to the scene
	$".".add_child(arrow_line)
	# Create the Polygon2D for the arrowhead
	var arrowhead = Polygon2D.new()
	
	# Calculate direction and base of the arrowhead
	var direction = (end_point - start_point).normalized()
	var perpendicular = Vector2(-direction.y, direction.x) * (width * 2)
	var arrowhead_base_left = end_point + perpendicular
	var arrowhead_base_right = end_point - perpendicular 
	
	# Define the points of the arrowhead (triangle)
	var points = PackedVector2Array()
	points.append(end_point + direction * (width * 4)) # Tip of the arrow
	points.append(arrowhead_base_left)    # Left base
	points.append(arrowhead_base_right)   # Right base
	arrowhead.polygon = points
	arrowhead.color = color  # Set arrowhead color
	# Add the Polygon2D to the scene
	$".".add_child(arrowhead)
var fold_arrow: Line2D = null
# prevent errors for more button presses
var button_presses = 1

# Called when the node enters the scene tree for the first time.
func _ready():
	pass
# label defined here so can be altered properly
var handtext: Label = null

func _on_next_button_pressed():
	fold_arrow = arrow($Fold_text.position + (Vector2(200, 60)), 
	$Button_bg.position + (Vector2(150, -30)), Color.WHITE, 9)
	if button_presses == 2:
		fold_arrow.queue_free()
		fold_arrow = null
	
	if button_presses == 1:
		# removes previous labels
		$Fold_text.queue_free()
		#.queue_free()
		
		# creates new label on first button press
		handtext = Label.new()
		handtext.set_name("Hand3")
		handtext.text = "This specific hand can be matched with the 5 community
			cards. In particular this hand gives 9 pair and 10 high.
			This is done by swapping the 9 in your hand for the lowest
			card in the community cards which is the 3. Then seeing if
			your 10 can be swapped which it can with the 8."
		handtext.add_theme_font_size_override("font_size",20)
		
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

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
