/* eslint-disable class-methods-use-this */
import { Controller } from '@hotwired/stimulus';

const featureRestrictionMetadata = {
    Simulator: [
        'Combinational Analysis Tool',
        'Verilog tools',
    ],
    Project: [
        'Copy / Paste',
        'Allow Collaborators',
    ],
};

function featureRestrictionsMap(restrictions) {
    return restrictions.reduce((map, feature) => {
        map[feature] = true;
        return map;
    }, {});
}

function htmlRowFeatureName(name) {
    return `<h6 class="circuit-element-category">${name}</h6>`;
}

function htmlInlineFeatureCheckbox(elementName, checked) {
    return `
        <div class="form-check form-check-inline">
            <label class="form-check-label primary-checkpoint-container" id="label-${elementName}" for="checkbox-${elementName}">
                <input 
                    class="form-check-input feature-restriction" 
                    type="checkbox" 
                    id="checkbox-${elementName}" 
                    value="${elementName}" 
                    ${checked ? 'checked' : ''} 
                    aria-label="Toggle feature ${elementName}"
                />
                <div class="primary-checkpoint"></div>
                <span>${elementName}</span>
            </label>
        </div>
    `;
}

function generateFeatureRow(name, elements, restrictionMap) {
    const html = elements
        .map(element => htmlInlineFeatureCheckbox(element, restrictionMap[element]))
        .join('');
    return `${htmlRowFeatureName(name)}${html}`;
}

function loadFeatureHtml(featureHierarchy, restrictionMap) {
    Object.entries(featureHierarchy).forEach(([category, elements]) => {
        const html = generateFeatureRow(category, elements, restrictionMap);
        document.querySelector('.restricted-feature-list').insertAdjacentHTML('beforeend', html);
    });
}

function loadFeatureRestrictions() {
    const featureRestrictionMap = featureRestrictionsMap(Object.keys(featureRestrictionMetadata));
    loadFeatureHtml(featureRestrictionMetadata, featureRestrictionMap);
}

export default class extends Controller {
    handleFeatureMainCheckbox() {
        const restrictedList = document.querySelector('.restricted-feature-list');
        const isChecked = document.getElementById('restrict-feature').checked;
        restrictedList.style.display = isChecked ? 'none' : 'block';
    }

    connect() {
        loadFeatureRestrictions();
    }
}