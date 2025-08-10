## Домашнее задание № 7 — «Управление пакетами. Дистрибьюция софта.»

Цель домашнего задания: 1) Создать свой RPM пакет; 2) Создать свой репозиторий 
и разместить там ранее собранный RPM пакет в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

**1) Создать свой RPM пакет:**


Для данного задания нам понадобятся следующие установленные пакеты:
```console
[root@vbox ~]# yum install -y wget rpmdevtools rpm-build createrepo yum-utils cmake gcc git nano
...
Installed:
  annobin-12.65-1.el9.x86_64                         attr-2.5.1-3.el9.x86_64                                cmake-3.26.5-2.el9.x86_64                         cmake-data-3.26.5-2.el9.noarch
  cmake-filesystem-3.26.5-2.el9.x86_64               cmake-rpm-macros-3.26.5-2.el9.noarch                   createrepo_c-0.20.1-2.el9.x86_64                  createrepo_c-libs-0.20.1-2.el9.x86_64
  debugedit-5.0-5.el9.x86_64                         ed-1.14.2-12.el9.x86_64                                elfutils-0.191-4.el9.alma.1.x86_64                emacs-filesystem-1:27.2-11.el9_5.2.noarch
  gcc-11.5.0-5.el9_5.alma.1.x86_64                   gcc-plugin-annobin-11.5.0-5.el9_5.alma.1.x86_64        gdb-minimal-14.2-3.el9.x86_64                     git-2.43.5-2.el9_5.x86_64
  git-core-2.43.5-2.el9_5.x86_64                     git-core-doc-2.43.5-2.el9_5.noarch                     glibc-devel-2.34-125.el9_5.8.alma.1.x86_64        info-6.7-15.el9.x86_64
  kernel-headers-5.14.0-503.40.1.el9_5.x86_64        libuv-1:1.42.0-2.el9_4.x86_64                          libxcrypt-devel-4.4.18-3.el9.x86_64               make-1:4.3-8.el9.x86_64
  nano-5.6.1-6.el9.x86_64                            patch-2.7.6-16.el9.x86_64                              perl-Error-1:0.17029-7.el9.noarch                 perl-Git-2.43.5-2.el9_5.noarch
  python3-argcomplete-1.12.0-5.el9.noarch            python3-chardet-4.0.0-5.el9.noarch                     python3-idna-2.10-7.el9_4.1.noarch                python3-pysocks-1.7.1-12.el9.noarch
  python3-requests-2.25.1-8.el9.noarch               python3-urllib3-1.26.5-6.el9.noarch                    rpm-build-4.16.1.3-34.el9.x86_64                  rpmdevtools-9.5-1.el9.noarch
  vim-filesystem-2:8.2.2637-21.el9.noarch            wget-1.21.1-8.el9_4.x86_64                             yum-utils-4.3.0-16.el9.noarch                     zstd-1.5.1-2.el9.x86_64
Complete!
```

Для примера возьмем пакет Nginx и соберем его с дополнительным модулем ngx_broli.  
Загрузим SRPM пакет Nginx для дальнейшей работы над ним:  
(yumdownloader - Download package to current directory)
```console
[root@vbox ~]# mkdir rpm && cd rpm

[root@vbox rpm]# yumdownloader --source nginx

[root@vbox rpm]# ll
total 1084
-rw-r--r--. 1 root root 1109119 May 19 17:57 nginx-1.20.1-20.el9.alma.1.src.rpm
```

При установке такого пакета в домашней директории создается дерево каталогов для сборки,  
далее поставим все зависимости для сборки пакета Nginx:  
(yum-builddep - Install build dependencies for package or spec file)
```console
[root@vbox rpm]# rpm -Uvh nginx-1.20.1-20.el9.alma.1.src.rpm
Updating / installing...
   1:nginx-2:1.20.1-20.el9.alma.1     ################################# [100%]

[root@vbox rpm]# ll ~/
total 0
drwxr-xr-x. 2 root root 48 May 19 18:38 rpm
drwxr-xr-x. 4 root root 34 May 19 19:12 rpmbuild

[root@vbox rpm]# yum-builddep nginx
...
Installed:
  brotli-1.0.9-6.el9.x86_64             brotli-devel-1.0.9-6.el9.x86_64            bzip2-devel-1.0.8-8.el9.x86_64           cairo-1.17.4-7.el9.x86_64                 dejavu-sans-fonts-2.37-18.el9.noarch
  fontconfig-2.14.0-2.el9_1.x86_64      fontconfig-devel-2.14.0-2.el9_1.x86_64     fonts-filesystem-1:2.0.5-7.el9.1.noarch  freetype-2.10.4-10.el9_5.x86_64           freetype-devel-2.10.4-10.el9_5.x86_64
  gd-2.3.2-3.el9.x86_64                 gd-devel-2.3.2-3.el9.x86_64                glib2-devel-2.68.4-14.el9_4.1.x86_64     graphite2-1.3.14-9.el9.x86_64             graphite2-devel-1.3.14-9.el9.x86_64
  harfbuzz-2.7.4-10.el9.x86_64          harfbuzz-devel-2.7.4-10.el9.x86_64         harfbuzz-icu-2.7.4-10.el9.x86_64         jbigkit-libs-2.1-23.el9.x86_64            langpacks-core-font-en-3.0-16.el9.noarch
  libICE-1.0.10-8.el9.x86_64            libSM-1.2.3-10.el9.x86_64                  libX11-1.7.0-9.el9.x86_64                libX11-common-1.7.0-9.el9.noarch          libX11-devel-1.7.0-9.el9.x86_64
  libX11-xcb-1.7.0-9.el9.x86_64         libXau-1.0.9-8.el9.x86_64                  libXau-devel-1.0.9-8.el9.x86_64          libXext-1.3.4-8.el9.x86_64                libXpm-3.5.13-10.el9.x86_64
  libXpm-devel-3.5.13-10.el9.x86_64     libXrender-0.9.10-16.el9.x86_64            libXt-1.2.0-6.el9.x86_64                 libblkid-devel-2.37.4-20.el9.x86_64       libffi-devel-3.4.2-8.el9.x86_64
  libgpg-error-devel-1.42-5.el9.x86_64  libicu-67.1-9.el9.x86_64                   libicu-devel-67.1-9.el9.x86_64           libjpeg-turbo-2.0.90-7.el9.x86_64         libjpeg-turbo-devel-2.0.90-7.el9.x86_64
  libmount-devel-2.37.4-20.el9.x86_64   libpng-2:1.6.37-12.el9.x86_64              libpng-devel-2:1.6.37-12.el9.x86_64      libselinux-devel-3.6-1.el9.x86_64         libsepol-devel-3.6-1.el9.x86_64
  libtiff-4.4.0-13.el9.x86_64           libtiff-devel-4.4.0-13.el9.x86_64          libwebp-1.2.0-8.el9_3.x86_64             libwebp-devel-1.2.0-8.el9_3.x86_64        libxcb-1.13.1-9.el9.x86_64
  libxcb-devel-1.13.1-9.el9.x86_64      libxml2-devel-2.9.13-6.el9_5.2.x86_64      libxslt-1.1.34-9.el9_5.3.x86_64          libxslt-devel-1.1.34-9.el9_5.3.x86_64     pcre-cpp-8.44-4.el9.x86_64
  pcre-devel-8.44-4.el9.x86_64          pcre-utf16-8.44-4.el9.x86_64               pcre-utf32-8.44-4.el9.x86_64             pcre2-devel-10.40-6.el9.x86_64            pcre2-utf16-10.40-6.el9.x86_64
  pcre2-utf32-10.40-6.el9.x86_64        perl-ExtUtils-Embed-1.35-481.el9.noarch    perl-Fedora-VSP-0.001-23.el9.noarch      perl-devel-4:5.32.1-481.el9.x86_64        perl-generators-1.11-12.el9.noarch
  pixman-0.40.0-6.el9_3.x86_64          sysprof-capture-devel-3.40.1-3.el9.x86_64  xml-common-0.6.3-58.el9.noarch           xorg-x11-proto-devel-2024.1-1.el9.noarch  xz-devel-5.2.5-8.el9_0.x86_64

Complete!
```

Также нужно скачать исходный код модуля ngx_brotli — он потребуется при сборке:
```console
[root@vbox ~]# git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
Cloning into 'ngx_brotli'...
remote: Enumerating objects: 237, done.
remote: Counting objects: 100% (37/37), done.
remote: Compressing objects: 100% (16/16), done.
remote: Total 237 (delta 24), reused 21 (delta 21), pack-reused 200 (from 1)
Receiving objects: 100% (237/237), 79.51 KiB | 1.30 MiB/s, done.
Resolving deltas: 100% (114/114), done.
Submodule 'deps/brotli' (https://github.com/google/brotli.git) registered for path 'deps/brotli'
Cloning into '/root/ngx_brotli/deps/brotli'...
remote: Enumerating objects: 7810, done.
remote: Counting objects: 100% (20/20), done.
remote: Compressing objects: 100% (19/19), done.
remote: Total 7810 (delta 11), reused 1 (delta 1), pack-reused 7790 (from 2)
Receiving objects: 100% (7810/7810), 40.62 MiB | 10.76 MiB/s, done.
Resolving deltas: 100% (5071/5071), done.
Submodule path 'deps/brotli': checked out 'ed738e842d2fbdf2d6459e39267a633c4a9b2f5d'

[root@vbox ~]# ll
total 0
drwxr-xr-x. 7 root root 179 May 19 19:19 ngx_brotli
drwxr-xr-x. 2 root root  48 May 19 18:38 rpm
drwxr-xr-x. 4 root root  34 May 19 19:12 rpmbuild

[root@vbox ~]# cd ngx_brotli/deps/brotli

/root/ngx_brotli/deps/brotli

[root@vbox brotli]# mkdir out && cd out
```

Собираем модуль ngx_brotli:
```console
[root@vbox out]# cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
-- The C compiler identification is GNU 11.5.0
-- Detecting C compiler ABI info
-- Detecting C compiler ABI info - done
-- Check for working C compiler: /bin/cc - skipped
-- Detecting C compile features
-- Detecting C compile features - done
-- Build type is 'Release'
-- Performing Test BROTLI_EMSCRIPTEN
-- Performing Test BROTLI_EMSCRIPTEN - Failed
-- Compiler is not EMSCRIPTEN
-- Looking for log2
-- Looking for log2 - not found
-- Looking for log2
-- Looking for log2 - found
-- Configuring done (0.5s)
-- Generating done (0.0s)
CMake Warning:
  Manually-specified variables were not used by the project:
    CMAKE_CXX_FLAGS
-- Build files have been written to: /root/ngx_brotli/deps/brotli/out

[root@vbox out]# cmake --build . --config Release -j 2 --target brotlienc
[  3%] Building C object CMakeFiles/brotlicommon.dir/c/common/constants.c.o
[  6%] Building C object CMakeFiles/brotlicommon.dir/c/common/context.c.o
[ 10%] Building C object CMakeFiles/brotlicommon.dir/c/common/dictionary.c.o
[ 13%] Building C object CMakeFiles/brotlicommon.dir/c/common/platform.c.o
[ 17%] Building C object CMakeFiles/brotlicommon.dir/c/common/shared_dictionary.c.o
[ 20%] Building C object CMakeFiles/brotlicommon.dir/c/common/transform.c.o
[ 24%] Linking C static library libbrotlicommon.a
[ 24%] Built target brotlicommon
[ 27%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references.c.o
[ 31%] Building C object CMakeFiles/brotlienc.dir/c/enc/backward_references_hq.c.o
[ 34%] Building C object CMakeFiles/brotlienc.dir/c/enc/bit_cost.c.o
[ 37%] Building C object CMakeFiles/brotlienc.dir/c/enc/block_splitter.c.o
[ 41%] Building C object CMakeFiles/brotlienc.dir/c/enc/brotli_bit_stream.c.o
[ 44%] Building C object CMakeFiles/brotlienc.dir/c/enc/cluster.c.o
[ 48%] Building C object CMakeFiles/brotlienc.dir/c/enc/command.c.o
[ 51%] Building C object CMakeFiles/brotlienc.dir/c/enc/compound_dictionary.c.o
[ 55%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment.c.o
[ 58%] Building C object CMakeFiles/brotlienc.dir/c/enc/compress_fragment_two_pass.c.o
[ 62%] Building C object CMakeFiles/brotlienc.dir/c/enc/dictionary_hash.c.o
[ 65%] Building C object CMakeFiles/brotlienc.dir/c/enc/encode.c.o
[ 68%] Building C object CMakeFiles/brotlienc.dir/c/enc/encoder_dict.c.o
[ 72%] Building C object CMakeFiles/brotlienc.dir/c/enc/entropy_encode.c.o
[ 75%] Building C object CMakeFiles/brotlienc.dir/c/enc/fast_log.c.o
[ 79%] Building C object CMakeFiles/brotlienc.dir/c/enc/histogram.c.o
[ 82%] Building C object CMakeFiles/brotlienc.dir/c/enc/literal_cost.c.o
[ 86%] Building C object CMakeFiles/brotlienc.dir/c/enc/memory.c.o
[ 89%] Building C object CMakeFiles/brotlienc.dir/c/enc/metablock.c.o
[ 93%] Building C object CMakeFiles/brotlienc.dir/c/enc/static_dict.c.o
[ 96%] Building C object CMakeFiles/brotlienc.dir/c/enc/utf8_util.c.o
[100%] Linking C static library libbrotlienc.a
[100%] Built target brotlienc
```

Нужно поправить сам spec файл, чтобы Nginx собирался с необходимыми нам опциями: находим секцию с параметрами configure (до условий if)  
и добавляем указание на модуль (не забудьте указать завершающий обратный слэш):  
_--add-module=/root/ngx_brotli \_  
По [этой](https://nginx.org/ru/docs/configure.html) ссылке можно посмотреть все доступные опции для сборки.  
Теперь можно приступить к сборке RPM пакета:
```console
[root@vbox ~]# cd ~/rpmbuild/SPECS/

[root@vbox SPECS]# rpmbuild -ba nginx.spec -D 'debug_package %{nil}'
...
Checking for unpackaged file(s): /usr/lib/rpm/check-files /root/rpmbuild/BUILDROOT/nginx-1.20.1-20.el9.alma.1.x86_64
Wrote: /root/rpmbuild/SRPMS/nginx-1.20.1-20.el9.alma.1.src.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-image-filter-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/x86_64/nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1.x86_64.rpm
Wrote: /root/rpmbuild/RPMS/noarch/nginx-all-modules-1.20.1-20.el9.alma.1.noarch.rpm
Wrote: /root/rpmbuild/RPMS/noarch/nginx-filesystem-1.20.1-20.el9.alma.1.noarch.rpm
Executing(%clean): /bin/sh -e /var/tmp/rpm-tmp.sVRvmN
+ umask 022
+ cd /root/rpmbuild/BUILD
+ cd nginx-1.20.1
+ /usr/bin/rm -rf /root/rpmbuild/BUILDROOT/nginx-1.20.1-20.el9.alma.1.x86_64
+ RPM_EC=0
++ jobs -p
+ exit 0
```

Убедимся, что пакеты создались:
```console
[root@vbox SPECS]# ll ~/rpmbuild/RPMS/x86_64/
total 2000
-rw-r--r--. 1 root root   36234 May 20 13:13 nginx-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root 1035322 May 20 13:13 nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root  759882 May 20 13:13 nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   19365 May 20 13:13 nginx-mod-http-image-filter-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   30996 May 20 13:13 nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   18160 May 20 13:13 nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   53797 May 20 13:13 nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   80417 May 20 13:13 nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm
```

Копируем пакеты в общий каталог:
```console
[root@vbox SPECS]# cp ~/rpmbuild/RPMS/noarch/* ~/rpmbuild/RPMS/x86_64/

[root@vbox SPECS]# cd ~/rpmbuild/RPMS/x86_64/
```

Теперь можно установить наш пакет и убедиться, что nginx работает:
```console
[root@vbox x86_64]# yum localinstall *.rpm
...
Installed:
  almalinux-logos-httpd-90.5.1-1.1.el9.noarch                              nginx-2:1.20.1-20.el9.alma.1.x86_64                              nginx-all-modules-2:1.20.1-20.el9.alma.1.noarch
  nginx-core-2:1.20.1-20.el9.alma.1.x86_64                                 nginx-filesystem-2:1.20.1-20.el9.alma.1.noarch                   nginx-mod-devel-2:1.20.1-20.el9.alma.1.x86_64
  nginx-mod-http-image-filter-2:1.20.1-20.el9.alma.1.x86_64                nginx-mod-http-perl-2:1.20.1-20.el9.alma.1.x86_64                nginx-mod-http-xslt-filter-2:1.20.1-20.el9.alma.1.x86_64
  nginx-mod-mail-2:1.20.1-20.el9.alma.1.x86_64                             nginx-mod-stream-2:1.20.1-20.el9.alma.1.x86_64
Complete!

[root@vbox x86_64]# systemctl start nginx

[root@vbox x86_64]# systemctl status nginx
● nginx.service - The nginx HTTP and reverse proxy server
     Loaded: loaded (/usr/lib/systemd/system/nginx.service; disabled; preset: disabled)
     Active: active (running) since Tue 2025-05-20 13:19:14 UTC; 1s ago
    Process: 32586 ExecStartPre=/usr/bin/rm -f /run/nginx.pid (code=exited, status=0/SUCCESS)
    Process: 32587 ExecStartPre=/usr/sbin/nginx -t (code=exited, status=0/SUCCESS)
    Process: 32588 ExecStart=/usr/sbin/nginx (code=exited, status=0/SUCCESS)
   Main PID: 32589 (nginx)
      Tasks: 2 (limit: 5473)
     Memory: 5.8M
        CPU: 26ms
     CGroup: /system.slice/nginx.service
             ├─32589 "nginx: master process /usr/sbin/nginx"
             └─32590 "nginx: worker process"

May 20 13:19:14 vbox systemd[1]: Starting The nginx HTTP and reverse proxy server...
May 20 13:19:14 vbox nginx[32587]: nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
May 20 13:19:14 vbox nginx[32587]: nginx: configuration file /etc/nginx/nginx.conf test is successful
May 20 13:19:14 vbox systemd[1]: Started The nginx HTTP and reverse proxy server.
```
Далее мы будем использовать его для доступа к своему репозиторию.


**2) Создать свой репозиторий и разместить там ранее собранный RPM пакет:**

Теперь приступим к созданию своего репозитория.  
Директория для статики у Nginx по умолчанию /usr/share/nginx/html. Создадим там каталог repo:
```console
[root@vbox x86_64]# ll /usr/share/nginx/html/
total 12
-rw-r--r--. 1 root root 3797 Oct  3  2024 404.html
-rw-r--r--. 1 root root 3846 Oct  3  2024 50x.html
drwxr-xr-x. 2 root root   27 May 20 13:19 icons
lrwxrwxrwx. 1 root root   25 May 20 13:13 index.html -> ../../testpage/index.html
-rw-r--r--. 1 root root  368 Oct  3  2024 nginx-logo.png
lrwxrwxrwx. 1 root root   14 May 20 13:13 poweredby.png -> nginx-logo.png
lrwxrwxrwx. 1 root root   37 May 20 13:13 system_noindex_logo.png -> ../../pixmaps/system-noindex-logo.png

[root@vbox x86_64]# mkdir /usr/share/nginx/html/repo
```

Копируем туда наши собранные RPM-пакеты:
```console
[root@vbox x86_64]# cp ~/rpmbuild/RPMS/x86_64/*.rpm /usr/share/nginx/html/repo/

[root@vbox x86_64]# ll /usr/share/nginx/html/repo
total 2020
-rw-r--r--. 1 root root   36234 May 20 13:25 nginx-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root    7345 May 20 13:25 nginx-all-modules-1.20.1-20.el9.alma.1.noarch.rpm
-rw-r--r--. 1 root root 1035322 May 20 13:25 nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root    8430 May 20 13:25 nginx-filesystem-1.20.1-20.el9.alma.1.noarch.rpm
-rw-r--r--. 1 root root  759882 May 20 13:25 nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   19365 May 20 13:25 nginx-mod-http-image-filter-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   30996 May 20 13:25 nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   18160 May 20 13:25 nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   53797 May 20 13:25 nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm
-rw-r--r--. 1 root root   80417 May 20 13:25 nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm
```

Инициализируем репозиторий командой:
```console
[root@vbox x86_64]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 10 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished
```

Для прозрачности настроим в NGINX доступ к листингу каталога.  
В файле /etc/nginx/nginx.conf в блоке server добавим следующие директивы:  
_index index.html index.htm;  
autoindex on;_  
```console
[root@vbox x86_64]# nano /etc/nginx/nginx.conf
```

Проверяем синтаксис и перезапускаем NGINX:
```console
[root@vbox x86_64]# nginx -t
nginx: the configuration file /etc/nginx/nginx.conf syntax is ok
nginx: configuration file /etc/nginx/nginx.conf test is successful

[root@vbox x86_64]# nginx -s reload
```

Теперь ради интереса можно посмотреть в браузере или с помощью curl:
```console
[root@vbox x86_64]# curl -a http://localhost/repo/

<html>
<head><title>Index of /repo/</title></head>
<body>
<h1>Index of /repo/</h1><hr><pre><a href="../">../</a>
<a href="repodata/">repodata/</a>                                          20-May-2025 13:25                   -
<a href="nginx-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-1.20.1-20.el9.alma.1.x86_64.rpm</a>              20-May-2025 13:25               36234
<a href="nginx-all-modules-1.20.1-20.el9.alma.1.noarch.rpm">nginx-all-modules-1.20.1-20.el9.alma.1.noarch.rpm</a>  20-May-2025 13:25                7345
<a href="nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-core-1.20.1-20.el9.alma.1.x86_64.rpm</a>         20-May-2025 13:25             1035322
<a href="nginx-filesystem-1.20.1-20.el9.alma.1.noarch.rpm">nginx-filesystem-1.20.1-20.el9.alma.1.noarch.rpm</a>   20-May-2025 13:25                8430
<a href="nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-devel-1.20.1-20.el9.alma.1.x86_64.rpm</a>    20-May-2025 13:25              759882
<a href="nginx-mod-http-image-filter-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-http-image-filter-1.20.1-20.el9.alma...&gt;</a> 20-May-2025 13:25               19365
<a href="nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-http-perl-1.20.1-20.el9.alma.1.x86_64..&gt;</a> 20-May-2025 13:25               30996
<a href="nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-http-xslt-filter-1.20.1-20.el9.alma.1..&gt;</a> 20-May-2025 13:25               18160
<a href="nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-mail-1.20.1-20.el9.alma.1.x86_64.rpm</a>     20-May-2025 13:25               53797
<a href="nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm">nginx-mod-stream-1.20.1-20.el9.alma.1.x86_64.rpm</a>   20-May-2025 13:25               80417
</pre><hr></body>
</html>
```

Все готово для того, чтобы протестировать репозиторий.  
Добавим его в /etc/yum.repos.d:
```console
[root@vbox x86_64]# cat >> /etc/yum.repos.d/otus.repo << EOF
> [otus]
> name=otus-linux
> baseurl=http://localhost/repo
> gpgcheck=0
> enabled=1
> EOF

[root@vbox x86_64]# yum repolist enabled | grep otus
otus                             otus-linux

[root@vbox x86_64]# cd /usr/share/nginx/html/repo/

[root@vbox repo]# wget https://repo.percona.com/yum/percona-release-latest.noarch.rpm
--2025-05-20 13:34:32--  https://repo.percona.com/yum/percona-release-latest.noarch.rpm
Resolving repo.percona.com (repo.percona.com)... 49.12.125.205, 2a01:4f8:242:5792::2
Connecting to repo.percona.com (repo.percona.com)|49.12.125.205|:443... connected.
HTTP request sent, awaiting response... 200 OK
Length: 28300 (28K) [application/x-redhat-package-manager]
Saving to: ‘percona-release-latest.noarch.rpm’

percona-release-latest.noarch.rpm                    100%[=====================================================================================================================>]  27.64K  --.-KB/s    in 0.001s

2025-05-20 13:34:32 (27.4 MB/s) - ‘percona-release-latest.noarch.rpm’ saved [28300/28300]
```

Обновим список пакетов в репозитории:
```console
[root@vbox repo]# createrepo /usr/share/nginx/html/repo/
Directory walk started
Directory walk done - 11 packages
Temporary output repo path: /usr/share/nginx/html/repo/.repodata/
Preparing sqlite DBs
Pool started (with 5 workers)
Pool finished

[root@vbox repo]# yum makecache
AlmaLinux 9 - AppStream                                                                                                                                                            6.0 kB/s | 4.2 kB     00:00
AlmaLinux 9 - BaseOS                                                                                                                                                               5.6 kB/s | 3.8 kB     00:00
AlmaLinux 9 - Extras                                                                                                                                                               4.6 kB/s | 3.3 kB     00:00
otus-linux                                                                                                                                                                         3.1 MB/s | 7.2 kB     00:00
Metadata cache created.

[root@vbox repo]# yum list | grep otus
percona-release.noarch                               1.0-30                              otus
```

Так как Nginx у нас уже стоит, установим репозиторий percona-release:
```console
[root@vbox repo]# yum install -y percona-release.noarch
Last metadata expiration check: 0:01:30 ago on Tue May 20 13:34:59 2025.
Dependencies resolved.
===================================================================================================================================================================================================================
 Package                                                   Architecture                                     Version                                           Repository                                      Size
===================================================================================================================================================================================================================
Installing:
 percona-release                                           noarch                                           1.0-30                                            otus                                            28 k

Transaction Summary
===================================================================================================================================================================================================================
Install  1 Package
...
Installed:
  percona-release-1.0-30.noarch

Complete!
```
Все прошло успешно. В случае, если потребуется обновить репозиторий (а это  
делается при каждом добавлении файлов) снова, необходимо выполнить команду:  
_#createrepo /usr/share/nginx/html/repo/_


**Задание со * "Создать свой DEB пакет":**

Обновим списки доступных пакетов:
```console
root@test:~# apt update
…
All packages are up to date.
```

Установим окружение для сборки:
```console
root@test:~# apt install -y dpkg-dev build-essential zlib1g-dev libpcre3 libpcre3-dev unzip
```

Внесем изменения в sources.list:  
(раскоментим (или впишем руками) deb-src, который указывает на то, что данный репозиторий содержит исходные коды пакетов вместо бинарных файлов)
```console
nano /etc/apt/sources.list
```

Установим зависимости для сборки:
```console
root@test:~# apt install -y cmake debhelper-compat libexpat-dev libgd-dev libgeoip-dev libhiredis-dev libmaxminddb-dev libmhash-dev libpam0g-dev libperl-dev libssl-dev libxslt1-dev quilt
```

Создадим директорию для сборки и скачаем исходные файлы nginx:
```console
root@test:~# mkdir ~/custom-nginx && cd ~/custom-nginx

root@test:~/custom-nginx# apt source nginx
```

Перейдём в суб директорию и скачаем модуль brotli:
```console
root@test:~/custom-nginx# cd nginx-1.18.0/debian/modules

root@test:~/custom-nginx/nginx-1.18.0/debian/modules# git clone --recurse-submodules -j8 https://github.com/google/ngx_brotli
…
Submodule path 'deps/brotli': checked out 'ed738e842d2fbdf2d6459e39267a633c4a9b2f5d'
```

Перейдём в директорию модуля brotli и создадим директорию для сборки:
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules# cd ngx_brotli/deps/brotli

root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli# mkdir out && cd out
```

Подготовим сборку:
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# cmake -DCMAKE_BUILD_TYPE=Release -DBUILD_SHARED_LIBS=OFF -DCMAKE_C_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_CXX_FLAGS="-Ofast -m64 -march=native -mtune=native -flto -funroll-loops -ffunction-sections -fdata-sections -Wl,--gc-sections" -DCMAKE_INSTALL_PREFIX=./installed ..
…
-- Build files have been written to: /root/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out

root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# cmake --build . --config Release --target brotlienc
…
[100%] Built target brotlienc
```

Редактируем файл сборки, добавляем модуль brotli в раздел # configure flags:
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# nano ~/custom-nginx/nginx-1.18.0/debian/rules
--add-module=$(MODULESDIR)/ngx_brotli \
```

Редактируем файл версии, добавляем тег -custom к последней версии сборки:
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# nano ~/custom-nginx/nginx-1.18.0/debian/changelog
```

Собираем пакет
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# cd ~/custom-nginx/nginx-1.18.0/
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# dpkg-buildpackage -b
```

Смотрим собраные пакеты:
```console
root@test:~/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli/deps/brotli/out# cd ~/custom-nginx/

root@test:~/custom-nginx# ll *.deb
-rw-r--r-- 1 root root  41958 Jul  4 22:08 libnginx-mod-http-auth-pam_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  44510 Jul  4 22:08 libnginx-mod-http-cache-purge_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  50000 Jul  4 22:08 libnginx-mod-http-dav-ext_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  54724 Jul  4 22:08 libnginx-mod-http-echo_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  47288 Jul  4 22:08 libnginx-mod-http-fancyindex_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  43248 Jul  4 22:08 libnginx-mod-http-geoip_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  43824 Jul  4 22:08 libnginx-mod-http-geoip2_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  47738 Jul  4 22:08 libnginx-mod-http-headers-more-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  47300 Jul  4 22:08 libnginx-mod-http-image-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  39070 Jul  4 22:08 libnginx-mod-http-ndk_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  56098 Jul  4 22:08 libnginx-mod-http-perl_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  45172 Jul  4 22:08 libnginx-mod-http-subs-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  49326 Jul  4 22:08 libnginx-mod-http-uploadprogress_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  45394 Jul  4 22:08 libnginx-mod-http-upstream-fair_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  45700 Jul  4 22:08 libnginx-mod-http-xslt-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  77760 Jul  4 22:08 libnginx-mod-mail_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root 261862 Jul  4 22:08 libnginx-mod-nchan_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root 166230 Jul  4 22:08 libnginx-mod-rtmp_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root 104784 Jul  4 22:08 libnginx-mod-stream_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  42330 Jul  4 22:08 libnginx-mod-stream-geoip_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  43328 Jul  4 22:08 libnginx-mod-stream-geoip2_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  37080 Jul  4 22:08 nginx_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  72366 Jul  4 22:08 nginx-common_1.18.0-6ubuntu14-custom-brotli_all.deb
-rw-r--r-- 1 root root 957596 Jul  4 22:08 nginx-core_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  46506 Jul  4 22:08 nginx-doc_1.18.0-6ubuntu14-custom-brotli_all.deb
-rw-r--r-- 1 root root 969736 Jul  4 22:08 nginx-extras_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root  37550 Jul  4 22:08 nginx-full_1.18.0-6ubuntu14-custom-brotli_amd64.deb
-rw-r--r-- 1 root root 931846 Jul  4 22:08 nginx-light_1.18.0-6ubuntu14-custom-brotli_amd64.deb
```

Фиксируем пакет nginx:  
(Команда apt-mark hold используется для пометки пакета как "задержанного",  
что предотвращает его автоматическую установку, обновление или удаление с помощью apt.  
Она полезна, когда нужно зафиксировать определенную версию пакета или избежать нежелательных изменений в системе. )
```console
root@test:~/custom-nginx# apt-mark hold nginx
nginx set on hold.
```

Установим nginx из только что собранного пакета:
```console
root@test:~/custom-nginx# dpkg -i ./*.deb
Selecting previously unselected package libnginx-mod-http-auth-pam.
(Reading database ... 122770 files and directories currently installed.)
Preparing to unpack .../libnginx-mod-http-auth-pam_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-auth-pam (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-cache-purge.
Preparing to unpack .../libnginx-mod-http-cache-purge_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-cache-purge (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-dav-ext.
Preparing to unpack .../libnginx-mod-http-dav-ext_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-dav-ext (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-echo.
Preparing to unpack .../libnginx-mod-http-echo_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-echo (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-fancyindex.
Preparing to unpack .../libnginx-mod-http-fancyindex_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-fancyindex (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-geoip.
Preparing to unpack .../libnginx-mod-http-geoip_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-geoip (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-geoip2.
Preparing to unpack .../libnginx-mod-http-geoip2_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-geoip2 (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-headers-more-filter.
Preparing to unpack .../libnginx-mod-http-headers-more-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-headers-more-filter (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-image-filter.
Preparing to unpack .../libnginx-mod-http-image-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-image-filter (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-ndk.
Preparing to unpack .../libnginx-mod-http-ndk_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-ndk (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-perl.
Preparing to unpack .../libnginx-mod-http-perl_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-perl (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-subs-filter.
Preparing to unpack .../libnginx-mod-http-subs-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-subs-filter (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-uploadprogress.
Preparing to unpack .../libnginx-mod-http-uploadprogress_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-uploadprogress (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-upstream-fair.
Preparing to unpack .../libnginx-mod-http-upstream-fair_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-upstream-fair (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-http-xslt-filter.
Preparing to unpack .../libnginx-mod-http-xslt-filter_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-http-xslt-filter (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-mail.
Preparing to unpack .../libnginx-mod-mail_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-mail (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-nchan.
Preparing to unpack .../libnginx-mod-nchan_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-nchan (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-rtmp.
Preparing to unpack .../libnginx-mod-rtmp_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-rtmp (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-stream.
Preparing to unpack .../libnginx-mod-stream_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-stream (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-stream-geoip.
Preparing to unpack .../libnginx-mod-stream-geoip_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-stream-geoip (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package libnginx-mod-stream-geoip2.
Preparing to unpack .../libnginx-mod-stream-geoip2_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking libnginx-mod-stream-geoip2 (1.18.0-6ubuntu14-custom-brotli) ...
Preparing to unpack .../nginx_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking nginx (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package nginx-common.
Preparing to unpack .../nginx-common_1.18.0-6ubuntu14-custom-brotli_all.deb ...
Unpacking nginx-common (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package nginx-core.
Preparing to unpack .../nginx-core_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking nginx-core (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package nginx-doc.
Preparing to unpack .../nginx-doc_1.18.0-6ubuntu14-custom-brotli_all.deb ...
Unpacking nginx-doc (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package nginx-extras.
dpkg: regarding .../nginx-extras_1.18.0-6ubuntu14-custom-brotli_amd64.deb containing nginx-extras:
 nginx-extras conflicts with nginx-core
  nginx-core (version 1.18.0-6ubuntu14-custom-brotli) is present and unpacked but not configured.

dpkg: error processing archive ./nginx-extras_1.18.0-6ubuntu14-custom-brotli_amd64.deb (--install):
 conflicting packages - not installing nginx-extras
Selecting previously unselected package nginx-full.
Preparing to unpack .../nginx-full_1.18.0-6ubuntu14-custom-brotli_amd64.deb ...
Unpacking nginx-full (1.18.0-6ubuntu14-custom-brotli) ...
Selecting previously unselected package nginx-light.
dpkg: regarding .../nginx-light_1.18.0-6ubuntu14-custom-brotli_amd64.deb containing nginx-light:
 nginx-light conflicts with nginx-core
  nginx-core (version 1.18.0-6ubuntu14-custom-brotli) is present and unpacked but not configured.

dpkg: error processing archive ./nginx-light_1.18.0-6ubuntu14-custom-brotli_amd64.deb (--install):
 conflicting packages - not installing nginx-light
Setting up nginx-common (1.18.0-6ubuntu14-custom-brotli) ...
Created symlink /etc/systemd/system/multi-user.target.wants/nginx.service → /lib/systemd/system/nginx.service.
Setting up nginx-doc (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-auth-pam (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-cache-purge (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-dav-ext (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-echo (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-fancyindex (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-geoip (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-geoip2 (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-headers-more-filter (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-image-filter (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-ndk (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-perl (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-subs-filter (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-uploadprogress (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-upstream-fair (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-http-xslt-filter (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-mail (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-nchan (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-rtmp (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-stream (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-stream-geoip (1.18.0-6ubuntu14-custom-brotli) ...
Setting up libnginx-mod-stream-geoip2 (1.18.0-6ubuntu14-custom-brotli) ...
Setting up nginx-core (1.18.0-6ubuntu14-custom-brotli) ...
 * Upgrading binary nginx                                                                                                                     [ OK ]
Setting up nginx-full (1.18.0-6ubuntu14-custom-brotli) ...
Setting up nginx (1.18.0-6ubuntu14-custom-brotli) ...
Processing triggers for ufw (0.36.1-4ubuntu0.1) ...
Processing triggers for man-db (2.10.2-1) ...
Errors were encountered while processing:
 ./nginx-extras_1.18.0-6ubuntu14-custom-brotli_amd64.deb
 ./nginx-light_1.18.0-6ubuntu14-custom-brotli_amd64.deb
```

Проверим статус текущее состояние nginx:
```console
root@test:~# systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Fri 2025-07-04 22:30:15 MSK; 57s ago
       Docs: man:nginx(8)
    Process: 632 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 698 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 706 (nginx)
      Tasks: 3 (limit: 2220)
     Memory: 23.9M
        CPU: 241ms
     CGroup: /system.slice/nginx.service
             ├─706 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             ├─707 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""
             └─708 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Jul 04 22:30:14 test systemd[1]: Starting A high performance web server and a reverse proxy server...
Jul 04 22:30:15 test systemd[1]: Started A high performance web server and a reverse proxy server.
```

Посмотрим версия nginx и состав модулей:
```console
root@test:~# nginx -v
nginx version: nginx/1.18.0 (Ubuntu)

root@test:~# nginx -V
nginx version: nginx/1.18.0 (Ubuntu)
built with OpenSSL 3.0.2 15 Mar 2022
TLS SNI support enabled
configure arguments: --with-cc-opt='-g -O2 -ffile-prefix-map=/root/custom-nginx/nginx-1.18.0=. -flto=auto -ffat-lto-objects -flto=auto -ffat-lto-objects -fstack-protector-strong -Wformat -Werror=format-security -fPIC -Wdate-time -D_FORTIFY_SOURCE=2' --with-ld-opt='-Wl,-Bsymbolic-functions -flto=auto -ffat-lto-objects -flto=auto -Wl,-z,relro -Wl,-z,now -fPIC' --prefix=/usr/share/nginx --conf-path=/etc/nginx/nginx.conf --http-log-path=/var/log/nginx/access.log --error-log-path=/var/log/nginx/error.log --lock-path=/var/lock/nginx.lock --pid-path=/run/nginx.pid --modules-path=/usr/lib/nginx/modules --http-client-body-temp-path=/var/lib/nginx/body --http-fastcgi-temp-path=/var/lib/nginx/fastcgi --http-proxy-temp-path=/var/lib/nginx/proxy --http-scgi-temp-path=/var/lib/nginx/scgi --http-uwsgi-temp-path=/var/lib/nginx/uwsgi --with-compat --with-debug --with-pcre-jit --with-http_ssl_module --with-http_stub_status_module --with-http_realip_module --with-http_auth_request_module --with-http_v2_module --with-http_dav_module --with-http_slice_module --with-threads --add-dynamic-module=/root/custom-nginx/nginx-1.18.0/debian/modules/http-geoip2 --add-module=/root/custom-nginx/nginx-1.18.0/debian/modules/ngx_brotli --with-http_addition_module --with-http_gunzip_module --with-http_gzip_static_module --with-http_sub_module
```

Посмотрим информации о сетевых соединениях, связанных с nginx:
```console
root@test:~# ss -tulpn | grep nginx
tcp   LISTEN 0      511                  0.0.0.0:80          0.0.0.0:*     users:(("nginx",pid=708,fd=6),("nginx",pid=707,fd=6),("nginx",pid=706,fd=6))
tcp   LISTEN 0      511                     [::]:80             [::]:*     users:(("nginx",pid=708,fd=7),("nginx",pid=707,fd=7),("nginx",pid=706,fd=7))
root@test:~# ps -aux | grep nginx
root         706  0.0  0.2 203736  5532 ?        Ss   22:30   0:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
www-data     707  0.0  0.5 204472 10988 ?        S    22:30   0:00 nginx: worker process
www-data     708  0.0  0.5 204472 11048 ?        S    22:30   0:00 nginx: worker process
root        1001  0.0  0.1   6480  2252 pts/1    S+   22:33   0:00 grep --color=auto nginx
```


root@test:~# ps -elf | grep nginx
1 S root         706       1  0  80   0 - 50934 sigsus 22:30 ?        00:00:00 nginx: master process /usr/sbin/nginx -g daemon on; master_process on;
5 S www-data     707     706  0  80   0 - 51118 ep_pol 22:30 ?        00:00:00 nginx: worker process
5 S www-data     708     706  0  80   0 - 51118 ep_pol 22:30 ?        00:00:00 nginx: worker process
0 S root        1003     855  0  80   0 -  1620 pipe_r 22:34 pts/1    00:00:00 grep --color=auto nginx

root@test:~# ip a | grep inet
    inet 127.0.0.1/8 scope host lo
    inet6 ::1/128 scope host
    inet 192.168.131.72/24 metric 100 brd 192.168.131.255 scope global dynamic enp0s3
    inet6 2a03:d000:4224:573e:a00:27ff:feab:1b53/64 scope global dynamic mngtmpaddr noprefixroute
    inet6 fe80::a00:27ff:feab:1b53/64 scope link
root@test:~# curl 192.168.131.72
<!DOCTYPE html>
<html>
<head>
<title>Welcome to nginx!</title>
<style>
    body {
        width: 35em;
        margin: 0 auto;
        font-family: Tahoma, Verdana, Arial, sans-serif;
    }
</style>
</head>
<body>
<h1>Welcome to nginx!</h1>
<p>If you see this page, the nginx web server is successfully installed and
working. Further configuration is required.</p>

<p>For online documentation and support please refer to
<a href="http://nginx.org/">nginx.org</a>.<br/>
Commercial support is available at
<a href="http://nginx.com/">nginx.com</a>.</p>

<p><em>Thank you for using nginx.</em></p>
</body>
</html>
```


Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
