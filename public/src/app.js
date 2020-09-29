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
                "net": "A",
                "order": 0,
                "bits": 2
            },
            "dev1": {
                "type": "Input",
                "net": "B",
                "order": 1,
                "bits": 1
            },
            "dev2": {
                "type": "Output",
                "net": "sum",
                "order": 2,
                "bits": 3
            },
            "dev3": {
                "label": "$add$/tmp/tmp-54207VCkh01QnefeF.sv:5$1",
                "type": "Addition",
                "bits": {
                    "in1": 2,
                    "in2": 1,
                    "out": 3
                },
                "signed": {
                    "in1": false,
                    "in2": false
                }
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
                "name": "A"
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
                "name": "B"
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
                "name": "sum"
            }
        ],
        "subcircuits": {}
    };

    YosysJSON2CV(js);
    keyBinder();
});

window.Array = Array;
