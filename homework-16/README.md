## Домашнее задание № 16 — «Ansible»

**Цель домашнего задания: Написать первые шаги с Ansible**.

**Выполнение домашнего задания**:

1) Установим Vagrant + гипервизор Virtualbox, Ansible и подготовим стенд Vagrant с одним сервером:

```console
root@test:~/otus/hw-16/Ansible# apt update
...
All packages are up to date.

root@test:~/otus/hw-16/Ansible# apt install vagrant
...

root@test:~/otus/hw-16/Ansible# vagrant -v
Vagrant 2.2.19

root@test:~/otus/hw-16/Ansible# apt install virtualbox

root@test:~/otus/hw-16/Ansible# python3 -V
Python 3.10.12

root@test:~/otus/hw-16/Ansible# apt install pipx

root@test:~/otus/hw-16/Ansible# pipx install --include-deps ansible
...

root@test:~/otus/hw-16/Ansible# ansible --version
ansible [core 2.17.13]
  config file = /root/otus/hw-16/Ansible/ansible.cfg
  configured module search path = ['/root/.ansible/plugins/modules', '/usr/share/ansible/plugins/modules']
  ansible python module location = /root/.local/pipx/venvs/ansible/lib/python3.10/site-packages/ansible
  ansible collection location = /root/.ansible/collections:/usr/share/ansible/collections
  executable location = /root/.local/bin/ansible
  python version = 3.10.12 (main, May 27 2025, 17:12:29) [GCC 11.4.0] (/root/.local/pipx/venvs/ansible/bin/python)
  jinja version = 3.1.6
  libyaml = True
```

Инициализируем создание и запуск ВМ, описанной в Vagrantfile:
```console
root@test:~/otus/hw-16/Ansible# vagrant up
Bringing machine 'nginx' up with 'virtualbox' provider...
==> nginx: Clearing any previously set forwarded ports...
==> nginx: Clearing any previously set network interfaces...
==> nginx: Preparing network interfaces based on configuration...
    nginx: Adapter 1: nat
    nginx: Adapter 2: intnet
==> nginx: Forwarding ports...
    nginx: 22 (guest) => 2222 (host) (adapter 1)
==> nginx: Running 'pre-boot' VM customizations...
==> nginx: Booting VM...
==> nginx: Waiting for machine to boot. This may take a few minutes...
    nginx: SSH address: 127.0.0.1:2222
    nginx: SSH username: vagrant
    nginx: SSH auth method: private key
==> nginx: Machine booted and ready!
==> nginx: Checking for guest additions in VM...
==> nginx: Setting hostname...
==> nginx: Configuring and enabling network interfaces...
==> nginx: Machine already provisioned. Run `vagrant provision` or use the `--provision`
==> nginx: flag to force provisioning. Provisioners marked to run always will still run.
```

Посмотрим информацию о настройках SSH для текущей виртуальной машины Vagrant,  
чтобы подключиться к ней через SSH вручную, если это необходимо.  
Она показывает параметры, такие как адрес хоста, порт, имя пользователя и приватный ключ,  
которые можно использовать для подключения к виртуальной машине через SSH-клиент.
```console
root@test:~/otus/hw-16/Ansible# vagrant ssh-config
Host nginx
  HostName 127.0.0.1
  User vagrant
  Port 2222
  UserKnownHostsFile /dev/null
  StrictHostKeyChecking no
  PasswordAuthentication no
  IdentityFile /root/otus/hw-16/Ansible/.vagrant/machines/nginx/virtualbox/private_key
  IdentitiesOnly yes
  LogLevel FATAL
```

Создадим свой первый inventory файл ./staging/hosts со следующим содержимым:  
[web]  
nginx ansible_host=127.0.0.1 ansible_port=2222 ansible_user=vagrant ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key  
и, наконец, убедимся, что Ansible может управлять нашим хостом. Сделать это можно с помощью команды:  
```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m ping -i ./staging/hosts
The authenticity of host '[127.0.0.1]:2222 ([127.0.0.1]:2222)' can't be established.
ED25519 key fingerprint is SHA256:EWxVoEMJqTStkgmL9GA+FenBnF4rbSqPvYiJPWFVRew.
This key is not known by any other names
Are you sure you want to continue connecting (yes/no/[fingerprint])? yes
[WARNING]: Platform linux on host nginx is using the discovered Python interpreter at /usr/bin/python3.10, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
nginx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
```
Как видно, нам придется каждый раз явно указывать наш inventory file и вписывать в него много информации.  

Это можно обойти используя ansible.cfg файл - прописав конфигурацию в нем.  
Для этого в текущем каталоге создадим файл ansible.cfg со следующим содержанием:  
[defaults]
inventory = staging/hosts
remote_user = vagrant
host_key_checking = False
retry_files_enabled = False  
Теперь из инвентори можно убрать информацию о пользователе:
[web]
nginx ansible_host=127.0.0.1 ansible_port=2222
ansible_private_key_file=.vagrant/machines/nginx/virtualbox/private_key
```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m ping
[WARNING]: Platform linux on host nginx is using the discovered Python interpreter at /usr/bin/python3.10, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
nginx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "ping": "pong"
}
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m command -a 'uname -r'
[WARNING]: Platform linux on host nginx is using the discovered Python interpreter at /usr/bin/python3.10, but future installation of another Python interpreter could change the meaning of that path. See
https://docs.ansible.com/ansible-core/2.17/reference_appendices/interpreter_discovery.html for more information.
nginx | CHANGED | rc=0 >>
5.15.0-91-generic
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m systemd -a name=firewalld
nginx | SUCCESS => {
    "ansible_facts": {
        "discovered_interpreter_python": "/usr/bin/python3.10"
    },
    "changed": false,
    "name": "firewalld",
    "status": {
        "ActiveEnterTimestamp": "n/a",
        "ActiveEnterTimestampMonotonic": "0",
        "ActiveExitTimestamp": "n/a",
        "ActiveExitTimestampMonotonic": "0",
        "ActiveState": "inactive",
        "AllowIsolate": "no",
        "AssertResult": "no",
        "AssertTimestamp": "n/a",
        "AssertTimestampMonotonic": "0",
        "BlockIOAccounting": "no",
        "BlockIOWeight": "[not set]",
        "CPUAccounting": "yes",
        "CPUAffinityFromNUMA": "no",
        "CPUQuotaPerSecUSec": "infinity",
        "CPUQuotaPeriodUSec": "infinity",
        "CPUSchedulingPolicy": "0",
        "CPUSchedulingPriority": "0",
        "CPUSchedulingResetOnFork": "no",
        "CPUShares": "[not set]",
        "CPUUsageNSec": "[not set]",
        "CPUWeight": "[not set]",
        "CacheDirectoryMode": "0755",
        "CanFreeze": "yes",
        "CanIsolate": "no",
        "CanReload": "no",
        "CanStart": "no",
        "CanStop": "yes",
        "CapabilityBoundingSet": "cap_chown cap_dac_override cap_dac_read_search cap_fowner cap_fsetid cap_kill cap_setgid cap_setuid cap_setpcap cap_linux_immutable cap_net_bind_service cap_net_broadcast cap_net_admin cap_net_raw cap_ipc_lock cap_ipc_owner cap_sys_module cap_sys_rawio cap_sys_chroot cap_sys_ptrace cap_sys_pacct cap_sys_admin cap_sys_boot cap_sys_nice cap_sys_resource cap_sys_time cap_sys_tty_config cap_mknod cap_lease cap_audit_write cap_audit_control cap_setfcap cap_mac_override cap_mac_admin cap_syslog cap_wake_alarm cap_block_suspend cap_audit_read cap_perfmon cap_bpf cap_checkpoint_restore",
        "CleanResult": "success",
        "CollectMode": "inactive",
        "ConditionResult": "no",
        "ConditionTimestamp": "n/a",
        "ConditionTimestampMonotonic": "0",
        "ConfigurationDirectoryMode": "0755",
        "ControlPID": "0",
        "CoredumpFilter": "0x33",
        "DefaultDependencies": "yes",
        "DefaultMemoryLow": "0",
        "DefaultMemoryMin": "0",
        "Delegate": "no",
        "Description": "firewalld.service",
        "DevicePolicy": "auto",
        "DynamicUser": "no",
        "ExecMainCode": "0",
        "ExecMainExitTimestamp": "n/a",
        "ExecMainExitTimestampMonotonic": "0",
        "ExecMainPID": "0",
        "ExecMainStartTimestamp": "n/a",
        "ExecMainStartTimestampMonotonic": "0",
        "ExecMainStatus": "0",
        "FailureAction": "none",
        "FileDescriptorStoreMax": "0",
        "FinalKillSignal": "9",
        "FreezerState": "running",
        "GID": "[not set]",
        "GuessMainPID": "yes",
        "IOAccounting": "no",
        "IOReadBytes": "18446744073709551615",
        "IOReadOperations": "18446744073709551615",
        "IOSchedulingClass": "2",
        "IOSchedulingPriority": "4",
        "IOWeight": "[not set]",
        "IOWriteBytes": "18446744073709551615",
        "IOWriteOperations": "18446744073709551615",
        "IPAccounting": "no",
        "IPEgressBytes": "[no data]",
        "IPEgressPackets": "[no data]",
        "IPIngressBytes": "[no data]",
        "IPIngressPackets": "[no data]",
        "Id": "firewalld.service",
        "IgnoreOnIsolate": "no",
        "IgnoreSIGPIPE": "yes",
        "InactiveEnterTimestamp": "n/a",
        "InactiveEnterTimestampMonotonic": "0",
        "InactiveExitTimestamp": "n/a",
        "InactiveExitTimestampMonotonic": "0",
        "JobRunningTimeoutUSec": "infinity",
        "JobTimeoutAction": "none",
        "JobTimeoutUSec": "infinity",
        "KeyringMode": "private",
        "KillMode": "control-group",
        "KillSignal": "15",
        "LimitAS": "infinity",
        "LimitASSoft": "infinity",
        "LimitCORE": "infinity",
        "LimitCORESoft": "0",
        "LimitCPU": "infinity",
        "LimitCPUSoft": "infinity",
        "LimitDATA": "infinity",
        "LimitDATASoft": "infinity",
        "LimitFSIZE": "infinity",
        "LimitFSIZESoft": "infinity",
        "LimitLOCKS": "infinity",
        "LimitLOCKSSoft": "infinity",
        "LimitMEMLOCK": "92483584",
        "LimitMEMLOCKSoft": "92483584",
        "LimitMSGQUEUE": "819200",
        "LimitMSGQUEUESoft": "819200",
        "LimitNICE": "0",
        "LimitNICESoft": "0",
        "LimitNOFILE": "1048576",
        "LimitNOFILESoft": "1048576",
        "LimitNPROC": "2369",
        "LimitNPROCSoft": "2369",
        "LimitRSS": "infinity",
        "LimitRSSSoft": "infinity",
        "LimitRTPRIO": "0",
        "LimitRTPRIOSoft": "0",
        "LimitRTTIME": "infinity",
        "LimitRTTIMESoft": "infinity",
        "LimitSIGPENDING": "2369",
        "LimitSIGPENDINGSoft": "2369",
        "LimitSTACK": "infinity",
        "LimitSTACKSoft": "8388608",
        "LoadError": "org.freedesktop.systemd1.NoSuchUnit \"Unit firewalld.service not found.\"",
        "LoadState": "not-found",
        "LockPersonality": "no",
        "LogLevelMax": "-1",
        "LogRateLimitBurst": "0",
        "LogRateLimitIntervalUSec": "0",
        "LogsDirectoryMode": "0755",
        "MainPID": "0",
        "ManagedOOMMemoryPressure": "auto",
        "ManagedOOMMemoryPressureLimit": "0",
        "ManagedOOMPreference": "none",
        "ManagedOOMSwap": "auto",
        "MemoryAccounting": "yes",
        "MemoryAvailable": "infinity",
        "MemoryCurrent": "[not set]",
        "MemoryDenyWriteExecute": "no",
        "MemoryHigh": "infinity",
        "MemoryLimit": "infinity",
        "MemoryLow": "0",
        "MemoryMax": "infinity",
        "MemoryMin": "0",
        "MemorySwapMax": "infinity",
        "MountAPIVFS": "no",
        "NFileDescriptorStore": "0",
        "NRestarts": "0",
        "NUMAPolicy": "n/a",
        "Names": "firewalld.service",
        "NeedDaemonReload": "no",
        "Nice": "0",
        "NoNewPrivileges": "no",
        "NonBlocking": "no",
        "NotifyAccess": "none",
        "OOMScoreAdjust": "0",
        "OnFailureJobMode": "replace",
        "OnSuccessJobMode": "fail",
        "Perpetual": "no",
        "PrivateDevices": "no",
        "PrivateIPC": "no",
        "PrivateMounts": "no",
        "PrivateNetwork": "no",
        "PrivateTmp": "no",
        "PrivateUsers": "no",
        "ProcSubset": "all",
        "ProtectClock": "no",
        "ProtectControlGroups": "no",
        "ProtectHome": "no",
        "ProtectHostname": "no",
        "ProtectKernelLogs": "no",
        "ProtectKernelModules": "no",
        "ProtectKernelTunables": "no",
        "ProtectProc": "default",
        "ProtectSystem": "no",
        "RefuseManualStart": "no",
        "RefuseManualStop": "no",
        "ReloadResult": "success",
        "RemainAfterExit": "no",
        "RemoveIPC": "no",
        "Restart": "no",
        "RestartKillSignal": "15",
        "RestartUSec": "100ms",
        "RestrictNamespaces": "no",
        "RestrictRealtime": "no",
        "RestrictSUIDSGID": "no",
        "Result": "success",
        "RootDirectoryStartOnly": "no",
        "RuntimeDirectoryMode": "0755",
        "RuntimeDirectoryPreserve": "no",
        "RuntimeMaxUSec": "infinity",
        "SameProcessGroup": "no",
        "SecureBits": "0",
        "SendSIGHUP": "no",
        "SendSIGKILL": "yes",
        "StandardError": "inherit",
        "StandardInput": "null",
        "StandardOutput": "inherit",
        "StartLimitAction": "none",
        "StartLimitBurst": "5",
        "StartLimitIntervalUSec": "10s",
        "StartupBlockIOWeight": "[not set]",
        "StartupCPUShares": "[not set]",
        "StartupCPUWeight": "[not set]",
        "StartupIOWeight": "[not set]",
        "StateChangeTimestamp": "n/a",
        "StateChangeTimestampMonotonic": "0",
        "StateDirectoryMode": "0755",
        "StatusErrno": "0",
        "StopWhenUnneeded": "no",
        "SubState": "dead",
        "SuccessAction": "none",
        "SyslogFacility": "3",
        "SyslogLevel": "6",
        "SyslogLevelPrefix": "yes",
        "SyslogPriority": "30",
        "SystemCallErrorNumber": "2147483646",
        "TTYReset": "no",
        "TTYVHangup": "no",
        "TTYVTDisallocate": "no",
        "TasksAccounting": "yes",
        "TasksCurrent": "[not set]",
        "TasksMax": "710",
        "TimeoutAbortUSec": "1min 30s",
        "TimeoutCleanUSec": "infinity",
        "TimeoutStartFailureMode": "terminate",
        "TimeoutStartUSec": "1min 30s",
        "TimeoutStopFailureMode": "terminate",
        "TimeoutStopUSec": "1min 30s",
        "TimerSlackNSec": "50000",
        "Transient": "no",
        "UID": "[not set]",
        "UMask": "0022",
        "UtmpMode": "init",
        "WatchdogSignal": "6",
        "WatchdogTimestamp": "n/a",
        "WatchdogTimestampMonotonic": "0",
        "WatchdogUSec": "infinity"
    }
}
```

hello

```console
root@test:~/otus/hw-16/Ansible# vagrant ssh
Last login: Sat Aug  9 17:19:59 2025 from 10.0.2.2
vagrant@nginx:~$ sudo systemctl status nginx
Unit nginx.service could not be found.
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible-playbook nginx.yml

PLAY [NGINX | Install and configure NGINX] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [nginx]

TASK [update] *****************************************************************************************************************************************************************************************************
changed: [nginx]

PLAY RECAP ********************************************************************************************************************************************************************************************************
nginx                      : ok=2    changed=1    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

hello

```console
root@test:~/otus/hw-16/Ansible# vagrant ssh
Last login: Sat Aug  9 19:43:45 2025 from 10.0.2.2
vagrant@nginx:~$ sudo systemctl status nginx
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sat 2025-08-09 19:44:07 UTC; 40s ago
       Docs: man:nginx(8)
    Process: 5933 ExecStartPre=/usr/sbin/nginx -t -q -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
    Process: 5934 ExecStart=/usr/sbin/nginx -g daemon on; master_process on; (code=exited, status=0/SUCCESS)
   Main PID: 6037 (nginx)
      Tasks: 2 (limit: 710)
     Memory: 5.6M
        CPU: 203ms
     CGroup: /system.slice/nginx.service
             ├─6037 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─6039 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Aug 09 19:44:07 nginx systemd[1]: Starting A high performance web server and a reverse proxy server...
Aug 09 19:44:07 nginx systemd[1]: Started A high performance web server and a reverse proxy server.
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible-playbook nginx.yml

PLAY [NGINX | Install and configure NGINX] ************************************************************************************************************************************************************************

TASK [Gathering Facts] ********************************************************************************************************************************************************************************************
ok: [nginx]

TASK [update] *****************************************************************************************************************************************************************************************************
changed: [nginx]

TASK [NGINX | Install NGINX] **************************************************************************************************************************************************************************************
ok: [nginx]

TASK [NGINX | Create NGINX config file from template] *************************************************************************************************************************************************************
changed: [nginx]

RUNNING HANDLER [reload nginx] ************************************************************************************************************************************************************************************
changed: [nginx]

PLAY RECAP ********************************************************************************************************************************************************************************************************
nginx                      : ok=5    changed=3    unreachable=0    failed=0    skipped=0    rescued=0    ignored=0
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m command -a 'systemctl status nginx'
nginx | CHANGED | rc=0 >>
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-08-10 01:05:51 UTC; 5min ago
       Docs: man:nginx(8)
   Main PID: 605 (nginx)
      Tasks: 2 (limit: 710)
     Memory: 5.0M
        CPU: 99ms
     CGroup: /system.slice/nginx.service
             ├─605 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─607 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Warning: some journal files were not opened due to insufficient permissions.
```
hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m command -a 'id'
nginx | CHANGED | rc=0 >>
uid=1000(vagrant) gid=1000(vagrant) groups=1000(vagrant)
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m command -a 'sudo systemctl status nginx'
nginx | CHANGED | rc=0 >>
● nginx.service - A high performance web server and a reverse proxy server
     Loaded: loaded (/lib/systemd/system/nginx.service; enabled; vendor preset: enabled)
     Active: active (running) since Sun 2025-08-10 01:05:51 UTC; 7min ago
       Docs: man:nginx(8)
   Main PID: 605 (nginx)
      Tasks: 2 (limit: 710)
     Memory: 5.0M
        CPU: 99ms
     CGroup: /system.slice/nginx.service
             ├─605 "nginx: master process /usr/sbin/nginx -g daemon on; master_process on;"
             └─607 "nginx: worker process" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" "" ""

Aug 10 01:05:50 nginx systemd[1]: Starting A high performance web server and a reverse proxy server...
Aug 10 01:05:51 nginx systemd[1]: Started A high performance web server and a reverse proxy server.
```

hello

```console
root@test:~/otus/hw-16/Ansible# ansible nginx -m command -a 'curl http://192.168.11.150:8080'
nginx | CHANGED | rc=0 >>
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
</html>  % Total    % Received % Xferd  Average Speed   Time    Time     Time  Current
                                 Dload  Upload   Total   Spent    Left  Speed
100   612  100   612    0     0  61322      0 --:--:-- --:--:-- --:--:-- 76500
```




```console
root@test:~/otus/hw-16/Ansible# ll
total 36
drwxr-xr-x 6 root root 4096 Aug 10 03:44 ./
drwxr-xr-x 3 root root 4096 Aug  9 17:18 ../
-rw-r--r-- 1 root root  277 Aug  9 20:16 ansible.cfg
-rw-r--r-- 1 root root  801 Aug 10 03:41 nginx.yml
drwxr-xr-x 2 root root 4096 Aug  9 20:13 staging/
drwxr-xr-x 2 root root 4096 Aug 10 03:32 templates/
drwxr-xr-x 3 root root 4096 Aug  9 20:37 tmp/
drwxr-xr-x 4 root root 4096 Aug  9 17:19 .vagrant/
-rw-r--r-- 1 root root 1109 Aug  9 17:30 Vagrantfile
```







Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
