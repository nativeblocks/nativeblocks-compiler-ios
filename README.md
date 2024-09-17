# Nativeblocks compiler

The Nativeblocks compiler is a tool that generates server-driven blocks and actions based on Swift code. It produces
JSON and Swift files for each block and action, preparing them for upload to Nativeblocks servers.

## How it works

Before starting we need to 
- [Install the Nativeblocks frameworks](https://github.com/nativeblocks/nativeblocks-ios-sdk)
- [Install the Nativeblocks Compiler frameworks](/docs/install.md)

Then it needed to provide compiler arguments, Properties belongs to each Studio account, from Nativeblocks Studio, find Link Device and copy properties to `nativeblocks.json` file.
```json
{
    "endpoint": "",
    "authToken": "",
    "organizationId": ""
}
```

- #### [How block it works on Block](/docs/block.md)
- #### [How block it works on Action](/docs/action.md)
- #### [How to generate provider](/docs/generate-provider.md)
- #### [How to sync natives](/docs/sync.md)



