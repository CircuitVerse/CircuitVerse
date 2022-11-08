export const generateSpacings = (spaceLength) => {
    const spacement = new Array(spaceLength).fill(' ')

    const regexComma = /,/g
    return spacement.join().replace(regexComma, '')
}

export const generateHeaderVhdlEntity = (component, index) => {
    const header = [
    `\n//-------------${component}${index}-------------\n`,
    'library IEEE;\n',
    'use IEEE.std_logic_1164.all;\n',
    `\nENTITY ${component}${index} IS\n`,
    generateSpacings(2),
    'PORT (\n',
    ]

    const regexComma = /,/g
    parseHeader = header.toString().replace(regexComma, "")

    return parseHeader
}

export const generatePortsIO = (type, idx) => {
    const portsQuantity = Math.pow(2, idx)
    let portsArray = []
    const isOnePort = idx === 0
    
    for(var i = 0; i < portsQuantity; i++){
        isOnePort
        ? portsArray[i] = `${type}`
        : portsArray[i] = `${type}${i}`
    }

    return generateSpacings(4) + portsArray.join(', ')
}

export const generateSTDType = (type, width) => {
    return (width !== 1)
    ? `: ${type} STD_LOGIC_VECTOR (${width - 1} DOWNTO 0);\n`
    : `: ${type} STD_LOGIC;\n`
}

export const generateFooterEntity = () => {
    const footer = [
            generateSpacings(2),
            `);\n`,
            `END ENTITY;\n`,
            `\n`,
        ]
    
        const regexComma = /,/g
        parseFooter = footer.toString().replace(regexComma, "")
    
        return parseFooter
}

export const generateArchitetureHeader = (component, index)  => {
    const header = [
        `ARCHITECTURE rtl OF ${component}${index} IS\n`,
        generateSpacings(2),
        `BEGIN\n`,
    ]

    const regexComma = /,/g
    parseHeader = header.toString().replace(regexComma, "")

    return parseHeader
}

export const generateZeros = (quantity, position) => {
    let zeros = ''
    
    for(var i = 0; i < quantity; i++){
        zeros += '0'
    }

    return zeros + position.toString(2)
}

export const generateLogicMux = (quantity) => {
    let output = []
    let quotationmark = ''

    quotationmark = (quantity > 1) ? '"' : "'"
    
    for (var j = 0; j < Math.pow(2,quantity); j++) {
        var k = generateZeros(quantity, j)
        output[j] = `in${j} WHEN ${quotationmark}${k.slice(-(quantity))}${quotationmark}`
    }

    return output.join(`,\n${generateSpacings(9)}`)
}

export const generateLogicDemux = (quantity, bitwidth) => {
    let output = []
    const quotationcontrol = (quantity > 1) ? '"' : "'"
    const quotationbit = (bitwidth > 1) ? '"' : "'"
    const iterations = Math.pow(2,quantity)
    
    for (var j = 0; j < iterations; j++) {
        const isFirstConditional = (j === 0)
        const isLastConditional = (j === iterations - 1)
        let conditional = (isFirstConditional
            ? 'IF'
            : isLastConditional 
                ? 'ELSE' 
                : 'ELSIF'
        )
        var controlsignalnumber = generateZeros(quantity, j)
        var bitwidthzeros = generateZeros(bitwidth-1, 0)
        const isNotElse = (conditional !== 'ELSE') ? `(sel = ${quotationcontrol}${controlsignalnumber.slice(-(quantity))}${quotationcontrol}) THEN` : ''
        
        output[j] = `${conditional}${isNotElse}\n`
        
        for (var p = 0; p < iterations; p++){
            output[j] += (p===j)
                ? output[j] += `${generateSpacings(10)}out${j} <= in0;\n` 
                : output[j] += `${generateSpacings(10)}out${p} <= ${quotationbit}${bitwidthzeros.slice(-(bitwidth))}${quotationbit};\n`
        }
    }

    return output.join(`${generateSpacings(9)}`)
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
    const component = [
        `\n  COMPONENT ${name}${identificator} IS\n`,
        generateSpacings(4),
        `PORT (\n`
    ]

    const regexComma = /,/g
    parseComponent = component.toString().replace(regexComma, "")

    return parseComponent
}