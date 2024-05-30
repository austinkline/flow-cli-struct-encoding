# Flow CLI Struct Encoding Bug

If you try to deploy this contract using the current `flow` and `flow-c1` emulators, it is not valid:

```
➜  flow-cli-struct-encoding git:(main) ✗ flow project deploy
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                           ⚠ Upgrade to Cadence 1.0
     The Crescendo network upgrade, including Cadence 1.0, is coming soon.
     You may need to update your existing contracts to support this change.
                     Please visit our migration guide here:
             https://cadence-lang.org/docs/cadence_migration_guide
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

❗   Version warning: a new version of Flow CLI is available (v1.18.0).
   Read the installation guide for upgrade instructions: https://docs.onflow.org/flow-cli/install


Deploying 2 contracts for accounts: emulator-account

Bar -> 0xf8d6e0586b0a20c7 (a8ed940780c9128424756bb480f706681b587fb399e02dce19a9a039800aa944)
❌ Failed to deploy contract Foo: failed to deploy contract Foo: [Error Code: 1101] error caused by: 1 error occurred:
	* transaction preprocess failed: [Error Code: 1101] cadence runtime error: Execution failed:
error: cannot find type in this scope: `A`
 --> 348ebcfa7ab3252b787a7e176bcf2fa7352175f3084e9602a997b98dc3407013:2:46
  |
2 | 	transaction(name: String, code: String ,arg0:A.f8d6e0586b0a20c7.Bar.B) {
  | 	                                             ^ not found in this scope
```

```
➜  flow-cli-struct-encoding git:(main) ✗ flow-c1 project deploy

Deploying 2 contracts for accounts: emulator-account

Bar -> 0xf8d6e0586b0a20c7 (02876916dcc10a5b231b5735e9e3d794af7b83daef8b254a94d2192912bc8980)
❌ Failed to deploy contract Foo: failed to deploy contract Foo: [Error Code: 1101] error caused by: 1 error occurred:
	* transaction preprocess failed: [Error Code: 1101] cadence runtime error: Execution failed:
error: cannot find type in this scope: `A`
 --> 23be62938b9ff859fd2385c21c8792c6697f6adfd7f45eb874c96546d08089a1:2:46
  |
2 | 	transaction(name: String, code: String ,arg0:A.f8d6e0586b0a20c7.Bar.B) {
  | 	                                             ^ not found in this scope



❌ Command Error: failed deploying all contracts
```

If you inspect the submitted transaction, there are some missing imports, and the input type of the first arg is not valid.

```
➜  flow-cli-struct-encoding git:(main) ✗ flow-c1 transactions get 23be62938b9ff859fd2385c21c8792c6697f6adfd7f45eb874c96546d08089a1 --include code

Block ID	8d89edc10edd543c66d231409da162afeb3aa6dfe2829e398cc0a6965c061e20
Block Height	2
❌ Transaction Error
[Error Code: 1101] error caused by: 1 error occurred:
	* transaction preprocess failed: [Error Code: 1101] cadence runtime error: Execution failed:
error: cannot find type in this scope: `A`
 --> 23be62938b9ff859fd2385c21c8792c6697f6adfd7f45eb874c96546d08089a1:2:46
  |
2 | 	transaction(name: String, code: String ,arg0:A.f8d6e0586b0a20c7.Bar.B) {
  | 	                                             ^ not found in this scope





Status		✅ SEALED
ID		23be62938b9ff859fd2385c21c8792c6697f6adfd7f45eb874c96546d08089a1
Payer		f8d6e0586b0a20c7
Authorizers	[f8d6e0586b0a20c7]

Proposal Key:
    Address	f8d6e0586b0a20c7
    Index	0
    Sequence	1

No Payload Signatures

Envelope Signature 0: f8d6e0586b0a20c7
Signatures (minimized, use --include signatures)

Events:	 None


Arguments (3):
    - Argument 0: {"value":"Foo","type":"String"}
    - Argument 1: {"value":"import Bar from 0xf8d6e0586b0a20c7\n\naccess(all) contract Foo {\n    access(all) let B: Bar.B\n\n    init(b: Bar.B) {\n        self.B = b\n    }\n}","type":"String"}
    - Argument 2: {"value":{"id":"A.f8d6e0586b0a20c7.Bar.B","fields":[{"value":{"value":"1","type":"Int"},"name":"x"}]},"type":"Struct"}

Code


	transaction(name: String, code: String ,arg0:A.f8d6e0586b0a20c7.Bar.B) {
		prepare(signer: auth(AddContract) &Account) {
			signer.contracts.add(name: name, code: code.utf8 ,arg0)
		}
	}


Payload (hidden, use --include payload)

Fee Events (hidden, use --include fee-events)
```

The transaction should instead be:

```
import Bar from 0xf8d6e0586b0a20c7

transaction(name: String, code: String, arg0: Bar.B) {
    prepare(signer: auth(AddContract) &Account) {
        signer.contracts.add(name: name, code: code.utf8, arg0)
    }
}
```

## Versions

```
➜  flow-cli-struct-encoding git:(main) flow-c1 version
Version: v1.18.0-cadence-v1.0.0-preview.24
Commit: 6aac3b6c7f510feaf7728a48dd8ffa020feb6a0a

Flow Package Dependencies
github.com/onflow/atree v0.7.0-rc.2
github.com/onflow/cadence v1.0.0-preview.29
github.com/onflow/cadence-tools/languageserver v1.0.0-preview.29
github.com/onflow/cadence-tools/lint v1.0.0-preview.29
github.com/onflow/cadence-tools/test v1.0.0-preview.29
github.com/onflow/contract-updater/lib/go/templates v1.0.1
github.com/onflow/crypto v0.25.1
github.com/onflow/fcl-dev-wallet v0.8.0-stable-cadence.1
github.com/onflow/flixkit-go v1.2.1-cadence-v1-preview.15
github.com/onflow/flow-core-contracts/lib/go/contracts v1.1.0
github.com/onflow/flow-core-contracts/lib/go/templates v1.0.0
github.com/onflow/flow-emulator v1.0.0-preview.23
github.com/onflow/flow-evm-gateway v0.11.0
github.com/onflow/flow-ft/lib/go/contracts v1.0.0
github.com/onflow/flow-ft/lib/go/templates v1.0.0
github.com/onflow/flow-go v0.35.5-0.20240517202625-55f862b45dfd
github.com/onflow/flow-go-sdk v1.0.0-preview.30
github.com/onflow/flow-nft/lib/go/contracts v1.2.1
github.com/onflow/flow-nft/lib/go/templates v1.2.0
github.com/onflow/flow/protobuf/go/flow v0.4.3
github.com/onflow/flowkit/v2 v2.0.0-stable-cadence-alpha.20
github.com/onflow/go-ethereum v1.13.4
github.com/onflow/sdks v0.5.1-0.20230912225508-b35402f12bba
github.com/onflow/wal v1.0.2
```

```
➜  flow-cli-struct-encoding git:(main) ✗ flow version
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
                           ⚠ Upgrade to Cadence 1.0
     The Crescendo network upgrade, including Cadence 1.0, is coming soon.
     You may need to update your existing contracts to support this change.
                     Please visit our migration guide here:
             https://cadence-lang.org/docs/cadence_migration_guide
++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
Version: v1.17.1
Commit: 2e4dfbe6ab7c23ce65269adbf6d9887cc0a89294

Flow Package Dependencies
github.com/onflow/atree v0.6.0
github.com/onflow/cadence v0.42.10
github.com/onflow/cadence-tools/languageserver v0.33.5-0.20240412233530-f5cf3a868fc6
github.com/onflow/cadence-tools/lint v0.14.2
github.com/onflow/cadence-tools/test v0.14.7
github.com/onflow/crypto v0.25.1
github.com/onflow/fcl-dev-wallet v0.7.4
github.com/onflow/flixkit-go v1.1.3
github.com/onflow/flow-core-contracts/lib/go/contracts v1.2.4-0.20231016154253-a00dbf7c061f
github.com/onflow/flow-core-contracts/lib/go/templates v1.2.4-0.20231016154253-a00dbf7c061f
github.com/onflow/flow-emulator v0.62.1
github.com/onflow/flow-ft/lib/go/contracts v0.7.1-0.20230711213910-baad011d2b13
github.com/onflow/flow-go v0.33.2-0.20240412174857-015156b297b5
github.com/onflow/flow-go-sdk v0.46.2
github.com/onflow/flow-nft/lib/go/contracts v1.1.0
github.com/onflow/flow/protobuf/go/flow v0.4.0
github.com/onflow/flowkit v1.17.3
github.com/onflow/go-ethereum v1.13.4
github.com/onflow/nft-storefront/lib/go/contracts v0.0.0-20221222181731-14b90207cead
github.com/onflow/sdks v0.5.0
github.com/onflow/wal v0.0.0-20240208022732-d756cd497d3b
```