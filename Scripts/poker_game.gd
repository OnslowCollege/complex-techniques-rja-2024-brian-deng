extends Node2D

func dealing():
	$Dealing/Dealing
	$Dealing/Dealing2

# Called when the node enters the scene tree for the first time.
func _ready():
	$Dealing/Dealing2.play("Dealing")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass


func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")
