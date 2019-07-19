# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.box = "ubuntu/bionic64"

  config.vm.provider "virtualbox" do |vbox|
    # Display the VirtualBox GUI when booting the machine
    # vbox.gui = true

    # Customize the amount of memory on the VM:
    vbox.memory = (1024 * 4).to_s
    vbox.cpus   = 8
  end
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "private_network", ip: "192.168.136.10"

  config.vm.provision "shell", inline: (<<-SHELL).gsub(/^ {4}/m, "")
    set -x
    if ! test -f /vagrant/.setup-done; then
      apt -y -q update

      # See: https://github.com/mruby/mruby/blob/master/doc/guides/compile.md and some for CRuby
      apt -y -q install build-essential devscripts git libreadline-dev zlib1g-dev ruby rake bison

      # ref: https://github.com/pepabo/ngx_mruby-package-builder/blob/master/Dockerfile.ubuntu1604
      apt -y -q install libssl-dev wget libxslt-dev libgd-dev libgeoip-dev libperl-dev

      # use Docker for dummy upstream
      snap install docker --classic

      touch /vagrant/.setup-done
    fi
  SHELL
end
