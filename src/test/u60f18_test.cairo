use debug::PrintTrait;
use traits::Into;

use suna::math::u60f18::Felt252ToU60F18;
use suna::math::u60f18::Rounding;
use suna::math::u60f18::U256MulDiv;
use suna::math::u60f18::U256ToU60F18;
use suna::math::u60f18::U60F18;
use suna::math::u60f18::U60F18DivEq;
use suna::math::u60f18::U60F18Mul;
use suna::math::u60f18::U60F18MulEq;
use suna::math::u60f18::U60F18PartialEq;
use suna::math::u60f18::U60F18PartialOrd;
use suna::math::u60f18::U60F18PrintImpl;
use suna::math::u60f18::U60F18ToU256;

fn t_mul_div_down(a: felt252, b: felt252, denominator: felt252, expected: felt252) {
    let result = U256MulDiv::mul_div(a.into(), b.into(), denominator.into(), Rounding::Down(()));
    assert(result == expected.into(), 'mul_div invalid');
}

fn t_mul_div_up(a: felt252, b: felt252, denominator: felt252, expected: felt252) {
    let result = U256MulDiv::mul_div(a.into(), b.into(), denominator.into(), Rounding::Up(()));
    assert(result == expected.into(), 'mul_div invalid');
}

#[test]
fn test_mul_div_down() {
    let base = 1000000000000000000;
    t_mul_div_down(13, 7, 5, 18);
    t_mul_div_down(7, 13, 5, 18);
    t_mul_div_down(13, base, 7, 1857142857142857142);
    t_mul_div_down(base, 13, 7, 1857142857142857142);
    t_mul_div_down(0, 7, base, 0);
}

#[test]
fn test_mul_div_up() {
    let base = 1000000000000000000;
    t_mul_div_up(13, 7, 5, 19);
    t_mul_div_up(7, 13, 5, 19);
    t_mul_div_up(13, base, 7, 1857142857142857143);
    t_mul_div_up(base, 13, 7, 1857142857142857143);
    t_mul_div_up(0, 7, base, 0);
}

#[test]
#[should_panic(expected: ('multiplication overflow', ))]
fn test_mul_div_down_failed() {
    U256MulDiv::mul_div(1.into(), 1.into(), 0.into(), Rounding::Down(()));
}

#[test]
#[should_panic(expected: ('multiplication overflow', ))]
fn test_mul_div_up_failed() {
    U256MulDiv::mul_div(1.into(), 1.into(), 0.into(), Rounding::Up(()));
}

#[test]
fn test_u256_to_u60f18_conversion() {
    let base: u256 = 1000000000000000000.into();
    let a: u256 = 2.into();
    let a_fraction: U60F18 = a.into();
    assert(a_fraction.scaled == a * base, 'u60f18 conversion invalid');
}
#[test]
fn test_u60f18_to_u256_conversion() {
    let base: u256 = 1000000000000000000.into();
    let a: u256 = 2.into();
    let a_fraction = U60F18 { scaled: a * base + 95.into() };
    assert(a == a_fraction.into(), 'u60f18 conversion invalid');
}

#[test]
fn test_u60f18_arithmetic() {
    let a: U60F18 = 57.into();
    let mut b: U60F18 = 68.into();
    b /= 1000.into();
    assert(a * b == b * a, 'u60f18 mul noncommute');
    assert(b < a, 'u60f18 lt failed');
    assert(b <= a, 'u60f18 le failed');
    assert(b <= b, 'u60f18 le failed');
    assert(a * b < a, 'u60f18 le failed');
    b *= 1000.into();
    assert(b == 68.into(), 'u60f18 mul_eq failed');
}

