use option::OptionTrait;
use traits::Into;
use traits::TryInto;
use zeroable::Zeroable;

use suna::math::u256::U256TruncatedDiv;
use suna::math::u256::U256TruncatedDivEq;
use suna::math::u256::U256TruncatedRem;
use suna::math::u256::U256TruncatedRemEq;
use suna::math::u256::U256Zeroable;

#[test]
fn test_u256_zeroable() {
    assert(U256Zeroable::zero() == u256{low: 0_u128, high: 0_u128}, 'zero() error');
    assert(U256Zeroable::is_zero(u256{low: 0_u128, high: 0_u128}), 'is_zero error');
    assert(!U256Zeroable::is_zero(u256{low: 1_u128, high: 0_u128}), 'is_zero error');
    assert(!U256Zeroable::is_zero(u256{low: 0_u128, high: 1_u128}), 'is_zero error');
    assert(!U256Zeroable::is_non_zero(u256{low: 0_u128, high: 0_u128}), 'is_non_zero error');
    assert(U256Zeroable::is_non_zero(u256{low: 1_u128, high: 0_u128}), 'is_non_zero error');
    assert(U256Zeroable::is_non_zero(u256{low: 0_u128, high: 1_u128}), 'is_non_zero error');
}

fn t_trunc_div_rem(a: felt, b: felt) {
    let a1: u128 = a.try_into().unwrap();
    let b1: u128 = b.try_into().unwrap();
    let a2: u256 = a.into();
    let b2: u256 = b.into();
    assert(u256{low: a1 / b1, high: 0_u128} == a2 / b2, 'div error');
    assert(u256{low: a1 % b1, high: 0_u128} == a2 % b2, 'rem error');

    let mut x = a2;
    x /= b2;
    let mut y = a2;
    y %= b2;
    assert(u256{low: a1 / b1, high: 0_u128} == x, 'div_eq error');
    assert(u256{low: a1 % b1, high: 0_u128} == y, 'rem_eq error');
}

#[test]
fn test_u256_div_traits() {
    t_trunc_div_rem(0, 1);
    t_trunc_div_rem(5, 7);
    t_trunc_div_rem(7, 5);
    t_trunc_div_rem(999, 20);
    t_trunc_div_rem(1000, 20);
    t_trunc_div_rem(1001, 20);
}

#[test]
#[should_panic]
fn test_div_by_zero() {
    let a: u256 = 10.into();
    let b: u256 = 0.into();
    let q = a / b;
}

#[test]
#[should_panic]
fn test_rem_by_zero() {
    let a: u256 = 10.into();
    let b: u256 = 0.into();
    let q = a % b;
}
