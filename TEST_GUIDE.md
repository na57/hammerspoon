# API调用失败场景测试指南

## 测试目标
验证在所有API调用失败场景下，不再弹出输入对话框，同时确保其他错误处理机制正常运行。

## 测试步骤

### 1. 加载测试模块
在Hammerspoon控制台中执行以下命令：

```lua
local testCalendar = require("test_calendar_api_failure")
```

### 2. 运行所有测试
在Hammerspoon控制台中执行以下命令：

```lua
testCalendar.runAllTests()
```

### 3. 验证结果

#### 预期行为：
- ✅ 所有测试都应该显示错误提示（通过`hs.alert.show`）
- ✅ 所有测试都不应该弹出输入对话框（`hs.dialog.textPrompt`）
- ✅ Hammerspoon控制台应该输出详细的调试日志

#### 测试场景：
1. **API密钥未配置** - 应显示"请先在config.lua中配置OpenAI API密钥"
2. **无效的API密钥** - 应显示"API调用失败，状态码：401"
3. **无效的API URL** - 应显示网络错误提示
4. **正常的API调用** - 应成功创建事件或显示错误提示

## 代码修改摘要

### 修改的文件：
1. `calendar.lua` - 移除了API调用失败时的输入对话框代码
2. `test_calendar_api_failure.lua` - 新增测试脚本

### 具体修改：
- 移除了第316-332行的输入对话框代码（`hs.dialog.textPrompt`）
- 保留了所有错误日志记录（`print`语句）
- 保留了所有用户友好提示（`hs.alert.show`）
- 添加了测试专用函数`calendar.testProcessText()`用于测试

## 验证要点

### 1. 错误日志记录
检查Hammerspoon控制台输出，确认以下日志存在：
- `[调试] API请求状态码: xxx`
- `[调试] API响应内容: xxx`
- `[调试] 解析API响应成功/失败`
- `[调试] API请求超时`

### 2. 用户友好提示
确认以下提示通过`hs.alert.show`显示：
- "请先在config.lua中配置OpenAI API密钥"
- "API调用失败，状态码：xxx"
- "API调用超时，请重试"
- "无法解析API响应"
- "API返回格式错误"

### 3. 输入对话框
确认在所有测试场景中都没有弹出输入对话框（`hs.dialog.textPrompt`）

## 测试完成确认

- [ ] 所有测试都运行完成
- [ ] 所有测试都显示了错误提示
- [ ] 所有测试都没有弹出输入对话框
- [ ] Hammerspoon控制台输出了详细的调试日志
- [ ] 其他错误处理机制（日志、提示）正常运行

## 注意事项

1. 测试脚本会临时修改配置，测试完成后会自动恢复
2. 如果API密钥未配置，测试4（正常API调用）会被跳过
3. 每个测试之间有短暂间隔，请等待前一个测试完成后再观察结果
4. 测试结果会显示在Hammerspoon控制台中

## 手动测试

除了自动化测试，您还可以手动测试：

### 方法1：使用快捷键
按 `Hyper+C` 触发输入对话框，输入文本后观察：
- 如果API调用失败，应该只显示错误提示
- 不应该弹出第二个输入对话框

### 方法2：直接调用
在Hammerspoon控制台中执行：

```lua
local calendar = require("calendar")
calendar.testProcessText("明天下午3点开会")
```

观察是否有输入对话框弹出。
