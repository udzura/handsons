# mrbgem を作る

* mgemのコードは作業用リポジトリの `./workspace` の下に作ってください！共有フォルダの関係です。
* このmarkdownでの手順は、 `<on Mac>` `<on Linux>` に分かれます。それぞれターミナルを分けておくのがオススメ

## できればするといいこと

* git の以下の設定を入れておくと、 `mrbgem-template` コマンドがいい感じに動きます

```console
$ git config --global github.user udzura
$ git config --global user.name "Uchio Kondo"
```

## 1) 負荷を取得するmgemを作る

### Making a boilerplate

```console
### <on Mac>
$ cd workspace/
$ mrbgem-template mruby-loadavg
Generate all files of mruby-loadavg
create dir : ./mruby-loadavg
create dir : ./mruby-loadavg/src
...
```

以下のようなファイル構成になります。CRubyのgemよりちょっと少ないかな？

```
mruby-loadavg
├── LICENSE
├── README.md
├── Rakefile
├── mrbgem.rake
├── mrblib
│   └── mrb_loadavg.rb
├── mruby-loadavg.gem
├── src
│   ├── mrb_loadavg.c
│   └── mrb_loadavg.h
└── test
    └── mrb_loadavg.rb

3 directories, 9 files
```

今回は `src` ディレクトリは **不要なので** 削除しちゃっていいです。

```console
### <on Mac>
$ cd mruby-loadavg
$ rm -rf src/
```

また、 `mrbgem.rake` で依存する外部もしくは標準添付のmgemを指定します。今回は `File` クラスが定義されている `mruby-io` mgemが必要そうですね。

```ruby
MRuby::Gem::Specification.new('mruby-loadavg') do |spec|
  spec.license = 'MIT'
  spec.authors = 'Uchio Kondo'

  spec.add_dependency 'mruby-io'
end
```

### ビルドできるかだけ試しておきましょう

```console
### <on Linux>
$ cd /vagrant/workspace/mruby-loadavg
$ rake
$ ./mruby/bin/mirb 
mirb - Embeddable Interactive Ruby Shell

> Loadavg.class
 => Class
```

### ここまでできたら、 `mrblib` の下にあるRubyスクリプトに、いつものようにRubyを書けばOKです。

* エディタはMac側で立ち上げて編集すると楽かな？
* rbファイルを追加すればそれも勝手に認識してくれます。

### 実装のヒント

* `/proc/loadavg` というファイルを読み込めばOKです
  * こういうフォーマットになります
  * ただのファイルとして開いて、読み取り、splitすれば良さそう

```console
### <on Linux>
$ cat /proc/loadavg 
0.07 0.12 0.11 1/140 22587
```

* しかし、それぞれの数字の意味はなんでしょう？
  * [man があります](https://linuxjm.osdn.jp/html/LDP_man-pages/man5/proc.5.html)
  * シスプロを始めると man のセクション1以外を見るようになります :)
* 実装したら、 `rake && mirb` を繰り返し、Loadavgが取得できているか確認しつつ進めましょう

### Publish the mgem

* GitHub に個人のアカウントに紐づけて `mruby-***` というリポジトリを作り、pushすれば完了です。
* さっきの mrbgem-template で作ったプロジェクトを Git リポジトリ化しておきましょう。

```console
### <on Mac>
$ cd workspace/mruby-loadavg
$ git init .
$ git add . ; git status
$ git commit
$ git remote add origin git@github.com:udzura/mruby-loadavg.git
$ git push origin master
```

## 2) `uname(2)` を利用したmgemを作る

* 基本的な手順は 1) に従います。
* 上級者向けなのでざっくりした手順しか書きません。完成コードは実装済みなので、困ったら見てね。

### `uname(2)` の定義を知る

* [manで確認する](https://linuxjm.osdn.jp/html/LDP_man-pages/man2/uname.2.html)。

```c
#include <sys/utsname.h>

int uname(struct utsname *buf);

struct utsname {
    char sysname[];    /* OS の名前 (例: "Linux") */
    char nodename[];   /* 「実装時に定義された、何らかの
                          ネットワーク」におけるマシン名 */
    char release[];    /* オペレーションシステムのリリース番号 (例: "2.6.28") */
    char version[];    /* オペレーティングシステムのバージョン */
    char machine[];    /* ハードウェア識別子 */
#ifdef _GNU_SOURCE
    char domainname[]; /* NIS や YP のドメイン名 */
#endif
};
```

### データの取り扱いを決める

* mrubyの都合で生の構造体の名前は不便なので、別名をつけます。

```c
typedef struct utsname mrb_utsname;
```

* freeする関数を定義します。今回はmrb_freeに渡すだけですが、専用の解放関数があるような時はそれを使うようラップすると良いでしょう

```c
void mrb_uname_free(mrb_state *mrb, void *p) {
  mrb_free(mrb, (mrb_utsname *)p);
}
```

* で、型ごとにどの関数で解放するかの対応を指定しましょう

```
static const struct mrb_data_type mrb_uname_data_type = {
  "mrb_utsname", mrb_uname_free,
};
```

* この `struct mrb_data_type` はinitializeの時に使います。

### initializeでのmalloc

* initialize 相当の関数内でuname(2)を読んで、インスタンスの後ろのデータとしてアサインする。専用のマクロを活用します。ジェネレータの吐き出すコードをベースにすればOK

```c
// ジェネレータはかなり丁寧なコードを吐くのでそれベースで。
static mrb_value mrb_uname_init(mrb_state *mrb, mrb_value self)
{
  mrb_utsname *data;
  data = (mrb_utsname *)DATA_PTR(self);
  if (data) {
    mrb_free(mrb, data);
  }
  DATA_TYPE(self) = &mrb_uname_data_type;
  DATA_PTR(self) = NULL;

  data = (mrb_utsname *)mrb_malloc(mrb, sizeof(mrb_utsname));

  if(uname(data) < 0) {
    mrb_sys_fail(mrb, "uname");
  }

  DATA_PTR(self) = data;

  return self;
}
```

### 構造体のメンバーに対応するメソッドを書く

* これはまあ機械的にできますね。

```c
static mrb_value mrb_uname_sysname(mrb_state *mrb, mrb_value self)
{
  mrb_utsname *data = DATA_PTR(self);

  return mrb_str_new_cstr(mrb, data->sysname);
}
```

### gem自体の初期化関数で、関数をメソッドとして定義し直す

* `mrb_#{gemname.sub(/-/, '_')}_gem_init` という関数が、mruby初期化時に呼ばれる規約です。そこでクラスが定義されるといい感じです。

```c
void mrb_mruby_myuname_gem_init(mrb_state *mrb)
{
  struct RClass *uname;
  uname = mrb_define_class(mrb, "Uname", mrb->object_class);
  mrb_define_method(mrb, uname, "initialize", mrb_uname_init, MRB_ARGS_NONE());
  mrb_define_method(mrb, uname, "sysname", mrb_uname_sysname, MRB_ARGS_NONE());
  //...
  DONE;
}
```

### 全体のつなぎ

* こういうノリでCの関数、構造体とRubyの世界をつなげていきます。
* 元の生成されたコードを参考にしつついい感じにつないでください。

### ポイント

* **コンパイラの警告を無視しない**。だいたいバグの原因。
* メモリリークの確認には `valgrind` が一番。インスタンスの生成→破棄のループを回してあげて、それに `valgrind` をかければOK。

```console
$ sudo apt install valgrind
$ valgrind --tool=memcheck ./mruby/bin/mruby -e '50.times { Uname.new.sysname }'
==19625== Memcheck, a memory error detector
==19625== Copyright (C) 2002-2017, and GNU GPL'd, by Julian Seward et al.
==19625== Using Valgrind-3.13.0 and LibVEX; rerun with -h for copyright info
==19625== Command: ./mruby/bin/mruby -e 50.times\ {\ Uname.new.sysname\ }
==19625== 
==19625== 
==19625== HEAP SUMMARY:
==19625==     in use at exit: 19,500 bytes in 50 blocks
==19625==   total heap usage: 3,302 allocs, 3,252 frees, 520,898 bytes allocated
==19625== 
==19625== LEAK SUMMARY:
==19625==    definitely lost: 19,500 bytes in 50 blocks
==19625==    indirectly lost: 0 bytes in 0 blocks
==19625==      possibly lost: 0 bytes in 0 blocks
==19625==    still reachable: 0 bytes in 0 blocks
==19625==         suppressed: 0 bytes in 0 blocks
==19625== Rerun with --leak-check=full to see details of leaked memory
==19625== 
==19625== For counts of detected and suppressed errors, rerun with: -v
==19625== ERROR SUMMARY: 0 errors from 0 contexts (suppressed: 0 from 0)
```

* あえて `free` しないコードにすればちゃんと警告が出るはず。試してみましょう。メモリをただしく扱うのがシスプロの基本です。<s>最後は人間で管理しきれなくなってRustを書く。</s>

### 今回やっていないこと

* 引数が不要なので `mrb_get_args` と言った基本的な関数を使っていない。宿題です（と言って調べるのは大変でしょうが...）。

## 実装例について

* @udzura の実装例を [作業用リポジトリのmruby-loadavg](https://github.com/udzura/handsons/tree/master/mruby-loadavg) [mruby-myuname](https://github.com/udzura/handsons/tree/master/mruby-myuname) に置いてあるので困ったら眺めてください。
