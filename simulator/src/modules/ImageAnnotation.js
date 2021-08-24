import CircuitElement from '../circuitElement';
import Node, { findNode } from '../node';
import simulationArea from '../simulationArea';
import { correctWidth, rect, fillText, drawImage} from '../canvasApi';
import { colors } from '../themer/themer';
import { promptFile, showMessage, getImageDimensions} from '../utils'
/**
 * @class
 * Image
 * @extends CircuitElement
 * @param {number} x - x coordinate of element.
 * @param {number} y - y coordinate of element.
 * @param {Scope=} scope - Cirucit on which element is drawn
 * @param {number=} rows - number of rows
 * @param {number=} cols - number of columns.
 * @category modules
 */
export default class ImageAnnotation extends CircuitElement {
    constructor(x, y, scope = globalScope, rows = 15, cols = 20, imageUrl='') {
        super(x, y, scope, 'RIGHT', 1);
        this.directionFixed = true;
        this.fixedBitWidth = true;
        this.imageUrl = imageUrl;
        this.cols = cols || parseInt(prompt('Enter cols:'), 10);
        this.rows = rows || parseInt(prompt('Enter rows:'), 10);
        this.setSize();
        this.loadImage();
    }

    /**
     * @memberof Image
     * @param {number} size - new size of rows
     */
    changeRowSize(size) {
        if (size === undefined || size < 5 || size > 1000) return;
        if (this.rows === size) return;
        this.rows = parseInt(size, 10);
        this.setSize();
        return this;
    }

    /**
     * @memberof Image
     * @param {number} size - new size of columns
     */
    changeColSize(size) {
        if (size === undefined || size < 5 || size > 1000) return;
        if (this.cols === size) return;
        this.cols = parseInt(size, 10);
        this.setSize();
        return this;
    }

    /**
     * @memberof Image
     * listener function to change direction of Image
     * @param {string} dir - new direction
     */
    keyDown3(dir) {
        if (dir === 'ArrowRight') { this.changeColSize(this.cols + 2); }
        if (dir === 'ArrowLeft') { this.changeColSize(this.cols - 2); }
        if (dir === 'ArrowDown') { this.changeRowSize(this.rows + 2); }
        if (dir === 'ArrowUp') { this.changeRowSize(this.rows - 2); }
    }

    /**
     * @memberof Image
     * fn to create save Json Data of object
     * @return {JSON}
     */
    customSave() {
        const data = {
            constructorParamaters: [this.rows, this.cols, this.imageUrl],
        };
        return data;
    }

    /**
     * @memberof Image
     * function to draw element
     */
    customDraw() {
        var ctx = simulationArea.context;
        const xx = this.x;
        const yy = this.y;
        var w = this.elementWidth;
        var h = this.elementHeight;
        if(this.image && this.image.complete) {
            drawImage(ctx, this.image, xx - w / 2, yy - h / 2, w, h);
        }
        else {
            ctx.beginPath();
            ctx.strokeStyle = 'rgba(0,0,0,1)';
            ctx.setLineDash([5 * globalScope.scale, 5 * globalScope.scale]);
            ctx.lineWidth = correctWidth(1.5);

            rect(ctx, xx - w / 2, yy - h / 2, w, h);
            ctx.stroke();

            if (simulationArea.lastSelected === this || simulationArea.multipleObjectSelections.contains(this)) {
                ctx.fillStyle = 'rgba(255, 255, 32,0.1)';
                ctx.fill();
            }

            ctx.beginPath();
            ctx.textAlign = 'center';
            ctx.fillStyle = colors['text'];
            fillText(ctx, "Double Click to Insert Image", xx, yy, 10);
            ctx.fill();

            ctx.setLineDash([]);
        }
    }

    /**
     * Procedure if image is double clicked
    **/
    dblclick() {
        if (embed) return;
        this.uploadImage();
    }

    async uploadImage() {
        var file = await promptFile("image/*", false);
        var apiUrl = 'https://api.imgur.com/3/image';
        var apiKey = '9a33b3b370f1054';
        var settings = {
            crossDomain: true,
            processData: false,
            contentType: false,
            type: 'POST',
            url: apiUrl,
            headers: {
            Authorization: 'Client-ID ' + apiKey,
            Accept: 'application/json',
            },
            mimeType: 'multipart/form-data',
        };
        var formData = new FormData();
        formData.append('image', file);
        settings.data = formData;

        // Response contains stringified JSON
        // Image URL available at response.data.link
        showMessage('Uploading Image');
        var response = await $.ajax(settings);
        showMessage('Image Uploaded');
        this.imageUrl = JSON.parse(response).data.link;
        this.loadImage();
    }

    async loadImage() {
        if(!this.imageUrl) return;
        this.image = new Image;
        this.image.crossOrigin="anonymous"
        this.image.src = this.imageUrl;
    }
    /**
     * @memberof Image
     * function to reset or (internally) set size
     */
    setSize() {
        this.elementWidth = this.cols * 10;
        this.elementHeight = this.rows * 10;
        this.upDimensionY = this.elementHeight/2;
        this.downDimensionY = this.elementHeight/2;
        this.leftDimensionX = this.elementWidth/2;
        this.rightDimensionX = this.elementWidth/2;
    }
}

/**
 * @memberof Image
 * Help Tip
 * @type {string}
 * @category modules
 */
ImageAnnotation.prototype.tooltipText = 'Image ToolTip: Embed an image in the circuit for annotation';
ImageAnnotation.prototype.propagationDelayFixed = true;

/**
 * @memberof Image
 * Mutable properties of the element
 * @type {JSON}
 * @category modules
 */
ImageAnnotation.prototype.mutableProperties = {
    cols: {
        name: 'Columns',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeColSize',
    },
    rows: {
        name: 'Rows',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeRowSize',
    },
};
ImageAnnotation.prototype.objectType = 'ImageAnnotation';
ImageAnnotation.prototype.rectangleObject = false;
ImageAnnotation.prototype.mutableProperties = {
    imageUrl: {
        name: 'Upload Image',
        type: 'button',
        func: 'uploadImage',
    },
    cols: {
        name: 'Columns',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeColSize',
    },
    rows: {
        name: 'Rows',
        type: 'number',
        max: '1000',
        min: '5',
        func: 'changeRowSize',
    },
};