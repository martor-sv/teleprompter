# PromptSmart Pro 提词器 (Teleprompter App)

一款使用 Flutter 构建的高端跨平台智能提词器应用，模仿并增强了著名提词软件 PromptSmart Pro 的核心体验。支持 macOS、Windows、iOS 和 Android 平台。

![Flutter](https://img.shields.io/badge/Flutter-3.38.3-blue.svg)
![Platform](https://img.shields.io/badge/Platform-macOS%20%7C%20Windows%20%7C%20iOS%20%7C%20Android-brightgreen.svg)
![License](https://img.shields.io/badge/License-MIT-orange.svg)

---

## 🌟 核心特性 (Key Features)

- 🎙️ **Smart Scroll (智能语音追踪)**：基于系统原生语音识别引擎，自动随发言者的语速与语气实时同步推进台词进度。
- ⚡ **时间驱动自动滚动 (Auto Scroll)**：提供微调级别的滚动速度设置（WPM/像素级流畅滚动），在无麦克风权限或静音模式下无缝降级使用。
- 🪞 **硬件级镜像翻转 (Hardware Mirroring)**：支持水平镜像（Horizontal Mirror）与垂直镜像翻转，完美兼容物理提词器光学透镜折射设备。
- ⌨️ **物理键盘与翻页笔控制 (Keyboard Controls)**：
  - `↑` / `↓` 方向键：单次点击微调台词位置，长按触发平滑缓动连续滚动。
  - `Space` 空格键：一键快捷播放 / 暂停。
  - 可在全局偏好中自由调整按键步进距离（30px ~ 250px）。
- 📝 **剧本持久化管理 (Script Management)**：支持演说稿件的新建、编辑、格式化与本地 JSON 持久化存储。内置实时字数统计与一键清空功能。
- 🎨 **现代化极致 UI**：采用现代深邃夜蓝与极简暗黑系配色（Dark Mode），提供视口焦点高亮引导线与启动倒计时功能，全方位保障演讲专注度。

---

## 📱 平台支持与系统要求

| 平台 | 最低版本要求 | 备注 |
| :--- | :--- | :--- |
| **macOS** | macOS 11.0 (Big Sur) 或更高版本 | 已配置 entitlements 麦克风与语音识别权限 |
| **iOS** | iOS 13.0 或更高版本 | 支持 iPhone / iPad 提词模式 |
| **Windows** | Windows 10/11 | 兼容 x64 桌面环境 |
| **Android** | Android 5.0 (API Level 21) 或更高 | 兼容安卓平板与手机 |

---

## 🛠️ 技术栈 (Tech Stack)

- **核心框架**: [Flutter](https://flutter.dev) (Dart 3)
- **状态管理**: [Provider](https://pub.dev/packages/provider)
- **语音识别**: [speech_to_text](https://pub.dev/packages/speech_to_text)
- **本地存储**: [path_provider](https://pub.dev/packages/path_provider) + [shared_preferences](https://pub.dev/packages/shared_preferences)
- **国际化/时间格式**: [intl](https://pub.dev/packages/intl)

---

## 📂 项目结构 (Project Structure)

```text
提示词 app/
├── lib/
│   ├── main.dart                 # 应用入口与全局主题初始化
│   ├── models/
│   │   └── script_model.dart     # 演说台词实体数据模型
│   ├── providers/
│   │   ├── prompter_controller.dart # 滚动定时器、平滑缓动算法与 Smart Scroll 逻辑
│   │   ├── script_provider.dart     # 剧本增删改查状态管理
│   │   └── settings_provider.dart   # 字体大小、速度、镜像、键盘步幅等偏好配置
│   ├── screens/
│   │   ├── edit_script_screen.dart # 剧本编辑器视口
│   │   ├── home_screen.dart        # 剧本卡片列表主主页与全局设置弹窗
│   │   └── prompter_screen.dart    # 全屏提词器视口与悬浮 HUD 控制面板
│   └── services/
│       └── storage_service.dart    # 本地 JSON 文件持久化读写服务
├── macos/                        # macOS 原生平台工程与 Podfile
├── ios/                          # iOS 原生平台工程与 Podfile
└── pubspec.yaml                  # 项目依赖与配置定义
```

---

## 🚀 快速开始 (Getting Started)

### 1. 克隆项目 (Clone Repository)

```bash
git clone https://github.com/your-username/teleprompter-app.git
cd "teleprompter-app/提示词 app"
```

### 2. 获取依赖 (Get Packages)

```bash
flutter pub get
```

### 3. 运行项目 (Run Application)

- **运行在 macOS 桌面端**：
  ```bash
  flutter run -d macos
  ```
- **运行在 Windows 桌面端**：
  ```bash
  flutter run -d windows
  ```
- **运行在移动端** (连接设备或启动模拟器)：
  ```bash
  flutter run
  ```

---

## 💡 键盘快捷键指南 (Shortcuts)

在提词全屏界面下，支持以下快捷键操作：

| 快捷键 | 功能说明 |
| :--- | :--- |
| `Space` (空格键) | 播放 / 暂停提词器 |
| `↑` (上方向键) | 向上微调台词 (长按平滑向上滚动) |
| `↓` (下方向键) | 向下微调台词 (长按平滑向下滚动) |

---

## 📄 开源许可证 (License)

本项目采用 [MIT License](LICENSE) 许可证开源。开源共享，欢迎贡献 PR 与 Issue！
