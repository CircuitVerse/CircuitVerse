

var inputSample = 5;
var dataSample=[['01---','11110','01---','00000'],['01110','1-1-1','----0'],['01---','11110','01110','1-1-1','0---0'],['----1']];

var sampleInputListNames=["A", "B"];
var sampleOutputListNames=["X"];

createCombinationalAnalysisPrompt=function(scope=globalScope){
    //console.log("Ya");
    scheduleBackup();
    $('#combinationalAnalysis').empty();
    $('#combinationalAnalysis').append("<p>Enter Input names separated by commas: <input id='inputNameList' type='text'  placeHolder='eg. In A, In B'></p>");
    $('#combinationalAnalysis').append("<p>Enter Output names separated by commas: <input id='outputNameList' type='text'  placeHolder='eg. Out X, Out Y'></p>");
    $('#combinationalAnalysis').append("<p>Do you need a decimal column? <input id='decimalColumnBox' type='checkbox'></p>");
    $('#combinationalAnalysis').dialog({
        width:"auto",
      buttons: [
        {
          text: "Next",
          click: function() {
            // //console.log($("#inputNameList"),$("#inputNameList").val(),$("#inputNameList").html());
            var inputList=$("#inputNameList").val().split(',');
            var outputList=$("#outputNameList").val().split(',');
            inputList = inputList.map( x => x.trim() );
            outputList = outputList.map( x => x.trim() );
            $( this ).dialog( "close" );
            createBooleanPrompt(inputList,outputList,scope);
        },
        }
      ]
    });

}
function createBooleanPrompt(inputListNames,outputListNames,scope=globalScope){

    inputListNames=inputListNames||(prompt("Enter inputs separated by commas").split(','));
    outputListNames=outputListNames||(prompt("Enter outputs separated by commas").split(','));
    outputListNamesInteger=[];
    for (var i = 0; i < outputListNames.length; i++)
        outputListNamesInteger[i] = 7*i + 13;//assigning an integer to the value, 7*i + 13 is random

    var s='<table>';
    s+='<tbody style="display:block; max-height:70vh; overflow-y:scroll" >';
    s+='<tr>';
    if($("#decimalColumnBox").is(":checked"))
        s+='<th>'+'dec'+'</th>';
    for(var i=0;i<inputListNames.length;i++)
        s+='<th>'+inputListNames[i]+'</th>';
    for(var i=0;i<outputListNames.length;i++)
        s+='<th>'+outputListNames[i]+'</th>';
    s+='</tr>';

    var matrix = [];
    for(var i=0; i<inputListNames.length; i++) {
        matrix[i] = new Array((1<<inputListNames.length));
    }

    for(var i=0;i<inputListNames.length;i++){
        for(var j=0;j<(1<<inputListNames.length);j++){
            matrix[i][j]=(+((j&(1<<(inputListNames.length-i-1)))!=0));
        }
    }

    for(var j=0;j<(1<<inputListNames.length);j++){
        s+='<tr>';
        if($("#decimalColumnBox").is(":checked"))
            s+='<td>'+j+'</td>';
        for(var i=0;i<inputListNames.length;i++){
            s+='<td>'+matrix[i][j]+'</td>';
        }
        for(var i=0;i<outputListNamesInteger.length;i++){
            s+='<td class ="output '+outputListNamesInteger[i]+'" id="'+j+'">'+'x'+'</td>';
            //using hash values as they'll be used in the generateBooleanTableData function
        }
        s+='</tr>';
    }
    s+='</tbody>';
    s+='</table>';
    //console.log(s)
    $('#combinationalAnalysis').empty()
    $('#combinationalAnalysis').append(s)
    $('#combinationalAnalysis').dialog({
        width:"auto",
      buttons: [
        {
          text: "Generate Circuit",
          click: function() {
            $( this ).dialog( "close" );
            var data = generateBooleanTableData(outputListNamesInteger);
            //passing the hash values to avoid spaces being passed which is causing a problem
            minmizedCircuit = [];
            for(let output in data){
                let temp = new BooleanMinimize(
                    inputListNames.length,
                    data[output][1].map(Number),
                    data[output]['x'].map(Number)
                )
                minmizedCircuit.push(temp.result);
            }
            // //console.log(dataSample);
            drawCombinationalAnalysis(minmizedCircuit,inputListNames,outputListNames,scope)
        },

        }
      ]
    });

    $('.output').click(function (){
        var v=$(this).html();
        if(v==0)v=$(this).html(1);
        else if(v==1)v=$(this).html('x');
        else if(v=='x')v=$(this).html(0);
    })
}

function generateBooleanTableData(outputListNames){
    var data={};
    for(var i=0;i<outputListNames.length;i++){
        data[outputListNames[i]]={
            'x':[],
            '1':[],
            '0':[],
        }
        $rows=$('.'+outputListNames[i]);
        for(j=0;j<$rows.length;j++){
            //console.log($rows[j].innerHTML)
            data[outputListNames[i]][$rows[j].innerHTML].push($rows[j].id);
        }

    }
    //console.log(data);
    return data;
}

function drawCombinationalAnalysis(combinationalData,inputList,outputListNames,scope=globalScope){

    //console.log(combinationalData);
    var inputCount=inputList.length;
    var maxTerms=0;
    for(var i=0;i<combinationalData.length;i++)
    maxTerms=Math.max(maxTerms,combinationalData[i].length);

    var startPosX=200;
    var startPosY=200;

    var currentPosY=300;
    var andPosX=startPosX+inputCount*40+40;
    var orPosX=andPosX+Math.floor(maxTerms/2)*10+80;
    var outputPosX=orPosX+60;
    var inputObjects=[];

    var logixNodes=[];

    for(var i=0;i<inputCount;i++){
        inputObjects.push(new Input(startPosX+i*40,startPosY,scope,"DOWN",1));
        inputObjects[i].setLabel(inputList[i]);
        inputObjects[i].newLabelDirection("UP");
        var v1=new Node(startPosX+i*40,startPosY+20,2,scope.root);
        inputObjects[i].output1.connect(v1);
        var v2=new Node(startPosX+i*40+20,startPosY+20,2,scope.root);
        v1.connect(v2);
        var notG=new NotGate(startPosX+i*40+20, startPosY+40, scope, "DOWN",  1);
        notG.inp1.connect(v2);
        logixNodes.push(v1);
        logixNodes.push(notG.output1);
    }

    function countTerm(s){
        var c=0;
        for(var i=0;i<s.length;i++)
            if(s[i]!=='-')c++;
        return c;
    }

    for(var i=0;i<combinationalData.length;i++){
        // //console.log(combinationalData[i]);
        var andGateNodes=[];
        for(var j=0;j<combinationalData[i].length;j++){

            var c=countTerm(combinationalData[i][j]);
            if(c>1){
                var andGate=new AndGate(andPosX, currentPosY, scope, "RIGHT", c, 1);
                andGateNodes.push(andGate.output1);
                var misses=0;
                for(var k=0;k<combinationalData[i][j].length;k++){
                    if(combinationalData[i][j][k]=='-'){misses++;continue;}
                    var index=2*k+(combinationalData[i][j][k]==0);
                    //console.log(index);
                    //console.log(andGate);
                    var v=new Node(logixNodes[index].absX(),andGate.inp[k-misses].absY(),2,scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index]=v;
                    v.connect(andGate.inp[k-misses]);
                }
            }
            else{
                for(var k=0;k<combinationalData[i][j].length;k++){
                    if(combinationalData[i][j][k]=='-')continue;
                    var index=2*k+(combinationalData[i][j][k]==0);
                    var andGateSubstituteNode= new Node(andPosX, currentPosY, 2,scope.root);
                    var v=new Node(logixNodes[index].absX(),andGateSubstituteNode.absY(),2,scope.root);
                    logixNodes[index].connect(v);
                    logixNodes[index]=v;
                    v.connect(andGateSubstituteNode);
                    andGateNodes.push(andGateSubstituteNode);
                }
            }
            currentPosY+=c*10+30;
        }

        var andGateCount=andGateNodes.length;
        var midWay=Math.floor(andGateCount/2);
        var orGatePosY=(andGateNodes[midWay].absY()+andGateNodes[Math.floor((andGateCount-1)/2)].absY())/2;
        if( orGatePosY%10 == 5)
            orGatePosY += 5; // To make or gate fall in grid
        if(andGateCount>1){

            var o=new OrGate(orPosX,orGatePosY,scope,"RIGHT",andGateCount,1);
            if(andGateCount%2==1)andGateNodes[midWay].connect(o.inp[midWay]);
            for(var j=0;j<midWay;j++){
                var v=new Node(andPosX+30+(midWay-j)*10,andGateNodes[j].absY(),2,scope.root);
                v.connect(andGateNodes[j]);
                var v2=new Node(andPosX+30+(midWay-j)*10,o.inp[j].absY(),2,scope.root);
                v2.connect(v)
                o.inp[j].connect(v2);

                var v=new Node(andPosX+30+(midWay-j)*10,andGateNodes[andGateCount-j-1].absY(),2,scope.root);
                v.connect(andGateNodes[andGateCount-j-1]);
                var v2=new Node(andPosX+30+(midWay-j)*10,o.inp[andGateCount-j-1].absY(),2,scope.root);
                v2.connect(v)
                o.inp[andGateCount-j-1].connect(v2);
            }
            var out=new Output(outputPosX,o.y,scope,"LEFT",1);
            out.inp1.connect(o.output1);
        }
        else{

            var out=new Output(outputPosX,andGateNodes[0].absY(),scope,"LEFT",1);
            out.inp1.connect(andGateNodes[0]);
        }
        out.setLabel(outputListNames[i]);
        out.newLabelDirection("RIGHT");


    }
    for(var i=0;i<logixNodes.length;i++){
        if(logixNodes[i].absY()!=currentPosY){
            var v=new Node(logixNodes[i].absX(),currentPosY,2,scope.root);
            logixNodes[i].connect(v)
        }
    }

}
