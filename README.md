# orbithub-box

Provisioning environment for local development based on Vagrant and Vaprobash.

See:

* Vaprobash - https://github.com/fideloper/Vaprobash
* Vagrant - https://www.vagrantup.com/

## Overview 

This project sets up a development VM for liberated-living on your local machine:

* initializes a Ubuntu/trusty64 virtual machine
* runs vaprobash scripts to install a compatible LAMP environment - apache, php-fpm, mysql, memcached, composer, git
* checks out the liberated-living project, by default into the sites/ folder of this project
* sets up the correct environment files for local development
* downloads a database dump from a shared filesystem (TBD) and provisions the database

It does *not* update your hosts file, which you will need to do manually (instructions below).

### A Few Key Points (if you are no stranger to vagrant, skip this section)

* vagrant runs a Linux virtual machine on your local system.  Some Windows users may have to enable virtualization in their BIOS.  Macs etc. should be good to go.  The VM runs an environment similar (if not identical) to the server environment - Linux/Apache/PHP5/MySQL/Memcached, and has dev tools such as composer, npm and bower installed on it.  So you can keep your local system very lean.  
* vagrant syncs the relevant local file system with the file system on the VM.  So you will clone the web repo to `sites/liberated-living` on your local machine, and it will get mirrored to the filesystem on the vagrant VM.  This folder (the one with the README) is mounted as `/vagrant` on the vagrant box.
* this means you develop in your *local* environment with your usual tools, but access the web server and database on the vagrant VM.  You don't need to sync your files or anything, when you save they are automatically on both filesystems.
* you start and stop your VM with `vagrant up` and `vagrant halt`.  
* as long as you don't have anything developer-mission-critical you can blow away your vagrant box and start over anytime (I would recommend a mysqldump so you can keep your local DB if you have seeded anything important).  The following will destroy the VM and start over:

```
vagrant halt
vagrant destroy
# answer yes
vagrant up
```

* note that destroy/up gets a bit faster after the first time because the ubuntu/trusty64 base box image is downloaded and cached locally. It takes about 10 minutes to hard-bounce the box on my MacBook Air (MK).
* you can shell in to the vagrant VM using `vagrant ssh` from this folder.  You don't need keys, they should have been set up the first time you provisioned a VM.  Once in the VM, it (this one) is standard Ubuntu Linux, and everything is where you expect, save for the `/vagrant` filesystem which syncs with local.  On top of that `sudo su` gets you to a root shell so you have full control of the VM.
* composer, npm and bower and scss are installed on the box, so if you don't want to futz with your local environment (Windows is tough, Mac with homebrew is better but still a pain), you can `vagrant ssh` in and use the tools there - `gulp watch`, `scss build`, `composer update`, `npm install` etc.  Or use `vagrant ssh whatever-command` and run commands from your local env and pipe the output to your local console.

## Requirements:

* VirtualBox 5.0 - https://www.virtualbox.org/ and https://www.virtualbox.org/manual/UserManual.html
* Vagrant 1.5 - https://www.vagrantup.com/downloads.html and https://docs.vagrantup.com/v2/installation/

## Installation

1. Install VirtualBox and Vagrant.  [This link](http://stackoverflow.com/questions/24547805/oracle-virtualbox-vt-x-is-disabled-in-the-bios) might help if you are on windows and getting complaints from the OS about virtualization - you need to enable it in your BIOS and many Windows machines have it disabled by default.

Check out this project using git clone

```
cd /wherever/you/keep/stuff
git clone https://github.com/orbithub/orbithub-box.git
```

If you want to customize the settings, create a local git branch so you can track upstream changes:

``` 
git branch -t local-YourInitials origin/master 
git checkout local-YourInitials

```

Clone the liberated-living repo to the sites folder.  This is so we can keep the provisioning project separate from the main project.

```
cd orbithub-box
mkdir sites
cd sites
git clone https://github.com/orbithub/liberated-living.git

```

Download a database snapshot from *TODO - where shall we put this?*.  Snapshots are available as follows:

* current development dump (nightly) - *TODO - link*
* current master (schema + seed tables only) - *TODO - link*
* your custom DB dump - if you've got one, just copy it to data/orbithub-db.dump.sql.gz and it will be imported

Open a command prompt, cd to the folder where you checked this out.  Then start the box:
  
``` 
vagrant up 
```

Watch the console for errors. 

Finally, update your `/etc/hosts` file (or wherever it is on windows - /windows/system32/etc/hosts I think ...):

```
# This covers both the older codebase and the new (MK proposed .dev for local env) domains:

192.168.22.10   orbithub.dev www.orbithub.dev tennis.orbithub.dev squash.orbithub.dev tabletennis.orbithub.dev badminton.orbithub.dev ncta.dev www.ncta.dev tennis.ncta.dev squash.ncta.dev tabletennis.ncta.dev badminton.ncta.dev orbithub.org www.orbithub.org tennis.orbithub.org squash.orbithub.org tabletennis.orbithub.org badminton.orbithub.org ncta.org www.ncta.org tennis.ncta.org squash.ncta.org tabletennis.ncta.org badminton.ncta.org

```

Try it out! 

* Browse to `http://orbithub.dev` (or `http://orbithub.org`)
* Or connect to MySQL on 127.0.0.1 port 3307 (port is forwarded from the VM to your local)

## Other neat stuff

* if you can temporarily set up your routes to be not-domain-based, http://xip.io/ is great for sharing access to your box on the local network.  If you want to share to anyone in the world, try https://ngrok.com/ .  Port 8000 on your host (your box) should be forwarded to port 80 on the vagrant box, so `ngrok -http 8000` should do it.  Once again, you need to mess with the domain matching so http://*whatever*.ngrok.com pulls up the correct site.  Or if you are just demoing try [Chrome Remote Desktop](https://chrome.google.com/webstore/detail/chrome-remote-desktop/gbchcmhmhahfdphkhkmpfmihenigjmpp?hl=en) or [join.me](http://join.me).



Finally, update your `/etc/hosts` file (or wherever it is on windows - /windows/system32/etc/hosts I think ...):

```
# This covers both the older codebase and the new (MK proposed .dev for local env) domains:

192.168.22.10   orbithub.dev www.orbithub.dev tennis.orbithub.dev squash.orbithub.dev tabletennis.orbithub.dev badminton.orbithub.dev ncta.dev www.ncta.dev tennis.ncta.dev squash.ncta.dev tabletennis.ncta.dev badminton.ncta.dev orbithub.org www.orbithub.org tennis.orbithub.org squash.orbithub.org tabletennis.orbithub.org badminton.orbithub.org ncta.org www.ncta.org tennis.ncta.org squash.ncta.org tabletennis.ncta.org badminton.ncta.org

```

Try it out! 

* Browse to `http://orbithub.org` (or `http://orbithub.dev` depending on your environment)
* Or connect to MySQL on 192.168.22.10 port 3306

## Other neat stuff

* if you can temporarily set up your routes to be not-domain-based, http://xip.io/ is great for sharing access to your box on the local network.  If you want to share to anyone in the world, try https://ngrok.com/ .  Port 8000 on your host (your box) should be forwarded to port 80 on the vagrant box, so `ngrok -http 8000` should do it.  Once again, you need to mess with the domain matching so http://*whatever*.ngrok.com pull up the correct site.  Or if you are just demoing try [Chrome Remote Desktop](https://chrome.google.com/webstore/detail/chrome-remote-desktop/gbchcmhmhahfdphkhkmpfmihenigjmpp?hl=en) or [join.me](http://join.me).



