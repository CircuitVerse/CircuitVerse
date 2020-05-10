/* eslint-disable no-bitwise */
/* eslint-disable guard-for-in */
/* eslint-disable no-restricted-syntax */
/* eslint-disable no-restricted-globals */
/* eslint-disable consistent-return */
/* eslint-disable func-names */
/* eslint-disable array-callback-return */
/* eslint-disable no-use-before-define */
/* eslint-disable no-param-reassign */
/* eslint-disable no-alert */
/**
 * Function to create new circuit
 * Function creates button in tab, creates scope and switches to this circuit
 * @param {string} name - name of the new circuit
 * @param {string} id - identifier for circuit
 */
function newCircuit(name, id) {
    name = name || prompt('Enter circuit name:');
    name = stripTags(name);
    if (!name) return;
    const scope = new Scope(name);
    if (id) scope.id = id;
    scopeList[scope.id] = scope;
    globalScope = scope;
    $('.circuits').removeClass('current');
    $('#tabsBar').append(`<div class='circuits toolbarButton current' id='${scope.id}'>${name}<span class ='tabsCloseButton' onclick='deleteCurrentCircuit()'  >x</span></div>`);
    $('.circuits').click(function () {
        switchCircuit(this.id);
    });
    if (!embed) {
        showProperties(scope.root);
    }
    dots(false);
    return scope;
}

/**
 * Used to change name of a circuit
 * @param {string} name - new name
 * @param {string} id - id of the circuit
 */
function changeCircuitName(name, id = globalScope.id) {
    name = name || 'Untitled';
    name = stripTags(name);
    $(`#${id}`).html(name);
    scopeList[id].name = name;
}

/**
 * Function to set the name of project.
 * @param {string} name - name for project
 */
function setProjectName(name) {
    name = stripTags(name);
    projectName = name;
    $('#projectName').html(name);
}

/**
 * Function to clear project
 */
function clearProject() {
    if (confirm('Would you like to clear the project?')) {
        globalScope = undefined;
        scopeList = {};
        $('.circuits').remove();
        newCircuit('main');
        showMessage('Your project is as good as new!');
    }
}

/**
 Function used to start a new project while prompting confirmation from the user
 * @param {boolean} verify - flag to verify a new project
 */
function newProject(verify) {
    if (verify || projectSaved || !checkToSave() || confirm('What you like to start a new project? Any unsaved changes will be lost.')) {
        clearProject();
        localStorage.removeItem('recover');
        window.location = '/simulator';

        projectName = undefined;
        projectId = generateId();
        showMessage('New Project has been created!');
    }
}

/**
 * Helper function used to generate SVG - only used for internal purposes to generate the icons
 */
function generateSvg() {
    resolution = 1;
    view = 'full';
    const backUpOx = globalScope.ox;
    const backUpOy = globalScope.oy;
    const backUpWidth = width;
    const backUpHeight = height;
    const backUpScale = globalScope.scale;
    backUpContextBackground = backgroundArea.context;
    backUpContextSimulation = simulationArea.context;
    backgroundArea.context = simulationArea.context;
    globalScope.ox *= resolution / backUpScale;
    globalScope.oy *= resolution / backUpScale;

    globalScope.scale = resolution;

    const scope = globalScope;

    if (view === 'full') {
        let minX = 10000000;
        let minY = 10000000;
        let maxX = -10000000;
        let maxY = -10000000;
        let maxDimension = 0;
        for (let i = 0; i < updateOrder.length; i++) {
            for (let j = 0; j < scope[updateOrder[i]].length; j++) {
                if (scope[updateOrder[i]][j].objectType !== 'Wire') {
                    minX = Math.min(minX, scope[updateOrder[i]][j].absX());
                    maxX = Math.max(maxX, scope[updateOrder[i]][j].absX());
                    minY = Math.min(minY, scope[updateOrder[i]][j].absY());
                    maxY = Math.max(maxY, scope[updateOrder[i]][j].absY());
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].leftDimensionX);
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].rightDimensionX);
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].upDimensionY);
                    maxDimension = Math.max(maxDimension, scope[updateOrder[i]][j].downDimensionY);
                }
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


    for (let i = 0; i < updateOrder.length; i++) {
        for (let j = 0; j < scope[updateOrder[i]].length; j++) { scope[updateOrder[i]][j].draw(); }
    }

    const mySerializedSVG = simulationArea.context.getSerializedSvg(); // true here, if you need to convert named to numbered entities.
    download('test.svg', mySerializedSVG);
    width = backUpWidth;
    height = backUpHeight;
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;
    globalScope.scale = backUpScale;
    backgroundArea.context = backUpContextBackground;
    simulationArea.context = backUpContextSimulation;
    globalScope.ox = backUpOx;
    globalScope.oy = backUpOy;

    updateSimulation = true;
    updateCanvas = true;
    scheduleUpdate();
    dots(false);
}

/**
 * Function used to change the current focusedCircuit
 * Disables layoutMode if enabled
 * Changes UI tab etc
 * Sets flags to make updates, resets most of the things
 * @param {string} id - identifier for circuit
 */
function switchCircuit(id) {
    if (layoutMode) { toggleLayoutMode(); }

    // globalScope.fixLayout();
    scheduleBackup();
    if (id === globalScope.id) return;
    $(`#${globalScope.id}`).removeClass('current');
    $(`#${id}`).addClass('current');
    simulationArea.lastSelected = undefined;
    simulationArea.multipleObjectSelections = [];
    simulationArea.copyList = [];
    globalScope = scopeList[id];
    updateSimulation = true;
    updateSubcircuit = true;
    forceResetNodes = true;
    dots(false);
    simulationArea.lastSelected = globalScope.root;
    if (!embed) {
        showProperties(simulationArea.lastSelected);
    }
    updateCanvas = true;
    scheduleUpdate();

    // to update the restricted elements information
    updateRestrictedElementsList();
}

/**
 * Helper function to save canvas as image based on image type
 * @param {string} name -name of the circuit
 * @param {*} imgType - image type ex: png,jpg etc.
 */
function downloadAsImg(name, imgType) {
    const gh = simulationArea.canvas.toDataURL(`image/${imgType}`);
    const anchor = document.createElement('a');
    anchor.href = gh;
    anchor.download = `${name}.${imgType}`;
    anchor.click();
}

/**
 * Function to restore copy from backup
 * @param {Scope=} scope - The circuit on which undo is called
 */
function undo(scope = globalScope) {
    if (layoutMode) return;
    if (scope.backups.length === 0) return;
    const backupOx = globalScope.ox;
    const backupOy = globalScope.oy;
    const backupScale = globalScope.scale;
    globalScope.ox = 0;
    globalScope.oy = 0;
    const tempScope = new Scope(scope.name);
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

/** Never used TBD */
function extract(obj) {
    return obj.saveObject();
}

// Check if there is anything to backup - to be deprecated
/**
 * Check if backup is available
 * @param {Scope} scope
 * @return {boolean}
 */
function checkIfBackup(scope) {
    for (let i = 0; i < updateOrder.length; i++) { if (scope[updateOrder[i]].length) return true; }
    return false;
}

/**
 * Function that should backup if there is a change, otherwise ignore
 * @param {Scope} scope
 * @return {string}
 */
function scheduleBackup(scope = globalScope) {
    const backup = JSON.stringify(backUp(scope));
    if (scope.backups.length === 0 || scope.backups[scope.backups.length - 1] !== backup) {
        scope.backups.push(backup);
        scope.timeStamp = new Date().getTime();
        projectSaved = false;
    }

    return backup;
}

/**
 * Function to generate random id
 * @return {string}
 */
function generateId() {
    let id = '';
    const possible = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789';

    for (let i = 0; i < 20; i++) { id += possible.charAt(Math.floor(Math.random() * possible.length)); }

    return id;
}

/**
 * fn to create save data of a specific circuit
 * @param {Scope} scope
 * @return {JSON}
 */
function backUp(scope = globalScope) {
    // Disconnection of subcircuits are needed because these are the connections between nodes
    // in current scope and those in the subcircuit's scope
    for (let i = 0; i < scope.SubCircuit.length; i++) { scope.SubCircuit[i].removeConnections(); }
    const data = {};
    // Storing layout
    data.layout = scope.layout;
    // Storing all nodes
    data.allNodes = scope.allNodes.map(extract);
    // Storing other details
    data.id = scope.id;
    data.name = scope.name;
    // Storing details of all module objects
    for (let i = 0; i < moduleList.length; i++) {
        if (scope[moduleList[i]].length) { data[moduleList[i]] = scope[moduleList[i]].map(extract); }
    }
    // Adding restricted circuit elements used in the save data
    data.restrictedCircuitElementsUsed = scope.restrictedCircuitElementsUsed;
    // Storing intermediate nodes (nodes in wires)
    data.nodes = [];
    for (let i = 0; i < scope.nodes.length; i++) { data.nodes.push(scope.allNodes.indexOf(scope.nodes[i])); }
    // Restoring the connections
    for (let i = 0; i < scope.SubCircuit.length; i++) { scope.SubCircuit[i].makeConnections(); }
    return data;
}

/**
 * Generating the order in which the circuits should be stored so that they can be loaded correctly
 * POSET, Finish times
 */
function generateDependencyOrder() {
    const dependencyList = {};
    const completed = {};
    for (id in scopeList) { dependencyList[id] = scopeList[id].getDependencies(); }

    function saveScope(id) {
        if (completed[id]) return;
        for (let i = 0; i < dependencyList[id].length; i++) { saveScope(dependencyList[id][i]); }
        completed[id] = true;
        data.scopes.push(id);
    }
}

/**
 * Deletes the current circuit
 * Ensures that at least one circuit is there
 * Ensures that no circuit depends on the current circuit
 * Switched to a random circuit
 */
function deleteCurrentCircuit() {
    if (Object.keys(scopeList).length <= 1) {
        showError('At least 2 circuits need to be there in order to delete a circuit.');
        return;
    }
    let dependencies = '';
    for (id in scopeList) {
        if (id !== globalScope.id && scopeList[id].checkDependency(globalScope.id)) {
            if (dependencies === '') {
                dependencies = scopeList[id].name;
            } else {
                dependencies += `, ${scopeList[id].name}`;
            }
        }
    }
    if (dependencies) {
        dependencies = `\nThe following circuits are depending on '${globalScope.name}': ${dependencies}\nDelete subcircuits of ${globalScope.name} before trying to delete ${globalScope.name}`;
        alert(dependencies);
        return;
    }

    const confirmation = confirm(`Are you sure want to delete: ${globalScope.name}\nThis cannot be undone.`);
    if (confirmation) {
        $(`#${globalScope.id}`).remove();
        delete scopeList[globalScope.id];
        switchCircuit(Object.keys(scopeList)[0]);
        showMessage('Circuit was successfully deleted');
    } else { showMessage('Circuit was not deleted'); }
}

/**
 * Generates JSON of the entire project
 * @param {string} name - the name of project
 * @return {JSON}
 */
function generateSaveData(name) {
    data = {};

    // Prompts for name, defaults to Untitled
    name = projectName || name || prompt('Enter Project Name:') || 'Untitled';
    data.name = stripTags(name);
    projectName = data.name;
    setProjectName(projectName);

    // Save project details
    data.timePeriod = simulationArea.timePeriod;
    data.clockEnabled = simulationArea.clockEnabled;
    data.projectId = projectId;
    data.focussedCircuit = globalScope.id;

    // Project Circuits, each scope is one circuit
    data.scopes = [];
    const dependencyList = {};
    const completed = {};

    // Getting list of dependencies for each circuit
    for (id in scopeList) { dependencyList[id] = scopeList[id].getDependencies(); }

    // Helper function to save Scope
    // Recursively saves inner subcircuits first, before saving parent circuits
    function saveScope(id) {
        if (completed[id]) return;

        for (let i = 0; i < dependencyList[id].length; i++) {
            // Save inner subcircuits
            saveScope(dependencyList[id][i]);
        }

        completed[id] = true;

        update(scopeList[id], true); // For any pending integrity checks on subcircuits

        data.scopes.push(backUp(scopeList[id]));
    }

    // Save all circuits
    for (id in scopeList) { saveScope(id); }

    // convert to text
    data = JSON.stringify(data);
    return data;
}

/**
 * Function that is used to save image for display in the website
 * @return {JSON}
 */
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

    data = generateImage('jpeg', 'current', false, resolution, down = false);

    // Restores Focus
    globalScope.centerFocus(false);
    return data;
}

/**
 * Function to save data online
 */
function save() {
    projectSaved = true;

    $('.loadingIcon').fadeIn();
    const data = generateSaveData();

    if (!userSignedIn) {
        // user not signed in, save locally temporarily and force user to sign in
        localStorage.setItem('recover_login', data);
        // Asking user whether they want to login.
        if (confirm('You have to login to save the project, you will be redirected to the login page.')) window.location.href = '/users/sign_in';
        else $('.loadingIcon').fadeOut();
    // eslint-disable-next-line camelcase
    } else if (logix_project_id === 0) {
        // Create new project - this part needs to be improved and optimised
        const form = $('<form/>', {
            action: '/simulator/create_data',
            method: 'post',
        });
        form.append(
            $('<input>', {
                type: 'hidden',
                name: 'authenticity_token',
                value: $('meta[name="csrf-token"]').attr('content'),
            }),
        );
        form.append(
            $('<input>', {
                type: 'text',
                name: 'data',
                value: data,
            }),
        );
        form.append(
            $('<input>', {
                type: 'text',
                name: 'image',
                value: generateImageForOnline(),
            }),
        );

        form.append(
            $('<input>', {
                type: 'text',
                name: 'name',
                value: projectName,
            }),
        );

        $('body').append(form);
        form.submit();
    } else {
        // updates project - this part needs to be improved and optimised
        $.ajax({
            url: '/simulator/update_data',
            type: 'POST',
            beforeSend(xhr) {
                xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
            },
            data: {
                data,
                id: logix_project_id,
                image: generateImageForOnline(),
                name: projectName,
            },
            success(response) {
                showMessage(`We have saved your project: ${projectName} in our servers.`);
                $('.loadingIcon').fadeOut();
                localStorage.removeItem('recover');
            },
            failure(err) {
                showMessage("There was an error, we couldn't save to our servers");
                $('.loadingIcon').fadeOut();
            },
        });
    }

    // Restore everything
    resetup();
}

// Function to load project from data
/**
 * loads a saved project
 * @param {JSON} data - the json data of the
 */
function load(data) {
    // If project is new and no data is there, then just set project name
    if (!data) {
        setProjectName(projectName);
        return;
    }

    projectId = data.projectId;
    projectName = data.name;

    if (data.name === 'Untitled') { projectName = undefined; } else { setProjectName(data.name); }

    globalScope = undefined;
    scopeList = {}; // Remove default scope
    $('.circuits').remove(); // Delete default scope

    // Load all circuits according to the dependency order
    for (let i = 0; i < data.scopes.length; i++) {
        // Create new circuit
        const scope = newCircuit(data.scopes[i].name || 'Untitled', data.scopes[i].id);

        // Load circuit data
        loadScope(scope, data.scopes[i]);

        // Focus circuit
        globalScope = scope;

        // Center circuit
        if (embed) { globalScope.centerFocus(true); } else { globalScope.centerFocus(false); }

        // update and backup circuit once
        update(globalScope, true);

        // Updating restricted element list initially on loading
        updateRestrictedElementsInScope();

        scheduleBackup();
    }

    // Restore clock
    simulationArea.changeClockTime(data.timePeriod || 500);
    simulationArea.clockEnabled = data.clockEnabled === undefined ? true : data.clockEnabled;


    if (!embed) { showProperties(simulationArea.lastSelected); }

    // Switch to last focussedCircuit
    if (data.focussedCircuit) switchCircuit(data.focussedCircuit);


    updateSimulation = true;
    updateCanvas = true;
    gridUpdate = true;
    scheduleUpdate();
}

/**
 * Backward compatibility - needs to be deprecated
 * @param {CircuitElement} obj - the object to be rectified
 */
function rectifyObjectType(obj) {
    const rectify = {
        FlipFlop: 'DflipFlop',
        Ram: 'Rom',
    };
    return rectify[obj] || obj;
}

/**
 * Function to load CircuitElements
 * @param {JSON} data - JSOn data
 * @param {Scope} scope - circuit in which we want to load modules
 */
function loadModule(data, scope) {
    // Create circuit element
    const obj = new window[rectifyObjectType(data.objectType)](data.x, data.y, scope, ...data.customData.constructorParamaters || []);

    // Sets directions
    obj.label = data.label;
    obj.labelDirection = data.labelDirection || oppositeDirection[fixDirection[obj.direction]];

    // Sets delay
    obj.propagationDelay = data.propagationDelay || obj.propagationDelay;
    obj.fixDirection();

    // Restore other values
    if (data.customData.values) {
        for (prop in data.customData.values) {
            obj[prop] = data.customData.values[prop];
        }
    }

    // Replace new nodes with the correct old nodes (with connections)
    if (data.customData.nodes) {
        for (node in data.customData.nodes) {
            const n = data.customData.nodes[node];
            if (n instanceof Array) {
                for (let i = 0; i < n.length; i++) {
                    obj[node][i] = replace(obj[node][i], n[i]);
                }
            } else {
                obj[node] = replace(obj[node], n);
            }
        }
    }
}

/**
 * Helper function to download text
 * @param {string} filename - name of the to be downloaded file
 * @param {*} text - text in the file
 */
function download(filename, text) {
    const pom = document.createElement('a');
    pom.setAttribute('href', `data:text/plain;charset=utf-8,${encodeURIComponent(text)}`);
    pom.setAttribute('download', filename);


    if (document.createEvent) {
        const event = document.createEvent('MouseEvents');
        event.initEvent('click', true, true);
        pom.dispatchEvent(event);
    } else {
        pom.click();
    }
}

/**
 * Function to load a full circuit
 * @param {Scope} scope
 * @param {JSON} data
 */
function loadScope(scope, data) {
    const ML = moduleList.slice(); // Module List copy
    scope.restrictedCircuitElementsUsed = data.restrictedCircuitElementsUsed;

    // Load all nodes
    data.allNodes.map((x) => loadNode(x, scope));

    // Make all connections
    for (let i = 0; i < data.allNodes.length; i++) { constructNodeConnections(scope.allNodes[i], data.allNodes[i]); }
    // Load all modules
    for (let i = 0; i < ML.length; i++) {
        if (data[ML[i]]) {
            if (ML[i] === 'SubCircuit') {
                // Load subcircuits differently
                for (let j = 0; j < data[ML[i]].length; j++) { loadSubCircuit(data[ML[i]][j], scope); }
            } else {
                // Load everything else similarly
                for (let j = 0; j < data[ML[i]].length; j++) {
                    loadModule(data[ML[i]][j], scope);
                }
            }
        }
    }
    // Update wires according
    scope.wires.map((x) => {
        x.updateData(scope);
    });
    removeBugNodes(scope); // To be deprecated
    // If layout exists, then restore
    if (data.layout) {
        scope.layout = data.layout;
    } else {
        // Else generate new layout according to how it would have been otherwise (backward compatibility)
        scope.layout = {};
        scope.layout.width = 100;
        scope.layout.height = Math.max(scope.Input.length, scope.Output.length) * 20 + 20;
        scope.layout.title_x = 50;
        scope.layout.title_y = 13;
        for (let i = 0; i < scope.Input.length; i++) {
            scope.Input[i].layoutProperties = {
                x: 0,
                y: scope.layout.height / 2 - scope.Input.length * 10 + 20 * i + 10,
                id: generateId(),
            };
        }
        for (let i = 0; i < scope.Output.length; i++) {
            scope.Output[i].layoutProperties = {
                x: scope.layout.width,
                y: scope.layout.height / 2 - scope.Output.length * 10 + 20 * i + 10,
                id: generateId(),
            };
        }
    }
    // Backward compatibility
    if (scope.layout.titleEnabled === undefined) { scope.layout.titleEnabled = true; }
}

/**
 * This function shouldn't ideally exist. But temporary fix
 * for some issues while loading nodes.
 */
function removeBugNodes(scope = globalScope) {
    let x = scope.allNodes.length;
    for (let i = 0; i < x; i++) {
        if (scope.allNodes[i].type !== 2 && scope.allNodes[i].parent.objectType === 'CircuitElement') { scope.allNodes[i].delete(); }
        if (scope.allNodes.length !== x) {
            i = 0;
            x = scope.allNodes.length;
        }
    }
}

/**
 * Helper function to show prompt to save image
 * Options - resolution, image type, view
 * @param {Scope=} scope - useless though
 */
function createSaveAsImgPrompt(scope = globalScope) {
    $('#saveImageDialog').dialog({
        width: 'auto',
        buttons: [{
            text: 'Render Circuit Image',
            click() {
                generateImage($('input[name=imgType]:checked').val(), $('input[name=view]:checked').val(), $('input[name=transparent]:checked').val(), $('input[name=resolution]:checked').val());
                $(this).dialog('close');
            },
        }],

    });
    $('input[name=imgType]').change(() => {
        $('input[name=resolution]').prop('disabled', false);
        $('input[name=transparent]').prop('disabled', false);
        const imgType = $('input[name=imgType]:checked').val();
        if (imgType === 'svg') {
            $('input[name=resolution][value=1]').click();
            $('input[name=view][value="full"]').click();
            $('input[name=resolution]').prop('disabled', true);
            $('input[name=view]').prop('disabled', true);
        } else if (imgType !== 'png') {
            $('input[name=transparent]').attr('checked', false);
            $('input[name=transparent]').prop('disabled', true);
            $('input[name=view]').prop('disabled', false);
        } else {
            $('input[name=view]').prop('disabled', false);
        }
    });
}

/**
 * Function to delete offline project of selected id
 * @param {number} projectId
 */
function deleteOfflineProject(projectId) {
    const projectList = JSON.parse(localStorage.getItem('projectList'));
    const confirmation = confirm(`Are You Sure You Want To Delete Project ${projectList[projectId]} ?`);
    if (confirmation) {
        delete projectList[projectId];
        localStorage.removeItem(projectId);
        localStorage.setItem('projectList', JSON.stringify(projectList));
        $('#openProjectDialog').empty();
        for (id in projectList) {
            $('#openProjectDialog').append(`<label class="option"><input type="radio" name="projectId" value="${id}" />${projectList[id]}<i class="fa fa-times deleteOfflineProject" onclick="deleteOfflineProject('${id}')"></i></label>`);
        }
    }
}

/**
 * Prompt to restore from localStorage
 */
function createOpenLocalPrompt() {
    $('#openProjectDialog').empty();
    const projectList = JSON.parse(localStorage.getItem('projectList'));
    let flag = true;
    for (id in projectList) {
        flag = false;
        $('#openProjectDialog').append(`<label class="option"><input type="radio" name="projectId" value="${id}" />${projectList[id]}<i class="fa fa-times deleteOfflineProject" onclick="deleteOfflineProject('${id}')"></i></label>`);
    }
    if (flag) $('#openProjectDialog').append('<p>Looks like no circuit has been saved yet. Create a new one and save it!</p>');
    $('#openProjectDialog').dialog({
        width: 'auto',
        buttons: !flag ? [{
            text: 'Open Project',
            click() {
                if (!$('input[name=projectId]:checked').val()) return;
                load(JSON.parse(localStorage.getItem($('input[name=projectId]:checked').val())));
                $(this).dialog('close');
            },
        }] : [],

    });
}

/**
 * Prompt to create subcircuit, shows list of circuits which dont depend on the current circuit
 * @param {Scope=} scope
 */
function createSubCircuitPrompt(scope = globalScope) {
    $('#insertSubcircuitDialog').empty();
    let flag = true;
    for (id in scopeList) {
        if (!scopeList[id].checkDependency(scope.id)) {
            flag = false;
            $('#insertSubcircuitDialog').append(`<label class="option"><input type="radio" name="subCircuitId" value="${id}" />${scopeList[id].name}</label>`);
        }
    }
    if (flag) $('#insertSubcircuitDialog').append('<p>Looks like there are no other circuits which doesn\'t have this circuit as a dependency. Create a new one!</p>');
    $('#insertSubcircuitDialog').dialog({
        maxHeight: 350,
        width: 250,
        maxWidth: 250,
        minWidth: 250,
        buttons: !flag ? [{
            text: 'Insert SubCircuit',
            click() {
                if (!$('input[name=subCircuitId]:checked').val()) return;
                simulationArea.lastSelected = new SubCircuit(undefined, undefined, globalScope, $('input[name=subCircuitId]:checked').val());
                $(this).dialog('close');
            },
        }] : [],

    });
}

/**
 * Helper function to store to localStorage -- needs to be deprecated/removed
 */
function saveOffline() {
    projectSaved = true;
    const data = generateSaveData();
    localStorage.setItem(projectId, data);
    const temp = JSON.parse(localStorage.getItem('projectList')) || {};
    temp[projectId] = projectName;
    localStorage.setItem('projectList', JSON.stringify(temp));
    showMessage(`We have saved your project: ${projectName} in your browser's localStorage`);
}

/**
 * Checks if any circuit has unsaved data
 */
function checkToSave() {
    let saveFlag = false;
    for (id in scopeList) {
        saveFlag |= checkIfBackup(scopeList[id]);
    }
    return saveFlag;
}

/**
 * Prompt user to save data if unsaved
 */
window.onbeforeunload = function () {
    if (projectSaved || embed) return;

    if (!checkToSave()) return;

    alert('You have unsaved changes on this page. Do you want to leave this page and discard your changes or stay on this page?');
    const data = generateSaveData('Untitled');
    localStorage.setItem('recover', data);
    return 'Are u sure u want to leave? Any unsaved changes may not be recoverable';
};

/**
 * Function to generate image for the circuit
 * @param {string} imgType - ex: png,jpg etc.
 * @param {string} view - view type ex: full
 * @param {boolean} transparent - tranparent bg or not
 * @param {number} resolution - resolution of the image
 * @param {boolean=} down - will download if true
 */
function generateImage(imgType, view, transparent, resolution, down = true) {
    // Backup all data
    const backUpOx = globalScope.ox;
    const backUpOy = globalScope.oy;
    const backUpWidth = width;
    const backUpHeight = height;
    const backUpScale = globalScope.scale;
    backUpContextBackground = backgroundArea.context;
    backUpContextSimulation = simulationArea.context;

    backgroundArea.context = simulationArea.context;

    globalScope.ox *= 1 / backUpScale;
    globalScope.oy *= 1 / backUpScale;

    // If SVG, create SVG context - using canvas2svg here
    if (imgType === 'svg') {
        simulationArea.context = new C2S(width, height);
        resolution = 1;
    } else if (imgType !== 'png') {
        transparent = false;
    }

    globalScope.scale = resolution;

    const scope = globalScope;

    // Focus circuit
    if (view === 'full') {
        findDimensions();
        const minX = simulationArea.minWidth;
        const minY = simulationArea.minHeight;
        const maxX = simulationArea.maxWidth;
        const maxY = simulationArea.maxHeight;
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
        simulationArea.context.fillStyle = 'white';
        simulationArea.context.rect(0, 0, width, height);
        simulationArea.context.fill();
    }

    // Draw circuits, why is it updateOrder and not renderOrder?
    for (let i = 0; i < renderOrder.length; i++) {
        for (let j = 0; j < scope[renderOrder[i]].length; j++) { scope[renderOrder[i]][j].draw(); }
    }

    // If circuit is to be downloaded, download, other wise return dataURL
    if (down) {
        if (imgType === 'svg') {
            const mySerializedSVG = simulationArea.context.getSerializedSvg(); // true here, if you need to convert named to numbered entities.
            download(`${globalScope.name}.svg`, mySerializedSVG);
        } else {
            downloadAsImg(globalScope.name, imgType);
        }
    } else {
        const returnData = simulationArea.canvas.toDataURL(`image/${imgType}`);
    }

    // Restore everything
    width = backUpWidth;
    height = backUpHeight;
    simulationArea.canvas.width = width;
    simulationArea.canvas.height = height;
    backgroundArea.canvas.width = width;
    backgroundArea.canvas.height = height;
    globalScope.scale = backUpScale;
    backgroundArea.context = backUpContextBackground;
    simulationArea.context = backUpContextSimulation;
    globalScope.ox = backUpOx;
    globalScope.oy = backUpOy;

    resetup();

    if (!down) return returnData;
}

/**
 * remind user to save the project
 */
// eslint-disable-next-line camelcase
if (logix_project_id === 0) { setTimeout(promptSave, 120000); }

/**
 * prompt for saving project
 */
function promptSave() {
    if (confirm('You have not saved your creation! Would you like save your project online? ')) { save(); }
}

/**
 * The helper function to post user issue to slack channel
 * @param {string} message - complaint message
 */
function postUserIssue(message) {
    $.ajax({
        url: '/simulator/post_issue',
        type: 'POST',
        beforeSend(xhr) {
            xhr.setRequestHeader('X-CSRF-Token', $('meta[name="csrf-token"]').attr('content'));
        },
        data: {
            text: message,
        },
        success(response) {
            $('#result').html("<i class='fa fa-check' style='color:green'></i> You've successfully submitted the issue. Thanks for improving our platform.");
        },
        failure(err) {
            $('#result').html("<i class='fa fa-check' style='color:red'></i> There seems to be a network issue. Please reach out to us at support@ciruitverse.org");
        },
    });
}
