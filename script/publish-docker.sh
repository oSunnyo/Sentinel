#!/bin/bash
# 在执行环境中配置好Maven及Docker，Docker需要登陆到注册表中。

# 获取当前脚本所在目录的绝对路径
SCRIPT_DIR=$(cd "$(dirname "$0")" || exit 1; pwd)

# 定义仓库的根目录为工作目录并切换到工作目录
WORK_DIR=$(cd "$(dirname "$SCRIPT_DIR")" || exit 1; pwd)
cd "$WORK_DIR" || exit 1;

# 获取最新生成的JAR文件名确保使用相对路径
JAR_FILE=$(find xxx-center-facade -name "*.jar")
if [ -z "$JAR_FILE" ]; then
  echo "Jar包不存在！"
  exit 1
fi

# 存入harbor的镜像名称
TAG_NAME="cloud/sentinel"

# 执行 Maven 命令获取项目版本号
TAG_VERSION=$(mvn help:evaluate -Dexpression=project.version -q -DforceStdout)

# bellsoft/liberica-runtime-container:jre-17-musl
# bellsoft/liberica-runtime-container:jdk-all-17.0.7-musl
BASE_IMAGE="bellsoft/liberica-runtime-container:jre-17-musl"

# 远程注册表地址
DOCKER_REGISTRY="harbor.magusiot.cn:9443"

if docker images --format "{{.Repository}}:{{.Tag}}" | grep -q "^$BASE_IMAGE$"; then
    echo "使用基础镜像: $BASE_IMAGE"
else
    echo "拉取基础镜像: $BASE_IMAGE"
    docker pull $BASE_IMAGE
fi

# 默认使用基础镜像的缓存，加速构建
docker build \
--build-arg BASE_IMAGE="$BASE_IMAGE" \
--build-arg JAR_FILE="$JAR_FILE" \
-t $DOCKER_REGISTRY/$TAG_NAME:"$TAG_VERSION" \
-f ./Dockerfile \
.

# 推送到远程注册表
docker push $DOCKER_REGISTRY/$TAG_NAME:"$TAG_VERSION"

echo -e "镜像\033[32m[$TAG_NAME:$TAG_VERSION]\033[0m发布成功！"