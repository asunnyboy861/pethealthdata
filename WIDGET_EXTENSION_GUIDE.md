# 🎯 Widget Extension 详细配置指南

## 📱 在 Xcode 中添加 Widget Extension

### 第一步：添加 Widget Target

1. **打开项目**
   - 在 Xcode 中打开 `pethealthdata.xcodeproj`

2. **添加 Target**
   - 在项目导航器中，点击项目文件（蓝色图标）
   - 在 TARGETS 列表下方，点击 **+** 按钮
   - 在弹出的对话框中：
     - 搜索 **Widget Extension**
     - 选择 **Widget Extension** 模板
     - 点击 **Next**

3. **配置 Widget**
   - **Product Name**：`PetHealthWidget`
   - **Team**：选择你的开发团队（自动填充）
   - **Bundle Identifier**：`com.zzoutuo.pethealthdata.PetHealthWidget`（自动生成）
   - **Language**：Swift
   - **取消勾选** "Include Configuration Intent"（不需要）
   - **取消勾选** "Include Live Activity"（不需要）
   - 点击 **Finish**

4. **激活 Scheme**
   - 在弹出的对话框中点击 **Activate**

---

## ⚙️ 配置 Widget Target

### 第二步：配置签名和 Capabilities

1. **选择 Widget Target**
   - 在项目导航器中，选择 **PetHealthWidget** target
   - 点击 **Signing & Capabilities** 标签

2. **配置签名**
   - **Automatically manage signing**：勾选
   - **Team**：选择你的开发团队
   - **Bundle Identifier**：`com.zzoutuo.pethealthdata.PetHealthWidget`

3. **添加 Capabilities**（可选）
   - 如果 Widget 需要访问数据，点击 **+ Capability**
   - 搜索并添加 **iCloud**
   - 配置：
     - ✅ **iCloud Documents**：勾选
     - ✅ **CloudKit**：勾选
     - ✅ **Containers**：选择 `iCloud.com.zzoutuo.pethealthdata`

---

## 📁 Widget 文件结构

### 第三步：创建 Widget 文件

添加 Widget Extension 后，Xcode 会自动创建以下文件：

```
PetHealthWidget/
├── PetHealthWidget.swift              # Widget 入口文件
├── PetHealthWidgetBundle.swift         # Bundle 配置
├── Assets.xcassets                  # Widget 资源
├── Info.plist                       # Widget 配置
└── PetHealthWidget.intentdefinition   # Intent 定义（如果启用）
```

---

## 💻 Widget 代码实现

### 第四步：实现 Widget Provider

创建或修改 `PetHealthWidget.swift`：

```swift
import WidgetKit
import SwiftUI
import SwiftData

// Widget 入口
struct PetHealthWidget: Widget {
    let kind: String = "PetHealthWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetHealthProvider()) { entry in
            PetHealthWidgetEntryView(entry: entry)
        }
        .configurationDisplayName("My Pets")
        .description("Quick view of your pets")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

// 时间线条目
struct PetHealthEntry: TimelineEntry {
    let date: Date
    let pets: [Pet]
    let upcomingVaccines: Int
}

// 数据提供者
struct PetHealthProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PetHealthEntry {
        PetHealthEntry(
            date: Date(),
            pets: [],
            upcomingVaccines: 0
        )
    }
    
    func getSnapshot(in context: Context, completion: @escaping (PetHealthEntry) -> ()) {
        Task {
            let entry = await snapshot(for: context)
            completion(entry)
        }
    }
    
    func getTimeline(for configuration: PetHealthIntent, in context: Context) async -> Timeline<PetHealthEntry> {
        let entry = await snapshot(for: context)
        
        // 每 15 分钟更新一次
        let nextUpdate = Calendar.current.date(byAdding: .minute, value: 15, to: Date())!
        
        return Timeline(
            entries: [entry],
            policy: .after(nextUpdate)
        )
    }
    
    func snapshot(for context: Context) async -> PetHealthEntry {
        // 从共享的 ModelContainer 获取数据
        guard let container = try? ModelContainer(
            for: [Pet.self, VaccineRecord.self],
            configurations: []
        ) else {
            return PetHealthEntry(date: Date(), pets: [], upcomingVaccines: 0)
        }
        
        let modelContext = ModelContext(container)
        
        // 获取所有宠物
        let petsDescriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.name)])
        let pets = (try? modelContext.fetch(petsDescriptor)) ?? []
        
        // 计算即将到期的疫苗
        var upcomingCount = 0
        let calendar = Calendar.current
        let thirtyDaysFromNow = calendar.date(byAdding: .day, value: 30, to: Date())!
        
        for pet in pets {
            for vaccine in pet.vaccines {
                if let nextDue = vaccine.nextDueDate,
                   nextDue <= thirtyDaysFromNow && nextDue >= Date() {
                    upcomingCount += 1
                }
            }
        }
        
        return PetHealthEntry(
            date: Date(),
            pets: pets,
            upcomingVaccines: upcomingCount
        )
    }
}

// Widget 视图
struct PetHealthWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.pets.isEmpty {
            emptyStateView
        } else {
            if #available(iOS 17.0, *) {
                if entry.family == .systemSmall {
                    smallWidgetView
                } else {
                    mediumWidgetView
                }
            }
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No pets")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget)
    }
    
    @ViewBuilder
    private var smallWidgetView: some View {
        VStack(alignment: .leading, spacing: 6) {
            if let firstPet = entry.pets.first {
                HStack(spacing: 6) {
                    Image(systemName: firstPet.speciesIcon)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(firstPet.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        if entry.upcomingVaccines > 0 {
                            HStack(spacing: 4) {
                                Image(systemName: "exclamationmark.triangle.fill")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                                
                                Text("\(entry.upcomingVaccines) due")
                                    .font(.caption2)
                                    .foregroundColor(.orange)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget)
    }
    
    @ViewBuilder
    private var mediumWidgetView: some View {
        VStack(alignment: .leading, spacing: 8) {
            HStack {
                Text("My Pets")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(.secondary)
                
                Spacer()
                
                if entry.upcomingVaccines > 0 {
                    HStack(spacing: 4) {
                        Image(systemName: "bell.fill")
                            .font(.caption2)
                            .foregroundColor(.orange)
                        
                        Text("\(entry.upcomingVaccines)")
                            .font(.caption2)
                            .fontWeight(.bold)
                            .foregroundColor(.orange)
                    }
                }
            }
            
            Divider()
            
            VStack(alignment: .leading, spacing: 6) {
                ForEach(Array(entry.pets.prefix(3)), id: \.id) { pet in
                    HStack(spacing: 6) {
                        Image(systemName: pet.speciesIcon)
                            .font(.caption)
                            .foregroundColor(.blue)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            Text(pet.name)
                                .font(.caption)
                                .fontWeight(.semibold)
                                .lineLimit(1)
                            
                            Text(pet.age)
                                .font(.caption2)
                                .foregroundColor(.secondary)
                        }
                    }
                }
                
                if entry.pets.count > 3 {
                    Text("+ \(entry.pets.count - 3) more")
                        .font(.caption2)
                        .foregroundColor(.secondary)
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .containerBackground(for: .widget)
    }
}
```

---

## 🎨 Widget UI 设计

### 第五步：添加 Widget 资源

1. **打开 Assets.xcassets**
   - 在项目导航器中，展开 **PetHealthWidget**
   - 双击 **Assets.xcassets**

2. **添加图标**（可选）
   - 右键点击 → **New Image Set**
   - 命名：`widget-icon`
   - 添加 16x16、32x32、64x64 的图标
   - 支持浅色和深色模式

3. **配置颜色**（可选）
   - 右键点击 → **New Color Set**
   - 添加自定义颜色用于 Widget

---

## ⚙️ 配置 Info.plist

### 第六步：验证 Widget Info.plist

Widget Extension 的 `Info.plist` 应该包含：

```xml
<?xml version="1.0" encoding="UTF-8"?>
<!DOCTYPE plist PUBLIC "-//Apple//DTD PLIST 1.0//EN" "http://www.apple.com/DTDs/PropertyList-1.0.dtd">
<plist version="1.0">
<dict>
    <key>CFBundleDevelopmentRegion</key>
    <string>$(DEVELOPMENT_LANGUAGE)</string>
    <key>CFBundleDisplayName</key>
    <string>PetHealthWidget</string>
    <key>CFBundleExecutable</key>
    <string>$(EXECUTABLE_NAME)</string>
    <key>CFBundleIdentifier</key>
    <string>$(PRODUCT_BUNDLE_IDENTIFIER)</string>
    <key>CFBundleInfoDictionaryVersion</key>
    <string>6.0</string>
    <key>CFBundleName</key>
    <string>$(PRODUCT_NAME)</string>
    <key>CFBundlePackageType</key>
    <string>$(PRODUCT_BUNDLE_PACKAGE_TYPE)</string>
    <key>CFBundleShortVersionString</key>
    <string>1.0</string>
    <key>CFBundleVersion</key>
    <string>1</string>
    <key>NSExtension</key>
    <dict>
        <key>NSExtensionPointIdentifier</key>
        <string>com.apple.widgetkit-extension</string>
    </dict>
</dict>
</plist>
```

---

## 🔗 配置主 App 支持 Widget

### 第七步：更新主 App 的 Info.plist

在主 App（pethealthdata）的 `Info.plist` 中添加：

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

---

## 🧪 测试 Widget

### 第八步：在模拟器中测试

1. **选择 Widget Scheme**
   - 在 Xcode 顶部，点击 Scheme 选择器
   - 选择 **PetHealthWidget**
   - 选择模拟器（如 iPhone 16）

2. **运行 Widget**
   - 按 **Cmd + R** 运行
   - Widget Extension 会在模拟器中启动

3. **测试 Widget**
   - 长按主屏幕
   - 点击 **+**
   - 搜索 **PetHealthData**
   - 选择 Widget 大小（小/中）
   - 验证显示：
     - ✅ 显示宠物列表
     - ✅ 显示即将到期的疫苗数量
     - ✅ 点击 Widget 打开主 App

---

## 📱 在真机上测试 Widget

### 第九步：真机测试步骤

1. **连接设备**
   - 用 USB 连接 iPhone
   - 在 Xcode 中选择你的设备

2. **运行 Widget**
   - 选择 **PetHealthWidget** scheme
   - 按 **Cmd + R** 运行

3. **添加到主屏幕**
   - 长按主屏幕
   - 点击 **+**
   - 搜索 **PetHealthData**
   - 添加 Widget

4. **验证功能**
   - ✅ Widget 显示正确的宠物数据
   - ✅ 疫苗到期提示正确
   - ✅ 点击 Widget 打开 App
   - ✅ 数据更新时 Widget 刷新

---

## 🐛 常见问题和解决方法

### 问题 1：Widget 不显示

**可能原因**：
- Widget Extension 没有运行
- Bundle ID 不正确
- 签名配置错误

**解决方法**：
1. 检查 Widget Extension 是否在运行
2. 验证 Bundle ID 格式：`com.zzoutuo.pethealthdata.PetHealthWidget`
3. 检查 Signing & Capabilities 配置

### 问题 2：Widget 显示空白

**可能原因**：
- SwiftData 访问失败
- Timeline Provider 没有正确实现
- 数据为空

**解决方法**：
1. 检查控制台日志
2. 验证 ModelContainer 配置
3. 确认数据获取逻辑正确

### 问题 3：Widget 不更新

**可能原因**：
- Timeline policy 设置错误
- 数据没有变化
- 系统限制了更新频率

**解决方法**：
1. 检查 `getTimeline` 方法
2. 确认使用了正确的 policy
3. 测试数据变化后是否更新

### 问题 4：编译错误

**可能原因**：
- SwiftData 在 Widget Extension 中不可用
- iOS 版本不匹配

**解决方法**：
1. 确保最低 iOS 版本为 17.0
2. 检查 Widget Extension 的部署目标
3. 验证所有导入的框架

---

## ✅ 配置检查清单

### Widget Extension Target

- [ ] 添加了 Widget Extension Target
- [ ] 配置了正确的 Bundle ID
- [ ] 配置了签名（Team）
- [ ] 添加了必要的 Capabilities（iCloud）
- [ ] 实现了 Widget Provider
- [ ] 实现了 Widget View
- [ ] 配置了 Info.plist

### Widget 功能

- [ ] 显示宠物列表
- [ ] 显示即将到期的疫苗
- [ ] 支持小号和中号尺寸
- [ ] 点击 Widget 打开主 App
- [ ] 数据自动更新

### 测试

- [ ] 在模拟器中测试通过
- [ ] 在真机上测试通过
- [ ] 验证了 Widget 更新
- [ ] 验证了点击跳转

---

## 📝 提交代码

### 第十步：提交到 Git

```bash
# 添加所有文件
git add .

# 提交
git commit -m "Add Widget Extension support

- Added PetHealthWidget target
- Implemented widget provider with SwiftData
- Created small and medium widget views
- Added vaccine due date indicators
- Configured widget signing and capabilities"

# 推送到 GitHub
git push origin main
```

---

## 🚀 App Store 配置

### 第十一步：更新 App Store 元数据

在 App Store Connect 中更新版本信息：

**What's New in Version 1.1**：
- ✅ Added home screen widgets
- ✅ Quick view of your pets
- ✅ Vaccine due date reminders
- ✅ Small and medium widget sizes

**Screenshots**：
- 添加 Widget 显示的截图（小号和中号）

---

## 📚 参考文档

- [Apple WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [Creating a Widget Extension](https://developer.apple.com/documentation/widgetkit/creating-a-widget-extension)
- [SwiftData in Widgets](https://developer.apple.com/documentation/swiftdata/modelcontainer)
- [Widget Best Practices](https://developer.apple.com/documentation/widgetkit/best-practices)
