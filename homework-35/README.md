PS C:\Users\funt1k> mkdir .\vagrant\otus\hw-34

    Каталог: C:\Users\funt1k\vagrant\otus

Mode                 LastWriteTime         Length Name
----                 -------------         ------ ----
d-----        23.07.2025      1:30                hw-34

PS C:\Users\funt1k> cd .\vagrant\otus\hw-34

PS C:\Users\funt1k\vagrant\otus\hw-34>

PS C:\Users\funt1k\vagrant\otus\hw-34> cat .\Vagrantfile
Vagrant.configure("2") do |config|
    config.vm.box = "ubuntu/jammy64"
    config.vm.define "server" do |server|
        server.vm.hostname = "server.loc"
        server.vm.network "private_network", ip: "192.168.56.10"
    end

    config.vm.define "client" do |client|
        client.vm.hostname = "client.loc"
        client.vm.network "private_network", ip: "192.168.56.20"
    end
end

PS C:\Users\funt1k\vagrant\otus\hw-34> vagrant up
Bringing machine 'server' up with 'virtualbox' provider...
Bringing machine 'client' up with 'virtualbox' provider...

PS C:\Users\funt1k\vagrant\otus\hw-34> vagrant ssh server
Welcome to Ubuntu 22.04.5 LTS (GNU/Linux 5.15.0-142-generic x86_64)

vagrant@server:~$ sudo apt update

vagrant@server:~$ sudo apt install openvpn iperf3 selinux-utils
...
The following NEW packages will be installed:
  iperf3 libiperf0 libpkcs11-helper1 libsctp1 openvpn selinux-utils

vagrant@server:~$ sudo setenforce 0
setenforce: SELinux is disabled






