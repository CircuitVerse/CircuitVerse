const path = require('path');
const rails = require('esbuild-rails');
const sassPlugin = require('esbuild-plugin-sass');

const watchDirectories = [
    './app/javascript/**/*.js',
    './app/views/**/*.html.erb',
    './app/assets/stylesheets/**/*',
];

require('esbuild').build({
    entryPoints: ['application.js', 'simulator.js', 'testbench.js'],
    bundle: true,
    outdir: path.join(process.cwd(), 'app/assets/builds'),
    absWorkingDir: path.join(process.cwd(), 'app/javascript'),
    sourcemap: true,
    watch: process.argv.includes('--watch'),
    incremental: process.argv.includes('--watch'),
    loader: {
        '.png': 'file', '.svg': 'file', '.ttf': 'file', '.woff': 'file', '.woff2': 'file', '.eot': 'file',
    },
    plugins: [rails(), sassPlugin()],
}).catch(() => process.exit(1));
