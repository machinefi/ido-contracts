## IDO contracts

```
// 0x31B68B862eD8141F370e81a98E05A17edc188041
forge create --legacy --rpc-url $ETH_RPC_URL \
  --constructor-args "0x6972C35dB95258DB79D662959244Eaa544812c5A" "0xA0C9f9A884cdAE649a42F16b057735Bc4fE786CD" \
  --private-key $PRIVATE_KEY src/Launchpad.sol:Launchpad

// Launchpad token uri provider: 0x312276F506794ABbe743e3775d0Bd03c5Bc1f4Ce
// Pod for project 2: 0x18E2D20Bc3BA64d43391a626808d4d78dbC98fC6

// 0x23E5deFE37Fdf7A054d2E7557548e0EFc6d1b1ff
forge create --legacy --rpc-url $ETH_RPC_URL \
  --constructor-args "0x31B68B862eD8141F370e81a98E05A17edc188041" \
  --private-key $PRIVATE_KEY src/test/DummyOwner.sol:DummyOwner
```

### Start IDO workflow

1. apply pod by project owner
2. start pod by Launchpad owner
