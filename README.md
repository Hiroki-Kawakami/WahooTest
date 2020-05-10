# WahooTest
Wahoo SDK Test

# 実行する前に
WFConnector.frameworkがGitHubに上げられないため、プロジェクト内のFrameworksディレクトリに配置する必要あり。
Wahooの公式ページからSDKをダウンロード後、ターミナルから以下unzipコマンドを利用してBitcode版を展開、Frameworksフォルダに入れたらXcodeで認識されているか確認。
```unzip -d WFConnector.framework WFConnector.framework-v4.0.2.1-BITCODE.zip```

# Environment
Xcode 11.4

# SDKセットアップ方法

## 必要なライブラリ
TargetsのGeneralから追加するとtbdがEmbedされずエラーになるので、Build PhasesのLink Binary With Librariesから追加すること

- SystemConfiguration.framework
- libc++.tbd
- libz.tbd
- WFConnector.framework
- CoreBluetooth.framework
- ExternalAccessory.framework

## SDKのインポート
ダウンロードしたzipファイルをmacOS標準のアンアーカイバで展開するとライブラリが壊れるため、ターミナルからunzipコマンドを使って解凍すること。AppStoreに提出するならBitcode版を利用した方がいい。

- Project NavigatorのFrameworksグループ内にWFConnector.frameworkをD&D
- Build SettingsのOther linker flagsに`-lstdc++`、`-Objc`、`-all_load`を追加
- Swiftで使うならBridging Headerに`#import <Foundation/Foundation.h>`と`#import <WFConnector/WFConnector.h>`を追加する

## バックグラウンド動作の許可
TargetsのSigning & CapabilitiesからBackground Modesの以下3つを有効化する
- External accessory communication
- Uses Bluetooth LE accessories
- Acts as a Bluetooth LE Accessory

## Bluetoothを使用する説明を追加
Info.plistにNSBluetoothAlwaysUsageDescription(Privacy - Bluetooth Always Usage Description)をキーとするString値で、Bluetoothを使用するための説明文を記載する

# SDKの使い方

## デバイスの検出
WFDiscoveryManagerを使う
インスタンスを生成し、
```- (void)discoverSensorTypes:(NSArray *)sensorTypes onNetwork:(WFNetworkType_t)networkType```
これを実行するとデバイスの検出を開始する。
`- (NSArray *)discoveredDevices`にて検出されたデバイスの情報(WFDeviceInformation)の配列を取得できるので、タイマーで回してチェックしてもいいが、別途WFDiscoveryManagerDelegateがあるので、それを使うといい

詳細は当プロジェクトのDiscoveryTableViewControllerを見るべし

## WFHardwareConnector
デバイスとの接続を管理するクラス。最初に`enableBTLE(true)`を呼ばないと上手く動かない。
```+(WFHardwareConnector *)shared```
上記のシングルトンが存在するので、これを使うべし。

## 心拍数の取得
WFDiscoveryManagerを使用して接続したいデバイスの情報(WFDeviceInformation)を取得した後、WFDeviceInformationのインスタンスメソッド
```-(WFConnectionParams*)connectionParamsForSensorType:(WFSensorType_t)sensorType```
を`sensorType`に`WF_SENSORTYPE_HEARTRATE`を渡して接続用のパラメータ(WFConnectionParams)を取得。

WFConnectionParamsをWFHardwareConnectorの
```- (WFSensorConnection*)requestSensorConnection:(WFConnectionParams *)params```
に渡すとWFHeartrateConnectionが取得できる。

これに対して定期的に`getHeartrateData`を呼び出して得られる`WFHeartrateData`内の`computedHeartrate`が実際の心拍数となる。

WFSensorConnectionDelegateに`connection:stateChanged:`が存在するが、こちらは心拍数が変動した際に呼ばれるわけではないので、別途Timerを自分で回して取得すべし。
