# Install cluster (N master - multiple workers) with kubespray

Установка K8S в home network (LAN). Схема "N master" - используется несколько Control Nodes. <br>
Установка с помощью kubespray<br>


#### Setup
* несколько физических машин (2-5). они служат для запуска вирталок и далее мы абстрагируемся от них
    * ubuntu 24.04 LTS
    * устанавливаются вручную
    * есть вариант автоматической установки: Ubuntu Server (.iso image + autoinstall.yaml) или Debian (cloud .qcow2 image)
    * к ним есть доступ по ssh - это ansible slaves первого уровня (Virtualization Layer)
* по несколько одинаковых виртуалок на каждой реальной машине
    * ubuntu 24.04 LTS
    * в режиме network bridge - получают собственный IP
    * к ним есть доступ по ssh - это ansible slaves второго уровня (K8s cluster)
* ansible (11.8.0) - python pip
* kubernetes (v1.32)
* kubernetes (v2.28.0)


![do not forget to update pic when update the scheme file](res/k8s_scheme.png "initial scheme of k8s setup") <br>


#### Prepare VMs

```
# git clone <this repo>
# cd k8sss/n-master-kubespray               # enter working directory
---
# python3 -m venv venv                      # # # create own Python virtual env (only on first launch)
# . venv/bin/activate                       # enter to the python virtual env
# python3 -m pip install --upgrade pip      # # # upgrade pip (only on first launch)
# pip install -r requirements.txt           # # # install our project requirements (only on first launch)
```

настройка виртуальных машин: static IP + manual DNS server 208.67.222.222

установка ssh-server + доступ по паролю
* sudo apt update
* sudo apt install openssh-server
* sudo systemctl enable ssh
* sudo systemctl restart ssh

создать файл hosts и добавить туда все установленные виртуалки
```
# touch hosts                                                       # fill according to your scheme
...
# ssh-keygen -t ed25519 -f ~/.ssh/key-2-k8s-machines -q -N ""       # create ssh key for all K8s nodes (only on first launch)
# ansible-playbook prepare-ssh-key.yml                              # copy ssh key to all K8s nodes (only on first launch)
# ansible-playbook workers-up.yml                                   # every time when you turn on physical hosts
# deactivate                                                        # leave my own python virtual env
```



#### Prepare Python virtual env with ansible
```
# git clone https://github.com/kubernetes-sigs/kubespray.git
# cp hosts2 ./kubespray/inventory/hosts                             # copy prepared inventory file from own repo
# cd kubespray
# git checkout v2.28.0
---
# VENVDIR=kubespray-venv
# KUBESPRAYDIR=kubespray
# python3 -m venv $VENVDIR                                          # # # create Python virtual env for kubespray (only on first launch)
# source $VENVDIR/bin/activate                                      # enter to the python virtual env
# cd $KUBESPRAYDIR
# pip install -U -r requirements.txt                                # # # install kubespray project requirements (only on first launch)
---
# ansible-playbook -i inventory/hosts --private-key ~/.ssh/key-2-k8s-machines --become --extra-vars "ansible_become_password=123" cluster.yml
```

For my setup it will take about 1 hour <br>

Now login on Control Plane:
```
kubectl get nodes
```

