# 3DGS REAL

一个面向 Windows、macOS、Linux、Android 的 Flutter 跨平台应用，用于引导用户围绕物体旋转拍摄照片，或从相册导入一系列环绕物体拍摄的照片，并在本地或远端服务器发起 3D Gaussian Splatting (3DGS) 建模任务。

## 当前版本能力

- 引导拍摄流程（已接入相机权限与设备可用性检查，当前采集结果仍使用演示照片串联流程）
- 相册批量导入流程（已接入真实图片多选，失败时自动回退到演示流）
- 环绕照片轨道分布可视化
- 照片质量评分与筛选
- 本地 / 远端重建模式切换
- 3DGS 任务创建、进度跟踪、任务列表展示
- 远端服务 API 骨架（FastAPI）

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

## 后续可继续增强

1. 接入真实 `camera` 实时取景、拍照与覆盖层引导
2. 对导入照片补充 EXIF / 文件名排序策略与缩略图预览
3. 对接 Python 训练服务（COLMAP + gsplat）
4. 增加模型预览器、导出中心、项目管理页

详见：`docs/architecture.md`
