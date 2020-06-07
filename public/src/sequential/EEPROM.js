import RAM from './RAM';
/**
 * @class
 * EEPROM Component.
 * @extends CircuitElement
 * @param {number} x - x coord of element
 * @param {number} y - y coord of element
 * @param {Scope=} scope - the ciruit in which we want the Element
 * @param {string=} dir - direcion in which element has to drawn

 *
 * This is basically a RAM component that persists its contents.
 *
 * We consider EEPROMs more 'expensive' than RAMs, so we arbitrarily limit
 * the addressWith to a maximum of 10 bits (1024 addresses) with a default of 8-bit (256).
 *
 * In the EEPROM all addresses are initialized to zero.
 * This way we serialize unused values as "0" instead of "null".
 *
 * These two techniques help keep reduce the size of saved projects.
 * @category sequential
 */
export default class EEPROM extends RAM {
    constructor(
        x,
        y,
        scope = globalScope,
        dir = 'RIGHT',
        bitWidth = 8,
        addressWidth = 8,
        data = null,
    ) {
        super(x, y, scope, dir, bitWidth, addressWidth);
        /*
        this.scope['EEPROM'].push(this);
        */
        this.data = data || this.data;
    }

    customSave() {
        const saveInfo = RAM.prototype.customSave.call(this);

        // Normalize this.data to use zeroes instead of null when serialized.
        const { data } = this;
        for (let i = 0; i < data.length; i++) {
            data[i] = data[i] || 0;
        }

        saveInfo.constructorParamaters.push(data);
        return saveInfo;
    }
}

EEPROM.prototype.tooltipText = 'Electrically Erasable Programmable Read-Only Memory';
EEPROM.prototype.shortName = 'EEPROM';
EEPROM.prototype.maxAddressWidth = 10;
EEPROM.prototype.mutableProperties = {
    addressWidth: {
        name: 'Address Width',
        type: 'number',
        max: '10',
        min: '1',
        func: 'changeAddressWidth',
    },
    dump: RAM.prototype.mutableProperties.dump,
    reset: RAM.prototype.mutableProperties.reset,
};
EEPROM.prototype.objectType = 'EEPROM';
