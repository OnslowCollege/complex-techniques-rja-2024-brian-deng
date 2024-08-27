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
	add_child(arrow_line)
	# Create the Polygon2D for the arrowhead
	var arrowhead = Polygon2D.new()
	# Calculate direction and base of the arrowhead
	var direction = (end_point - start_point).normalized()
	var perpendicular = Vector2(-direction.y, direction.x) * (width * 2)
	var arrowhead_base_left = end_point + perpendicular
	var arrowhead_base_right = end_point - perpendicular 
	# Define the points of the arrowhead (triangle)
	var points = PackedVector2Array()
	points.append(end_point + direction * (width * 4))          # Tip of the arrow
	points.append(arrowhead_base_left)    # Left base
	points.append(arrowhead_base_right)   # Right base
	arrowhead.polygon = points
	arrowhead.color = color  # Set arrowhead color
	# Add the Polygon2D to the scene
	add_child(arrowhead)

# Called when the node enters the scene tree for the first time.
func _ready():
	arrow($Fold_text.position + (Vector2(200, 60)), 
	$Button_bg.position + (Vector2(150, -30)), Color.WHITE, 10)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
