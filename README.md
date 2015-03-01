# tcpflowのログのHTTPの通信の部分からディレクトリ構造とか復元するやつ

tcpdumpとかtcpflowのアレから元ファイル復元したいときに使う。
双方向のファイルを読むので、引数に渡すのは、`*.*-*.00080` だけでok (対になる `*.00080-*.*` は勝手に読む)。

e.g.
```console
# tcpflow -ieth0 port 80
なんか通信
$ ./parse_tcpflow_http.sh *.00080
```
