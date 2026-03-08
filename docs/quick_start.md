# 3DGS REAL 快速开始指南

## 环境准备

### 1. 安装Flutter
```bash
# 检查Flutter版本
flutter --version

# 应该 >= 3.3.0
```

### 2. 克隆项目
```bash
git clone <repository-url>
cd 3DGS-REAL
```

### 3. 安装依赖
```bash
flutter pub get
```

## 运行应用

### Windows
```bash
flutter run -d windows
```

### macOS
```bash
flutter run -d macos
```

### Linux
```bash
# 先安装系统依赖
sudo apt-get install clang cmake ninja-build pkg-config libgtk-3-dev

# 运行应用
flutter run -d linux
```

### Android
```bash
# 连接Android设备或启动模拟器
flutter devices

# 运行
flutter run -d <device-id>
```

## 功能测试

### 测试相机拍摄
1. 启动应用
2. 点击"相机引导拍摄"
3. 授予相机权限
4. 点击拍摄按钮测试

### 测试相册导入
1. 点击"导入相册照片"
2. 选择多张图片
3. 查看照片轨道图

### 测试重建流程
1. 完成照片采集
2. 选择"本地重建"或"远端重建"
3. 点击"启动 3DGS 建模"
4. 观察进度更新

## 本地重建配置

如需使用本地重建功能，需要安装：

### COLMAP
```bash
# Ubuntu/Debian
sudo apt-get install colmap

# macOS
brew install colmap

# Windows
# 从 https://github.com/colmap/colmap/releases 下载
```

### 3DGS训练环境
```bash
# 克隆3DGS仓库
git clone https://github.com/graphdeco-inria/gaussian-splatting
cd gaussian-splatting

# 安装依赖
pip install -r requirements.txt
```

## 远端服务配置

### 启动服务端
```bash
cd server
python3 -m venv .venv
source .venv/bin/activate  # Windows: .venv\Scripts\activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

### 配置客户端
修改 [`lib/models/reconstruction_settings.dart`](../lib/models/reconstruction_settings.dart)：
```dart
serverEndpoint: 'http://localhost:8080/api/reconstruction/jobs',
```

## 常见问题

### 相机权限被拒绝
- Android: 在设置中手动授予权限
- macOS: 系统偏好设置 > 安全性与隐私 > 相机

### 文件选择器不工作
- 确保已安装 file_picker 依赖
- 检查平台权限配置

### 本地重建失败
- 确认COLMAP已安装并在PATH中
- 检查Python环境配置
- 查看错误日志

## 下一步

- 查看 [`docs/architecture.md`](architecture.md) 了解架构设计
- 查看 [`docs/implementation_status.md`](implementation_status.md) 了解实现状态
- 开始开发新功能或修复问题
