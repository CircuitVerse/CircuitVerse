const { environment } = require('@rails/webpacker');
const erb = require('./loaders/erb')
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

environment.loaders.prepend('erb', erb)
module.exports = environment;
