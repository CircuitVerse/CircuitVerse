const fs = require('fs')
const core = require('@actions/core')
const command = require('@actions/core/lib/command')

async function main() {
  const workspacePath = process.env.GITHUB_WORKSPACE
  const errorFilename = `${workspacePath}/errors.txt`

  try {

    if (fs.existsSync(errorFilename)) {
      let lines = fs.readFileSync(errorFilename).toString('utf8')
      command.issueCommand('error', undefined, lines)
    }
    else {
      core.info(`No ${errorFilename} present.  Skipping!`)
    }
  } 
  catch (error) {
    core.setFailed(`Action failed with error ${error}`)
  }

}

main()
