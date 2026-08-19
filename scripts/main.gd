# ============================================================
# main.gd - 主场景脚本
# Step 2：管道循环生成
# ============================================================
# 主场景 main.tscn 是游戏启动后加载的第一个场景。
# 这个脚本挂在根节点 Main（Node2D）上，负责：
#   Step 1：作为容器，引用 Player
#   Step 2：定时生成管道（每 2 秒一个，缺口位置随机）
#   Step 3：监听碰撞 → 切换到 Game Over 状态（待实现）
#   Step 5：重新开始（待实现）

extends Node2D

# === 资源预加载 ===
# preload() 在编译期把场景文件加载进内存，返回 PackedScene 对象。
# 比运行时 load() 快很多，适合这种"会反复实例化"的资源。
# 注意路径必须以 res:// 开头（res:// 是项目根目录）。
const PIPE_SCENE: PackedScene = preload("res://scenes/pipe_pair.tscn")

# === 生成参数 ===
# 两次管道生成之间的间隔（秒）。值越小越难。
const PIPE_SPAWN_INTERVAL: float = 2.0

# 管道生成的 X 坐标（屏幕右边界 1280 + 100 缓冲）。
# 这样管道出现时还在屏幕外，玩家不会看到"突然冒出来"。
const PIPE_SPAWN_X: float = 1280.0 + 100.0

# 缺口中心的 Y 坐标范围（屏幕高 720）。
# 限制在 [200, 520] 让缺口不会贴顶或贴底。
const GAP_Y_MIN: float = 200.0
const GAP_Y_MAX: float = 520.0


# === 节点引用 ===
# @onready 表示"节点进入场景树后立即赋值"。
# $Player 是 get_node("Player") 的简写，等同于场景树中名为 Player 的子节点。
# 类型标注 : CharacterBody2D 让编辑器自动补全更智能。
@onready var player: CharacterBody2D = $Player


# === 内部状态 ===
# 自定义计时器：每帧累加 delta，达到 PIPE_SPAWN_INTERVAL 时生成管道并归零。
# 也可以用 Godot 内置的 Timer 节点，但手写更便于理解原理。
var _spawn_timer: float = 0.0


func _ready() -> void:
	# _ready 在节点进入场景树时调用一次（场景启动时）。
	# 这里打印日志，验证脚本正确加载。
	# 在 Godot 编辑器里运行游戏后，看底部的 Output 面板能看到这些日志。
	print("[Main] _ready - 游戏开始！")
	print("[Main] 玩家初始位置：", player.position)


func _process(delta: float) -> void:
	# 累加计时器
	_spawn_timer += delta

	# 达到生成间隔 → 生成管道 + 归零
	if _spawn_timer >= PIPE_SPAWN_INTERVAL:
		_spawn_timer = 0.0
		_spawn_pipe()


# 生成一个管道对，放在屏幕右侧，缺口 Y 随机
# 函数名前缀 _ 表示"私有方法"（GDScript 惯例，不强制）
func _spawn_pipe() -> void:
	# instantiate() 创建 PackedScene 的一个新实例（Node 对象）
	# 此时实例还没加入场景树，不会被渲染或处理
	var pipe: Node2D = PIPE_SCENE.instantiate()

	# 设置位置：X 在屏幕右侧外，Y 在合理范围内随机
	# randf_range(min, max) 返回 [min, max] 之间的随机 float
	pipe.position = Vector2(PIPE_SPAWN_X, randf_range(GAP_Y_MIN, GAP_Y_MAX))

	# add_child() 把节点挂到当前节点下，加入场景树
	# 节点一旦加入场景树，其 _ready/_process 等回调就会被触发
	add_child(pipe)
