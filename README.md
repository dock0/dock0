dock0
=========

[![Gem Version](https://img.shields.io/gem/v/dock0.svg)](https://rubygems.org/gems/dock0)
[![Dependency Status](https://img.shields.io/gemnasium/dock0/dock0.svg)](https://gemnasium.com/dock0/dock0)
[![Build Status](https://img.shields.io/circleci/project/dock0/dock0.svg)](https://circleci.com/gh/dock0/dock0)
[![Coverage Status](https://img.shields.io/codecov/c/github/dock0/dock0.svg)](https://codecov.io/github/dock0/dock0)
[![Code Quality](https://img.shields.io/codacy/df0d7e6f7241482db8eb4d0b920c36ad.svg)](https://www.codacy.com/app/akerl/dock0)
[![MIT Licensed](https://img.shields.io/badge/license-MIT-green.svg)](https://tldrlegal.com/license/mit-license)

Component generator for building Arch systems

For information on how this is used, check out my blog posts:

* [The original workflow](http://blog.akerl.org/2014/01/30/dock0-minimal-docker-host/)
* [Newer layout, with more features](http://blog.akerl.org/2014/12/17/dock0-round-2/)

## Usage

### Build a rootfs

```
dock0 image config.yaml
```

This will build a compressed rootfs from your configuration. Here is [an example configuration](https://github.com/dock0/rootfs)

### Build a config bundle

```
dock0 config config.yaml
```

This builds a config tarball designed to be used to customize a rootfs. Here is [an example configuration](https://github.com/dock0/deploy_tool)

### Build a system deployment

```
dock0 install config.yaml
```

This downloads created artifacts and runs build scripts to combine precreated and dynamic components into a full system. Here is [an example configuration](https://github.com/dock0/vm_spec)

## Installation

    gem install dock0

## License

dock0 is released under the MIT License. See the bundled LICENSE file for details.

