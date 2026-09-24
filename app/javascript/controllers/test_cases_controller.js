// Each row is one testbench group with n: 1 (one case per row).
/* eslint-disable class-methods-use-this */
import { Controller } from '@hotwired/stimulus';

const PIN_PATTERN = /^([A-Za-z_]\w*)(?::(\d+))?=(.+)$/;

export default class extends Controller {
    static get targets() {
        return ['list', 'output', 'error'];
    }

    static get values() {
        // The suite's existing type (e.g. 'seq'), preserved as-is since
        // this editor only authors 'comb' cases.
        return { type: String };
    }

    connect() {
        if (this.listTarget.children.length === 0) this.add();
    }

    add() {
        this.appendRow(null);
        this.toggleError(false);
    }

    remove(event) {
        event.target.closest('tr').remove();
    }

    serialize(event) {
        this.toggleError(false);
        const rows = Array.from(this.listTarget.querySelectorAll('tr'));

        if (rows.some((row) => this.rowState(row) === 'partial')) {
            // stopPropagation too: rails-ujs still disables the submit button
            // on a merely-prevented submit as it bubbles to its document listener.
            event.preventDefault();
            event.stopPropagation();
            this.toggleError(true);
            return;
        }

        const groups = rows.map((row) => this.rowToGroup(row)).filter((group) => group !== null);

        this.outputTarget.value = groups.length > 0
            ? JSON.stringify({ type: this.typeValue || 'comb', groups })
            : '';
    }

    appendRow(testCase) {
        const row = document.createElement('tr');
        row.innerHTML = this.rowTemplate(testCase);
        this.listTarget.appendChild(row);
    }

    rowTemplate(testCase) {
        const label = testCase ? testCase.label : '';
        const inputs = testCase ? this.pinsToText(testCase.inputs) : '';
        const outputs = testCase ? this.pinsToText(testCase.outputs) : '';
        const hidden = testCase && testCase.hidden ? 'checked' : '';
        return `
      <td><input type="text" class="form-control test-case-label" aria-label="Test case name" value="${this.escape(label)}"></td>
      <td><input type="text" class="form-control test-case-inputs" aria-label="Input pins" value="${this.escape(inputs)}" placeholder="a=1,b:2=3"></td>
      <td><input type="text" class="form-control test-case-outputs" aria-label="Expected output pins" value="${this.escape(outputs)}" placeholder="sum=1"></td>
      <td class="text-center"><input type="checkbox" class="test-case-hidden" aria-label="Hidden from student" ${hidden}></td>
      <td><button type="button" class="btn btn-sm btn-outline-danger" aria-label="Remove this test case" data-action="test-cases#remove">&times;</button></td>
    `;
    }

    // 'empty' (ignored on submit), 'complete' (all 3 fields, well-formed
    // pins), or 'partial' (missing a field, or a malformed pin - blocks submit).
    rowState(row) {
        const label = row.querySelector('.test-case-label').value.trim();
        const inputs = row.querySelector('.test-case-inputs').value.trim();
        const outputs = row.querySelector('.test-case-outputs').value.trim();
        const filled = [label, inputs, outputs].filter((value) => value.length > 0).length;

        if (filled === 0) return 'empty';
        if (filled === 3 && this.pinsWellFormed(inputs) && this.pinsWellFormed(outputs)) return 'complete';
        return 'partial';
    }

    // A malformed token (e.g. "b:two=1") is silently dropped by parsePins,
    // so compare counts to catch it rather than saving a partial pin list.
    pinsWellFormed(text) {
        const tokens = text.split(',').map((token) => token.trim()).filter((token) => token.length > 0);
        return tokens.length === this.parsePins(text).length;
    }

    rowToGroup(row) {
        if (this.rowState(row) !== 'complete') return null;

        return {
            label: row.querySelector('.test-case-label').value.trim(),
            n: 1,
            hidden: row.querySelector('.test-case-hidden').checked,
            inputs: this.parsePins(row.querySelector('.test-case-inputs').value),
            outputs: this.parsePins(row.querySelector('.test-case-outputs').value),
        };
    }

    toggleError(show) {
        this.errorTarget.classList.toggle('d-none', !show);
    }

    parsePins(text) {
        return text.split(',')
            .map((token) => token.trim())
            .filter((token) => token.length > 0)
            .map((token) => token.match(PIN_PATTERN))
            .filter((match) => match !== null)
            .map(([, label, bitWidth, value]) => ({
                label,
                bitWidth: bitWidth ? parseInt(bitWidth, 10) : 1,
                values: [value],
            }));
    }

    pinsToText(pins) {
        return (pins || []).map((pin) => {
            const bits = pin.bitWidth && pin.bitWidth !== 1 ? `:${pin.bitWidth}` : '';
            return `${pin.label}${bits}=${(pin.values || [])[0]}`;
        }).join(',');
    }

    escape(value) {
        return String(value).replace(/"/g, '&quot;');
    }
}
