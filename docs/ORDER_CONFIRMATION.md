# 订单确认机制详解

## 📋 订单确认流程

系统通过 **三阶段智能对话** 实现订单细节的确认：

---

## 🎯 三个核心阶段

### 阶段 1: 信息收集 (ask_more)
**目标**: 逐步收集订单信息

**特点**:
- AI 每次只问 1-2 个问题，避免用户overwhelm
- 根据已有信息智能询问缺失字段
- 支持用户一次性提供多个信息

**示例对话**:
```
用户: "我要一杯奶茶"
AI:   "好的！请问您想要哪一款呢？我们有乌龙奶茶、茉莉奶绿、红茶拿铁等。"
      [action: "ask_more"]

用户: "乌龙奶茶"
AI:   "好的，乌龙奶茶！请问您要什么杯型？我们有小杯、中杯、大杯。甜度和冰块呢？"
      [action: "ask_more"]

用户: "大杯，三分糖，去冰"
AI:   "好的！为您确认一下：大杯乌龙奶茶，三分糖，去冰。请问需要加料吗？"
      [action: "ask_more"]
```

---

### 阶段 2: 订单复述确认 (confirm)
**目标**: 向用户完整复述订单，等待确认

**触发条件**:
- ✅ 所有必填信息已收集（饮品、杯型、甜度、冰块）
- ✅ order_state.is_complete = true

**特点**:
- 完整复述所有订单细节
- 使用清晰的格式化话术
- 明确询问用户是否确认

**示例对话**:
```
用户: "加珍珠"
AI:   "好的！为您下单：
       - 饮品：大杯乌龙奶茶
       - 甜度：三分糖
       - 冰块：去冰
       - 加料：珍珠

       请问确认下单吗？"
      [action: "confirm"]
```

---

### 阶段 3: 保存订单 (save_order)
**目标**: 确认用户同意后保存订单

**触发条件**:
- 用户说"确认"、"对"、"没错"、"就这样"等肯定词
- 前一轮 action 是 "confirm"

**特点**:
- 保存到数据库
- 返回订单号
- 给出成功提示

**示例对话**:
```
用户: "确认"
AI:   "好的，订单已确认！您的订单是：大杯乌龙奶茶，三分糖，去冰，加珍珠。
       订单号：#1234
       请稍等，马上为您准备！"
      [action: "save_order"]
```

---

## 🔄 完整流程图

```
开始
  │
  ▼
┌─────────────────────┐
│  用户发起对话        │
└──────────┬──────────┘
           │
           ▼
    ┌─────────────┐
    │ 信息完整？   │
    └──┬───────┬──┘
       │      │
      否      是
       │      │
       ▼      ▼
┌──────────┐ ┌──────────────┐
│ ask_more │ │   confirm    │◄─┐
│ 继续询问  │ │ 复述订单确认  │  │ 用户说"不对"
└──────────┘ └──────┬───────┘  │ 或要修改
       │            │          │
       └────────────┤          │
                    ▼          │
              ┌──────────┐    │
              │用户确认？ │────┘
              └────┬─────┘
                   │
                  是
                   │
                   ▼
            ┌─────────────┐
            │ save_order  │
            │ 保存到数据库 │
            └──────┬──────┘
                   │
                   ▼
              返回订单号
                   │
                   ▼
                 结束
```

---

## 🧠 智能判断机制

### LLM Agent 的决策逻辑

系统通过 GPT-4 智能判断当前应该执行哪个 action：

```python
class AgentAction(str, Enum):
    ASK_MORE = "ask_more"      # 继续收集信息
    CONFIRM = "confirm"        # 复述确认
    SAVE_ORDER = "save_order"  # 保存订单
```

### 判断依据

1. **ask_more 的条件**:
   ```python
   - drink_name 为空 → 询问饮品
   - size 为空 → 询问杯型
   - sugar 为空 → 询问甜度
   - ice 为空 → 询问冰块
   - 可选：询问加料、备注
   ```

2. **confirm 的条件**:
   ```python
   - drink_name ✓
   - size ✓
   - sugar ✓
   - ice ✓
   - is_complete = true
   ```

3. **save_order 的条件**:
   ```python
   - 前一轮 action = "confirm"
   - 用户输入 = "确认" / "对" / "没错" / "是的" 等
   ```

---

## 📊 订单状态追踪

### OrderState 数据结构

```json
{
  "drink_name": "乌龙奶茶",    // 必填
  "size": "大杯",             // 必填
  "sugar": "三分糖",          // 必填
  "ice": "去冰",              // 必填
  "toppings": ["珍珠"],       // 可选
  "notes": "不要太烫",        // 可选
  "is_complete": true         // 标记是否完整
}
```

### 状态转换

```
空状态 → 部分信息 → 完整信息 → 已确认 → 已保存
  ↓         ↓          ↓         ↓        ↓
null   drink_name   is_complete  用户确认  order_id
       size         = true
       sugar
       ice
```

---

## 🎭 实际对话示例

### 场景 1: 顺利确认

```
用户: "我要一杯大杯乌龙奶茶，三分糖，去冰，加珍珠"
AI:   "好的！为您下单：大杯乌龙奶茶，三分糖，去冰，加珍珠。
       请问确认下单吗？"
       [状态: confirming, action: confirm]

用户: "确认"
AI:   "好的，订单已确认！订单号：#1234"
       [状态: saved, action: save_order]
```

---

### 场景 2: 修改订单

```
AI:   "为您下单：大杯乌龙奶茶，三分糖，去冰。请问确认下单吗？"
      [状态: confirming]

用户: "等等，我要五分糖"
AI:   "好的，已修改为五分糖。为您确认：大杯乌龙奶茶，五分糖，去冰。
       请问这样可以吗？"
       [状态: confirming，更新订单]

用户: "可以"
AI:   "好的，订单已确认！订单号：#1235"
       [状态: saved]
```

---

### 场景 3: 逐步收集

```
用户: "我要奶茶"
AI:   "好的！请问您想要哪一款呢？我们有乌龙奶茶、茉莉奶绿等。"
      [action: ask_more]

用户: "乌龙"
AI:   "好的，乌龙奶茶！请问杯型、甜度和冰块呢？"
      [action: ask_more]

用户: "中杯"
AI:   "好的，中杯。甜度和冰块呢？"
      [action: ask_more]

用户: "五分糖，少冰"
AI:   "好的！为您确认：中杯乌龙奶茶，五分糖，少冰。需要加料吗？"
      [action: ask_more]

用户: "不用"
AI:   "好的！为您下单：中杯乌龙奶茶，五分糖，少冰。请问确认下单吗？"
      [action: confirm]

用户: "确认"
AI:   "订单已确认！订单号：#1236"
      [action: save_order]
```

---

## 🔍 关键实现细节

### 1. System Prompt 中的确认指令

```python
"""
5. **对话规则**：
   - 当所有必填信息收集齐全时，向顾客总结订单并询问是否确认
   - 顾客确认后，明确表示订单已完成
"""
```

### 2. Action 控制流程

```python
# backend/main.py 中的处理
if agent_response.action == AgentAction.SAVE_ORDER:
    # 保存订单
    order_id = db.save_order(session_id, agent_response.order_state)
    session_manager.update_status(session_id, OrderStatus.SAVED)

elif agent_response.action == AgentAction.CONFIRM:
    # 等待确认
    session_manager.update_status(session_id, OrderStatus.CONFIRMING)

else:
    # 继续收集
    session_manager.update_status(session_id, OrderStatus.COLLECTING)
```

### 3. 前端实时显示

```typescript
// frontend/src/components/OrderInfo.tsx
// 实时显示当前订单状态
{orderState.drink_name && (
  <OrderItem label="饮品" value={orderState.drink_name} />
)}
```

---

## ✨ 确认机制的优势

### 1. 智能判断
- ✅ AI 自动判断信息是否完整
- ✅ 自动进入确认阶段
- ✅ 无需人工编写复杂规则

### 2. 灵活修改
- ✅ 确认阶段可以修改任何字段
- ✅ 重新复述修改后的订单
- ✅ 支持多次修改

### 3. 清晰反馈
- ✅ 完整复述订单细节
- ✅ 明确询问确认
- ✅ 保存后返回订单号

### 4. 用户友好
- ✅ 自然的对话流程
- ✅ 不强制固定顺序
- ✅ 支持一次说多个信息

---

## 🎯 测试场景

### 已通过的测试

```python
# test_integration.py
def test_complete_order_flow():
    """测试完整订单流程"""
    # 1. 发送消息 → collecting
    # 2. 继续对话 → confirming
    # 3. 用户确认 → saved
    # 4. 验证订单号返回
```

---

## 📝 总结

订单确认通过 **三阶段状态机** 实现：

1. **ask_more** - 收集信息（可多轮）
2. **confirm** - 复述确认（可修改）
3. **save_order** - 保存订单（完成）

LLM 智能判断每个阶段的转换，用户体验自然流畅！🎉
