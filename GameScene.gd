extends Node2D

# 值~每个雷代表-1，周围的数字代表周围雷数量。0~8
var chess
var chess_lock
var scene_button
var scene_label
var time
var is_lock = false
var mine = 0
var flag = 0
var is_start = false

func _ready() -> void:
	chess = initialize_2d_array(Global.height, Global.width, 0)
	chess_lock = initialize_2d_array(Global.height, Global.width, true)
	scene_button = initialize_2d_array(Global.height, Global.width, null)
	scene_label = initialize_2d_array(Global.height, Global.width, null)
	time = Global.second
	flag = Global.mine
	$LabelSecond.text = "剩余秒数：" + str(time)
	$LabelFlag.text = "剩余旗子：" + str(flag)
	# 蒙布+为文字和按钮赋初始框框
	_reload_scene()

var time_accumulator = 0.0
func _process(delta: float) -> void:
	# 判断是否点击场上任意按钮（此时是否开始）
	if is_start:
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
	
# 随机生成所有雷
func _rand_mine(m: int, n: int):
	for o in range(Global.mine):
		while true:
			var i = randi() % Global.height
			var j = randi() % Global.width
			if(m == i && j == n):
				continue
			if(chess[i][j] == 0):
				chess[i][j] = -1
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
			if chess[i][j] == -1:
				foo = -1
			else:
				if i > 0 and j > 0:
					if chess[i - 1][j - 1] == -1:
						foo += 1
				if i > 0 and j < Global.width - 1:
					if chess[i - 1][j + 1] == -1:
						foo += 1
				if i < Global.height - 1 and j > 0:
					if chess[i + 1][j - 1] == -1:
						foo += 1
				if i < Global.height - 1 and j < Global.width - 1:
					if chess[i + 1][j + 1] == -1:
						foo += 1
				if i > 0:
					if chess[i - 1][j] == -1:
						foo += 1
				if j > 0:
					if chess[i][j - 1] == -1:
						foo += 1
				if i < Global.height - 1:
					if chess[i + 1][j] == -1:
						foo += 1
				if j < Global.width - 1:
					if chess[i][j + 1] == -1:
						foo += 1
			chess[i][j] = foo
			
# 将color的int数字，转换成float形式的数据并返回。
func color_int_to_float(r: int, g: int, b: int) -> Color:
	return Color(float(r) / 255, float(g) / 255, float(b) / 255)
			
# 初始化场景
func _reload_scene():
	for i in Global.height:
		for j in Global.width:
			scene_label[i][j] = Label.new()
			var label = StyleBoxFlat.new()
			label.border_width_top = 2
			label.border_width_right = 2
			label.border_width_left = 2
			label.border_width_bottom = 2
			label.border_color = color_int_to_float(10, 10, 10)
			scene_label[i][j].add_theme_stylebox_override("normal", label)
			scene_label[i][j].add_theme_font_size_override("font_size", 29)
			scene_label[i][j].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			scene_label[i][j].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			scene_label[i][j].size.x = 40
			scene_label[i][j].size.y = 40
			scene_label[i][j].position.x = j * 40
			scene_label[i][j].position.y = i * 40
			$MineScenePanel.add_child(scene_label[i][j])
			scene_button[i][j] = Button.new()
			var normal = StyleBoxFlat.new()
			normal.border_width_top = 2
			normal.border_width_right = 2
			normal.border_width_left = 2
			normal.border_width_bottom = 2
			normal.border_color = color_int_to_float(10, 10, 10)
			normal.bg_color = color_int_to_float(60, 60, 60)
			var hover = StyleBoxFlat.new()
			hover.border_width_top = 2
			hover.border_width_right = 2
			hover.border_width_left = 2
			hover.border_width_bottom = 2
			hover.border_color = color_int_to_float(10, 10, 10)
			hover.bg_color = color_int_to_float(40, 40, 40)
			var pressed = StyleBoxFlat.new()
			pressed.border_width_top = 2
			pressed.border_width_right = 2
			pressed.border_width_left = 2
			pressed.border_width_bottom = 2
			pressed.border_color = color_int_to_float(10, 10, 10)
			pressed.bg_color = color_int_to_float(20, 20, 20)
			scene_button[i][j].add_theme_stylebox_override("pressed", pressed)
			scene_button[i][j].add_theme_stylebox_override("normal", normal)
			scene_button[i][j].add_theme_stylebox_override("hover", hover)
			scene_button[i][j].size.x = 40
			scene_button[i][j].size.y = 40
			scene_button[i][j].position.x = j * 40
			scene_button[i][j].position.y = i * 40
			#scene_button[i][j].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			#scene_button[i][j].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			scene_button[i][j].add_theme_font_size_override("font_size", 29)
			scene_button[i][j].connect("gui_input", Callable(self, "_on_any_button_gui_input").bind(i, j))
			$MineScenePanel.add_child(scene_button[i][j])
			
# 点击按钮
func _on_any_button_gui_input(event, i: int, j: int):
	# 首先判断一次是否已经判断了输赢
	if not is_lock:
		if event is InputEventMouseButton and event.pressed:
		# 左键，执行on_any_button_pressed
			if event.button_index == 1:
				_on_any_button_step(i, j)
			# 右键，为按钮标旗子~
			elif event.button_index == 2:
				_on_any_button_flag(i, j)

# 标记旗子
func _on_any_button_flag(i: int, j: int):
	if flag > 0:
		if chess_lock[i][j]:
			scene_button[i][j].text = "旗"
			flag -= 1
		else:
			scene_button[i][j].text = ""
			flag += 1
		chess_lock[i][j] = not chess_lock[i][j]
		$LabelFlag.text = "剩余旗子：" + str(flag)
	else:
		if not chess_lock[i][j]:
			scene_button[i][j].text = ""
			flag += 1
			chess_lock[i][j] = not chess_lock[i][j]
			$LabelFlag.text = "剩余旗子：" + str(flag)
			
# 显示数字~对照着chess的值直接赋值
func show_number(i: int, j: int):
	scene_label[i][j].text = str(chess[i][j]) if chess[i][j] > 0 else "" if chess[i][j] == 0 else "雷"
	match chess[i][j]:
		-1:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(30, 30, 120))
		1:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 128, 255))
		2:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 128, 0))
		3:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(192, 0, 0))
		4:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 0, 96))
		5:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 0, 96))
		6:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 96, 96))
		7:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 0, 0))
		8:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(100, 100, 100))
		_:
			pass

# 任意一个按钮点击
func _on_any_button_step(i: int, j: int):
	# 当点击第一个按钮时，埋雷并且初始化chess，为is_start赋值为true。
	if not is_start:
		is_start = true
		# 埋雷
		_rand_mine(i, j)
		# 将chess赋值
		_reload_array()
	if chess_lock[i][j]:
		if scene_button[i][j] != null:
			remove_child(scene_button[i][j])
			scene_button[i][j].queue_free()
			scene_button[i][j] = null;
			show_number(i, j)
			if chess[i][j] == -1:
				is_lock = true
				$LabelWin.text = "你输了~"
				for k in range(Global.height):
					for l in range(Global.width):
						if scene_button[k][l] != null and chess[k][l] == -1:
							show_number(k, l)
							remove_child(scene_button[k][l])
							scene_button[k][l].queue_free()
							scene_button[k][l] = null;
				var normal = StyleBoxFlat.new()
				normal.border_width_top = 2
				normal.border_width_right = 2
				normal.border_width_left = 2
				normal.border_width_bottom = 2
				normal.border_color = color_int_to_float(10, 10, 10)
				normal.bg_color = color_int_to_float(200, 0, 0)
				scene_label[i][j].add_theme_stylebox_override("normal", normal)
				return
			mine += 1
			Global.score += 10
			$LabelScore.text = "分数：" + str(Global.score)
			if mine >= Global.width * Global.height - Global.mine:
				is_lock = true
				$LabelWin.text = "你赢了~"
			# 如果走到空格，则递归调用八次本函数以翻开周围8个格子。
			if chess[i][j] == 0:
				if i > 0 and j > 0:
					_on_any_button_step(i - 1, j - 1)
				if i > 0 and j < Global.width - 1:
					_on_any_button_step(i - 1, j + 1)
				if i < Global.height - 1 and j > 0:
					_on_any_button_step(i + 1, j - 1)
				if i < Global.height - 1 and j < Global.width - 1:
					_on_any_button_step(i + 1, j + 1)
				if i > 0:
					_on_any_button_step(i - 1, j)
				if j > 0:
					_on_any_button_step(i, j - 1)
				if i < Global.height - 1:
					_on_any_button_step(i + 1, j)
				if j < Global.width - 1:
					_on_any_button_step(i, j + 1)
		
			
func _on_button_return_pressed() -> void:
	get_tree().change_scene_to_file("res://MainScene.tscn")
	Global.mine = 10
	Global.height = 8
	Global.width = 8
	Global.score = 0
	Global.second = 300
