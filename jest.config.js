module.exports = {
    setupFiles: ['./jest.setup.js'],
    testMatch: ['**/spec/**/*.spec.js'],
    verbose: true,
    moduleNameMapper: {
        '\\.(css|less|sass|scss)$': 'identity-obj-proxy',
        'typeface-nunito': 'identity-obj-proxy',
    },
};
