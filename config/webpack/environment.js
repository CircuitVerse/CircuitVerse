const { environment } = require('@rails/webpacker');
const webpack = require('../../node_modules/webpack');

environment.loaders.append('expose', {
    test: require.resolve('jquery'),
    use: [{
        loader: 'expose-loader',
        options: '$'
    }, {
        loader: 'expose-loader',
        options: 'jQuery',
    }]
})

environment.plugins.append('Provide', new webpack.ProvidePlugin({
    $: 'jquery',
    jQuery: 'jquery',
    "window.jQuery": "jquery",
    "window.$": "jquery",
}));

module.exports = environment;
