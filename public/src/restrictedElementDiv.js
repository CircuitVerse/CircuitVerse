
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
