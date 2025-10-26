# TravelVerse 快速设置指南 🚀

## 第一步：安装依赖

### 方法1：使用Swift Package Manager（推荐）

1. 打开Xcode，打开你的 `TravelVerse.xcodeproj`
2. 在顶部菜单选择：`File` → `Add Package Dependencies...`
3. 在搜索框输入：
   ```
   https://github.com/firebase/firebase-ios-sdk.git
   ```
4. 版本选择：`Up to Next Major Version` 输入 `10.0.0`
5. 点击 `Add Package`
6. 在产品列表中勾选：
   - ✅ FirebaseFirestore
   - ✅ FirebaseStorage
   - ✅ FirebaseCore
7. 点击 `Add Package`

## 第二步：配置Firebase

### 1. 创建Firebase项目

1. 访问 https://console.firebase.google.com/
2. 点击 `添加项目`
3. 输入项目名称：`TravelVerse` （或任意名称）
4. 可以禁用Google Analytics（不需要）
5. 点击 `创建项目`

### 2. 添加iOS应用

1. 在Firebase项目主页，点击iOS图标
2. **iOS Bundle ID**: 
   - 在Xcode中找到：选择项目 → Target → General → Bundle Identifier
   - 复制这个ID（例如：`com.yourname.TravelVerse`）
   - 粘贴到Firebase的Bundle ID输入框
3. **App昵称**：输入 `TravelVerse`
4. 点击 `注册应用`

### 3. 下载配置文件

1. 点击 `下载 GoogleService-Info.plist`
2. **重要**：将这个文件拖入Xcode项目：
   - 直接拖到项目导航器中的 `TravelVerse` 文件夹（蓝色图标）
   - 确保勾选 ✅ `Copy items if needed`
   - 确保勾选 ✅ `TravelVerse` target
3. 点击 `下一步`，然后 `继续到控制台`

## 第三步：设置Firestore数据库

1. 在Firebase控制台左侧菜单，点击 `Firestore Database`
2. 点击 `创建数据库`
3. 选择 `以测试模式启动`（用于开发）
4. 选择位置：`us-central` 或离你最近的位置
5. 点击 `启用`

## 第四步：设置Firebase Storage

1. 在Firebase控制台左侧菜单，点击 `Storage`
2. 点击 `开始使用`
3. 选择 `以测试模式启动`
4. 使用默认位置
5. 点击 `完成`

## 第五步：配置App权限

### 在Xcode中设置Info.plist

**方法A：使用可视化编辑器**
1. 在Xcode项目导航器中找到 `Info.plist`
2. 右键点击 → `Open As` → `Property List`
3. 点击任意一行，然后点击 `+` 号添加新行
4. 添加以下三个权限：

| Key | Type | Value |
|-----|------|-------|
| Privacy - Location When In Use Usage Description | String | 我们需要您的位置信息来记录照片拍摄地点 |
| Privacy - Camera Usage Description | String | 我们需要访问相机来拍摄旅行照片 |
| Privacy - Photo Library Usage Description | String | 我们需要访问相册来选择照片 |

**方法B：直接编辑源代码**
1. 右键点击 `Info.plist` → `Open As` → `Source Code`
2. 在 `<dict>` 标签内添加：

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>我们需要您的位置信息来记录照片拍摄地点</string>
<key>NSCameraUsageDescription</key>
<string>我们需要访问相机来拍摄旅行照片</string>
<key>NSPhotoLibraryUsageDescription</key>
<string>我们需要访问相册来选择照片</string>
```

## 第六步：构建并运行

1. 选择一个模拟器或连接真机
2. 按 `Command + B` 构建项目
3. 按 `Command + R` 运行

## 测试App

### 1. 创建示例旅行
- 打开app
- 点击右上角的 `+` 按钮
- 点击 `创建示例旅行`

### 2. 查看行程
- 点击旅行卡片
- 查看详细行程信息
- 切换不同的天数

### 3. 上传照片（模拟器）
- 在行程页面点击右上角的相机图标
- 点击 `从相册选择`
- 选择一张照片
- 填写地点名称
- **设置模拟器位置**：
  - Xcode菜单 → `Debug` → `Simulate Location` → 选择一个城市
- 点击上传

## 常见问题解决

### ❌ 编译错误：Cannot find 'FirebaseCore' in scope

**解决方法**：
1. 确认Firebase包已经添加
2. Clean Build Folder：`Shift + Command + K`
3. 关闭Xcode并重新打开
4. 重新构建项目

### ❌ App崩溃：Firebase app not configured

**解决方法**：
1. 检查 `GoogleService-Info.plist` 是否在项目中
2. 确认文件在正确的target中（查看File Inspector）
3. Clean并重新构建

### ❌ 位置服务不工作

**解决方法（模拟器）**：
1. Xcode菜单 → `Debug` → `Simulate Location` → 选择位置
2. 或在模拟器中：`Features` → `Location` → `Custom Location`

**解决方法（真机）**：
1. 设置 → 隐私与安全性 → 定位服务 → TravelVerse → 使用App期间

### ❌ 上传照片失败

**解决方法**：
1. 检查Firebase Storage是否已启用
2. 检查网络连接
3. 在Firebase Console查看Storage规则是否允许写入

## Firestore数据结构（给队友）

如果你的队友需要往Firestore写入数据，告诉他们数据结构：

### Trips Collection

路径：`trips/{tripId}`

```javascript
{
  userId: "demo_user_123",
  cityName: "东京",
  startDate: Timestamp,
  endDate: Timestamp,
  itinerary: [
    {
      day: 1,
      date: Timestamp,
      places: [
        {
          id: "place_123",
          name: "浅草寺",
          address: "东京都台东区浅草2-3-1",
          latitude: 35.7148,
          longitude: 139.7967,
          category: "attraction",
          description: "东京最古老的寺庙",
          startTime: "09:00",
          endTime: "11:00",
          realTimeInfo: "今日天气晴朗，游客较多" // 这是web scraping的数据
        }
      ],
      notes: "第一天行程"
    }
  ],
  createdAt: Timestamp,
  updatedAt: Timestamp
}
```

### Photos Collection

路径：`photos/{photoId}`

iOS app会自动写入这个collection，队友可以读取：

```javascript
{
  userId: "demo_user_123",
  tripId: "trip_id_here",
  placeName: "浅草寺",
  imageUrl: "https://firebasestorage.googleapis.com/...",
  caption: "美丽的寺庙",
  latitude: 35.7148,
  longitude: 139.7967,
  timestamp: Timestamp,
  cityName: "东京"
}
```

## 下一步

- ✅ App已经可以运行了！
- 🤝 与队友共享Firebase项目（在Firebase Console添加成员）
- 📱 在真机上测试照片上传功能
- 🎨 根据需要自定义UI
- 🚀 准备好Hackathon演示！

祝你好运！🎉
