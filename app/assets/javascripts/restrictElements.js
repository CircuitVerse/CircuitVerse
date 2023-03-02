const handleMainCheckbox = () => {
    const restrictElements = document.querySelector('#restrict-elements');
    const restrictedElementsList = document.querySelector(
        '.restricted-elements-list',
    );
    restrictElements.addEventListener('change', (e) => {
        e.preventDefault();
        const radio = e.target;

        if (radio.checked) {
            restrictedElementsList.style.display = 'block';
        } else {
            restrictedElementsList.style.display = 'none';
        }
    });

    restrictElements.dispatchEvent(new Event('change'));
};

const restrictionsMap = (restrictions) => restrictions.reduce((acc, restriction) => ({
    ...acc,
    [restriction]: true,
}), {});

const htmlRowName = (name) => `<h6 class="circuit-element-category"> ${name} </h6>`;

const htmlInlineCheckbox = (elementName, checked) => `
      <div class="form-check form-check-inline">
        <label class="form-check-label primary-checkpoint-container" id="label-${elementName}" for="checkbox-${elementName}">
          <input class="form-check-input element-restriction" type="checkbox" id="checkbox-${elementName}" value="${elementName}" ${
    checked ? 'checked' : ''
}>
          <div class="primary-checkpoint"></div>&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;&nbsp;
          ${elementName}
        </label>
      </div>
    `;

const generateRow = (name, elements, restrictionMap) => {
    let html = htmlRowName(name);
    for (let i = 0; i < elements.length; i++) {
        const element = elements[i];
        const checked = restrictionMap[element] ? 'checked' : '';
        html += htmlInlineCheckbox(element, checked);
    }
    return html;
};

const loadHtml = (elementHierarchy, restrictionMap) => {
    const restrictedElementsList = document.querySelector(
        '.restricted-elements-list',
    );

    Object.entries(elementHierarchy).forEach(([name, elements]) => {
        const html = generateRow(name, elements, restrictionMap);
        restrictedElementsList.insertAdjacentHTML('beforeend', html);
    });
};

const loadRestrictions = (restrictions) => {
    handleMainCheckbox();
    const { elementHierarchy } = metadata;
    const restrictionMap = restrictionsMap(restrictions);
    loadHtml(elementHierarchy, restrictionMap);
};
