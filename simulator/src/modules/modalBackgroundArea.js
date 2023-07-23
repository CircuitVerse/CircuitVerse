import { dotsOnModal } from './canvasApi';

var modalBackgroundArea;
export default modalBackgroundArea = {
    canvas: document.getElementById('modalBackgroundArea'),
    setup() {
        this.canvas = document.getElementById('modalBackgroundArea');
        this.canvas.width = width;
        this.canvas.height = height;
        this.context = this.canvas.getContext('2d');
        dotsOnModal(true, false);
    },
    clear() {
        if (!this.context) return;
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    },
};
