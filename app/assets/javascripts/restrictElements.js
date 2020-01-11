function handleMainCheckbox() {
    $('#restrict-elements').change((e) => {
        e.preventDefault();
        const radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-elements-list').removeClass('display--none');
        } else {
            $('.restricted-elements-list').addClass('display--none');
        }
    });
    $('#restrict-elements').trigger('change');
}

function restrictionsMap(restrictions) {
    const map = {};
    for (let i = 0; i < restrictions.length; i++) {
        map[restrictions[i]] = true;
    }
    return map;
}

function htmlRowName(name) {
    return `<div class="circuit-element-category"> ${name} </div>`;
}

function htmlInlineCheckbox(elementName, checked) {
    return `
    <div class="form-check form-check-inline">
        <input class="form-check-input element-restriction" type="checkbox" id="checkbox-${elementName}" value="${elementName}" ${checked}>
        <label class="form-check-label" for="checkbox-${elementName}">${elementName}</label>
    </div>`;
}

function generateRow(name, elements, restrictionMap) {
    let html = htmlRowName(name);
    for (let i = 0; i < elements.length; i++) {
        const element = elements[i];
        const checked = restrictionMap[element] ? 'checked' : '';
        html += htmlInlineCheckbox(element, checked);
    }
    return html;
}

function loadHtml(elementHierarchy, restrictionMap) {
    for (let i = 0; i < Object.entries(elementHierarchy).length; i++) {
        const category = Object.entries(elementHierarchy)[i];
        const html = generateRow(category[0], category[1], restrictionMap);
        $('.restricted-elements-list').append(html);
    }
}

function loadRestrictions(restrictions) {
    handleMainCheckbox();

    const { elementHierarchy } = metadata;
    const restrictionMap = restrictionsMap(restrictions);

    loadHtml(elementHierarchy, restrictionMap);
}
