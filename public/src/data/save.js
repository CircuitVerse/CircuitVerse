import { scopeList } from '../circuit';
import { resetup } from '../setup';
import { update } from '../engine';
import { stripTags, showMessage } from '../utils';
import { backUp } from './backupCircuit';
import simulationArea from '../simulationArea';
import backgroundArea from '../backgroundArea';
import { findDimensions } from '../canvasApi';
import { projectSavedSet } from './project';
import { colors } from '../themer/themer';
import {layoutModeGet, toggleLayoutMode} from '../layoutMode';
import {verilogModeGet} from '../Verilog2CV';
import domtoimage from 'dom-to-image';

var projectName = undefined;

/**
 * Function to set the name of project.
 * @param {string} name - name for project
 * @category data
 */
export function setProjectName(name) {
    if(name == undefined) {
        $('#projectName').html('Untitled');
        return;
    }
    name = stripTags(name);
    projectName = name;
    $('#projectName').html(name);
}

/**
 * Function to set the name of project.
 * @param {string} name - name for project
 * @category data
 */
export function getProjectName() {
    return projectName;
}

/**
 * Helper function to save canvas as image based on image type
 * @param {string} name -name of the circuit
 * @param {string} imgType - image type ex: png,jpg etc.
 * @category data
 */
function downloadAsImg(name, imgType) {
    const gh = simulationArea.canvas.toDataURL(`image/${imgType}`);
    const anchor = document.createElement('a');
    anchor.href = gh;
    anchor.download = `${name}.${imgType}`;
    anchor.click();
}

/**
 * Returns the order of tabs in the project
*/
export function getTabsOrder() {
    var tabs = $("#tabsBar").children().not('button');
    var order = [];
    for (let i = 0; i < tabs.length; i++) {
         order.push(tabs[i].id);
    }
    return order
}

/**
 * Generates JSON of the entire project
 * @param {string} name - the name of project
 * @return {JSON}
 * @category data
 */
export function generateSaveData(name) {
    data = {};

    // Prompts for name, defaults to Untitled
    name = getProjectName() || name || prompt('Enter Project Name:') || 'Untitled';
    data.name = stripTags(name);
    setProjectName(data.name);

    // Save project details
    data.timePeriod = simulationArea.timePeriod;
    data.clockEnabled = simulationArea.clockEnabled;
    data.projectId = projectId;
    data.focussedCircuit = globalScope.id;
    data.orderedTabs = getTabsOrder();

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

/**
 * Function to generate image for the circuit
 * @param {string} imgType - ex: png,jpg etc.
 * @param {string} view - view type ex: full
 * @param {boolean} transparent - tranparent bg or not
 * @param {number} resolution - resolution of the image
 * @param {boolean=} down - will download if true
 * @category data
 */
export function generateImage(imgType, view, transparent, resolution, down = true) {
    // Backup all data
    const backUpOx = globalScope.ox;
    const backUpOy = globalScope.oy;
    const backUpWidth = width;
    const backUpHeight = height;
    const backUpScale = globalScope.scale;
    const backUpContextBackground = backgroundArea.context;
    const backUpContextSimulation = simulationArea.context;

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
    var flag = 1;
    if (flag) {
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
        simulationArea.context.fillStyle = colors["canvas_fill"];
        simulationArea.context.rect(0, 0, width, height);
        simulationArea.context.fill();
    }

    // Draw circuits, why is it updateOrder and not renderOrder?
    for (let i = 0; i < renderOrder.length; i++) {
        for (let j = 0; j < scope[renderOrder[i]].length; j++) { scope[renderOrder[i]][j].draw(); }
    }

    let returnData;
    // If circuit is to be downloaded, download, other wise return dataURL
    if (down) {
        if (imgType === 'svg') {
            const mySerializedSVG = simulationArea.context.getSerializedSvg(); // true here, if you need to convert named to numbered entities.
            download(`${globalScope.name}.svg`, mySerializedSVG);
        } else {
            downloadAsImg(globalScope.name, imgType);
        }
    } else {
        returnData = simulationArea.canvas.toDataURL(`image/${imgType}`);
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

async function crop(dataURL, w, h) {
  //get empty second canvas
  var myCanvas = document.createElement("CANVAS");
  myCanvas.width = w;
  myCanvas.height = h;
  var myContext = myCanvas.getContext('2d');
  var myImage;
  var img = new Image();
  return new Promise (function (resolved, rejected) {
        img.src = dataURL;
        img.onload = () => {
        myContext.drawImage(img, 0, 0, w, h,0,0, w ,h);
        myContext.save();

        //create a new data URL
        myImage = myCanvas.toDataURL('image/jpeg');
        resolved(myImage);}
    })
}

/**
 * Function that is used to save image for display in the website
 * @return {JSON}
 * @category data
 */
async function generateImageForOnline() {
    // Verilog Mode -> Different logic
    // Fix aspect ratio to 1.6
    // Ensure image is approximately 700 x 440
    var ratio = 1.6
    if(verilogModeGet()) {
        var node = document.getElementsByClassName('CodeMirror')[0];
        // var node = document.getElementsByClassName('CodeMirror')[0];
        var prevHeight = $(node).css('height');
        var prevWidth = $(node).css('width');
        var baseWidth = 500;
        var baseHeight = Math.round(baseWidth / ratio);
        $(node).css('height', baseHeight);
        $(node).css('width', baseWidth);
        
        var data = await domtoimage.toJpeg(node);
        $(node).css('width', prevWidth);
        $(node).css('height', prevHeight);
        data = await crop(data, baseWidth, baseHeight);
        return data;
    }

    simulationArea.lastSelected = undefined; // Unselect any selections

    // Fix aspect ratio to 1.6
    if (width > height * ratio) {
        height = width / ratio;
    } else {
        width = height * 1.6;
    }

    // Center circuits
    globalScope.centerFocus();

    // Ensure image is approximately 700 x 440
    const resolution = Math.min(700 / (simulationArea.maxWidth - simulationArea.minWidth), 440 / (simulationArea.maxHeight - simulationArea.minHeight));

    data = generateImage('jpeg', 'current', false, resolution, false);

    // Restores Focus
    globalScope.centerFocus(false);
    return data;
    
}
/**
 * Function called when you save acircuit online
 * @category data
 * @exports save
 */
export default async function save() {
    if(layoutModeGet())
        toggleLayoutMode();

    projectSavedSet(true);

    $('.loadingIcon').fadeIn();
    const data = generateSaveData();

    const projectName = getProjectName();
    var imageData = await generateImageForOnline();

    if (!userSignedIn) {
        // user not signed in, save locally temporarily and force user to sign in
        localStorage.setItem('recover_login', data);
        // Asking user whether they want to login.
        if (confirm('You have to login to save the project, you will be redirected to the login page.')) window.location.href = '/users/sign_in';
        else $('.loadingIcon').fadeOut();
        // eslint-disable-next-line camelcase
    } else if (__logix_project_id == "0") {
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
                value: imageData,
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
                id: __logix_project_id,
                image: imageData,
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
