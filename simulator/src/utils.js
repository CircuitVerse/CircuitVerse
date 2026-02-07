import { circuitProperty } from './circuit';
import { showMessage } from './circuit';

//definitions
export function stripTags(str) {
    if ((str === null) || (str === '')) return false;
    else str = str.toString();
    return str.replace(/<[^>]*>/g, '');
}

export function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, "&amp;")
        .replace(/</g, "&lt;")
        .replace(/>/g, "&gt;")
        .replace(/"/g, "&quot;")
        .replace(/'/g, "&#039;");
}

export function toHex(dec) {
    return (dec + Math.pow(16, 6)).toString(16).substr(-6);
}

export function bitConverter(str, baseFrom, baseTo) {
    const HEX = "0123456789ABCDEF";
    const BIN = "01";
    const DEC = "0123456789";
    const bases = {
        "Binary": BIN,
        "Decimal": DEC,
        "Hexdecimal": HEX,
    };
    if (baseFrom === baseTo) return str;
    const baseFromString = bases[baseFrom];
    const baseToString = bases[baseTo];
    // check if valid str
    for (let i = 0; i < str.length; i += 1) {
        if (!baseFromString.includes(str[i])) return "NaN";
    }

    // Convert to decimal
    let dec = 0;
    for (let i = 0; i < str.length; i += 1) {
        const val = baseFromString.indexOf(str[i]);
        dec += val * Math.pow(baseFromString.length, str.length - i - 1);
    }

    // Convert to baseTo
    let res = "";
    while (dec > 0) {
        const val = dec % baseToString.length;
        res = baseToString[val] + res;
        dec = Math.floor(dec / baseToString.length);
    }
    return res;
}

export function findDimensions(img) {
    return new Promise(function (resolve, reject) {
        if (img.complete) resolve({
            width: img.width,
            height: img.height
        })
        else {
            img.onload = function () {
                resolve({
                    width: img.width,
                    height: img.height
                })
            }
        }
    })
}

// 2.22... => 2.22 (two decimal places)
export function roundToTwo(num) {
    return +(Math.round(num + "e+2") + "e-2");
}

export function generateVerilog(name, data) {
    var inputs = [];
    var outputs = [];
    var wires = [];
    var modules = [];
    var gates = [];

    // Extracting inputs, outputs, wires, modules, and gates from the JSON data
    // Assuming data is your JSON object like scope.allNodes logic

    // Dummy logic for extracting, replace with your actual logic
    // ...

    var res = "module " + name;
    if (inputs.length > 0 || outputs.length > 0) {
        res += "(";
        if (inputs.length > 0) {
            res += "input " + inputs.join(", ");
        }
        if (outputs.length > 0) {
            if (inputs.length > 0) res += ", ";
            res += "output " + outputs.join(", ");
        }
        res += ");\n";
    }
    else {
        res += ";\n";
    }

    if (wires.length > 0) {
        res += "  wire " + wires.join(", ") + ";\n";
    }

    // Module instantiations
    // ...

    // Gate instantiations
    // ...

    res += "endmodule\n";
    return res;
}

// Helper function to generate Verilog for a component
export function processVerilogGate(gate, inputs, outputs, invert = false) {
    var res = "  assign ";
    if (outputs.length === 1)
        res += outputs[0].verilogLabel;
    else
        res += `{${outputs.map(x => x.verilogLabel).join(", ")}}`;

    res += " = ";

    var inputParams = inputs.map(x => x.verilogLabel).join(` ${gate} `);
    if (invert) {
        res += `~(${inputParams});`;
    }
    else {
        res += inputParams + ';';
    }
    return res;
}

export function uniq(a) {
    var seen = {};
    return a.filter(function (item) {
        return seen.hasOwnProperty(item) ? false : (seen[item] = true);
    });
}

export function showMessage2(msg) {
    // Check if the message is "Error: Infinity loop detected"
    // If it is, then changing the color to red
    var alert;
    if (msg == "Error: Infinity loop detected") {
        alert = `<div class="alert alert-danger alert-dismissible fade show" role="alert">
        ${msg}
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        </div>`
    } else {
        alert = `<div class="alert alert-warning alert-dismissible fade show" role="alert">
        ${msg}
        <button type="button" class="close" data-dismiss="alert" aria-label="Close">
            <span aria-hidden="true">&times;</span>
        </button>
        </div>`
    }

    $("#message").append(alert);
    $(".alert").alert();
    window.setTimeout(function () {
        $(".alert").alert('close');
    }, 3000);
}

// Function to copy text to clipboard
export const copyToClipboard = (text) => {
    if (!text) return false;

    // Create a temporary textarea element to hold the text
    const textarea = document.createElement('textarea');
    textarea.value = text;
    textarea.setAttribute('readonly', '');
    textarea.style.position = 'absolute';
    textarea.style.left = '-9999px';
    document.body.appendChild(textarea);

    // Provide improved UX on iOS devices.
    const selected = document.getSelection().rangeCount > 0
        ? document.getSelection().getRangeAt(0)
        : false;

    textarea.select();

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
    return str.slice(0, num) + '...';
}

export function showError(message) {
    showMessage(message);
}
