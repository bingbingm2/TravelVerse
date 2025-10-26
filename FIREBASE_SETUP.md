# Firebase配置详细说明

## Firestore集合结构

### 1. trips（旅行集合）

**目的**：存储用户的旅行计划和行程安排

**文档ID**：自动生成

**字段说明**：

| 字段名 | 类型 | 必填 | 说明 |
|-------|------|------|------|
| userId | string | ✅ | 用户ID |
| cityName | string | ✅ | 城市名称 |
| startDate | timestamp | ✅ | 旅行开始日期 |
| endDate | timestamp | ✅ | 旅行结束日期 |
| itinerary | array | ✅ | 行程数组 |
| createdAt | timestamp | ✅ | 创建时间 |
| updatedAt | timestamp | ✅ | 更新时间 |

**itinerary数组结构**：
```json
[
  {
    "id": "day_1",
    "day": 1,
    "date": "Timestamp",
    "places": [
      {
        "id": "place_1",
        "name": "地点名称",
        "address": "完整地址",
        "latitude": 35.7148,
        "longitude": 139.7967,
        "category": "attraction|restaurant|hotel|shopping",
        "description": "地点描述",
        "startTime": "09:00",
        "endTime": "11:00",
        "realTimeInfo": "实时信息（web scraping数据）"
      }
    ],
    "notes": "当天备注"
  }
]
```

### 2. photos（照片集合）

**目的**：存储用户上传的旅行照片及位置信息

**文档ID**：自动生成

**字段说明**：

| 字段名 | 类型 | 必填 | 说明 |
|-------|------|------|------|
| userId | string | ✅ | 用户ID |
| tripId | string | ✅ | 关联的旅行ID |
| placeId | string | ❌ | 关联的地点ID（可选） |
| placeName | string | ✅ | 地点名称 |
| imageUrl | string | ✅ | Firebase Storage中的图片URL |
| caption | string | ❌ | 照片说明 |
| latitude | number | ✅ | 纬度 |
| longitude | number | ✅ | 经度 |
| timestamp | timestamp | ✅ | 拍摄/上传时间 |
| cityName | string | ✅ | 城市名称 |

### 3. users（用户集合）

**目的**：存储用户基本信息

**文档ID**：用户ID

**字段说明**：

| 字段名 | 类型 | 必填 | 说明 |
|-------|------|------|------|
| name | string | ✅ | 用户名 |
| email | string | ✅ | 邮箱 |
| profileImageUrl | string | ❌ | 头像URL |
| createdAt | timestamp | ✅ | 注册时间 |

## Storage结构

```
storage/
└── photos/
    └── {userId}/
        └── {tripId}/
            ├── photo1.jpg
            ├── photo2.jpg
            └── ...
```

## 安全规则

### Firestore Rules（开发环境）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 允许所有读写（仅用于开发）
    match /{document=**} {
      allow read, write: if true;
    }
  }
}
```

### Firestore Rules（生产环境）

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // 旅行数据
    match /trips/{tripId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // 照片数据
    match /photos/{photoId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == resource.data.userId;
    }
    
    // 用户数据
    match /users/{userId} {
      allow read: if true;
      allow create: if request.auth != null;
      allow update, delete: if request.auth != null && 
        request.auth.uid == userId;
    }
  }
}
```

### Storage Rules（开发环境）

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /{allPaths=**} {
      allow read, write: if true;
    }
  }
}
```

### Storage Rules（生产环境）

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    match /photos/{userId}/{tripId}/{fileName} {
      allow read: if true;
      allow write: if request.auth != null && 
        request.auth.uid == userId &&
        request.resource.size < 10 * 1024 * 1024 && // 限制10MB
        request.resource.contentType.matches('image/.*');
    }
  }
}
```

## 队友集成指南

### 写入行程数据（Node.js示例）

```javascript
const admin = require('firebase-admin');
admin.initializeApp();
const db = admin.firestore();

async function createTrip(userId, cityName, itineraryData) {
  const tripRef = await db.collection('trips').add({
    userId: userId,
    cityName: cityName,
    startDate: admin.firestore.Timestamp.fromDate(new Date('2024-01-01')),
    endDate: admin.firestore.Timestamp.fromDate(new Date('2024-01-05')),
    itinerary: itineraryData,
    createdAt: admin.firestore.FieldValue.serverTimestamp(),
    updatedAt: admin.firestore.FieldValue.serverTimestamp()
  });
  
  console.log('Trip created with ID:', tripRef.id);
  return tripRef.id;
}
```

### 读取照片数据（Node.js示例）

```javascript
async function getPhotosForTrip(tripId) {
  const photosSnapshot = await db.collection('photos')
    .where('tripId', '==', tripId)
    .orderBy('timestamp', 'desc')
    .get();
  
  const photos = [];
  photosSnapshot.forEach(doc => {
    photos.push({
      id: doc.id,
      ...doc.data()
    });
  });
  
  return photos;
}
```

### 读取照片数据（Python示例）

```python
import firebase_admin
from firebase_admin import credentials, firestore

# 初始化
cred = credentials.Certificate('serviceAccountKey.json')
firebase_admin.initialize_app(cred)
db = firestore.client()

def get_photos_for_trip(trip_id):
    photos_ref = db.collection('photos')
    query = photos_ref.where('tripId', '==', trip_id).order_by('timestamp', direction=firestore.Query.DESCENDING)
    
    photos = []
    for doc in query.stream():
        photo_data = doc.to_dict()
        photo_data['id'] = doc.id
        photos.append(photo_data)
    
    return photos
```

## Web Portal可以做的事情

### 1. 读取所有旅行照片
- 查询特定旅行的所有照片
- 按时间排序显示
- 在地图上显示照片位置

### 2. 生成时间线
- 根据timestamp排序
- 显示每个地点的访问顺序
- 创建旅行故事

### 3. 地理可视化
- 使用latitude和longitude在地图上标记
- 绘制旅行路线
- 显示访问过的所有地点

### 4. 视频生成
- 下载所有照片（使用imageUrl）
- 根据时间顺序排列
- 添加地点名称和说明
- 生成旅行回忆视频

### 5. 实时更新行程
- 更新places数组中的realTimeInfo字段
- iOS app会自动显示更新的信息

## 索引建议

为了优化查询性能，在Firestore中创建以下复合索引：

1. **photos集合**：
   - tripId (升序) + timestamp (降序)
   - userId (升序) + timestamp (降序)

2. **trips集合**：
   - userId (升序) + startDate (降序)

Firestore会在你首次运行查询时自动提示创建索引，跟随链接即可。

## 成本估算（免费额度）

Firebase免费计划（Spark Plan）包括：

- **Firestore**：
  - 存储：1 GB
  - 读取：50,000次/天
  - 写入：20,000次/天
  - 删除：20,000次/天

- **Storage**：
  - 存储：5 GB
  - 下载：1 GB/天
  - 上传：无限制

对于Hackathon项目，这些额度完全足够！
