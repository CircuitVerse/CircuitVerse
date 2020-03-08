(function ($) {
    'use strict';

    $.fn.tableToJSON = function (opts) {

        // Set options
        var defaults = {
            ignoreColumns: [],
            onlyColumns: null,
            ignoreHiddenRows: true,
            headings: null,
            allowHTML: false
        };
        opts = $.extend(defaults, opts);

        var notNull = function (value) {
            return value !== undefined && value !== null;
        };

        var ignoredColumn = function (index) {
            if (notNull(opts.onlyColumns)) {
                return $.inArray(index, opts.onlyColumns) === -1;
            }
            return $.inArray(index, opts.ignoreColumns) !== -1;
        };

        var arraysToHash = function (keys, values) {
            var result = {}, index = 0;
            $.each(values, function (i, value) {
                // when ignoring columns, the header option still starts
                // with the first defined column
                if (index < keys.length && notNull(value)) {
                    result[keys[index]] = value;
                    index++;
                }
            });
            return result;
        };

        var cellValues = function (cellIndex, cell) {
            var value, result;
            if (!ignoredColumn(cellIndex)) {
                var override = $(cell).data('override');
                if (opts.allowHTML) {
                    value = $.trim($(cell).html());
                } else {
                    value = $.trim($(cell).text());
                }
                result = notNull(override) ? override : value;
            }
            return result;
        };

        var rowValues = function (row) {
            var result = [];
            $(row).children('td,th').each(function (cellIndex, cell) {
                if (!ignoredColumn(cellIndex)) {
                    result.push(cellValues(cellIndex, cell));
                }
            });
            return result;
        };

        var getHeadings = function (table) {
            var firstRow = table.find('tr:first').first();
            return notNull(opts.headings) ? opts.headings : rowValues(firstRow);
        };

        var construct = function (table, headings) {
            var i, j, len, len2, txt, $row, $cell,
            tmpArray = [],
                cellIndex = 0,
                result = [];
            table.children('tbody,*').children('tr').each(function (rowIndex, row) {
                if (rowIndex > 0 || notNull(opts.headings)) {
                    $row = $(row);
                    if ($row.is(':visible') || !opts.ignoreHiddenRows) {
                        if (!tmpArray[rowIndex]) {
                            tmpArray[rowIndex] = [];
                        }
                        cellIndex = 0;
                        $row.children().each(function () {
                            if (!ignoredColumn(cellIndex)) {
                                $cell = $(this);

                                // process rowspans
                                if ($cell.filter('[rowspan]').length) {
                                    len = parseInt($cell.attr('rowspan'), 10) - 1;
                                    txt = cellValues(cellIndex, $cell, []);
                                    for (i = 1; i <= len; i++) {
                                        if (!tmpArray[rowIndex + i]) {
                                            tmpArray[rowIndex + i] = [];
                                        }
                                        tmpArray[rowIndex + i][cellIndex] = txt;
                                    }
                                }
                                // process colspans
                                if ($cell.filter('[colspan]').length) {
                                    len = parseInt($cell.attr('colspan'), 10) - 1;
                                    txt = cellValues(cellIndex, $cell, []);
                                    for (i = 1; i <= len; i++) {
                                        // cell has both col and row spans
                                        if ($cell.filter('[rowspan]').length) {
                                            len2 = parseInt($cell.attr('rowspan'), 10);
                                            for (j = 0; j < len2; j++) {
                                                tmpArray[rowIndex + j][cellIndex + i] = txt;
                                            }
                                        } else {
                                            tmpArray[rowIndex][cellIndex + i] = txt;
                                        }
                                    }
                                }
                                // skip column if already defined
                                while (tmpArray[rowIndex][cellIndex]) {
                                    cellIndex++;
                                }
                                if (!ignoredColumn(cellIndex)) {
                                    txt = tmpArray[rowIndex][cellIndex] || cellValues(cellIndex, $cell, []);
                                    if (notNull(txt)) {
                                        tmpArray[rowIndex][cellIndex] = txt;
                                    }
                                }
                            }
                            cellIndex++;
                        });
                    }
                }
            });
            $.each(tmpArray, function (i, row) {
                if (notNull(row)) {
                    txt = arraysToHash(headings, row);
                    result[result.length] = txt;
                }
            });
            return result;
        };

        // Run
        var headings = getHeadings(this);
        return construct(this, headings);
    };
})(jQuery);

$('#convert-table').click(function () {
    var table = $('#example-table').tableToJSON(); // Convert the table into a javascript object
    console.log(table);
    var json = JSON.stringify(table);
    var res = document.getElementById("res");
    res.value = json;
});
