// Application bundle (esbuild). Replaces app/assets/javascripts/application_sprockets.js.
// Loaded synchronously in the layout so inline <script> blocks can use these globals.
//
// NOTE: './jquery' must stay the first import. ES modules evaluate imports
// before the importing module's body, so globals it sets (window.$, ...)
// have to be assigned in a dependency module, not in this file's body,
// otherwise libraries evaluated earlier would see undefined.
import './jquery';
import Rails from '@rails/ujs';

Rails.start();

import * as bootstrap from 'bootstrap';

window.bootstrap = bootstrap;

import autoComplete from '@tarekraafat/autocomplete.js';

window.autoComplete = autoComplete;

import DOMPurify from 'dompurify';

window.DOMPurify = DOMPurify;

import 'trumbowyg';
import 'trumbowyg/dist/plugins/colors/trumbowyg.colors.min.js';
import 'trumbowyg/dist/plugins/pasteembed/trumbowyg.pasteembed.min.js';
import 'trumbowyg/dist/plugins/upload/trumbowyg.upload.min.js';
import 'trumbowyg/dist/plugins/resizimg/trumbowyg.resizimg.min.js';
import 'trumbowyg/dist/plugins/fontfamily/trumbowyg.fontfamily.min.js';

// Exposed globally so inline <script> blocks in .erb views (which aren't
// part of the esbuild module graph) can initialize email-tag inputs
// without duplicating this logic per view.
import initEmailTagSelect from './utils/emailTagSelect';

window.initEmailTagSelect = initEmailTagSelect;

import 'jquery-resizable-dom/dist/jquery-resizable.min.js';

import './legacy/scroll';
import './legacy/time';
import './legacy/restrictElements';

import './controllers';
