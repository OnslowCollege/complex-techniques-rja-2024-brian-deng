extends Object

# This function is for seperating the integers from the card file name.
# list_of_strings: This parameter is for the list inputted in the func 
static func separate_int(list_of_strings: Array) -> Array:
	var card_nums = []
	# For if the list is empty, this list is typically the hand of player so two cards or strings
	if list_of_strings == ["", ""]:
		return []
	# Iterates through string to seperate the numbers for each element in list
	for item in list_of_strings:
		# This list is for the numbers extracted from the file name
		var num_list = []
		# This variable is for if the integer in the file name is a double digit
		var double_digit = []
		# file name is typically in this pattern, card-clubs-5.png
		var string_split = item.split("-")
		# For if .png is there so to get rid of the .png and just get the number
		if ".png" in string_split[-1]:
			var png_split = Array(string_split[-1].split(""))
			# Creates slice of the last 4 letters in string
			var png_slice = png_split.slice(-4)
			# Iterates through the slice to remove .png from the number from the string split
			for i in png_slice:
				(png_split).erase(i)
			num_list = png_split
		# This is for if the .png isn't there so the last split would just be the number
		else:
			num_list = string_split[-1]
		# Puts the num_list elements in double digit cause maybe to prevent non numbers
		for char in num_list:
			if char == "0":
				double_digit.append(char)
			elif int(char):
				double_digit.append(char)
		# Checks if double digit is a double digit number so can append the full number
		if len(double_digit) >= 2:
			card_nums.append(("%s%s" % [double_digit[0], double_digit[1]]))
		elif len(double_digit) == 0:
			pass
		else:
			card_nums.append(double_digit[0])
	print(str(card_nums) + "nums")
	return card_nums


# This function is checking if the hand and the community cards would make a straight
# list1: List of community cards
# list2: List of numbers of hand
static func if_straight(list1: Array, list2: Array) -> Variant:
	var combined = (list1 + list2)
	var unique_combined = []
	# As straight is consecutive num, doesn't need duplicate nums
	for item in combined:
		if item not in unique_combined: 
			unique_combined.append(item)
	if 1 in unique_combined: unique_combined.append(14)
	# Sort so smallest to largest num
	unique_combined.sort()
	
	var count = 0
	var straight = []
	# Checks for consecutive numbers
	for num in range(len(unique_combined)-1, -1, -1): 
		if unique_combined[num] < 1 or unique_combined[num] > 14: continue
		if unique_combined[num] == 14 and unique_combined[num - 1] == 1: continue
		# If current num - 1 == previous num 
		if int(unique_combined[num]) - 1 == unique_combined[num - 1]:
			count += 1
			straight.append(num)
			if count == 4: 
				return straight
		# As not consecutive clears straight and retries
		else: 
			count = 0
			straight.clear()
	print(str(unique_combined) + "unique")
	return false

# This function checks if the hand plus community cards would make a flush
# p_hand: This is the current hand it is checking
# community_cards: this is for the community cards
static func if_flush(p_hand: Array, community_cards: Array) -> bool:
	var suits: Array = ["clubs", "spades", "hearts", "diamonds"] 
	var player_suits = []
	var community_suits = []
	# Adds the suits of the hand and community cards into one list 
	for suit in suits:
		for card in p_hand:
			if suit in card:
				player_suits.append(suit)
		for card in community_cards:
			if suit in card:
				community_suits.append(suit)
	# Adds the list of suits together to the check if a flush is made from the cards
	var total_suits = player_suits + community_suits
	print(str(total_suits) + "total_suits")
	for suit in total_suits:
		var suit_count = total_suits.count(suit)
		if suit_count == 5:
			return true
	return false

# This function is to check if the hand and community cards have duplicates and then labelling
# player_list: player/bot hand or list of cards
# community_list: list of community cards
static func of_a_kind(player_list: Array, community_list: Array) -> String:
	var total_list = player_list + community_list
	var dup_to_num = {}
	var num_duplicates = []
	
	# Checks total list for if there are duplicates of one number and if so appends how many duplicates 
	for num in range(0, 15):
		var dup_count = total_list.count(num)
		if dup_count >= 2:
			num_duplicates.append(dup_count)
	# for if there is 3 sets of duplicates so as the hand is best 5 cards it removes one of the duplicates 
	if len(num_duplicates) >= 3:
		num_duplicates.sort()
		num_duplicates.pop_front()
	# Assigns hand name for the amount of duplicates
	if 4 in num_duplicates:
		return "Four of a Kind"
	elif num_duplicates.count(3) >= 1:
		if num_duplicates.count(3) >= 2:
			return "Full House"
		elif num_duplicates.count(3) == 1 and num_duplicates.count(2) >= 1 :
			return "Full House"
		elif num_duplicates.count(3) == 1:
			return "Three of a Kind"
	elif num_duplicates.count(2) == 2:
		return "Two Pair"
	elif num_duplicates.count(2) == 1:
		return "Pair"
	else:
		return "High Card"
	return ("")

# This function is to assign a rating of the hands provided based on the round
# p_hand: Either a list of player or bot hand
# round: round of betting; preflop, flop, turn, river
static func rating_hand(p_hand: Array, round: Dictionary) -> Dictionary:
	var hands = {"Royal Flush": 10, "Straight Flush": 9, "Four of a Kind": 8, 
	"Full House": 7, "Flush": 6, "Straight": 5, "Three of a Kind": 4, 
	"Two Pair": 3, "Pair": 2, "High Card": 1}
	var card_id = {}
	var suit = ""

	# takes the values of the round or the dict of cards file name
	for card in round.values():
		var card_as_list = []
		card_as_list.append(card)
		var card_int = separate_int(card_as_list)
		var split = card.split("-")
		var key = int(card_int[0])
		suit = split[1]

		# Assigns a value per card from 1 to 52
		if suit ==  "clubs":
			card_id[key] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "diamonds":
			card_id[key + 13] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "hearts":
			card_id[key + 26] = ("%s %s" % [suit, card_int[0]])
		if suit ==  "spades":
			card_id[key + 39] = ("%s %s" % [suit, card_int[0]])
	print((card_id) + "card_id")

	# Gets list of integers of p_hand and round and converts the elements to int
	var player_int_list = separate_int(p_hand).map(func(s): return int(s))
	var com_int_list = separate_int(card_id.values()).map(func(s): return int(s))


	var straight  = false
	var flush = false 
	var straight_nums = if_straight(player_int_list,com_int_list)
	# Checks if the provided list form a straight or flush
	if not straight_nums: 
		pass
	else: 
		straight = true
	if if_flush(p_hand, card_id.values()):
		flush = true

	var hand_value = 0
	var high_card = (player_int_list + com_int_list).max()
	# Assigns value depending on the hand formed
	if straight and flush and (straight_nums.max() == 14):
		hand_value = hands["Royal Flush"]
	elif straight and flush and (straight_nums.max() != 14):
		hand_value = hands["Straight Flush"]
	elif flush:
		hand_value = hands["Flush"]
	elif straight:
		hand_value = hands["Straight"]
	elif of_a_kind(player_int_list, com_int_list) != "":
		hand_value = hands[of_a_kind(player_int_list, com_int_list)]
	else:
		hand_value = hands["High Card"]
	return {"value": hand_value, "high_card": high_card}
