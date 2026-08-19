# ============================================================
# main.gd - 主场景脚本
# Step 1：场景容器
# ============================================================
# 主场景 main.tscn 是游戏启动后加载的第一个场景。
# 这个脚本挂在根节点 Main（Node2D）上，负责：
#   Step 1：作为容器，引用 Player
#   Step 2：定时生成管道（PipeSpawner）
#   Step 3：监听碰撞 → 切换到 Game Over 状态
#   Step 5：重新开始

extends Node2D

# @onready 表示"节点进入场景树后立即赋值"。
# $Player 是 get_node("Player") 的简写，等同于场景树中名为 Player 的子节点。
# 类型标注 : CharacterBody2D 让编辑器自动补全更智能。
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	# _ready 在节点进入场景树时调用一次（场景启动时）。
	# 这里只是打印日志，验证脚本正确加载。
	# 在 Godot 编辑器里运行游戏后，看底部的 Output 面板能看到这些日志。
	print("[Main] _ready - 游戏开始！")
	print("[Main] 玩家初始位置：", player.position)


# 在 Step 1 中不需要每帧逻辑，所以暂时没有 _process / _physics_process。
# 后续 Step 会在这里加入管道生成、碰撞检测等。
