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
- 重力 + 跳跃（空格 / 上箭头）
- 主场景背景 + 提示文字

### 后续 Step 路线图

- [ ] Step 2：管道滚动 + 循环生成（学习 Timer、Area2D、节点复制）
- [ ] Step 3：碰撞检测 + Game Over 状态（学习信号 body_entered、状态机）
- [ ] Step 4：分数 + UI（学习 Label、CanvasLayer、信号通信）
- [ ] Step 5：重新开始（学习 reload_current_scene）

## 项目结构

```
flappy-clone/
├── project.godot          # Godot 项目配置
├── icon.svg               # 项目图标
├── .gitignore
├── README.md
├── scenes/                # 场景文件（.tscn）
│   ├── main.tscn          # 主场景（游戏入口）
│   └── player.tscn        # 玩家场景
├── scripts/               # GDScript 脚本（.gd）
│   ├── main.gd            # 主场景脚本
│   └── player.gd          # 玩家脚本（重力 + 跳跃）
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
| 空格 / 上箭头 / 回车 | 跳跃 |

## 学到的概念

- **Node（节点）**：Godot 的基本构成单元
- **Scene（场景）**：节点的组合，可被实例化
- **CharacterBody2D**：可控物理角色节点
- **velocity + move_and_slide()**：移动的标准范式
- **Input.is_action_just_pressed**：输入检测
- **_physics_process(delta)**：物理帧回调
- **Polygon2D**：用顶点数组画多边形
- **@onready + $NodeName**：节点引用

## 下一步建议

完成 Step 1 后，建议你做这几件事，巩固理解：

1. **改参数试试**：在 `player.gd` 里把 `GRAVITY` 改成 `800`、`JUMP_VELOCITY` 改成 `-380`，感受不同手感
2. **加旋转**：让小鸟跳跃时抬头、下落时低头（用 `rotation` 属性 + `lerp_angle`）
3. **改成 @export**：把 const 改成 `@export var`，在 Inspector 面板调参
4. **看日志**：运行后观察 Output 面板里的 `[Main] _ready` 输出

---

学习来源：
- [Godot 官方文档](https://docs.godotengine.org/en/4.7/)
- [Godot Step by Step 教程](https://docs.godotengine.org/en/4.7/getting_started/step_by_step/index.html)
