# ============================================================
# main.gd - 主场景脚本
# Step 3：碰撞检测 + Game Over 状态机
# ============================================================
# 主场景 main.tscn 是游戏启动后加载的第一个场景。
# 这个脚本挂在根节点 Main（Node2D）上，负责：
#   Step 1：作为容器，引用 Player
#   Step 2：定时生成管道
#   Step 3：监听碰撞 + Game Over 状态机 + 简单重启
#   Step 5：更完善的重启（菜单 + 动画 + 最高分 - 待实现）

extends Node2D

# === 资源预加载 ===
# preload() 在编译期把场景文件加载进内存，返回 PackedScene 对象。
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


# === 状态机 ===
# 简单的两态状态机：
#   - _is_game_over = false：正常游戏（生成管道、玩家物理、滚动）
#   - _is_game_over = true：Game Over（停止一切更新，等待玩家按重启键）
var _spawn_timer: float = 0.0
var _is_game_over: bool = false


func _ready() -> void:
	print("[Main] _ready - 游戏开始！")
	print("[Main] 玩家初始位置：", player.position)
	# GameOverUI 默认隐藏，撞管/撞地板后才显示
	game_over_ui.visible = false


func _process(delta: float) -> void:
	# === Game Over 状态：只处理重启输入 ===
	if _is_game_over:
		# 按跳跃键（鼠标左键 / 空格）重新开始
		# reload_current_scene() 重新加载当前场景，所有状态自动重置
		if Input.is_action_just_pressed("jump"):
			get_tree().reload_current_scene()
		return  # 不再执行下面的逻辑

	# === 正常游戏状态 ===
	# 1) 累加计时器 + 生成管道
	_spawn_timer += delta
	if _spawn_timer >= PIPE_SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_pipe()

	# 2) 检测地板碰撞（天花板由 player.gd clamp，不触发 Game Over）
	if player.position.y > FLOOR_Y:
		_trigger_game_over()


func _spawn_pipe() -> void:
	var pipe: Node2D = PIPE_SCENE.instantiate()
	pipe.position = Vector2(PIPE_SPAWN_X, randf_range(GAP_Y_MIN, GAP_Y_MAX))

	# 连接管道的自定义信号 player_hit 到本脚本的 _on_pipe_player_hit。
	# 这是 Godot 节点间解耦通信的标准方式：
	#   - 管道不需要知道 main.gd 的存在，只负责发出信号
	#   - main.gd 监听信号并做出响应（触发 Game Over）
	pipe.player_hit.connect(_on_pipe_player_hit)

	add_child(pipe)


# 玩家撞到管道时由 pipe_pair.gd 的 player_hit 信号触发
func _on_pipe_player_hit() -> void:
	_trigger_game_over()


# 触发 Game Over 状态。
# 用一个统一的入口函数，避免逻辑分散（撞管 / 撞地板 都走这里）。
func _trigger_game_over() -> void:
	# 防止重复触发（玩家可能同时撞管+撞地板）
	if _is_game_over:
		return
	_is_game_over = true

	print("[Main] Game Over!")

	# 停止玩家物理（不再下落 / 跳跃）
	# set_physics_process(false) 让 _physics_process 不再被调用
	player.set_physics_process(false)

	# 停止所有管道滚动
	# get_nodes_in_group("pipes") 返回所有加入 "pipes" 组的节点
	# set_process(false) 让 _process 不再被调用
	for pipe in get_tree().get_nodes_in_group("pipes"):
		pipe.set_process(false)

	# 显示 Game Over UI
	game_over_ui.visible = true
