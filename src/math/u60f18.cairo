//! Decimal fixed-point datatype based on u256.

use debug::PrintTrait;
use traits::Into;

use core::integer::U256Div;
use core::integer::U256Rem;
use core::zeroable::Zeroable;
use core::integer::U256Mul;

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
fn mul_div_down(lhs: u256, rhs: u256, denominator: u256) -> u256 {
    let max_u128 = 0xffffffffffffffffffffffffffffffff_u128;
    let max_u256 = u256 { low: max_u128, high: max_u128 };
    // TODO: Change this back when u256 non-truncating division is implemented
    // let max_u256 = 0xffffffffffffffffffffffffffffffff.into();
    let cond = Zeroable::is_non_zero(
        denominator
    ) & (Zeroable::is_zero(rhs) | lhs <= Div::div(max_u256, rhs));
    assert(cond, 'multiplication overflow');
    lhs * rhs / denominator
}

/// Return a * b % denominator without checks.
fn unsafe_mul_mod(lhs: u256, rhs: u256, denominator: u256) -> u256 {
    lhs * rhs % denominator
}

trait MulDiv<T> {
    /// Return a * b / denominator with given rounding mode.
    fn mul_div(lhs: T, rhs: T, denominator: T, rounding: Rounding) -> T;
}

impl U256MulDiv of MulDiv<u256> {
    fn mul_div(lhs: u256, rhs: u256, denominator: u256, rounding: Rounding) -> u256 {
        let result = mul_div_down(lhs, rhs, denominator);
        match rounding {
            Rounding::Down(_) => result,
            Rounding::Up(_) => if unsafe_mul_mod(
                lhs, rhs, denominator
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

impl U60F18Add of Add<U60F18> {
    fn add(lhs: U60F18, rhs: U60F18) -> U60F18 {
        U60F18 { scaled: lhs.scaled + rhs.scaled }
    }
}

impl U60F18AddEq of AddEq<U60F18> {
    #[inline(always)]
    fn add_eq(ref self: U60F18, other: U60F18) {
        self = Add::add(self, other);
    }
}

impl U60F18Sub of Sub<U60F18> {
    fn sub(lhs: U60F18, rhs: U60F18) -> U60F18 {
        U60F18 { scaled: lhs.scaled - rhs.scaled }
    }
}

impl U60F18SubEq of SubEq<U60F18> {
    #[inline(always)]
    fn sub_eq(ref self: U60F18, other: U60F18) {
        self = Sub::sub(self, other);
    }
}

impl U60F18Mul of Mul<U60F18> {
    fn mul(lhs: U60F18, rhs: U60F18) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: mul_div_down(lhs.scaled, rhs.scaled, base) }
    }
}

impl U60F18MulEq of MulEq<U60F18> {
    #[inline(always)]
    fn mul_eq(ref self: U60F18, other: U60F18) {
        self = Mul::mul(self, other);
    }
}

impl U60F18Div of Div<U60F18> {
    fn div(lhs: U60F18, rhs: U60F18) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: mul_div_down(lhs.scaled, base, rhs.scaled) }
    }
}

impl U60F18DivEq of DivEq<U60F18> {
    #[inline(always)]
    fn div_eq(ref self: U60F18, other: U60F18) {
        self = Div::div(self, other);
    }
}

impl U60F18PartialEq of PartialEq<U60F18> {
    #[inline(always)]
    fn eq(lhs: U60F18, rhs: U60F18) -> bool {
        lhs.scaled == rhs.scaled
    }
    #[inline(always)]
    fn ne(lhs: U60F18, rhs: U60F18) -> bool {
        !(lhs.scaled == rhs.scaled)
    }
}

impl U60F18PartialOrd of PartialOrd<U60F18> {
    #[inline(always)]
    fn le(lhs: U60F18, rhs: U60F18) -> bool {
        lhs.scaled <= rhs.scaled
    }
    #[inline(always)]
    fn ge(lhs: U60F18, rhs: U60F18) -> bool {
        rhs.scaled <= lhs.scaled
    }
    #[inline(always)]
    fn lt(lhs: U60F18, rhs: U60F18) -> bool {
        lhs.scaled < rhs.scaled
    }
    #[inline(always)]
    fn gt(lhs: U60F18, rhs: U60F18) -> bool {
        rhs.scaled < lhs.scaled
    }
}

impl U60F18ToU256 of Into<U60F18, u256> {
    fn into(self: U60F18) -> u256 {
        let base: u256 = 1000000000000000000.into();
        self.scaled / base
    }
}

impl U256ToU60F18 of Into<u256, U60F18> {
    fn into(self: u256) -> U60F18 {
        let base: u256 = 1000000000000000000.into();
        U60F18 { scaled: self * base }
    }
}

impl Felt252ToU60F18 of Into<felt252, U60F18> {
    fn into(self: felt252) -> U60F18 {
        let a: u256 = self.into();
        a.into()
    }
}

impl U60F18PrintImpl of PrintTrait<U60F18> {
    fn print(self: U60F18) {
        self.scaled.print();
    }
}

/// Canonical implementation of Zeroable for u256.
impl U256Zeroable of Zeroable<u256> {
    #[inline(always)]
    fn zero() -> u256 {
        u256 { low: 0_u128, high: 0_u128 }
    }

    #[inline(always)]
    fn is_zero(self: u256) -> bool {
        self == U256Zeroable::zero()
    }

    #[inline(always)]
    fn is_non_zero(self: u256) -> bool {
        !self.is_zero()
    }
}
// TODO: Implement StorageAccess once it's testable

