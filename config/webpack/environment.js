const { environment } = require("@rails/webpacker");

environment.loaders.append("expose", {
    test: require.resolve("jquery"),
    use: [
        {
            loader: "expose-loader",
            options: "$",
        },
        {
            loader: "expose-loader",
            options: "jQuery",
        },
    ],
});
module.exports = environment;
