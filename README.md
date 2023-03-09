<p align="center">
  <img src=".github/cover.png" alt="Suna Cover Photo" width="400">
</p>

# Suna ![PRs Welcome](https://img.shields.io/badge/PRs-welcome-green.svg) [![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://github.com/auditless/suna/blob/main/LICENSE) <a href="https://github.com/auditless/suna/actions/workflows/test.yaml"> <img src="https://github.com/auditless/suna/actions/workflows/test.yaml/badge.svg?event=push" alt="CI Badge"/> </a>

[Built with **`auditless/cairo-template`**](https://github.com/auditless/cairo-template)

Typesafe opinionated abstractions for developing Cairo 1.0 smart contracts.
Originally created to facilitate [Yagi Finance](https://www.yagi.fi) smart contract development.

## What is included

- [`suna.math.u256`](https://github.com/auditless/suna/blob/main/src/math/u256.cairo): Missing trait implementations for the `u256` data type: `U256Zeroable` and a truncated division implementation `U256TruncatedDiv` of `Div<u256>`
- [`suna.math.u60f18`](https://github.com/auditless/suna/blob/main/src/math/u60f18.cairo): An unsigned fixed point decimal type based on `u256`; `MulDiv` trait and operators

## Warning

Suna is an experimental and unaudited library and is subject to a lot of iteration.
There may be bugs.


## How to use the library

You can directly add Suna to your Scarb dependencies:

```toml
[dependencies]
suna = { git = "https://github.com/auditless/suna.git" }
```

The below examples are illustrative and you can find more
functions by reading the code and tests directly.

### `u256` trait implementations

Most Defi applications will use the `u256` type to deal with token amounts.
Unfortunately the trait implementations are not yet complete.
To add support for `u256` division/mod operations, add the following:

```cairo
use suna::math::u256::U256TruncatedDiv;
use suna::math::u256::U256TruncatedDivEq;
use suna::math::u256::U256TruncatedRem;
use suna::math::u256::U256TruncatedRemEq;

let a: u256 = 10.into();
let b: u256 = 2.into();
let c = a / b; // this will now work
```

### `MulDiv` trait

When building a yield/pooling application, you may need a way to
calculate how much of an underlying asset a given share owner
controls. You can do it as follows:

```cairo
use suna::math::u60f18::U256MulDiv;

let total_supply: u256 = 10000.into();
let shares: u256 = 33.into();
let total_assets: u256 = 853000000000000000000.into();
// Calculates shares * total_assets / total_supply safely
let assets_owned = U256MulDiv::mul_div(shares, total_assets, total_supply);
```

### An 18-decimal fixed point type `U60F18`

You may also want to maintain certain fractional values such as weights
or interest rates in your application using 18 decimals. To do that,
you can use our `U60F18` type which supports conversion from `u256`
and many of the standard operators:

```cairo
use traits::Into;
use suna::math::u60f18::U256ToU60F18;
use suna::math::u60f18::U60F18DivEq;

// Represent an interest rate of 2%
let mut interest_rate: U60F18 = 2.into();
interest_rate /= 100.into();
```

## Design principles

- Be useful to developers building production Cairo contracts
- Design from first principles with both Rust and smart contract idioms in mind
- Build typesafe and efficient abstractions that are consistently designed
- Respect and embrace the `corelib` trait hierarchy
- Aspire to build well-documented and declarative code

## How to contribute

- Read the Cairo 1.0 setup guide at https://github.com/auditless/cairo-template
- Check our issues for scoped tasks or propose/request a new one by opening an issue
- Submit a PR linking the relevant issue
- You may also submit a PR that fixes a bug or nit directly

## Thanks to

- The [Quaireaux](https://github.com/keep-starknet-strange/quaireaux) team for paving the way for Cairo 1.0 library development
- The [Scarb](https://github.com/software-mansion/scarb) contributors for creating a pioneering package manager which we rely on
- The [OpenZeppelin](https://github.com/OpenZeppelin/openzeppelin-contracts) team for the mulDiv interface
- S. Tsuchiya for the cover photo
- Last but not least, the StarkWare team for building the first smart contract language that is a joy to use

## License

[MIT](https://github.com/auditless/suna/blob/main/LICENSE) © [Auditless Limited](https://www.auditless.com)
