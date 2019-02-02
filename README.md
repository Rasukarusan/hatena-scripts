# 概要
はてぶの全記事を画像込みでローカルにダウンロードする
md形式で記事を書いている人に限る。

# 使い方

```sh 
sh hatena.sh
```
![デモ](https://cdn-ak.f.st-hatena.com/images/fotolife/r/rasukarusan/20190203/20190203002203.gif)

## スクリプト実行後のディレクトリ
```sh 
# シェル叩いた後
$ ls

2018      2019      hatena.sh

# ディレクトリ構成
$ tree 2019
.
`-- 01
    |-- 07
    |   `-- 【Swift4】UIImageでURLで画像を指定する.md
    |-- 26
    |   `-- apacheのDOCUMENT_ROOTを知る方法.md
    `-- 27
        |-- 20190126015937.png
        |-- 20190126020540.png
        `-- laravel+apacheでTesting 123...と出てしまう問題の解決法.md
```

## .mdファイルをはてぶにアップロードしたときの形式を保持したままダウンロード

```sh 
$ cat ./01/27/laravel+apacheでTesting\ 123...と出てしまう問題の解決法.md

[f:id:uhhohho:20190126020540p:plain]


サーバーにlaravelで作ったアプリを設置するときに若干詰まった。

結局シンプルな変更漏れっていうオチなんですけどね。


## 解決1

DOCUMENT_ROOTを設定するときにhttpd.confの設定で変更漏れがあった。
\```zsh
DocumentRoot /var/www/html/laravel-app/public
ServerName example.com

#<Directory "/var/www/html"<
<Directory "/var/www/html/laravel-app/public"< # ←こっちも変更する
\```
...(省略)

```

## 本スクリプトについての記事

https://www.rasukarusan.com/entry/2019/02/03/000000
