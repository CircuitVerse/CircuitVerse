## Setup Code Autocompletion [LSP Solargraph]

### Visual Studio Code
1. **Native Installation**
    
    No extra configuration required

2. **Docker based Installation**

    - Go to Settings
    - Search "solargraph"
    - Look for "Solargraph: External Server"
    - Click "Edit settings.json"
    - In the JSON, add this details
    ```json
    {
      ....
      "solargraph.externalServer": {
          "host": "localhost",
          "port": 3002
      }
    }
    ```
### Sublime Text Editor

Install LSP package in Sublime Text Editor by `Type Ctrl+Shift+P > Install Package > Search & Install LSP`

1. **Native Installation**

Go to `Preferences > Package Settings > LSP > Settings` and paste this configuration

```json
{
    "clients": {
        "ruby": {
            "enabled": true,
            "command": ["solargraph", "stdio"],
            "selector": "source.ruby | text.html.ruby",
            "initializationOptions": {
                "diagnostics": false
            }
        }
    }
}
```

2. **Docker baser Installation**

Go to `Preferences > Package Settings > LSP > Settings` and paste this configuration

```json
{
    "clients": {
        "ruby": {
            "enabled": true,
            "selector": "source.ruby | text.html.ruby",
            "tcp_port": 3002,
            "initializationOptions": {
                "diagnostics": false
            }
        }
    }
}
```

### NeoVim

1. **Native Installation**

   a. With Native LSP Package
   Install `lspconfig` in Neovim

   Open config file [~/.config/nvim/init.lua] and paste this
   ```lua
   require'lspconfig'.solargraph.setup{}
   ```

   b. With CoC-nvim
   Install `coc-solargraph` by coc-nvim by running this command
   ```
   :CocInstall coc-solargraph
   ```

2. Docker Based Installation

    a. Install [coc-nvim](https://github.com/neoclide/coc.nvim)

    b. Install `coc-solargraph` by coc-nvim by running this command
    ```
    :CocInstall coc-solargraph
    ``` 
    c. Edit configuration by `:CocConfig`
    Paste this configuration. Save & Restart nvim
    ```json
    {
        "solargraph.transport": "external",
        "solargraph.externalServer": {
            "host": "localhost",
            "port": 3002
        }
    }
    ```

**To configure Solargraph for Other IDE, [Check this docs for guide](https://github.com/castwide/solargraph#using-solargraph)**
