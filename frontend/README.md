# 前端 - 奶茶点单 AI Agent

基于 **Vite + React + TypeScript + Tailwind CSS** 构建的现代化前端应用。

## 🚀 快速开始

### 安装依赖

```bash
npm install
# 或
yarn install
# 或
pnpm install
```

### 开发模式

```bash
npm run dev
```

访问 http://localhost:3000 查看应用。

### 生产构建

```bash
npm run build
```

构建产物将生成在 `dist/` 目录。

### 预览生产构建

```bash
npm run preview
```

## 📦 技术栈

- **⚡ Vite** - 下一代前端构建工具
- **⚛️ React 18** - UI 库
- **📘 TypeScript** - 类型安全的 JavaScript
- **🎨 Tailwind CSS** - 实用优先的 CSS 框架
- **🎭 Lucide React** - 现代化图标库

## 📁 项目结构

```
src/
├── components/          # React 组件
│   ├── ChatContainer.tsx    # 聊天消息容器
│   ├── Message.tsx          # 消息组件
│   ├── ModeSelector.tsx     # 模式选择器
│   ├── OrderInfo.tsx        # 订单信息展示
│   ├── ProductionBoard.tsx  # 排队面板（展示所有订单状态）
│   ├── TextInput.tsx        # 文本输入
│   ├── VoiceInput.tsx       # 语音输入
│   └── ProgressAgent.tsx    # 制作进度助手
├── hooks/              # 自定义 Hooks
│   └── useAudioRecorder.ts  # 音频录制
├── services/           # API 服务
│   ├── api.ts              # API 调用
│   └── utils.ts            # 工具函数
├── types/              # TypeScript 类型
│   └── index.ts
├── App.tsx             # 主应用组件
├── main.tsx            # 应用入口
└── index.css           # 全局样式
```

## 🎨 组件说明

### App.tsx

主应用组件，负责：
- 管理全局状态（消息、订单状态）
- 处理文本/语音输入
- 与后端 API 通信
- 会话管理

### ChatContainer.tsx

聊天消息容器，特性：
- 自动滚动到最新消息
- 消息列表渲染
- 响应式高度

### Message.tsx

单条消息组件：
- 区分用户/AI 消息样式
- 支持多行文本
- 优雅的气泡设计

### ModeSelector.tsx

输入模式切换器：
- 文字模式
- 语音模式
- 平滑过渡动画

### TextInput.tsx

文本输入组件：
- Enter 键发送
- 发送按钮
- 加载状态禁用

### VoiceInput.tsx

语音输入组件：
- 录音按钮（带动画）
- 文件上传支持
- 麦克风权限处理
- 错误提示

### OrderInfo.tsx

订单信息展示：
- 动态显示已收集信息
- 美观的布局
- 空状态隐藏

## 🔧 自定义 Hooks

### useAudioRecorder

音频录制 Hook：

```typescript
const { isRecording, error, toggleRecording } = useAudioRecorder();

// 开始/停止录音
const audioBlob = await toggleRecording();
```

特性：
- 管理 MediaRecorder 状态
- 处理音轨清理
- 错误处理
- 返回 Blob 数据

## 🌐 API 服务

### ApiService

封装所有后端 API 调用：

```typescript
// 发送文本
await ApiService.sendText(sessionId, text);

// 实时语音识别通过 WebSocket
// 详见 VoiceInput 组件实现 (ws://host/ws/stt)

// 重置会话
await ApiService.resetSession(sessionId);

// 获取订单
await ApiService.getOrder(orderId);
```

## ⚙️ 配置

### 环境变量

创建 `.env` 文件：

```env
VITE_API_URL=http://localhost:8000
VITE_MODEL_BADGE="OpenRouter · Llama 3.3 70B"
```

### Vite 配置

`vite.config.ts` 包含：
- React 插件
- 开发服务器配置
- API 代理配置

### Tailwind 配置

`tailwind.config.js` 包含：
- 自定义颜色（primary、secondary）
- 自定义动画
- 响应式断点

### TypeScript 配置

`tsconfig.json` 包含：
- 严格类型检查
- React JSX 支持
- 模块解析配置

## 🎨 样式系统

### Tailwind CSS

使用 Tailwind 实用类：

```tsx
<div className="flex items-center justify-center">
  <button className="bg-primary-500 hover:bg-primary-600 text-white">
    按钮
  </button>
</div>
```

### 自定义主题

在 `tailwind.config.js` 中定义：

```javascript
colors: {
  primary: {
    500: '#667eea',
    600: '#5568d3',
    // ...
  }
}
```

## 🐛 调试

### 开发者工具

- React DevTools
- TypeScript 类型检查
- Vite HMR（热模块替换）

### 常见问题

#### CORS 错误

确保后端 CORS 配置正确：

```python
# backend/main.py
app.add_middleware(
    CORSMiddleware,
    allow_origins=["http://localhost:3000"],
    # ...
)
```

#### 语音录音不工作

- 检查浏览器支持
- 确认麦克风权限
- 使用 HTTPS 或 localhost

## 📝 开发规范

### 代码风格

- 使用 TypeScript 严格模式
- 组件使用函数式组件
- Hooks 规范命名（use 前缀）
- Props 定义明确的 interface

### 命名规范

- 组件：PascalCase
- Hooks：camelCase（use 前缀）
- 工具函数：camelCase
- 类型：PascalCase

### 目录组织

- 按功能分组（components、hooks、services）
- 单一职责原则
- 可复用组件独立文件

## 🚀 部署

### 构建

```bash
npm run build
```

### 静态托管

构建产物可部署到：
- Vercel
- Netlify
- GitHub Pages
- 任何静态文件服务器

### 环境变量

生产环境设置：

```env
VITE_API_URL=https://api.yourdomain.com
```

## 📄 许可证

MIT License
