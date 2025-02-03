
export function updateRestrictedElementsList() {
    if (restrictedElements.length === 0) return;

    const { restrictedCircuitElementsUsed } = globalScope;
    let restrictedStr = '';

    restrictedCircuitElementsUsed.forEach((element) => {
        restrictedStr += `${element}, `;
    });

    if (restrictedStr === '') {
        restrictedStr = 'None';
    } else {
        restrictedStr = restrictedStr.slice(0, -2);
    }

    $('#restrictedElementsDiv--list').html(restrictedStr);
}


export function updateRestrictedElementsInScope(scope = globalScope) {
    // Do nothing if no restricted elements
    if (restrictedElements.length === 0) return;

    const restrictedElementsUsed = [];
    restrictedElements.forEach((element) => {
        if (scope[element].length > 0) {
            restrictedElementsUsed.push(element);
        }
    });

    scope.restrictedCircuitElementsUsed = restrictedElementsUsed;
    updateRestrictedElementsList();
}

export function showRestricted() {
    $('#restrictedDiv').removeClass('display--none');
    // Show no help text for restricted elements
    $('#Help').removeClass('show');
    $('#restrictedDiv').html('The element has been restricted by mentor. Usage might lead to deduction in marks');
}

export function hideRestricted() {
    $('#restrictedDiv').addClass('display--none');
}
