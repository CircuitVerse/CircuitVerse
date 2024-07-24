import { BackgroundArea } from './interface/backgroundArea'
import { dots } from './canvasApi';

export const backgroundArea: BackgroundArea = {
    canvas: null,
    context: null,
    setup() {
        this.canvas = document.getElementById('backgroundArea') as HTMLCanvasElement;
        this.canvas.width = width;
        this.canvas.height = height;
        this.context = this.canvas.getContext('2d');
        dots(true, false);
    },
    clear() {
        if (!this.context || !this.canvas) {
            return;
        }
        this.context.clearRect(0, 0, this.canvas.width, this.canvas.height);
    },
};
