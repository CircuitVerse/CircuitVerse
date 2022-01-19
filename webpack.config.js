const path = require('path');
const webpack = require('webpack');
// Extracts CSS into .css file
const MiniCssExtractPlugin = require('mini-css-extract-plugin');
// Removes exported JavaScript files from CSS-only entries
// in this example, entry.custom will create a corresponding empty custom.js file
const FixStyleOnlyEntriesPlugin = require('webpack-fix-style-only-entries');

module.exports = {
    mode: 'production',
    devtool: 'source-map',
    entry: {
        application: './app/javascript/application.js',
        simulator: './app/javascript/simulator.js',
    },
    output: {
        filename: '[name].js',
        sourceMapFilename: '[name].js.map',
        path: path.resolve(__dirname, 'app/assets/builds'),
    },
    plugins: [
        new webpack.optimize.LimitChunkCountPlugin({
            maxChunks: 1,
        }),
        new FixStyleOnlyEntriesPlugin(),
        new MiniCssExtractPlugin(),
    ],
    module: {
        rules: [
            {
                test: /\.(js)$/,
                exclude: /node_modules/,
                use: ['babel-loader'],
            },
            {
                test: /\.s[ac]ss$/i,
                use: [MiniCssExtractPlugin.loader, 'css-loader', 'sass-loader'],
            },
            {
                test: /\.css$/i,
                use: [MiniCssExtractPlugin.loader, 'css-loader'],
            },

            {
                test: /\.(png|jpe?g|gif|eot|woff2|woff|ttf|svg)$/i,
                use: 'file-loader',
            },
        ],
    },
    resolve: {
    // Add additional file types
        extensions: ['.js', '.jsx', '.scss', '.css'],
    },
};
