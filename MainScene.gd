extends Node2D

func _ready() -> void:
	pass

func _process(delta: float) -> void:
	pass

func _on_button_start_pressed() -> void:
	get_tree().change_scene_to_file("res://DifficultyScene.tscn")

func _on_button_help_pressed() -> void:
	get_tree().change_scene_to_file("res://HelpScene.tscn")
