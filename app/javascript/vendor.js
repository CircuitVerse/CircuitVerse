// Plain-CSS vendor styles that dart-sass cannot @import (it passes .css imports
// through as-is). Bundled by esbuild into builds/vendor.css; dart-sass builds
// application.css separately, so the two never collide.
import 'trumbowyg/dist/ui/trumbowyg.min.css';
import 'tom-select/dist/css/tom-select.bootstrap5.css';
