module.exports = {
    setupFiles: ['./jest.setup.js'],
    testMatch: ['**/simulator/spec/**/*.spec.js'],
    maxWorkers: '50%',
    verbose: true,
    moduleNameMapper: {
        '\\.(css|less|sass|scss)$': 'identity-obj-proxy',
        'typeface-nunito': 'identity-obj-proxy',
    },
};
