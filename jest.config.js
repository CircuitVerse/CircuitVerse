module.exports = {
    testEnvironment: 'jsdom',

    // To Ensure the environment is ready before running jest.setup.js
    setupFilesAfterEnv: ['./jest.setup.js'],

    // Only match test files in simulator/spec/ outside of cv-frontend-vue
    testMatch: ['**/simulator/spec/**/*.spec.js'],

    // Explicitly ignore the cv-frontend-vue folder so Jest doesn’t pick up
    // ES module or Vitest tests from that sub-project
    testPathIgnorePatterns: ['<rootDir>/cv-frontend-vue/'],

    maxWorkers: '50%',
    verbose: true,

    moduleNameMapper: {
        '\\.(css|less|sass|scss)$': 'identity-obj-proxy',
        'typeface-nunito': 'identity-obj-proxy',
    },
};
