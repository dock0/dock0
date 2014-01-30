dock0
=========

[![Gem Version](https://badge.fury.io/rb/dock0.png)](http://badge.fury.io/rb/dock0)
[![Dependency Status](https://gemnasium.com/akerl/dock0.png)](https://gemnasium.com/akerl/dock0)
[![Code Climate](https://codeclimate.com/github/akerl/dock0.png)](https://codeclimate.com/github/akerl/dock0)

Dynamic Arch image generator for building a read-only host system for [Docker](https://www.docker.io)

## Usage

This is basically a meta-script that builds Arch images. Its primary use is to build read-only Docker hosts for me, but it could realistically be repurposed for other kinds of minimal deployments.

An example configuration can be found in [this repo](https://www.github.com/akerl/my_dock0).

The dock0 command accepts a list of configuration files as arguments. It changes to the directory of the first file given, so all other files and configuration options can use relative pathing based from that location:

    dock0 /opt/my_dock0/config.yaml ./configs/foobar.yaml

The module's Dock0::Image class exposes various methods, but the recommended option is to run .easy_mode(), which runs through them all in the preferred order. This is the sequence (@config represents the merged configs provided):

1. `.prepare_device()` makes an ext2 filesystem at `@config['paths']['device']` and mounts it at `@config['paths']['mount']`
2. `.prepare_root()` creates a filesystem at `@config['paths']['build_file']` and mounts it at `@config['paths']['build']`
3. `.install_packages()` pacstraps the root filesystem with all the packages listed in `@config['paths']['package_list']`
4. `.apply_overlay()` copies the contents of `@config['paths']['overlay']` into the root filesystem
5. `.run_scripts()` runs all the ruby scripts in `@config['paths']['scripts']` in its own scope (the have access to `@config` and such)
6. `.run_commands()` runs all commands in `@config['commands']['chroot']` using arch-chroot and all commands in `@config['commands']['host']` on the host system
7. `.finalize()` unmounts the root FS, packs it in a squashfs, puts it on the target device, and unmounts that

## Installation

    gem install dock0

## License

dock0 is released under the MIT License. See the bundled LICENSE file for details.

