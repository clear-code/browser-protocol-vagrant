# -*- mode: ruby -*-
#
# Copyright (C) 2017 Kouhei Sutou <kou@clear-code.com>
# Copyright (C) 2017 Kentaro Hayashi <hayashi@clear-code.com>
#
# This library is free software; you can redistribute it and/or
# modify it under the terms of the GNU Lesser General Public
# License as published by the Free Software Foundation; either
# version 2.1 of the License, or (at your option) any later version.
#
# This library is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser General Public
# License along with this library; if not, write to the Free Software
# Foundation, Inc., 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301  USA

Vagrant.configure("2") do |config|
  name = "browser-protocol"
  config.vm.define(name) do |node|
    node.vm.box = "bento/ubuntu-17.04-i386"
    node.vm.network :public_network, :bridge => ENV["VAGRANT_BRIDGE"]

    node.vm.provider "virtualbox" do |virtualbox|
      virtualbox.memory = "2048"
    end

    node.vm.provision "ansible" do |ansible|
      ansible.playbook = "ansible/playbook.yml"
      ansible.groups = {
        "servers" => [name],
      }
      ansible.host_key_checking = false
      ansible.raw_arguments  = [
        "-vvv",
      ]
    end
  end
end
