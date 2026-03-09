# 📱 CloudKit & Widget Extension 配置指南

## 🌤️ CloudKit 配置步骤

### 第一步：创建 CloudKit 容器

1. **登录 Apple Developer Portal**
   - 访问：https://developer.apple.com/account/
   - 使用你的 Apple ID 登录

2. **创建 CloudKit 容器**
   - 进入 **Certificates, Identifiers & Profiles**
   - 选择 **CloudKit** → **Containers**
   - 点击 **+** 创建新容器
   - 输入容器名称：`iCloud.com.zzoutuo.pethealthdata`
   - 点击 **Continue** → **Create**

3. **配置 App ID**
   - 进入 **Identifiers** → **App IDs**
   - 找到你的 App ID（通常格式：`com.zzoutuo.pethealthdata`）
   - 点击编辑
   - 在 **Capabilities** 中启用：
     - ✅ **iCloud**
     - ✅ 选择刚创建的 CloudKit 容器
   - 保存更改

---

### 第二步：在 Xcode 中启用 CloudKit

1. **打开项目设置**
   - 在 Xcode 中打开项目
   - 选择项目（蓝色图标）
   - 选择 **pethealthdata** target

2. **添加 Capability**
   - 点击 **Signing & Capabilities** 标签
   - 点击 **+ Capability**
   - 搜索并添加 **iCloud**
   - 配置 iCloud：
     - ✅ **iCloud Documents**：勾选
     - ✅ **CloudKit**：勾选
     - ✅ **Containers**：选择 `iCloud.com.zzoutuo.pethealthdata`

3. **验证配置**
   - 项目导航器中应该看到：
     - `iCloud entitlements` 文件
     - `.entitlements` 文件被添加

---

### 第三步：修改代码以支持 CloudKit

在 `pethealthdataApp.swift` 中修改 ModelContainer 配置：

```swift
import SwiftUI
import SwiftData
import CloudKit

@main
struct pethealthdataApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Pet.self,
            VaccineRecord.self,
            Medication.self,
            WeightRecord.self,
            HealthEvent.self
        ])
        
        // CloudKit 配置
        let modelConfiguration = ModelConfiguration(
            schema: schema,
            isStoredInMemoryOnly: false,
            allowsSave: true,
            cloudKitDatabase: .automatic  // 启用 CloudKit 同步
        )
        
        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .onAppear {
                    requestNotificationPermission()
                }
        }
        .modelContainer(sharedModelContainer)
    }
    
    private func requestNotificationPermission() {
        NotificationService.shared.requestAuthorization { granted in
            if granted {
                print("Notification permission granted")
            } else {
                print("Notification permission denied")
            }
        }
    }
}
```

---

## 🎯 Widget Extension 配置步骤

### 第一步：添加 Widget Extension Target

1. **在 Xcode 中添加 Target**
   - 选择项目文件（蓝色图标）
   - 点击底部的 **+** 按钮
   - 选择 **Widget Extension**
   - 命名为：`PetHealthWidget`
   - 点击 **Finish**

2. **配置 Widget**
   - 在弹出的对话框中：
     - ✅ **Include Configuration Intent**：勾选（可选）
     - ✅ **Include Live Activity**：不勾选
   - 点击 **Activate**

---

### 第二步：配置 Widget Target

1. **选择 Widget Target**
   - 在项目导航器中选择 **PetHealthWidget** target
   - 点击 **Signing & Capabilities** 标签

2. **配置签名**
   - **Team**：选择你的开发团队
   - **Bundle Identifier**：自动设置为 `com.zzoutuo.pethealthdata.PetHealthWidget`

3. **添加 Capabilities**（如果需要）
   - 如果 Widget 需要访问数据，添加：
     - ✅ **iCloud**（如果需要访问 CloudKit 数据）

---

### 第三步：创建 Widget 代码

在 `PetHealthWidget.swift` 中实现：

```swift
import WidgetKit
import SwiftUI
import SwiftData

struct PetHealthWidget: Widget {
    let kind: String = "PetHealthWidget"
    
    var body: some WidgetConfiguration {
        StaticConfiguration(kind: kind, provider: PetHealthProvider()) { entry in
            entry.configuration
        }
        .configurationDisplayName("My Pets")
        .description("Quick view of your pets")
        .supportedFamilies([.systemSmall, .systemMedium])
    }
}

struct PetHealthEntry: TimelineEntry {
    let date: Date
    let pets: [Pet]
}

struct PetHealthProvider: AppIntentTimelineProvider {
    func placeholder(in context: Context) -> PetHealthEntry {
        PetHealthEntry(date: Date(), pets: [])
    }
    
    func snapshot(for configuration: PetHealthIntent, in context: Context) async -> PetHealthEntry {
        // 从 SwiftData 获取宠物数据
        let container = try? ModelContainer(for: [Pet.self])
        let context = container?.mainContext
        
        let descriptor = FetchDescriptor<Pet>(sortBy: [SortDescriptor(\.name)])
        let pets = (try? context?.fetch(descriptor)) ?? []
        
        return PetHealthEntry(date: Date(), pets: pets)
    }
    
    func timeline(for configuration: PetHealthIntent, in context: Context) async -> Timeline<PetHealthEntry> {
        let entry = await snapshot(for: configuration, in: context)
        let timeline = Timeline(entries: [entry], policy: .atEnd)
        return timeline
    }
}

struct PetHealthIntent: AppIntent {
    static var title: LocalizedStringResource = "Pet Health"
    static var description = IntentDescription("View your pets")
}

struct PetHealthWidgetEntryView: View {
    var entry: Provider.Entry
    
    var body: some View {
        if entry.pets.isEmpty {
            emptyStateView
        } else {
            petListView
        }
    }
    
    @ViewBuilder
    private var emptyStateView: some View {
        VStack(spacing: 8) {
            Image(systemName: "pawprint.fill")
                .font(.title)
                .foregroundColor(.secondary)
            
            Text("No pets yet")
                .font(.caption)
                .foregroundColor(.secondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
    
    @ViewBuilder
    private var petListView: some View {
        VStack(alignment: .leading, spacing: 8) {
            ForEach(Array(entry.pets.prefix(3)), id: \.id) { pet in
                HStack(spacing: 8) {
                    Image(systemName: pet.speciesIcon)
                        .font(.caption)
                        .foregroundColor(.blue)
                    
                    VStack(alignment: .leading, spacing: 2) {
                        Text(pet.name)
                            .font(.caption)
                            .fontWeight(.semibold)
                            .lineLimit(1)
                        
                        if let vaccine = pet.vaccines.first {
                            if vaccine.isOverdue {
                                Text("Vaccine due!")
                                    .font(.caption2)
                                    .foregroundColor(.red)
                            }
                        }
                    }
                }
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(Color(.systemGroupedBackground))
    }
}
```

---

### 第四步：配置 Info.plist

Widget Extension 的 `Info.plist` 会自动配置，但可以验证：

```xml
<key>NSExtension</key>
<dict>
    <key>NSExtensionPointIdentifier</key>
    <string>com.apple.widgetkit-extension</string>
</dict>
```

---

### 第五步：更新主 App 的 Info.plist

在主 App 的 `Info.plist` 中添加 Widget 支持声明：

```xml
<key>NSSupportsLiveActivities</key>
<true/>
```

---

## 🧪 测试步骤

### 测试 CloudKit 同步

1. **在两台设备上测试**
   - 在设备 A 上添加宠物
   - 在设备 B 上登录相同的 iCloud 账户
   - 等待几秒钟
   - 验证宠物数据是否同步

2. **测试离线模式**
   - 关闭网络
   - 添加/修改宠物数据
   - 打开网络
   - 验证数据自动同步

### 测试 Widget

1. **添加 Widget 到主屏幕**
   - 长按主屏幕
   - 点击 **+**
   - 搜索 **PetHealthData**
   - 选择 Widget 大小（小/中）

2. **验证显示**
   - Widget 应该显示最近的宠物
   - 疫苗到期应该显示警告
   - 点击 Widget 应该打开 App

---

## ⚠️ 常见问题

### CloudKit 问题

**问题**：数据不同步
- **解决**：
  1. 检查 iCloud 登录状态
  2. 验证 CloudKit 容器名称正确
  3. 在设置中启用 iCloud 同步

**问题**：同步冲突
- **解决**：
  1. SwiftData 自动处理冲突
  2. 用户可以选择保留哪个版本

### Widget 问题

**问题**：Widget 不更新
- **解决**：
  1. 检查 Timeline Provider 是否正确实现
  2. 验证 Widget 的 Bundle ID 正确
  3. 在 Xcode 中重新运行 Widget Extension

**问题**：Widget 显示空白
- **解决**：
  1. 检查 SwiftData 访问权限
  2. 验证 Widget Extension 的签名配置
  3. 查看控制台日志

---

## 📝 配置检查清单

### CloudKit

- [ ] Apple Developer Portal 创建了 CloudKit 容器
- [ ] App ID 启用了 iCloud Capability
- [ ] Xcode 项目添加了 iCloud Capability
- [ ] 代码中启用了 CloudKit 同步
- [ ] 测试了跨设备同步

### Widget Extension

- [ ] 添加了 Widget Extension Target
- [ ] 配置了 Widget 签名
- [ ] 实现了 Widget Provider
- [ ] 实现了 Widget View
- [ ] 测试了 Widget 显示
- [ ] 测试了 Widget 更新

---

## 🚀 部署步骤

1. **提交代码**
   ```bash
   git add .
   git commit -m "Add CloudKit and Widget support"
   git push
   ```

2. **更新 App Store Connect**
   - 上传新版本的 App
   - 在版本说明中提到：
     - ✅ iCloud 同步支持
     - ✅ 主屏幕 Widget 支持

3. **提交审核**
   - 等待 Apple 审核（通常 1-3 天）
   - 审核通过后用户即可更新

---

## 📚 参考文档

- [Apple CloudKit Documentation](https://developer.apple.com/documentation/cloudkit)
- [WidgetKit Documentation](https://developer.apple.com/documentation/widgetkit)
- [SwiftData with CloudKit](https://developer.apple.com/documentation/swiftdata/modelconfiguration/cloudkitdatabase)
