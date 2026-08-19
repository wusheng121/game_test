# ============================================================
# player.gd - 小鸟脚本
# Step 1：重力 + 跳跃
# ============================================================
# 这个脚本挂在 Player 场景的根节点（CharacterBody2D）上。
# CharacterBody2D 是 Godot 为"可控角色"设计的物理节点：
#   - 自带 velocity（速度）属性
#   - 自带 move_and_slide() 方法（处理碰撞与滑动）
#   - 不受物理引擎推动，完全由你的代码控制

extends CharacterBody2D

# === 物理常量 ===
# 注意：常量（const）在编译期确定，无法在编辑器调参。
# 如果你想边玩边调数值，把 const 改成 @export var：
#   @export var gravity: float = 1200.0
# 这样在 Inspector 面板就能直接拖动数值实时测试。

# 重力加速度（单位：像素/秒²）。
# Godot 4 的 2D 没有全局重力（那是 RigidBody2D 的概念），
# 所以 CharacterBody2D 的重力需要我们手写。
const GRAVITY: float = 1200.0

# 跳跃瞬时速度（单位：像素/秒）。
# 由于 Y 轴向下为正方向，"向上跳"必须给负值。
# 数值越大跳得越猛。
const JUMP_VELOCITY: float = -450.0

# 天花板 Y 坐标（屏幕顶部）。玩家中心 y 不会低于此值。
# 注意：这里只 clamp 位置，不触发 Game Over（与地板不同，撞天花板不死）。
const CEILING_Y: float = 0.0


# _physics_process 是 Godot 的"物理帧"回调。
# 与 _process（每渲染帧调用）不同，_physics_process 在固定时间步长上调用
# （默认 60 次/秒），适合做物理相关的逻辑。
# 参数 delta 是上一帧的耗时（秒），用它累加速度可以保证
# 在不同帧率下游戏速度一致。
func _physics_process(delta: float) -> void:
	# 1) 累加重力 → 让小鸟下落
	#    velocity 是 CharacterBody2D 的内置 Vector2 属性
	#    每帧把重力累加到 Y 分量上
	velocity.y += GRAVITY * delta

	# 2) 检测跳跃输入
	#    Input.is_action_just_pressed(action_name) 返回 true 的条件：
	#    "玩家在本帧按下了该动作对应的键"，只在按下的那一帧触发，
	#    长按不会重复触发。
	#
	#    jump 是我们在 Project Settings → Input Map 自定义的输入动作，
	#    已绑定 鼠标左键 + 空格。
	#    想改键位？直接在 Input Map 里增删事件，无需改代码。
	if Input.is_action_just_pressed("jump"):
		# 直接覆盖 Y 速度，制造"瞬间上跳"效果
		velocity.y = JUMP_VELOCITY

	# 3) 应用移动
	#    move_and_slide() 会：
	#      a) 按 velocity 移动节点
	#      b) 遇到碰撞时沿表面滑动（不卡死）
	#      c) 自动用 delta 做帧率无关处理
	#    它内部读取 velocity 属性，所以前面修改 velocity 就够了。
	move_and_slide()

	# 4) 天花板边界（clamp，不死亡）
	#    玩家上跳过高时，position.y 可能小于 0（飞出屏幕顶部）。
	#    这里把位置硬性拉回 0，并把向上的速度清零，防止"卡在天花板抖动"。
	#    与地板不同：撞天花板只挡住，不算 Game Over。
	if position.y < CEILING_Y:
		position.y = CEILING_Y
		if velocity.y < 0:
			velocity.y = 0
