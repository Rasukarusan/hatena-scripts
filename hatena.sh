#!/bin/sh

#
# はてぶの全記事をローカルにダウンロード
# 記事内で使用されている画像もダウンロードします。
#
# ※md形式で書かれた記事のみ対応
# 
# [使い方]
# sh hatena.sh
#

API_KEY=`XXXXXXXXXXXXXXXXXXXX`
HATENA_ID=`XXXXXXXX`
BLOG_ID=`XXXXXXXX`

ENDPOINT_ROOT="https://blog.hatena.ne.jp/${HATENA_ID}/${BLOG_ID}/atom"
ENDPOINT_ENTRY='/entry'

# エンコードされた特殊文字(&,",',<,>)をデコードする
function decodeSpecialChars() {
     sed 's/&amp;/&/g'  \
   | sed 's/&quot;/"/g' \
   | sed "s/&#39;/'/g"  \
   | sed 's/&lt;/</g'   \
   | sed 's/&gt;/</g'
}

# 全記事のエンドポイントを取得する
function getEntryId() {
    page=`curl -su ${HATENA_ID}:${API_KEY} ${ENDPOINT_ROOT}${ENDPOINT_ENTRY}?page=$1`

    # entry_idの取得
    # たまにBinary file (standard input) matchesと表示され処理が止まるのを防ぐため-aをつける
    echo "$page" \
    | grep -a 'link rel="edit"' \
    | grep -oP 'href=".*"' \
    | sed 's/href="//g' \
    | tr -d '"'

    # 次のページがある場合、再帰してエントリーIDを出力する
    next=`echo "$page" | grep 'link rel="next"'`
    if [ $? -eq 0 ] ; then
        pageId=`echo "$next" | grep -oP "page=[0-9]*" | tr -d "page="`
        getEntryId $pageId
    fi
}

# contentタグの中身だけ取得。特殊文字はデコードして出力
# 第一引数に対象の記事のエンドポイントをとる
function getContent() {
    # contentタグの始めと終わりの行番号を取得するためのラベル
    START_CONTENT_LABEL='<content type="text\/x-markdown">'
    END_CONTENT_LABEL='<\/content>'

    endPoint=$1
    article=`curl -su ${HATENA_ID}:${API_KEY} ${endPoint}`

    # コンテンツ内容を投稿日時毎のディレクトリに保存し、ファイル名をタイトルにするため
    postDate=`echo "$article" | grep 'link rel="alternate"' | grep -oP "[0-9]{4}/[0-9]{2}/[0-9]{2}"`
    title=`echo "$article" | grep -oP "(?<=\<title\>).*(?=\<\/title\>)"`

    # 画像ファイルを取得するため
    blogUrl=`echo "$article" | grep 'link rel="alternate"' | grep -oP '(?<=href=").*(?=")'`
    blog=`curl -s ${blogUrl}`
    imgUrls=`echo "$blog" | grep -oP '<img src.*itemprop="image"' | grep -oP '(?<=src=").*(?=" alt)'`

    printf "\e[92m\e[1m$postDate\e[m\n"
    echo $title

    # 記事毎に内容と画像を保存したいので、投稿日時ごとのディレクトリを作成
    mkdir -p $postDate

    # 画像をダウンロードし、投稿日時ディレクトリに保存
    for imgUrl in `echo "$imgUrls"`; do
        imgName=`echo $imgUrl | grep -oP "[0-9]{12}.*"`
        echo "$imgName"
        echo "${postDate}/${imgName} $imgUrl"
        wget -q -O ${postDate}/${imgName} $imgUrl
    done

    # contentタグの中身のみ取得したいため、始めと終わりの行番号を取得
    contentLineNo=`
    echo "$article" \
    | grep -nE "(${START_CONTENT_LABEL}|${END_CONTENT_LABEL})" \
    | sed 's/:.*//g'
    `

    # 記事の内容を投稿日時ディレクトリにmd形式で保存
    start=`echo "$contentLineNo" | head -n 1`
    end=`echo "$contentLineNo" | tail -n 1`
    content=`echo "$article" | awk "NR==${start},NR==${end}"`
    echo "$content" | decodeSpecialChars \
    | sed "s/$START_CONTENT_LABEL//g" \
    | sed "s/$END_CONTENT_LABEL//g" \
    > $postDate/$title.md
}

# 全ての記事の内容を取得する
function main() {
    for i in `getEntryId`
    do
        getContent $i
    done
}

main
