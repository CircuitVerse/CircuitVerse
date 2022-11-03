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

    return portsArray.join(', ')
}

export const generateSTDType = (width) => {
    return (width !== 1)
    ? `: IN STD_LOGIC_VECTOR (${width - 1} DOWNTO 0);\n`
    : `: IN STD_LOGIC;\n`
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
        generateSpacings(4),
        `WITH sel SELECT\n`,
        generateSpacings(4),
        `x <= `,
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