//
// NOTE: This action script is Ubuntu specific!
//

const os = require('os')
const fs = require('fs')
const path = require('path')
const crypto = require('crypto')

const core = require('@actions/core')
const exec = require('@actions/exec')
const cache = require('@actions/cache')
const io = require('@actions/io')

let aptUpdated = false; // only `sudo apt-get update` once!


// removes trailing newlines and linefeeds from the given text string
function chomp(text) {
  return text.replace(/(\n|\r)+$/, '')
}

// invokes the @actions/exec exec function with listeners to capture the 
// output stream as the return result.
async function execute(command) {
 try {
   let outputStr = ''

   const options = {}
   options.listeners = {
     stdout: (data) => { outputStr += data.toString() },
     stderr: (data) => { core.error(data.toString()) }
   }

   await exec.exec(command, [], options)

   return chomp(outputStr);

 } catch (error) {
   console.error(error.toString())
 }
}

// given one or more space-separated (not comma-delimited) dependency 
// names, invokes the package manager to install them.
async function installDependencies(kind, dependencyList) {
  if (dependencyList === '') { return }
  core.startGroup(`Installing ${kind} dependencies`)

  core.info(`installing ${kind} dependencies ${dependencyList}`)

  // only update package list once per workflow invocation.
  if (!aptUpdated) {
    await exec.exec(`sudo apt-get update`)
    aptUpdated = true
  }
  await exec.exec(`sudo apt-get install -y --no-install-recommends ${dependencyList}`)

  core.endGroup()
}

// installs system dependencies needed to successfully build the ruby executables
async function installBuildDependencies() {
  const dependencyList = 'libyaml-dev libgdbm-dev libreadline-dev libncurses5-dev zlib1g-dev libffi-dev'

  await installDependencies('ruby-build', dependencyList);
}

// Returns if Ruby version is <= 2.3
function usesOldOpenSsl(rubyVersion) {
  return rubyVersion.match(/^2\.[0123]/);
}

// ruby-build is used to compile Ruby and it's various executables
// rbenv's ruby-build doesn't fully support EOL rubies (< 2.4 at time of this writing).
// setup-ruby also doesn't correctly build the older rubies with openssl support.
// long story short, openssl library for these older ruby need to be 1.0 variant.
async function installRubyBuild(rubyVersion) {
  core.startGroup(`Installing ruby-build`)

  const buildDir = `${process.env.HOME}/ruby-build`
  var repoPath

  // Rubies 2.0 ... 2.3 (these need OpenSSL 1.0 and eregon provides it for us)
  if (usesOldOpenSsl(rubyVersion)) {
    core.info('cloning eregon/ruby-build')
    repoPath = '--branch ruby23-openssl-linux https://github.com/eregon/ruby-build.git'

  // all the other Rubies
  } else {
    core.info('cloning rbenv/ruby-build')
    repoPath = 'https://github.com/rbenv/ruby-build.git'
  }

  await exec.exec(`git clone ${repoPath} ${buildDir}`)
  await exec.exec(`sudo ${buildDir}/install.sh`)

  core.endGroup()
}

// Add the environment variables needed to correctly build ruby and later run ruby tests.
// this function is invoked even if ruby is cached and compile step is skipped.
async function setupRubyEnvironment(rubyVersion) {

  // LANG environment must be set or Ruby will default external_encoding to US-ASCII i
  // instead of UTF-8 and this will fail many tests.
  core.exportVariable('LANG', 'C.UTF-8')

  // https://github.com/actions/virtual-environments/issues/267
  core.exportVariable('CPPFLAGS', '-DENABLE_PATH_CHECK=0')

  // Ensures Bundler retries failed attempts before giving up
  core.exportVariable('BUNDLE_RETRY', 1)

  // Number of jobs in parallel 
  core.exportVariable('BUNDLE_JOBS', 4)

  // Where to keep the gem files
  core.exportVariable('BUNDLE_PATH', gemspecFilePath(rubyVersion))

  // enable-shared prevents native extension gems from breaking if they're cached
  // independently of the ruby binaries
  core.exportVariable('RUBY_CONFIGURE_OPTS', '--enable-shared --disable-install-doc')

  // many multiverse suite tests end up in resource contention when run in parallel
  core.exportVariable('SERIALIZE', 1)
}

// Sets up any options at the bundler level so that when gems that 
// need specific settings are installed, their specific flags are relayed.
async function configureBundleOptions(rubyVersion) {
  if (!usesOldOpenSsl(rubyVersion)) { return }

  const openSslPath = rubyOpenSslPath(rubyVersion);
  
  // https://stackoverflow.com/questions/30834421/error-when-trying-to-install-app-with-mysql2-gem
  await exec.exec('bundle', [
    'config', '--global', 'build.mysql2',
      `"--with-ldflags=-L${openSslPath}/lib"`,
      `"--with-cppflags=-I${openSslPath}/include"`
  ]);
}

// prepends the given value to the environment variable
function prependEnv(envName, envValue, divider=' ') {
  let existingValue = process.env[envName];
  if (existingValue) {
    envValue += `${divider}${existingValue}`
  }
  core.exportVariable(envName, envValue);
}

// The older Rubies also need older MySQL that was built against the older OpenSSL libraries.
// Otherwise mysql adapter will segfault in Ruby because it attempts to dynamically link 
// to the 1.1 series while Ruby links against the 1.0 series.
async function downgradeMySQL() {
  core.startGroup(`Downgrade MySQL`)

  const pkgDir = `${process.env.HOME}/packages`
  const pkgOption = `--directory-prefix=${pkgDir}/`
  const mirrorUrl = 'https://mirrors.mediatemple.net/debian-security/pool/updates/main/m/mysql-5.5'

  // executes the following all in parallel  
  const promise1 = exec.exec('sudo', ['apt-get', 'remove', 'mysql-client'])
  const promise2 = exec.exec('wget', [pkgOption, `${mirrorUrl}/libmysqlclient18_5.5.62-0%2Bdeb8u1_amd64.deb`])
  const promise3 = exec.exec('wget', [pkgOption, `${mirrorUrl}/libmysqlclient-dev_5.5.62-0%2Bdeb8u1_amd64.deb`])

  // wait for the parallel processes to finish
  await Promise.all([promise1, promise2, promise3])

  // executes serially
  await exec.exec('sudo', ['dpkg', '-i', `${pkgDir}/libmysqlclient18_5.5.62-0+deb8u1_amd64.deb`])
  await exec.exec('sudo', ['dpkg', '-i', `${pkgDir}/libmysqlclient-dev_5.5.62-0+deb8u1_amd64.deb`])

  core.endGroup()
}

// mySQL (and others) must be downgraded for EOL rubies for native extension
// gems to install correctly and against the right openSSL libraries.
async function downgradeSystemPackages(rubyVersion) {
  if (!usesOldOpenSsl(rubyVersion)) { return }

  await downgradeMySQL();
}

// any settings needed in all Ruby environments from EOL'd rubies to current
async function setupAllRubyEnvironments() {
  // core.startGroup("Setup for all Ruby Environments")

  // // No-Op

  // core.endGroup()
}

// any settings needed specifically for the EOL'd rubies
async function setupOldRubyEnvironments(rubyVersion) {
  if (!usesOldOpenSsl(rubyVersion)) { return }

  core.startGroup("Setup for EOL Ruby Environments")

  const openSslPath = rubyOpenSslPath(rubyVersion);

  core.exportVariable('OPENSSL_DIR', openSslPath)

  prependEnv('LDFLAGS', `-L${openSslPath}/lib`)
  prependEnv('CPPFLAGS', `-I${openSslPath}/include`)
  prependEnv('PKG_CONFIG_PATH', `${openSslPath}/lib/pkgconfig`, ':')

  openSslOption = `--with-openssl-dir=${openSslPath}`
  core.exportVariable('CONFIGURE_OPTS', openSslOption)
  prependEnv('RUBY_CONFIGURE_OPTS', openSslOption)

  // required for some versions of nokogiri
  gemInstall('pkg-config', '~> 1.1.7')

  core.endGroup()
}

// setup the Ruby environment settings after Ruby has been built
// or restored from cache.
async function setupRubyEnvironmentAfterBuild(rubyVersion) {
  await setupAllRubyEnvironments()
  await setupOldRubyEnvironments(rubyVersion)
}

// Shows some version love!
async function showVersions() {
  core.startGroup("Show Versions")

  await exec.exec('ruby', ['--version'])
  await exec.exec('ruby', ['-ropenssl', '-e', "puts OpenSSL::OPENSSL_LIBRARY_VERSION"])
  await exec.exec('gem', ['--version'])
  await exec.exec('bundle', ['--version'])
  await exec.exec('openssl', ['version'])

  core.endGroup()
}

// Just one place to define the ruby binaries path and that is here
// NOTE: the cache step in the workflow .yml file must match this path
function rubyPath(rubyVersion) {
  return `${process.env.HOME}/.rubies/ruby-${rubyVersion}`
}

// Returns the path to openSSL that this version of Ruby was compiled with.
// NOTE: throws an error if called for Rubies that are compiled against the system OpenSSL
function rubyOpenSslPath(rubyVersion) {
  if (usesOldOpenSsl(rubyVersion)) {
    return `${rubyPath(rubyVersion)}/openssl`;
  }
  else {
    throw `custom OpenSSL path not needed for this version of Ruby ${rubyVersion}`;
  }
}

// This "activates" our newly built ruby so it comes first in the path
function addRubyToPath(rubyVersion) {
  core.addPath(`${rubyPath(rubyVersion)}/bin`);

  if (usesOldOpenSsl(rubyVersion)) {
    core.addPath(`${rubyPath(rubyVersion)}/openssl/bin`);
  }
}

// kicks off the ruby build process.
async function buildRuby(rubyVersion) {
  core.startGroup(`Build Ruby ${rubyVersion}`)
  await exec.exec(`ruby-build --verbose ${rubyVersion} ${rubyPath(rubyVersion)}`) 
  core.endGroup()
}

// Older rubies come with Ruby gems 2.5.x and we need 3.0.6 minimum to 
// correctly install Bundler and do anything else within the multiverse test suite
async function upgradeRubyGems(rubyVersion) {
  core.startGroup(`Upgrade RubyGems`)

  await execute('gem --version').then(res => { gemVersionStr = res; });

  core.info(`Current RubyGems is "${gemVersionStr}"`)

  if (parseFloat(rubyVersion) < 2.7) {

    if (parseFloat(gemVersionStr) < 3.0) {
      core.info(`Ruby < 2.7, upgrading RubyGems from ${gemVersionStr}`)

      await exec.exec('gem', ['update', '--system', '3.0.6', '--force']).then(res => { exitCode = res });
      if (exitCode != 0) {
        gemInstall('rubygems-update', '<3')
        await exec.exec('update_rubygems')
      };
      
    }
    else {
      core.info(`Ruby < 2.7, but RubyGems already at ${gemVersionStr}`)
    }
  } 

  else {
    core.info(`Ruby >= 2.7, keeping RubyGems at ${gemVersionStr}`)
  }

  await execute('which gem').then(res => { core.info("which gem: " + res) });
  await execute('gem --version').then(res => { core.info("New RubyGems is: " + res) });

  core.endGroup()
}

// utility function to standardize installing ruby gems.
async function gemInstall(name, version = undefined, binPath = undefined) {
  let options = ['install', name, '--no-document']

  if (version) { options.push('-v', version) }
  if (binPath) { options.push('--bindir', binPath) }

  await exec.exec('gem', options)
}

// install Bundler 1.17.3 (or thereabouts)
// Ruby 2.6 is first major Ruby to ship with bundle, but it also ships 
// with incompatible 1.17.2 version that must be upgraded to 1.17.3
// for some test environments/suites to function correctly.
async function installBundler(rubyVersion) {
  core.startGroup(`Install bundler`)

  const rubyBinPath = `${rubyPath(rubyVersion)}/bin`

  if (!fs.existsSync(`${rubyBinPath}/bundle`)) {
    await gemInstall('bundler', '~> 1.17.3', rubyBinPath)
  }
  else {
    await execute('bundle --version').then(res => { bundleVersionStr = res; });
    if (bundleVersionStr.match(/1\.17\.2/)) { 
     core.info(`found bundle ${bundleVersionStr}.  Upgrading to 1.17.3`)
     await gemInstall('bundler', '~> 1.17.3', rubyBinPath) 
    }
  }

  core.endGroup()
}

function rubyCachePaths(rubyVersion) {
  return [ `${process.env.HOME}/.rubies/ruby-${rubyVersion}` ]
}

function rubyCacheKey(rubyVersion) {
  return `v8-ruby-cache-${rubyVersion}`
}

// will attempt to restore the previously built Ruby environment if one exists.
async function restoreRubyFromCache(rubyVersion) {
  core.startGroup(`Restore Ruby from Cache`)
 
  const key = rubyCacheKey(rubyVersion)
  await cache.restoreCache(rubyCachePaths(rubyVersion), key, [key])
  
  core.endGroup()
}

// Causes current Ruby environment to be archived and cached.
async function saveRubyToCache(rubyVersion) {
  core.startGroup(`Save Ruby to Cache`)

  const key = rubyCacheKey(rubyVersion)
  await cache.saveCache(rubyCachePaths(rubyVersion), key)
  
  core.endGroup()
}

// Ensures working, properly configured environment for running test suites.
async function postBuildSetup(rubyVersion) {
  await downgradeSystemPackages(rubyVersion)
  await setupRubyEnvironmentAfterBuild(rubyVersion)
  await configureBundleOptions(rubyVersion)
  await showVersions()
}

// Premable steps necessary for building/running the correct Ruby
async function setupEnvironment(rubyVersion, dependencyList) { 
  const systemDependencyList = "libcurl4-nss-dev build-essential libsasl2-dev libxslt1-dev libxml2-dev"

  await installDependencies('system', systemDependencyList)
  await installDependencies('workflow', dependencyList)
  await setupRubyEnvironment(rubyVersion)
  await addRubyToPath(rubyVersion)
}

async function setupRuby(rubyVersion){
  // skip build process and just setup environment if successfully restored
  if (isRubyBuilt(rubyVersion)) {
    core.info("Ruby already built.  Skipping the build process!")
  }

  // otherwise, build Ruby, cache it, then setup environment
  else {
    await installRubyBuild(rubyVersion)
    await installBuildDependencies()
    await buildRuby(rubyVersion)
    await upgradeRubyGems(rubyVersion)
    await installBundler(rubyVersion)

    await saveRubyToCache(rubyVersion)
  }

  await postBuildSetup(rubyVersion)
}

// fingerprints the given filename, returning hex string representation
function fileHash(filename) {
  let sum = crypto.createHash('md5')
  sum.update(fs.readFileSync(filename))
  return sum.digest('hex')
}

function bundleCacheKey(rubyVersion) {
  const keyHash = fileHash(`${process.env.GITHUB_WORKSPACE}/newrelic_rpm.gemspec`)
  return `v2-bundle-cache-${rubyVersion}-${keyHash}`
}

function gemspecFilePath(rubyVersion) {
  return `${rubyPath(rubyVersion)}/.bundle-cache`
}

function bundleCachePaths(rubyVersion) {
  return [ gemspecFilePath(rubyVersion) ]
}

// will attempt to restore the previously built Ruby environment if one exists.
async function restoreBundleFromCache(rubyVersion) {
  core.startGroup(`Restore Bundle from Cache`)
 
  const key = bundleCacheKey(rubyVersion)
  core.info(`restore using ${key}`)
  await cache.restoreCache(bundleCachePaths(rubyVersion), key, [key])
  
  core.endGroup()
}

// Causes current Ruby environment to be archived and cached.
async function saveBundleToCache(rubyVersion) {
  core.startGroup(`Save Bundle to Cache`)

  const key = bundleCacheKey(rubyVersion)
  await cache.saveCache(bundleCachePaths(rubyVersion), key)
  
  core.endGroup()
}

async function setupTestEnvironment(rubyVersion) {
  core.startGroup('Setup Test Environment')
  
  const filePath = gemspecFilePath(rubyVersion)
  const workspacePath = process.env.GITHUB_WORKSPACE

  await restoreBundleFromCache(rubyVersion)

  // restore the Gemfile.lock to working folder if cache-hit
  if (fs.existsSync(`${filePath}/Gemfile.lock`)) {
    await io.cp(`${filePath}/Gemfile.lock`, `${workspacePath}/Gemfile.lock`)
    await exec.exec('bundle', ['install'])
  }

  // otherwise, bundle install and cache it
  else {
    await exec.exec('bundle', ['install'])
    await io.cp(`${workspacePath}/Gemfile.lock`, `${filePath}/Gemfile.lock`)
    try {
      await saveBundleToCache(rubyVersion)
    }
    catch (error) {
      console.log('Failed to save cache' + error.toString())
    }
  }

  core.endGroup()
}

// Detects if we're expected to build Ruby vs. running the test suite
// This conditional controls whether we go through pain of setting up the 
// environment when Ruby was previously built and cached.
function isBuildJob() { 
  return process.env.GITHUB_JOB.match(/build/)
}

// Returns true if Ruby was restored from cache
function isRubyBuilt(rubyVersion) {
  const rubyBinPath = `${rubyPath(rubyVersion)}/bin`

  return fs.existsSync(`${rubyBinPath}/ruby`)
}

// Will set up the Ruby environment so the desired Ruby binaries are used in the unit tests
// If Ruby hasn't been built and cached, yet, we also compile the Ruby binaries.
async function main() {
  const dependencyList = core.getInput('dependencies')
  const rubyVersion = core.getInput('ruby-version')

  try {
    // restores from cache if this ruby version was previously built and cached
    await restoreRubyFromCache(rubyVersion)

    // skip setting up environment when we're only building and Ruby's already built!
    if (isRubyBuilt(rubyVersion) && isBuildJob()) { return }

    await setupEnvironment(rubyVersion, dependencyList)
    await setupRuby(rubyVersion)
    await setupTestEnvironment(rubyVersion)
  } 
  catch (error) {
    core.setFailed(`Action failed with error ${error}`)
  }

}

main()
