# ============================================================
# player.gd - 小鸟脚本
# Step 5：重力 + 跳跃 + 天花板 clamp + 死亡旋转动画
# ============================================================
# 这个脚本挂在 Player 场景的根节点（CharacterBody2D）上。
# CharacterBody2D 是 Godot 为"可控角色"设计的物理节点：
#   - 自带 velocity（速度）属性
#   - 自带 move_and_slide() 方法（处理碰撞与滑动）
#   - 不受物理引擎推动，完全由你的代码控制
#
# Step 5 新增：
#   - is_dead 状态标志（由 main.gd 在 Game Over 时设置为 true）
#   - 死亡后启用旋转动画（小鸟翻滚下坠）
#   - 暴露 jump() 方法供 main.gd 调用（用于首次按键触发跳跃）

extends CharacterBody2D

# === 物理常量 ===
# 重力加速度（单位：像素/秒²）。
# Godot 4 的 2D 没有全局重力（那是 RigidBody2D 的概念），
# 所以 CharacterBody2D 的重力需要我们手写。
const GRAVITY: float = 1200.0

# 跳跃瞬时速度（单位：像素/秒）。Y 轴向下为正，"向上跳"必须给负值。
const JUMP_VELOCITY: float = -450.0

# 天花板 Y 坐标（屏幕顶部）。玩家中心 y 不会低于此值。
const CEILING_Y: float = 0.0

# 死亡旋转速度（弧度/秒）。8 rad/s ≈ 458°/s，快速翻滚效果。
const DEATH_ROTATION_SPEED: float = 8.0


# === 状态 ===
# Step 5 新增：死亡标志。
# 由 main.gd 在 _trigger_game_over 时设为 true。
# 死亡后：禁用跳跃、启用旋转下坠动画、跳过天花板 clamp。
var is_dead: bool = false


# _physics_process 是 Godot 的"物理帧"回调。
# 与 _process（每渲染帧调用）不同，_physics_process 在固定时间步长上调用
# （默认 60 次/秒），适合做物理相关的逻辑。
func _physics_process(delta: float) -> void:
	# 1) 累加重力 → 让小鸟下落
	velocity.y += GRAVITY * delta

	if not is_dead:
		# 2a) 检测跳跃输入（仅活着时）
		if Input.is_action_just_pressed("jump"):
			jump()
	else:
		# 2b) 死亡状态：旋转下坠
		rotation += DEATH_ROTATION_SPEED * delta

	# 3) 应用移动
	move_and_slide()

	# 4) 天花板边界（clamp，不死亡）
	#    仅活着时 clamp；死后允许自由下落到屏幕外。
	if not is_dead and position.y < CEILING_Y:
		position.y = CEILING_Y
		if velocity.y < 0:
			velocity.y = 0


# 由 main.gd 调用，触发一次跳跃。
# 用途：玩家在 MENU 状态按跳跃键 → main.gd 调 jump()，
# 避免"第一次按键只用于开始游戏，不产生跳跃"的尴尬。
func jump() -> void:
	velocity.y = JUMP_VELOCITY
