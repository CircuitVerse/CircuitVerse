export interface BackgroundArea {
    canvas: HTMLCanvasElement | null;
    context: CanvasRenderingContext2D | null;
    setup(): void;
    clear(): void;
}