# TravelVerse 设置检查清单 ✅

## 开始之前
- [ ] 确保安装了最新版Xcode
- [ ] 有Google/Firebase账号
- [ ] 项目已经在Xcode中打开

## 第一步：Firebase SDK
- [ ] 在Xcode中打开 `File` → `Add Package Dependencies...`
- [ ] 添加Firebase SDK: `https://github.com/firebase/firebase-ios-sdk.git`
- [ ] 选择了以下产品：
  - [ ] FirebaseFirestore
  - [ ] FirebaseStorage
  - [ ] FirebaseCore
- [ ] 包已成功添加（没有错误）

## 第二步：Firebase项目
- [ ] 访问 https://console.firebase.google.com/
- [ ] 创建了新项目或选择了现有项目
- [ ] 项目名称：________________
- [ ] 添加了iOS应用
- [ ] Bundle ID已正确填写：________________

## 第三步：配置文件
- [ ] 下载了 `GoogleService-Info.plist`
- [ ] 文件已拖入Xcode项目
- [ ] ✅ 勾选了 "Copy items if needed"
- [ ] ✅ 勾选了正确的target (TravelVerse)
- [ ] 文件在项目导航器中可见

## 第四步：Firestore设置
- [ ] 在Firebase Console创建了Firestore数据库
- [ ] 选择了模式：
  - [ ] 测试模式（开发用）
  - [ ] 生产模式（需要配置规则）
- [ ] 数据库已成功创建

## 第五步：Storage设置
- [ ] 在Firebase Console启用了Storage
- [ ] 选择了测试模式（开发用）
- [ ] Storage已成功启用

## 第六步：Info.plist权限
- [ ] 打开了Info.plist文件
- [ ] 添加了以下三个权限：
  - [ ] NSLocationWhenInUseUsageDescription
  - [ ] NSCameraUsageDescription
  - [ ] NSPhotoLibraryUsageDescription
- [ ] 每个权限都有中文描述

## 第七步：构建项目
- [ ] 按 `Command + B` 构建项目
- [ ] ✅ 构建成功（没有错误）
- [ ] 如有错误，已解决：
  - [ ] Clean Build Folder (`Shift + Command + K`)
  - [ ] 重启Xcode
  - [ ] 重新构建

## 第八步：运行测试
- [ ] 选择了模拟器或真机
- [ ] 按 `Command + R` 运行app
- [ ] App成功启动
- [ ] 看到了 "我的旅行" 主页

## 第九步：功能测试

### 创建旅行
- [ ] 点击右上角 "+" 按钮
- [ ] 点击 "创建示例旅行"
- [ ] 旅行卡片出现在列表中

### 查看行程
- [ ] 点击旅行卡片
- [ ] 看到详细行程信息
- [ ] 可以切换不同天数
- [ ] 地点卡片正常显示

### 上传照片（模拟器）
- [ ] 在行程页面点击相机图标
- [ ] 模拟器设置了位置：
  - Xcode → Debug → Simulate Location → 选择城市
- [ ] 选择了照片（从相册或拍照）
- [ ] 填写了地点名称
- [ ] 看到了位置信息
- [ ] 点击上传按钮
- [ ] ✅ 上传成功

### 验证数据（Firebase Console）
- [ ] 打开Firebase Console
- [ ] 进入Firestore Database
- [ ] 看到 `trips` collection有数据
- [ ] 看到 `photos` collection有数据
- [ ] 进入Storage
- [ ] 看到上传的照片文件

## 第十步：队友集成准备
- [ ] 向队友提供Firebase项目访问权限
- [ ] 分享了数据结构文档（FIREBASE_SETUP.md）
- [ ] 提供了示例数据格式
- [ ] 确认队友可以访问Firestore

## 常见问题排查

### 如果编译失败
- [ ] 检查Firebase包是否正确添加
- [ ] 尝试Clean Build Folder
- [ ] 重启Xcode
- [ ] 检查Swift版本兼容性

### 如果App崩溃
- [ ] 检查GoogleService-Info.plist是否在项目中
- [ ] 检查文件是否在正确的target中
- [ ] 查看Xcode控制台的错误信息

### 如果位置不工作
- [ ] 检查Info.plist权限描述
- [ ] 模拟器：设置了模拟位置
- [ ] 真机：检查系统设置中的位置权限

### 如果上传失败
- [ ] 检查网络连接
- [ ] 检查Firebase Storage是否启用
- [ ] 检查Storage规则是否允许写入
- [ ] 查看错误消息

## Hackathon演示准备
- [ ] 创建了几个示例旅行
- [ ] 准备了演示用的照片
- [ ] 测试了完整流程（至少3次）
- [ ] 网络连接稳定
- [ ] 设备充满电
- [ ] 备份设备（带第二台设备）

## 文档清单
- [ ] README.md - 完整说明
- [ ] SETUP_GUIDE_CN.md - 快速设置
- [ ] FIREBASE_SETUP.md - Firebase配置
- [ ] PROJECT_SUMMARY.md - 项目总结
- [ ] CHECKLIST.md - 本清单

## 最终检查
- [ ] 所有功能都测试通过
- [ ] Firebase数据正确存储
- [ ] 队友可以访问和读取数据
- [ ] UI显示正常
- [ ] 没有明显bug
- [ ] 准备好演示脚本
- [ ] 团队所有成员都了解各自负责部分

---

## ✅ 完成状态

**设置完成日期**: _______________

**测试人员**: _______________

**准备状态**: 
- [ ] 已完成所有设置
- [ ] 已测试所有功能
- [ ] 准备好Hackathon演示

**备注**:
_______________________________________________
_______________________________________________
_______________________________________________

---

**祝你好运！加油！** 🚀🎉
