#!/bin/bash
# 在执行环境中安装并配置好Minio Client https://min.io/docs/minio/linux/reference/minio-mc.html

# 获取当前脚本所在目录的绝对路径
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)

# 定义仓库的根目录为工作目录并切换到工作目录
WORK_DIR=$(cd "$(dirname "$SCRIPT_DIR")" || exit 1; pwd)
cd "$WORK_DIR" || exit 1;

# 获取最新生成的JAR文件名确保使用相对路径
JAR_FILE=$(find sentinel-dashboard -name "*.jar")
if [ -z "$JAR_FILE" ]; then
  echo "Jar包不存在！"
  exit 1
fi

# 存入minio的目标路径
TARGET_PATH="cloud/sentinel"

# mc设定的存储目标
MINIO_ALIAS="minio-prod"

# 上传JAR包到MinIO
mc cp "$JAR_FILE" $MINIO_ALIAS/$TARGET_PATH/

echo -e "Jar包\033[32m[$(basename "$JAR_FILE")]\033[0m发布成功！"