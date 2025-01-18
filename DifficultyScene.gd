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
	var seed_str = str($DifficultySeedTextEdit.text)
	var seed = seed_str.to_int()
	if str(height) == height_str and height >= 8 and height <= 25:
		Global.height = height
	if str(width) == width_str and width >= 8 and width <= 30:
		Global.width = width
	if str(mine) == mine_str and mine >= 10 and mine <= Global.width * Global.height - 10:
		Global.mine = mine
	else:
		var x = Global.width * Global.height
		var r = (0.20625 * x) if 480 <= x else (x * x) / 5760 + x / 8
		Global.mine = int(r)
	if str(second) == second_str and second >= 60 and second <= 1200:
		Global.second = second
	if str(seed) == seed_str and seed > 0 and seed < 4294967296:
		Global.seed = seed
	get_tree().change_scene_to_file("res://GameScene.tscn")

func _on_easy_button_pressed() -> void:
	$DifficultyHeightTextEdit.text = str(9)
	$DifficultyWidthTextEdit.text = str(9)
	$DifficultyMineTextEdit.text = str(10)
	$DifficultySecondTextEdit.text = str(60)

func _on_normal_button_pressed() -> void:
	$DifficultyHeightTextEdit.text = str(16)
	$DifficultyWidthTextEdit.text = str(16)
	$DifficultyMineTextEdit.text = str(40)
	$DifficultySecondTextEdit.text = str(600)

func _on_hard_button_pressed() -> void:
	$DifficultyHeightTextEdit.text = str(16)
	$DifficultyWidthTextEdit.text = str(30)
	$DifficultyMineTextEdit.text = str(99)
	$DifficultySecondTextEdit.text = str(1200)
