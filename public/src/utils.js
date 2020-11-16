import simulationArea from './simulationArea';
import {
    scheduleUpdate, play, updateCanvasSet, errorDetectedSet, errorDetectedGet,
} from './engine';
import { layoutModeGet } from './layoutMode';

window.globalScope = undefined;
window.lightMode = false; // To be deprecated
window.projectId = undefined;
window.id = undefined;
window.loading = false; // Flag - all assets are loaded

var prevErrorMessage; // Global variable for error messages
var prevShowMessage; // Global variable for error messages
export function generateId() {
    var id = '';
    var possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (var i = 0; i < 20; i++) { id += possible.charAt(Math.floor(Math.random() * possible.length)); }

    return id;
}

// To strip tags from input
export function stripTags(string = '') {
    return string.replace(/(<([^>]+)>)/ig, '').trim();
}


export function clockTick() {
    if (!simulationArea.clockEnabled) return;
    if (errorDetectedGet()) return;
    if (layoutModeGet()) return;
    updateCanvasSet(true);
    globalScope.clockTick();
    play();
    scheduleUpdate(0, 20);
}

/**
 * Helper function to show error
 * @param {string} error -The error to be shown
 * @category utils
 */
export function showError(error) {
    errorDetectedSet(true);
    // if error ha been shown return
    if (error === prevErrorMessage) return;
    prevErrorMessage = error;
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-danger' role='alert' id='${id}'> ${error}</div>`);
    setTimeout(() => {
        prevErrorMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 1500);
}

// Helper function to show message
export function showMessage(mes) {
    if (mes === prevShowMessage) return;
    prevShowMessage = mes;
    var id = Math.floor(Math.random() * 10000);
    $('#MessageDiv').append(`<div class='alert alert-success' role='alert' id='${id}'> ${mes}</div>`);
    setTimeout(() => {
        prevShowMessage = undefined;
        $(`#${id}`).fadeOut();
    }, 2500);
}

export function distance(x1, y1, x2, y2) {
    return Math.sqrt((x2 - x1) ** 2) + ((y2 - y1) ** 2);
}

/**
 * Helper function to return unique list
 * @param {Array} a - any array
 * @category utils
 */
export function uniq(a) {
    var seen = {};
    const tmp = a.filter((item) => (seen.hasOwnProperty(item) ? false : (seen[item] = true)));
    return tmp;
}

// Generates final verilog code for each element
// Gate = &/|/^
// Invert is true for xNor, Nor, Nand
export function gateGenerateVerilog(gate, invert = false) {
    var inputs = [];
    var outputs = [];

    for (var i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type == NODE_INPUT) {
            inputs.push(this.nodeList[i]);
        } else {
            if (this.nodeList[i].connections.length > 0)
                outputs.push(this.nodeList[i]);
            else
                outputs.push(""); // Don't create a wire
        }
    }

    var res = "assign ";
    if (outputs.length == 1)
        res += outputs[0].verilogLabel;
    else
        res += `{${outputs.map(x => x.verilogLabel).join(", ")}}`;

    res += " = ";

    var inputParams = inputs.map(x => x.verilogLabel).join(` ${gate} `);
    if(invert) {
        res += `~(${inputParams});`;
    }
    else {
        res += inputParams + ';';
    }
    return res;
}

// Helper function to download text
export function download(filename, text) {
    var pom = document.createElement('a');
    pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    pom.setAttribute('download', filename);


    if (document.createEvent) {
        var event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    } else {
        pom.click();
    }
}

// Helper function to open a new tab
export function openInNewTab(url) {
    var win = window.open(url, '_blank');
    win.focus();
}

export function copyToClipboard(text) {
    const textarea = document.createElement('textarea');
    
    // Move it off-screen.
    textarea.style.cssText = 'position: absolute; left: -99999em';

    // Set to readonly to prevent mobile devices opening a keyboard when
    // text is .select()'ed.
    textarea.setAttribute('readonly', true);

    document.body.appendChild(textarea);
      textarea.value = text;
  
      // Check if there is any content selected previously.
      const selected = document.getSelection().rangeCount > 0 ?
        document.getSelection().getRangeAt(0) : false;
  
      // iOS Safari blocks programmatic execCommand copying normally, without this hack.
      // https://stackoverflow.com/questions/34045777/copy-to-clipboard-using-javascript-in-ios
      if (navigator.userAgent.match(/ipad|ipod|iphone/i)) {
        const editable = textarea.contentEditable;
        textarea.contentEditable = true;
        const range = document.createRange();
        range.selectNodeContents(textarea);
        const sel = window.getSelection();
        sel.removeAllRanges();
        sel.addRange(range);
        textarea.setSelectionRange(0, 999999);
        textarea.contentEditable = editable;
      }
      else {
        textarea.select();
      }
  
      try {
        const result = document.execCommand('copy');
  
        // Restore previous selection.
        if (selected) {
          document.getSelection().removeAllRanges();
          document.getSelection().addRange(selected);
        }
        textarea.remove();
        return result;
      }
      catch (err) {
        console.error(err);
        textarea.remove();
        return false;
      }
};

export function truncateString(str, num) {
    // If the length of str is less than or equal to num
    // just return str--don't truncate it.
    if (str.length <= num) {
        return str;
    }
    // Return str truncated with '...' concatenated to the end of str.
    return str.slice(0, num) + "...";
}
