function getDialogContent(label, defaultValue) {
    return `
        <label for='promptInput'>${label}</label>
        <input id='promptInput' type='text' placeholder='${defaultValue}' name='promptInput'>
    `;
}

/**
 * A function to prompt Message on Simulator
 * Replacement for js-prompt dialogs
 * @param {String} message
 */
export const promptDialog = (label, defaultValue) => {
    $("#promptDialog").empty();
    $("#promptDialog").append(getDialogContent(label, defaultValue));
    $("#promptDialog").dialog({
        resizable: false,
    });
};