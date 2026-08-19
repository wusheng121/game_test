# Flappy Clone

我的第一款 Godot 游戏 —— Flappy Bird 复刻学习项目。

## 引擎与版本

- **引擎**：Godot 4.7.2 Stable (Standard)
- **语言**：GDScript
- **渲染**：GL Compatibility (OpenGL)
- **目标**：PC (Windows)

## 当前进度

### Step 1 ✅ 已完成
- 项目骨架搭建
- Player 场景（CharacterBody2D + Polygon2D 黄方块）
- 重力 + 跳跃（鼠标左键 / 空格）
- 主场景背景 + 提示文字
- 自定义输入动作 `jump`（Input Map 配置）

### Step 2 ✅ 已完成
- PipePair 场景（上管道 + 下管道 + 缺口）
- 管道循环滚动 + 出屏销毁（queue_free）
- 主场景定时生成管道 + 随机缺口位置

### Step 3 ✅ 已完成
- 管道改为 Area2D（带 CollisionShape2D）
- 玩家撞管检测（body_entered 信号）
- 撞地板检测（Game Over）
- 天花板边界 clamp（不死，仅挡住玩家）
- Game Over 状态机（停止生成 / 停止滚动 / 停止玩家物理）
- Game Over UI + 按键重启（reload_current_scene）

### Step 4 ✅ 已完成
- PassDetector Area2D（位于缺口中央，检测玩家穿过）
- 自定义信号 player_passed（与 player_hit 互斥）
- 分数管理（_score 变量 + ScoreLabel 显示）
- CanvasLayer 独立 UI 层（UILayer）
- Game Over UI 动态显示最终得分（字符串格式化 %d）

### Step 5 ✅ 已完成
- 三态状态机（MENU / PLAYING / GAME_OVER，用 enum + match）
- 启动菜单（TitleLabel，按跳跃键开始游戏）
- 最高分持久化（FileAccess 读写 `user://highscore.txt`）
- 死亡旋转动画（player.is_dead + rotation 累加）
- Game Over UI 延迟显示（0.6s 让死亡动画可见）
- HighScoreLabel 顶部右侧显示历史最高分
- 多 UI 共存（Title / Score / HighScore / GameOver 各司其职）

## 项目结构

```
flappy-clone/
├── project.godot          # Godot 项目配置（含 jump 输入动作）
├── icon.svg               # 项目图标
├── .gitignore
├── README.md
├── scenes/                # 场景文件（.tscn）
│   ├── main.tscn          # 主场景（含 UILayer: Score/HighScore/Title）
│   ├── player.tscn        # 玩家场景
│   └── pipe_pair.tscn     # 管道对场景（Area2D + PassDetector）
├── scripts/               # GDScript 脚本（.gd）
│   ├── main.gd            # 主场景脚本（状态机 + 高分 + 生成）
│   ├── player.gd          # 玩家脚本（重力 + 跳跃 + 死亡动画）
│   └── pipe_pair.gd       # 管道对脚本（滚动 + 碰撞 + 计分信号）
└── assets/                # 美术/音效资源（暂空）
```

## 运行方式

### 方式一：用 Godot 编辑器（推荐）
1. 双击 `C:\Users\slient\Desktop\games\godot\Godot_v4.7.2-stable_win64.exe`
2. 选择 "Import" → 浏览到本目录 → 选择 `project.godot` → 确认
3. 打开项目后按 **F5**（运行）或 **F6**（运行当前场景）

### 方式二：命令行
```powershell
cd C:\Users\slient\Desktop\games\flappy-clone
godot  # 打开编辑器（已加入 PATH）
# 或直接运行：
godot --path .  # 打开项目
```

## 操作

| 按键 | 动作 |
|------|------|
| 鼠标左键 / 空格 | 开始游戏 / 跳跃 / 重新开始 |

## 学到的概念

### Step 1
- **Node（节点）**：Godot 的基本构成单元
- **Scene（场景）**：节点的组合，可被实例化
- **CharacterBody2D**：可控物理角色节点
- **velocity + move_and_slide()**：移动的标准范式
- **Input.is_action_just_pressed**：输入检测
- **_physics_process(delta)**：物理帧回调
- **Polygon2D**：用顶点数组画多边形
- **@onready + $NodeName**：节点引用
- **Input Map**：自定义输入动作 + 多按键绑定

### Step 2
- **PackedScene + preload() + instantiate()**：场景实例化范式
- **add_child()**：动态添加节点到场景树
- **_process(delta)**：渲染帧回调（适合非物理逻辑）
- **queue_free()**：安全销毁节点
- **randf_range()**：随机数生成
- **自定义计时器模式**：用累加变量做计时

### Step 3
- **Area2D + CollisionShape2D**：触发区域 + 碰撞形状
- **body_entered 信号**：PhysicsBody2D 进入区域时触发
- **signal + emit() + connect()**：自定义信号通信
- **节点组（Group）**：跨节点查找机制
- **状态机模式**：用 _is_game_over 标志切换行为
- **set_process(false) / set_physics_process(false)**：动态启停节点
- **get_tree().reload_current_scene()**：场景重载
- **Label 多行文本**：text 属性支持换行
- **天花板 clamp**：position 边界限制（不死）

### Step 4
- **多信号设计**：player_hit + player_passed 互斥
- **CanvasLayer**：独立 UI 层（不随世界变换）
- **字符串格式化**：`"得分：%d" % score`（printf 风格）
- **动态 UI 更新**：运行时改 Label.text
- **Area2D 多用途**：同一节点家族同时用于碰撞 + 计分

### Step 5
- **enum + match 状态机**：清晰的多状态切换（MENU/PLAYING/GAME_OVER）
- **FileAccess + user://**：持久化数据到用户目录
- **节点状态外部控制**：player.is_dead 由 main.gd 设置
- **延迟 UI 显示**：用计时器变量控制时序（让死亡动画可见）
- **多 UI 共存**：TitleLabel / ScoreLabel / HighScoreLabel / GameOverUI 各司其职
- **方法暴露**：player.gd 暴露 jump() 供外部调用

## 下一步建议

完成 Step 5 后，建议你做这几件事巩固理解：

1. **改死亡动画**：让玩家死亡时屏幕震动（用 Tween 改 Camera2D offset）而不是旋转
2. **加音效**：跳跃 sfx、撞管 sfx、加分 sfx、背景音乐（用 AudioStreamPlayer）
3. **像素美术**：用 Aseprite 画小鸟、管道、云朵替换 ColorRect
4. **导出 .exe**：用 Export Templates 打包发给朋友玩（无需装 Godot）
5. **加暂停**：按 P 键暂停游戏（用 `get_tree().paused = true` + process_mode）
6. **加难度递增**：随分数提高 SCROLL_SPEED（动态难度）
7. **观察高分存档**：运行游戏后到 `%APPDATA%/Godot/app_userdata/Flappy Clone/` 看 highscore.txt

---

学习来源：
- [Godot 官方文档](https://docs.godotengine.org/en/4.7/)
- [Godot Step by Step 教程](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/index.html)
- [Godot 信号教程](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html)
- [Godot UI 教程](https://docs.godotengine.org/en/4.7/tutorials/ui/index.html)
- [Godot 保存游戏](https://docs.godotengine.org/en/4.7/tutorials/io/saving_games.html)
