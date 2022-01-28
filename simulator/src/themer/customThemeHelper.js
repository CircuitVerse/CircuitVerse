import themeOptions from './themes';

export default {
    navbar : {
        color : themeOptions['Custom Theme']['--bg-navbar'],
        linked : ['--bg-navbar'],
    },
    primary : {
        color : themeOptions['Custom Theme']['--primary'],
        linked : ['--primary', '--br-circuit'],
    },
    secondary : {
        color : themeOptions['Custom Theme']['--context-text'],
        linked : ['--context-text', '--br-circuit-cur'],
    },
    canvasBackground : {
        color : themeOptions['Custom Theme']['--canvas-fill'],
        linked : ['--canvas-fill'],
    },
    canvasStroke : {
        color : themeOptions['Custom Theme']['--canvas-stroke'],
        linked : ['--canvas-stroke'],
    },
    text : {
        color : themeOptions['Custom Theme']['--text'],
        linked : ['--text'],
    }
}
