// Function to create new circuit
// Function creates button in tab, creates scope and switches to this circuit
function newCircuit(name, id) {
    name = name || prompt("Enter circuit name:");
    name = stripTags(name);
    if (!name) return;
    var scope = new Scope(name);
    if (id) scope.id = id;
    scopeList[scope.id] = scope;
    globalScope = scope;
    var $windowsize = $('body').width();
    var $sideBarsize = $('.side').width();
    var $maxwidth = ($windowsize - $sideBarsize);
    var resizer = "max-width:" + ($maxwidth - 30);
    $('.circuits').removeClass("current");
    $('#tabsBar').append("<a href = '#' data-toggle = 'tooltip' title='" + name + "'><div class='circuits toolbarButton current' id='" + scope.id + "' style='" + resizer + "'>" + name + "<span class ='tabsCloseButton' onclick='deleteCurrentCircuit()'  ><i class='fa fa-times'></i></span></div></a>");
    $('.circuits').click(function() {
        switchCircuit(this.id)
    });
    if (!embed) {
        showProperties(scope.root);
    }

    dots(true, false);

    return scope;
}


function changeCircuitName(name, id = globalScope.id) {
    name = name || "Untitled";
    name = stripTags(name);
    $('#' + id).html(name + "<span class ='tabsCloseButton' onclick='deleteCurrentCircuit()'  ><i class='fa fa-times'></i></span>");
    scopeList[id].name = name;
}

function setProjectName(name) {
    name = stripTags(name);
    projectName = name;
    $('#projectName').html(name);
}

function clearProject() {
    if (confirm("Would you like to clear the project?")){
    globalScope = undefined;
    scopeList = {};
    $('.circuits').remove();
    newCircuit("main");
    showMessage("Your project is as good as new!");
    }
}

// Function used to start a new project while prompting confirmation from the user
function newProject(verify) {

    if (verify || projectSaved || !checkToSave() || confirm("What you like to start a new project? Any unsaved changes will be lost.")) {
        clearProject();
        localStorage.removeItem("recover");
        window.location = "/simulator";

        projectName = undefined;
        projectId = generateId();
        showMessage("New Project has been created!");
    }

}

// Helper function used to generate SVG - only used for internal purposes to generate the icons
function generateSvg() {
    resolution = 1;
    view = "full"

    var backUpOx = globalScope.ox;
    var backUpOy = globalScope.oy;
    var backUpWidth = width
    var backUpHeight = height;
    var backUpScale = globalScope.scale;
    backUpContextBackground = backgroundArea.context;
    backUpContextSimulation = simulationArea.context;
    backgroundArea.context = simulationArea.context;
    globalScope.ox *= resolution / backUpScale;
    globalScope.oy *= resolution / backUpScale;

    globalScope.scale = resolution;

    var scope = globalScope;

    if (view == "full") {
        var minX = 10000000;
        var minY = 10000000;
        var maxX = -10000000;
        var maxY = -10000000;
        var maxDimension = 0;
        for (var i = 0; i < updateOrder.length; i++)
            for (var j = 0; j < scope[updateOrder[i]].length; j++) {
                if (scope[updateOrder[i]][j].objectType !== "Wire") {
                    minX = Math.min(minX, scope[updateOrder[i]][j].absX());
                    maxX = Math.max(maxX, scope[updateOrder[i]][j].absX());
                    minY = Math.min(minY, scope[updateOrder[i]][j].absY());
                    maxY = Math.max(maxY, scope[updateOrder[i]][j].absY());
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].leftDimensionX)
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].rightDimensionX)
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].upDimensionY)
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].downDimensionY)
                }
            }

        // width = (maxX - minX + 60) * resolution;
        // height = (maxY - minY + 60) * resolution;
        //
        // globalScope.ox = (-minX + maxDimension+11)*resolution;
        // globalScope.oy = (-minY + maxDimension-6)*resolution;
        width = (maxX - minX + 2 * maxDimension + 10) * resolution;
        height = (maxY - minY + 2 * maxDimension + 10) * resolution;

        globalScope.ox = (-minX + maxDimension + 5) * resolution;
        globalScope.oy = (-minY + maxDimension + 5) * resolution;
    } else {
        width = (width * resolution) / backUpScale;
        height = (height * resolution) / backUpScale;
    }
    globalScope.ox = Math.round(globalScope.ox);
    globalScope.oy = Math.round(globalScope.oy);

    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;
    simulationArea.context = new C2S(width, height);
    backgroundArea.context = simulationArea.context;

    simulationArea.clear();


    for (var i = 0; i < updateOrder.length; i++)
        for (var j = 0; j < scope[updateOrder[i]].length; j++)
            scope[updateOrder[i]][j].draw();

    var mySerializedSVG = simulationArea.context.getSerializedSvg(); //true here, if you need to convert named to numbered entities.
    download("test.svg", mySerializedSVG);
    width = backUpWidth
    height = backUpHeight
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;
    globalScope.scale = backUpScale;
    backgroundArea.context = backUpContextBackground;
    simulationArea.context = backUpContextSimulation;
    globalScope.ox = backUpOx
    globalScope.oy = backUpOy;

    updateSimulation = true;
    updateCanvas = true;
    scheduleUpdate();
    dots(true, false);

}

// Function used to change the current focusedCircuit
// Disables layoutMode if enabled
// Changes UI tab etc
// Sets flags to make updates, resets most of the things

function switchCircuit(id) {

    if (layoutMode)
        toggleLayoutMode();

    // globalScope.fixLayout();
    scheduleBackup();
    if (id == globalScope.id) return;
    $('#' + globalScope.id).removeClass("current");
    $('#' + id).addClass("current");
    simulationArea.lastSelected = undefined;
    simulationArea.multipleObjectSelections = [];
    simulationArea.copyList = [];
    globalScope = scopeList[id];
    updateSimulation = true;
    updateSubcircuit = true;
    forceResetNodes = true;
    dots(true, false);
    simulationArea.lastSelected = globalScope.root;
    if (!embed) {
        showProperties(simulationArea.lastSelected);
    }
    updateCanvas=true;
    scheduleUpdate();

    // to update the restricted elements information
    updateRestrictedElementsList();
}

// Helper function to save canvas as image based on image type
function downloadAsImg(name, imgType) {

    var gh = simulationArea.canvas.toDataURL('image/' + imgType);
    var anchor = document.createElement('a');
    anchor.href = gh;
    anchor.download = name + '.' + imgType;
    anchor.click()

}

// Function to restore copy from backup
function undo(scope = globalScope) {
    if(layoutMode)return;
    if (scope.backups.length == 0) return;
    var backupOx = globalScope.ox;
    var backupOy = globalScope.oy;
    var backupScale = globalScope.scale;
    globalScope.ox = 0;
    globalScope.oy = 0;
    var tempScope = new Scope(scope.name);
    loading = true;
    loadScope(tempScope, JSON.parse(scope.backups.pop()));
    tempScope.backups = scope.backups;
    tempScope.id = scope.id;
    tempScope.name = scope.name;
    scopeList[scope.id] = tempScope;
    globalScope = tempScope;
    globalScope.ox = backupOx;
    globalScope.oy = backupOy;
    globalScope.scale = backupScale;
    loading = false;
    forceResetNodes = true;

    // Updated restricted elements
    updateRestrictedElementsInScope();
}

//helper fn
function extract(obj) {
    return obj.saveObject();
}

// Check if there is anything to backup - to be deprecated
function checkIfBackup(scope) {
    for (var i = 0; i < updateOrder.length; i++)
        if (scope[updateOrder[i]].length) return true;
    return false;
}

// Function that should backup if there is a change, otherwise ignore
function scheduleBackup(scope = globalScope) {

    var backup = JSON.stringify(backUp(scope));
    if (scope.backups.length == 0 || scope.backups[scope.backups.length - 1] != backup) {
        scope.backups.push(backup);
        scope.timeStamp = new Date().getTime();
        projectSaved = false;
    }

    return backup;
}

// Random ID generator
function generateId() {
    var id = "";
    var possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789";

    for (var i = 0; i < 20; i++)
        id += possible.charAt(Math.floor(Math.random() * possible.length));

    return id;
}

//fn to create save data of a specific circuit
function backUp(scope = globalScope) {

    // Disconnection of subcircuits are needed because these are the connections between nodes
    // in current scope and those in the subcircuit's scope
    for (let i = 0; i < scope.SubCircuit.length; i++)
        scope.SubCircuit[i].removeConnections();

    var data = {};

    // Storing layout
    data["layout"] = scope.layout;

    // Storing all nodes
    data["allNodes"] = scope.allNodes.map(extract);

    // Storing other details
    data["id"] = scope.id;
    data["name"] = scope.name;

    // Storing details of all module objects
    for (var i = 0; i < moduleList.length; i++) {
        if (scope[moduleList[i]].length)
            data[moduleList[i]] = scope[moduleList[i]].map(extract);
    }

    // Adding restricted circuit elements used in the save data
    data["restrictedCircuitElementsUsed"] = scope.restrictedCircuitElementsUsed;

    // Storing intermediate nodes (nodes in wires)
    data["nodes"] = []
    for (var i = 0; i < scope.nodes.length; i++)
        data["nodes"].push(scope.allNodes.indexOf(scope.nodes[i]));

    // Restoring the connections
    for (let i = 0; i < scope.SubCircuit.length; i++)
        scope.SubCircuit[i].makeConnections();

    return data
}

// Generating the order in which the circuits should be stored so that they can be loaded correctly
// POSET, Finish times
function generateDependencyOrder() {
    var dependencyList = {};
    var completed = {};
    for (id in scopeList)
        dependencyList[id] = scopeList[id].getDependencies();

    function saveScope(id) {
        if (completed[id]) return;
        for (var i = 0; i < dependencyList[id].length; i++)
            saveScope(dependencyList[id][i]);
        completed[id] = true;
        data.scopes.push(id);
    }
}

// Deletes the current circuit
// Ensures that at least one circuit is there
// Ensures that no circuit depends on the current circuit
// Switched to a random circuit

function deleteCurrentCircuit() {
    if (Object.keys(scopeList).length <= 1) {
        showError("At least 2 circuits need to be there in order to delete a circuit.")
        return;
    }
    var dependencies = "";
    for (id in scopeList) {
        if (id != globalScope.id && scopeList[id].checkDependency(globalScope.id)) {
            if (dependencies == "")
                dependencies = scopeList[id].name
            else
                dependencies += ", " + scopeList[id].name
        }

    }
    if (dependencies) {
        dependencies = "\nThe following circuits are depending on '" + globalScope.name + "': " + dependencies + "\nDelete subcircuits of " + globalScope.name + " before trying to delete " + globalScope.name
        alert(dependencies)
        return;
    }

    var confirmation = confirm("Are you sure want to delete: " + globalScope.name + "\nThis cannot be undone.");
    if (confirmation) {
        $('#' + globalScope.id).remove()
        delete scopeList[globalScope.id]
        switchCircuit(Object.keys(scopeList)[0])
        showMessage("Circuit was successfully deleted")
    } else
        showMessage("Circuit was not deleted")
}

// Generates JSON of the entire project
function generateSaveData(name) {

    data = {};

    // Prompts for name, defaults to Untitled
    name = projectName || name || prompt("Enter Project Name:") || "Untitled";
    data["name"] = stripTags(name)
    projectName = data["name"];
    setProjectName(projectName)

    // Save project details
    data["timePeriod"] = simulationArea.timePeriod;
    data["clockEnabled"] = simulationArea.clockEnabled;
    data["projectId"] = projectId;
    data["focussedCircuit"] = globalScope.id;

    // Project Circuits, each scope is one circuit
    data.scopes = []
    var dependencyList = {};
    var completed = {};

    // Getting list of dependencies for each circuit
    for (id in scopeList)
        dependencyList[id] = scopeList[id].getDependencies();

    // Helper function to save Scope
    // Recursively saves inner subcircuits first, before saving parent circuits
    function saveScope(id) {

        if (completed[id]) return;

        for (var i = 0; i < dependencyList[id].length; i++) // Save inner subcircuits
            saveScope(dependencyList[id][i]);

        completed[id] = true;

        update(scopeList[id], true); // For any pending integrity checks on subcircuits

        data.scopes.push(backUp(scopeList[id]));

    }

    // Save all circuits
    for (id in scopeList)
        saveScope(id);

    //convert to text
    data = JSON.stringify(data);
    return data;
}

// Function that is used to save image for display in the website
function generateImageForOnline() {

    simulationArea.lastSelected = undefined; // Unselect any selections

    // Fix aspect ratio to 1.6
    if (width > height * 1.6) {
        height = width / 1.6;
    } else {
        width = height * 1.6;
    }

    // Center circuits
    globalScope.centerFocus();

    // Ensure image is approximately 700 x 440
    resolution = Math.min(700 / (simulationArea.maxWidth - simulationArea.minWidth), 440 / (simulationArea.maxHeight - simulationArea.minHeight));

    data = generateImage("jpeg", "current", false, resolution, false);

    // Restores Focus
    globalScope.centerFocus(false);
    return data;
}

// Function to save data online
function save() {
    projectSaved = true;

    $('.loadingIcon').fadeIn();
    var data = generateSaveData();

    if (!userSignedIn) {
        // user not signed in, save locally temporarily and force user to sign in
        localStorage.setItem("recover_login", data);
        // Asking user whether they want to login.
        if(confirm("You have to login to save the project, you will be redirected to the login page.")) window.location.href = "/users/sign_in";
        else $('.loadingIcon').fadeOut();
    } else if (logix_project_id == 0) {

        // Create new project - this part needs to be improved and optimised
        var form = $("<form/>", {
            action: '/simulator/create_data',
            method: "post"
        });
        form.append(
            $("<input>", {
                type: 'hidden',
                name: 'authenticity_token',
                value: $('meta[name="csrf-token"]').attr('content')
            })
        );
        form.append(
            $("<input>", {
                type: 'text',
                name: 'data',
                value: data
            })
        );
        form.append(
            $("<input>", {
                type: 'text',
                name: 'image',
                value: generateImageForOnline()
            })
        );

        form.append(
            $("<input>", {
                type: 'text',
                name: 'name',
                value: projectName,
            })
        );

        $('body').append(form);
        form.submit();
    } else {

        // updates project - this part needs to be improved and optimised
        $.ajax({
            url: '/simulator/update_data',
            type: 'POST',
            beforeSend: function(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
            },
            data: {
                "data": data,
                "id": logix_project_id,
                "image": generateImageForOnline(),
                name: projectName
            },
            success: function(response) {
                showMessage("We have saved your project: " + projectName + " in our servers.")
                $('.loadingIcon').fadeOut();
                localStorage.removeItem("recover");
            },
            failure: function(err) {
                showMessage("There was an error, we couldn't save to our servers")
                $('.loadingIcon').fadeOut();
            }
        });
    }

    // Restore everything
    resetup();

}

// Function to load project from data
function load(data) {

    // If project is new and no data is there, then just set project name
    if (!data) {
        setProjectName(projectName)
        return;
    }

    projectId = data.projectId;
    projectName = data.name;

    if (data.name == "Untitled")
        projectName = undefined;
    else
        setProjectName(data.name);

    globalScope = undefined;
    scopeList = {}; // Remove default scope
    $('.circuits').remove(); // Delete default scope

    // Load all circuits according to the dependency order
    for (var i = 0; i < data.scopes.length; i++) {

        // Create new circuit
        var scope = newCircuit(data.scopes[i].name || "Untitled", data.scopes[i].id);

        // Load circuit data
        loadScope(scope, data.scopes[i]);

        // Focus circuit
        globalScope = scope;

        // Center circuit
        if (embed)
            globalScope.centerFocus(true);
        else
            globalScope.centerFocus(false);

        // update and backup circuit once
        update(globalScope, true);

        // Updating restricted element list initially on loading
        updateRestrictedElementsInScope();

        scheduleBackup();

    }

    // Restore clock
    simulationArea.changeClockTime(data["timePeriod"] || 500);
    simulationArea.clockEnabled = data["clockEnabled"] == undefined ? true : data["clockEnabled"];


    if (!embed)
        showProperties(simulationArea.lastSelected)

    // Switch to last focussedCircuit
    if (data["focussedCircuit"]) switchCircuit(data["focussedCircuit"])


    updateSimulation = true;
    updateCanvas = true;
    gridUpdate = true
    scheduleUpdate();


}

// Backward compatibility - needs to be deprecated
function rectifyObjectType(obj) {

    var rectify = {
        "FlipFlop": "DflipFlop",
        "Ram": "Rom"
    };
    return rectify[obj] || obj;

}

// Function to load CircuitElements
function loadModule(data, scope) {

    // Create circuit element
    var obj = new window[rectifyObjectType(data["objectType"])](data["x"], data["y"], scope, ...data.customData["constructorParamaters"] || []);

    // Sets directions
    obj.label = data["label"];
    obj.labelDirection = data["labelDirection"] || oppositeDirection[fixDirection[obj.direction]];

    // Sets delay
    obj.propagationDelay = data["propagationDelay"] || obj.propagationDelay;
    obj.fixDirection();

    // Restore other values
    if (data.customData["values"])
        for (prop in data.customData["values"]) {
            obj[prop] = data.customData["values"][prop];
        }

    // Replace new nodes with the correct old nodes (with connections)
    if (data.customData["nodes"])
        for (node in data.customData["nodes"]) {
            var n = data.customData["nodes"][node]
            if (n instanceof Array) {
                for (var i = 0; i < n.length; i++) {
                    obj[node][i] = replace(obj[node][i], n[i]);
                }
            } else {
                obj[node] = replace(obj[node], n);
            }
        }

}

// Helper function to download text
function download(filename, text) {
    var pom = document.createElement('a');
    pom.setAttribute('href', 'data:text/plain;charset=utf-8,' + encodeURIComponent(text));
    pom.setAttribute('download', filename);


    if (document.createEvent) {
        var event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    } else {
        pom.click();
    }
}

// Function to load a full circuit
function loadScope(scope, data) {

    var ML = moduleList.slice(); // Module List copy
    scope.restrictedCircuitElementsUsed = data["restrictedCircuitElementsUsed"];

    // Load all nodes
    data["allNodes"].map(function(x) {
        return loadNode(x, scope)
    });

    // Make all connections
    for (var i = 0; i < data["allNodes"].length; i++)
        constructNodeConnections(scope.allNodes[i], data["allNodes"][i]);

    // Load all modules
    for (var i = 0; i < ML.length; i++) {
        if (data[ML[i]]) {

            if (ML[i] == "SubCircuit") {
                // Load subcircuits differently
                for (var j = 0; j < data[ML[i]].length; j++)
                    loadSubCircuit(data[ML[i]][j], scope);

            } else {

                // Load everything else similarly
                for (var j = 0; j < data[ML[i]].length; j++) {
                    loadModule(data[ML[i]][j], scope);
                }

            }
        }
    }

    // Update wires according

    scope.wires.map(function(x) {
        x.updateData(scope)
    });

    removeBugNodes(scope); // To be deprecated

    // If layout exists, then restore
    if (data["layout"])
        scope.layout = data["layout"]

    // Else generate new layout according to how it would have been otherwise (backward compatibility)
    else {
        scope.layout = {}
        scope.layout.width = 100;
        scope.layout.height = Math.max(scope.Input.length, scope.Output.length) * 20 + 20;
        scope.layout.title_x = 50;
        scope.layout.title_y = 13;
        for (var i = 0; i < scope.Input.length; i++) {
            scope.Input[i].layoutProperties = {
                x: 0,
                y: scope.layout.height / 2 - scope.Input.length * 10 + 20 * i + 10,
                id: generateId()
            }
        }
        for (var i = 0; i < scope.Output.length; i++)
            scope.Output[i].layoutProperties = {
                x: scope.layout.width,
                y: scope.layout.height / 2 - scope.Output.length * 10 + 20 * i + 10,
                id: generateId()
            }
    }

    // Backward compatibility
    if(scope.layout.titleEnabled==undefined)
        scope.layout.titleEnabled=true;

}


// This fn shouldn't ideally exist. But temporary fix
function removeBugNodes(scope = globalScope) {
    var x = scope.allNodes.length
    for (var i = 0; i < x; i++) {
        if (scope.allNodes[i].type != 2 && scope.allNodes[i].parent.objectType == "CircuitElement")
            scope.allNodes[i].delete();
        if (scope.allNodes.length != x) {
            i = 0;
            x = scope.allNodes.length;
        }
    }
}

// Helper function to show prompt to save image
// Options - resolution, image type, view
createSaveAsImgPrompt = function(scope = globalScope) {
    $('#saveImageDialog').dialog({
        width: "auto",
        buttons: [{
            text: "Render Circuit Image",
            click: function() {
                generateImage($('input[name=imgType]:checked').val(), $('input[name=view]:checked').val(), $('input[name=transparent]:checked').val(), $('input[name=resolution]:checked').val());
                $(this).dialog("close");
            },
        }]

    });
    $("input[name=imgType]").change(function() {
        $('input[name=resolution]').prop("disabled", false);
        $('input[name=transparent]').prop("disabled", false);
        var imgType = $('input[name=imgType]:checked').val();
        if (imgType == 'svg') {
            $('input[name=resolution][value=1]').click();
            $('input[name=view][value="full"]').click();
            $('input[name=resolution]').prop("disabled", true);
            $('input[name=view]').prop("disabled", true);
        } else if (imgType != 'png') {
            $('input[name=transparent]').attr('checked', false);
            $('input[name=transparent]').prop("disabled", true);
            $('input[name=view]').prop("disabled", false);
        } else {
            $('input[name=view]').prop("disabled", false);
        }
    });
}

// Function to delete offline project of selected id
deleteOfflineProject = function (projectId) {
    var projectList = JSON.parse(localStorage.getItem("projectList"));
    var confirmation = confirm("Are You Sure You Want To Delete Project " + projectList[projectId] + " ?");
    if (confirmation) {
        delete projectList[projectId];
        localStorage.removeItem(projectId);
        localStorage.setItem("projectList", JSON.stringify(projectList));
        $('#openProjectDialog').empty();
        for (id in projectList) {
            $('#openProjectDialog').append('<label class="option"><input type="radio" name="projectId" value="' + id + '" />' + projectList[id] + '<i class="fa fa-times deleteOfflineProject" onclick="deleteOfflineProject(\'' + id + '\')"></i></label>');
        }
    }
}

// Prompt to restore from localStorage
createOpenLocalPrompt = function() {
    $('#openProjectDialog').empty();
    var projectList = JSON.parse(localStorage.getItem("projectList"));
    var flag = true;
    for (id in projectList) {
        flag = false;
        $('#openProjectDialog').append('<label class="option"><input type="radio" name="projectId" value="' + id + '" />' + projectList[id] + '<i class="fa fa-times deleteOfflineProject" onclick="deleteOfflineProject(\'' + id + '\')"></i></label>');
    }
    if (flag) $('#openProjectDialog').append('<p>Looks like no circuit has been saved yet. Create a new one and save it!</p>')
    $('#openProjectDialog').dialog({
        width: "auto",
        buttons: !flag ? [{
            text: "Open Project",
            click: function() {
                if (!$("input[name=projectId]:checked").val()) return;
                load(JSON.parse(localStorage.getItem($("input[name=projectId]:checked").val())));
                $(this).dialog("close");
            },
        }] : []

    });

}

// Prompt to create subcircuit, shows list of circuits which dont depend on the current circuit
createSubCircuitPrompt = function(scope = globalScope) {
    $('#insertSubcircuitDialog').empty();
    var flag = true;
    for (id in scopeList) {
        if (!scopeList[id].checkDependency(scope.id)) {
            flag = false;
            $('#insertSubcircuitDialog').append('<label class="option"><input type="radio" name="subCircuitId" value="' + id + '" />' + scopeList[id].name + '</label>');
        }
    }
    if (flag) $('#insertSubcircuitDialog').append('<p>Looks like there are no other circuits which doesn\'t have this circuit as a dependency. Create a new one!</p>')
    $('#insertSubcircuitDialog').dialog({
        maxHeight: 350,
        width: 250,
        maxWidth: 250,
        minWidth: 250,
        buttons: !flag ? [{
            text: "Insert SubCircuit",
            click: function() {
                if (!$("input[name=subCircuitId]:checked").val()) return;
                simulationArea.lastSelected = new SubCircuit(undefined, undefined, globalScope, $("input[name=subCircuitId]:checked").val());
                $(this).dialog("close");
            },
        }] : []

    });

}

// Helper function to store to localStorage -- needs to be deprecated/removed
function saveOffline() {
    projectSaved = true;
    var data = generateSaveData();
    localStorage.setItem(projectId, data);
    var temp = JSON.parse(localStorage.getItem("projectList")) || {};
    temp[projectId] = projectName;
    localStorage.setItem("projectList", JSON.stringify(temp));
    showMessage("We have saved your project: " + projectName + " in your browser's localStorage");
}

// Checks if any circuit has unsaved data
function checkToSave() {
    var save = false
    for (id in scopeList) {
        save |= checkIfBackup(scopeList[id]);
    }
    return save;
}

// Prompt user to save data if unsaved
window.onbeforeunload = function() {
    if (projectSaved || embed) return;

    if (!checkToSave()) return;

    alert("You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?");
    var data = generateSaveData("Untitled");
    localStorage.setItem("recover", data);
    return "Are u sure u want to leave? Any unsaved changes may not be recoverable"

}

// Function to generate image and prompt download
function generateImage(imgType, view, transparent, resolution, down = true) {

    // Backup all data
    var backUpOx = globalScope.ox;
    var backUpOy = globalScope.oy;
    var backUpWidth = width
    var backUpHeight = height;
    var backUpScale = globalScope.scale;
    backUpContextBackground = backgroundArea.context;
    backUpContextSimulation = simulationArea.context;

    backgroundArea.context = simulationArea.context;

    globalScope.ox *= 1 / backUpScale;
    globalScope.oy *= 1 / backUpScale;

    // If SVG, create SVG context - using canvas2svg here
    if (imgType == 'svg') {
        simulationArea.context = new C2S(width, height);
        resolution = 1;
    } else if (imgType != 'png') {
        transparent = false;
    }

    globalScope.scale = resolution;

    var scope = globalScope;

    // Focus circuit
    if (view == "full") {
        findDimensions();
        var minX = simulationArea.minWidth;
        var minY = simulationArea.minHeight;
        var maxX = simulationArea.maxWidth;
        var maxY = simulationArea.maxHeight;
        width = (maxX - minX + 100) * resolution;
        height = (maxY - minY + 100) * resolution;

        globalScope.ox = (-minX + 50) * resolution;
        globalScope.oy = (-minY + 50) * resolution;
    } else {
        globalScope.ox *= resolution;
        globalScope.oy *= resolution;
        width = (width * resolution) / backUpScale;
        height = (height * resolution) / backUpScale;
    }

    globalScope.ox = Math.round(globalScope.ox);
    globalScope.oy = Math.round(globalScope.oy);

    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;


    backgroundArea.context = simulationArea.context;

    simulationArea.clear();

    // Background
    if (!transparent) {
        simulationArea.context.fillStyle = "white";
        simulationArea.context.rect(0, 0, width, height);
        simulationArea.context.fill();
    }

    // Draw circuits, why is it updateOrder and not renderOrder?
    for (var i = 0; i < renderOrder.length; i++)
        for (var j = 0; j < scope[renderOrder[i]].length; j++)
            scope[renderOrder[i]][j].draw();

    // If circuit is to be downloaded, download, other wise return dataURL
    if (down) {
        if (imgType == 'svg') {
            var mySerializedSVG = simulationArea.context.getSerializedSvg(); //true here, if you need to convert named to numbered entities.
            download(globalScope.name + ".svg", mySerializedSVG);
        } else {
            downloadAsImg(globalScope.name, imgType)
        }
    } else {
        var returnData = simulationArea.canvas.toDataURL('image/' + imgType);
    }

    // Restore everything
    width = backUpWidth
    height = backUpHeight
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;
    globalScope.scale = backUpScale;
    backgroundArea.context = backUpContextBackground;
    simulationArea.context = backUpContextSimulation;
    globalScope.ox = backUpOx
    globalScope.oy = backUpOy;

    resetup();

    if (!down) return returnData

}

if (logix_project_id && logix_project_id == 0)
setTimeout(promptSave,120000);

function promptSave(){
    console.log("PROMPT")
    if(confirm("You have not saved your creation! Would you like save your project online? "))
    save()
}

async function postUserIssue(message) {
    var img = generateImage("jpeg", "full", false, 1, false).split(',')[1];
    const result = await $.ajax({
            url: 'https://api.imgur.com/3/image',
            type: 'POST',
            data: {
                image: img
            },
            dataType: 'json',
            headers: {
                Authorization: 'Client-ID 9a33b3b370f1054'
            },
        });

    message += "\n" + result.data.link;
    
    $.ajax({
        url: '/simulator/post_issue',
        type: 'POST',
        beforeSend: function(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'))
        },
        data: {
            "text": message,
        },
        success: function(response) {
            $('#result').html("<i class='fa fa-check' style='color:green'></i> You've successfully submitted the issue. Thanks for improving our platform.");
        },
        failure: function(err) {
            $('#result').html("<i class='fa fa-check' style='color:red'></i> There seems to be a network issue. Please reach out to us at support@ciruitverse.org");
        }
    });
}
