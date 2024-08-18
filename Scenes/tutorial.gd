extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
#	$VBoxContainer.alignment
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_next_pressed():
	get_tree().change_scene_to_file("res://Scenes/more_tutorial.tscn")
