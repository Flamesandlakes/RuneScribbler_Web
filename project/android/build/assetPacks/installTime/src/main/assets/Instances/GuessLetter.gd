extends Button

var option_label = ""

func set_option(option):
	option_label = option

func _on_pressed():
	get_tree().root.get_node("Root2D").evaluate(option_label)  # Replace with function body.

