## IDO contracts

```
// 0xd4e87D3Af2fFc01BEeDD55bD92CD1c00Ed9c1A10
forge create --legacy --rpc-url $ETH_RPC_URL \
  --constructor-args "0x6972C35dB95258DB79D662959244Eaa544812c5A" "0x3b9650B88a78e398613eBB442788Fc4eDd1eF768" \
  --private-key $PRIVATE_KEY src/Launchpad.sol:Launchpad

// IDO NFT: 0xE04dFA88df72872c53DeE130c3f42C2142B6A158
// Pod: 0xd146879c54e97fd7eF60e605B12b2f4827DE98E6
```

### Start IDO workflow

1. apply pod by project owner
2. start pod by Launchpad owner
3. Add mint privilege to pod address for IDO contract
