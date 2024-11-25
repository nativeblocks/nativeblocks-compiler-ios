## Generate Provider

After providing annotations for blocks and actions, you can use the `GenerateProvider` plugin to generate Swift code. These can then be initialized in App or via dependency injection

Note: The prefix for the provider name comes from the target name that was selected. In this case, since we
provided "MyApp," the
the compiler generates with the "MyApp" prefix.

```swift
MyAppBlockProvider.provideBlocks()
MyAppBlockProvider.provideActions(bot)
```

1) Choose `GenerateProvider`

<img src="./resource/generate-provider-1.png" alt="generate-provider-1" height="400"/>

2) Select Target

<img src="./resource/generate-provider-2.png" alt="generate-provider-2" height="400"/>

3) Add `MyAppBlockProvider.swift` to Target

<img src="./resource/generate-provider-3.png" alt="generate-provider-3" height="400"/>

4) Use `MyAppBlockProvider`

<img src="./resource/generate-provider-4.png" alt="generate-provider-4" height="400"/>

