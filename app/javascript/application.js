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

// Select2's npm build exports an uninvoked (root, jQuery) factory instead of
// self-registering (unlike the old select2-rails asset), so invoke it
// explicitly with our jQuery instance.
import jquery from 'jquery';
import select2 from 'select2';

select2(window, jquery);

import 'jquery-resizable-dom/dist/jquery-resizable.min.js';

import './legacy/scroll';
import './legacy/time';
import './legacy/restrictElements';

import './controllers';
