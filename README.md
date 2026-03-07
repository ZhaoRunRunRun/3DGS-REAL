# 3DGS REAL

一个面向 Windows、macOS、Linux、Android 的 Flutter 跨平台应用骨架，用于引导用户围绕物体旋转拍摄照片，或从相册导入成组环绕照片，并在本地或远端服务器发起 3D Gaussian Splatting (3DGS) 建模任务。

## 当前已完成

- Flutter 项目基础结构（应用层、页面层、服务层、模型层）
- 采集与建模控制台首页 UI
- 本地 / 远端重建模式抽象
- 相机引导与重建服务接口占位
- 一键初始化 Flutter 平台工程脚本
- 面向后续 3DGS 管线接入的架构文档

## 目标平台

- Windows
- macOS
- Linux
- Android

## 核心功能规划

1. 相机拍摄引导
   - 引导用户围绕目标物体旋转拍摄
   - 提示角度覆盖率、拍摄距离、模糊风险、光照问题
2. 相册批量导入
   - 导入多张按环绕顺序拍摄的图片
   - 基础质检（分辨率、重复、模糊、曝光）
3. 3DGS 建模
   - 本地模式：桌面设备直接在本机运行重建管线
   - 远端模式：上传图像与任务参数到服务端构建模型
4. 结果展示与导出
   - 预览训练状态、日志、缩略图
   - 导出 splat / ply / glb 等成果格式

## 快速开始

### 1. 安装 Flutter SDK

请先安装 Flutter，并确保以下命令可用：

```bash
flutter --version
```

### 2. 初始化平台目录

在仓库根目录执行：

```bash
sh scripts/bootstrap_flutter.sh
```

该脚本会自动补齐 Flutter 标准平台目录与缺失文件：

- `android/`
- `linux/`
- `macos/`
- `windows/`

### 3. 拉取依赖

```bash
flutter pub get
```

### 4. 运行应用

```bash
flutter run -d windows
flutter run -d macos
flutter run -d linux
flutter run -d android
```

## 推荐后端接口

### 创建重建任务

`POST /api/reconstruction/jobs`

请求体建议：

```json
{
  "mode": "remote",
  "images": ["..."],
  "pipeline": "3dgs",
  "options": {
    "use_colmap": true,
    "iterations": 30000,
    "export_formats": ["splat", "ply"]
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

## 下一步接入建议

1. 接入 `camera` 插件实现实时取景和拍摄引导覆盖层
2. 接入 `file_picker` / `image_picker` 完成图片导入
3. 对接 Python 服务端（COLMAP + 3DGS 训练）
4. 增加任务详情页、照片质量评估、模型预览页

详见：`docs/architecture.md`
