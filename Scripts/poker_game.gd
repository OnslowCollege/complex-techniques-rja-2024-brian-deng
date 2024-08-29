extends Node2D

var files = []
var cards = {}

func list_files_in_directory(path):
	var dir = DirAccess.open(path)
	dir.list_dir_begin()
	while true:
		var file = dir.get_next()
		if file == "":
			break
		elif ".import" in file:
			continue
		elif not file.begins_with("."):
			files.append(file)
	return files

# Called when the node enters the scene tree for the first time.
func _ready():
	$Dealing/Dealing2.play("Dealing")
	(list_files_in_directory(
		"res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"))
	for i in range(len(files)-1, -1, -1):
		var file = files[i]
		if ("clubs" in file or "hearts" in file or 
			"spades" in file or "diamonds" in file):
			continue
		else:
			files.remove_at(i) 

	var count: int = 1
	var suit = ""
	for file in files:
		if count <= 13:
			suit = "clubs"
		elif 13 < count and count <= 26:
			suit = "diamonds"
		elif 26 < count and count <= 39:
			suit = "hearts"
		elif 39 < count and count <= 52:
			suit = "spades"
		if (("%s" % [suit] in file) and ("%d" % [count] in file)):
			cards["%s %d" % [suit, count]] = file
		count += 1
	print(cards)
	print(cards.keys())
	
	#print(list_files_in_directory("res://Assets/Pixel Fantasy Playing Cards/Playing Cards/"))
	# Reading from file to get flashcard data.
	#if let Menu: String = try? String(contentsOfFile: "facts.txt"): 
		## Putting items in loop from the facts imported from facts.text
		#for items in Menu.components(separatedBy: "\n"):
			## Putting event and it's date
			#var item = items.components(separatedBy: ",")
			## Incase the there is a empty line in .txt file
			#if item[0] == ""{ continue }
			## To ensure no index out of range error
			#item.append("")
			## Adds the item and date to list in a struct
			#var info = FlashCard(historicEvent: item[0], eventDate: item[1], bCE: item[2])
			#flashCards.append(info)
		#
	#else: print("No such file")


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func _on_menu_pressed():
	get_tree().change_scene_to_file("res://Scenes/menu.tscn")

