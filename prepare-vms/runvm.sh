
server_iso_name="ubuntu-24.04-live-server-amd64.iso"
generic_iso_name="ubuntu-24.04-desktop-amd64.iso"
short_name="ubu24.iso"

choosen_iso="$server_iso_name"

# if install VMs with debian
# https://cloud.debian.org/images/cloud/bookworm/latest/debian-12-nocloud-amd64.qcow2
# fastest mirror
download_link_by="http://by.releases.ubuntu.com/24.04/$choosen_iso"
# official server (reserve)
download_link_off_srv="http://releases.ubuntu.com/24.04/$choosen_iso"

download_file="/home/$USER/Downloads/$choosen_iso"
prepared_iso="/home/$USER/Downloads/$short_name"



if [ ! -f "$download_file" ]; then
    echo "no $download_file"
    wget --inet4-only "$download_link_by" -O "$download_file"
else
    echo "$download_file exist"
fi

# ----------- ----------- ----------- ----------- -----------

prepare_image () {
    rm $prepared_iso
    sync

    default_user=$USER

    sudo mkdir /mnt/src_iso
    sudo mount $download_file /mnt/src_iso

    sudo mkdir /mnt/dst_iso
    sudo cp -r /mnt/src_iso/* /mnt/dst_iso/
    sync
    sudo umount /mnt/src_iso
    sudo rm -rf /mnt/src_iso

    sudo cp autoinstall.yaml /mnt/dst_iso/
    sync
    # sudo mkisofs -o /mnt/new.iso -b isolinux/isolinux.bin -c isolinux/boot.cat -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "NEWUBUNRU24" /mnt/abc/
    sudo mkisofs -no-emul-boot -boot-load-size 4 -boot-info-table -J -R -V "NEWUBUNRU24" -r -o $prepared_iso /mnt/dst_iso/
    sync
    sudo rm -rf /mnt/dst_iso
    sudo chown $default_user:$default_user $prepared_iso

    # not working
    #VBoxManage convertfromraw DiskImage.iso VirtualDisk.vdi
    #vboximg-mount --image ubuntu-24.04.vdi mnt-tmp/        # vboximg-mount: error: The given path 'ubuntu-24.04.vdi' is not fully qualified

    #VBoxManage clonehd --format RAW ubuntu-24.04.vdi ubuntu-24.04.img
    #mount -t ext3 -o loop,rw ./ubuntu-24.04.img mnt-tmp/   # mount: /home/waka/Downloads/mnt-tmp/: mount failed: No such file or directory - просто, хотя все есть

    # способ 2
    # qemu-img -O=vmdk ubuntu-24.04.iso ubuntu-24.04.vmdk
    # ошибка - что-то с командой - должна быть # qemu-img convert


    # vboxmanage list hdds --long | grep 'Ubuntu-24.04' | grep -u uuid
}
# prepare_image




# prepare: remove extra hdds
# vboxmanage list hdds
# vboxmanage closemedium disk <uuid> --delete-all

# prepare: remove extra VMs
# vboxmanage unregistervm Ubuntu-24.04 --delete

# sudo usermod -aG vboxusers $USER

# https://blogs.oracle.com/virtualization/post/guide-for-virtualbox-vm-unattended-installation

vboxmanage createvm \
    --register \
    --basefolder "~/vbox" \
    --name "Ubuntu-24.04" \
    --ostype Ubuntu22_LTS_64

# -------------- -------------- --------------

# изначально memory=128MB cpus=1 vram=8MB ?net=NAT? ?mac?
# а без этого показывает трабл (ошибка? вроде варнинг) - запустится ли? может лучше none? --graphicscontroller vmsvga (дефолт: vboxvga)
# vboxmanage modifyvm "Ubuntu-24.04" --cpus 2 --memory 3072 --vram 128 --graphicscontroller vmsvga --usbohci on --mouse usbtablet

# --mac-address= address
# get wlo1 as grep `ip a`
vboxmanage modifyvm "Ubuntu-24.04" \
    --cpus 2 \
    --memory 3072 \
    --vram 128 \
    --nic1 bridged \
    --bridgeadapter1 wlo1 \
    --macaddress1 auto \
    --graphicscontroller vmsvga \
    --usbohci on \
    --mouse usbtablet

# -------------- -------------- --------------

# изначально даже контроллера нет никакого
# create .vdi storage to install system
# == vboxmanage createmedium
vboxmanage createhd \
    --filename ~/vbox/Ubuntu-24.04/Ubuntu-24.04.vdi \
    --format VDI \
    --size 20480 \
    --variant Standard

vboxmanage storagectl "Ubuntu-24.04" \
    --name "SATA-Ctrlr-4-sys" \
    --add sata \
    --bootable on \
    --hostiocache off

vboxmanage storageattach "Ubuntu-24.04" \
    --storagectl "SATA-Ctrlr-4-sys" \
    --port 0 \
    --device 0 \
    --type hdd \
    --medium ~/vbox/Ubuntu-24.04/Ubuntu-24.04.vdi

# -------------- -------------- --------------

# create controller to insert live-iso with Ubuntu 24.04
#vboxmanage storagectl "Ubuntu-24.04" \
#    --name "IDE-Ctrlr-4-live-iso" \
#    --add ide

#vboxmanage storageattach "Ubuntu-24.04" \
#    --storagectl "IDE-Ctrlr-4-live-iso" \
#    --port 0 \
#    --device 0 \
#    --type dvddrive \
#    --medium "$prepared_iso"

# -------------- -------------- --------------

# By default, the server uses the current directory. The option -d/--directory specifies a directory to which it should serve the files
# python -m http.server --directory /tmp/


#cd /home/waka/workdir/tmp/kubik8s/
#mkdir -p ./www
#cp autoinstall.yaml ./www/user-data
#cd ./www
#touch meta-data
#touch vendor-data # вот это чисто моя догадка из-за ошибки
    # 192.168.23.192 - - code 404, message File not found
    # 192.168.23.192 - - "GET /vendor-data HTTP/1.1" 404 -
#python3 -m http.server 3003

# -------------- -------------- --------------

# --hostname = Ubuntu-24-04.myguest.virtualbox.org
# auto-generate vm-name, user, password, hostname
VBoxManage unattended install "Ubuntu-24.04" \
    --iso "$prepared_iso" \
    --extra-install-kernel-parameters 'autoinstall ds="nocloud-net;s=http://192.168.23.76:3003/"'
# cloud-config-url=http://192.168.23.76:3003/user-data
# ds=nocloud-net;s=http://192.168.23.76:3003/
# ds=nocloud;s=http://192.168.23.76:3003
# "s=" == "seedfrom=""
#    --extra-install-kernel-parameters "auto=true ds=nocloud-net;s=http://_gateway:3003/ priority=critical quiet splash noprompt noshell automatic-ubiquity debian-installer/locale=en_US keyboard-configuration/layoutcode=us languagechooser/language-name=English localechooser/supported-locales=en_US.UTF-8 countrychooser/shortlist=CT --"
# curl 192.168.23.7:3003/user-data

# походу нужны cloud-utils (доступно в dnf) - но зачем?
# я уже делал минимальный autoinstall.yaml и user-data
# экранировал в extra-install-kernel-parameters кавычки в ds="nocloud-net;s=http://192.168.23.76:3003/" и ;
# делал с cloud-config-url и без него - ноль разницы
# добавлял vendor-data пустой и копия user-data - ноль разницы

VBoxManage startvm "Ubuntu-24.04" # \
#    --type headless
