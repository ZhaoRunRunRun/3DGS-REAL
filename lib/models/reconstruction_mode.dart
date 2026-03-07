enum ReconstructionMode {
  local(
    title: '本地重建',
    description: '适合高性能桌面设备，本地执行特征提取、配准与 3DGS 训练。',
  ),
  remote(
    title: '远端重建',
    description: '将照片与参数发往服务器，适合移动端或多人协作场景。',
  );

  const ReconstructionMode({
    required this.title,
    required this.description,
  });

  final String title;
  final String description;
}
