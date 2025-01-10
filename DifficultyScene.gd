extends Node2D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_return_button_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")


func _on_start_button_pressed() -> void:
	var height_str = str($DifficultyHeightTextEdit.text)
	var height = height_str.to_int()
	var width_str = str($DifficultyWidthTextEdit.text)
	var width = width_str.to_int()
	var mine_str = str($DifficultyMineTextEdit.text)
	var mine = mine_str.to_int()
	var second_str = str($DifficultySecondTextEdit.text)
	var second = second_str.to_int()
	if str(height) == height_str and height >= 8 and height <= 20:
		Global.height = height
	if str(width) == width_str and width >= 8 and width <= 20:
		Global.width = width
	if str(mine) == mine_str and mine >= 10 and mine <= Global.width * Global.height - 10:
		Global.mine = mine
	if str(second) == second_str and second >= 60 and second <= 600:
		Global.second = second
	get_tree().change_scene_to_file("res://GameScene.tscn")


func _on_easy_button_button_down() -> void:
	$DifficultyHeightTextEdit.text = str(9)
	$DifficultyWidthTextEdit.text = str(9)
	$DifficultyMineTextEdit.text = str(10)
	$DifficultySecondTextEdit.text = str(60)

func _on_normal_button_button_down() -> void:
	$DifficultyHeightTextEdit.text = str(14)
	$DifficultyWidthTextEdit.text = str(14)
	$DifficultyMineTextEdit.text = str(40)
	$DifficultySecondTextEdit.text = str(240)

func _on_hard_button_button_down() -> void:
	$DifficultyHeightTextEdit.text = str(20)
	$DifficultyWidthTextEdit.text = str(20)
	$DifficultyMineTextEdit.text = str(80)
	$DifficultySecondTextEdit.text = str(600)
