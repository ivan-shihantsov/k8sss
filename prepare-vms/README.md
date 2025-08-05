
сетап
    несколько (2-3) реальных машин - based on ubuntu 24.04 LTS
    на каждой из них запущены одинаковые виртуалки - ubuntu 24.04 LTS
    + картинка

// сначала эксперимент с одним control plane + картинку схемы
вопросы
    применим ли тут ansible?
        - сначала кажется нет. чтоб настроить целевые виртуалки из п.2, они должны быть установлены. а это не так
        но можно сделать список реальных машин, на которых будут запущены виртуалки. и скриптом запустить на них .OVA (даже headless + server edition)
            к реальными машинам придется иметь доступ заранее: sshd и .OVA
            сделать проверку: есть ли .OVA - скачать только первый раз и то автоматом / или использовать, если уже скачано
            sshd на серверной убунте предустановлен
        + теперь кажется, и установку виртуалок на реальные машины + преднастройку сможно сделать через ansible (п.1) - хз, костыль ли это, просто использовать разные inventory
технологии
    ansible
    docker
    kubernetes
    grafana + prometheus
    nginx
порядок работы
    1. [install machines] имеется две реальные машины
    сначала на них устанавливается по N виртуалок с network bridge - удобнее с ova/ovf
    2. далее ansible работает с виртуалками, поэтому в его inventory заранее прописать их статические IP
        на каждой из виртуалок
        hostnamectl set-hostname <name>
        append /etc/hosts
        configure /etc/modules-load.d/containerd.conf
        kernel parameters /etc/sysctl.d/kubernetes.conf
        install apt-transport-https ca-certificates curl gnupg
        install containerd, docker
        prepare /etc/containerd/config.toml
        install kubelet kubeadm kubectl
        Join Worker Nodes to the Cluster
        test
// далее эксперимент с N1 control plane + N2 worker node + nginx
    + картинку схемы

найти прилагу nodeJS, которая просто на get запрос выдает статическую страницу (), типа: 
    отскейлить ее на много нод
графану привязать к nodejs
найти прилагу nodeJS, которая просто на запрос выдает страницу: ip
    отскейлить ее на много нод
графану привязать к nodejs
    вряд ли между control plane-ами и worker-ами - хотя там тоже можно повесить просто для отслеживания нагрузки
    в первую очередь на каждый отдельный ingress контроллер, для оценки нагрузки на каждой отдельной worker node



# https://canonical-subiquity.readthedocs-hosted.com/en/latest/reference/autoinstall-reference.html#ai-identity
# https://github.com/canonical/autoinstall-desktop/tree/main
# https://canonical-subiquity.readthedocs-hosted.com/en/latest/tutorial/creating-autoinstall-configuration.html




2 управляющие машины
    user1@comp1 192.168.100.100
    uha@uhas    192.168.100.110

как с ними работать
# vboxmanage list vms
# vboxmanage list runningvms
# VBoxManage startvm "vm1" --type headless



bash
kubeadm init --pod-network-cidr=192.168.0.0/16
Here, the CIDR range 192.168.0.0/16 allows pods to use IP addresses within that range, ensuring that all pods have unique IPs and enabling seamless communication between them.

This setting is particularly important when using certain network plugins like Calico or Flannel, which require you to specify the pod network range during cluster initialization. Without it, the cluster may not be able to establish proper pod networking

Параметр --pod-network-cidr в команде kubeadm init
  указания диапазона CIDR (Classless Inter-Domain Routing)
  для сети pod в кластере Kubernetes
Pod-ы взаимодействуют друг с другом через эту сеть (в этой сети)
т.е. это внутренняя сеть k8s
  --pod-network-cidr задает диапазон IP-адресов, который будут использовать pod в кластере
  гарантирует, что все модули будут иметь уникальные IP-адреса и обеспечивая бесперебойную связь между ними.
Этот параметр особенно важен при использовании определенных сетевых плагинов, таких как Calico или Flannel, 
  которые требуют указания диапазона сети модуля во время инициализации кластера. 
  Без него кластер может не установить надлежащую сеть модуля


--control-plane-endpoint option
  указывает stable endpoint для control plane в Kubernetes cluster
  это бывает полезно при установке highly available (HA) cluster с несколькими control plane нодами

kubeadm init --control-plane-endpoint="load-balancer.example.com:6443"

It defines the address (hostname or IP) and port (default is 6443) where the control plane components (like the API server) can be reached.
When multiple control plane nodes are involved, this endpoint typically points to a load balancer that routes traffic to the different nodes.
It ensures that all the cluster components and clients (like kubectl) can consistently communicate with the control plane, even if individual control plane nodes go down or change.
This is an essential flag for clusters aiming for high availability. If you're setting up a basic, single-node control plane, this option isn't necessary.





    - name: Ensure Kubelet is running on worker nodes
      when: "'k8s_worker' in group_names"
      ansible.builtin.systemd:
        name: kubelet
        state: started
        enabled: yes




To stop, reset, and remove a Kubernetes cluster on all nodes, you can follow these steps:

1. Stop and Drain Nodes
Before removing the cluster, ensure that all workloads are safely moved or terminated.

    List Nodes:
        kubectl get nodes

    Drain Each Node:
        kubectl drain <node-name> --ignore-daemonsets --delete-emptydir-data
        This command evicts all pods from the node except for DaemonSet-managed pods.

2. Delete All Resources in the Cluster
To clean up the cluster resources:

    Delete All Resources in All Namespaces:
        kubectl delete all --all --all-namespaces
        This removes all pods, services, deployments, etc., across all namespaces.

3. Delete Nodes from the Cluster
After draining the nodes:

    Cordon Nodes (Optional):
    Prevent new pods from being scheduled:
        kubectl cordon <node-name>

    Delete Nodes:
        kubectl delete node <node-name>
        This removes the node from the cluster.

4. Reset Kubernetes on Each Node
To completely reset Kubernetes components on each node:

    Use kubeadm reset:
    On every node (control plane and worker nodes), run:
        sudo kubeadm reset
        This command removes all Kubernetes configurations and data from the node. Add the --force flag if necessary.

    Clean Up Networking:
    Remove any residual networking configurations:

        sudo iptables -F && sudo iptables -X && sudo iptables -t nat -F && sudo iptables -t nat -X && sudo iptables -t mangle -F && sudo iptables -t mangle -X && sudo iptables -P FORWARD ACCEPT

    Remove Kubernetes Directories:
    Delete Kubernetes-related files and directories:
        sudo rm -rf /etc/kubernetes /var/lib/etcd /var/lib/kubelet /var/lib/dockershim /var/run/kubernetes ~/.kube

5. Remove Cluster from Cloud Providers (if applicable)
If using a managed Kubernetes service (e.g., GKE, EKS, AKS), delete the cluster using their respective tools or consoles:

GKE Example:
    gcloud container clusters delete <CLUSTER_NAME>
    This removes all associated resources such as control plane, nodes, and networking.

6. Verify Cleanup
Ensure that no Kubernetes processes or configurations remain on any node. Rebooting nodes after cleanup is recommended to ensure a fresh state.

These steps will completely stop, reset, and remove your Kubernetes cluster from all nodes.



https://docs.tigera.io/calico/latest/getting-started/kubernetes/quickstart


ansible-playbook -vv -i hosts --step --start-at-task "add Kubernetes APT repo (sudo)" install.yml
ansible-playbook -vv -i hosts clean-1.yml


