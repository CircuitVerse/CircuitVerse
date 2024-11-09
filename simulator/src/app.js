import * as Sentry from "@sentry/browser";
import { setup } from './setup';
import Array from './arrayHelpers';

// Initialize Sentry for error tracking
Sentry.init({
  dsn: "https://a9660d5d8964d5b348b07b77691d61a7@o4507251968376832.ingest.de.sentry.io/4507251969949776", 
  integrations: [new Sentry.Integrations.Breadcrumbs({ console: false })],
  tracesSampleRate: 1.0, 
});

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
                "net": "addr",
                "order": 1,
                "bits": 4
            },
            "dev2": {
                "type": "Output",
                "net": "data",
                "order": 2,
                "bits": 5
            },
            "dev3": {
                "type": "Input",
                "net": "addr2",
                "order": 3,
                "bits": 4
            },
            "dev4": {
                "type": "Output",
                "net": "data2",
                "order": 4,
                "bits": 5
            },
            "dev5": {
                "type": "Input",
                "net": "wraddr",
                "order": 5,
                "bits": 4
            },
            "dev6": {
                "type": "Input",
                "net": "wrdata",
                "order": 6,
                "bits": 5
            },
            "dev7": {
                "type": "Input",
                "net": "wraddr2",
                "order": 7,
                "bits": 4
            },
            "dev8": {
                "type": "Input",
                "net": "wrdata2",
                "order": 8,
                "bits": 5
            },
            "dev9": {
                "label": "mem",
                "type": "Memory",
                "bits": 5,
                "abits": 4,
                "words": 16,
                "offset": 0,
                "rdports": [
                    {},
                    {
                        "clock_polarity": true
                    }
                ],
                "wrports": [
                    {
                        "clock_polarity": true
                    },
                    {
                        "clock_polarity": true
                    }
                ],
                "memdata": [
                    13,
                    "00001",
                    3,
                    "11111"
                ]
            }
        },
        "connectors": [
            {
                "to": {
                    "id": "dev9",
                    "port": "rd1clk"
                },
                "from": {
                    "id": "dev0",
                    "port": "out"
                },
                "name": "clk"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr0clk"
                },
                "from": {
                    "id": "dev0",
                    "port": "out"
                },
                "name": "clk"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr1clk"
                },
                "from": {
                    "id": "dev0",
                    "port": "out"
                },
                "name": "clk"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "rd0addr"
                },
                "from": {
                    "id": "dev1",
                    "port": "out"
                },
                "name": "addr"
            },
            {
                "to": {
                    "id": "dev2",
                    "port": "in"
                },
                "from": {
                    "id": "dev9",
                    "port": "rd0data"
                },
                "name": "data"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "rd1addr"
                },
                "from": {
                    "id": "dev3",
                    "port": "out"
                },
                "name": "addr2"
            },
            {
                "to": {
                    "id": "dev4",
                    "port": "in"
                },
                "from": {
                    "id": "dev9",
                    "port": "rd1data"
                },
                "name": "data2"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr0addr"
                },
                "from": {
                    "id": "dev5",
                    "port": "out"
                },
                "name": "wraddr"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr0data"
                },
                "from": {
                    "id": "dev6",
                    "port": "out"
                },
                "name": "wrdata"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr1addr"
                },
                "from": {
                    "id": "dev7",
                    "port": "out"
                },
                "name": "wraddr2"
            },
            {
                "to": {
                    "id": "dev9",
                    "port": "wr1data"
                },
                "from": {
                    "id": "dev8",
                    "port": "out"
                },
                "name": "wrdata2"
            }
        ],
        "subcircuits": {}
    };
});

window.Array = Array;
