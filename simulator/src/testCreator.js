/*
    This file contains all javascript related to the test creator UI
    at /testbench
*/

import _ from '../vendor/table2csv';

const CREATORMODE = {
    NORMAL: 0,
    SIMULATOR_POPUP: 1,
};

var testMode = 'comb';
var groupIndex = 0;
var inputCount = 0;
var nextInputIndex = 0;
var outputCount = 0;
var nextOutputIndex = 0;
var cases = [0];
var creatorMode = CREATORMODE.NORMAL;
var circuitScopeID;

function dataReset() {
    groupIndex = -1;
    cases = [0];
}

/**
 * Onload, check if it is opened in a popup.
 * Check if test is being edited, or created
 */
window.onload = () => {
    const query = new URLSearchParams(window.location.search);
    if (query.has('popUp')) {
        if (query.get('popUp') == 'true') {
            creatorMode = CREATORMODE.SIMULATOR_POPUP;
            $('.right-button-group').append('<button class="lower-button save-buton" onclick="saveData();">Attach</button>');
        }
    }
    if (query.has('data')) {
        $('#tb-creator-head').html('<b>Edit Test</b>');
        circuitScopeID = query.get('scopeID');
        loadData(query.get('data'));
        return;
    }

    if (query.has('result')) {
        $('#tb-creator-head').html('<b>Test Result</b>');
        loadResult(query.get('result'));
        readOnlyUI();
        return;
    }

    circuitScopeID = query.get('scopeID');
    addInput();
    addOutput();
    makeSortable();
};

/* Change UI testMode between Combinational(comb) and Sequential(seq) */
function changeTestMode(m) {
    if (testMode === m) return false;
    dataReset();
    testMode = m;
    $('#combSelect').removeClass('tab-selected');
    $('#seqSelect').removeClass('tab-selected');
    $('#tb-new-group').css('visibility', m === 'seq' ? 'visible' : 'hidden');
    $(`#${m}Select`).addClass('tab-selected');
    $('#dataGroup').empty();

    return true;
}

/* Adds case to a group */
function addCase(grp) {
    const currentGroupTable = $(`#data-table-${grp + 1}`);

    let s = '<tr><td class="tb-handle"><div onclick="deleteCase($(this))"class="fa fa-minus-square tb-minus"></div></td>\n';
    for (let i = 0; i < inputCount + outputCount; i++) s += '<td contenteditable="true">0</td>';
    s += '</tr>';

    // Sortable hack
    currentGroupTable.find('tbody').remove();
    currentGroupTable.append(s);
}

/* Deletes case from a group */
function deleteCase(element) {
    const row = element.parent().parent();
    const grp = Number(row.parent().attr('id').split('-').pop());

    row.remove();
}

/* Adds group with default name 'Group N' or name supplied in @param groupName */
/* Used without params by UI, used with params by loadData() */
function addGroup(groupName = `${testMode === 'comb' ? 'Group' : 'Set'} ${groupIndex + 2}`) {
    $('.plus-button').removeClass('latest-button');
    groupIndex++;

    const s = `
    <div id="data-group-${groupIndex + 1}" class="data-group">
        <h3 id="data-group-title-${groupIndex + 1}" contenteditable="true">${escapeHtml(groupName)}</h3>
        <h5 class="data-group-info">Click + to add tests to the ${testMode === 'comb' ? 'group' : 'set'}</h5>
        <table class="tb-table" id="data-table-${groupIndex + 1}">
        <tbody></tbody>
        </table>
        <button class="lower-button plus-button latest-button" id="plus-${groupIndex + 1}" onclick="addCase(${groupIndex})" style="font-size: 25px;">+</button>
    </div>
    `;
    cases[groupIndex] = 0;
    $('#dataGroup').append(s);

    makeSortable();
}

/* Deletes a group */
function deleteGroup(element) {
    const groupDiv = element.parent();
    const grp = Number(groupDiv.attr('id').split('-').pop());
    groupDiv.remove();
}

/* Adds input with default value 0 or values supplied in @param inputData */
/* Used without params for UI, used with params by loadData() */
function addInput(label = `inp${nextInputIndex + 1}`, bitwidth = 1, inputData = []) {
    nextInputIndex++;
    inputCount++;
    // Change head table contents
    const sHead = `<th style="background-color: #aaf" id="tb-inp-label-${nextInputIndex}"><span contenteditable="true">${escapeHtml(label)}</span> <a onclick="deleteInput($(this));"><span class="fa fa-minus-square tb-minus"></span></a></th>`;
    const sData = `<td contenteditable="true">${escapeHtml(bitwidth.toString())}</td>`;
    $('#testBenchTable').find('tr').eq(1).find('th')
        .eq(inputCount - 1)
        .after(sHead);
    $('#testBenchTable').find('tr').eq(2).find('td')
        .eq(inputCount - 1)
        .after(sData);
    $('#tb-inputs-head').attr('colspan', inputCount);

    // Change data tables' contents
    $('#dataGroup').find('table').each(function (group_i) {
        $(this).find('tr').each(function (case_i) {
            const s = `<td contenteditable="true">${inputData.length ? escapeHtml(inputData[group_i][case_i]) : 0}</td>`;
            $(this).find('td').eq(inputCount - 1).after(s);
        });
    });
}

/* Adds output with default value 0 or values supplied in @param outputData */
/* Used without params for UI, used with params by loadData() */
/* Used with resultData and result=true for setting result */
function addOutput(label = `out${nextOutputIndex + 1}`, bitwidth = 1, outputData = [], result = false, resultData = []) {
    nextOutputIndex++;
    outputCount++;
    // Change head table contents
    let sHead = `<th style="background-color: #afa" id="tb-out-label-${nextOutputIndex}"><span contenteditable="true">${escapeHtml(label)}</span> <a onclick="deleteOutput($(this));"><span class="fa fa-minus-square tb-minus"></span></a></th>`;
    let sData = `<td contenteditable="true">${escapeHtml(bitwidth.toString())}</td>`;

    // If result then set colspan to 2
    if (result) {
        sHead = `<th style="background-color: #afa" id="tb-out-label-${nextOutputIndex}" colspan="2"><span contenteditable="true">${escapeHtml(label)}</span> <a onclick="deleteOutput($(this));"><span class="fa fa-minus-square tb-minus"></span></a></th>`;
        sData = `<td contenteditable="true" colspan="2">${escapeHtml(bitwidth.toString())}</td>`;
    }

    $('#testBenchTable').find('tr').eq(1).find('th')
        .eq(inputCount + outputCount - 1)
        .after(sHead);
    $('#testBenchTable').find('tr').eq(2).find('td')
        .eq(inputCount + outputCount - 1)
        .after(sData);
    // If not result then colspan is outputCount
    $('#tb-outputs-head').attr('colspan', outputCount);
    // else it's 2*outputCount
    if (result) {
        $('#tb-outputs-head').attr('colspan', 2 * outputCount);
    }

    // Change data tables' contents

    // If not result just add the outputs
    if (!result) {
        $('#dataGroup').find('table').each(function (group_i) {
            $(this).find('tr').each(function (case_i) {
                const s = `<td contenteditable="true">${outputData.length ? escapeHtml(outputData[group_i][case_i]) : 0}</td>`;
                $(this).find('td').eq(inputCount + outputCount - 1).after(s);
            });
        });

    // If result then add results besides the outputs
    // Hacky
    } else {
        $('#dataGroup').find('table').each(function (group_i) {
            $(this).find('tr').each(function (case_i) {
                // Add the outputs (expected values)
                const outputCellData = `<td>${escapeHtml(outputData[group_i][case_i])}</td>`;
                $(this).find('td').eq(inputCount + 2 * (outputCount - 1)).after(outputCellData);

                // Add the actual values
                const resultColor = resultData[group_i][case_i] === outputData[group_i][case_i] ? 'green' : 'red';
                const resultCellData = `<td style="color: ${resultColor}">${escapeHtml(resultData[group_i][case_i])}</td>`;
                $(this).find('td').eq(inputCount + 2 * outputCount - 1).after(resultCellData);
            });
        });
    }
}

/* Deletes input unless there's only one input */
function deleteInput(element) {
    if (inputCount === 1) return;
    const columnIndex = element.parent().eq(0).index();

    $('#testBenchTable tr, .data-group tr').slice(1).each(function () {
        $(this).find('td, th').eq(columnIndex).remove();
    });

    inputCount--;
    $('#tb-inputs-head').attr('colspan', inputCount);
}

/* Deletes output unless there's only one output */
function deleteOutput(element) {
    if (outputCount === 1) return;
    const columnIndex = element.parent().eq(0).index();

    $('#testBenchTable tr, .data-group tr').slice(1).each(function () {
        $(this).find('td, th').eq(columnIndex).remove();
    });

    outputCount--;
    $('#tb-outputs-head').attr('colspan', outputCount);
}

/* Returns input/output(keys) and their bitwidths(values) */
/* Called by getData() */
function getBitWidths() {
    const bitwidths = {};
    $('#testBenchTable').find('tr').eq(1).find('th')
        .slice(1)
        .each(function (index) {
            const inp = $(this).text();
            const bw = $('#testBenchTable').find('tr').eq(2).find('td')
                .slice(1)
                .eq(index)
                .html();
            bitwidths[inp] = Number(bw);
        });
    return bitwidths;
}

/* Returns data for all the groups for all inputs and outputs */
/* Called by parse() */
function getData() {
    const bitwidths = getBitWidths();
    const groups = [];
    const groupCount = $('#dataGroup').children().length;
    for (let group_i = 0; group_i < groupCount; group_i++) {
        const group = {};
        group.label = getGroupTitle(group_i);
        group.inputs = [];
        group.outputs = [];

        const group_table = $(`#data-table-${group_i + 1}`);
        group.n = group_table.find('tr').length;

        // Push all the inputs in the group
        for (let inp_i = 0; inp_i < inputCount; inp_i++) {
            const label = Object.keys(bitwidths)[inp_i];
            const input = { label: label.slice(0, label.length - 1), bitWidth: bitwidths[label], values: [] };
            group_table.find('tr').each(function () {
                input.values.push($(this).find('td').slice(1).eq(inp_i)
                    .html());
            });

            group.inputs.push(input);
        }

        // Push all the outputs in the group
        for (let out_i = 0; out_i < outputCount; out_i++) {
            const label = Object.keys(bitwidths)[inputCount + out_i];
            const output = { label: label.slice(0, label.length - 1), bitWidth: bitwidths[label], values: [] };
            group_table.find('tr').each(function () {
                output.values.push($(this).find('td').slice(1).eq(inputCount + out_i)
                    .html());
            });

            group.outputs.push(output);
        }

        groups.push(group);
    }

    return groups;
}

function getTestTitle() {
    return $('#test-title-label').text();
}

function getGroupTitle(group_i) {
    return $(`#data-group-title-${group_i + 1}`).text();
}

/* Parse UI table into Javascript Object */
function parse() {
    const data = {};
    const tableData = getData();
    data.type = testMode;
    data.title = getTestTitle();
    data.groups = tableData;
    return data;
}

/* Export test data as a CSV file */
function exportAsCSV() {
    let csvData = '';
    csvData += 'Title,Test Type,Input Count,Output Count\n';
    csvData += `${getTestTitle()},${testMode},${inputCount},${outputCount}\n\n\n`;
    csvData += $('table').eq(0).table2CSV();
    csvData += '\n\n';
    $('table').slice(1).each(function (group_i) {
        csvData += getGroupTitle(group_i);
        csvData += '\n';
        csvData += $(this).table2CSV();
        csvData += '\n\n';
    });

    download(`${getTestTitle()}.csv`, csvData);
    return csvData;
}

/*
 Imports data from CSV and loads into the table
 To achieve this, first converts to JSON then uses request param to load json to table
*/
function importFromCSV() {
    const file = $('#csvFileInput').prop('files')[0];
    const reader = new FileReader();

    // If circuitScopeID exists, ie. if popup opened from testbench, then use that to redirect
    const query = new URLSearchParams(window.location.search);
    // Preserve popup status while redirecting
    const isPopup = query.get('popUp') || false;

    // When the file is read, redirect to the data location
    reader.onload = () => {
        const csvContent = reader.result;
        const jsonData = csv2json(csvContent, 1, 1);

        window.location = `/testbench?scopeID=${circuitScopeID || ''}&data=${jsonData}&popUp=${isPopup}`;
    };

    reader.readAsText(file);
}

// Clicks the hidden upload file button, entrypoint into importFromCSV()
// The hidden button in-turn calls importFromCSV()
function clickUpload() {
    $('#csvFileInput').click();
}

/* Converts CSV to JSON to be loaded into the table */
function csv2json(csvFileData) {
    const stripQuotes = (str) => str.replaceAll('"', '');

    /* Extracts bitwidths from the csv data */
    const getBitWidthsCSV = (csvDataBW) => {
        const testMetadata = csvDataBW.split('\n\n')[0].split('\n');
        const labels = testMetadata[1].split(',').slice(1).map((label) => stripQuotes(label));
        const bitWidths = testMetadata[2].split(',').slice(1).map((bw) => Number(stripQuotes(bw)));

        return { labels, bitWidths };
    };

    const csvMetadata = csvFileData.split('\n\n\n')[0].split('\n')[1].split(',');
    const csvData = csvFileData.split('\n\n\n')[1];
    const jsonData = {};

    jsonData.title = csvMetadata[0];
    jsonData.type = csvMetadata[1];
    const inputCountCSV = Number(csvMetadata[2]);
    const outputCountCSV = Number(csvMetadata[3]);

    jsonData.groups = [];
    const { labels, bitWidths } = getBitWidthsCSV(csvData);

    const groups = csvData.split('\n\n').slice(1);
    for (let group_i = 0; group_i < groups.length - 1; group_i++) {
        const rows = groups[group_i].split('\n');
        jsonData.groups[group_i] = {
            label: rows[0], n: rows.length - 1, inputs: [], outputs: [],
        };

        // Parse Inputs
        for (let input_i = 0; input_i < inputCountCSV; input_i++) {
            const thisInput = { label: labels[input_i], bitWidth: bitWidths[input_i], values: [] };
            for (let case_i = 1; case_i < rows.length; case_i++) thisInput.values.push(stripQuotes(rows[case_i].split(',')[input_i + 1]));

            jsonData.groups[group_i].inputs.push(thisInput);
        }

        // Parse Outputs
        for (let output_i = inputCountCSV; output_i < inputCountCSV + outputCountCSV; output_i++) {
            const thisOutput = { label: labels[output_i], bitWidth: bitWidths[output_i], values: [] };
            for (let case_i = 1; case_i < rows.length; case_i++) {
                thisOutput.values.push(stripQuotes(rows[case_i].split(',')[output_i + 1]));
            }

            jsonData.groups[group_i].outputs.push(thisOutput);
        }
    }

    return JSON.stringify(jsonData);
}

/* Helper function to download generated file */
function download(filename, text) {
    var element = document.createElement('a');
    element.setAttribute('href', `data:text/plain;charset=utf-8,${encodeURIComponent(text)}`);
    element.setAttribute('download', filename);

    element.style.display = 'none';
    document.body.appendChild(element);

    element.click();

    document.body.removeChild(element);
}

/**
 * Called when Save is clicked. If opened in popup, sends message to parent window
 * to attach test to the testbench.
 */
function saveData() {
    const testData = parse();

    if (creatorMode === CREATORMODE.SIMULATOR_POPUP) {
        const postData = { scopeID: circuitScopeID, testData };
        window.opener.postMessage({ type: 'testData', data: JSON.stringify(postData) }, '*');
        window.close();
    }
}

/* Loads data from JSON string into the table */
function loadData(dataJSON) {
    const data = JSON.parse(dataJSON);
    if (data.title) $('#test-title-label').text(data.title);
    changeTestMode();
    changeTestMode(data.type);
    for (let group_i = 0; group_i < data.groups.length; group_i++) {
        const group = data.groups[group_i];
        addGroup(group.label);
        for (let case_i = 0; case_i < group.inputs[0].values.length; case_i++) {
            addCase(group_i);
        }
    }

    // Add input values
    for (let input_i = 0; input_i < data.groups[0].inputs.length; input_i++) {
        const input = data.groups[0].inputs[input_i];
        const values = data.groups.map((group) => group.inputs[input_i].values);

        addInput(input.label, input.bitWidth, values);
    }

    // Add output values
    for (let output_i = 0; output_i < data.groups[0].outputs.length; output_i++) {
        const output = data.groups[0].outputs[output_i];
        const values = data.groups.map((group) => group.outputs[output_i].values);

        addOutput(output.label, output.bitWidth, values);
    }
}

/**
 * Loads result from JSON string into the testbench creator UI
 */
function loadResult(dataJSON) {
    const data = JSON.parse(dataJSON);
    if (data.title) $('#test-title-label').text(data.title);
    changeTestMode();
    changeTestMode(data.type);
    for (let group_i = 0; group_i < data.groups.length; group_i++) {
        const group = data.groups[group_i];
        addGroup(group.label);
        for (let case_i = 0; case_i < group.inputs[0].values.length; case_i++) {
            addCase(group_i);
        }
    }

    // Add input values
    for (let input_i = 0; input_i < data.groups[0].inputs.length; input_i++) {
        const input = data.groups[0].inputs[input_i];
        const values = data.groups.map((group) => group.inputs[input_i].values);

        addInput(input.label, input.bitWidth, values);
    }

    // Add output values
    for (let output_i = 0; output_i < data.groups[0].outputs.length; output_i++) {
        const output = data.groups[0].outputs[output_i];
        const values = data.groups.map((group) => group.outputs[output_i].values);
        const results = data.groups.map((group) => group.outputs[output_i].results);
        const expectedOutputs = [];
        const actualOutputs = [];

        for (let group_i = 0; group_i < values.length; group_i++) {
            const groupExpectedOuts = [];
            const groupActualOuts = [];
            for (let val_i = 0; val_i < values[group_i].length; val_i++) {
                groupExpectedOuts.push(values[group_i][val_i]);
                groupActualOuts.push(results[group_i][val_i]);
            }

            expectedOutputs.push(groupExpectedOuts);
            actualOutputs.push(groupActualOuts);
        }
        addOutput(`${output.label}`, output.bitWidth, expectedOutputs, true, actualOutputs);
    }
}

/**
 * Makes the UI read only for displaying results
 */
function readOnlyUI() {
    makeContentUneditable();
    makeUnsortable();
    $('.lower-button, .table-button, .tb-minus').hide();
    $('.tablink').attr('disabled', 'disabled');
    $('.tablink').removeClass('tablink-no-override');
    $('.data-group-info').text('');
}

function makeContentUneditable() {
    $('body').find('td, th, span, h3, div').each(function () {
        $(this).attr('contenteditable', 'false');
    });
}

function makeSortable() {
    const helper = function (e, ui) {
        const helperE = ui.clone();
        helperE.children().each(function (child_i) {
            $(this).width(ui.children().eq(child_i).width());
        });

        return helperE;
    };

    function makePlaceholder(e, ui) {
        ui.placeholder.children().each(function () { $(this).css('border', '0px'); });
    }

    /*
        Sortable hack: To allow sorting inside empty tables, the tables should have some height.
        But it is not possible to give tables height without having rows, so we add a tbody.
        tbody gives the table height but messes up all the other things. So we only keep tbody
        if the table has no rows, and once table gets rows, we remove that tbody
     */
    function removeTbody(e, ui) {
        $(e.target).find('tbody').remove();
    }

    function createTbody(e, ui) {
        if ($(e.target).find('tr, tbody').length === 0) {
            $(e.target).append('<tbody></tbody>');
        }
    }

    $('.data-group table').sortable({
        handle: '.tb-handle',
        helper,
        start: makePlaceholder,
        placeholder: 'clone',
        connectWith: 'table',
        receive: removeTbody, // For sortable hack
        remove: createTbody, // For sortable hack
        items: 'tr',
        revert: 50,
        scroll: false,
    });
}

function makeUnsortable() {
    $('.data-group table').sortable({ disabled: true });
}

function escapeHtml(unsafe) {
    return unsafe
        .replace(/&/g, '&amp;')
        .replace(/</g, '&lt;')
        .replace(/>/g, '&gt;')
        .replace(/"/g, '&quot;')
        .replace(/'/g, '&#039;');
}

// Making HTML called functions global

window.addGroup = addGroup;
window.deleteGroup = deleteGroup;
window.addCase = addCase;
window.deleteCase = deleteCase;
window.addInput = addInput;
window.deleteInput = deleteInput;
window.addOutput = addOutput;
window.deleteOutput = deleteOutput;
window.parse = parse;
window.saveData = saveData;
window.changeTestMode = changeTestMode;
window.exportAsCSV = exportAsCSV;
window.importFromCSV = importFromCSV;
window.csv2json = csv2json;
window.clickUpload = clickUpload;
