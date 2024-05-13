## IDO contracts

```
// 0x2De4af58D2602091315813886aF79f19B91DA416
forge create --legacy --rpc-url $ETH_RPC_URL \
  --constructor-args "0x6972C35dB95258DB79D662959244Eaa544812c5A" "0x3b9650B88a78e398613eBB442788Fc4eDd1eF768" \
  --private-key $PRIVATE_KEY src/Launchpad.sol:Launchpad

// Launchpad token uri provider: 0x312276F506794ABbe743e3775d0Bd03c5Bc1f4Ce
// Pod for project 2: 0x18E2D20Bc3BA64d43391a626808d4d78dbC98fC6

// 0xbA2ea0b732BFE261eFE2356339eE0DB53AdECFFe
forge create --legacy --rpc-url $ETH_RPC_URL \
  --constructor-args "0x2De4af58D2602091315813886aF79f19B91DA416" \
  --private-key $PRIVATE_KEY src/test/DummyOwner.sol:DummyOwner
```

### Start IDO workflow

1. apply pod by project owner
2. start pod by Launchpad owner
