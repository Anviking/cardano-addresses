<p align="center">
  <big><strong>Cardano Addresses</strong></big>
</p>

<p align="center">
  <a href="https://github.com/input-output-hk/cardano-addresses/releases"><img src="https://img.shields.io/github/v/release/input-output-hk/cardano-addresses?color=%239b59b6&label=RELEASE&sort=semver&style=for-the-badge"/></a>
  <a href='https://github.com/input-output-hk/cardano-addresses/actions?query=workflow%3A"Continuous Integration"'><img src="https://img.shields.io/github/workflow/status/input-output-hk/cardano-addresses/Continuous Integration?style=for-the-badge" /></a>
  <a href="https://input-output-hk.github.io/cardano-addresses/coverage/hpc_index.html"><img src="https://input-output-hk.github.io/cardano-addresses/coverage/badge.svg" /></a>
</p>

## Overview

This module provides mnemonic (backup phrase) creation, and conversion of a
mnemonic to seed for wallet restoration, and address derivation functionalities.

![](.github/example.gif)

## Documentation

API documentation is available [here](https://input-output-hk.github.io/cardano-addresses/haddock).

## Command-Line 

`cardano-address` comes with a command-line interface for Linux. See the [release artifacts](https://github.com/input-output-hk/cardano-addresses/releases) or [continuous integration artifacts](https://github.com/input-output-hk/cardano-addresses/actions?query=workflow%3A%22Continuous+Integration%22) to get a pre-compiled binary, or [build a Docker image](#docker-image). The command-line is self explanatory by using `--help` on various commands and sub-commands.

> :bulb: Most commands read argument from the standard input. This prevent sensitive information from appearing into your shell history and, makes it easy to pipe commands!

Here's are some key examples:

<details>
  <summary>How to generate a recovery phrase</summary>

```
$ cardano-address recovery-phrase generate --size 15
east student silly already breeze enact seat trade few way online skin grass humble electric
```
</details>

<details>
  <summary>How to generate a root private key</summary>

```
$ cardano-address recovery-phrase generate --size 15 > recovery-phrase.prv
$ cat recovery-phrase.prv | cardano-address key from-recovery-phrase Shelley
xprv1fzu4e8cecxshgzzxzh7557sd8tffqreeq2je7fgsm7f02mq849vdupw7qwgxc3qawyqev0l8ew0f4fkp8hvr8mskz4hz6e6ejzjlevcskcl6lqpr07u7552fsfgteztuclse7luh4cp493zdhkrjdss0250cdw8n
```

Notice the `xprv` prefix to identify an e**x**tended **prv**ivate key. Should you prefer an hexadecimal output, you can choose a different output encoding via a special flag:

```
$ cat recovery-phrase.prv | cardano-address key from-recovery-phrase Shelley --base16
48b95c9f19c1a174084615fd4a7a0d3ad2900f3902a59f2510df92f56c07a958
de05de03906c441d7101963fe7cb9e9aa6c13dd833ee16156e2d675990a5fcb3
10b63faf80237fb9ea51498250bc897cc7e19f7f97ae0352c44dbd8726c20f55
```
</details>

<details>
  <summary>How to generate a public stake key</summary>

```
$ cardano-address recovery-phrase generate --size 15 > recovery-phrase.prv
$ cat recovery-phrase.prv \
| cardano-address key from-recovery-phrase Shelley \
| cardano-address key child 1852H/1815H/0H/2/0 \
| cardano-address key public
xpub16y4vhpyuj2t84gh2qfe3ydng3wc37yqzxev6gce380fvvg47ye8um3dm3wn5a64gt7l0fh5j6sjlugy655aqemlvk6gmkuna46xwj9g4frwzw
```

> :information_source: `1852H/1815H/0H/2/0` is the derivation path that is typically used by Cardano wallet to identify a stake key within HD wallet. If you seek compatibility with Daedalus or Yoroi, use this as well!

</details>

<details>
  <summary>How to generate a payment address</summary>

```
  $ cardano-address recovery-phrase generate --size 15 \
  | cardano-address key from-recovery-phrase Shelley > root.prv

  $ cat root.prv \
  | cardano-address key child 1852H/1815H/0H/0/0 > addr.prv

  $ cat addr.prv \
  | cardano-address key public \
  | cardano-address address payment --network-tag testnet

  addr_test1vqrlltfahghjxl5sy5h5mvfrrlt6me5fqphhwjqvj5jd88cccqcek
```
</details>

<details>
  <summary>How to generate a delegation address</summary>

  Follow the steps from 'How to generate a payment address'. Then, simply extend
  an existing payment address with a stake key!

```
  $ cat root.prv \
  | cardano-address key child 1852H/1815H/0H/2/0 > stake.prv

  $ cat addr.prv \
  | cardano-address key public \
  | cardano-address address payment --network-tag testnet \
  | cardano-address address delegation $(cat stake.prv | cardano-address key public)
  addr1vrcmygdgp7v3mhz78v8kdsfru0y9wysnr9pgvvgmdqx2w0qrg8swg...
```
</details>

## Docker Image

### Build

```console
$ docker build -t cardano-address .
```

### Run

Use the auto-remove flag `--rm` when running commands.

```console
$ docker run --rm cardano-address recovery-phrase generate --size 15
dismiss grit bacon glare napkin satisfy tribe proud carpet bench fantasy rich history face north
```

Use the interactive flag `-i` when piping stdin

```console
$ echo "addr1gqtnpvdhqrtpd4g424fcaq7k0ufuzyadt7djygf8qdyzevuph3wczvf2dwyx5u" | docker run --rm -i cardano-addresses address inspect
{
    "address_style": "Shelley",
    "stake_reference": "by pointer",
    "spending_key_hash": "1730b1b700d616d51555538e83d67f13c113ad5f9b22212703482cb3",
    "pointer": {
        "slot_num": 24157,
        "output_index": 42,
        "transaction_index": 177
    },
    "network_tag": 0
}
```

## Contributing

Pull requests are welcome.

When creating a pull request, please make sure that your code adheres to our
[coding standards](https://github.com/input-output-hk/adrestia/wiki/Coding-Standards).

<hr />

<p align="center">
  <a href="https://github.com/input-output-hk/cardano-addresses/blob/master/LICENSE"><img src="https://img.shields.io/github/license/input-output-hk/cardano-addresses.svg?style=for-the-badge" /></a>
</p>
