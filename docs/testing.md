# 测试

## 当前状态

后端 **7 项测试**（`bun test`），前端 **10 项测试**（`flutter test`）。测试覆盖认证、解析器、路由守卫和核心 Provider。

## 运行测试

```bash
# Flutter 测试
flutter test                                    # 运行所有 test/ 下的测试
flutter test test/app/app_router_test.dart     # 运行单个文件
flutter test --coverage                         # 生成覆盖率报告

# 后端测试
cd app && bun test                              # 运行所有 __tests__/
cd app && bun test --coverage                   # 覆盖率报告
```

## 测试结构

```
test/
├── helpers/
│   └── secure_storage_mock.dart              # FlutterSecureStorage 平台通道 mock
├── app/
│   └── app_router_test.dart                 # 3 项：未登录重定向、已登录渲染、登录页自动跳转
├── core/
│   └── api_client_test.dart                 # 2 项：端点路径构建、Bearer header 格式
└── features/
    └── auth/
        └── auth_provider_test.dart          # 5 项：TokenNotifier set/clear/initial/migration

app/src/__tests__/
├── helpers/
│   └── db.ts                                # 内存 SQLite 测试夹具（10 张表）
├── auth.test.ts                             # 4 项：JWT 签发、验证、过期、篡改
├── importers.test.ts                        # 7 项：ICS 解析、JSON 解析、边界情况
└── url-validator.test.ts                    # 3 项：URL 解析、协议校验
```

共 **17 项测试**（10 前端 + 7 后端）。

## 编写测试

### Widget 测试 + 认证守卫

```dart
import '../helpers/secure_storage_mock.dart';

void main() {
  setUp(() {
    mockSecureStorageChannel();
  });

  testWidgets('redirects to /login when no token', (tester) async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    await tester.pumpWidget(pumpApp(initialToken: null, prefs: prefs));
    await tester.pumpAndSettle();
    expect(find.text('登录'), findsOneWidget);
  });
}
```

`pumpApp` 定义在 `test/app/app_router_test.dart` 中，直接复用。

### Provider 单元测试

TokenNotifier 通过 `secure_storage_mock.dart` mock 平台通道即可直接测试：

```dart
test('setToken updates state', () async {
  SharedPreferences.setMockInitialValues({});
  final prefs = await SharedPreferences.getInstance();
  final notifier = TokenNotifier(prefs, const FlutterSecureStorage(), null);

  await notifier.setToken('new-token');
  expect(notifier.state, 'new-token');
});
```

### 后端测试（bun test）

```typescript
// 必须在所有 import 之前设置 JWT_SECRET
process.env.JWT_SECRET = 'test-secret-key-64chars-minimum-length'
import { describe, it, expect } from 'bun:test'
import { AuthService } from '../../services/auth.service'

const auth = new AuthService()
// ... test ...
```

数据库测试使用 `helpers/db.ts` 的内存 SQLite 夹具：

```typescript
import { createTestDb, insertTestUser } from './helpers/db'

const { db } = createTestDb()
const userId = insertTestUser(db.sqlite)
// ... 通过 db 操作表并验证 ...
```

## 覆盖率目标

| 模块 | 当前覆盖 | 说明 |
|------|---------|------|
| `auth.service.ts` | ✅ 4 tests | JWT 签发/验证/过期/篡改 |
| `ics.importer.ts` | ✅ 3 tests | 单事件、合并同名课程、空日历 |
| `json.importer.ts` | ✅ 4 tests | 对象/courses 数组/裸数组/默认值填充 |
| `url.validator.ts` | ✅ 3 tests | URL 解析、协议校验 |
| `auth_provider.dart` | ✅ 5 tests | TokenNotifier set/clear/init/migration |
| `app_router.dart` | ✅ 3 tests | 重定向/已登录/登录页跳转 |
| `api_client.dart` | ⚠️ 2 basic tests | 路径构建，未测 Dio 拦截器 |
| 课表 UI widget | ❌ 0 | 需 mock Dio 数据，待补充 |

建议后续优先补充：
- `TimetableService` 数据库集成测试（周视图/日视图过滤）
- 课表主页 widget 测试（空状态/周视图渲染）
- `ImportNotifier` 状态测试（mock repository）
