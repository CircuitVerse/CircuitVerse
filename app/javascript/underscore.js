// Sets window._ before libraries that read it at evaluation time
// (e.g. third_party/commontator). Must be imported before them.
//
// NOTE: imports the UMD build explicitly: underscore's ESM build ("module")
// omits _.noConflict(), which commontator's mentions.js calls at load time.
import _ from 'underscore/underscore-umd.js';

window._ = _;
