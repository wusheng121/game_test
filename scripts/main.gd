# ============================================================
# main.gd - 主场景脚本
# Step 4：分数系统 + UI 层
# ============================================================
# 主场景 main.tscn 是游戏启动后加载的第一个场景。
# 这个脚本挂在根节点 Main（Node2D）上，负责：
#   Step 1：作为容器，引用 Player
#   Step 2：定时生成管道
#   Step 3：监听碰撞 + Game Over 状态机 + 简单重启
#   Step 4：分数管理 + ScoreLabel + Game Over 显示最终得分

extends Node2D

# === 资源预加载 ===
const PIPE_SCENE: PackedScene = preload("res://scenes/pipe_pair.tscn")

# === 生成参数 ===
const PIPE_SPAWN_INTERVAL: float = 2.0
const PIPE_SPAWN_X: float = 1280.0 + 100.0
const GAP_Y_MIN: float = 200.0
const GAP_Y_MAX: float = 520.0

# === 边界（地板碰撞）===
# 屏幕高 720。玩家中心 y 超过 FLOOR_Y = 撞地板 → Game Over。
# 注意：天花板由 player.gd 内部 clamp 位置，不算死亡（玩家撞顶不死）。
const FLOOR_Y: float = 720.0


# === 节点引用 ===
@onready var player: CharacterBody2D = $Player
@onready var game_over_ui: Label = $GameOverUI
@onready var score_label: Label = $UILayer/ScoreLabel


# === 状态 ===
var _spawn_timer: float = 0.0
var _is_game_over: bool = false
var _score: int = 0   # Step 4 新增：当前得分


func _ready() -> void:
	print("[Main] _ready - 游戏开始！")
	print("[Main] 玩家初始位置：", player.position)
	game_over_ui.visible = false
	_update_score_label()  # 初始化分数显示为 "0"


func _process(delta: float) -> void:
	# === Game Over 状态：只处理重启输入 ===
	if _is_game_over:
		if Input.is_action_just_pressed("jump"):
			get_tree().reload_current_scene()
		return

	# === 正常游戏状态 ===
	_spawn_timer += delta
	if _spawn_timer >= PIPE_SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_pipe()

	if player.position.y > FLOOR_Y:
		_trigger_game_over()


func _spawn_pipe() -> void:
	var pipe: Node2D = PIPE_SCENE.instantiate()
	pipe.position = Vector2(PIPE_SPAWN_X, randf_range(GAP_Y_MIN, GAP_Y_MAX))

	# 连接管道的两个信号：
	#   - player_hit：撞管 → Game Over（Step 3）
	#   - player_passed：穿过缺口 → 加分（Step 4 新增）
	pipe.player_hit.connect(_on_pipe_player_hit)
	pipe.player_passed.connect(_on_pipe_player_passed)

	add_child(pipe)


# 玩家撞到管道（Step 3）
func _on_pipe_player_hit() -> void:
	_trigger_game_over()


# 玩家穿过缺口（Step 4 新增）
func _on_pipe_player_passed() -> void:
	# Game Over 后不再加分（防止死后还计分）
	if _is_game_over:
		return
	_score += 1
	_update_score_label()
	print("[Main] 得分：", _score)


# 更新 ScoreLabel 显示
func _update_score_label() -> void:
	# str() 把 int 转成字符串（GDScript 不会自动转换类型）
	score_label.text = str(_score)


# 触发 Game Over 状态
func _trigger_game_over() -> void:
	if _is_game_over:
		return
	_is_game_over = true

	print("[Main] Game Over! 最终得分：", _score)

	# 停止玩家物理
	player.set_physics_process(false)

	# 停止所有管道滚动
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_process(false)

	# 动态更新 GameOverUI 文本，显示最终得分
	# %d 是 GDScript 的格式化占位符（类似 C 的 printf）
	# \n 是换行符
	game_over_ui.text = "Game Over!\n得分：%d\n按 空格 / 鼠标左键 重新开始" % _score
	game_over_ui.visible = true
