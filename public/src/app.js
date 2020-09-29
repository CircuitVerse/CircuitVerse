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
                "net": "clk",
                "order": 0,
                "bits": 1
            },
            "dev1": {
                "type": "Input",
                "net": "rst",
                "order": 1,
                "bits": 1
            },
            "dev2": {
                "type": "Input",
                "net": "en",
                "order": 2,
                "bits": 1
            },
            "dev3": {
                "type": "Output",
                "net": "count",
                "order": 3,
                "bits": 4
            },
            "dev4": {
                "label": "$add$/tmp/tmp-1593055CwLmFIwiXL.sv:10$2",
                "type": "Addition",
                "bits": {
                    "in1": 4,
                    "in2": 1,
                    "out": 4
                },
                "signed": {
                    "in1": false,
                    "in2": false
                }
            },
            "dev5": {
                "label": "$auto$dff2dffe.cc:159:make_patterns_logic$10",
                "type": "Ne",
                "bits": {
                    "in1": 2,
                    "in2": 1
                },
                "signed": {
                    "in1": false,
                    "in2": false
                }
            },
            "dev6": {
                "label": "$auto$dff2dffe.cc:215:handle_dff_cell$11",
                "type": "Dff",
                "bits": 4,
                "polarity": {
                    "clock": true,
                    "enable": true
                }
            },
            "dev7": {
                "label": "$procmux$6",
                "type": "Mux",
                "bits": {
                    "in": 4,
                    "sel": 1
                }
            },
            "dev8": {
                "type": "BusGroup",
                "groups": [
                    1,
                    1
                ]
            },
            "dev9": {
                "type": "Constant",
                "constant": "1"
            },
            "dev10": {
                "type": "Constant",
                "constant": "0"
            },
            "dev11": {
                "type": "Constant",
                "constant": "0000"
            }
        },
        "connectors": [
            {
                "to": {
                    "id": "dev6",
                    "port": "clk"
                },
                "from": {
                    "id": "dev0",
                    "port": "out"
                },
                "name": "clk"
            },
            {
                "to": {
                    "id": "dev7",
                    "port": "sel"
                },
                "from": {
                    "id": "dev1",
                    "port": "out"
                },
                "name": "rst"
            },
            {
                "to": {
                    "id": "dev8",
                    "port": "in0"
                },
                "from": {
                    "id": "dev1",
                    "port": "out"
                },
                "name": "rst"
            },
            {
                "to": {
                    "id": "dev8",
                    "port": "in1"
                },
                "from": {
                    "id": "dev2",
                    "port": "out"
                },
                "name": "en"
            },
            {
                "to": {
                    "id": "dev3",
                    "port": "in"
                },
                "from": {
                    "id": "dev6",
                    "port": "out"
                },
                "name": "count"
            },
            {
                "to": {
                    "id": "dev4",
                    "port": "in1"
                },
                "from": {
                    "id": "dev6",
                    "port": "out"
                },
                "name": "count"
            },
            {
                "to": {
                    "id": "dev4",
                    "port": "in2"
                },
                "from": {
                    "id": "dev9",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev7",
                    "port": "in0"
                },
                "from": {
                    "id": "dev4",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev5",
                    "port": "in1"
                },
                "from": {
                    "id": "dev8",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev5",
                    "port": "in2"
                },
                "from": {
                    "id": "dev10",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev6",
                    "port": "en"
                },
                "from": {
                    "id": "dev5",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev6",
                    "port": "in"
                },
                "from": {
                    "id": "dev7",
                    "port": "out"
                }
            },
            {
                "to": {
                    "id": "dev7",
                    "port": "in1"
                },
                "from": {
                    "id": "dev11",
                    "port": "out"
                }
            }
        ],
        "subcircuits": {}
    };
    YosysJSON2CV(js);
    keyBinder();
});

window.Array = Array;
