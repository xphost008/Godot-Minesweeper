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
var mode = 4

func read_file(path: String) -> String:
	var file = FileAccess.open(path, FileAccess.READ)
	var txt = file.get_as_text()
	file.close()
	return txt

func write_file(path: String, content: String) -> void:
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(content)
	file.close()

func delete_file(path: String, file_name: String) -> bool:
	var dir = DirAccess.open(path)
	return dir.remove(file_name) == 0

# 判断记录（当随机种子时才使用）
func _judge_start_record() -> void:
	# 读一次文件~
	var ospath = OS.get_executable_path()
	var rlpath = ospath.substr(0, ospath.rfind("/")) + "/Record.json"
	if not FileAccess.file_exists(rlpath):
		write_file(rlpath, "{\n\t\"easy\": {\n\t\t\"score\": 0,\n\t\t\"second\": 60\n\t},\n\t\"normal\": {\n\t\t\"score\": 0,\n\t\t\"second\": 600\n\t},\n\t\"hard\": {\n\t\t\"score\": 0,\n\t\t\"second\": 1200\n\t}\n}")
	# 简单模式~
	# 将读取的记录信息写入到文本框内容
	if mode != 4 and Global.width == 9 && Global.height == 9 && Global.mine == 10 && Global.second == 60:
		mode = 1
		$DifLabel.text = "当前难度：简单"
		var file = read_file(rlpath)
		var json = JSON.parse_string(file)
		var easy = json["easy"]
		var score = str(easy["score"])
		var second = str(easy["second"])
		$ScoreRecordLabel.text = "分数记录：" + score
		$SecondRecordLabel.text = "秒数记录：" + second
	# 普通模式
	elif mode != 4 and Global.width == 16 && Global.height == 16 && Global.mine == 40 && Global.second == 600:
		mode = 2
		$DifLabel.text = "当前难度：普通"
		var f = read_file(rlpath)
		var json = JSON.parse_string(f)
		var easy = json["normal"]
		var score = str(easy["score"])
		var second = str(easy["second"])
		$ScoreRecordLabel.text = "分数记录：" + score
		$SecondRecordLabel.text = "秒数记录：" + second
	# 困难模式
	elif mode != 4 and Global.width == 30 && Global.height == 16 && Global.mine == 99 && Global.second == 1200:
		mode = 3
		$DifLabel.text = "当前难度：困难"
		var f = read_file(rlpath)
		var json = JSON.parse_string(f)
		var easy = json["hard"]
		var score = str(easy["score"])
		var second = str(easy["second"])
		$ScoreRecordLabel.text = "分数记录：" + score
		$SecondRecordLabel.text = "秒数记录：" + second
	# 自定义模式
	else:
		mode = 4
		$DifLabel.text = "当前难度：自定义"
		$SecondRecordLabel.text = "秒数记录："
		$ScoreRecordLabel.text = "分数记录："
	pass
	
# 保存记录~
func judge_save_record() -> void:
	# 获取秒数和分数
	var sco = mine * 10
	var sec = Global.second - time
	# 再读一次文件~
	var ospath = OS.get_executable_path()
	var rlpath = ospath.substr(0, ospath.rfind("/")) + "/Record.json"
	var file = read_file(rlpath)
	var json = JSON.parse_string(file)
	# 开始写记录
	match mode:
		1:
			var easy = json["easy"]
			var rsco = easy["score"]
			var rsec = easy["second"]
			if sco > rsco:
				json["easy"]["score"] = sco
				json["easy"]["second"] = sec
			elif sco == rsco:
				if sec < rsec:
					json["easy"]["score"] = sco
					json["easy"]["second"] = sec
		2:
			var easy = json["normal"]
			var rsco = easy["score"]
			var rsec = easy["second"]
			if sco > rsco:
				json["normal"]["score"] = sco
				json["normal"]["second"] = sec
			elif sco == rsco:
				if sec < rsec:
					json["normal"]["score"] = sco
					json["normal"]["second"] = sec
		3:
			var easy = json["hard"]
			var rsco = easy["score"]
			var rsec = easy["second"]
			if sco > rsco:
				json["hard"]["score"] = sco
				json["hard"]["second"] = sec
			elif sco == rsco:
				if sec < rsec:
					json["hard"]["score"] = sco
					json["hard"]["second"] = sec
		_:
			pass
	# 将文件重新再写出一次~
	if not FileAccess.file_exists(rlpath):
		delete_file(rlpath.substr(0, rlpath.rfind("/")), "Record.json")
	write_file(rlpath, JSON.stringify(json, "\t"))

# 重新开始游戏
func _on_retry_button_pressed() -> void:
	Global.seed = 0
	_ready()

# 以种子重新开始游戏
func _on_retry_by_seed_button_pressed() -> void:
	_ready()

# 开始游戏啦~亲亲~~~~~~~
func _ready() -> void:
	if Global.seed != 0:
		mode = 4
		seed(Global.seed)
	else:
		mode = 0
		#Global.seed = randi()
		#seed(Global.seed)
	initialize_2d_array(Global.height, Global.width)
	time = Global.second
	flag = Global.mine
	Global.score = 0
	mine = 0
	is_lock = false
	is_start = false
	$LabelWin.text = ""
	$LabelScore.text = "分数：0"
	$LabelSecond.text = "剩余秒数：" + str(time)
	$LabelFlag.text = "剩余旗子：" + str(flag)
	$CurrentSeedLabel.text = "当前种子：\n" + str(Global.seed)
	# 判断一次记录表
	_judge_start_record()
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
			$LabelWin.add_theme_color_override("font_color", color_int_to_float(255, 0, 0))
			$LabelWin.text = "你输了~"
		else:
			time -= 1
			$LabelSecond.text = "剩余秒数：" + str(time)
	
# 仅初始化一次棋盘。
func _reload_chess():
	chess = []
	chess.resize(Global.height)
	for i in range(Global.height):
		chess[i] = []
		chess[i].resize(Global.width)
		for j in range(Global.width):
			chess[i][j] = 0
		
# 随机生成所有雷
func _rand_mine(sd: int) -> int:
	# 先判断一次种子是否已经设置，如果已经设置了，则按照默认初始种子设置雷。同时返回种子值。
	var gl = randi()
	# 如果没有设置初始种子，则随机生成一个数字作为种子。之后返回种子值。
	if sd != 0:
		gl = sd
	seed(gl)
	# 初始化棋盘，防止当点到重复种子时出现棋盘上全是雷的情况。
	_reload_chess()
	for o in range(Global.mine):
		while true:
			var i = randi() % Global.height
			var j = randi() % Global.width
			if(chess[i][j] == 0):
				chess[i][j] = -1
				break
	return gl
	
	
# 初始化一次二维数组。
func initialize_2d_array(rows: int, columns: int):
	chess = []
	chess_lock = []
	scene_button = []
	scene_label = []
	chess.resize(rows)
	chess_lock.resize(rows)
	scene_button.resize(rows)
	scene_label.resize(rows)
	for i in range(rows):
		chess[i] = []
		chess_lock[i] = []
		scene_button[i] = []
		scene_label[i] = []
		chess[i].resize(columns)
		chess_lock[i].resize(columns)
		scene_button[i].resize(columns)
		scene_label[i].resize(columns)
		for j in range(columns):
			chess[i][j] = 0
			chess_lock[i][j] = true
			scene_button[i][j] = null
			scene_label[i][j] = null

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
			label.border_width_top = 1
			label.border_width_right = 1
			label.border_width_left = 1
			label.border_width_bottom = 1
			label.border_color = color_int_to_float(10, 10, 10)
			scene_label[i][j].add_theme_stylebox_override("normal", label)
			scene_label[i][j].add_theme_font_size_override("font_size", 25)
			scene_label[i][j].horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			scene_label[i][j].vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			scene_label[i][j].size.x = 40
			scene_label[i][j].size.y = 40
			scene_label[i][j].position.x = j * 40
			scene_label[i][j].position.y = i * 40
			scene_label[i][j].mouse_filter = Control.MOUSE_FILTER_STOP
			scene_label[i][j].connect("gui_input", Callable(self, "_on_any_label_gui_input").bind(i, j))
			$MineScenePanel.add_child(scene_label[i][j])
			scene_button[i][j] = Button.new()
			var normal = StyleBoxFlat.new()
			normal.border_width_top = 1
			normal.border_width_right = 1
			normal.border_width_left = 1
			normal.border_width_bottom = 1
			normal.border_color = color_int_to_float(10, 10, 10)
			normal.bg_color = color_int_to_float(60, 60, 60)
			var hover = StyleBoxFlat.new()
			hover.border_width_top = 1
			hover.border_width_right = 1
			hover.border_width_left = 1
			hover.border_width_bottom = 1
			hover.border_color = color_int_to_float(10, 10, 10)
			hover.bg_color = color_int_to_float(40, 40, 40)
			var pressed = StyleBoxFlat.new()
			pressed.border_width_top = 1
			pressed.border_width_right = 1
			pressed.border_width_left = 1
			pressed.border_width_bottom = 1
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
			scene_button[i][j].add_theme_font_size_override("font_size", 25)
			scene_button[i][j].connect("gui_input", Callable(self, "_on_any_button_gui_input").bind(i, j))
			$MineScenePanel.add_child(scene_button[i][j])
			
# 开启已开过的格子周围8个格子
func _on_any_label_step(i: int, j: int):
	var cc = chess[i][j]
	var k = 0
	# 首先判断一次周围8个格子是否已经被开过或者是否插了旗子
	if i > 0 and j > 0:
		if not chess_lock[i - 1][j - 1]:
			k += 1
	if i > 0:
		if not chess_lock[i - 1][j]:
			k += 1
	if i > 0 and j < Global.width - 1:
		if not chess_lock[i - 1][j + 1]:
			k += 1
	if j < Global.width - 1:
		if not chess_lock[i][j + 1]:
			k += 1
	if i < Global.height - 1 and j < Global.width - 1:
		if not chess_lock[i + 1][j + 1]:
			k += 1
	if i < Global.height - 1:
		if not chess_lock[i + 1][j]:
			k += 1
	if j > 0:
		if not chess_lock[i][j - 1]:
			k += 1
	if i < Global.height - 1 and j > 0:
		if not chess_lock[i + 1][j - 1]:
			k += 1
	# 如果格子本身的数字小于或者等于周围插旗子的数字，则开启
	if cc <= k:
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

# 点击数字
func _on_any_label_gui_input(event: InputEvent, i: int, j: int):
	# 首先还是要判断一次是否已经判断了输赢
	if not is_lock:
		if event is InputEventMouseButton and event.is_pressed():
			# 标签只有右键（执行开启周围8个格子）
			if event.button_index == 2:
				_on_any_label_step(i, j)

# 点击按钮
func _on_any_button_gui_input(event: InputEvent, i: int, j: int):
	# 首先判断一次是否已经判断了输赢
	if not is_lock:
		if event is InputEventMouseButton and event.is_pressed():
			# 左键，执行on_any_button_pressed
			if event.button_index == 1:
				_on_any_button_step(i, j)
			# 右键，为按钮标旗子~
			elif event.button_index == 2:
				_on_any_button_flag(i, j)

# 标记旗子
func _on_any_button_flag(i: int, j: int):
	if scene_button[i][j] != null:
		if flag > 0:
			if chess_lock[i][j]:
				scene_button[i][j].text = "🚩"
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
	scene_label[i][j].text = str(chess[i][j]) if chess[i][j] > 0 else "" if chess[i][j] == 0 else "💣"
	match chess[i][j]:
		1:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 128, 255))
		2:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 128, 0))
		3:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(192, 0, 0))
		4:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 0, 96))
		5:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(128, 0, 48))
		6:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(0, 96, 96))
		7:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(10, 10, 10))
		8:
			scene_label[i][j].add_theme_color_override("font_color", color_int_to_float(100, 100, 100))
		_:
			pass

# 任意一个按钮点击
func _on_any_button_step(i: int, j: int):
	# 当点击第一个按钮时，埋雷并且初始化chess，为is_start赋值为true。
	if not is_start:
		is_start = true
		# 埋雷，并且重复执行本步骤，直到点击的位置不是有雷时。
		while true:
			# 用一个变量接收种子。如果传入的Global.seed等于0，则返回值就是新种子。
			# 无需m、n变量，这里已经是一个while true函数。
			var gl = _rand_mine(Global.seed)
			# 如果未设置初始种子，并且
			if Global.seed == 0:
				if chess[i][j] == -1:
					continue
			Global.seed = gl
			$CurrentSeedLabel.text = "当前种子：\n" + str(gl)
			break
		# 将chess赋值
		_reload_array()
	if chess_lock[i][j] and scene_button[i][j] != null:
		# 移除覆盖在上面的按钮
		remove_child(scene_button[i][j])
		scene_button[i][j].queue_free()
		scene_button[i][j] = null;
		# 显示当前数字
		show_number(i, j)
		# 如果踩到雷
		if chess[i][j] == -1:
			is_lock = true
			$LabelWin.add_theme_color_override("font_color", color_int_to_float(255, 0, 0))
			$LabelWin.text = "你输了~"
			# 遍历输出所有的雷
			for k in range(Global.height):
				for l in range(Global.width):
					if scene_button[k][l] != null and chess[k][l] == -1:
						show_number(k, l)
						remove_child(scene_button[k][l])
						scene_button[k][l].queue_free()
						scene_button[k][l] = null;
			# 将踩到的雷背景标红
			var normal = StyleBoxFlat.new()
			normal.border_width_top = 1
			normal.border_width_right = 1
			normal.border_width_left = 1
			normal.border_width_bottom = 1
			normal.border_color = color_int_to_float(10, 10, 10)
			normal.bg_color = color_int_to_float(200, 0, 0)
			scene_label[i][j].add_theme_stylebox_override("normal", normal)
			judge_save_record()
			# 返回函数
			return
		mine += 1
		Global.score += 10
		$LabelScore.text = "分数：" + str(Global.score)
		if mine >= Global.width * Global.height - Global.mine:
			is_lock = true
			$LabelWin.add_theme_color_override("font_color", color_int_to_float(0, 255, 0))
			$LabelWin.text = "你赢了~"
			judge_save_record()
			return
		# 如果走到空格，则递归调用八、五、三次本函数以翻开周围8个格子。
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
	Global.height = 9
	Global.width = 9
	Global.score = 0
	Global.second = 60
	Global.seed = 0
