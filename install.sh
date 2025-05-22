#!/bin/bash

booster_sdk_dir=$(
    cd $(dirname $0)
    pwd
)
echo "Booster Robotics SDK Dir = $booster_sdk_dir"

cpu_arch=$(uname -m)
echo "CPU Arch=$cpu_arch"

third_party_dir=$booster_sdk_dir/third_party
echo "Third Party Dir = $third_party_dir"

set -e

# apt update

# apt install git
# apt install build-essential
# apt install cmake
# apt install libssl-dev
# apt install libasio-dev
# apt install libtinyxml2-dev

ubuntu_version=$(lsb_release -rs)
ubuntu_version_flag=20
case $ubuntu_version in
    22.*) ubuntu_version_flag=22 ;;
    20.*) ubuntu_version_flag=20 ;;
    18.*) ubuntu_version_flag=18 ;;
    *) ubuntu_version_flag=0 ;;
esac

if [ $ubuntu_version_flag -eq 22 ]; then
    booster_sdk_lib_dir=$booster_sdk_dir/lib/$cpu_arch
    third_party_lib_dir=$third_party_dir/lib/$cpu_arch
else
    booster_sdk_lib_dir=$booster_sdk_dir/lib/$cpu_arch/$ubuntu_version_flag
    third_party_lib_dir=$third_party_dir/lib/$cpu_arch/$ubuntu_version_flag
fi

echo "SDK Lib Dir = $booster_sdk_lib_dir"
echo "Third Party Lib Dir = $third_party_lib_dir"

install_dir=$(echo $HOME)/library/booster
# install_dir=/usr/local
echo "Install Dir = $install_dir"

mkdir -p $install_dir/include
mkdir -p $install_dir/lib

cp -r $booster_sdk_dir/include/* $install_dir/include
cp -r $booster_sdk_lib_dir/* $install_dir/lib
echo "Booster Robotics SDK installed successfully!"

cp -r $third_party_dir/include/* $install_dir/include
cp -r $third_party_lib_dir/* $install_dir/lib
echo "Third Party Libraries installed successfully!"

# ldconfig

cd $install_dir/lib
cd $install_dir/lib
for lib in *.so; do
    [ -f "$lib" ] || continue
    soname=$(readelf -d "$lib" | grep SONAME | sed -E 's/.*\[(.*)\].*/\1/')
    if [ -n "$soname" ] && [ "$soname" != "$lib" ] && [ ! -e "$soname" ]; then
        ln -sf "$lib" "$soname"
        echo "Created symlink: $soname -> $lib"
    fi
done