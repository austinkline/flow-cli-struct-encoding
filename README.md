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