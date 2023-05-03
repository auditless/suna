use suna::math::u256::U256Zeroable;

#[test]
fn test_u256_zeroable() {
    assert(U256Zeroable::zero() == u256 { low: 0_u128, high: 0_u128 }, 'zero() error');
    assert(U256Zeroable::is_zero(u256 { low: 0_u128, high: 0_u128 }), 'is_zero error');
    assert(!U256Zeroable::is_zero(u256 { low: 1_u128, high: 0_u128 }), 'is_zero error');
    assert(!U256Zeroable::is_zero(u256 { low: 0_u128, high: 1_u128 }), 'is_zero error');
    assert(!U256Zeroable::is_non_zero(u256 { low: 0_u128, high: 0_u128 }), 'is_non_zero error');
    assert(U256Zeroable::is_non_zero(u256 { low: 1_u128, high: 0_u128 }), 'is_non_zero error');
    assert(U256Zeroable::is_non_zero(u256 { low: 0_u128, high: 1_u128 }), 'is_non_zero error');
}
