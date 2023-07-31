import simulationArea from "./simulationArea";

class MoveGesture {
    constructor(listener, circuit, selected) {
        this.listener = listener;
        this.circuit = circuit;
        this.selected = new Set(selected);
        this.connections = null;
        this.initAvoid = null;
        this.cachedResults = new Map();
    }

    getSelected() {
        return simulationArea.selected;
    }

    getConnections() {
        let ret = this.connections;
        if (!ret) {
            ret = computeConnections(this.circuit, this.selected);
            this.connections = ret;
        }
        return ret;
    }

    findResult(dx, dy) {
        const request = new MoveRequest(this, dx, dy);
        return this.cachedResults.get(request);
    }

    enqueueRequest(dx, dy) {
        const request = new MoveRequest(this, dx, dy);
        const result = this.cachedResults.get(request);
        if (!result) {
            ConnectorThread.enqueueRequest(request, false);
            return true;
        } else {
            return false;
        }
    }

}
export default MoveGesture;
