# ============================================================
# pipe_pair.gd - 管道对脚本
# Step 2：滚动 + 出屏销毁
# ============================================================
# 挂在 PipePair 场景的根节点（Node2D）上。
# Step 2 只负责：
#   1) 每帧把自己向左移动
#   2) 出屏后调用 queue_free() 自我销毁
# Step 3 才会加碰撞检测（用 Area2D + body_entered 信号）

extends Node2D

# === 滚动参数 ===
# 滚动速度（像素/秒）。负值表示向左移动。
# 想让游戏更难？把数值改成更负的（如 -400），管道飞得更快。
const SCROLL_SPEED: float = -200.0

# 销毁阈值：当 PipePair 的 X 坐标小于这个值时，
# 说明已经完全离开屏幕左侧，可以销毁回收内存。
# -100 给个缓冲，避免视觉上"突然消失"。
const DESPAWN_X: float = -100.0


# _process 是 Godot 的"渲染帧"回调，每渲染帧调用一次。
# 为什么用 _process 而不是 _physics_process？
#   - 管道滚动是纯视觉移动，不涉及物理碰撞响应
#   - 用 _process 让移动更顺滑（不受固定物理帧率 60Hz 限制）
#   - 但要用 delta 累加，否则不同帧率速度不一致
func _process(delta: float) -> void:
	# 1) 向左移动
	#    position 是 Node2D 内置 Vector2 属性
	position.x += SCROLL_SPEED * delta

	# 2) 出屏检测 + 销毁
	#    queue_free() 是 Godot 的"安全销毁"：
	#      - 不会立即销毁，而是排队到帧末统一处理
	#      - 避免在迭代过程中销毁节点导致崩溃
	#    这是 Godot 处理"动态生成/销毁"的标准做法
	if position.x < DESPAWN_X:
		queue_free()
