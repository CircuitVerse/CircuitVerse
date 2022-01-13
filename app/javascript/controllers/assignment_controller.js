import { Controller } from 'stimulus';

var featureRestrictionMetadata = {
    Simulator: [
        'Combinational Analysis Tool',
        'Verilog tools',
    ],
    Project: [
        'Copy / Paste',
        'Allow Collaborators',
    ],
};

function handleFeatureMainCheckbox() {
    $('#restrict-feature').change((e) => {
        e.preventDefault();
        var radio = $(e.currentTarget);

        if (radio.is(':checked')) {
            $('.restricted-feature-list').css('display', 'block');
        } else {
            $('.restricted-feature-list').css('display', 'none');
        }
    });
    $('#restrict-feature').trigger('change');
}

function featureRestrictionsMap(restrictions) {
    var map = {};
    for (var i = 0; i < restrictions.length; i++) {
        map[restrictions[i]] = true;
    }
    return map;
}

function htmlRowFeatureName(name) {
    return '<h6 class="circuit-element-category"> '.concat(name, ' </h6>');
}

function htmlInlineFeatureCheckbox(elementName, checked) {
    return '\n <div class="form-check form-check-inline"> \n <label class="form-check-label primary-checkpoint-container" id = "label-'
        .concat(elementName, '" for="checkbox-')
        .concat(elementName, '">')
        .concat('<input class="form-check-input feature-restriction" type="checkbox" id="checkbox-')
        .concat(elementName, '" value="')
        .concat(elementName, '" ')
        .concat('>\n')
        .concat('<div class="primary-checkpoint"></div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;')
        .concat(elementName, '</span></label>\n</div>');
}

function generateFeatureRow(name, elements, restrictionMap) {
    var html = htmlRowFeatureName(name);
    for (var i = 0; i < elements.length; i++) {
        var element = elements[i];
        var checked = restrictionMap[element] ? 'checked' : '';
        html += htmlInlineFeatureCheckbox(element, checked);
    }
    return html;
}

function loadFeatureHtml(featureHierarchy, restrictionMap) {
    for (var i = 0; i < Object.entries(featureHierarchy).length; i++) {
        var category = Object.entries(featureHierarchy)[i];
        var html = generateFeatureRow(category[0], category[1], restrictionMap);
        $('.restricted-feature-list').append(html);
    }
}

function loadFeatureRestrictions() {
    handleFeatureMainCheckbox();
    var featureRestrictionMap = featureRestrictionsMap(featureRestrictionMetadata);
    loadFeatureHtml(featureRestrictionMetadata, featureRestrictionMap);
}

export default class extends Controller {
    connect() {
        loadFeatureRestrictions();
    }
}
