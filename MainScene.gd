extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_button_start_pressed() -> void:
	#$Label.text = "{\n\t\"easy\": {\n\t\t\"score\": 0,\n\t\t\"second\": 60\n\t},\n\t\"normal\": {\n\t\t\"score\": 0,\n\t\t\"second\": 240\n\t},\n\t\"hard\": {\n\t\t\"score\": 0,\n\t\t\"second\": 600\n\t}\n}";
	#var ospath = OS.get_executable_path()
	#$Label.text = ospath.substr(0, ospath.rfind("/")) + "/Record.json";
	get_tree().change_scene_to_file("res://DifficultyScene.tscn")

func _on_button_help_pressed() -> void:
	get_tree().change_scene_to_file("res://HelpScene.tscn")
