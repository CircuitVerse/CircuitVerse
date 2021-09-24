
# Install Node

Using Homebrew, install Node (npm will be installed with Node):

```
brew install node
```

# Install Yarn

Yarn provides dependency management, so install it:

```
brew install yarn
```

# Install NCC

NCC is used to compile the *.js into a dist/index.js

```
npm i -g @zeit/ncc
```

# Build the dist/index.js

```
yarn run package
```

# Installing new javascript packages

Adding new javascript packages is fairly straightforward.  If you're adding a github @actions/xxx package,
simply refer to it by its short-hand name:

```
npm install @actions/core
```

# Optional pre-commit hook

A pre-commit hook is provided that can help keep dist/index.js in tune with local changes


# Using Node as a REPL

If you're developing or working on the index.js script, it can be handy to try out stuff 
locally.  To do that, use Node to start up a REPL shell by running it from the action's folder:

```
cd .github/workflow/actions/annotate
node
```

Example session:

```javascript
Welcome to Node.js v14.3.0.
Type ".help" for more information.
> const os = require('os')
undefined
> const fs = require('fs')
undefined
> const path = require('path')
undefined
>
> const core = require('@actions/core')
undefined
> core.startGroup("hello")
::group::hello
undefined
> console.debug("hello")
hello
undefined
> core.endGroup()
::endgroup::
undefined
```