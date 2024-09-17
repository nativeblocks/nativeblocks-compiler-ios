# Nativeblocks compiler

The Nativeblocks compiler is a tool that generates server-driven blocks and actions based on Swift code. It produces
JSON and Swift files for each block and action, preparing them for upload to Nativeblocks servers.

## How it works

Before starting we need to 
- [Install the Nativeblocks frameworks](https://github.com/nativeblocks/nativeblocks-ios-sdk)
- [Install the Nativeblocks Compiler frameworks](https://github.com)

Then it needed to provide compiler arguments, Properties belongs to each Studio account, from Nativeblocks Studio, find Link Device and copy properties to `nativeblocks.json` file.
```json
{
    "endpoint": "",
    "authToken": "",
    "organizationId": ""
}
```

### [How block it works on Block](/docs/block.md)

### [How block it works on Action](/docs/action.md)

### Generate Provider

After providing annotations for blocks and actions, you can use `GenerateProvider` plugin to generates Swift code. These can then be initialize in App or via dependency injection

Note: The prefix for the provider name comes from the target name that selected. In this case, since we
provided "Demo," the
compiler generates with "Demo" prefix.

```swift
DemoBlockProvider.provideBlocks()
DemoActionProvider.provideActions(xBot)
```

For actions, all dependencies must be provided during initialization. To optimize performance, consider using dependency
injection for scoped or lazy instances.
