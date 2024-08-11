/**
 * @class
 * ContentionPendingData
 *
 * Data structure to store pending contentions in the circuit.
 **/
export default class ContentionPendingData {
	constructor() {
		// Map<Node, Set<Node>>
		this.contentionPendingMap = new Map();
		this.totalContentions = 0;
	}

	// Adds
	add(ourNode, theirNode) {
		if (this.contentionPendingMap.has(ourNode)) {
			if (!this.contentionPendingMap.get(ourNode).has(theirNode)) this.totalContentions++;
			this.contentionPendingMap.get(ourNode).add(theirNode);
			return;
		}

		this.totalContentions++;
		this.contentionPendingMap.set(ourNode, new Set([theirNode]));
	}

	has(ourNode) {
		return this.contentionPendingMap.has(ourNode);
	}

	// Removes contention entry ourNode -> theirNode.
	remove(ourNode, theirNode) {
		if (!this.contentionPendingMap.has(ourNode) || !this.contentionPendingMap.get(ourNode).has(theirNode)) return;

		this.contentionPendingMap.get(ourNode).delete(theirNode);
		if (this.contentionPendingMap.get(ourNode).size == 0) this.contentionPendingMap.delete(ourNode);
		this.totalContentions--;
	}

	// Removes all contentionPending entries for ourNode.
	// Since ourNode is strictly a NODE_OUTPUT, we should remove all contentions for the node when the
	// node resolves.
	removeAllContentionsForNode(ourNode) {
		if (!this.contentionPendingMap.has(ourNode)) return;

		const contentionsForOurNode = this.contentionPendingMap.get(ourNode);
		for (const theirNode of contentionsForOurNode) this.remove(ourNode, theirNode);
	}

	// Removes contention entry ourNode -> theirNode if the contention between them has resolved.
	removeIfResolved(ourNode, theirNode) {
		if (ourNode.bitWidth === theirNode.bitWidth && (ourNode.value === theirNode.value || ourNode.value === undefined))
			this.remove(ourNode, theirNode);
	}

	removeIfResolvedAllContentionsForNode(ourNode) {
		if (!this.contentionPendingMap.has(ourNode)) return;

		const contentionsForOurNode = this.contentionPendingMap.get(ourNode);
		for (const theirNode of contentionsForOurNode) this.removeIfResolved(ourNode, theirNode);
	}

	size() {
		return this.totalContentions;
	}

	// Returns a list of [ourNode, theirNode] for all contentions.
	nodes() {
		var items = [];
		for (const [ourNode, contentionSet] of this.contentionPendingMap) {
			for (const theirNode of contentionSet) items.push([ourNode, theirNode]);
		}

		return items;
	}

}
