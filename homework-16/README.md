## Домашнее задание № 16 — «Ansible»

**Цель домашнего задания: Написать первые шаги с Ansible в операционной системе (ОС) GNU/Linux**.

**Выполнение домашнего задания**:

1) 

```console
root@test:~/otus/hw-16/Ansible# vagrant ssh
Last login: Sat Aug  9 17:19:59 2025 from 10.0.2.2
vagrant@nginx:~$ sudo systemctl status nginx
Unit nginx.service could not be found.
```

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

```console
root@test:~/otus/hw-16/Ansible# ansible-playbook nginx_2nd_stage.yml

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



















Домашнее задание выполнено.

<br/>

[Вернуться к списку всех ДЗ](../README.md)
