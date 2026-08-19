# ============================================================
# main.gd - 主场景脚本
# Step 5：完善重启（启动菜单 + 死亡动画 + 最高分持久化）
# ============================================================
# 主场景 main.tscn 是游戏启动后加载的第一个场景。
# 这个脚本挂在根节点 Main（Node2D）上，负责：
#   Step 1：作为容器，引用 Player
#   Step 2：定时生成管道
#   Step 3：监听碰撞 + Game Over
#   Step 4：分数系统 + UI 层
#   Step 5：三态状态机 + 最高分持久化 + 死亡动画 + 启动菜单

extends Node2D

# === 状态机（Step 5 新增）===
# 用 enum + match 替代之前的 _is_game_over 单 flag
# 三态清晰互斥，便于扩展（如未来加 PAUSE 状态）
enum State { MENU, PLAYING, GAME_OVER }
var _state: State = State.MENU

# === 资源 ===
const PIPE_SCENE: PackedScene = preload("res://scenes/pipe_pair.tscn")
# 最高分存档路径。user:// 是 Godot 的"用户数据目录"，
# 在 Windows 上是 %APPDATA%/Godot/app_userdata/<项目名>/
const HIGHSCORE_PATH: String = "user://highscore.txt"

# === 生成参数 ===
const PIPE_SPAWN_INTERVAL: float = 2.0
const PIPE_SPAWN_X: float = 1280.0 + 100.0
const GAP_Y_MIN: float = 200.0
const GAP_Y_MAX: float = 520.0

# === 边界 ===
const FLOOR_Y: float = 720.0

# === Game Over UI 延迟 ===
# 死亡后等 0.6 秒再显示 UI，让玩家看到死亡动画（旋转下坠）。
const GAME_OVER_UI_DELAY: float = 0.6


# === 节点引用 ===
@onready var player: CharacterBody2D = $Player
@onready var game_over_ui: Label = $GameOverUI
@onready var score_label: Label = $UILayer/ScoreLabel
@onready var title_label: Label = $UILayer/TitleLabel
@onready var highscore_label: Label = $UILayer/HighScoreLabel


# === 状态 ===
var _spawn_timer: float = 0.0
var _score: int = 0
var _high_score: int = 0
# Game Over UI 延迟计时器（>0 表示还在等动画，<=0 表示 UI 已显示）
var _game_over_delay: float = 0.0


func _ready() -> void:
	print("[Main] _ready - 游戏开始！")
	print("[Main] 玩家初始位置：", player.position)

	# 加载最高分（从 user://highscore.txt）
	_high_score = _load_high_score()
	print("[Main] 历史最高分：", _high_score)

	# 初始化 UI
	_update_score_label()
	_update_highscore_label()
	game_over_ui.visible = false

	# MENU 状态：禁用玩家物理（让小鸟悬停在初始位置）
	# 注意：is_dead 必须为 false（防止死亡旋转逻辑误触发）
	player.set_physics_process(false)
	player.is_dead = false


func _process(delta: float) -> void:
	# 用 match 实现状态机分发（比 if/else 链更清晰）
	match _state:
		State.MENU:
			_process_menu()
		State.PLAYING:
			_process_playing(delta)
		State.GAME_OVER:
			_process_game_over(delta)


# === MENU 状态：等待玩家按跳跃键开始游戏 ===
func _process_menu() -> void:
	if Input.is_action_just_pressed("jump"):
		_start_game()


# === PLAYING 状态：正常游戏逻辑 ===
func _process_playing(delta: float) -> void:
	# 1) 累加计时器 + 生成管道
	_spawn_timer += delta
	if _spawn_timer >= PIPE_SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_pipe()

	# 2) 检测地板碰撞
	if player.position.y > FLOOR_Y:
		_trigger_game_over()


# === GAME_OVER 状态：等待死亡动画 → 显示 UI → 等待重启 ===
func _process_game_over(delta: float) -> void:
	# 阶段 1：还在等死亡动画播完（_game_over_delay > 0）
	if _game_over_delay > 0.0:
		_game_over_delay -= delta
		if _game_over_delay <= 0.0:
			_show_game_over_ui()
		return  # 动画期间不响应重启输入

	# 阶段 2：UI 已显示，等待玩家按跳跃键重启
	if Input.is_action_just_pressed("jump"):
		get_tree().reload_current_scene()


# 从 MENU 切换到 PLAYING
func _start_game() -> void:
	_state = State.PLAYING
	title_label.visible = false  # 隐藏标题
	# 启用玩家物理（开始下落 + 跳跃响应）
	player.set_physics_process(true)
	# 让首次按键也产生跳跃（因为 set_physics_process 在下一物理帧才生效，
	# 同帧内的 is_action_just_pressed 不会触发 player.gd 的 jump 逻辑）
	player.jump()


func _spawn_pipe() -> void:
	var pipe: Node2D = PIPE_SCENE.instantiate()
	pipe.position = Vector2(PIPE_SPAWN_X, randf_range(GAP_Y_MIN, GAP_Y_MAX))
	pipe.player_hit.connect(_on_pipe_player_hit)
	pipe.player_passed.connect(_on_pipe_player_passed)
	add_child(pipe)


# 玩家撞到管道（仅 PLAYING 状态响应，防止 GAME_OVER 后重复触发）
func _on_pipe_player_hit() -> void:
	if _state == State.PLAYING:
		_trigger_game_over()


# 玩家穿过缺口（仅 PLAYING 状态加分）
func _on_pipe_player_passed() -> void:
	if _state != State.PLAYING:
		return
	_score += 1
	_update_score_label()
	print("[Main] 得分：", _score)


# 触发 Game Over 状态
func _trigger_game_over() -> void:
	# 防御：只接受 PLAYING → GAME_OVER 转换
	if _state != State.PLAYING:
		return
	_state = State.GAME_OVER

	print("[Main] Game Over! 最终得分：", _score)

	# 更新最高分（如有新纪录则持久化）
	if _score > _high_score:
		_high_score = _score
		_save_high_score(_high_score)
		_update_highscore_label()
		print("[Main] 新最高分：", _high_score)

	# 启动死亡动画：玩家继续物理 + 旋转
	player.is_dead = true

	# 停止所有管道滚动（但玩家继续下坠）
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_process(false)

	# 延迟显示 Game Over UI，让死亡动画可见
	_game_over_delay = GAME_OVER_UI_DELAY


# 显示 Game Over UI（在 _game_over_delay 倒计时结束后调用）
func _show_game_over_ui() -> void:
	# 用格式化字符串嵌入分数和最高分
	# %d = int 占位符；多个占位符用 % [val1, val2] 语法
	game_over_ui.text = "Game Over!\n得分：%d\n最高分：%d\n按 空格 / 鼠标左键 重新开始" % [_score, _high_score]
	game_over_ui.visible = true


func _update_score_label() -> void:
	score_label.text = str(_score)


func _update_highscore_label() -> void:
	highscore_label.text = "最高分：%d" % _high_score


# === 最高分持久化 ===
# FileAccess 是 Godot 的文件读写类。
# user:// 路径是项目专属的用户数据目录，跨平台一致。
# 文件不存在时 FileAccess.open 返回 null，需判空。
func _load_high_score() -> int:
	var file = FileAccess.open(HIGHSCORE_PATH, FileAccess.READ)
	if file == null:
		return 0  # 第一次玩 / 文件被删，返回 0
	var content = file.get_as_text().strip_edges()
	file.close()
	# int("") 会报错，先判空
	if content.is_empty():
		return 0
	return int(content)


func _save_high_score(score: int) -> void:
	var file = FileAccess.open(HIGHSCORE_PATH, FileAccess.WRITE)
	if file == null:
		push_warning("[Main] 无法保存最高分到 " + HIGHSCORE_PATH)
		return
	file.store_string(str(score))
	file.close()
