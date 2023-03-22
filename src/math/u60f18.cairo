//! Decimal fixed-point datatype based on u256.

use debug::PrintTrait;
use traits::Into;

use suna::math::u256::U256TruncatedDiv;
use suna::math::u256::U256TruncatedRem;
use suna::math::u256::U256Zeroable;

/// Rounding mode.
#[derive(Copy, Drop)]
enum Rounding {
    /// Round toward negative infinity
    Down: (),
    /// Round toward infinity
    Up: (),
    /// Round toward zero
    Zero: (),
}

/// Return a * b / c rounded down.
fn mul_div_down(a: u256, b: u256, denominator: u256) -> u256 {
    let max_u128 = 0xffffffffffffffffffffffffffffffff_u128;
    // let max_u256 = u256{low: max_u128, high: max_u128};
    // TODO: Change this back when u256 non-truncating division is implemented
    let max_u256 = 0xffffffffffffffffffffffffffffffff.into();
    let cond = U256Zeroable::is_non_zero(
        denominator
    ) & (U256Zeroable::is_zero(b) | a <= max_u256 / b);
    assert(cond, 'multiplication overflow');
    a * b / denominator
}

/// Return a * b % denominator without checks.
fn unsafe_mul_mod(a: u256, b: u256, denominator: u256) -> u256 {
    a * b % denominator
}

trait MulDiv<T> {
    /// Return a * b / denominator with given rounding mode.
    fn mul_div(a: T, b: T, denominator: T, rounding: Rounding) -> T;
}

impl U256MulDiv of MulDiv::<u256> {
    fn mul_div(a: u256, b: u256, denominator: u256, rounding: Rounding) -> u256 {
        let result = mul_div_down(a, b, denominator);
        match rounding {
            Rounding::Down(_) => result,
            Rounding::Up(_) => if unsafe_mul_mod(
                a, b, denominator
            ) > 0.into() {
                result + 1.into()
            } else {
                result
            },
            Rounding::Zero(_) => result,
        }
    }
}

/// Unsigned 18-decimal fixed point representation.
/// 60-decimal unsigned part and 18-decimal fractional part
/// (nomenclature borrowed from the Rust crate `fixed`
/// but adapted to use decimals rather than bits).
#[derive(Copy, Drop)]
struct U60F18 {
    /// A scaled value of x represents the fraction x / 10^18
    scaled: u256,
}

impl U60F18Add of Add::<U60F18> {
    fn add(a: U60F18, b: U60F18) -> U60F18 {
        U60F18 { scaled: a.scaled + b.scaled }
    }
}

impl U60F18AddEq of AddEq::<U60F18> {
    #[inline(always)]
    fn add_eq(ref self: U60F18, other: U60F18) {
        self = Add::add(self, other);
    }
}

impl U60F18Sub of Sub::<U60F18> {
    fn sub(a: U60F18, b: U60F18) -> U60F18 {
        U60F18 { scaled: a.scaled - b.scaled }
    }
}

impl U60F18SubEq of SubEq::<U60F18> {
    #[inline(always)]
    fn sub_eq(ref self: U60F18, other: U60F18) {
        self = Sub::sub(self, other);
    }
}

impl U60F18Mul of Mul::<U60F18> {
    fn mul(a: U60F18, b: U60F18) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: mul_div_down(a.scaled, b.scaled, base) }
    }
}

impl U60F18MulEq of MulEq::<U60F18> {
    #[inline(always)]
    fn mul_eq(ref self: U60F18, other: U60F18) {
        self = Mul::mul(self, other);
    }
}

impl U60F18Div of Div::<U60F18> {
    fn div(a: U60F18, b: U60F18) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: mul_div_down(a.scaled, base, b.scaled) }
    }
}

impl U60F18DivEq of DivEq::<U60F18> {
    #[inline(always)]
    fn div_eq(ref self: U60F18, other: U60F18) {
        self = Div::div(self, other);
    }
}

impl U60F18PartialEq of PartialEq::<U60F18> {
    #[inline(always)]
    fn eq(a: U60F18, b: U60F18) -> bool {
        a.scaled == b.scaled
    }
    #[inline(always)]
    fn ne(a: U60F18, b: U60F18) -> bool {
        !(a.scaled == b.scaled)
    }
}

impl U60F18PartialOrd of PartialOrd::<U60F18> {
    #[inline(always)]
    fn le(a: U60F18, b: U60F18) -> bool {
        a.scaled <= b.scaled
    }
    #[inline(always)]
    fn ge(a: U60F18, b: U60F18) -> bool {
        b.scaled <= a.scaled
    }
    #[inline(always)]
    fn lt(a: U60F18, b: U60F18) -> bool {
        a.scaled < b.scaled
    }
    #[inline(always)]
    fn gt(a: U60F18, b: U60F18) -> bool {
        b.scaled < a.scaled
    }
}

impl U60F18ToU256 of Into::<U60F18, u256> {
    fn into(self: U60F18) -> u256 {
        let base: u256 = 1000000000000000000.into();
        self.scaled / base
    }
}

impl U256ToU60F18 of Into::<u256, U60F18> {
    fn into(self: u256) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: self * base }
    }
}

impl Felt252ToU60F18 of Into::<felt252, U60F18> {
    fn into(self: felt252) -> U60F18 {
        let a: u256 = self.into();
        a.into()
    }
}

impl U60F18PrintImpl of PrintTrait::<U60F18> {
    fn print(self: U60F18) {
        self.scaled.print();
    }
}

/// This is a ChatGPT generated StorageAccess implementation
/// Do not trust it until it's testable
impl StorageAccessU60F18 of StorageAccess::<U60F18> {
    fn read(address_domain: u32, base: StorageBaseAddress) -> SyscallResult<U60F18> {
        Result::Ok(U256ToU60F18::into(StorageAccess::<u256>::read(address_domain, base)?))
    }

    fn write(address_domain: u32, base: StorageBaseAddress, value: U60F18) -> SyscallResult<()> {
        StorageAccess::<u256>::write(address_domain, base, U60F18ToU256::into(value))
    }
}
