extends Control


#@onready var RecordData = load("res://RecordData.gd").RecordData

var user_file_path = "user://"
#var save_file_name = "UserProgress.tres"
#
#var recordData = RecordData.new()
var save_path = user_file_path + "UserProgress.json"
var recordData = {}

var config_path = user_file_path + "UserConfig.json"
var configData = {}

@onready var runeholder = preload("res://Instances/rune_holder.tscn")
@onready var letterinput = preload("res://Instances/LetterButton.tscn")

#ar lettercontainer = find_child("ButtonContainer")
@onready var snowgenerator = get_node("Control/SnowParticles")
@onready var runecontainer = get_node("Control/CenterContainer/VSplitContainer/RuneContainer")
@onready var lettercontainer = get_node("Control/CenterContainer/VSplitContainer/ButtonContainer")


var feedbackeffect = preload("res://Instances/ExplosionEffect.tscn")

var config_base = {
	"button_number" : 6,
	"label_format" : "modern_equivalent",
	"effect_scale" : 2
}

var recency_limit = 6
var time_per_button = 10

var new_data = {
		"current_guess" : "",
		"correct_guesses" : 0,
		"total_guesses" : 0,
		"current_streak" : 0,
		"correctly_guessed" : [],
		"highest_streak": 0
	}


@onready var totallabel = get_node("Control/TopInfo/LabelContainer/TotalLabel")
@onready var highstreak = get_node("Control/TopInfo/LabelContainer/StreakLabel")
@onready var streaklabel = get_node("Control/CenterContainer/VSplitContainer/CurrentStreak")
@onready var countdownslider = get_node("Control/CenterContainer/VSplitContainer/Countdown")

var streak_label_size_base = 40
var streak_label_size = 40
var positive_size_trend = true


var rune_set = {"A":{"name": "Ansuz","path": "a"}, 
				"B":{"name": "Berkanan","path": "b"}, 
				"D":{"name": "Dagaz" ,"path": "d"}, 
				"E":{"name": "Ehwaz","path": "e"}, 
				"F":{"name": "Fehu","path": "f"}, 
				"G":{"name": "Gebo","path": "g"},
				"H":{"name": "Haglaz" ,"path": "h - mod"},
				"I":{"name": "Isaz","path":  "i"},
				"J":{"name": "Jeran","path": "j, y, but mirrored"},
				"K":{"name": "Kauna","path": "c, k, q"},
				"L":{"name": "Laukaz","path": "l"},
				"M":{"name": "Mannaz","path": "m, sort of"},
				"N":{"name": "Naudiz" ,"path": "n"},
				"NG":{"name": "Ingwaz","path":  "ng"},
				"O":{"name": "Othalan","path":  "o"},
				"P":{"name": "Pertho" ,"path":  "p"},
				"R":{"name": "Raido","path":  "r"},
				"S":{"name": "Sowilo","path":  "s - mod"},
				"T":{"name": "Tiwaz","path":  "t"},
				"TH":{"name": "Thurisaz" ,"path":  "th, sort of"},
				"U":{"name": "Uruz" ,"path":  "u"},
				"W":{"name": "Wunjo","path":  "v, w"},
				"Z":{"name": "Algiz","path":  "z"}}

var current_rune = "0_blank"
var rune_path = "res://Fonts/Grey as Elder Futhark/Tile/%s.png"

###############

func save_as_json(recordedData, path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(recordedData))
	file.close()

func load_json(json_path, placeholder):
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())	
		
		if content is Dictionary:
			if content.has_all(placeholder.keys()) == false:
				for key in placeholder.keys():
					if content.has(key) == false:
						content[key] = placeholder[key]
				
			return content
	else:
		#print("Prior progress not found. Using default instead.")
		return placeholder
		
	

# Called when the node enters the scene tree for the first time.
func _ready():
	recordData = load_json(save_path, new_data) #load_data()
	configData = load_json(config_path, config_base)
	
	if configData.effect_scale < 2:
		snowgenerator.emitting = false
		
	
	totallabel.text = "Total: "+str(recordData.correct_guesses)+" / "+str(recordData.total_guesses)+"   "
	highstreak.text = "Highest streak: "+str(recordData.highest_streak)+"   "
	if recordData.current_streak > 0:
		streaklabel.text = "current streak is "+str(recordData.current_streak)+"  "
	else: 
		streaklabel.text = "   "
	
	setup() # Run the setup function when the scene is loaded/initialized
	
func setup():
	screen_setup()
	
	current_rune = initialize_rune(true)
	var path = rune_path % rune_set[current_rune].path
	
	var holder = runeholder.instantiate()#get_node("CenterContainer/VSplitContainer/RuneHolder")
	#holder.position = get_viewport_rect().size / 2
	holder.position.y *= 0.2
	holder.get_node("Sprite").texture = load(path)
	
	runecontainer.add_child(holder)
	
	initialize_letter_options(current_rune, configData.button_number)
	
func screen_setup():
	
	# make sure that button_number is an integer
	if typeof(configData.button_number) != TYPE_INT:
		configData.button_number = int(configData.button_number)

	# set the number of columns based on button number
	if configData.button_number % 3 == 0:
		lettercontainer.columns = 3
	elif configData.button_number % 4 == 0:
		lettercontainer.columns = 2
		
	# setup the countdown timer
	countdownslider.set_max(time_per_button * configData.button_number)
	countdownslider.set_value_no_signal(time_per_button * configData.button_number)
	
	if recordData.current_streak > 4:
		countdownslider.self_modulate = Color(2, 0, 0)
		countdownslider.get_node("Timer").start()
	else:
		countdownslider.get_node("Timer").stop()		
		countdownslider.self_modulate = Color(1,1,1)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	pass

func _on_timer_timeout():
	if positive_size_trend:
		streak_label_size += 1 
	else: 
		streak_label_size -=1

	streaklabel.set("theme_override_font_sizes/font_size", streak_label_size)

	if streak_label_size < (streak_label_size_base - 5) or streak_label_size > (streak_label_size_base + 5):
		positive_size_trend = not positive_size_trend

func _on_second_clock():
	var rate = 1
	if recordData.current_streak > 20:
		rate = 2
	
	countdownslider.set_value_no_signal(countdownslider.value - rate)
	if countdownslider.value == 0:
		countdownslider.get_node("Timer").stop()
		evaluate("TIME HAS RUN OUT!")
		
		
func initialize_rune(ignore_recent_rights = true):
	var index = randi() % rune_set.values().size()
	var rune = rune_set.keys()[index]
	
	if ignore_recent_rights == true:
		while rune in recordData.correctly_guessed:  
			index = randi() % rune_set.values().size()
			rune = rune_set.keys()[index]
	return rune
	
func initialize_letter_options(curr_rune, n_options = 9):
	#var offset = 0
	
	# remove existing buttons (if any) from container
	if lettercontainer.get_child_count() != 0:
		for _button in lettercontainer.get_children():
			lettercontainer.remove_child(_button)
			_button.queue_free()
	
	# randomize options (besides the correct one)
	var options = [curr_rune]
	var list = rune_set.keys()
	list.remove_at(list.find(curr_rune))
	for i in range(n_options-1):
		var letter_index = randi()%list.size()
		options.append(list[letter_index])
		list.remove_at(letter_index)
	
	# order the options
	var options_ord = []
	for r in rune_set.keys():
		if r in options:
			options_ord.append(r)
	
	# init button
	for option in options_ord:

		var _button = create_inputButton(option)
		
		lettercontainer.add_child(_button)
		
		
func evaluate(input):
	recordData.total_guesses += 1
	var is_correct = true
	
	if current_rune == input:
		recordData.correct_guesses += 1
		recordData.current_streak += 1
		recordData.correctly_guessed.append(current_rune)
		if recordData.correctly_guessed.size() > recency_limit:
				recordData.correctly_guessed.remove_at(0)
		##print(correctly_guessed)
		if recordData.current_streak > recordData.highest_streak:
			recordData.highest_streak = recordData.current_streak
		
		is_correct = true
	
	else:
		#recordData.process_eval(false)
		recordData.current_streak = 0
		is_correct = false
	
	for i in range(configData.effect_scale * 10):
		instant_feedback(is_correct)
	
	totallabel.text = "Total: "+str(recordData.correct_guesses)+" / "+str(recordData.total_guesses)+"   "
	highstreak.text = "Highest streak: "+str(recordData.highest_streak)+"   "
	if recordData.current_streak > 0:
		streaklabel.text = "current streak is "+str(recordData.current_streak)+"  "
	else: 
		streaklabel.text = "   "
	setup()
	
func instant_feedback(positive = true):
	var _feedback = feedbackeffect.instantiate()
	
	# change color depending on feedback type
	if positive == false:
		var color = Color(2, 0, 0)
		_feedback.self_modulate = color

	runecontainer.add_child(_feedback)
	_feedback.emitting = true

func create_inputButton(label):
	var button = Button.new()
		
	if configData.label_format == "protogermanic": #in_protogermanic:
		button.text = "    "+rune_set[label]["name"]+"    "
	else:
		button.text = "       "+ label + "       "# % "%10d"
	#button.add_theme_font_size_override("dance", 60)
	button.pressed.connect(evaluate.bind(label))
	return button


func _on_Return_pressed():
	save_as_json(recordData, save_path)# save_data()
	get_tree().change_scene_to_file("res://Worlds/StartMenu.tscn")

