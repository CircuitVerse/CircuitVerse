export const generateSpacings = (spaceLength) => {
    const spacement = new Array(spaceLength).fill(' ')
    const regexComma = /,/g

    return spacement.join().replace(regexComma, '')
}

export const generateHeaderVhdlEntity = (component, index) => {
    const regexComma = /,/g
    const header = [
    `\n//-------------${component}${index}-------------\n`,
    'library IEEE;\n',
    'use IEEE.std_logic_1164.all;\n',
    `\nENTITY ${component}${index} IS\n`,
    generateSpacings(2),
    'PORT (\n',
    ]

    return header.toString().replace(regexComma, "")
}

export const generateHeaderVhdlWithNumericLib = (component, index) => {
    const regexComma = /,/g
    const header = [
    `\n//-------------${component}${index}-------------\n`,
    'library IEEE;\n',
    'use IEEE.std_logic_1164.all;\n',
    'use IEEE.numeric_std.all;\n',
    `\nENTITY ${component}${index} IS\n`,
    generateSpacings(2),
    'PORT (\n',
    ]

    return header.toString().replace(regexComma, "")
}

export const generatePortsIO = (type, idx) => {
    const portsQuantity = Math.pow(2, idx)
    let portsArray = []
    const isOnePort = (idx === 0)
    
    for(let i = 0; i < portsQuantity; i++){
        (isOnePort)
            ? portsArray[i] = `${type}`
            : portsArray[i] = `${type}${i}`
    }

    return generateSpacings(4) + portsArray.join(', ')
}

export const generatePortsIOPriorityEnc = (type, idx) => {
    let portsArray = []
    const isOnePort = (idx === 0)
    
    for(let i = 0; i < idx; i++){
        (isOnePort)
            ? portsArray[i] = `${type}`
            : portsArray[i] = `${type}${i}`
    }

    return generateSpacings(4) + portsArray.join(', ')
}


export const generateSTDType = (type, width) => {
    return (width !== 1)
        ? `: ${type} STD_LOGIC_VECTOR (${width - 1} DOWNTO 0)`
        : `: ${type} STD_LOGIC`
}

export const generateFooterEntity = () => {
    const regexComma = /,/g
    const footer = [
            generateSpacings(2),
            `);\n`,
            `END ENTITY;\n`,
            `\n`,
        ]

    return footer.toString().replace(regexComma, "")
}

export const generateArchitetureHeader = (component, index)  => {
    const regexComma = /,/g
    const header = [
        `ARCHITECTURE rtl OF ${component}${index} IS\n`,
        (component === 'MSB' || component === 'LSB') ? `  SIGNAL reset: INTEGER := 0;\n${generateSpacings(2)}` : generateSpacings(2),
        `BEGIN\n`,
    ]

    return header.toString().replace(regexComma, "")
}

export const generateZeros = (quantity, position) => {
    let zeros = ''
    
    for(let i = 0; i < quantity; i++){
        zeros += '0'
    }

    return zeros + position.toString(2)
}

export const generateLogicMux = (quantity) => {
    let output = []
    let quotationmark = (quantity > 1) ? '"' : "'"
    let k = ''
    
    for (let j = 0; j < Math.pow(2,quantity); j++) {
        k = generateZeros(quantity, j)
        output[j] = `in${j} WHEN ${quotationmark}${k.slice(-(quantity))}${quotationmark}`
    }

    return output.join(`,\n${generateSpacings(9)}`)
}

export const generateLogicDemux = (quantity, bitwidth) => {
    let output = []
    const quotationcontrol = (quantity > 1) ? '"' : "'"
    const quotationbit = (bitwidth > 1) ? '"' : "'"
    const iterations = Math.pow(2,quantity)
    let conditional = ''
    let controlsignalnumber = ''
    let bitwidthzeros = ''
    
    for (let j = 0; j < iterations; j++) {
        const isFirstConditional = (j === 0)
        const isLastConditional = (j === iterations - 1)
        
        conditional = (isFirstConditional
            ? 'IF'
            : isLastConditional ? 'ELSE' : 'ELSIF'
        )
        controlsignalnumber = generateZeros(quantity, j)
        bitwidthzeros = generateZeros(bitwidth - 1, 0)
        const isNotElse = (conditional !== 'ELSE') ? `(sel = ${quotationcontrol}${controlsignalnumber.slice(-(quantity))}${quotationcontrol}) THEN` : ''
        
        output[j] = `${conditional}${isNotElse}\n`
        
        for (let p = 0; p < iterations; p++){
            output[j] += (p===j)
                ? `${generateSpacings(10)}out${j} <= in0;\n` 
                : `${generateSpacings(10)}out${p} <= ${quotationbit}${bitwidthzeros.slice(-(bitwidth))}${quotationbit};\n`
        }
    }

    return output.join(`${generateSpacings(9)}`)
}

export const generateLogicDecoder = (quantity) => {
    let output = []
    const quotationbit = (quantity > 1) ? '"' : "'"
    const iterations = Math.pow(2, quantity)
    let conditional = ''
    let bitwidthzeros = ''
    
    for (let j = 0; j < iterations; j++) {
        const isFirstConditional = (j === 0)
        const isLastConditional = (j === iterations - 1)
        
        conditional = (isFirstConditional
            ? 'IF'
            : isLastConditional ? 'ELSE' : 'ELSIF'
        )
        bitwidthzeros = generateZeros(quantity, j)
        const isNotElse = (conditional !== 'ELSE') ? `(in0 = ${quotationbit}${bitwidthzeros.slice(-(quantity))}${quotationbit}) THEN` : ''
        
        output[j] = `${conditional}${isNotElse}\n`
        
        for (let p = 0; p < iterations; p++){
            output[j] += (p===j)
                ? `${generateSpacings(10)}out${j} <= '1';\n` 
                : `${generateSpacings(10)}out${p} <= '0';\n`
        }
    }

    return output.join(`${generateSpacings(9)}`)
}

export const generateLogicdlatch = () => {
    let output = [
        "IF(clock = '1') THEN",
        generateSpacings(10) + "q0 <= in0;",
        generateSpacings(10) + "q1 <= NOT in0;\n",
    ]
    return output.join('\n')
}

export const removeDuplicateComponent = (component) => {
    const setComponent = new Set();
        
    const filterComponent = component.filter((component) => {
        const duplicatedComponent = setComponent.has(component.identificator);
        setComponent.add(component.identificator)
        return !duplicatedComponent;
    });

    return filterComponent;
}

export const generateComponentHeader = (name, identificator) => {
    const regexComma = /,/g
    const component = [
        `\n  COMPONENT ${name}${identificator} IS\n`,
        generateSpacings(4),
        `PORT (\n`
    ]

    return component.toString().replace(regexComma, "")
}

export const generateHeaderPortmap = (component, index, acronym, identificator) => {
    return `\n  ${component}${index}: ${acronym}${identificator} PORT MAP (\n`
}

export const generatePortMapIOS = (type, objectIo) => {
    let ios = []
    
    objectIo.forEach((el, index) => {
        ios[index] = `    ${type}${index} => ${el.verilogLabel}`
    })
    
    return ios.join(',\n')
}

export const hasComponent = (component) => {
    if (component.length !== 0) {
        return true
    }
}

export const hasExtraPorts = (enable, preset, reset)  => {
    let output = ''

    output += hasComponent(enable) ? ', enable' : ''
    output += hasComponent(preset) ? ', preset' : ''
    output += hasComponent(reset) ? ', reset' : ''

    return output
}

export const generateLogicDFlipFlop = (dflipflopcomponent) => {
    const hasReset = (dflipflopcomponent.reset.connections.length > 0) ? true : false
    const hasEnable = (dflipflopcomponent.en.connections.length > 0) ? true : false
    const hasPreset = (dflipflopcomponent.preset.connections.length > 0) ? true : false
    const regexComma = /,/g
    let output = []

    if(hasReset && hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            q0 <= preset;\n`,
            `            q1 <= NOT preset;\n`,
            `          ELSE\n`,
            `            IF(enable = '1') THEN\n`,
            `              q0 <= inp;\n`,
            `              q1 <= NOT inp;\n`,
            `            ELSE\n`,
            `              q0 <= '0';\n`,
            `              q1 <= '1';\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && hasEnable && !hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF reset = '0' AND enable = '1' THEN\n`,
            `              q0 <= inp;\n`,
            `              q1 <= NOT inp;\n`,
            `          ELSE\n`,
            `              q0 <= '0';\n`,
            `              q1 <= '1';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            q0 <= preset;\n`,
            `            q1 <= NOT preset;\n`,
            `          ELSE\n`,
            `            q0 <= inp;\n`,
            `            q1 <= NOT inp;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (!hasReset && hasEnable) {
        output = [
            `IF clock'EVENT AND clock = '1' AND enable = '1' THEN\n`,
            `          q0 <= inp;\n`,
            `          q1 <= NOT inp;\n`,
            `        END IF;\n`
        ]
    } 
    else if (hasReset && !hasEnable && !hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF reset = '1' THEN\n`,
            `            q0 <= '0';\n`,
            `            q1 <= '1';\n`,
            `          ELSE\n`,
            `            q0 <= inp;\n`,
            `            q1 <= NOT inp;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    }
    else {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          q0 <= inp;\n`,
            `          q1 <= NOT inp;\n`,
            `        END IF;\n`
        ]
    }

    return output.join().replace(regexComma, '')
}

export const generateArchitetureHeaderTFlipFlop = (component, index)  => {
    const regexComma = /,/g
    const header = [
        `ARCHITECTURE rtl OF ${component}${index} IS\n`,
        generateSpacings(2),
        `SIGNAL tmp: STD_LOGIC := '0';\n`,
        generateSpacings(2),
        `BEGIN\n`,
    ]

    return header.toString().replace(regexComma, "")
}

export const generateLogicTFlipFlop = (tflipflopcomponent) => {
    const hasReset = (tflipflopcomponent.reset.connections.length > 0) ? true : false
    const hasEnable = (tflipflopcomponent.en.connections.length > 0) ? true : false
    const hasPreset = (tflipflopcomponent.preset.connections.length > 0) ? true : false
    const regexComma = /,/g
    let output = []

    if(hasReset && hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            tmp <= preset;\n`,
            `          ELSE\n`,
            `            IF(enable = '1') THEN\n`,
            `              IF inp = '0' THEN\n`,
            `                tmp <= tmp;\n`,
            `              ELSE\n`,
            `                tmp <= NOT tmp;\n`,
            `              END IF;\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && hasEnable && !hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF reset = '0' AND enable = '1' THEN\n`,
            `            IF inp = '0' THEN\n`,
            `              tmp <= tmp;\n`,
            `            ELSE\n`,
            `              tmp <= NOT tmp;\n`,
            `            END IF;\n`,
            `          ELSIF reset = '1' THEN\n`,
            `              tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            tmp <= preset;\n`,
            `          ELSE\n`,
            `            IF inp = '0' THEN\n`,
            `              tmp <= tmp;\n`,
            `            ELSE\n`,
            `              tmp <= NOT tmp;\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (!hasReset && hasEnable) {
        output = [
            `IF clock'EVENT AND clock = '1' AND enable = '1' THEN\n`,
            `          IF inp = '0' THEN\n`,
            `            tmp <= tmp;\n`,
            `          ELSE\n`,
            `            tmp <= NOT tmp;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF inp = '0' THEN\n`,
            `            tmp <= tmp;\n`,
            `          ELSE\n`,
            `            tmp <= NOT tmp;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    }

    return output.join().replace(regexComma, '')
}

export const generateLogicJKFlipFlop = (tflipflopcomponent) => {
    const hasReset = (tflipflopcomponent.reset.connections.length > 0) ? true : false
    const hasEnable = (tflipflopcomponent.en.connections.length > 0) ? true : false
    const hasPreset = (tflipflopcomponent.preset.connections.length > 0) ? true : false
    const regexComma = /,/g
    let output = []

    if(hasReset && hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            tmp <= preset;\n`,
            `          ELSE\n`,
            `            IF(enable = '1') THEN\n`,
            `              IF J = '1' AND K = '1' THEN\n`,
            `                tmp <= NOT tmp;\n`,
            `              ELSIF J = '1' AND K = '0' THEN\n`,
            `                tmp <= '1';\n`,
            `              ELSIF J = '0' AND K = '1' THEN\n`,
            `                tmp <= '0';\n`,
            `              END IF;\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`,

        ]
    } else if (hasReset && hasEnable && !hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF reset = '0' AND enable = '1' THEN\n`,
            `            IF J = '1' AND K = '1' THEN\n`,
            `              tmp <= NOT tmp;\n`,
            `            ELSIF J = '1' AND K = '0' THEN\n`,
            `              tmp <= '1';\n`,
            `            ELSIF J = '0' AND K = '1' THEN\n`,
            `              tmp <= '0';\n`,
            `            END IF;\n`,
            `          ELSIF reset = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF(reset = '1') THEN\n`,
            `            tmp <= preset;\n`,
            `          ELSE\n`,
            `            IF J = '1' AND K = '1' THEN\n`,
            `              tmp <= NOT tmp;\n`,
            `            ELSIF J = '1' AND K = '0' THEN\n`,
            `              tmp <= '1';\n`,
            `            ELSIF J = '0' AND K = '1' THEN\n`,
            `              tmp <= '0';\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (!hasReset && hasEnable) {
        output = [
            `IF clock'EVENT AND clock = '1' AND enable = '1' THEN\n`,
            `          IF J = '1' AND K = '1' THEN\n`,
            `            tmp <= NOT tmp;\n`,
            `          ELSIF J = '1' AND K = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF J = '0' AND K = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && !hasPreset) {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF reset = '0' THEN\n`,
            `            IF J = '1' AND K = '1' THEN\n`,
            `              tmp <= NOT tmp;\n`,
            `            ELSIF J = '1' AND K = '0' THEN\n`,
            `              tmp <= '1';\n`,
            `            ELSIF J = '0' AND K = '1' THEN\n`,
            `              tmp <= '0';\n`,
            `            END IF;\n`,
            `          ELSE\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else {
        output = [
            `IF clock'EVENT AND clock = '1' THEN\n`,
            `          IF J = '1' AND K = '1' THEN\n`,
            `            tmp <= NOT tmp;\n`,
            `          ELSIF J = '1' AND K = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF J = '0' AND K = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    }

    return output.join().replace(regexComma, '')
}

export const generateLogicSRFlipFlop = (srflipflopcomponent) => {
    const hasReset = (srflipflopcomponent.reset.connections.length > 0) ? true : false
    const hasEnable = (srflipflopcomponent.en.connections.length > 0) ? true : false
    const hasPreset = (srflipflopcomponent.preset.connections.length > 0) ? true : false
    const regexComma = /,/g
    let output = []

    if(hasReset && hasEnable && hasPreset) {
        output = [
            `IF(reset = '1') THEN\n`,
            `          tmp <= preset;\n`,
            `        ELSE\n`,
            `          IF(enable = '1') THEN\n`,
            `            IF S = '1' AND R = '0' THEN\n`,
            `              tmp <= '1';\n`,
            `            ELSIF S = '0' AND R = '1' THEN\n`,
            `              tmp <= '0';\n`,
            `            END IF;\n`,
            `          END IF;\n`,
            `        END IF;\n`,
        ]
    } else if (hasReset && hasEnable && !hasPreset) {
        output = [
            `IF reset = '0' AND enable = '1' THEN\n`,
            `          IF S = '1' AND R = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF S = '0' AND R = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        ELSIF reset = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && hasPreset) {
        output = [
            `IF(reset = '1') THEN\n`,
            `          tmp <= preset;\n`,
            `        ELSE\n`,
            `          IF S = '1' AND R = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF S = '0' AND R = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (!hasReset && hasEnable) {
        output = [
            `IF enable = '1' THEN\n`,
            `          IF S = '1' AND R = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF S = '0' AND R = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        END IF;\n`
        ]
    } else if (hasReset && !hasEnable && !hasPreset) {
        output = [
            `IF reset = '0' THEN\n`,
            `          IF S = '1' AND R = '0' THEN\n`,
            `            tmp <= '1';\n`,
            `          ELSIF S = '0' AND R = '1' THEN\n`,
            `            tmp <= '0';\n`,
            `          END IF;\n`,
            `        ELSE\n`,
            `          tmp <= '0';\n`,
            `        END IF;\n`
        ]
    } else {
        output = [
            `IF S = '1' AND R = '0' THEN\n`,
            `          tmp <= '1';\n`,
            `        ELSIF S = '0' AND R = '1' THEN\n`,
            `          tmp <= '0';\n`,
            `        END IF;\n`
        ]
    }

    return output.join().replace(regexComma, '')
}

export const generateLogicMSB = (quantity) => {
    let output = []
    
    output = [
        `${generateSpacings(4)}process (inp) is\n`,
        `${generateSpacings(6)}BEGIN\n`,
        `${generateSpacings(8)}enabled <= '0';\n`,
        `${generateSpacings(8)}FOR i IN ${quantity-1} DOWNTO 0 LOOP\n`,
        `${generateSpacings(10)}IF inp(i) = '1' THEN\n`,
        `${generateSpacings(12)}reset <= i;\n`,
        `${generateSpacings(12)}enabled <= '1';\n`,
        `${generateSpacings(12)}EXIT;\n`,
        `${generateSpacings(10)}END IF;\n`,
        `${generateSpacings(8)}END LOOP;\n`,
        `${generateSpacings(4)}END PROCESS;\n\n`,
        `${generateSpacings(4)}out1 <= std_logic_vector(to_unsigned(reset, out1'length));\n`
    ]

    return output.join('')
}

export const generateLogicLSB = (quantity) => {
    let output = []
    
    output = [
        `${generateSpacings(4)}process (inp) is\n`,
        `${generateSpacings(6)}BEGIN\n`,
        `${generateSpacings(8)}enabled <= '0';\n`,
        `${generateSpacings(8)}FOR i IN 0 TO ${quantity-1} LOOP\n`,
        `${generateSpacings(10)}IF inp(i) = '1' THEN\n`,
        `${generateSpacings(12)}reset <= i;\n`,
        `${generateSpacings(12)}enabled <= '1';\n`,
        `${generateSpacings(12)}EXIT;\n`,
        `${generateSpacings(10)}END IF;\n`,
        `${generateSpacings(8)}END LOOP;\n`,
        `${generateSpacings(4)}END PROCESS;\n\n`,
        `${generateSpacings(4)}out1 <= std_logic_vector(to_unsigned(reset, out1'length));\n`
    ]

    return output.join('')
}

export const generateLogicpriorityEncoder = (quantity) => {
    let output = []
    const initializeConditional = [
        `    PROCESS(${generatePortsIO('inp', quantity).replace('    ','') + ', enabled'})\n`,
        `    BEGIN\n`,
        `    IF enabled = '1' THEN\n`,
        `      IF `
    ]
    const finishConditional = `      END IF;\n    END IF;\n  END PROCESS;`

    for (let i = Math.pow(quantity, 2) - 1; i >= 0; i--) {
        output.push(`inp${i} = '1' THEN\n${assertOutput(i, quantity)}`);
    }

    return initializeConditional.join('') +  output.join("      ELSIF ").replace("ELSIF inp0 = '1' THEN", "ELSE") + finishConditional
}


export const assertOutput = (value, bitwidth) => {
    const valorBinario = value.toString(2).padStart(bitwidth, "0");
    let output = "";

    for (let i = 0; i < bitwidth; i++) {
        output += `        out${i} <= '${valorBinario[i]}';\n`;
    }

    return output;
}