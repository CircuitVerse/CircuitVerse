/**
 * creates a dialog for inter converting values in different bases.
 */
export function createBitConverter() {
    $('#bitconverterprompt').append(`
    <label style='color:grey'>Decimal value</label><br><input  type='text' id='decimalInput' label="Decimal" name='text1'><br><br>
    <label  style='color:grey'>Binary value</label><br><input  type='text' id='binaryInput' label="Binary" name='text1'><br><br>
    <label  style='color:grey'>Octal value</label><br><input  type='text' id='octalInput' label="Octal" name='text1'><br><br>
    <label  style='color:grey'>Hexadecimal value</label><br><input  type='text' id='hexInput' label="Hex" name='text1'><br><br>
    `);
    $('#bitconverterprompt').dialog({
        buttons: [
            {
                text: 'Reset',
                click() {
                    $('#decimalInput').val('0');
                    $('#binaryInput').val('0');
                    $('#octalInput').val('0');
                    $('#hexInput').val('0');
                },
            },
        ],
    });

    $('#decimalInput').on('keyup', () => {
        const x = parseInt($('#decimalInput').val(), 10);
        setBaseValues(x);
    });

    $('#binaryInput').on('keyup', () => {
        const x = parseInt($('#binaryInput').val(), 2);
        setBaseValues(x);
    });

    $('#hexInput').on('keyup', () => {
        const x = parseInt($('#hexInput').val(), 16);
        setBaseValues(x);
    });

    $('#octalInput').on('keyup', () => {
        const x = parseInt($('#octalInput').val(), 8);
        setBaseValues(x);
    });
}
// convertors
const convertors = {
    dec2bin: (x) => `0b${x.toString(2)}`,
    dec2hex: (x) => `0x${x.toString(16)}`,
    dec2octal: (x) => `0${x.toString(8)}`,
};

function setBaseValues(x) {
    if (isNaN(x)) return;
    $('#binaryInput').val(convertors.dec2bin(x));
    $('#octalInput').val(convertors.dec2octal(x));
    $('#hexInput').val(convertors.dec2hex(x));
    $('#decimalInput').val(x);
}
