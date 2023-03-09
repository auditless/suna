//! Missing corelib trait implementations for u256.

use array::ArrayTrait;     
use zeroable::Zeroable;

/// Canonical implementation of Zeroable for u256.
impl U256Zeroable of Zeroable::<u256> {
    #[inline(always)]
    fn zero() -> u256 {
        u256{low: 0_u128, high: 0_u128}
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

// Placeholder implementations of truncated division traits for u256.
// Implementations unsafely convert both arguments to u128.
// TODO: Remove once https://github.com/starkware-libs/cairo/issues/2329 is resolved.

/// Placeholder implementation of Div::<u256> trait.
impl U256TruncatedDiv of Div::<u256> {
    fn div(a: u256, b: u256) -> u256 {
        assert(a.high == 0_u128 & b.high == 0_u128, 'u256 too large');
        u256{low: a.low / b.low, high: 0_u128}
    }
}

/// Placeholder implementation of DivEq::<u256> trait.
impl U256TruncatedDivEq of DivEq::<u256> {
    #[inline(always)]
    fn div_eq(ref self: u256, other: u256) {
        self = Div::div(self, other);
    }
}

/// Placeholder implementation of Rem::<u256> trait.
impl U256TruncatedRem of Rem::<u256> {
    fn rem(a: u256, b: u256) -> u256 {
        assert(a.high == 0_u128 & b.high == 0_u128, 'u256 too large');
        u256{low: a.low % b.low, high: 0_u128}
    }
}

/// Placeholder implementation of RemEq::<u256> trait.
impl U256TruncatedRemEq of RemEq::<u256> {
    #[inline(always)]
    fn rem_eq(ref self: u256, other: u256) {
        self = Rem::rem(self, other);
    }
}
