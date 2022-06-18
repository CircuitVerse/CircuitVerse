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

    clearData() {
        super.clearData();
        for (var i = 0; i < this.data.length; i++)
            this.data[i] = this.data[i] || 0;
    }

    customSave() {
        var saveInfo = super.customSave(this);

        // Normalize this.data to use zeroes instead of null when serialized.
        var {data} = this;

        saveInfo.constructorParamaters.push(data);
        return saveInfo;
    }

    //This is a EERAM without a clock - not normal
    //reset is supported
    static moduleVerilog() {
        return `
    module EEPROM(dout, addr, din, we, dmp, rst);
        parameter WIDTH = 8;
        parameter ADDR = 10;
        output [WIDTH-1:0] dout;
        input [ADDR-1:0] addr;
        input [WIDTH-1:0] din;
        input we;
        input dmp;
        input rst;
        reg [WIDTH-1:0] mem[2**ADDR-1:0];
        integer j;
    
        assign dout = mem[addr];
    
        always @ (*) begin
        if (!rst)
            for (j=0; j < 2**ADDR-1; j=j+1) begin
                mem[j] = 0;
            end
        if (!we)
            mem[addr] = din;
        dout = mem[addr];
        end
    endmodule
    `;
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
    load: RAM.prototype.mutableProperties.load,
    reset: RAM.prototype.mutableProperties.reset,
};
EEPROM.prototype.objectType = 'EEPROM';
