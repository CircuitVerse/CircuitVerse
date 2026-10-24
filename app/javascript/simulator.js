// Legacy simulator bundle (esbuild). Replaces the vite entrypoints
// (jquery/bootstrap/simulator) until the simulator is replaced by cv-frontend-vue.
//
// NOTE: './jquery' must stay the first import. ES modules evaluate imports
// before the importing module's body, and simulator sources (e.g.
// simulator/src/listeners.js) call bare `$` during evaluation, so window.$
// has to be assigned in a dependency module evaluated before them.
import './jquery';

import { Tooltip } from 'bootstrap';

window.Tooltip = Tooltip;

import '../../simulator/src/app';

import './src/sass/simulator.scss';
import './src/sass/color_theme.scss';
import './src/sass/tutorials.scss';
import '../../simulator/src/css/main.stylesheet.css';
