/**
 * This plugin has been modified to support metakeys
 */

/*
 * Library to normalize key codes across browsers.  This works with keydown
 * events; keypress events are not fired for all keys, and the codes are
 * different for them.  It returns an object with the following fields:
 * { int code, bool shift, bool alt, bool ctrl }.  The normalized keycodes
 * obey the following rules:
 *
 * For alphabetic characters, the ASCII code of the uppercase version
 *
 * For codes that are identical across all browsers (this includes all
 * modifiers, esc, delete, arrows, etc.), the common keycode
 *
 * For numeric keypad keys, the value returned by numkey().
 * (Usually 96 + the number)
 *
 * For symbols, the ASCII code of the character that appears when shift
 * is not held down, EXCEPT for '" => 222 (conflicts with right-arrow/pagedown),
 * .> => 190 (conflicts with Delete) and `~ => 126 (conflicts with Num0).
 *
 * Basic usage:
 * document.onkeydown = function(e) {
 *    do_something_with(KeyCode.translateEvent(e)
 * };
 *
 * The naming conventions for functions use 'code' to represent an integer
 * keycode, 'key' to represent a key description (specified above), and 'e'
 * to represent an event object.
 *
 * There's also functionality to track and detect which keys are currently
 * being held down: install 'key_up' and 'key_down' on their respective event
 * handlers, and then check with 'is_down'.
 *
 * @fileoverview
 * @author Jonathan Tang
 * @version 0.9
 * @license BSD
 */

/*
Copyright (c) 2008 Jonathan Tang
All rights reserved.

Redistribution and use in source and binary forms, with or without
modification, are permitted provided that the following conditions
are met:
1. Redistributions of source code must retain the above copyright
   notice, this list of conditions and the following disclaimer.
2. Redistributions in binary form must reproduce the above copyright
   notice, this list of conditions and the following disclaimer in the
   documentation and/or other materials provided with the distribution.
3. The name of the author may not be used to endorse or promote products
   derived from this software without specific prior written permission.

THIS SOFTWARE IS PROVIDED BY THE AUTHOR ``AS IS'' AND ANY EXPRESS OR
IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE IMPLIED WARRANTIES
OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE DISCLAIMED.
IN NO EVENT SHALL THE AUTHOR BE LIABLE FOR ANY DIRECT, INDIRECT,
INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL DAMAGES (INCLUDING, BUT
NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR SERVICES; LOSS OF USE,
DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER CAUSED AND ON ANY
THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY, OR TORT
(INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE OF
THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
 */

var modifiers = ['ctrl', 'alt', 'shift', 'meta'], KEY_MAP = {},
    shifted_symbols = {
      58: 59,   // : -> ;
      43: 61,   // = -> +
      60: 44,   // < -> ,
      95: 45,   // _ -> -
      62: 46,   // > -> .
      63: 47,   // ? -> /
      96: 192,  // ` -> ~
      124: 92,  // | -> \
      39: 222,  // ' -> 222
      34: 222,  // " -> 222
      33: 49,   // ! -> 1
      64: 50,   // @ -> 2
      35: 51,   // # -> 3
      36: 52,   // $ -> 4
      37: 53,   // % -> 5
      94: 54,   // ^ -> 6
      38: 55,   // & -> 7
      42: 56,   // * -> 8
      40: 57,   // ( -> 9
      41: 58,   // ) -> 0
      123: 91,  // { -> [
      125: 93,  // } -> ]
    };

function isLower(ascii) {
  return ascii >= 97 && ascii <= 122;
}
function capitalize(str) {
  return str.substr(0, 1).toUpperCase() + str.substr(1).toLowerCase();
}

var is_gecko = navigator.userAgent.indexOf('Gecko') != -1,
    is_ie = navigator.userAgent.indexOf('MSIE') != -1,
    is_windows = navigator.platform.indexOf('Win') != -1,
    is_opera = window.opera && window.opera.version() < 9.5,
    is_konqueror = navigator.vendor && navigator.vendor.indexOf('KDE') != -1,
    is_icab = navigator.vendor && navigator.vendor.indexOf('iCab') != -1;

var GECKO_IE_KEYMAP = {
  186: 59,   // ;: in IE
  187: 61,   // =+ in IE
  188: 44,   // ,<
  109: 95,   // -_ in Mozilla
  107: 61,   // =+ in Mozilla
  189: 95,   // -_ in IE
  190: 62,   // .>
  191: 47,   // /?
  192: 126,  // `~
  219: 91,   // {[
  220: 92,   // \|
  221: 93,   // }]
};

var OPERA_KEYMAP = {};

// Browser detection taken from quirksmode.org
if (is_opera && is_windows) {
  KEY_MAP = OPERA_KEYMAP;
} else if (is_opera || is_konqueror || is_icab) {
  var unshift = [
    33,
    64,
    35,
    36,
    37,
    94,
    38,
    42,
    40,
    41,
    58,
    43,
    60,
    95,
    62,
    63,
    124,
    34,
  ];
  KEY_MAP = OPERA_KEYMAP;
  for (var i = 0; i < unshift.length; ++i) {
    KEY_MAP[unshift[i]] = shifted_symbols[unshift[i]];
  }
} else {
  // IE and Gecko are close enough that we can use the same map for both,
  // and the rest of the world (eg. Opera 9.50) seems to be standardizing
  // on them
  KEY_MAP = GECKO_IE_KEYMAP;
}

if (is_konqueror) {
  KEY_MAP[0] = 45;
  KEY_MAP[127] = 46;
  KEY_MAP[45] = 95;
}

var key_names = {
  32: 'SPACE',
  13: 'ENTER',
  9: 'TAB',
  8: 'BACKSPACE',
  16: 'SHIFT',
  17: 'CTRL',
  18: 'ALT',
  20: 'CAPS_LOCK',
  144: 'NUM_LOCK',
  145: 'SCROLL_LOCK',
  37: 'LEFT',
  38: 'UP',
  39: 'RIGHT',
  40: 'DOWN',
  33: 'PAGE_UP',
  34: 'PAGE_DOWN',
  36: 'HOME',
  35: 'END',
  45: 'INSERT',
  46: 'DELETE',
  27: 'ESCAPE',
  19: 'PAUSE',
  222: '\'',
  91: 'META'
};
function fn_name(code) {
  if (code >= 112 && code <= 123) return 'F' + (code - 111);
  return false;
}
function num_name(code) {
  if (code >= 96 && code < 106) return 'Num' + (code - 96);
  switch (code) {
    case 106:
      return 'Num*';
    case 111:
      return 'Num/';
    case 110:
      return 'Num.';
    default:
      return false;
  }
}

var current_keys = {
  codes: {},
  ctrl: false,
  alt: false,
  shift: false,
  meta: false,
};

function update_current_modifiers(key) {
  current_keys.ctrl = key.ctrl;
  current_keys.alt = key.alt;
  current_keys.shift = key.shift;
  current_keys.meta = key.meta;
}

function same_modifiers(key1, key2) {
  return (
      key1.ctrl === key2.ctrl && key1.alt === key2.alt &&
      key1.shift === key2.shift && key1.meta === key2.meta);
}

if (typeof window.KeyCode != 'undefined') {
  var _KeyCode = window.KeyCode;
}

export const KeyCode = {
  no_conflict: function() {
    window.KeyCode = _KeyCode;
    return KeyCode;
  },

  /** Generates a function key code from a number between 1 and 12 */
  fkey: function(num) {
    return 111 + num;
  },

  /**
   * Generates a numeric keypad code from a number between 0 and 9.
   * Also works for (some) arithmetic operators.  The mappings are:
   *
   * *: 106, /: 111, .: 110
   *
   * + and - are not supported because the keycodes generated by Mozilla
   * conflict with the non-keypad codes.  The same applies to all the
   * arithmetic keypad keys on Konqueror and early Opera.
   */
  numkey: function(num) {
    switch (num) {
      case '*':
        return 106;
      case '/':
        return 111;
      case '.':
        return 110;
      default:
        return 96 + num;
    }
  },

  /**
   * Generates a key code from the ASCII code of (the first character of) a
   * string.
   */
  key: function(str) {
    var c = str.charCodeAt(0);
    if (isLower(c)) return c - 32;
    return shifted_symbols[c] || c;
  },

  /** Checks if two key objects are equal. */
  key_equals: function(key1, key2) {
    return key1.code == key2.code && same_modifiers(key1, key2);
  },

  /** Translates a keycode to its normalized value. */
  translate_key_code: function(code) {
    return KEY_MAP[code] || code;
  },

  /**
   * Translates a keyDown event to a normalized key event object.  The
   * object has the following fields:
   * { int code; boolean shift, boolean alt, boolean ctrl }
   */
  translate_event: function(e) {
    e = e || window.event;
    var code = e.which || e.keyCode;
    return {
      code: KeyCode.translate_key_code(code),
      shift: e.shiftKey,
      alt: e.altKey,
      ctrl: e.ctrlKey,
      meta: e.metaKey
    };
  },

  /**
   * Keydown event listener to update internal state of which keys are
   * currently pressed.
   */

  key_down: function(e) {
    var key = KeyCode.translate_event(e);
    current_keys.codes[key.code] = key.code;
    update_current_modifiers(key);
  },

  /**
   * Keyup event listener to update internal state.
   */
  key_up: function(e) {
    var key = KeyCode.translate_event(e);
    delete current_keys.codes[key.code];
    update_current_modifiers(key);
  },

  /**
   * Returns true if the key spec (as returned by translate_event) is
   * currently held down.
   */
  is_down: function(key) {
    var code = key.code;
    if (code == KeyCode.CTRL) return current_keys.ctrl;
    if (code == KeyCode.ALT) return current_keys.alt;
    if (code == KeyCode.SHIFT) return current_keys.shift;

    return (
        current_keys.codes[code] !== undefined &&
        same_modifiers(key, current_keys));
  },

  /**
   * Returns a string representation of a key event suitable for the
   * shortcut.js or JQuery HotKeys plugins.  Also makes a decent UI display.
   */
  hot_key: function(key) {
    var pieces = [];
    for (var i = 0; i < modifiers.length; ++i) {
      var modifier = modifiers[i];
      if (key[modifier] && modifier.toUpperCase() != key_names[key.code]) {
        pieces.push(capitalize(modifier));
      }
    }

    var c = key.code;
    var key_name =
        key_names[c] || fn_name(c) || num_name(c) || String.fromCharCode(c);
    pieces.push(capitalize(key_name));
    return pieces.join('+');
  },
};

// Add key constants
for (var code in key_names) {
  KeyCode[key_names[code]] = code;
}


// var fields = ['charCode', 'keyCode', 'which', 'type', 'timeStamp',
//               'altKey', 'ctrlKey', 'shiftKey', 'metaKey'];
// var types = ['keydown', 'keypress', 'keyup'];

// function show_event(type) {
//     return function(e) {
//         var lines = [];
//         for(var i = 0; i < fields.length; ++i) {
//             lines.push('<b>' + fields[i] + '</b>: ' + e[fields[i]] + '<br />');
//         }
//         document.getElementByI(type).innerHTML = lines.join('\n');
//         return false;
//     }
// };

// function show_is_key_down(id, code, ctrl, alt, shift) {
//     document.getElementById(id + '_down').innerHTML = KeyCode.is_down({
//         code: code,
//         ctrl: ctrl,
//         alt: alt,
//         shift: shift
//     });
// };

// function update_key_downs() {
//     show_is_key_down('x', KeyCode.key('x'), false, false, false);
//     show_is_key_down('shift_x', KeyCode.key('x'), false, false, true);
//     show_is_key_down('shift_c', KeyCode.key('c'), false, false, true);
//     show_is_key_down('ctrl_a', KeyCode.key('a'), true, false, false);
// };
