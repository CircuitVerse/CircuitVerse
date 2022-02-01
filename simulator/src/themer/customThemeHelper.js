import themeOptions from './themes';

export default {
    Navbar: {
        color: themeOptions['Custom Theme']['--bg-navbar'],
        description: 'navbar background',
        ref: ['--bg-navbar'],
    },
    Primary: {
        color: themeOptions['Custom Theme']['--primary'],
        description: 'modals background',
        ref: ['--primary'],
    },
    Secondary: {
        color: themeOptions['Custom Theme']['--bg-tabs'],
        description: 'tabBar background',
        ref: ['--bg-tabs'],
    },
    Canvas: {
        color: themeOptions['Custom Theme']['--canvas-fill'],
        description: 'canvas background',
        ref: ['--canvas-fill'],
    },
    Stroke: {
        color: themeOptions['Custom Theme']['--canvas-stroke'],
        description: 'canvas grid color',
        ref: ['--canvas-stroke'],
    },
    Text: {
        color: themeOptions['Custom Theme']['--text-lite'],
        description: 'text color',
        ref: ['--text-lite', '--text-panel', '--text-dark'],
    },
    Borders: {
        color: themeOptions['Custom Theme']['--br-secondary'],
        description: 'borders color',
        ref: ['--br-secondary'],
    }
};
