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

### 后续 Step 路线图

- [ ] Step 4：分数 + UI（学习 Label、CanvasLayer、信号通信）
- [ ] Step 5：完善重新开始（菜单 + 动画 + 最高分记录）

## 项目结构

```
flappy-clone/
├── project.godot          # Godot 项目配置（含 jump 输入动作）
├── icon.svg               # 项目图标
├── .gitignore
├── README.md
├── scenes/                # 场景文件（.tscn）
│   ├── main.tscn          # 主场景（含 GameOverUI）
│   ├── player.tscn        # 玩家场景
│   └── pipe_pair.tscn     # 管道对场景（Area2D + 碰撞）
├── scripts/               # GDScript 脚本（.gd）
│   ├── main.gd            # 主场景脚本（生成 + Game Over 状态机）
│   ├── player.gd          # 玩家脚本（重力 + 跳跃）
│   └── pipe_pair.gd       # 管道对脚本（滚动 + 碰撞信号）
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
| 鼠标左键 / 空格 | 跳跃 |
| 游戏结束后：鼠标左键 / 空格 | 重新开始 |

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

## 下一步建议

完成 Step 3 后，建议你做这几件事巩固理解：

1. **改 Game Over 文案**：在 `main.tscn` 的 GameOverUI 节点改 text 属性
2. **加分数提示**：在玩家通过管道时加分（为 Step 4 做准备）
3. **改碰撞响应**：撞管后让小鸟旋转下坠（在 player.gd 加 rotation 动画）
4. **观察信号**：在 `_on_pipe_body_entered` 加 print，观察信号触发时机
5. **测试边界**：故意撞天花板 / 撞地板 / 撞管道，验证 Game Over 触发

---

学习来源：
- [Godot 官方文档](https://docs.godotengine.org/en/4.7/)
- [Godot Step by Step 教程](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/index.html)
- [Godot 信号教程](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/signals.html)
