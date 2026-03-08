# 3DGS REAL

一个面向 Windows、macOS、Linux、Android 的 Flutter 跨平台应用，用于引导用户围绕物体旋转拍摄照片，或从相册导入一系列环绕物体拍摄的照片，并在本地或远端服务器发起 3D Gaussian Splatting (3DGS) 建模任务。

## 当前版本能力

### ✅ 已完成功能
- **真实相机拍摄**：实时预览、引导式拍摄、自动保存
- **相册批量导入**：多文件选择、自动排序、质量评分
- **照片质量管理**：质量评分系统、过滤功能、可视化展示
- **环绕照片轨道分布可视化**：实时显示拍摄覆盖度
- **本地/远端重建模式切换**：支持两种建模方式
- **远端API集成**：文件上传、参数传递、错误处理
- **本地重建支持**：COLMAP集成、3DGS训练调用
- **模型预览与导出**：预览页面、多格式导出（SPLAT/PLY/GLB）
- **任务管理**：创建、进度跟踪、历史列表
- **跨平台权限配置**：Android、macOS权限已配置

详细实现状态请查看：[`docs/implementation_status.md`](docs/implementation_status.md)

## 目标平台

- Windows
- macOS
- Linux
- Android

## 目录结构

- `lib/` Flutter 客户端代码
- `docs/` 架构与设计说明
- `scripts/` 项目初始化脚本
- `server/` 远端 3DGS 服务端骨架

## 快速开始

### 1. 安装 Flutter SDK

确保以下命令可用：

```bash
flutter --version
```

### 2. 初始化 Flutter 平台目录

```bash
sh scripts/bootstrap_flutter.sh
```

该脚本会生成或补齐：

- `android/`
- `linux/`
- `macos/`
- `windows/`

### 3. 安装依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
flutter run -d linux
flutter run -d windows
flutter run -d macos
flutter run -d android
```

## Linux 桌面依赖

在 RHEL / CentOS / Alibaba Cloud Linux 上建议安装：

```bash
dnf install -y clang cmake ninja-build pkg-config gtk3-devel libblkid-devel xz-devel
```

## 远端服务启动

```bash
cd server
python3 -m venv .venv
. .venv/bin/activate
pip install -r requirements.txt
uvicorn app.main:app --reload --host 0.0.0.0 --port 8080
```

## 推荐后端接口

### 创建重建任务

`POST /api/reconstruction/jobs`

```json
{
  "mode": "remote",
  "images": ["upload-1.jpg", "upload-2.jpg"],
  "pipeline": "3dgs",
  "options": {
    "use_colmap": true,
    "iterations": 30000,
    "export_formats": ["splat", "ply", "glb"]
  }
}
```

### 查询任务状态

`GET /api/reconstruction/jobs/{jobId}`

返回字段建议：

- `status`: queued / running / failed / done
- `progress`: 0~100
- `preview_url`
- `artifacts`
- `logs`

## 使用说明

### 相机拍摄模式
1. 点击"相机引导拍摄"按钮
2. 授予相机权限
3. 将物体放置在中心位置
4. 围绕物体旋转，每个角度点击拍摄按钮
5. 拍摄完成后点击确认

### 相册导入模式
1. 点击"导入相册照片"按钮
2. 选择一组围绕物体拍摄的照片
3. 系统自动按文件名排序并分配角度

### 启动重建
1. 选择"本地重建"或"远端重建"模式
2. 调整训练迭代次数（10000-50000）
3. 可选启用照片质量过滤
4. 点击"启动 3DGS 建模"
5. 等待任务完成后点击"预览模型"

## 后续可继续增强

### 优先级1 - 照片质量检测
- 真实的模糊检测算法
- 特征点覆盖度分析
- 曝光检测
- 重复照片去重

### 优先级2 - 3D模型渲染
- 集成3D渲染引擎（如three.js的Flutter版本）
- 交互式旋转/缩放
- 点云可视化

### 优先级3 - 服务端完善
- 实际COLMAP集成
- 实际3DGS训练管线
- 任务队列管理
- WebSocket实时推送

### 优先级4 - 用户体验
- 项目保存/加载功能
- 多语言支持
- 暗色模式
- 离线模式

详见：[`docs/architecture.md`](docs/architecture.md) 和 [`docs/implementation_status.md`](docs/implementation_status.md)
