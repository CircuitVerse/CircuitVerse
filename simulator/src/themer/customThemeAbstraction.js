/**
 * CreateAbstraction
 * @param {*} themeOptions
 * @returns an Object
 */
export const CreateAbstraction = (themeOptions) => {
    return {
        Navbar: {
            color: themeOptions['--bg-navbar'],
            description: 'navbar background',
            ref: ['--bg-navbar'],
        },
        Primary: {
            color: themeOptions['--primary'],
            description: 'modals background',
            ref: ['--primary'],
        },
        Secondary: {
            color: themeOptions['--bg-tabs'],
            description: 'tabBar background',
            ref: ['--bg-tabs'],
        },
        Canvas: {
            color: themeOptions['--canvas-fill'],
            description: 'canvas background',
            ref: ['--canvas-fill'],
        },
        Stroke: {
            color: themeOptions['--canvas-stroke'],
            description: 'canvas grid color',
            ref: ['--canvas-stroke'],
        },
        Text: {
            color: themeOptions['--text-lite'],
            description: 'text color',
            ref: ['--text-lite', '--text-panel', '--text-dark'],
        },
        Borders: {
            color: themeOptions['--br-secondary'],
            description: 'borders color',
            ref: ['--br-secondary'],
        },
    };
};
