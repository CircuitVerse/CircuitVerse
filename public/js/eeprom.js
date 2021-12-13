/**
 * EEPROM Component.
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
 */
function EEPROM(x, y, scope = globalScope, dir = "RIGHT", bitWidth = 8, addressWidth = 8, data = null) {
    RAM.call(this, x, y, scope, dir, bitWidth, addressWidth);
    this.data = data || this.data;
}
EEPROM.prototype = Object.create(RAM.prototype);
EEPROM.prototype.tooltipText = "Electrically Erasable Programmable Read-Only Memory";
EEPROM.prototype.constructor = EEPROM;
EEPROM.prototype.shortName = "EEPROM";
EEPROM.prototype.maxAddressWidth = 10;
EEPROM.prototype.helplink = "https://docs.circuitverse.org/#/memoryElements?id=eeprom";
EEPROM.prototype.mutableProperties = {
    "addressWidth": {
        name: "Address Width",
        type: "number",
        max: "10",
        min: "1",
        func: "changeAddressWidth",
    },
    "dump": RAM.prototype.mutableProperties.dump,
    "reset": RAM.prototype.mutableProperties.reset,
}
EEPROM.prototype.customSave = function () {
    var saveInfo = RAM.prototype.customSave.call(this);

    // Normalize this.data to use zeroes instead of null when serialized.
    var data = this.data;
    for (var i = 0; i < data.length; i++) {
        data[i] = data[i] || 0;
    }

    saveInfo.constructorParamaters.push(data);
    return saveInfo;
}

//This is a EERAM without a clock - not normal
//reset is supported
EEPROM.moduleVerilog = function () {
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
