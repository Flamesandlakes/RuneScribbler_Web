extends Control

var user_file_path = "user://"

var config_path = user_file_path + "UserConfig.json"
var configData = {}

var config_base = {
	"button_number" : 6,
	"label_format" : "modern_equivalent",
	"effect_scale" : 2
}

@onready var snowgenerator = get_node("SnowParticles")

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
		print("Prior progress not found. Using default instead.")
		return placeholder



func _ready():
	configData = load_json(config_path, config_base)
	
	if configData.effect_scale < 2:
		snowgenerator.emitting = false
	else:
		snowgenerator.emitting = true
	
func _on_Play_pressed():
	get_tree().change_scene_to_file("res://Worlds/RuneQuessing_v00.tscn")

func _on_tutorial_pressed():
	get_tree().change_scene_to_file("res://Worlds/RuneTutorial.tscn")
	
func _on_options_pressed():
	get_tree().change_scene_to_file("res://Worlds/SettingsMenu.tscn")


func _on_Quit_pressed():
	OS.shell_open("https://flamesandlakes.github.io/")
	get_tree().quit() # Replace with function body.



