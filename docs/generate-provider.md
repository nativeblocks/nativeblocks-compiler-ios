## Generate Provider

After providing annotations for blocks and actions, you can use `GenerateProvider` plugin to generates Swift code. These can then be initialize in App or via dependency injection

Note: The prefix for the provider name comes from the target name that selected. In this case, since we
provided "MYApp," the
compiler generates with "MyApp" prefix.

```swift
MyAppBlockProvider.provideBlocks()
DemoActionProvider.provideActions(xBot)
```

1) Choose `GenerateProvider`



2) Select Target



3) Add `MyAppBlockProvider.swift` to Target



4) Use `MyAppBlockProvider`



