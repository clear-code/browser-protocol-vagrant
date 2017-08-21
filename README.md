# Vagrant for Chromium DevTools Protocol

This repository is used to setup headless Chromium virtual machine.

Internally, two systemd services are running in virtual machine.

* `browser-protocol.service`
* `browser-protocol-tunnel.service`

`browser-protocol.service` launches Chromium with headless mode which is enabled remote debugging port feature.

`browser-protocol-tunnel.service` provides forwarded `9223` port (public endpoint) to access internal remote debugging port `9222` from host machine.

## Install

* [Install Vagrant](https://www.vagrantup.com/downloads.html).
* [Install VirtualBox](https://www.virtualbox.org/wiki/Linux_Downloads).

Install Ansible:

* [For Debian GNU/Linux](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-debian)
* [For Ubuntu](http://docs.ansible.com/ansible/intro_installation.html#latest-releases-via-apt-ubuntu)
* [For CentOS](http://docs.ansible.com/ansible/intro_installation.html#latest-release-via-yum)

Install Git:

For Debian or Ubuntu:

```console
% sudo apt install -y -V git
```

For CentOS:

```console
% sudo yum install -y git
```

Clone this repository:

```console
% git clone https://github.com/clear-code/browser-protocol-vagrant
```

Start virtual machine. It takes long time...:

```console
% cd browser-protocol-vagrant
% vagrant up
```

## Usage

DevTools Protocol endpoint is provided by `http://192.168.92.22:9223/json`.
Note that you can't directly access port `9222` (DevTools Protocol default port) from host machine because of limitation about this protocol.

Here is the sample request to show how it works.

```console
$ curl http://192.168.92.22:9223/json
[ {
   "description": "",
   "devtoolsFrontendUrl": "/devtools/inspector.html?ws=192.168.92.22:9223/devtools/page/1a67968b-2752-4e96-9ddf-44e50fea68c4",
   "id": "1a67968b-2752-4e96-9ddf-44e50fea68c4",
   "title": "DevTools Protocol sample",
   "type": "page",
   "url": "file:///tmp/in.html",
   "webSocketDebuggerUrl": "ws://192.168.92.22:9223/devtools/page/1a67968b-2752-4e96-9ddf-44e50fea68c4"
} ]
```
