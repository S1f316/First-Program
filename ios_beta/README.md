# iOS Beta 应用

这是 Web 应用的 iOS 版本，实现相同的功能集。

## 功能列表
1. 用户认证
   - 管理员登录
   - 普通用户登录（使用生日验证）
2. Todo 任务管理
   - 创建、编辑、删除任务
   - 任务优先级管理
   - 任务完成状态追踪
3. 论坛功能
   - 发帖和评论
   - 点赞功能
   - 投诉功能
4. 用户管理（管理员功能）
   - 用户创建
   - 用户删除
   - 查看用户任务
5. 小组长功能

## 项目结构
```
ios_beta/
├── App/
│   ├── AppDelegate.swift
│   ├── SceneDelegate.swift
│   └── Info.plist
├── Features/
│   ├── Authentication/
│   ├── Todo/
│   ├── Forum/
│   ├── UserManagement/
│   └── GroupLeader/
├── Core/
│   ├── Models/
│   ├── Network/
│   ├── Storage/
│   └── Utils/
├── UI/
│   ├── Components/
│   ├── Screens/
│   └── Theme/
└── Resources/
    ├── Assets.xcassets/
    └── Localizable.strings
```

## 技术栈
- Swift UI 用于 UI 构建
- Combine 用于响应式编程
- Core Data 用于本地数据存储
- URLSession 用于网络请求

## 开发要求
- Xcode 14.0+
- iOS 15.0+
- Swift 5.5+ 