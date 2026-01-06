const path = require('path');
const fs = require('fs');
const esbuild = require('esbuild');
const rails = require('esbuild-rails');
const sassPlugin = require('esbuild-plugin-sass');
const { execSync } = require('child_process');

const watch = process.argv.includes('--watch');
const rebuildVueSimulator = process.env.REBUILD_VUE === 'true';

const VUE_DIR = path.join(process.cwd(), 'cv-frontend-vue');
const JS_DIR = path.join(process.cwd(), 'app/javascript');
const BUILD_DIR = path.join(process.cwd(), 'app/assets/builds');

function logBuildEvent(type, message = '') {
    const status = type === 'start' ? 'starting' : 'finished';
    // eslint-disable-next-line no-console
    console.log(
        `Build ${status} ${message} — ${new Date().toLocaleString()}`,
    );
}

function logErrorAndExit(error) {
    // eslint-disable-next-line no-console
    console.error(
        `\nBuild failed at ${new Date().toLocaleString()}\n\n`,
        error,
    );
    process.exit(1);
}

/* -------------------------------------------------
 * Vue Simulator Build
 * ------------------------------------------------- */
function validateVuePackageFiles() {
    const pkg = path.join(VUE_DIR, 'package.json');
    const lock = path.join(VUE_DIR, 'package-lock.json');

    if (!fs.existsSync(pkg) || !fs.existsSync(lock)) {
        throw new Error(
            'package.json or package-lock.json not found in cv-frontend-vue directory',
        );
    }
}

function buildVueSimulator() {
    if (process.env.NODE_ENV === 'production') return;

    logBuildEvent('start', '(Vue simulator)');
    validateVuePackageFiles();

    execSync('npm install', {
        cwd: VUE_DIR,
        stdio: 'inherit',
    });

    execSync(
        rebuildVueSimulator ? 'npm run build -- --watch' : 'npm run build',
        {
            cwd: VUE_DIR,
            stdio: 'inherit',
        },
    );

    logBuildEvent('end', '(Vue simulator)');
}

/* -------------------------------------------------
 * esbuild Plugins
 * ------------------------------------------------- */
const lifecycleLoggerPlugin = {
    name: 'lifecycleLogger',
    setup(build) {
        build.onStart(() => logBuildEvent('start', '(esbuild)'));
        build.onEnd((result) => {
            if (result.errors.length > 0) {
                logBuildEvent('end', '(esbuild with errors)');
            } else {
                logBuildEvent('end', '(esbuild successful)');
            }
        });
    },
};

/* -------------------------------------------------
 * esbuild Runner
 * ------------------------------------------------- */
async function runEsbuild() {
    const context = await esbuild.context({
        entryPoints: ['application.js', 'testbench.js'],
        absWorkingDir: JS_DIR,
        bundle: true,
        outdir: BUILD_DIR,
        sourcemap: 'inline',
        loader: {
            '.png': 'file',
            '.svg': 'file',
            '.ttf': 'file',
            '.woff': 'file',
            '.woff2': 'file',
            '.eot': 'file',
        },
        plugins: [
            rails(),
            sassPlugin(),
            lifecycleLoggerPlugin,
        ],
    });

    if (watch) {
        await context.watch();
    } else {
        await context.rebuild();
        await context.dispose();
    }
}

/* -------------------------------------------------
 * Main Execution (Sequential & Safe)
 * ------------------------------------------------- */
(async function main() {
    try {
        buildVueSimulator();
        await runEsbuild();
    } catch (error) {
        logErrorAndExit(error);
    }
})();
