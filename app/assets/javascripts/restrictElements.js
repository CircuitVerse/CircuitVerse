function handleMainCheckbox() {
    $('#restrict-elements').change(function (e) {
        e.preventDefault();
        var radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-elements-list').css("display", "block");
        } else {
            $('.restricted-elements-list').css("display", "none");
        }
    });
    $('#restrict-elements').trigger('change');
}

function restrictionsMap(restrictions) {
    var map = {};
    for (var i = 0; i < restrictions.length; i++) {
        map[restrictions[i]] = true;
    }
    return map;
}

function htmlRowName(name) {
    return '<h6 class="circuit-element-category"> '.concat(name, ' </h6><div class="restriction-grid">');
}

function htmlInlineCheckbox(elementName, checked) {
    return '<div class="restriction-grid-item">' +
        '<label class="primary-checkpoint-container" id="label-' + elementName + '" for="checkbox-' + elementName + '">' +
        '<input class="form-check-input element-restriction" type="checkbox" id="checkbox-' + elementName + '" value="' + elementName + '">' +
        '<div class="primary-checkpoint"></div>' +
        '</label>' +
        '<span class="restriction-label">' + elementName + '</span>' +
        '</div>';
}

function generateRow(name, elements, restrictionMap) {
    var html = htmlRowName(name);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var checked = restrictionMap[element] ? 'checked' : '';
        html += htmlInlineCheckbox(element, checked);
    }
    html += '</div>';
    return html;
}

function loadHtml(elementHierarchy, restrictionMap) {
    for (var i = 0; i < Object.entries(elementHierarchy).length; i++) {
        var category = Object.entries(elementHierarchy)[i];
        var html = generateRow(category[0], category[1], restrictionMap);
        $('.restricted-elements-list').append(html);
    }
}

function loadRestrictions(restrictions) {
    handleMainCheckbox();
    var _metadata = metadata;
    var elementHierarchy = _metadata.elementHierarchy;
    var restrictionMap = restrictionsMap(restrictions);
    loadHtml(elementHierarchy, restrictionMap);
}
