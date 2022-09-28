## Introduction

<details>
  <summary>
    Install Docker
  </summary>

```shell
curl -fsSL https://get.docker.com | sh --mirror Aliyun
```
</details>

> This image is not intended to be run manually.
> 
> To create a helper script for the image, run:
>
> `docker run --rm richardarducam/depthai:latest > depthai_env`
> 
> `chmod +x depthai_env`
>
> You may then wish to move the script to your PATH.

```shell
Usage: depthai_env [options] [--] command

By default, run the given *command* in Docker container.

The *options* can be one of:

    --save|-s         Docker image tag to save
    --image|-i        Docker image tag to use
    --help|-h         Show this message

Additionally, there are special update commands:

    update-image      Pull the latest richardarducam/depthai:latest.
    update-script     Update depthai_env from richardarducam/depthai:latest.
    update            Pull the latest richardarducam/depthai:latest, and then update depthai_env from that.
```

## Examples
> The script will map current/working directory to docker's working directory (`/workdir`)
>
> for example
> 
> current directory
> ```shell
> .
> ├── depthai
> └── depthai-python
> ```
> docker's working directory
> ```shell
> .
> ├── /workdir/depthai
> └── /workdir/depthai-python
> ...
> ```
> 

### Download env
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

## Modify Docker Image
If you want to install/upgrade some packages or other things, you can execute the following command.

It will go to the bash shell of the docker image, and then you can do what you want

```shell
depthai_env -s bash
```

> The `-s` option will ask you what tag you should use to save, 
> 
> which means that the modified image will be saved to the tag after you have done what you wanted to do.
> 
> You can then use the modified image with 
> ```shell
> depthai_env -i <tag> <command>
> ```
> If you use the default tag (`latest`), you can use the modified image as usual.
> 
> The old image is named to `latest_<year><month><day><hour><minute>` (e.g. latest_202209281127)
> 
