import { dots } from './canvasApi';

let backgroundArea;
export default backgroundArea = {
    canvas: document.getElementById('backgroundArea'),
    setup() {
        this.canvas = document.getElementById('backgroundArea');
        this.canvas.width = width;
        this.canvas.height = height;
        this.context = this.canvas.getContext('2d');
        dots(true, false);
    },
    clear() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    },
};
