FROM debian:bullseye-slim
ENV TZ='Asia/Shanghai' SHELL=/bin/bash DEBIAN_FRONTEND=noninteractive
ENV LANG=zh_CN.UTF-8 LC_ALL=zh_CN.UTF-8 LANGUAGE=zh_CN.UTF-8
COPY requirements.txt /tmp
COPY NotoSansCJK-Regular.ttc /usr/share/fonts/NotoSansCJK-Regular.ttc

RUN ln -fs /usr/share/zoneinfo/Asia/Shanghai /etc/localtime \
    && apt-get update -qq \
    && apt upgrade -y \
    && apt-get install -y locales python3-pyqt5 python3-pyqt5.qtquick python3-pipdeptree git \
    udev qml-module-qtquick-controls qml-module-qt-labs-platform qml-module-qtquick-controls2 \
    python3-venv python3-numpy libilmbase-dev libopenexr-dev libgstreamer1.0-dev libturbojpeg0 \
    python3-tk \
    && mkdir -p /etc/udev/rules.d/ \
    && echo 'SUBSYSTEM=="usb", ATTRS{idVendor}=="03e7", MODE="0666"' | tee /etc/udev/rules.d/80-movidius.rules > /dev/null \
    && sed -ie 's/# zh_CN.UTF-8 UTF-8/zh_CN.UTF-8 UTF-8/g' /etc/locale.gen \
    && locale-gen \
    && apt clean autoclean \
    && rm -rf /var/lib/{apt,cache,log} \
    && python3 -m pip install -U pip \
    && python3 -m pip install -r /tmp/requirements.txt --no-cache-dir --prefer-binary

COPY entrypoint.sh /tmp
WORKDIR /workdir
CMD cat /tmp/depthai_env