# 测试

## 当前状态

当前仅包含默认 Flutter 脚手架留下的 `test/widget_test.dart`，尚未编写实际项目测试。以下为推荐的测试策略和编写指南。

## 运行测试

```bash
# Flutter 测试
flutter test                        # 运行所有 test/ 下的测试
flutter test test/widget_test.dart  # 运行单个文件
flutter test --coverage             # 生成覆盖率报告

# 后端测试（待建）
cd app && bun test                  # 目前报 "Error: no test specified"
```

## 测试结构建议

```
test/
├── widget_test.dart                     # 现有：默认 Counter 测试（待替换）
├── core/
│   └── api_client_test.dart             # Dio 拦截器、Token 注入、401 处理
├── features/
│   ├── auth/
│   │   └── auth_provider_test.dart      # TokenNotifier / AuthNotifier 状态变化
│   ├── timetable/
│   │   ├── timetable_provider_test.dart # 课表列表/详情 Provider
│   │   └── timetable_home_page_test.dart # 周视图/日视图/空状态/宽屏渲染
│   └── import/
│       └── import_provider_test.dart    # 导入流程 Provider
│
├── app/
│   └── app_router_test.dart             # GoRouter 认证守卫测试
│
└── helpers/
    ├── pump_app.dart                    # 测试用 ProviderScope 包装器
    └── mock_repositories.dart           # Mock Repository 工厂
```

建议测试文件 10-15 个，目标覆盖率 > 60%。

## 编写测试

### 测试环境准备

由于 `main.dart` 中 `ProviderScope` 需要覆盖多个 Provider，创建 `test/helpers/pump_app.dart`：

```dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule/main.dart';
import 'package:shared_preferences/shared_preferences.dart';

Widget pumpApp({
  String? initialToken,
  required SharedPreferences prefs,
}) {
  return ProviderScope(
    overrides: [
      sharedPreferencesProvider.overrideWithValue(prefs),
      secureStorageProvider.overrideWithValue(
        const FlutterSecureStorage(
          aOptions: AndroidOptions(encryptedSharedPreferences: true),
        ),
      ),
      initialTokenProvider.overrideWithValue(initialToken),
    ],
    child: const MyApp(),
  );
}
```

### Widget 测试模式

```dart
void main() {
  testWidgets('显示"暂无课表"当没有导入课表时', (tester) async {
    SharedPreferences.setMockInitialValues({});

    await tester.pumpWidget(
      pumpApp(prefs: await SharedPreferences.getInstance()),
      // 需要手动设置 token 以跳过登录守卫
    );
    await tester.pumpAndSettle();

    expect(find.text('暂无课表，请导入'), findsOneWidget);
    expect(find.text('去导入'), findsOneWidget);
  });
}
```

### Provider 单元测试

不需要 Widget，直接测试 StateNotifier：

```dart
import 'package:flutter_test/flutter_test.dart';
import 'package:schedule/features/auth/application/auth_provider.dart';

void main() {
  test('TokenNotifier setToken 后清除旧 SharedPreferences key', () async {
    SharedPreferences.setMockInitialValues({'jwt_token': 'old_token'});
    final prefs = await SharedPreferences.getInstance();

    // 由于 FlutterSecureStorage 无法在测试中 mock，
    // 建议把 TokenNotifier 重构为可注入存储接口
  });
}
```

### Provider 测试建议

由于 `FlutterSecureStorage` 在测试环境中需要 Android/iOS 原生插件（不可用），建议重构 `TokenNotifier`：

```dart
// 增加抽象接口
abstract class TokenStorage {
  Future<String?> read(String key);
  Future<void> write(String key, String value);
  Future<void> delete(String key);
}

// 生产实现使用 FlutterSecureStorage
class SecureTokenStorage implements TokenStorage { ... }

// 测试用内存实现
class InMemoryTokenStorage implements TokenStorage {
  final _store = <String, String>{};
  ...
}
```

或使用测试环境直接 mock SharedPreferences（项目已有双存储回退逻辑）：

```dart
// TokenNotifier 现在的行为：
// 写：_secureStorage.write + _prefs.remove
// 读：_secureStorage.read → 不存在则从 _prefs 读取并迁移

// 测试时设置 SharedPreferences mock 初始值，模拟旧版 token
SharedPreferences.setMockInitialValues({'jwt_token': 'test_token_hex'});
```

### GoRouter 认证守卫测试

```dart
testWidgets('未登录时重定向到 /login', (tester) async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();

  await tester.pumpWidget(pumpApp(initialToken: null, prefs: prefs));
  await tester.pumpAndSettle();

  // 应该显示登录页面
  expect(find.text('登录'), findsWidgets);
});
```

## 推荐测试优先级

### 第一优先：认证流程

```text
test/features/auth/auth_provider_test.dart
  - TokenNotifier.setToken: 写入后 state 变化
  - TokenNotifier.clearToken: 清除后 state = null
  - AuthNotifier.login: 成功 → state = AsyncData
  - AuthNotifier.login: 401 → state = AsyncError('用户名或密码错误')
  - AuthNotifier.logout: 清除 token + user + 离线缓存
```

### 第二优先：课程表页面

```text
test/features/timetable/timetable_home_page_test.dart
  - 空状态：显示"暂无课表"
  - 周视图：7 列星期头 + 时间列 + 12 行课程格子
  - 日视图：仅 1 列
  - 课程卡片点击：弹出详情对话框
  - 宽屏模式：显示 WeatherCard 侧栏
  - 加载中状态：CircularProgressIndicator
  - 错误状态：重试按钮
```

### 第三优先：导入页面

```text
test/features/import/import_page_test.dart
  - URL 输入验证
  - 学校选择下拉
  - 验证码显示
  - 表单提交 loading 状态
```

### 第四优先：路由守卫

```text
test/app/app_router_test.dart
  - 无 token → / → 重定向到 /login
  - 有 token + /login → 重定向到 /
  - 有 token + / → 显示 TimetableHomePage
```

## API 测试

后端 API 可使用 **Bruno** 或 **curl** 脚本手动测试：

```bash
# 健康检查
curl http://localhost:3001/api/health

# 注册
curl -X POST http://localhost:3001/api/auth/register \
  -H 'Content-Type: application/json' \
  -d '{"username":"test","password":"123456"}'

# 登录
curl -X POST http://localhost:3001/api/auth/login \
  -H 'Content-Type: application/json' \
  -d '{"username":"test","password":"123456"}'
# → 复制 token

# 获取课表
curl http://localhost:3001/api/timetables \
  -H 'Authorization: Bearer <token>'
```

建议在 `bruno/` 目录中建立 collection：

```text
bruno/
├── 00-Health.bru
├── 01-Auth/
│   ├── Register.bru
│   └── Login.bru
├── 02-Timetable/
│   ├── List.bru
│   ├── Detail.bru
│   ├── WeekView.bru
│   └── DayView.bru
├── 03-Import/
│   ├── URL-Import.bru
│   └── JWC-Captcha.bru
├── 04-Source/
│   └── List+Sync.bru
└── 05-Admin/
    ├── UserList.bru
    ├── CreateUser.bru
    └── DeleteUser.bru
```

## 覆盖率目标

| 模块 | 目标 | 说明 |
|------|------|------|
| `auth_provider.dart` | > 80% | 认证逻辑集中，容易测 |
| `app_router.dart` | > 80% | 路由守卫逻辑简单 |
| `api_client.dart` | > 60% | Dio 拦截器 |
| `timetable_home_page.dart` | > 60% | 核心 UI，维度多 |
| `import_page.dart` | > 50% | 表单交互 |
| 其他 widget | > 40% | 展示型页面 |
| `*_repository.dart` | > 70% | Mock Dio 即可 |
| 领域模型 (freezed) | 100% | 自动生成，JSON 序列化 |

## 后端测试

后端暂无测试框架配置。建议添加：

```bash
cd app && bun add -d @types/bun
```

在 `app/src/` 下创建 `__tests__/`：

```typescript
// app/src/__tests__/timetable.test.ts
import { describe, it, expect } from 'bun:test'

describe('TimetableService', () => {
  it('getWeekNumber returns correct week', () => {
    // 直接测试 private 方法需要改为 public 或用反射
  })
})
```

运行：

```bash
cd app && bun test
```
