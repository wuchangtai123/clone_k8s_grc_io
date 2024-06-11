#!/bin/bash

while read -r image; do
    # 检查是否有 /
    if [[ $image == *"/*"* ]]; then
        # 截取 / 后的值
        repository=$(basename "$image")
        tag=$(echo "$image" | cut -d : -f 2)
        new_image="registry.cn-hangzhou.aliyuncs.com/wct_registry/$repository:$tag"
    else
        # 如果没有 /，则直接使用原名称作为新的repository
        new_image="registry.cn-hangzhou.aliyuncs.com/wct_registry/$image"
    fi

    # 拉取镜像,重新标记镜像,推送
    docker pull --platform=linux/arm64 "$image"
    docker tag "$image" "$new_image-arm64"
    docker push "$new_image-arm64"

    # 拉取镜像,重新标记镜像,推送
    docker pull --platform=linux/amd64 "$image"
    docker tag "$image" "$new_image-amd64"
    docker push "$new_image-amd64"

    #创建manifest
    docker manifest create ${new_image} \
                             ${new_image}-amd64 \
                             ${new_image}-arm64 --amend

    docker manifest push ${new_image}
    
done < images.txt
