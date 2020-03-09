function handleMainCheckbox() {
    $('#restrict-elements').change(function (e) {
        e.preventDefault();
        var radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-elements-list').removeClass('display--none');
        } else {
            $('.restricted-elements-list').addClass('display--none');
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
    return "<div class=\"circuit-element-category\"> ".concat(name, " </div>");
}

function htmlInlineCheckbox(elementName, checked) {
    return '\n    <div class="form-check form-check-inline">\n        <input class="form-check-input element-restriction" type="checkbox" id="checkbox-'
      .concat(elementName, '" value="')
      .concat(elementName, '" ')
      .concat(
        checked,
        '>\n        <label class="form-check-label" for="checkbox-'
      )
      .concat(elementName, '">')
      .concat(elementName, "</label>\n    </div>");
}

function generateRow(name, elements, restrictionMap) {
    var html = htmlRowName(name);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var checked = restrictionMap[element] ? 'checked' : '';
        html += htmlInlineCheckbox(element, checked);
    }
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

    var _metadata = metadata,
        elementHierarchy = _metadata.elementHierarchy;
    var restrictionMap = restrictionsMap(restrictions);

    loadHtml(elementHierarchy, restrictionMap);
}
