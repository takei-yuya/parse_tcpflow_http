# tcpflowのログのHTTPの通信の部分からディレクトリ構造とか復元するやつ

tcpdumpとかtcpflowのアレから元ファイル復元したいときに使う。

e.g.
```console
$ tcpflow port 80
なんか通信
$ ./parse_tcpflow_http.sh *80
```
