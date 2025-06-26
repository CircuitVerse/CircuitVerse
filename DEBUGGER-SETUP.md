## Instructions For Using Ruby Debugger
Ruby's debug.rb is a powerful tool that allows for you to stop the execution of the application at a particular moment and to investigate and interact within that context

#### Debugging with VSCode
1. Install [VSCode rdbg Ruby Debugger](https://marketplace.visualstudio.com/items?itemName=KoichiSasada.vscode-rdbg) extension.
    >  Use v1.0.0 of this extension
2. Run the app by `./bin/dev`
3. Go to Debug Menu
4. Choose `Attach Debugger`
5. Now you can set breakpoint and  debug

#### Debugging with Chrome

1. Run the app by `./bin/dev chrome_debug`
2. Chrome Devtools will be open
3. In Chrome, Move to `Filesystem` and add `CircuitVerse` folder to workspace
4. Now you can open any file and set breakpoint to debug

#### Debugging with VSCode (Docker)
1. Install [VSCode rdbg Ruby Debugger](https://marketplace.visualstudio.com/items?itemName=KoichiSasada.vscode-rdbg) extension.
    >  Use v1.0.0 of this extension
2. Run by `docker compose up`
3. Go to Debug Menu
4. Choose `(Docker) Attach Debugger[:3001]`
5. Now you can set breakpoint and  debug from VSCode 