/**
 * A function to Show Message on Simulator
 * Replacement for alert
 * @param {String} message
 */
export const alertDialog = (message) => {
    $('#alertDialog').empty();
    $('#alertDialog').append(`<div id="alertMessage">${message}</div>`);
    $('#alertDialog').dialog({
        resizable: false,
        buttons: [
            {
                text: 'OK',
                click() {
                    // to close the dialog
                    $(this).dialog("close");
                },
            },
        ],
    });
};
