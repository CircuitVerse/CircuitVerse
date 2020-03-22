var convert = function(src, output, from, to) {
    switch (from) {
        case "bin":
            document.getElementById(output).innerHTML = to === "dec" ? binToDec(src) : binToHex(src);
            break;            
        case "dec":
            document.getElementById(output).innerHTML = to === "bin" ? decToBin(src) : decToHex(src);
            break;
        case "hex":
            document.getElementById(output).innerHTML = to === "bin" ? hexToBin(src) : hexToDec(src);
            break;
    }
};

var binToDec = function(src) {
    
    var i;
    var n = 0;
    var srcString = src.toString();
    var returnNum = 0;
    
    for (i = srcString.length - 1; i >=0; i--) {
        returnNum += srcString[i] * 2 ** n;
        n++;
    }
    
    return returnNum;
    
};

var binToHex = function(src) {
    
    var mapping = {
        "0000" : "0",
        "0001" : "1",
        "0010" : "2",
        "0011" : "3",
        "0100" : "4",
        "0101" : "5",
        "0110" : "6",
        "0111" : "7",
        "1000" : "8",
        "1001" : "9",
        "1010" : "A",
        "1011" : "B",
        "1100" : "C",
        "1101" : "D",
        "1110" : "E",
        "1111" : "F"
    };
    
    var i;
    var srcString = src.toString();
    var returnString = "";
    var remainder = "";
    
    for (i = srcString.length; i >= 4; i -= 4) {
        if (i - 4 < srcString.length) {
            returnString = mapping[srcString.substr(i-4,4)] + returnString;
        }
    }
    
    if (i !== 0) {
        remainder = srcString.substr(0,i);
        
        while (remainder.length < 4) {
            remainder = "0" + remainder;
        }
        
        returnString = mapping[remainder] + returnString;
    }
    
    return returnString;
    
};

var decToBin = function(src) {
    
    var n = 0;
    var returnString = "";
    
    while (2 ** (n) < src) {
        n++;
    }
    
    for (n; n>=0; n--) {
        if (2 ** n <= src) {
            returnString += "1";
            src = src % 2 ** n;
        } else {
            returnString += returnString === "" ? "" : "0";
        }
    }
    
    return returnString;
    
};

var decToHex = function(src) {
    
    var mapping = {
        "0" : "0",
        "1" : "1",
        "2" : "2",
        "3" : "3",
        "4" : "4",
        "5" : "5",
        "6" : "6",
        "7" : "7",
        "8" : "8",
        "9" : "9",
        "10" : "A",
        "11" : "B",
        "12" : "C",
        "13" : "D",
        "14" : "E",
        "15" : "F"
    };
    
    var n = 0;
    var returnString = "";
    
    while (16 ** (n+1) < src) {
        n++;
    }
    
    for (n; n >= 0; n--) {
        if (16 ** n <= src) {
            returnString += mapping[Math.floor(src / 16 ** n).toString()];
            src = src - Math.floor(src / 16 ** n) * (16 ** n);
        } else {
            returnString += "0";
        }
    }
    
    return returnString;
    
};

var hexToBin = function(src) {
    
    var mapping = {
        "0" : "0000",
        "1" : "0001",
        "2" : "0010",
        "3" : "0011",
        "4" : "0100",
        "5" : "0101",
        "6" : "0110",
        "7" : "0111",
        "8" : "1000",
        "9" : "1001",
        "A" : "1010",
        "B" : "1011",
        "C" : "1100",
        "D" : "1101",
        "E" : "1110",
        "F" : "1111"
    };
    
    var srcString = src.toString();
    var i;
    var returnString = "";
    
    for (i = 0; i < srcString.length; i++) {
        returnString += mapping[srcString[i]];
    }
    
    return returnString;
    
};

var hexToDec = function(src) {
    
    var mapping = {
        "0" : "0",
        "1" : "1",
        "2" : "2",
        "3" : "3",
        "4" : "4",
        "5" : "5",
        "6" : "6",
        "7" : "7",
        "8" : "8",
        "9" : "9",
        "A" : "10",
        "B" : "11",
        "C" : "12",
        "D" : "13",
        "E" : "14",
        "F" : "15"
    };
    
    var srcString = src.toString();
    var returnNum = 0;
    var i;
    
    for (i = 0; i < srcString.length; i++) {
        returnNum += mapping[srcString[i]] * (16 ** (srcString.length -1 - i));
    }
    
    return returnNum;
    
};
