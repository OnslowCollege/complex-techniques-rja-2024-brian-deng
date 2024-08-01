extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	$VBoxContainer/StartButton.grab_focus()
	var title = Label.new()
	title.text = "Poker Game"
	title.modulate = Color.GHOST_WHITE
	title.horizontal_alignment = 1
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	add_child(title)
	$title.text = "Poker Game"
	$title.size.x = 100
	$title.add_theme_font_size_override("Poker Game", 1000)
	# Assuming you have a label node called "my_label"
	var label = $title

	# Create a new DynamicFont
	var new_font = FontFile.new()

	# Load a font file (.ttf, .otf, etc.)
	var font_file = load("res://Assets/vcr_osd_mono/VCR_OSD_MONO_1.001.ttf") as FontFile
	
	new_font.font_data = font_file

	# Set the desired font size
	new_font.size = 24

	# Assign the new font to the label
	label.add_theme_font("font", new_font)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_start_button_pressed():
	get_tree().change_scene("res://Scenes/poker_game.tscn")


func _on_option_button_pressed():
	get_tree().change_scene("res://Scenes/options.tscn")


func _on_tutorial_button_pressed():
	get_tree().change_scene("res://Scenes/tutorial.tscn")


func _on_quit_button_pressed():
	get_tree().quit()
