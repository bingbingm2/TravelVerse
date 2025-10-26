# TravelVerse iOS App

这是一个旅行行程规划和照片分享的iOS应用，为Hackathon项目开发。

## 项目功能

### ✈️ 核心功能
1. **旅行行程展示**
   - 显示队友通过web scraping生成的旅行行程
   - 实时显示地点信息和推荐
   - 按天查看详细行程规划

2. **照片上传（带位置追踪）**
   - 用户可以在旅行中上传照片
   - 自动记录GPS位置信息
   - 照片与行程地点关联
   - 支持拍照和相册选择

3. **数据共享**
   - 照片和位置数据存储在Firestore
   - 队友可以通过web portal访问这些数据
   - 用于生成旅行视频和回忆

## 项目结构

```
TravelVerse/
├── Models/                 # 数据模型
│   ├── Trip.swift         # 旅行模型
│   ├── Photo.swift        # 照片模型
│   └── User.swift         # 用户模型
├── ViewModels/            # 视图模型
│   ├── TripViewModel.swift    # 旅行数据管理
│   └── PhotoViewModel.swift   # 照片上传管理
├── Views/                 # 视图层
│   ├── HomeView.swift         # 主页（旅行列表）
│   ├── ItineraryView.swift    # 行程详情
│   └── UploadPhotoView.swift  # 照片上传
├── Services/              # 服务层
│   ├── FirebaseService.swift  # Firebase操作
│   └── LocationService.swift  # 位置服务
├── Helpers/               # 辅助工具
│   └── DateExtensions.swift   # 日期扩展
└── TravelVerseApp.swift   # App入口
```

## 技术栈

- **语言**: Swift
- **框架**: SwiftUI
- **后端**: Firebase (Firestore + Storage)
- **架构**: MVVM
- **定位**: CoreLocation

## 设置步骤

### 1. 安装Firebase依赖

在Xcode中添加Firebase SDK:
1. 打开 `TravelVerse.xcodeproj`
2. 在Xcode菜单选择: `File` → `Add Package Dependencies...`
3. 输入URL: `https://github.com/firebase/firebase-ios-sdk.git`
4. 选择版本: 最新版本（建议 10.0.0+）
5. 选择需要的产品:
   - FirebaseFirestore
   - FirebaseStorage
   - FirebaseAuth (如果需要用户认证)

### 2. 配置Firebase

1. 访问 [Firebase Console](https://console.firebase.google.com/)
2. 创建新项目或使用现有项目
3. 添加iOS应用:
   - Bundle ID: `com.yourname.TravelVerse` (需要与Xcode中的Bundle ID一致)
4. 下载 `GoogleService-Info.plist` 文件
5. 将文件拖入Xcode项目的根目录（与TravelVerseApp.swift同级）
   - ⚠️ **重要**: 确保勾选 "Copy items if needed" 和选择正确的target

### 3. 设置Firestore数据库

在Firebase Console中:
1. 进入 `Firestore Database`
2. 创建数据库（选择测试模式或生产模式）
3. 数据结构会自动创建，包括以下集合:
   - `trips` - 存储旅行信息
   - `photos` - 存储照片信息
   - `users` - 存储用户信息

### 4. 设置Firebase Storage

在Firebase Console中:
1. 进入 `Storage`
2. 点击 "Get started"
3. 选择存储规则（建议开发期间使用测试模式）

### 5. 配置Info.plist权限

在Xcode中打开 `Info.plist` 并添加以下权限:

```xml
<key>NSLocationWhenInUseUsageDescription</key>
<string>我们需要您的位置信息来记录照片拍摄地点</string>

<key>NSCameraUsageDescription</key>
<string>我们需要访问相机来拍摄旅行照片</string>

<key>NSPhotoLibraryUsageDescription</key>
<string>我们需要访问相册来选择照片</string>
```

**如何添加（在Xcode中）**:
1. 在项目导航器中找到 `Info.plist`
2. 右键点击 → `Open As` → `Source Code`
3. 在 `<dict>` 标签内添加上述权限代码

### 6. 数据库安全规则（生产环境）

为了保护数据，在Firebase Console中设置Firestore规则:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 旅行数据
    match /trips/{tripId} {
      allow read: if true; // 所有人可以读取
      allow write: if request.auth != null; // 需要认证才能写入
    }
    
    // 照片数据
    match /photos/{photoId} {
      allow read: if true;
      allow write: if request.auth != null;
    }
    
    // 用户数据
    match /users/{userId} {
      allow read: if true;
      allow write: if request.auth.uid == userId;
    }
  }
}
```

Storage规则:
```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{allPaths=**} {
      allow read: if true;
      allow write: if request.auth != null;
    }
  }
}
```

## 使用说明

### 查看行程
1. 打开app后会显示所有旅行列表
2. 点击任意旅行卡片查看详细行程
3. 使用天数选择器切换不同日期的行程

### 上传照片
1. 在行程详情页点击右上角的相机图标
2. 选择拍照或从相册选择
3. 填写地点名称（必填）
4. 添加照片说明（可选）
5. 确保位置权限已开启
6. 点击上传按钮

### 测试功能
- 点击主页的"+"按钮可以创建示例旅行
- 用于测试和演示功能

## 与队友的集成

### Firestore数据结构

**Trip Collection** (`trips/{tripId}`):
```json
{
  "userId": "string",
  "cityName": "string",
  "startDate": "timestamp",
  "endDate": "timestamp",
  "itinerary": [
    {
      "day": 1,
      "date": "timestamp",
      "places": [
        {
          "name": "string",
          "address": "string",
          "latitude": "double",
          "longitude": "double",
          "category": "string",
          "description": "string",
          "startTime": "string",
          "endTime": "string",
          "realTimeInfo": "string"  // 队友的web scraping数据
        }
      ],
      "notes": "string"
    }
  ],
  "createdAt": "timestamp",
  "updatedAt": "timestamp"
}
```

**Photo Collection** (`photos/{photoId}`):
```json
{
  "userId": "string",
  "tripId": "string",
  "placeId": "string",
  "placeName": "string",
  "imageUrl": "string",  // Firebase Storage URL
  "caption": "string",
  "latitude": "double",
  "longitude": "double",
  "timestamp": "timestamp",
  "cityName": "string"
}
```

### 队友需要做的事情

1. **Web Scraping部分**:
   - 将生成的行程数据写入Firestore的 `trips` collection
   - 更新 `realTimeInfo` 字段来显示实时信息

2. **Web Portal部分**:
   - 从Firestore读取 `photos` collection获取用户上传的照片
   - 使用 `latitude` 和 `longitude` 在地图上显示照片位置
   - 根据 `timestamp` 生成时间线
   - 使用 `imageUrl` 下载照片用于视频生成

## 常见问题

### Q: 编译错误：找不到Firebase模块
A: 确保已通过Swift Package Manager添加Firebase依赖，并且选择了正确的产品。

### Q: App崩溃：Firebase没有配置
A: 确保 `GoogleService-Info.plist` 文件已正确添加到项目中。

### Q: 无法获取位置信息
A: 
- 检查Info.plist中是否添加了位置权限描述
- 在设备/模拟器的设置中检查app的位置权限是否开启
- 如果使用模拟器，在菜单 `Features` → `Location` 中设置一个位置

### Q: 照片上传失败
A: 
- 检查Firebase Storage是否已启用
- 检查Storage规则是否允许写入
- 确保网络连接正常

### Q: 数据库规则错误
A: 在开发阶段，可以使用测试模式规则（允许所有读写），生产环境必须设置适当的安全规则。

## 后续改进建议

1. **用户认证**: 添加Firebase Authentication
2. **离线支持**: 使用Firestore的离线持久化
3. **地图视图**: 在MapKit上显示行程路线
4. **社交分享**: 分享旅行到社交媒体
5. **推送通知**: 提醒用户行程更新
6. **多语言支持**: 国际化

## 联系方式

如有问题请联系开发者。

## 许可证

本项目为Hackathon演示项目。
