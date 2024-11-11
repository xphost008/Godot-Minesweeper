extends Node2D

var chess
# 值~每个雷代表-1，周围的数字代表周围雷数量。0~8
var b_chess
var scene_button
var scene_label
var time
var is_lock = false
var mine = 0

func _ready() -> void:
	chess = initialize_2d_array(Global.height, Global.width, 0)
	b_chess = initialize_2d_array(Global.height, Global.width, 0)
	scene_button = initialize_2d_array(Global.height, Global.width, null)
	scene_label = initialize_2d_array(Global.height, Global.width, null)
	time = Global.second
	$LabelSecond.text = "剩余秒数：" + str(time)
	# 埋雷
	for i in range(Global.mine):
		_rand_mine()
	# 将b_chess赋值
	_reload_array()
	# 布置场景+蒙布
	_reload_scene()

var time_accumulator = 0.0
func _process(delta: float) -> void:
	# 时间自增delta
	time_accumulator += delta
	# 如果自增时间超过了自定义时间，则执行一次execute_task。然后将自增时间重设为0
	if time_accumulator >= 1:
		_execute_task()
		time_accumulator = 0.0

# 执行一次时间减少
func _execute_task():
	if not is_lock:
		if time < 1:
			is_lock = true
			$LabelWin.text = "你输了~"
		else:
			time -= 1
			$LabelSecond.text = "剩余秒数：" + str(time)
	
# 随机生成一个雷
func _rand_mine():
	while true:
		var i = randi() % Global.height
		var j = randi() % Global.width
		if(chess[i][j] == 0):
			chess[i][j] = 1
			break
	
# 初始化一次二维数组。
func initialize_2d_array(rows: int, columns: int, default_value):
	var array = []
	array.resize(rows)
	for i in range(rows):
		array[i] = []
		array[i].resize(columns)
		for j in range(columns):
			array[i][j] = default_value
	return array

func _reload_array():
	for i in range(Global.height):
		for j in range(Global.width):
			var foo = 0;
			if chess[i][j] == 1:
				foo = -1
			else:
				if i > 0 and j > 0:
					if chess[i - 1][j - 1] == 1:
						foo += 1
				if i > 0 and j < Global.width - 1:
					if chess[i - 1][j + 1] == 1:
						foo += 1
				if i < Global.height - 1 and j > 0:
					if chess[i + 1][j - 1] == 1:
						foo += 1
				if i < Global.height - 1 and j < Global.width - 1:
					if chess[i + 1][j + 1] == 1:
						foo += 1
				if i > 0:
					if chess[i - 1][j] == 1:
						foo += 1
				if j > 0:
					if chess[i][j - 1] == 1:
						foo += 1
				if i < Global.height - 1:
					if chess[i + 1][j] == 1:
						foo += 1
				if j < Global.width - 1:
					if chess[i][j + 1] == 1:
						foo += 1
			b_chess[i][j] = foo
			
# 将color的int数字，转换成float形式的数据并返回。
func color_int_to_float(r: int, g: int, b: int) -> Color:
	return Color(float(r) / 255, float(g) / 255, float(b) / 255)
			
func _reload_scene():
	for i in Global.height:
		for j in Global.width:
			scene_label[i][j] = Label.new()
			scene_label[i][j].add_theme_font_size_override("font_size", 29)
			scene_label[i][j].text = str(b_chess[i][j]) if b_chess[i][j] != -1 else "" if b_chess[i][j] == 0 else "雷"
			scene_label[i][j].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			scene_label[i][j].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			scene_label[i][j].size.x = 40
			scene_label[i][j].size.y = 40
			scene_label[i][j].position.x = j * 40
			scene_label[i][j].position.y = i * 40
			$MineScenePanel.add_child(scene_label[i][j])
			scene_button[i][j] = Button.new()
			var normal = StyleBoxFlat.new()
			normal.bg_color = color_int_to_float(20, 50, 70)
			var hover = StyleBoxFlat.new()
			hover.bg_color = color_int_to_float(80, 0, 20)
			var pressed = StyleBoxFlat.new()
			pressed.bg_color = color_int_to_float(30, 50, 30)
			scene_button[i][j].add_theme_stylebox_override("pressed", pressed)
			scene_button[i][j].add_theme_stylebox_override("normal", normal)
			scene_button[i][j].add_theme_stylebox_override("hover", hover)
			scene_button[i][j].size.x = 40
			scene_button[i][j].size.y = 40
			scene_button[i][j].position.x = j * 40
			scene_button[i][j].position.y = i * 40
			scene_button[i][j].pressed.connect(_on_any_button_pressed.bind(i, j))
			$MineScenePanel.add_child(scene_button[i][j])
			
func _on_any_button_pressed(i: int, j: int):
	if not is_lock:
		if scene_button[i][j] != null:
			remove_child(scene_button[i][j])
			scene_button[i][j].queue_free()
			scene_button[i][j] = null;
			if chess[i][j] == 1:
				is_lock = true
				$LabelWin.text = "你输了~"
				return
			mine += 1
			Global.score += 10
			$LabelScore.text = "分数：" + str(Global.score)
			if mine >= Global.width * Global.height - Global.mine:
				is_lock = true
				$LabelWin.text = "你赢了~"
			if b_chess[i][j] == 0:
				if i > 0 and j > 0:
					_on_any_button_pressed(i - 1, j - 1)
				if i > 0 and j < Global.width - 1:
					_on_any_button_pressed(i - 1, j + 1)
				if i < Global.height - 1 and j > 0:
					_on_any_button_pressed(i + 1, j - 1)
				if i < Global.height - 1 and j < Global.width - 1:
					_on_any_button_pressed(i + 1, j + 1)
				if i > 0:
					_on_any_button_pressed(i - 1, j)
				if j > 0:
					_on_any_button_pressed(i, j - 1)
				if i < Global.height - 1:
					_on_any_button_pressed(i + 1, j)
				if j < Global.width - 1:
					_on_any_button_pressed(i, j + 1)
		
			
func _on_button_return_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")
	Global.mine = 10
	Global.height = 8
	Global.width = 8
	Global.score = 0
	Global.second = 300
