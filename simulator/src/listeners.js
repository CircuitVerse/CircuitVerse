/* eslint-disable quotes */
/* eslint-disable no-undef */
/* eslint-disable semi */
// Most Listeners are stored here
import { layoutModeGet, tempBuffer, layoutUpdate, setupLayoutModePanelListeners } from './layoutMode';
import simulationArea from './simulationArea';
import {
  scheduleUpdate, update, updateSelectionsAndPane,
  wireToBeCheckedSet, updatePositionSet, updateSimulationSet,
  updateCanvasSet, gridUpdateSet, errorDetectedSet
} from './engine';
import { changeScale } from './canvasApi';
import { scheduleBackup } from './data/backupCircuit';
import { hideProperties, deleteSelected, uxvar, fullView, createElement } from './ux';
import { updateRestrictedElementsList, updateRestrictedElementsInScope, hideRestricted, showRestricted } from './restrictedElementDiv';
import { removeMiniMap, updatelastMinimapShown } from './minimap';
import undo from './data/undo';
import { copy, paste, selectAll } from './events';
// import save from './data/save';
import { verilogModeGet } from './Verilog2CV';
import { setupTimingListeners } from './plotArea';

const unit = 10;
let coordinate;
const returnCoordinate = {
  x: 0,
  y: 0,
}
let currDistance = 0;
let distance = 0;
let pinchZ = 0;
let centreX;
let centreY;

var isIe = (navigator.userAgent.toLowerCase().indexOf('msie') != -1 || navigator.userAgent.toLowerCase().indexOf('trident') != -1);
/*
 *Function to start the pan in simulator
 *Works for both touch and Mouse
 *For now variable name starts from mouse like mouseDown are used both
  touch and mouse will change in future
 */
function panStart (e) {
  coordinate = getCoordinate(e);
  simulationArea.mouseDown = true;
  // Deselect Input
  if (document.activeElement instanceof HTMLElement) { document.activeElement.blur() }
  errorDetectedSet(false);
  updateSimulationSet(true);
  updatePositionSet(true);
  updateCanvasSet(true);
  simulationArea.lastSelected = undefined;
  simulationArea.selected = false;
  simulationArea.hover = undefined;
  var rect = simulationArea.canvas.getBoundingClientRect();
  simulationArea.mouseDownRawX = (coordinate.x - rect.left) * DPR;
  simulationArea.mouseDownRawY = (coordinate.y - rect.top) * DPR;
  simulationArea.mouseDownX = Math.round(((simulationArea.mouseDownRawX - globalScope.ox) / globalScope.scale) / unit) * unit;
  simulationArea.mouseDownY = Math.round(((simulationArea.mouseDownRawY - globalScope.oy) / globalScope.scale) / unit) * unit;
  if (simulationArea.touch) {
    simulationArea.mouseX = simulationArea.mouseDownX;
    simulationArea.mouseY = simulationArea.mouseDownY;
  }
  simulationArea.oldx = globalScope.ox;
  simulationArea.oldy = globalScope.oy;
  e.preventDefault();
  scheduleBackup();
  scheduleUpdate(1);
  $('.dropdown.open').removeClass('open');
}

/*
 * Function to pan in simulator
 * Works for both touch and Mouse
 * Pinch to zoom also implemented in the same
 * For now variable name starts from mouse like mouseDown are used both
   touch and mouse will change in future
 */

function panMove (e) {
// if only one figure it touched
// pan left or right
  if (!simulationArea.touch || e.touches.length === 1) {
    coordinate = getCoordinate(e);
    var rect = simulationArea.canvas.getBoundingClientRect();
    simulationArea.mouseRawX = (coordinate.x - rect.left) * DPR;
    simulationArea.mouseRawY = (coordinate.y - rect.top) * DPR;
    simulationArea.mouseXf = (simulationArea.mouseRawX - globalScope.ox) / globalScope.scale;
    simulationArea.mouseYf = (simulationArea.mouseRawY - globalScope.oy) / globalScope.scale;
    simulationArea.mouseX = Math.round(simulationArea.mouseXf / unit) * unit;
    simulationArea.mouseY = Math.round(simulationArea.mouseYf / unit) * unit;
    updateCanvasSet(true);
    if (simulationArea.lastSelected && (simulationArea.mouseDown || simulationArea.lastSelected.newElement)) {
      updateCanvasSet(true);
      var fn;

      if (simulationArea.lastSelected == globalScope.root) {
        fn = function () {
          updateSelectionsAndPane();
        };
      } else {
        fn = function () {
          if (simulationArea.lastSelected) { simulationArea.lastSelected.update(); }
        };
      }
      scheduleUpdate(0, 20, fn);
    } else {
      scheduleUpdate(0, 200);
    }
  }
  // if two fingures are touched
  // pinchZoom
  if (simulationArea.touch && e.touches.length === 2) {
    pinchZoom(e);
  }
}
/* Function for Panstop on simulator
   *For now variable name starts with mouse like mouseDown are used both
    touch and mouse will change in future
*/

function panStop () {
  simulationArea.mouseDown = false;
  if (!lightMode) {
    updatelastMinimapShown();
    setTimeout(removeMiniMap, 2000);
  }

  errorDetectedSet(false);
  updateSimulationSet(true);
  updatePositionSet(true);
  updateCanvasSet(true);
  gridUpdateSet(true);
  wireToBeCheckedSet(1);

  scheduleUpdate(1);
  simulationArea.mouseDown = false;

  for (var i = 0; i < 2; i++) {
    updatePositionSet(true);
    wireToBeCheckedSet(1);
    update();
  }
  errorDetectedSet(false);
  updateSimulationSet(true);
  updatePositionSet(true);
  updateCanvasSet(true);
  gridUpdateSet(true);
  wireToBeCheckedSet(1);

  scheduleUpdate(1);
  // var rect = simulationArea.canvas.getBoundingClientRect();

  if (!(simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height)) {
    uxvar.smartDropXX = simulationArea.mouseX + 100; // Math.round(((simulationArea.mouseRawX - globalScope.ox+100) / globalScope.scale) / unit) * unit;
    uxvar.smartDropYY = simulationArea.mouseY - 50; // Math.round(((simulationArea.mouseRawY - globalScope.oy+100) / globalScope.scale) / unit) * unit;
  }
}
/* Function to getCoordinate
    *If touch is enable then it will return touch coordinate
    *else it will return mouse coordinate
 */
function getCoordinate (e) {
  if (simulationArea.touch) {
    returnCoordinate.x = e.touches[0].clientX;
    returnCoordinate.y = e.touches[0].clientY;
    return returnCoordinate;
  }
  if (!simulationArea.touch) {
    returnCoordinate.x = e.clientX;
    returnCoordinate.y = e.clientY;
    return returnCoordinate;
  }
}
/* Function for Pinch zoom
    *This function is used to ZoomIN and Zoomout on Simulator
*/
function pinchZoom (e) {
  gridUpdateSet(true);
  scheduleUpdate();
  updateSimulationSet(true);
  updatePositionSet(true);
  updateCanvasSet(true);
  distance = Math.sqrt(
    (e.touches[1].clientX - e.touches[0].clientX) * (e.touches[1].clientX - e.touches[0].clientX),
    (e.touches[1].clientY - e.touches[0].clientY) * (e.touches[1].clientY - e.touches[0].clientY));
  centreX = (e.touches[0].clientX + e.touches[1].clientX) / 2;
  centreY = (e.touches[0].clientY + e.touches[1].clientY) / 2;
  if (distance >= currDistance) {
    pinchZ += 0.05;
    currDistance = distance;
  } else if (currDistance >= distance) {
    pinchZ -= 0.05;
    currDistance = distance;
  }
  if (pinchZ >= 4.5) {
    pinchZ = 4.5;
  } else if (pinchZ <= 1) {
    pinchZ = 1;
  }
  globalScope.scale = Math.max(0.5, Math.min(4 * DPR, pinchZ * 2));
  globalScope.scale = Math.round(globalScope.scale * 10) / 10;
  globalScope.ox -= Math.round(centreX * (globalScope.scale - oldScale));
  globalScope.oy -= Math.round(centreY * (globalScope.scale - oldScale));
  gridUpdateSet(true);
  scheduleUpdate(1);
}

export default function startListeners () {
  $('#deleteSelected').on('click', () => {
    deleteSelected();
  });

  $('#zoomIn').on('click', () => {
    changeScale(0.2, 'zoomButton', 'zoomButton', 2);
  });

  $('#zoomOut').on('click', () => {
    changeScale(-0.2, 'zoomButton', 'zoomButton', 2);
  });

  $('#undoButton').on('click', () => {
    undo();
  });

  $('#viewButton').on('click', () => {
    fullView();
  });

  $('#projectName').on('click', () => {
    simulationArea.lastSelected = globalScope.root;
    setTimeout(() => {
      document.getElementById("projname").select();
    }, 100);
  });
  /* Makes tabs reordering possible by making them sortable */
  $("#tabsBar").sortable({
    containment: 'parent',
    items: '> div',
    revert: false,
    opacity: 0.5,
    tolerance: 'pointer',
    placeholder: 'placeholder',
    forcePlaceholderSize: true,
  });

  document.getElementById('simulationArea').addEventListener('mousedown', (e) => {
    simulationArea.touch = false;
    panStart(e);
  });
  document.getElementById('simulationArea').addEventListener('mouseup', (e) => {
    if (simulationArea.lastSelected) simulationArea.lastSelected.newElement = false;
    /*
        handling restricted circuit elements
        */

    if (simulationArea.lastSelected && restrictedElements.includes(simulationArea.lastSelected.objectType) && !globalScope.restrictedCircuitElementsUsed.includes(simulationArea.lastSelected.objectType)) {
      globalScope.restrictedCircuitElementsUsed.push(simulationArea.lastSelected.objectType);
      updateRestrictedElementsList();
    }

    //       deselect multible elements with click
    if (!simulationArea.shiftDown && simulationArea.multipleObjectSelections.length > 0
    ) {
      if (
        !simulationArea.multipleObjectSelections.includes(
          simulationArea.lastSelected,
        )
      ) { simulationArea.multipleObjectSelections = []; }
    }
  });
  document.getElementById('simulationArea').addEventListener('mousemove', e => {
    simulationArea.touch = false;
    panMove(e);
  });
  document.getElementById('simulationArea').addEventListener('mouseup', e => {
    simulationArea.touch = false;
    panStop();
  });

  /** Implementating touch listerners
          *All Main basic touch listerners are
           present here
    */
  document.getElementById('simulationArea').addEventListener('touchstart', e => {
    simulationArea.touch = true;
    panStart(e);
  });
  document.getElementById('simulationArea').addEventListener('touchmove', e => {
    simulationArea.touch = true;
    panMove(e);
  });
  document.getElementById('simulationArea').addEventListener('touchend', e => {
    simulationArea.touch = true;
    panStop();
  });
  window.addEventListener('keyup', e => {
    scheduleUpdate(1);
    simulationArea.shiftDown = e.shiftKey;
    if (e.keyCode == 16) {
      simulationArea.shiftDown = false;
    }
    if (e.key == 'Meta' || e.key == 'Control') {
      simulationArea.controlDown = false;
    }
  })

  window.addEventListener('keydown', (e) => {
    if (document.activeElement.tagName == 'INPUT') return;
    if (document.activeElement != document.body) return;

    simulationArea.shiftDown = e.shiftKey;
    if (e.key == 'Meta' || e.key == 'Control') {
      simulationArea.controlDown = true;
    }

    if (simulationArea.controlDown && e.key.charCodeAt(0) == 122) { // detect the special CTRL-Z code
      undo();
    }

    if (listenToSimulator) {
      // If mouse is focusing on input element, then override any action
      // if($(':focus').length){
      //     return;
      // }

      if (document.activeElement.tagName == 'INPUT' || simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) {
        return;
      }
      // HACK TO REMOVE FOCUS ON PROPERTIES
      if (document.activeElement.type == 'number') {
        hideProperties();
        showProperties(simulationArea.lastSelected);
      }

      errorDetectedSet(false);
      updateSimulationSet(true);
      updatePositionSet(true);
      simulationArea.shiftDown = e.shiftKey;

      if (e.key == 'Meta' || e.key == 'Control') {
        simulationArea.controlDown = true;
      }

      // zoom in (+)
      if ((simulationArea.controlDown && (e.keyCode == 187 || e.keyCode == 171)) || e.keyCode == 107) {
        e.preventDefault();
        ZoomIn();
      }
      // zoom out (-)
      if ((simulationArea.controlDown && (e.keyCode == 189 || e.keyCode == 173)) || e.keyCode == 109) {
        e.preventDefault();
        ZoomOut();
      }

      if (simulationArea.mouseRawX < 0 || simulationArea.mouseRawY < 0 || simulationArea.mouseRawX > width || simulationArea.mouseRawY > height) return;

      scheduleUpdate(1);
      updateCanvasSet(true);
      wireToBeCheckedSet(1);

      // Needs to be deprecated, moved to more recent listeners
      if (simulationArea.controlDown && (e.key == 'C' || e.key == 'c')) {
        //    simulationArea.copyList=simulationArea.multipleObjectSelections.slice();
        //    if(simulationArea.lastSelected&&simulationArea.lastSelected!==simulationArea.root&&!simulationArea.copyList.contains(simulationArea.lastSelected)){
        //        simulationArea.copyList.push(simulationArea.lastSelected);
        //    }
        //    copy(simulationArea.copyList);
      }

      if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown) {
        if (e.key.toString().length == 1 || e.key.toString() == 'Backspace' || e.key.toString() == 'Enter') {
          simulationArea.lastSelected.keyDown(e.key.toString());
          e.cancelBubble = true;
          e.returnValue = false;

          //e.stopPropagation works in Firefox.
          if (e.stopPropagation) {
            e.stopPropagation();
            e.preventDefault();
          }
          return;
        }
      }

      if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown2) {
        if (e.key.toString().length == 1) {
          simulationArea.lastSelected.keyDown2(e.key.toString());
          return;
        }
      }

      if (simulationArea.lastSelected && simulationArea.lastSelected.keyDown3) {
        if (e.key.toString() != 'Backspace' && e.key.toString() != 'Delete') {
          simulationArea.lastSelected.keyDown3(e.key.toString());
          return;
        }
      }

      if (e.keyCode == 16) {
        simulationArea.shiftDown = true;
        if (simulationArea.lastSelected && !simulationArea.lastSelected.keyDown && simulationArea.lastSelected.objectType != 'Wire' && simulationArea.lastSelected.objectType != 'CircuitElement' && !simulationArea.multipleObjectSelections.contains(simulationArea.lastSelected)) {
          simulationArea.multipleObjectSelections.push(simulationArea.lastSelected);
        }
      }

      // Detect offline save shortcut (CTRL+SHIFT+S)
      if (simulationArea.controlDown && e.keyCode == 83 && simulationArea.shiftDown) {
        saveOffline();
        e.preventDefault();
      }

      // Detect Select all Shortcut
      if (simulationArea.controlDown && (e.keyCode == 65 || e.keyCode == 97)) {
        selectAll();
        e.preventDefault();
      }

      // deselect all Shortcut
      if (e.keyCode == 27) {
        simulationArea.multipleObjectSelections = [];
        simulationArea.lastSelected = undefined;
        e.preventDefault();
      }

      if ((e.keyCode == 113 || e.keyCode == 81) && simulationArea.lastSelected != undefined) {
        if (simulationArea.lastSelected.bitWidth !== undefined) { simulationArea.lastSelected.newBitWidth(parseInt(prompt('Enter new bitWidth'), 10)); }
      }

      if (simulationArea.controlDown && (e.key == 'T' || e.key == 't')) {
        // e.preventDefault(); //browsers normally open a new tab
        simulationArea.changeClockTime(prompt('Enter Time:'));
      }
    }

    if (e.keyCode == 8 || e.key == 'Delete') {
      deleteSelected();
    }
  }, true);

  document.getElementById('simulationArea').addEventListener('dblclick', (e) => {
    updateCanvasSet(true);
    if (simulationArea.lastSelected && simulationArea.lastSelected.dblclick !== undefined) {
      simulationArea.lastSelected.dblclick();
    } else if (!simulationArea.shiftDown) {
      simulationArea.multipleObjectSelections = [];
    }
    scheduleUpdate(2);
  });
  document.getElementById('simulationArea').addEventListener('mousewheel', MouseScroll);
  document.getElementById('simulationArea').addEventListener('DOMMouseScroll', MouseScroll);

  function MouseScroll (event) {
    updateCanvasSet(true);
    event.preventDefault();
    var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
    event.preventDefault();
    // eslint-disable-next-line no-redeclare
    var deltaY = event.wheelDelta ? event.wheelDelta : -event.detail;
    const direction = deltaY > 0 ? 1 : -1;
    handleZoom(direction);
    updateCanvasSet(true);
    gridUpdateSet(true);

    if (layoutModeGet())layoutUpdate();
    else update(); // Schedule update not working, this is INEFFICIENT
  }

  document.addEventListener('cut', (e) => {
    if (verilogModeGet()) return;
    if (document.activeElement.tagName == 'INPUT') return;
    if (document.activeElement.tagName != 'BODY') return;

    if (listenToSimulator) {
      simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
      if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
        simulationArea.copyList.push(simulationArea.lastSelected);
      }

      var textToPutOnClipboard = copy(simulationArea.copyList, true);

      // Updated restricted elements
      updateRestrictedElementsInScope();
      localStorage.setItem('clipboardData', textToPutOnClipboard);
      e.preventDefault();
      if (textToPutOnClipboard == undefined) return;
      if (isIe) {
        window.clipboardData.setData('Text', textToPutOnClipboard);
      } else {
        e.clipboardData.setData('text/plain', textToPutOnClipboard);
      }
    }
  });

  document.addEventListener('copy', (e) => {
    if (verilogModeGet()) return;
    if (document.activeElement.tagName == 'INPUT') return;
    if (document.activeElement.tagName != 'BODY') return;

    if (listenToSimulator) {
      simulationArea.copyList = simulationArea.multipleObjectSelections.slice();
      if (simulationArea.lastSelected && simulationArea.lastSelected !== simulationArea.root && !simulationArea.copyList.contains(simulationArea.lastSelected)) {
        simulationArea.copyList.push(simulationArea.lastSelected);
      }

      var textToPutOnClipboard = copy(simulationArea.copyList);

      // Updated restricted elements
      updateRestrictedElementsInScope();
      localStorage.setItem('clipboardData', textToPutOnClipboard);
      e.preventDefault();
      if (textToPutOnClipboard == undefined) return;
      if (isIe) {
        window.clipboardData.setData('Text', textToPutOnClipboard);
      } else {
        e.clipboardData.setData('text/plain', textToPutOnClipboard);
      }
    }
  });

  document.addEventListener('paste', (e) => {
    if (document.activeElement.tagName == 'INPUT') return;
    if (document.activeElement.tagName != 'BODY') return;

    if (listenToSimulator) {
      var data;
      if (isIe) {
        data = window.clipboardData.getData('Text');
      } else {
        data = e.clipboardData.getData('text/plain');
      }

      paste(data);

      // Updated restricted elements
      updateRestrictedElementsInScope();

      e.preventDefault();
    }
  });

  // 'drag and drop' event listener for subcircuit elements in layout mode
  $('#subcircuitMenu').on('dragstop', '.draggableSubcircuitElement', function (event, ui) {
    const sideBarWidth = $('#guide_1')[0].clientWidth;
    let tempElement;

    if (ui.position.top > 10 && ui.position.left > sideBarWidth) {
      // make a shallow copy of the element with the new coordinates
      tempElement = globalScope[this.dataset.elementName][this.dataset.elementId];
      // Changing the coordinate doesn't work yet, nodes get far from element
      tempElement.x = ui.position.left - sideBarWidth;
      tempElement.y = ui.position.top;
      for (const node of tempElement.nodeList) {
        node.x = ui.position.left - sideBarWidth;
        node.y = ui.position.top
      }

      tempBuffer.subElements.push(tempElement);
      this.parentElement.removeChild(this);
    }
  });

  restrictedElements.forEach((element) => {
    $(`#${element}`).mouseover(() => {
      showRestricted();
    });

    $(`#${element}`).mouseout(() => {
      hideRestricted();
    });
  });

  $(".search-input").on("keyup", function () {
    var parentElement = $(this).parent().parent();
    var closeButton = $('.search-close', parentElement);
    var searchInput = $('.search-input', parentElement);
    var searchResults = $('.search-results', parentElement);
    var menu = $('.accordion', parentElement);

    searchResults.css('display', 'block');
    closeButton.css('display', 'block');
    menu.css('display', 'none');
    const value = $(this).val().toLowerCase();

    closeButton.on('click', () => {
      searchInput.val('');
      menu.css('display', 'block');
      searchResults.css('display', 'none');
      closeButton.css('display', 'none');
    });
    if (value.length === 0) {
      menu.css('display', 'block');
      searchResults.css('display', 'none');
      closeButton.css('display', 'none');
      return;
    }
    let htmlIcons = '';
    const result = elementPanelList.filter(ele => ele.toLowerCase().includes(value));
    if (!result.length) searchResults.text('No elements found ...');
    else {
      result.forEach( e => htmlIcons += createIcon(e));
      searchResults
        .html(htmlIcons);
      $('.filterElements').mousedown(createElement);
    }
  });
  function createIcon (element) {
    return `<div class="${element} icon logixModules filterElements" id="${element}" title="${element}">
            <img  src= "/img/${element}.svg" >
        </div>`;
  }

  zoomSliderListeners();
  setupLayoutModePanelListeners();
  if (!embed) {
    setupTimingListeners();
  }
}
function resizeTabs () {
  var $windowsize = $('body').width();
  var $sideBarsize = $('.side').width();
  var $maxwidth = ($windowsize - $sideBarsize);
  $('#tabsBar div').each(function (e) {
    $(this).css({ 'max-width': $maxwidth - 30 });
  });
}
window.addEventListener('resize', resizeTabs);
resizeTabs();
$(() => {
  $('[data-toggle="tooltip"]').tooltip();
});
// direction is only 1 or -1
function handleZoom (direction) {
  if (globalScope.scale > 0.5 * DPR) {
    changeScale(direction * 0.1 * DPR);
  } else if (globalScope.scale < 4 * DPR) {
    changeScale(direction * 0.1 * DPR);
  }
  gridUpdateSet(true);
  scheduleUpdate();
}
export function ZoomIn () {
  handleZoom(1);
}
export function ZoomOut () {
  handleZoom(-1);
}
function zoomSliderListeners () {
  document.getElementById("customRange1").value = 5;
  document.getElementById('simulationArea').addEventListener('DOMMouseScroll', zoomSliderScroll);
  document.getElementById('simulationArea').addEventListener('mousewheel', zoomSliderScroll);
  let curLevel = document.getElementById("customRange1").value;
  $(document).on('input change', '#customRange1', function (e) {
    const newValue = $(this).val();
    const changeInScale = newValue - curLevel;
    updateCanvasSet(true);
    changeScale(changeInScale * 0.1, 'zoomButton', 'zoomButton', 3)
    gridUpdateSet(true);
    curLevel = newValue;
  });
  function zoomSliderScroll (e) {
    let zoomLevel = document.getElementById("customRange1").value;
    const deltaY = e.wheelDelta ? e.wheelDelta : -e.detail;
    const directionY = deltaY > 0 ? 1 : -1;
    if (directionY > 0) zoomLevel++
    else zoomLevel--
    if (zoomLevel >= 45) {
      zoomLevel = 45;
      document.getElementById("customRange1").value = 45;
    } else if (zoomLevel <= 0) {
      zoomLevel = 0;
      document.getElementById("customRange1").value = 0;
    } else {
      document.getElementById("customRange1").value = zoomLevel;
      curLevel = zoomLevel;
    }
  }
  function sliderZoomButton (direction) {
    var zoomSlider = $('#customRange1');
    var currentSliderValue = parseInt(zoomSlider.val(), 10);
    if (direction === -1) {
      currentSliderValue--;
    } else {
      currentSliderValue++;
    }
    zoomSlider.val(currentSliderValue).change();
  }
  $('#decrement').click(() => {
    sliderZoomButton(-1);
  });
  $('#increment').click(() => {
    sliderZoomButton(1);
  });
}
