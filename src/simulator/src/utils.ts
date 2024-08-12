import { simulationArea } from './simulationArea'
import {
    scheduleUpdate,
    play,
    updateCanvasSet,
    errorDetectedSet,
    errorDetectedGet,
} from './engine'
import { layoutModeGet } from './layoutMode'
import plotArea from './plotArea'
import { SimulatorStore } from '#/store/SimulatorStore/SimulatorStore'
import { useActions } from '#/store/SimulatorStore/actions'

window.globalScope = undefined
window.lightMode = false // To be deprecated
window.projectId = undefined
window.id = undefined
window.loading = false // Flag - all assets are loaded

let prevErrorMessage: string | undefined // Global variable for error messages
let prevShowMessage: string | undefined // Global variable for error messages
export function generateId() {
    let id = ''
    const possible =
        'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789'

    for (let i = 0; i < 20; i++) {
        id += possible.charAt(Math.floor(Math.random() * possible.length))
    }

    return id
}

// To strip tags from input
export function stripTags(string = '') {
    return string.replace(/(<([^>]+)>)/gi, '').trim()
}

export function clockTick() {
    if (!simulationArea.clockEnabled) return
    if (errorDetectedGet()) return
    if (layoutModeGet()) return
    updateCanvasSet(true)
    globalScope.clockTick()
    plotArea.nextCycle()
    play()
    scheduleUpdate(0, 20)
}

/**
 * Helper function to show error
 */
export function showError(error: string) {
    errorDetectedSet(true)
    // if error ha been shown return
    if (error === prevErrorMessage) return
    prevErrorMessage = error

    useActions().showMessage(error, 'error')
}

// Helper function to show message
export function showMessage(mes: string) {
    if (mes === prevShowMessage) return
    prevShowMessage = mes

    useActions().showMessage(mes, 'success')
}

export function distance(x1: number, y1: number, x2: number, y2: number) {
    return Math.sqrt((x2 - x1) ** 2) + (y2 - y1) ** 2
}

/**
 * Helper function to return unique list
 * @param {Array} a - any array
 * @category utils
 */
export function uniq(a: any[]) {
    const seen: { [key: string]: boolean } = {};
    const tmp = a.filter((item) =>
        seen.hasOwnProperty(item) ? false : (seen[item] = true)
    );
    return tmp;
}

// Generates final verilog code for each element
// Gate = &/|/^
// Invert is true for xNor, Nor, Nand
export function gateGenerateVerilog(gate, invert = false) {
    let inputs = []
    let outputs = []

    for (let i = 0; i < this.nodeList.length; i++) {
        if (this.nodeList[i].type == NODE_INPUT) {
            inputs.push(this.nodeList[i])
        } else {
            if (this.nodeList[i].connections.length > 0)
                outputs.push(this.nodeList[i])
            else outputs.push('') // Don't create a wire
        }
    }

    let res = 'assign '
    if (outputs.length == 1) res += outputs[0].verilogLabel
    else res += `{${outputs.map((x) => x.verilogLabel).join(', ')}}`

    res += ' = '

    const inputParams = inputs.map((x) => x.verilogLabel).join(` ${gate} `)
    if (invert) {
        res += `~(${inputParams});`
    } else {
        res += inputParams + ';'
    }
    return res
}

// Helper function to download text
export function download(filename: string, text: string | number | boolean) {
    const pom = document.createElement('a')
    pom.setAttribute(
        'href',
        'data:text/plain;charset=utf-8,' + encodeURIComponent(text)
    )
    pom.setAttribute('download', filename)

    if (document.createEvent) {
        const event = document.createEvent('MouseEvents')
        event.initEvent('click', true, true)
        pom.dispatchEvent(event)
    } else {
        pom.click()
    }
}

// Helper function to open a new tab
export function openInNewTab(url: string | URL | undefined) {
    const win = window.open(url, '_blank')
    win?.focus()
}

export function copyToClipboard(text: string) {
    const textarea = document.createElement('textarea')

    // Move it off-screen.
    textarea.style.cssText = 'position: absolute; left: -99999em'

    // Set to readonly to prevent mobile devices opening a keyboard when
    // text is .select()'ed.
    textarea.setAttribute('readonly', 'true')

    document.body.appendChild(textarea)
    textarea.value = text

    // Check if there is any content selected previously.
    const selected =
        document.getSelection()?.rangeCount ?? 0 > 0
            ? document.getSelection()?.getRangeAt(0)
            : false

    // iOS Safari blocks programmatic execCommand copying normally, without this hack.
    // https://stackoverflow.com/questions/34045777/copy-to-clipboard-using-javascript-in-ios
    if (navigator.userAgent.match(/ipad|ipod|iphone/i)) {
        const editable = textarea.contentEditable
        textarea.contentEditable = 'true'
        const range = document.createRange()
        range.selectNodeContents(textarea)
        const sel = window.getSelection()
        sel?.removeAllRanges()
        sel?.addRange(range)
        textarea.setSelectionRange(0, 999999)
        textarea.contentEditable = editable
    } else {
        textarea.select()
    }

    try {
        const result = document.execCommand('copy')

        // Restore previous selection.
        if (selected) {
            document.getSelection()?.removeAllRanges()
            document.getSelection()?.addRange(selected)
        }
        textarea.remove()
        return result
    } catch (err) {
        console.error(err)
        textarea.remove()
        return false
    }
}

export function truncateString(str: string, num: number) {
    // If the length of str is less than or equal to num
    // just return str--don't truncate it.
    if (str.length <= num) {
        return str
    }
    // Return str truncated with '...' concatenated to the end of str.
    return str.slice(0, num) + '...'
}

export function bitConverterDialog() {
    const simulatorStore = SimulatorStore()
    simulatorStore.dialogBox.hex_bin_dec_converter_dialog = true
}

export function getImageDimensions(file: string) {
    return new Promise(function (resolved, rejected) {
        const i = new Image()
        i.onload = function () {
            resolved({ w: i.width, h: i.height })
        }
        i.src = file
    })
}

// convertors
export const convertors = {
    dec2bin: (x: number) => '0b' + x.toString(2),
    dec2hex: (x: number) => '0x' + x.toString(16),
    dec2octal: (x: number) => '0' + x.toString(8),
    dec2bcd: (x: number) => parseInt(x.toString(10), 16).toString(2),
}

export function parseNumber(num: string | number) {
    if(typeof num === 'number') return num;
    if (num.slice(0, 2).toLocaleLowerCase() == '0b')
        return parseInt(num.slice(2), 2)
    if (num.slice(0, 2).toLocaleLowerCase() == '0x')
        return parseInt(num.slice(2), 16)
    if (num.slice(0, 1).toLocaleLowerCase() == '0') return parseInt(num, 8)
    return parseInt(num)
}

export function promptFile(contentType: string, multiple: boolean) {
    const input = document.createElement('input')
    input.type = 'file'
    input.multiple = multiple
    input.accept = contentType
    return new Promise(function (resolve) {
        if (document.activeElement instanceof HTMLInputElement) {
            (document.activeElement as HTMLInputElement).onfocus = function () {
                (document.activeElement as HTMLInputElement).onfocus = null;
                setTimeout(resolve, 500);
            };
        }
        input.onchange = function () {
            const files = input.files
            if (files === null) return resolve([])
            const fileArray = Array.from(files)
            if (multiple) return resolve(fileArray)
            resolve(fileArray[0])
        }
        input.click()
    })
}

export function escapeHtml(unsafe: string) {
    return unsafe
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;')
}
