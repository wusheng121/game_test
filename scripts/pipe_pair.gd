# ============================================================
# pipe_pair.gd - 管道对脚本
# Step 3：滚动 + 出屏销毁 + 碰撞检测
# ============================================================
# 挂在 PipePair 场景的根节点（Node2D）上。
# Step 2：滚动 + 销毁
# Step 3 新增：
#   - 子节点 TopPipe/BottomPipe 改为 Area2D（带 CollisionShape2D）
#   - 玩家撞入管道时，Area2D.body_entered 信号触发
#   - 本脚本把信号转发为自定义信号 player_hit
#   - main.gd 监听 player_hit 来触发 Game Over

extends Node2D

# === 自定义信号 ===
# 玩家撞到管道时发出，由 main.gd 监听。
# signal 关键字定义的信号，可被外部用 .connect() 连接。
signal player_hit

# === 滚动参数 ===
# 滚动速度（像素/秒）。负值表示向左移动。
const SCROLL_SPEED: float = -200.0

# 销毁阈值：PipePair 的 X 坐标小于此值时，已离开屏幕左侧，可销毁。
const DESPAWN_X: float = -100.0


func _ready() -> void:
	# 把本管道加入 "pipes" 组，方便 main.gd 一键停止所有管道滚动。
	# 组（Group）是 Godot 跨节点查找的轻量机制，比层层 get_parent() 灵活。
	add_to_group("pipes")

	# 连接子节点 Area2D 的 body_entered 信号到本地处理函数。
	# $TopPipe 是 get_node("TopPipe") 的简写。
	# .body_entered 是 Area2D 的内置信号（PhysicsBody2D 进入区域时发出）。
	# .connect(目标函数) 把信号连到本脚本的 _on_pipe_body_entered。
	$TopPipe.body_entered.connect(_on_pipe_body_entered)
	$BottomPipe.body_entered.connect(_on_pipe_body_entered)


func _process(delta: float) -> void:
	# 向左滚动
	position.x += SCROLL_SPEED * delta

	# 出屏销毁
	if position.x < DESPAWN_X:
		queue_free()


# Area2D.body_entered 信号的回调函数。
# 信号会自动传入参数 body（进入区域的 PhysicsBody2D，在我们的场景里就是玩家）。
func _on_pipe_body_entered(body: Node2D) -> void:
	# 用名字判断是不是玩家（简单粗暴，但够用）。
	# 更正规的做法：把玩家加入 "player" 组，用 body.is_in_group("player") 判断。
	if body.name == "Player":
		# 发出自定义信号 player_hit，让 main.gd 处理 Game Over。
		# emit() 是 Godot 4 触发信号的方法（Godot 3 用 emit_signal("name")）。
		player_hit.emit()
