import { setup } from './setup';
import Array from './arrayHelpers';
import 'bootstrap';
import YosysJSON2CV from './Verilog2CV'

document.addEventListener('DOMContentLoaded', () => {
    setup();
    var js ={
        "devices": {
            "dev0": {
                "type": "Output",
                "net": "Y",
                "order": 0,
                "bits": 1
            },
            "dev1": {
                "type": "Input",
                "net": "A",
                "order": 1,
                "bits": 3
            },
            "dev2": {
                "type": "Input",
                "net": "B",
                "order": 2,
                "bits": 3
            },
            "dev3": {
                "label": "$and$/tmp/tmp-53067TiR5Q2lxIueD.sv:2$1",
                "type": "Le",
                "bits": 3
            }
        },
        "connectors": [
            {
                "to": {
                    "id": "dev0",
                    "port": "in"
                },
                "from": {
                    "id": "dev3",
                    "port": "out"
                },
                "name": "Y"
            },
            {
                "to": {
                    "id": "dev3",
                    "port": "in1"
                },
                "from": {
                    "id": "dev1",
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
                    "id": "dev2",
                    "port": "out"
                },
                "name": "B"
            }
        ],
        "subcircuits": {}
    };

    YosysJSON2CV(js);
});

window.Array = Array;
