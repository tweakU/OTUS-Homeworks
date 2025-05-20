## Домашнее задание № 7 — «Управление пакетами. Дистрибьюция софта.»

Цель домашнего задания: 1) Создать свой RPM пакет; 2) Создать свой репозиторий и разместить там ранее собранный RPM пакет в операционной системе (ОС) GNU/Linux.

Выполнение домашнего задания:

1) Создать свой RPM пакет:

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

yumdownloader - Download package to current directory
```console
[root@vbox ~]# mkdir rpm && cd rpm

[root@vbox rpm]# yumdownloader --source nginx

[root@vbox rpm]# ll
total 1084
-rw-r--r--. 1 root root 1109119 May 19 17:57 nginx-1.20.1-20.el9.alma.1.src.rpm

[root@vbox rpm]# rpm -Uvh nginx-1.20.1-20.el9.alma.1.src.rpm
Updating / installing...
   1:nginx-2:1.20.1-20.el9.alma.1     ################################# [100%]

[root@vbox rpm]# ll ~/
total 0
drwxr-xr-x. 2 root root 48 May 19 18:38 rpm
drwxr-xr-x. 4 root root 34 May 19 19:12 rpmbuild
```

yum-builddep - Install build dependencies for package or spec file
```console
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
```



```console
[root@vbox ~]# cd ngx_brotli/deps/brotli

/root/ngx_brotli/deps/brotli

[root@vbox brotli]# mkdir out && cd out

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
```

```console
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

```console
[root@vbox SPECS]# cd ~/rpmbuild/RPMS/x86_64/
[
root@vbox x86_64]# yum localinstall *.rpm
...
Installed:
  almalinux-logos-httpd-90.5.1-1.1.el9.noarch                              nginx-2:1.20.1-20.el9.alma.1.x86_64                              nginx-all-modules-2:1.20.1-20.el9.alma.1.noarch
  nginx-core-2:1.20.1-20.el9.alma.1.x86_64                                 nginx-filesystem-2:1.20.1-20.el9.alma.1.noarch                   nginx-mod-devel-2:1.20.1-20.el9.alma.1.x86_64
  nginx-mod-http-image-filter-2:1.20.1-20.el9.alma.1.x86_64                nginx-mod-http-perl-2:1.20.1-20.el9.alma.1.x86_64                nginx-mod-http-xslt-filter-2:1.20.1-20.el9.alma.1.x86_64
  nginx-mod-mail-2:1.20.1-20.el9.alma.1.x86_64                             nginx-mod-stream-2:1.20.1-20.el9.alma.1.x86_64

Complete!
```

```console
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



2) Создать свой репозиторий и разместить там ранее собранный RPM пакет:

```console

```











```console

```

Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
