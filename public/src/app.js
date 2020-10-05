import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import YosysJSON2CV from './Verilog2CV'
import { keyBinder } from './hotkey_binder/keyBinder';

document.addEventListener('DOMContentLoaded', () => {
    setup();
    var js = {
        "devices": {
            "dev0": {
                "type": "Input",
                "net": "a",
                "order": 0,
                "bits": 4
            },
            "dev1": {
                "type": "Input",
                "net": "b",
                "order": 1,
                "bits": 5
            },
            "dev2": {
                "type": "Output",
                "net": "out",
                "order": 2,
                "bits": 7
            },
            "dev3": {
                "label": "$shr$/tmp/tmp-12221nXqqXlYKW7W3.sv:6$1",
                "type": "ShiftRight",
                "bits": {
                    "in1": 4,
                    "in2": 5,
                    "out": 7
                },
                "signed": {
                    "in1": false,
                    "in2": false,
                    "out": false
                },
                "fillx": false
            }
        },
        "connectors": [
            {
                "to": {
                    "id": "dev3",
                    "port": "in1"
                },
                "from": {
                    "id": "dev0",
                    "port": "out"
                },
                "name": "a"
            },
            {
                "to": {
                    "id": "dev3",
                    "port": "in2"
                },
                "from": {
                    "id": "dev1",
                    "port": "out"
                },
                "name": "b"
            },
            {
                "to": {
                    "id": "dev2",
                    "port": "in"
                },
                "from": {
                    "id": "dev3",
                    "port": "out"
                },
                "name": "out"
            }
        ],
        "subcircuits": {}
    };
    YosysJSON2CV(js);
    keyBinder();
});

window.Array = Array;
