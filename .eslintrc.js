module.exports = {
    env: {
        node: true,
        browser: true,
        commonjs: true,
        es6: true,
        jquery: true,
    },
    extends: ["eslint:recommended", "plugin:vue/vue3-recommended", "prettier"],
    rules: {
        // override/add rules settings here, such as:
        // 'vue/no-unused-vars': 'error'
    },
};
