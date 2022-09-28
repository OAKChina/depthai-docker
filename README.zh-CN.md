## 介绍

<details>
  <summary>
    docker 安装
  </summary>

```shell
curl -fsSL https://get.docker.com | sh --mirror Aliyun
```
</details>

> 此镜像不需要手动运行。
> 
> 要为镜像创建帮助脚本，请运行：
>
> `docker run --rm richardarducam/depthai:latest > depthai_env`
> 
> `chmod +x depthai_env`
>
> 然后，您可能希望将脚本移动到您的 PATH。

```shell
Usage: depthai_env [options] [--] command

默认情况下，在 Docker 容器中运行给定的命令。

选项（options）可以是以下之一：

    --save|-s         要保存的 Docker 镜像标记
    --image|-i        要使用的 Docker 镜像标记
    --help|-h         显示此消息

此外，还有一些特殊的更新命令：

    update-image      拉最新的 'richarducamdepthai:latest'。
    update-script     从 `richardarducamdepthai:latest` 更新 `depthai_env`。
    update            提取最新的 `richarducamdepthai:latest`，然后从中更新 `depthai_env`。
```

## 例子
> 脚本会将当前工作目录映射到 docker 工作目录（`workdir`）
>
> 例如
> 
> 当前目录
> ```shell
> .
> ├── depthai
> └── depthai-python
> ```
> docker 的工作目录
> ```shell
> .
> ├── /workdir/depthai
> └── /workdir/depthai-python
> ...
> ```
> 

### 下载
[releases](https://github.com/richard-xx/depthai-docker/releases)

### DepthAI Demo
```shell
depthai_env python3 depthai/depthai_demo.py
```

### Calibration
```shell
depthai_env python3 depthai/calibrate.py [parameters]
```

### Rgb Preview
```shell
depthai_env python3 depthai-python/examples/ColorCamera/rgb_preview.py
```

### Spatial Tiny-yolo
```shell
depthai_env python3 depthai-python/examples/SpatialDetection/spatial_tiny_yolo.py 
```

### Device Manager
```shell
depthai_env python3 depthai-python/utilities/device_manager.py 
```

## 修改 Docker 镜像
如果要安装升级某些包或其他东西，可以执行以下命令。

它将进入 docker 镜像的 bash shell，然后你就可以为所欲为。

```shell
depthai_env -s bash
```

> `-s` 选项会询问你应该使用什么标签来保存，
> 
> 这意味着在您完成您想做的事情后，修改后的镜像将保存到标签中。
> 
> 然后，您可以这样使用修改后的镜像
> ```shell
> depthai_env -i <tag> <command>
> ```
> 如果您使用默认标签（`latest`），则可以照常使用修改后的镜像。
> 
> 旧镜像被命名为 `latest_< 年 >< 月 >< 日 >< 时 >< 分 >`（例如，latest_202209281127）。
> 
