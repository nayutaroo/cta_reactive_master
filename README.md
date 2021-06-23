# Simple News

<img src="https://user-images.githubusercontent.com/59905087/123040277-74514780-d42e-11eb-8730-8d4ebb1a828b.png" width="300">


CA Tech AccelでiOSアプリ開発におけるReactiveを理解していく学習リポジトリ

## Setup

以下のコマンドを叩くことで依存しているライブラリをインストールする

```
make setup
```

## CODING RULES

- base branchへの直接pushは禁止(いかなる場合でもPull Requestを作成し、担当の21卒学生からのApproveをもらうまではmergeしない)
- AutoLayoutを利用する(ViewController作成時はStoryboardではなく、xibを利用する)
- ライブラリを追加する際には基本的にCocoaPodsを利用する(CocoaPodsに対応してないものを利用する場合は相談してください)
- APIのレスポンスを受け取るときは `Decodable`で処理する
