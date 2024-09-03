extends Control
var next_counter: int = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	$Flop.visible = false
	$Turn.visible = false
	$River.visible = false
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_button_2_pressed():
	if next_counter == 0:
		$Intro_text.visible = false
		$Flop_text.visible = true
		$Flop.visible = true
		next_counter += 1
	elif next_counter == 1:
		$Flop_text.visible = false
		$Flop.modulate.a = 0.5
		$Turn_text.visible = true
		$Turn.visible = true 
		next_counter += 1
	elif next_counter == 2:
		$Turn_text.visible = false
		$Turn.modulate.a = 0.5
		$River_text.visible = true
		$River.visible = true
		next_counter += 1
	elif next_counter == 3:
		get_tree().change_scene_to_file("res://Scenes/menu.tscn")
