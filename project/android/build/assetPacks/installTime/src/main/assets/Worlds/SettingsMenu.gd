extends Control

var user_file_path = "user://"
#var save_file_name = "UserProgress.tres"
#
#var recordData = RecordData.new()
var save_path = user_file_path + "UserProgress.json"
var recordData = {}

var config_path = user_file_path + "UserConfig.json"
var configData = {}

var config_base = {
	"button_number" : 6,
	"label_format" : "modern_equivalent",
	"effect_scale" : 2
}
var existing_config = config_base

var new_data = {
		"current_guess" : "",
		"correct_guesses" : 0,
		"total_guesses" : 0,
		"current_streak" : 0,
		"correctly_guessed" : [],
		"highest_score": 0
	}
var existing_record = new_data

var reset_toggled = false

@onready var buttons_slider =  get_node("VBoxContainer/SetButtonsNumber")
@onready var format_option =  get_node("VBoxContainer/SetLabelFormat")
@onready var effects_slider =  get_node("VBoxContainer/ScaleEffects")
@onready var save_button =  get_node("VBoxContainer/SaveButton")

func save_as_json(recordedData, path):
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(JSON.stringify(recordedData))
	file.close()

func load_json(json_path, placeholder):
	if FileAccess.file_exists(json_path):
		var file = FileAccess.open(json_path, FileAccess.READ)
		var content = JSON.parse_string(file.get_as_text())	
		
		if content is Dictionary:
			# add missing keys
			if content.has_all(placeholder.keys()) == false:
				for key in placeholder.keys():
					if content.has(key) == false:
						content[key] = placeholder[key]
			
			# remove invalid entries
			if placeholder.has_all(content.keys()) == false:
				for key in content.keys():
					if placeholder.has(key) == false:
						content.erase(key)
			
			return content
	else:
		print("Prior progress not found. Using default instead.")
		return placeholder


# Called when the node enters the scene tree for the first time.
func _ready():
	recordData = load_json(save_path, new_data)
	configData = load_json(config_path, config_base)
	
	# make copies, to enable reference to original data
	existing_record = recordData.duplicate(true)
	existing_config = configData.duplicate(true)
	
	setup(configData)
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta):
	if reset_toggled or configData ==  existing_config:
		if save_button.disabled == true:
			save_button.disabled = false


func setup(config):
	buttons_slider.set_value_no_signal(config.button_number)
	#buttons_slider.value = configData.button_number
	
	if config.label_format == "protogermanic":
		format_option.button_pressed = true
	else:
		format_option.button_pressed = false
	
	print(config)
	effects_slider.set_value_no_signal(config.effect_scale)

func _on_set_buttons_number_drag_ended(value_changed):
	if value_changed:
		configData.button_number = buttons_slider.value 
	

func _on_set_label_format_toggled(toggled_on):
	if toggled_on: 
		configData.label_format = "protogermanic"
	else:
		configData.label_format = "modern_equivalent"

	
func _on_scale_effects_drag_ended(value_changed):
	if value_changed:
		configData.effect_scale = effects_slider.value 

func _on_reset_records_toggled(toggled_on):
	if toggled_on:
		recordData = new_data
		reset_toggled = true
	else:
		recordData = existing_record
		reset_toggled = false

func _on_save_button_pressed():
	save_as_json(configData, config_path)
	save_as_json(recordData, save_path)


func _on_Return_pressed():
	get_tree().change_scene_to_file("res://Worlds/StartMenu.tscn")












