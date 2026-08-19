# ============================================================
# pipe_pair.gd - 管道对脚本
# Step 4：滚动 + 销毁 + 碰撞 + 计分检测
# ============================================================
# 挂在 PipePair 场景的根节点（Node2D）上。
# Step 2：滚动 + 销毁
# Step 3：碰撞检测（body_entered → player_hit）
# Step 4 新增：
#   - PassDetector Area2D 检测玩家穿过缺口
#   - 穿过时发出 player_passed 信号，main.gd 加分
#   - 与 player_hit 互斥：玩家要么撞管（死），要么穿过（加分）

extends Node2D

# === 自定义信号 ===
# 玩家撞到管道时发出（Step 3）。
signal player_hit

# 玩家穿过缺口时发出（Step 4 新增）。
signal player_passed

# === 滚动参数 ===
const SCROLL_SPEED: float = -200.0
const DESPAWN_X: float = -100.0


func _ready() -> void:
	add_to_group("pipes")
	# 撞管检测（Step 3）
	$TopPipe.body_entered.connect(_on_pipe_body_entered)
	$BottomPipe.body_entered.connect(_on_pipe_body_entered)
	# 计分检测（Step 4 新增）
	# PassDetector 是缺口中央的细长 Area2D
	$PassDetector.body_entered.connect(_on_pass_detector_body_entered)


func _process(delta: float) -> void:
	position.x += SCROLL_SPEED * delta
	if position.x < DESPAWN_X:
		queue_free()


# 玩家撞管道 → 发出 player_hit
func _on_pipe_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_hit.emit()


# 玩家穿过缺口 → 发出 player_passed
func _on_pass_detector_body_entered(body: Node2D) -> void:
	if body.name == "Player":
		player_passed.emit()
