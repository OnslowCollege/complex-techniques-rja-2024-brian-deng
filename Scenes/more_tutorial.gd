extends Control


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

var Button_presses = 0
func _on_next_pressed():
	if Button_presses == 0:
		$Community.queue_free()
		$Hand2.queue_free()
		var Hand3 = Label.new()
		Hand3.set_name("Hand3")
		Hand3.text = "penis"
		$More_Tutorial.add_child("Hand3")
		Button_presses += 1
	
	
