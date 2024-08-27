extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready():
	$Label.text = "Hello World"
	$Label.modulate = Color.GREEN
	
	
func _input(event):
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
