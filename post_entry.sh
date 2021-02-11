#!/usr/bin/env bash

#
# はてぶ下書き投稿スクリプト
#

ID=$(cat ~/account.json | jq -r '.hatena.user_id')
BLOG_ID=$(cat ~/account.json | jq -r '.hatena.blog_id')
API_KEY=$(cat ~/account.json | jq -r '.hatena.api_key')

entry() {
  local title=$1
  local content=$2
  cat <<EOS
    <?xml version="1.0" encoding="utf-8"?>
    <entry xmlns="http://www.w3.org/2005/Atom"
           xmlns:app="http://www.w3.org/2007/app">
      <title>${title}</title>
      <content type="text/plain">
      ${content}
      </content>
      <updated></updated>
      <category term="" />
      <app:control>
        <app:draft>yes</app:draft>
      </app:control>
    </entry>
EOS
}

main() {
  local title=$1
  local content=$2
  entry "$title" "$content" | curl -s -u ${ID}:${API_KEY} -X POST https://blog.hatena.ne.jp/${ID}/${BLOG_ID}/atom/entry --data-binary @-
}
main
