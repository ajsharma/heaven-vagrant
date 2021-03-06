# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Use a custom name to allow simple app creation once the vagrant vm is up'ed
APPLICATION_NAME = 'heaven'

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  # All Vagrant configuration is done here. The most common configuration
  # options are documented and commented below. For a complete reference,
  # please see the online documentation at vagrantup.com.

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "ubuntu/trusty64"

  # The url from where the 'config.vm.box' box will be fetched if it
  # doesn't already exist on the user's system.
  # config.vm.box_url = "http://domain.com/path/to/above.box"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080
  config.vm.network "forwarded_port", guest: 3002, host: 3002

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.network "private_network", ip: "192.168.33.11"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # If true, then any SSH connections made will enable agent forwarding.
  # Default value: false
  config.ssh.forward_agent = true

  # custom fix for "stdin: is not a tty" error (https://github.com/mitchellh/vagrant/issues/1673)
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  config.vm.synced_folder ".", "/vagrant", type: "nfs"
  config.vm.synced_folder "../heaven", "/heaven", type: "nfs"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Don't boot with headless mode
  #   vb.gui = true
  #
  #   # Use VBoxManage to customize the VM. For example to change memory:
  #   vb.customize ["modifyvm", :id, "--memory", "1024"]
  # end
  #
  # View the documentation for the provider you're using for more
  # information on available options.

  config.vm.provider "virtualbox" do |vb|
    host = RbConfig::CONFIG['host_os']

    # Give VM 1/4 system memory & access to all cpu cores on the host
    if host =~ /darwin/
      cpus = `sysctl -n hw.ncpu`.to_i
      # sysctl returns Bytes and we need to convert to MB
      mem = `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 4
    elsif host =~ /linux/
      cpus = `nproc`.to_i
      # meminfo shows KB and we need to convert to MB
      mem = `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 4
    else # sorry Windows folks, I can't help you
      cpus = 2
      mem = 1024
    end

    vb.customize ["modifyvm", :id, "--memory", mem]
    vb.customize ["modifyvm", :id, "--cpus", cpus]
  end


  config.vm.provision :shell, :path => "vagrant/setup.sh"

  # Enable provisioning with Puppet stand alone.  Puppet manifests
  # are contained in a directory path relative to this Vagrantfile.
  # You will need to create the manifests directory and a manifest in
  # the file chef/ubuntu-12.04.pp in the manifests_path directory.
  #
  # An example Puppet manifest to provision the message of the day:
  #
  # # group { "puppet":
  # #   ensure => "present",
  # # }
  # #
  # # File { owner => 0, group => 0, mode => 0644 }
  # #
  # # file { '/etc/motd':
  # #   content => "Welcome to your Vagrant-built virtual machine!
  # #               Managed by Puppet.\n"
  # # }
  #
  # config.vm.provision "puppet" do |puppet|
  #   puppet.manifests_path = "manifests"
  #   puppet.manifest_file  = "site.pp"
  # end

  # Enable provisioning with chef solo, specifying a cookbooks path, roles
  # path, and data_bags path (all relative to this Vagrantfile), and adding
  # some recipes and/or roles.
  #
  config.vm.provision "chef_solo" do |chef|
    chef.log_level = :debug
    chef.cookbooks_path = "cookbooks"
    # chef.roles_path = "chef/roles"
    # chef.data_bags_path = "chef/data_bags"

    chef.add_recipe "nodejs"
    chef.add_recipe "postgresql::contrib" # before server b/c server creates the dbs
    chef.add_recipe "postgresql::server"
    chef.add_recipe "postgresql::client"
    chef.add_recipe "ruby_build"
    # chef.add_recipe "rbenv::system"
    # chef.add_recipe "rbenv::user"
    # chef.add_recipe "rbenv::vagrant"

    # chef.add_role "web"

    # You may also specify custom JSON attributes:
    chef.json = {
      "nodejs" => {
        },
      "postgresql" => {
        "apt_distribution" => "trusty", # Ubuntu 14.04
        "databases" => [
          {
            # generic database to allow easy command line access to psql
            "encoding" => "utf8",
            "locale" => "en_US.UTF8",
            "name" => "vagrant",
            "owner" => "vagrant",
            "template" => "template0"
            },
          {
            # rails-esque database so `rails new` will work out of the box
            "encoding" => "utf8",
            "locale" => "en_US.UTF8",
            "name" => "#{APPLICATION_NAME}_development",
            "owner" => "vagrant",
            "template" => "template0"
            },
          {
            # rails-esque database so `rake test` will work out of the box
            "encoding" => "utf8",
            "locale" => "en_US.UTF8",
            "name" => "#{APPLICATION_NAME}_test",
            "owner" => "vagrant",
            "template" => "template0"
            }
          ],
        "pg_hba" => [
            { "type" => "local", "db" => "all", "user" => "postgres",   "addr" => "",             "method" => "peer"  },
            { "type" => "local", "db" => "all", "user" => "all",        "addr" => "",             "method" => "trust" },
            { "type" => "host",  "db" => "all", "user" => "all",        "addr" => "127.0.0.1/32", "method" => "trust" },
            { "type" => "host",  "db" => "all", "user" => "all",        "addr" => "::1/128",      "method" => "trust" },
            { "type" => "host",  "db" => "all", "user" => "postgres",   "addr" => "127.0.0.1/32", "method" => "trust" },
            { "type" => "host",  "db" => "all", "user" => "username",   "addr" => "127.0.0.1/32", "method" => "trust" }
          ],
        "users" => [
          {
            "username" => "vagrant",
            "password" => "password", # yay, super secure!
            "superuser" => true,
            "createdb" => true,
            "login" => true
            }
          ],
        "version" => "9.3"
        },
      "rbenv" => {
        "rubies" => [
          "2.1.2"
          ],
        "user_installs" => [
          {
            "user" => "vagrant",
            "rubies" => [ "2.1.2" ],
            "global" => "2.1.2",
            "gems" => {
              "2.1.2" => [
                { "name" => "bundler" }
                ]
              }
            }
          ]
        }
      }
  end

  config.vm.provision :shell, :path => "vagrant/tools.sh"
  config.vm.provision :shell, :path => "vagrant/install-redis.sh"
  config.vm.provision :shell, :path => "vagrant/post-setup.sh"

  # Enable provisioning with chef server, specifying the chef server URL,
  # and the path to the validation key (relative to this Vagrantfile).
  #
  # The Opscode Platform uses HTTPS. Substitute your organization for
  # ORGNAME in the URL and validation key.
  #
  # If you have your own Chef Server, use the appropriate URL, which may be
  # HTTP instead of HTTPS depending on your configuration. Also change the
  # validation key to validation.pem.
  #
  # config.vm.provision "chef_client" do |chef|
  #   chef.chef_server_url = "https://api.opscode.com/organizations/ORGNAME"
  #   chef.validation_key_path = "ORGNAME-validator.pem"
  # end
  #
  # If you're using the Opscode platform, your validator client is
  # ORGNAME-validator, replacing ORGNAME with your organization name.
  #
  # If you have your own Chef Server, the default validation client name is
  # chef-validator, unless you changed the configuration.
  #
  #   chef.validation_client_name = "ORGNAME-validator"
end
