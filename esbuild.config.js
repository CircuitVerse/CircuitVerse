const path = require('path');
const esbuild = require('esbuild');
const rails = require('esbuild-rails');
const sassPlugin = require('esbuild-plugin-sass');

const watch = process.argv.includes('--watch');

function logBuildEvent(eventType, message = '') {
    const action = eventType === 'start' ? 'starting' : 'finished';
    // eslint-disable-next-line no-console
    console.log(`Build ${action}: ${message} ${new Date(Date.now()).toLocaleString()}`);
}

const watchPlugin = {
    name: 'watchPlugin',
    setup(build) {
        build.onStart(() => {
            logBuildEvent('start');
        });
        build.onEnd((result) => {
            if (result.errors.length > 0) {
                logBuildEvent('end', 'with errors');
            } else {
                logBuildEvent('end', 'Successfully');
            }
        });
    },
};

async function run() {
    const context = await esbuild.context({
        entryPoints: ['application.js', 'testbench.js', 'simulator.js', 'vendor.js'],
        bundle: true,
        outdir: path.join(process.cwd(), 'app/assets/builds'),
        absWorkingDir: path.join(process.cwd(), 'app/javascript'),
        // Match previous production behavior (Sprockets + terser minified JS).
        minify: process.env.NODE_ENV === 'production',
        sourcemap: 'inline',
        loader: {
            '.png': 'file',
            '.svg': 'file',
            '.ttf': 'file',
            '.woff': 'file',
            '.woff2': 'file',
            '.eot': 'file',
        },
        plugins: [rails(), sassPlugin(), watchPlugin],
    });

    if (watch) {
        await context.watch();
    } else {
        await context.rebuild();
        context.dispose();
    }
}

run().catch(() => {
    process.exit(1);
});
