# 未来改进路线（详细笔记）

记录 Flappy Clone 后续可选的改进方向。**当前未实现，仅作笔记备查**。

完成所有 Step 1-5 后，按推荐优先级顺序做即可。

---

## 1. 把 ColorRect / Polygon2D 占位符换成 PNG

### 概述
现在玩家用 `Polygon2D` 画黄色方块、管道用 `Polygon2D` 画绿色方块。
生产环境应该用 `Sprite2D + PNG 图片`。

### 步骤
1. 把 `player.png` 放到 `assets/gfx/player.png`
2. 在 `scenes/player.tscn` 删除 `Sprite` (Polygon2D) 子节点
3. 添加 `Sprite2D` 子节点（替代 Polygon2D 位置）
4. 拖 PNG 到 Sprite2D 的 `Texture` 属性
5. `CollisionShape2D` 保持不变（RectangleShape2D 32x32 照旧）

### 注意
- `CollisionShape2D` 不必和图片完全吻合，近似即可
- PNG 透明背景部分不会渲染，所以可以是任意形状（不必是方块）

---

## 2. 像素图与不规则形状

### 概述
像素图只是低分辨率位图，尺寸和形状自由，**不必须是正方形**。

### 关键概念
- 像素图本质是 PNG（位图），只是分辨率低（16x16 / 32x32）
- PNG 文件本身是矩形（如 32x24），但图内可画任意形状
- 不画的区域透明（PNG alpha 通道）
- CollisionShape2D 是近似的，不需要画多精确

### 碰撞形状选择
| 形状 | 适合 |
|------|------|
| RectangleShape2D | 方块类角色 |
| CircleShape2D | 球 / 圆形 |
| CapsuleShape2D | 立式人形 |
| CollisionPolygon2D | 不规则，自己画顶点（性能差，慎用） |

### 结论
Flappy Bird 用 32x32 RectangleShape2D 足够。玩家不会注意 1-2 像素偏差。

---

## 3. Player 动态效果（跳跃动作等）

### 三种方案

#### A. AnimatedSprite2D + SpriteFrames（推荐 2D）
适合"多帧动画"（扇翅膀、走路、待机）。

1. Aseprite 画 3-5 帧扇翅膀动画
2. 导出为 spritesheet（横向拼接 PNG，如 96x32 = 3 帧）
3. Godot 里把 Sprite2D 替换为 `AnimatedSprite2D`
4. 新建 `SpriteFrames` 资源 → 切片 → 命名动画 "flap"
5. 代码：
   ```gdscript
   @onready var anim: AnimatedSprite2D = $Anim
   func jump():
       velocity.y = JUMP_VELOCITY
       anim.play("flap")
   ```

#### B. AnimationPlayer（更灵活，可动画任何属性）
适合"无美术资源但有动效"：跳跃时 scale.y 压扁回弹（挤压感）。

```gdscript
@onready var anim_player: AnimationPlayer = $AnimPlayer
func jump():
    velocity.y = JUMP_VELOCITY
    anim_player.play("jump_squash")
```

#### C. 代码改 rotation（最简，我们已用过）
```gdscript
var target_rot = -0.4 if velocity.y < 0 else 0.6
rotation = lerp(rotation, target_rot, 0.1)
```

### 典型动画分类
| 动画名 | 帧数 | 触发时机 |
|--------|------|---------|
| idle | 3 帧 | 平时循环 |
| flap | 3 帧 | 跳跃时一次性 |
| fall | 1 帧 | 下落时 |
| dead | 4 帧 | 死亡时 |

### 推荐路径
先用代码版 rotation 练手（已会），再做 Aseprite 帧动画。

---

## 4. 音效制作

### 工具推荐
| 工具 | 价格 | 特点 |
|------|------|------|
| sfxr / jsfxr (https://sfxr.me/) | 免费 | 一键生成 8-bit 音效，3 秒一个 |
| Bfxr | 免费 | sfxr 增强版 |
| Audacity | 免费 | 录音 + 剪辑 |
| Freesound.org | 免费 (CC) | 海量现成音效 |
| Kenney.nl | 免费 | 游戏素材包 |

### 实操：3 分钟做 Flappy Bird 全套音效
打开 jsfxr，按下表操作：

| 音效 | sfxr 预设 | 修改 |
|------|----------|------|
| 跳跃 | "Power up" | 调高频率、缩短衰减 |
| 撞管 | "Hit/hurt" | 加噪声、降调 |
| 加分 | "Pickup/coin" | 直接用 |
| 死亡 | "Explosion" | 拉长衰减 |

每个点 "Mutate" 随机变种，听到满意的 Export WAV。

### Godot 里使用
1. 把 .wav 放到 `assets/sfx/jump.wav`
2. 在 `player.tscn` 加 `AudioStreamPlayer` 子节点，命名 `JumpSfx`
3. 拖 wav 到 Stream 属性
4. 代码：
   ```gdscript
   @onready var jump_sfx: AudioStreamPlayer = $JumpSfx
   func jump():
       velocity.y = JUMP_VELOCITY
       jump_sfx.play()
   ```

### 背景音乐
- Bosca Ceoil（免费傻瓜式 chiptune）
- 或 OpenGameArt 的免费 BGM
- `AudioStreamPlayer` + 勾选 `Autoplay` 循环播放

---

## 5. 导出 exe

### 步骤 1：装 Export Templates（一次性，约 1 GB）
Godot 编辑器 → `Editor → Manage Export Templates → Download from GitHub`
国内下载慢可走代理（127.0.0.1:6384）。

### 步骤 2：配置导出预设
`Project → Export... → Add... → Windows Desktop`
- Export Path: `C:\Users\slient\Desktop\games\flappy-clone\builds\flappy-clone.exe`
- 勾选 Embedded Pck（单文件分发）
- 其他默认

### 步骤 3：导出
**编辑器内**：Export 窗口 → `Export Project`（调试）或 `Export All`（发布）

**命令行**：
```powershell
godot --path C:\Users\slient\Desktop\games\flappy-clone `
      --export-release "Windows Desktop" `
      C:\Users\slient\Desktop\games\flappy-clone\builds\flappy-clone.exe
```

### 产物
```
builds\
└── flappy-clone.exe   (约 40-60 MB，可直接双击运行)
```
不需装 Godot，可发给朋友玩。

### 其他平台
| 平台 | 模板 | 注意 |
|------|------|------|
| Windows | .exe | 主推 |
| Linux | 二进制 | 跨发行版 |
| macOS | .app | 需苹果签名 |
| Web | .html + .wasm | 浏览器直接玩 |
| Android | .apk | 需 SDK |
| iOS | .ipa | 需 macOS + 苹果账号 |

---

## 6. 像素小鸟制作

### 工具推荐：Aseprite（25 美元买断）
免费替代：
- LibreSprite（Aseprite 老版本开源分支）
- Piskel（Web 端，免费）
- Pixie（VSCode 插件，凑合）

### 制作流程（Aseprite）

#### Step 1：新建文件
- File → New
- Size: `32 x 32`
- Color Mode: RGB

#### Step 2：选调色板
- 从 https://lospec.com 找 8 色调色板（如 "nostalgia"）
- Aseprite: `View → Palette Options → Load Palette` → 选 .pal 文件

#### Step 3：画第一帧
- 椭圆工具画身体轮廓（黄色 #ffd23f）
- 加喙（橙色三角）
- 加眼睛（1 像素黑点 + 1 像素白点）
- 加翅膀（深黄色，3x5 像素块）

#### Step 4：加帧做扇翅膀动画
- 时间轴 → 新建 Frame 2 → 复制 Frame 1
- 在 Frame 2 把翅膀往上移 1 像素
- 新建 Frame 3 → 翅膀往下移 1 像素
- 播放看效果（默认 8 fps 太快，改 4 fps）

#### Step 5：导出
**A. Spritesheet**（Godot 用这个）：
- `File → Export → Save As → sprite.png`
- 勾选 "Horizontal" 拼接
- 结果：96x32 PNG（3 帧横排）

**B. Animated GIF / WebP**：用于预览，Godot 不直接用

### 学习资源
- YouTube: **MortMort** — 像素画基础
- YouTube: **Saint11** — 像素画动画原理（强烈推荐）
- lospec.com — 调色板 + 教程聚合
- OpenGameArt.org — 免费参考图

### 速成路径（5 天）
1. **第一天**：装 Aseprite，画 32x32 静态小鸟（不动画）
2. **第二天**：加 3 帧扇翅膀动画
3. **第三天**：导出 PNG，替换到 Godot 项目，跑通
4. **第四天**：画管道（绿色矩形 + 黑边）+ 云朵
5. **第五天**：加音效，导出 .exe 发给朋友

---

## 推荐执行顺序

| 优先级 | 任务 | 工具 | 收益 |
|--------|------|------|------|
| 高 | 装 Aseprite + 画静态小鸟 | Aseprite | 替换 ColorRect，视觉质变 |
| 高 | 加跳跃 / 撞管 / 加分音效 | jsfxr + AudioStreamPlayer | 听觉质变 |
| 中 | 加扇翅膀动画 | AnimatedSprite2D + SpriteFrames | 动态感 |
| 中 | 画管道 + 云朵 | Aseprite | 场景完整 |
| 低 | 导出 .exe | Godot Export Templates | 可分发 |

**5 小时左右能全部做完**，效果会翻天覆地。

---

## 其他可选改进（非美术 / 音效类）

- 改死亡动画：用 Tween 做 Camera2D 屏幕震动（替代 rotation 翻滚）
- 加暂停：`get_tree().paused = true` + process_mode = ALWAYS
- 难度递增：随分数提高 SCROLL_SPEED（动态难度）
- 加 ParticleTrails / 粒子效果（跳跃尾迹）
- 用 TileMap 画地面 + 云朵背景（替代 ColorRect）
