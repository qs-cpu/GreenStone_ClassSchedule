# GreenStone ClassSchedule

A new Flutter project.

## Environment Deployment Process

### Flutter 开发

环境变量由 `direnv` 来管理：

> Direnv 是一个 shell 扩展工具，用于根据当前目录自动加载/卸载环境变量，非常适合管理开发工具链路径。

#### Direnv

首先安装 direnv 包，并让其加入当前 shell 的配置，这里使用 zsh：

```bash
sudo apt install direnv
echo 'eval "$(direnv hook zsh)"' >> ~/.zshenv
source ~/.zshenv
```

如果是 bash：

```bash
echo 'if [ -f ~/.bashrc ]; then source ~/.bashrc; fi' >> ~/.bash_profile
echo 'eval "$(direnv hook bash)"' >> ~/.bashrc
source ~/.bashrc
```

随后使用 `touch ./.envrc` 在项目下新建配置文件，写入以下内容（已兼容多发行版的 Java 路径探测）：

```bash
# Java
if [ -d "/usr/lib/jvm/java-1.17.0-openjdk-amd64" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-1.17.0-openjdk-amd64"  # Ubuntu
elif [ -d "/usr/lib/jvm/java-17-openjdk" ]; then
    export JAVA_HOME="/usr/lib/jvm/java-17-openjdk"            # Arch Linux
elif command -v java >/dev/null 2>&1; then
    export JAVA_HOME=$(dirname $(dirname $(readlink -f $(command -v java))))
else
    echo "Direnv: ⚠️ 无法自动定位 JAVA_HOME，请手动设置"
fi

# Android SDK
export ANDROID_HOME="$HOME/Android/Sdk"
export ANDROID_SDK_ROOT="$ANDROID_HOME"

# PATH
export PATH="$ANDROID_HOME/platform-tools:$PATH"
export PATH="$ANDROID_HOME/cmdline-tools/latest/bin:$PATH"

# Flutter
export PATH="$HOME/flutter/bin:$PATH"
```

随后使用 `direnv allow` 即可每次进入该目录的时候自动激活环境变量。

#### Android SDK

随后安装安卓 SDK 工具链，首先从 Google 官网下载 commandlinetools：

```bash
mkdir -p ~/Android/Sdk
cd ~/Android/Sdk

wget https://dl.google.com/android/repository/commandlinetools-linux-11076708_latest.zip
unzip commandlinetools-linux-*.zip -d tmp
mkdir -p cmdline-tools/latest
mv tmp/cmdline-tools/* cmdline-tools/latest/
rm -rf tmp
```

随后使用其中的 `sdkmanager` 下载 platforms 和 build-tools，注意版本为 36：

```bash
sdkmanager \
  "cmdline-tools;latest" \
  "platform-tools" \
  "platforms;android-36" \
  "build-tools;36.0.0"

sdkmanager --licenses
```

#### Flutter

现在下载 Flutter 工具链，使用 GitHub 下载并同意 license：

```bash
git clone https://github.com/flutter/flutter.git ~/flutter

## 告诉 Flutter SDK Android SDK 安装位置
flutter config --android-sdk $HOME/Android/Sdk
## 检查开发环境是否完整，并提示缺失的依赖
flutter doctor
## 同意 Flutter 编译 APK 所需的 Android 协议
flutter doctor --android-licenses
## 提前下载 Android 构建依赖，加快后续构建速度
flutter precache --android
```

#### Build apk

随后即可构建 apk 并进行安装测试：

```bash
just init
just build-apk
```
