(() => {

function $parcel$interopDefault(a) {
  return a && a.__esModule ? a.default : a;
}

function $parcel$defineInteropFlag(a) {
  Object.defineProperty(a, '__esModule', {value: true, configurable: true});
}

function $parcel$export(e, n, v, s) {
  Object.defineProperty(e, n, {get: v, set: s, enumerable: true, configurable: true});
}
// packages/alpinejs/src/scheduler.js
var $caa9439642c6336c$var$flushPending = false;
var $caa9439642c6336c$var$flushing = false;
var $caa9439642c6336c$var$queue = [];
var $caa9439642c6336c$var$lastFlushedIndex = -1;
function $caa9439642c6336c$var$scheduler(callback) {
    $caa9439642c6336c$var$queueJob(callback);
}
function $caa9439642c6336c$var$queueJob(job) {
    if (!$caa9439642c6336c$var$queue.includes(job)) $caa9439642c6336c$var$queue.push(job);
    $caa9439642c6336c$var$queueFlush();
}
function $caa9439642c6336c$var$dequeueJob(job) {
    let index = $caa9439642c6336c$var$queue.indexOf(job);
    if (index !== -1 && index > $caa9439642c6336c$var$lastFlushedIndex) $caa9439642c6336c$var$queue.splice(index, 1);
}
function $caa9439642c6336c$var$queueFlush() {
    if (!$caa9439642c6336c$var$flushing && !$caa9439642c6336c$var$flushPending) {
        $caa9439642c6336c$var$flushPending = true;
        queueMicrotask($caa9439642c6336c$var$flushJobs);
    }
}
function $caa9439642c6336c$var$flushJobs() {
    $caa9439642c6336c$var$flushPending = false;
    $caa9439642c6336c$var$flushing = true;
    for(let i = 0; i < $caa9439642c6336c$var$queue.length; i++){
        $caa9439642c6336c$var$queue[i]();
        $caa9439642c6336c$var$lastFlushedIndex = i;
    }
    $caa9439642c6336c$var$queue.length = 0;
    $caa9439642c6336c$var$lastFlushedIndex = -1;
    $caa9439642c6336c$var$flushing = false;
}
// packages/alpinejs/src/reactivity.js
var $caa9439642c6336c$var$reactive;
var $caa9439642c6336c$var$effect;
var $caa9439642c6336c$var$release;
var $caa9439642c6336c$var$raw;
var $caa9439642c6336c$var$shouldSchedule = true;
function $caa9439642c6336c$var$disableEffectScheduling(callback) {
    $caa9439642c6336c$var$shouldSchedule = false;
    callback();
    $caa9439642c6336c$var$shouldSchedule = true;
}
function $caa9439642c6336c$var$setReactivityEngine(engine) {
    $caa9439642c6336c$var$reactive = engine.reactive;
    $caa9439642c6336c$var$release = engine.release;
    $caa9439642c6336c$var$effect = (callback)=>engine.effect(callback, {
            scheduler: (task)=>{
                if ($caa9439642c6336c$var$shouldSchedule) $caa9439642c6336c$var$scheduler(task);
                else task();
            }
        });
    $caa9439642c6336c$var$raw = engine.raw;
}
function $caa9439642c6336c$var$overrideEffect(override) {
    $caa9439642c6336c$var$effect = override;
}
function $caa9439642c6336c$var$elementBoundEffect(el) {
    let cleanup2 = ()=>{};
    let wrappedEffect = (callback)=>{
        let effectReference = $caa9439642c6336c$var$effect(callback);
        if (!el._x_effects) {
            el._x_effects = /* @__PURE__ */ new Set();
            el._x_runEffects = ()=>{
                el._x_effects.forEach((i)=>i());
            };
        }
        el._x_effects.add(effectReference);
        cleanup2 = ()=>{
            if (effectReference === void 0) return;
            el._x_effects.delete(effectReference);
            $caa9439642c6336c$var$release(effectReference);
        };
        return effectReference;
    };
    return [
        wrappedEffect,
        ()=>{
            cleanup2();
        }
    ];
}
function $caa9439642c6336c$var$watch(getter, callback) {
    let firstTime = true;
    let oldValue;
    let effectReference = $caa9439642c6336c$var$effect(()=>{
        let value = getter();
        JSON.stringify(value);
        if (!firstTime) queueMicrotask(()=>{
            callback(value, oldValue);
            oldValue = value;
        });
        else oldValue = value;
        firstTime = false;
    });
    return ()=>$caa9439642c6336c$var$release(effectReference);
}
// packages/alpinejs/src/mutation.js
var $caa9439642c6336c$var$onAttributeAddeds = [];
var $caa9439642c6336c$var$onElRemoveds = [];
var $caa9439642c6336c$var$onElAddeds = [];
function $caa9439642c6336c$var$onElAdded(callback) {
    $caa9439642c6336c$var$onElAddeds.push(callback);
}
function $caa9439642c6336c$var$onElRemoved(el, callback) {
    if (typeof callback === "function") {
        if (!el._x_cleanups) el._x_cleanups = [];
        el._x_cleanups.push(callback);
    } else {
        callback = el;
        $caa9439642c6336c$var$onElRemoveds.push(callback);
    }
}
function $caa9439642c6336c$var$onAttributesAdded(callback) {
    $caa9439642c6336c$var$onAttributeAddeds.push(callback);
}
function $caa9439642c6336c$var$onAttributeRemoved(el, name, callback) {
    if (!el._x_attributeCleanups) el._x_attributeCleanups = {};
    if (!el._x_attributeCleanups[name]) el._x_attributeCleanups[name] = [];
    el._x_attributeCleanups[name].push(callback);
}
function $caa9439642c6336c$var$cleanupAttributes(el, names) {
    if (!el._x_attributeCleanups) return;
    Object.entries(el._x_attributeCleanups).forEach(([name, value])=>{
        if (names === void 0 || names.includes(name)) {
            value.forEach((i)=>i());
            delete el._x_attributeCleanups[name];
        }
    });
}
function $caa9439642c6336c$var$cleanupElement(el) {
    el._x_effects?.forEach($caa9439642c6336c$var$dequeueJob);
    while(el._x_cleanups?.length)el._x_cleanups.pop()();
}
var $caa9439642c6336c$var$observer = new MutationObserver($caa9439642c6336c$var$onMutate);
var $caa9439642c6336c$var$currentlyObserving = false;
function $caa9439642c6336c$var$startObservingMutations() {
    $caa9439642c6336c$var$observer.observe(document, {
        subtree: true,
        childList: true,
        attributes: true,
        attributeOldValue: true
    });
    $caa9439642c6336c$var$currentlyObserving = true;
}
function $caa9439642c6336c$var$stopObservingMutations() {
    $caa9439642c6336c$var$flushObserver();
    $caa9439642c6336c$var$observer.disconnect();
    $caa9439642c6336c$var$currentlyObserving = false;
}
var $caa9439642c6336c$var$queuedMutations = [];
function $caa9439642c6336c$var$flushObserver() {
    let records = $caa9439642c6336c$var$observer.takeRecords();
    $caa9439642c6336c$var$queuedMutations.push(()=>records.length > 0 && $caa9439642c6336c$var$onMutate(records));
    let queueLengthWhenTriggered = $caa9439642c6336c$var$queuedMutations.length;
    queueMicrotask(()=>{
        if ($caa9439642c6336c$var$queuedMutations.length === queueLengthWhenTriggered) while($caa9439642c6336c$var$queuedMutations.length > 0)$caa9439642c6336c$var$queuedMutations.shift()();
    });
}
function $caa9439642c6336c$var$mutateDom(callback) {
    if (!$caa9439642c6336c$var$currentlyObserving) return callback();
    $caa9439642c6336c$var$stopObservingMutations();
    let result = callback();
    $caa9439642c6336c$var$startObservingMutations();
    return result;
}
var $caa9439642c6336c$var$isCollecting = false;
var $caa9439642c6336c$var$deferredMutations = [];
function $caa9439642c6336c$var$deferMutations() {
    $caa9439642c6336c$var$isCollecting = true;
}
function $caa9439642c6336c$var$flushAndStopDeferringMutations() {
    $caa9439642c6336c$var$isCollecting = false;
    $caa9439642c6336c$var$onMutate($caa9439642c6336c$var$deferredMutations);
    $caa9439642c6336c$var$deferredMutations = [];
}
function $caa9439642c6336c$var$onMutate(mutations) {
    if ($caa9439642c6336c$var$isCollecting) {
        $caa9439642c6336c$var$deferredMutations = $caa9439642c6336c$var$deferredMutations.concat(mutations);
        return;
    }
    let addedNodes = [];
    let removedNodes = /* @__PURE__ */ new Set();
    let addedAttributes = /* @__PURE__ */ new Map();
    let removedAttributes = /* @__PURE__ */ new Map();
    for(let i = 0; i < mutations.length; i++){
        if (mutations[i].target._x_ignoreMutationObserver) continue;
        if (mutations[i].type === "childList") {
            mutations[i].removedNodes.forEach((node)=>{
                if (node.nodeType !== 1) return;
                if (!node._x_marker) return;
                removedNodes.add(node);
            });
            mutations[i].addedNodes.forEach((node)=>{
                if (node.nodeType !== 1) return;
                if (removedNodes.has(node)) {
                    removedNodes.delete(node);
                    return;
                }
                if (node._x_marker) return;
                addedNodes.push(node);
            });
        }
        if (mutations[i].type === "attributes") {
            let el = mutations[i].target;
            let name = mutations[i].attributeName;
            let oldValue = mutations[i].oldValue;
            let add2 = ()=>{
                if (!addedAttributes.has(el)) addedAttributes.set(el, []);
                addedAttributes.get(el).push({
                    name: name,
                    value: el.getAttribute(name)
                });
            };
            let remove = ()=>{
                if (!removedAttributes.has(el)) removedAttributes.set(el, []);
                removedAttributes.get(el).push(name);
            };
            if (el.hasAttribute(name) && oldValue === null) add2();
            else if (el.hasAttribute(name)) {
                remove();
                add2();
            } else remove();
        }
    }
    removedAttributes.forEach((attrs, el)=>{
        $caa9439642c6336c$var$cleanupAttributes(el, attrs);
    });
    addedAttributes.forEach((attrs, el)=>{
        $caa9439642c6336c$var$onAttributeAddeds.forEach((i)=>i(el, attrs));
    });
    for (let node of removedNodes){
        if (addedNodes.some((i)=>i.contains(node))) continue;
        $caa9439642c6336c$var$onElRemoveds.forEach((i)=>i(node));
    }
    for (let node of addedNodes){
        if (!node.isConnected) continue;
        $caa9439642c6336c$var$onElAddeds.forEach((i)=>i(node));
    }
    addedNodes = null;
    removedNodes = null;
    addedAttributes = null;
    removedAttributes = null;
}
// packages/alpinejs/src/scope.js
function $caa9439642c6336c$var$scope(node) {
    return $caa9439642c6336c$var$mergeProxies($caa9439642c6336c$var$closestDataStack(node));
}
function $caa9439642c6336c$var$addScopeToNode(node, data2, referenceNode) {
    node._x_dataStack = [
        data2,
        ...$caa9439642c6336c$var$closestDataStack(referenceNode || node)
    ];
    return ()=>{
        node._x_dataStack = node._x_dataStack.filter((i)=>i !== data2);
    };
}
function $caa9439642c6336c$var$closestDataStack(node) {
    if (node._x_dataStack) return node._x_dataStack;
    if (typeof ShadowRoot === "function" && node instanceof ShadowRoot) return $caa9439642c6336c$var$closestDataStack(node.host);
    if (!node.parentNode) return [];
    return $caa9439642c6336c$var$closestDataStack(node.parentNode);
}
function $caa9439642c6336c$var$mergeProxies(objects) {
    return new Proxy({
        objects: objects
    }, $caa9439642c6336c$var$mergeProxyTrap);
}
var $caa9439642c6336c$var$mergeProxyTrap = {
    ownKeys ({ objects: objects }) {
        return Array.from(new Set(objects.flatMap((i)=>Object.keys(i))));
    },
    has ({ objects: objects }, name) {
        if (name == Symbol.unscopables) return false;
        return objects.some((obj)=>Object.prototype.hasOwnProperty.call(obj, name) || Reflect.has(obj, name));
    },
    get ({ objects: objects }, name, thisProxy) {
        if (name == "toJSON") return $caa9439642c6336c$var$collapseProxies;
        return Reflect.get(objects.find((obj)=>Reflect.has(obj, name)) || {}, name, thisProxy);
    },
    set ({ objects: objects }, name, value, thisProxy) {
        const target = objects.find((obj)=>Object.prototype.hasOwnProperty.call(obj, name)) || objects[objects.length - 1];
        const descriptor = Object.getOwnPropertyDescriptor(target, name);
        if (descriptor?.set && descriptor?.get) return descriptor.set.call(thisProxy, value) || true;
        return Reflect.set(target, name, value);
    }
};
function $caa9439642c6336c$var$collapseProxies() {
    let keys = Reflect.ownKeys(this);
    return keys.reduce((acc, key)=>{
        acc[key] = Reflect.get(this, key);
        return acc;
    }, {});
}
// packages/alpinejs/src/interceptor.js
function $caa9439642c6336c$var$initInterceptors(data2) {
    let isObject2 = (val)=>typeof val === "object" && !Array.isArray(val) && val !== null;
    let recurse = (obj, basePath = "")=>{
        Object.entries(Object.getOwnPropertyDescriptors(obj)).forEach(([key, { value: value, enumerable: enumerable }])=>{
            if (enumerable === false || value === void 0) return;
            if (typeof value === "object" && value !== null && value.__v_skip) return;
            let path = basePath === "" ? key : `${basePath}.${key}`;
            if (typeof value === "object" && value !== null && value._x_interceptor) obj[key] = value.initialize(data2, path, key);
            else if (isObject2(value) && value !== obj && !(value instanceof Element)) recurse(value, path);
        });
    };
    return recurse(data2);
}
function $caa9439642c6336c$var$interceptor(callback, mutateObj = ()=>{}) {
    let obj = {
        initialValue: void 0,
        _x_interceptor: true,
        initialize (data2, path, key) {
            return callback(this.initialValue, ()=>$caa9439642c6336c$var$get(data2, path), (value)=>$caa9439642c6336c$var$set(data2, path, value), path, key);
        }
    };
    mutateObj(obj);
    return (initialValue)=>{
        if (typeof initialValue === "object" && initialValue !== null && initialValue._x_interceptor) {
            let initialize = obj.initialize.bind(obj);
            obj.initialize = (data2, path, key)=>{
                let innerValue = initialValue.initialize(data2, path, key);
                obj.initialValue = innerValue;
                return initialize(data2, path, key);
            };
        } else obj.initialValue = initialValue;
        return obj;
    };
}
function $caa9439642c6336c$var$get(obj, path) {
    return path.split(".").reduce((carry, segment)=>carry[segment], obj);
}
function $caa9439642c6336c$var$set(obj, path, value) {
    if (typeof path === "string") path = path.split(".");
    if (path.length === 1) obj[path[0]] = value;
    else if (path.length === 0) throw error;
    else {
        if (obj[path[0]]) return $caa9439642c6336c$var$set(obj[path[0]], path.slice(1), value);
        else {
            obj[path[0]] = {};
            return $caa9439642c6336c$var$set(obj[path[0]], path.slice(1), value);
        }
    }
}
// packages/alpinejs/src/magics.js
var $caa9439642c6336c$var$magics = {};
function $caa9439642c6336c$var$magic(name, callback) {
    $caa9439642c6336c$var$magics[name] = callback;
}
function $caa9439642c6336c$var$injectMagics(obj, el) {
    let memoizedUtilities = $caa9439642c6336c$var$getUtilities(el);
    Object.entries($caa9439642c6336c$var$magics).forEach(([name, callback])=>{
        Object.defineProperty(obj, `$${name}`, {
            get () {
                return callback(el, memoizedUtilities);
            },
            enumerable: false
        });
    });
    return obj;
}
function $caa9439642c6336c$var$getUtilities(el) {
    let [utilities, cleanup2] = $caa9439642c6336c$var$getElementBoundUtilities(el);
    let utils = {
        interceptor: $caa9439642c6336c$var$interceptor,
        ...utilities
    };
    $caa9439642c6336c$var$onElRemoved(el, cleanup2);
    return utils;
}
// packages/alpinejs/src/utils/error.js
function $caa9439642c6336c$var$tryCatch(el, expression, callback, ...args) {
    try {
        return callback(...args);
    } catch (e) {
        $caa9439642c6336c$var$handleError(e, el, expression);
    }
}
function $caa9439642c6336c$var$handleError(error2, el, expression) {
    error2 = Object.assign(error2 ?? {
        message: "No error message given."
    }, {
        el: el,
        expression: expression
    });
    console.warn(`Alpine Expression Error: ${error2.message}

${expression ? 'Expression: "' + expression + '"\n\n' : ""}`, el);
    setTimeout(()=>{
        throw error2;
    }, 0);
}
// packages/alpinejs/src/evaluator.js
var $caa9439642c6336c$var$shouldAutoEvaluateFunctions = true;
function $caa9439642c6336c$var$dontAutoEvaluateFunctions(callback) {
    let cache = $caa9439642c6336c$var$shouldAutoEvaluateFunctions;
    $caa9439642c6336c$var$shouldAutoEvaluateFunctions = false;
    let result = callback();
    $caa9439642c6336c$var$shouldAutoEvaluateFunctions = cache;
    return result;
}
function $caa9439642c6336c$var$evaluate(el, expression, extras = {}) {
    let result;
    $caa9439642c6336c$var$evaluateLater(el, expression)((value)=>result = value, extras);
    return result;
}
function $caa9439642c6336c$var$evaluateLater(...args) {
    return $caa9439642c6336c$var$theEvaluatorFunction(...args);
}
var $caa9439642c6336c$var$theEvaluatorFunction = $caa9439642c6336c$var$normalEvaluator;
function $caa9439642c6336c$var$setEvaluator(newEvaluator) {
    $caa9439642c6336c$var$theEvaluatorFunction = newEvaluator;
}
function $caa9439642c6336c$var$normalEvaluator(el, expression) {
    let overriddenMagics = {};
    $caa9439642c6336c$var$injectMagics(overriddenMagics, el);
    let dataStack = [
        overriddenMagics,
        ...$caa9439642c6336c$var$closestDataStack(el)
    ];
    let evaluator = typeof expression === "function" ? $caa9439642c6336c$var$generateEvaluatorFromFunction(dataStack, expression) : $caa9439642c6336c$var$generateEvaluatorFromString(dataStack, expression, el);
    return $caa9439642c6336c$var$tryCatch.bind(null, el, expression, evaluator);
}
function $caa9439642c6336c$var$generateEvaluatorFromFunction(dataStack, func) {
    return (receiver = ()=>{}, { scope: scope2 = {}, params: params = [] } = {})=>{
        let result = func.apply($caa9439642c6336c$var$mergeProxies([
            scope2,
            ...dataStack
        ]), params);
        $caa9439642c6336c$var$runIfTypeOfFunction(receiver, result);
    };
}
var $caa9439642c6336c$var$evaluatorMemo = {};
function $caa9439642c6336c$var$generateFunctionFromString(expression, el) {
    if ($caa9439642c6336c$var$evaluatorMemo[expression]) return $caa9439642c6336c$var$evaluatorMemo[expression];
    let AsyncFunction = Object.getPrototypeOf(async function() {}).constructor;
    let rightSideSafeExpression = /^[\n\s]*if.*\(.*\)/.test(expression.trim()) || /^(let|const)\s/.test(expression.trim()) ? `(async()=>{ ${expression} })()` : expression;
    const safeAsyncFunction = ()=>{
        try {
            let func2 = new AsyncFunction([
                "__self",
                "scope"
            ], `with (scope) { __self.result = ${rightSideSafeExpression} }; __self.finished = true; return __self.result;`);
            Object.defineProperty(func2, "name", {
                value: `[Alpine] ${expression}`
            });
            return func2;
        } catch (error2) {
            $caa9439642c6336c$var$handleError(error2, el, expression);
            return Promise.resolve();
        }
    };
    let func = safeAsyncFunction();
    $caa9439642c6336c$var$evaluatorMemo[expression] = func;
    return func;
}
function $caa9439642c6336c$var$generateEvaluatorFromString(dataStack, expression, el) {
    let func = $caa9439642c6336c$var$generateFunctionFromString(expression, el);
    return (receiver = ()=>{}, { scope: scope2 = {}, params: params = [] } = {})=>{
        func.result = void 0;
        func.finished = false;
        let completeScope = $caa9439642c6336c$var$mergeProxies([
            scope2,
            ...dataStack
        ]);
        if (typeof func === "function") {
            let promise = func(func, completeScope).catch((error2)=>$caa9439642c6336c$var$handleError(error2, el, expression));
            if (func.finished) {
                $caa9439642c6336c$var$runIfTypeOfFunction(receiver, func.result, completeScope, params, el);
                func.result = void 0;
            } else promise.then((result)=>{
                $caa9439642c6336c$var$runIfTypeOfFunction(receiver, result, completeScope, params, el);
            }).catch((error2)=>$caa9439642c6336c$var$handleError(error2, el, expression)).finally(()=>func.result = void 0);
        }
    };
}
function $caa9439642c6336c$var$runIfTypeOfFunction(receiver, value, scope2, params, el) {
    if ($caa9439642c6336c$var$shouldAutoEvaluateFunctions && typeof value === "function") {
        let result = value.apply(scope2, params);
        if (result instanceof Promise) result.then((i)=>$caa9439642c6336c$var$runIfTypeOfFunction(receiver, i, scope2, params)).catch((error2)=>$caa9439642c6336c$var$handleError(error2, el, value));
        else receiver(result);
    } else if (typeof value === "object" && value instanceof Promise) value.then((i)=>receiver(i));
    else receiver(value);
}
// packages/alpinejs/src/directives.js
var $caa9439642c6336c$var$prefixAsString = "x-";
function $caa9439642c6336c$var$prefix(subject = "") {
    return $caa9439642c6336c$var$prefixAsString + subject;
}
function $caa9439642c6336c$var$setPrefix(newPrefix) {
    $caa9439642c6336c$var$prefixAsString = newPrefix;
}
var $caa9439642c6336c$var$directiveHandlers = {};
function $caa9439642c6336c$var$directive(name, callback) {
    $caa9439642c6336c$var$directiveHandlers[name] = callback;
    return {
        before (directive2) {
            if (!$caa9439642c6336c$var$directiveHandlers[directive2]) {
                console.warn(String.raw`Cannot find directive \`${directive2}\`. \`${name}\` will use the default order of execution`);
                return;
            }
            const pos = $caa9439642c6336c$var$directiveOrder.indexOf(directive2);
            $caa9439642c6336c$var$directiveOrder.splice(pos >= 0 ? pos : $caa9439642c6336c$var$directiveOrder.indexOf("DEFAULT"), 0, name);
        }
    };
}
function $caa9439642c6336c$var$directiveExists(name) {
    return Object.keys($caa9439642c6336c$var$directiveHandlers).includes(name);
}
function $caa9439642c6336c$var$directives(el, attributes, originalAttributeOverride) {
    attributes = Array.from(attributes);
    if (el._x_virtualDirectives) {
        let vAttributes = Object.entries(el._x_virtualDirectives).map(([name, value])=>({
                name: name,
                value: value
            }));
        let staticAttributes = $caa9439642c6336c$var$attributesOnly(vAttributes);
        vAttributes = vAttributes.map((attribute)=>{
            if (staticAttributes.find((attr)=>attr.name === attribute.name)) return {
                name: `x-bind:${attribute.name}`,
                value: `"${attribute.value}"`
            };
            return attribute;
        });
        attributes = attributes.concat(vAttributes);
    }
    let transformedAttributeMap = {};
    let directives2 = attributes.map($caa9439642c6336c$var$toTransformedAttributes((newName, oldName)=>transformedAttributeMap[newName] = oldName)).filter($caa9439642c6336c$var$outNonAlpineAttributes).map($caa9439642c6336c$var$toParsedDirectives(transformedAttributeMap, originalAttributeOverride)).sort($caa9439642c6336c$var$byPriority);
    return directives2.map((directive2)=>{
        return $caa9439642c6336c$var$getDirectiveHandler(el, directive2);
    });
}
function $caa9439642c6336c$var$attributesOnly(attributes) {
    return Array.from(attributes).map($caa9439642c6336c$var$toTransformedAttributes()).filter((attr)=>!$caa9439642c6336c$var$outNonAlpineAttributes(attr));
}
var $caa9439642c6336c$var$isDeferringHandlers = false;
var $caa9439642c6336c$var$directiveHandlerStacks = /* @__PURE__ */ new Map();
var $caa9439642c6336c$var$currentHandlerStackKey = Symbol();
function $caa9439642c6336c$var$deferHandlingDirectives(callback) {
    $caa9439642c6336c$var$isDeferringHandlers = true;
    let key = Symbol();
    $caa9439642c6336c$var$currentHandlerStackKey = key;
    $caa9439642c6336c$var$directiveHandlerStacks.set(key, []);
    let flushHandlers = ()=>{
        while($caa9439642c6336c$var$directiveHandlerStacks.get(key).length)$caa9439642c6336c$var$directiveHandlerStacks.get(key).shift()();
        $caa9439642c6336c$var$directiveHandlerStacks.delete(key);
    };
    let stopDeferring = ()=>{
        $caa9439642c6336c$var$isDeferringHandlers = false;
        flushHandlers();
    };
    callback(flushHandlers);
    stopDeferring();
}
function $caa9439642c6336c$var$getElementBoundUtilities(el) {
    let cleanups = [];
    let cleanup2 = (callback)=>cleanups.push(callback);
    let [effect3, cleanupEffect] = $caa9439642c6336c$var$elementBoundEffect(el);
    cleanups.push(cleanupEffect);
    let utilities = {
        Alpine: $caa9439642c6336c$var$alpine_default,
        effect: effect3,
        cleanup: cleanup2,
        evaluateLater: $caa9439642c6336c$var$evaluateLater.bind($caa9439642c6336c$var$evaluateLater, el),
        evaluate: $caa9439642c6336c$var$evaluate.bind($caa9439642c6336c$var$evaluate, el)
    };
    let doCleanup = ()=>cleanups.forEach((i)=>i());
    return [
        utilities,
        doCleanup
    ];
}
function $caa9439642c6336c$var$getDirectiveHandler(el, directive2) {
    let noop = ()=>{};
    let handler4 = $caa9439642c6336c$var$directiveHandlers[directive2.type] || noop;
    let [utilities, cleanup2] = $caa9439642c6336c$var$getElementBoundUtilities(el);
    $caa9439642c6336c$var$onAttributeRemoved(el, directive2.original, cleanup2);
    let fullHandler = ()=>{
        if (el._x_ignore || el._x_ignoreSelf) return;
        handler4.inline && handler4.inline(el, directive2, utilities);
        handler4 = handler4.bind(handler4, el, directive2, utilities);
        $caa9439642c6336c$var$isDeferringHandlers ? $caa9439642c6336c$var$directiveHandlerStacks.get($caa9439642c6336c$var$currentHandlerStackKey).push(handler4) : handler4();
    };
    fullHandler.runCleanups = cleanup2;
    return fullHandler;
}
var $caa9439642c6336c$var$startingWith = (subject, replacement)=>({ name: name, value: value })=>{
        if (name.startsWith(subject)) name = name.replace(subject, replacement);
        return {
            name: name,
            value: value
        };
    };
var $caa9439642c6336c$var$into = (i)=>i;
function $caa9439642c6336c$var$toTransformedAttributes(callback = ()=>{}) {
    return ({ name: name, value: value })=>{
        let { name: newName, value: newValue } = $caa9439642c6336c$var$attributeTransformers.reduce((carry, transform)=>{
            return transform(carry);
        }, {
            name: name,
            value: value
        });
        if (newName !== name) callback(newName, name);
        return {
            name: newName,
            value: newValue
        };
    };
}
var $caa9439642c6336c$var$attributeTransformers = [];
function $caa9439642c6336c$var$mapAttributes(callback) {
    $caa9439642c6336c$var$attributeTransformers.push(callback);
}
function $caa9439642c6336c$var$outNonAlpineAttributes({ name: name }) {
    return $caa9439642c6336c$var$alpineAttributeRegex().test(name);
}
var $caa9439642c6336c$var$alpineAttributeRegex = ()=>new RegExp(`^${$caa9439642c6336c$var$prefixAsString}([^:^.]+)\\b`);
function $caa9439642c6336c$var$toParsedDirectives(transformedAttributeMap, originalAttributeOverride) {
    return ({ name: name, value: value })=>{
        let typeMatch = name.match($caa9439642c6336c$var$alpineAttributeRegex());
        let valueMatch = name.match(/:([a-zA-Z0-9\-_:]+)/);
        let modifiers = name.match(/\.[^.\]]+(?=[^\]]*$)/g) || [];
        let original = originalAttributeOverride || transformedAttributeMap[name] || name;
        return {
            type: typeMatch ? typeMatch[1] : null,
            value: valueMatch ? valueMatch[1] : null,
            modifiers: modifiers.map((i)=>i.replace(".", "")),
            expression: value,
            original: original
        };
    };
}
var $caa9439642c6336c$var$DEFAULT = "DEFAULT";
var $caa9439642c6336c$var$directiveOrder = [
    "ignore",
    "ref",
    "data",
    "id",
    "anchor",
    "bind",
    "init",
    "for",
    "model",
    "modelable",
    "transition",
    "show",
    "if",
    $caa9439642c6336c$var$DEFAULT,
    "teleport"
];
function $caa9439642c6336c$var$byPriority(a, b) {
    let typeA = $caa9439642c6336c$var$directiveOrder.indexOf(a.type) === -1 ? $caa9439642c6336c$var$DEFAULT : a.type;
    let typeB = $caa9439642c6336c$var$directiveOrder.indexOf(b.type) === -1 ? $caa9439642c6336c$var$DEFAULT : b.type;
    return $caa9439642c6336c$var$directiveOrder.indexOf(typeA) - $caa9439642c6336c$var$directiveOrder.indexOf(typeB);
}
// packages/alpinejs/src/utils/dispatch.js
function $caa9439642c6336c$var$dispatch(el, name, detail = {}) {
    el.dispatchEvent(new CustomEvent(name, {
        detail: detail,
        bubbles: true,
        // Allows events to pass the shadow DOM barrier.
        composed: true,
        cancelable: true
    }));
}
// packages/alpinejs/src/utils/walk.js
function $caa9439642c6336c$var$walk(el, callback) {
    if (typeof ShadowRoot === "function" && el instanceof ShadowRoot) {
        Array.from(el.children).forEach((el2)=>$caa9439642c6336c$var$walk(el2, callback));
        return;
    }
    let skip = false;
    callback(el, ()=>skip = true);
    if (skip) return;
    let node = el.firstElementChild;
    while(node){
        $caa9439642c6336c$var$walk(node, callback, false);
        node = node.nextElementSibling;
    }
}
// packages/alpinejs/src/utils/warn.js
function $caa9439642c6336c$var$warn(message, ...args) {
    console.warn(`Alpine Warning: ${message}`, ...args);
}
// packages/alpinejs/src/lifecycle.js
var $caa9439642c6336c$var$started = false;
function $caa9439642c6336c$var$start() {
    if ($caa9439642c6336c$var$started) $caa9439642c6336c$var$warn("Alpine has already been initialized on this page. Calling Alpine.start() more than once can cause problems.");
    $caa9439642c6336c$var$started = true;
    if (!document.body) $caa9439642c6336c$var$warn("Unable to initialize. Trying to load Alpine before `<body>` is available. Did you forget to add `defer` in Alpine's `<script>` tag?");
    $caa9439642c6336c$var$dispatch(document, "alpine:init");
    $caa9439642c6336c$var$dispatch(document, "alpine:initializing");
    $caa9439642c6336c$var$startObservingMutations();
    $caa9439642c6336c$var$onElAdded((el)=>$caa9439642c6336c$var$initTree(el, $caa9439642c6336c$var$walk));
    $caa9439642c6336c$var$onElRemoved((el)=>$caa9439642c6336c$var$destroyTree(el));
    $caa9439642c6336c$var$onAttributesAdded((el, attrs)=>{
        $caa9439642c6336c$var$directives(el, attrs).forEach((handle)=>handle());
    });
    let outNestedComponents = (el)=>!$caa9439642c6336c$var$closestRoot(el.parentElement, true);
    Array.from(document.querySelectorAll($caa9439642c6336c$var$allSelectors().join(","))).filter(outNestedComponents).forEach((el)=>{
        $caa9439642c6336c$var$initTree(el);
    });
    $caa9439642c6336c$var$dispatch(document, "alpine:initialized");
    setTimeout(()=>{
        $caa9439642c6336c$var$warnAboutMissingPlugins();
    });
}
var $caa9439642c6336c$var$rootSelectorCallbacks = [];
var $caa9439642c6336c$var$initSelectorCallbacks = [];
function $caa9439642c6336c$var$rootSelectors() {
    return $caa9439642c6336c$var$rootSelectorCallbacks.map((fn)=>fn());
}
function $caa9439642c6336c$var$allSelectors() {
    return $caa9439642c6336c$var$rootSelectorCallbacks.concat($caa9439642c6336c$var$initSelectorCallbacks).map((fn)=>fn());
}
function $caa9439642c6336c$var$addRootSelector(selectorCallback) {
    $caa9439642c6336c$var$rootSelectorCallbacks.push(selectorCallback);
}
function $caa9439642c6336c$var$addInitSelector(selectorCallback) {
    $caa9439642c6336c$var$initSelectorCallbacks.push(selectorCallback);
}
function $caa9439642c6336c$var$closestRoot(el, includeInitSelectors = false) {
    return $caa9439642c6336c$var$findClosest(el, (element)=>{
        const selectors = includeInitSelectors ? $caa9439642c6336c$var$allSelectors() : $caa9439642c6336c$var$rootSelectors();
        if (selectors.some((selector)=>element.matches(selector))) return true;
    });
}
function $caa9439642c6336c$var$findClosest(el, callback) {
    if (!el) return;
    if (callback(el)) return el;
    if (el._x_teleportBack) el = el._x_teleportBack;
    if (!el.parentElement) return;
    return $caa9439642c6336c$var$findClosest(el.parentElement, callback);
}
function $caa9439642c6336c$var$isRoot(el) {
    return $caa9439642c6336c$var$rootSelectors().some((selector)=>el.matches(selector));
}
var $caa9439642c6336c$var$initInterceptors2 = [];
function $caa9439642c6336c$var$interceptInit(callback) {
    $caa9439642c6336c$var$initInterceptors2.push(callback);
}
var $caa9439642c6336c$var$markerDispenser = 1;
function $caa9439642c6336c$var$initTree(el, walker = $caa9439642c6336c$var$walk, intercept = ()=>{}) {
    if ($caa9439642c6336c$var$findClosest(el, (i)=>i._x_ignore)) return;
    $caa9439642c6336c$var$deferHandlingDirectives(()=>{
        walker(el, (el2, skip)=>{
            if (el2._x_marker) return;
            intercept(el2, skip);
            $caa9439642c6336c$var$initInterceptors2.forEach((i)=>i(el2, skip));
            $caa9439642c6336c$var$directives(el2, el2.attributes).forEach((handle)=>handle());
            if (!el2._x_ignore) el2._x_marker = $caa9439642c6336c$var$markerDispenser++;
            el2._x_ignore && skip();
        });
    });
}
function $caa9439642c6336c$var$destroyTree(root, walker = $caa9439642c6336c$var$walk) {
    walker(root, (el)=>{
        $caa9439642c6336c$var$cleanupElement(el);
        $caa9439642c6336c$var$cleanupAttributes(el);
        delete el._x_marker;
    });
}
function $caa9439642c6336c$var$warnAboutMissingPlugins() {
    let pluginDirectives = [
        [
            "ui",
            "dialog",
            [
                "[x-dialog], [x-popover]"
            ]
        ],
        [
            "anchor",
            "anchor",
            [
                "[x-anchor]"
            ]
        ],
        [
            "sort",
            "sort",
            [
                "[x-sort]"
            ]
        ]
    ];
    pluginDirectives.forEach(([plugin2, directive2, selectors])=>{
        if ($caa9439642c6336c$var$directiveExists(directive2)) return;
        selectors.some((selector)=>{
            if (document.querySelector(selector)) {
                $caa9439642c6336c$var$warn(`found "${selector}", but missing ${plugin2} plugin`);
                return true;
            }
        });
    });
}
// packages/alpinejs/src/nextTick.js
var $caa9439642c6336c$var$tickStack = [];
var $caa9439642c6336c$var$isHolding = false;
function $caa9439642c6336c$var$nextTick(callback = ()=>{}) {
    queueMicrotask(()=>{
        $caa9439642c6336c$var$isHolding || setTimeout(()=>{
            $caa9439642c6336c$var$releaseNextTicks();
        });
    });
    return new Promise((res)=>{
        $caa9439642c6336c$var$tickStack.push(()=>{
            callback();
            res();
        });
    });
}
function $caa9439642c6336c$var$releaseNextTicks() {
    $caa9439642c6336c$var$isHolding = false;
    while($caa9439642c6336c$var$tickStack.length)$caa9439642c6336c$var$tickStack.shift()();
}
function $caa9439642c6336c$var$holdNextTicks() {
    $caa9439642c6336c$var$isHolding = true;
}
// packages/alpinejs/src/utils/classes.js
function $caa9439642c6336c$var$setClasses(el, value) {
    if (Array.isArray(value)) return $caa9439642c6336c$var$setClassesFromString(el, value.join(" "));
    else if (typeof value === "object" && value !== null) return $caa9439642c6336c$var$setClassesFromObject(el, value);
    else if (typeof value === "function") return $caa9439642c6336c$var$setClasses(el, value());
    return $caa9439642c6336c$var$setClassesFromString(el, value);
}
function $caa9439642c6336c$var$setClassesFromString(el, classString) {
    let split = (classString2)=>classString2.split(" ").filter(Boolean);
    let missingClasses = (classString2)=>classString2.split(" ").filter((i)=>!el.classList.contains(i)).filter(Boolean);
    let addClassesAndReturnUndo = (classes)=>{
        el.classList.add(...classes);
        return ()=>{
            el.classList.remove(...classes);
        };
    };
    classString = classString === true ? classString = "" : classString || "";
    return addClassesAndReturnUndo(missingClasses(classString));
}
function $caa9439642c6336c$var$setClassesFromObject(el, classObject) {
    let split = (classString)=>classString.split(" ").filter(Boolean);
    let forAdd = Object.entries(classObject).flatMap(([classString, bool])=>bool ? split(classString) : false).filter(Boolean);
    let forRemove = Object.entries(classObject).flatMap(([classString, bool])=>!bool ? split(classString) : false).filter(Boolean);
    let added = [];
    let removed = [];
    forRemove.forEach((i)=>{
        if (el.classList.contains(i)) {
            el.classList.remove(i);
            removed.push(i);
        }
    });
    forAdd.forEach((i)=>{
        if (!el.classList.contains(i)) {
            el.classList.add(i);
            added.push(i);
        }
    });
    return ()=>{
        removed.forEach((i)=>el.classList.add(i));
        added.forEach((i)=>el.classList.remove(i));
    };
}
// packages/alpinejs/src/utils/styles.js
function $caa9439642c6336c$var$setStyles(el, value) {
    if (typeof value === "object" && value !== null) return $caa9439642c6336c$var$setStylesFromObject(el, value);
    return $caa9439642c6336c$var$setStylesFromString(el, value);
}
function $caa9439642c6336c$var$setStylesFromObject(el, value) {
    let previousStyles = {};
    Object.entries(value).forEach(([key, value2])=>{
        previousStyles[key] = el.style[key];
        if (!key.startsWith("--")) key = $caa9439642c6336c$var$kebabCase(key);
        el.style.setProperty(key, value2);
    });
    setTimeout(()=>{
        if (el.style.length === 0) el.removeAttribute("style");
    });
    return ()=>{
        $caa9439642c6336c$var$setStyles(el, previousStyles);
    };
}
function $caa9439642c6336c$var$setStylesFromString(el, value) {
    let cache = el.getAttribute("style", value);
    el.setAttribute("style", value);
    return ()=>{
        el.setAttribute("style", cache || "");
    };
}
function $caa9439642c6336c$var$kebabCase(subject) {
    return subject.replace(/([a-z])([A-Z])/g, "$1-$2").toLowerCase();
}
// packages/alpinejs/src/utils/once.js
function $caa9439642c6336c$var$once(callback, fallback = ()=>{}) {
    let called = false;
    return function() {
        if (!called) {
            called = true;
            callback.apply(this, arguments);
        } else fallback.apply(this, arguments);
    };
}
// packages/alpinejs/src/directives/x-transition.js
$caa9439642c6336c$var$directive("transition", (el, { value: value, modifiers: modifiers, expression: expression }, { evaluate: evaluate2 })=>{
    if (typeof expression === "function") expression = evaluate2(expression);
    if (expression === false) return;
    if (!expression || typeof expression === "boolean") $caa9439642c6336c$var$registerTransitionsFromHelper(el, modifiers, value);
    else $caa9439642c6336c$var$registerTransitionsFromClassString(el, expression, value);
});
function $caa9439642c6336c$var$registerTransitionsFromClassString(el, classString, stage) {
    $caa9439642c6336c$var$registerTransitionObject(el, $caa9439642c6336c$var$setClasses, "");
    let directiveStorageMap = {
        "enter": (classes)=>{
            el._x_transition.enter.during = classes;
        },
        "enter-start": (classes)=>{
            el._x_transition.enter.start = classes;
        },
        "enter-end": (classes)=>{
            el._x_transition.enter.end = classes;
        },
        "leave": (classes)=>{
            el._x_transition.leave.during = classes;
        },
        "leave-start": (classes)=>{
            el._x_transition.leave.start = classes;
        },
        "leave-end": (classes)=>{
            el._x_transition.leave.end = classes;
        }
    };
    directiveStorageMap[stage](classString);
}
function $caa9439642c6336c$var$registerTransitionsFromHelper(el, modifiers, stage) {
    $caa9439642c6336c$var$registerTransitionObject(el, $caa9439642c6336c$var$setStyles);
    let doesntSpecify = !modifiers.includes("in") && !modifiers.includes("out") && !stage;
    let transitioningIn = doesntSpecify || modifiers.includes("in") || [
        "enter"
    ].includes(stage);
    let transitioningOut = doesntSpecify || modifiers.includes("out") || [
        "leave"
    ].includes(stage);
    if (modifiers.includes("in") && !doesntSpecify) modifiers = modifiers.filter((i, index)=>index < modifiers.indexOf("out"));
    if (modifiers.includes("out") && !doesntSpecify) modifiers = modifiers.filter((i, index)=>index > modifiers.indexOf("out"));
    let wantsAll = !modifiers.includes("opacity") && !modifiers.includes("scale");
    let wantsOpacity = wantsAll || modifiers.includes("opacity");
    let wantsScale = wantsAll || modifiers.includes("scale");
    let opacityValue = wantsOpacity ? 0 : 1;
    let scaleValue = wantsScale ? $caa9439642c6336c$var$modifierValue(modifiers, "scale", 95) / 100 : 1;
    let delay = $caa9439642c6336c$var$modifierValue(modifiers, "delay", 0) / 1e3;
    let origin = $caa9439642c6336c$var$modifierValue(modifiers, "origin", "center");
    let property = "opacity, transform";
    let durationIn = $caa9439642c6336c$var$modifierValue(modifiers, "duration", 150) / 1e3;
    let durationOut = $caa9439642c6336c$var$modifierValue(modifiers, "duration", 75) / 1e3;
    let easing = `cubic-bezier(0.4, 0.0, 0.2, 1)`;
    if (transitioningIn) {
        el._x_transition.enter.during = {
            transformOrigin: origin,
            transitionDelay: `${delay}s`,
            transitionProperty: property,
            transitionDuration: `${durationIn}s`,
            transitionTimingFunction: easing
        };
        el._x_transition.enter.start = {
            opacity: opacityValue,
            transform: `scale(${scaleValue})`
        };
        el._x_transition.enter.end = {
            opacity: 1,
            transform: `scale(1)`
        };
    }
    if (transitioningOut) {
        el._x_transition.leave.during = {
            transformOrigin: origin,
            transitionDelay: `${delay}s`,
            transitionProperty: property,
            transitionDuration: `${durationOut}s`,
            transitionTimingFunction: easing
        };
        el._x_transition.leave.start = {
            opacity: 1,
            transform: `scale(1)`
        };
        el._x_transition.leave.end = {
            opacity: opacityValue,
            transform: `scale(${scaleValue})`
        };
    }
}
function $caa9439642c6336c$var$registerTransitionObject(el, setFunction, defaultValue = {}) {
    if (!el._x_transition) el._x_transition = {
        enter: {
            during: defaultValue,
            start: defaultValue,
            end: defaultValue
        },
        leave: {
            during: defaultValue,
            start: defaultValue,
            end: defaultValue
        },
        in (before = ()=>{}, after = ()=>{}) {
            $caa9439642c6336c$var$transition(el, setFunction, {
                during: this.enter.during,
                start: this.enter.start,
                end: this.enter.end
            }, before, after);
        },
        out (before = ()=>{}, after = ()=>{}) {
            $caa9439642c6336c$var$transition(el, setFunction, {
                during: this.leave.during,
                start: this.leave.start,
                end: this.leave.end
            }, before, after);
        }
    };
}
window.Element.prototype._x_toggleAndCascadeWithTransitions = function(el, value, show, hide) {
    const nextTick2 = document.visibilityState === "visible" ? requestAnimationFrame : setTimeout;
    let clickAwayCompatibleShow = ()=>nextTick2(show);
    if (value) {
        if (el._x_transition && (el._x_transition.enter || el._x_transition.leave)) el._x_transition.enter && (Object.entries(el._x_transition.enter.during).length || Object.entries(el._x_transition.enter.start).length || Object.entries(el._x_transition.enter.end).length) ? el._x_transition.in(show) : clickAwayCompatibleShow();
        else el._x_transition ? el._x_transition.in(show) : clickAwayCompatibleShow();
        return;
    }
    el._x_hidePromise = el._x_transition ? new Promise((resolve, reject)=>{
        el._x_transition.out(()=>{}, ()=>resolve(hide));
        el._x_transitioning && el._x_transitioning.beforeCancel(()=>reject({
                isFromCancelledTransition: true
            }));
    }) : Promise.resolve(hide);
    queueMicrotask(()=>{
        let closest = $caa9439642c6336c$var$closestHide(el);
        if (closest) {
            if (!closest._x_hideChildren) closest._x_hideChildren = [];
            closest._x_hideChildren.push(el);
        } else nextTick2(()=>{
            let hideAfterChildren = (el2)=>{
                let carry = Promise.all([
                    el2._x_hidePromise,
                    ...(el2._x_hideChildren || []).map(hideAfterChildren)
                ]).then(([i])=>i?.());
                delete el2._x_hidePromise;
                delete el2._x_hideChildren;
                return carry;
            };
            hideAfterChildren(el).catch((e)=>{
                if (!e.isFromCancelledTransition) throw e;
            });
        });
    });
};
function $caa9439642c6336c$var$closestHide(el) {
    let parent = el.parentNode;
    if (!parent) return;
    return parent._x_hidePromise ? parent : $caa9439642c6336c$var$closestHide(parent);
}
function $caa9439642c6336c$var$transition(el, setFunction, { during: during, start: start2, end: end } = {}, before = ()=>{}, after = ()=>{}) {
    if (el._x_transitioning) el._x_transitioning.cancel();
    if (Object.keys(during).length === 0 && Object.keys(start2).length === 0 && Object.keys(end).length === 0) {
        before();
        after();
        return;
    }
    let undoStart, undoDuring, undoEnd;
    $caa9439642c6336c$var$performTransition(el, {
        start () {
            undoStart = setFunction(el, start2);
        },
        during () {
            undoDuring = setFunction(el, during);
        },
        before: before,
        end () {
            undoStart();
            undoEnd = setFunction(el, end);
        },
        after: after,
        cleanup () {
            undoDuring();
            undoEnd();
        }
    });
}
function $caa9439642c6336c$var$performTransition(el, stages) {
    let interrupted, reachedBefore, reachedEnd;
    let finish = $caa9439642c6336c$var$once(()=>{
        $caa9439642c6336c$var$mutateDom(()=>{
            interrupted = true;
            if (!reachedBefore) stages.before();
            if (!reachedEnd) {
                stages.end();
                $caa9439642c6336c$var$releaseNextTicks();
            }
            stages.after();
            if (el.isConnected) stages.cleanup();
            delete el._x_transitioning;
        });
    });
    el._x_transitioning = {
        beforeCancels: [],
        beforeCancel (callback) {
            this.beforeCancels.push(callback);
        },
        cancel: $caa9439642c6336c$var$once(function() {
            while(this.beforeCancels.length)this.beforeCancels.shift()();
            finish();
        }),
        finish: finish
    };
    $caa9439642c6336c$var$mutateDom(()=>{
        stages.start();
        stages.during();
    });
    $caa9439642c6336c$var$holdNextTicks();
    requestAnimationFrame(()=>{
        if (interrupted) return;
        let duration = Number(getComputedStyle(el).transitionDuration.replace(/,.*/, "").replace("s", "")) * 1e3;
        let delay = Number(getComputedStyle(el).transitionDelay.replace(/,.*/, "").replace("s", "")) * 1e3;
        if (duration === 0) duration = Number(getComputedStyle(el).animationDuration.replace("s", "")) * 1e3;
        $caa9439642c6336c$var$mutateDom(()=>{
            stages.before();
        });
        reachedBefore = true;
        requestAnimationFrame(()=>{
            if (interrupted) return;
            $caa9439642c6336c$var$mutateDom(()=>{
                stages.end();
            });
            $caa9439642c6336c$var$releaseNextTicks();
            setTimeout(el._x_transitioning.finish, duration + delay);
            reachedEnd = true;
        });
    });
}
function $caa9439642c6336c$var$modifierValue(modifiers, key, fallback) {
    if (modifiers.indexOf(key) === -1) return fallback;
    const rawValue = modifiers[modifiers.indexOf(key) + 1];
    if (!rawValue) return fallback;
    if (key === "scale") {
        if (isNaN(rawValue)) return fallback;
    }
    if (key === "duration" || key === "delay") {
        let match = rawValue.match(/([0-9]+)ms/);
        if (match) return match[1];
    }
    if (key === "origin") {
        if ([
            "top",
            "right",
            "left",
            "center",
            "bottom"
        ].includes(modifiers[modifiers.indexOf(key) + 2])) return [
            rawValue,
            modifiers[modifiers.indexOf(key) + 2]
        ].join(" ");
    }
    return rawValue;
}
// packages/alpinejs/src/clone.js
var $caa9439642c6336c$var$isCloning = false;
function $caa9439642c6336c$var$skipDuringClone(callback, fallback = ()=>{}) {
    return (...args)=>$caa9439642c6336c$var$isCloning ? fallback(...args) : callback(...args);
}
function $caa9439642c6336c$var$onlyDuringClone(callback) {
    return (...args)=>$caa9439642c6336c$var$isCloning && callback(...args);
}
var $caa9439642c6336c$var$interceptors = [];
function $caa9439642c6336c$var$interceptClone(callback) {
    $caa9439642c6336c$var$interceptors.push(callback);
}
function $caa9439642c6336c$var$cloneNode(from, to) {
    $caa9439642c6336c$var$interceptors.forEach((i)=>i(from, to));
    $caa9439642c6336c$var$isCloning = true;
    $caa9439642c6336c$var$dontRegisterReactiveSideEffects(()=>{
        $caa9439642c6336c$var$initTree(to, (el, callback)=>{
            callback(el, ()=>{});
        });
    });
    $caa9439642c6336c$var$isCloning = false;
}
var $caa9439642c6336c$var$isCloningLegacy = false;
function $caa9439642c6336c$var$clone(oldEl, newEl) {
    if (!newEl._x_dataStack) newEl._x_dataStack = oldEl._x_dataStack;
    $caa9439642c6336c$var$isCloning = true;
    $caa9439642c6336c$var$isCloningLegacy = true;
    $caa9439642c6336c$var$dontRegisterReactiveSideEffects(()=>{
        $caa9439642c6336c$var$cloneTree(newEl);
    });
    $caa9439642c6336c$var$isCloning = false;
    $caa9439642c6336c$var$isCloningLegacy = false;
}
function $caa9439642c6336c$var$cloneTree(el) {
    let hasRunThroughFirstEl = false;
    let shallowWalker = (el2, callback)=>{
        $caa9439642c6336c$var$walk(el2, (el3, skip)=>{
            if (hasRunThroughFirstEl && $caa9439642c6336c$var$isRoot(el3)) return skip();
            hasRunThroughFirstEl = true;
            callback(el3, skip);
        });
    };
    $caa9439642c6336c$var$initTree(el, shallowWalker);
}
function $caa9439642c6336c$var$dontRegisterReactiveSideEffects(callback) {
    let cache = $caa9439642c6336c$var$effect;
    $caa9439642c6336c$var$overrideEffect((callback2, el)=>{
        let storedEffect = cache(callback2);
        $caa9439642c6336c$var$release(storedEffect);
        return ()=>{};
    });
    callback();
    $caa9439642c6336c$var$overrideEffect(cache);
}
// packages/alpinejs/src/utils/bind.js
function $caa9439642c6336c$var$bind(el, name, value, modifiers = []) {
    if (!el._x_bindings) el._x_bindings = $caa9439642c6336c$var$reactive({});
    el._x_bindings[name] = value;
    name = modifiers.includes("camel") ? $caa9439642c6336c$var$camelCase(name) : name;
    switch(name){
        case "value":
            $caa9439642c6336c$var$bindInputValue(el, value);
            break;
        case "style":
            $caa9439642c6336c$var$bindStyles(el, value);
            break;
        case "class":
            $caa9439642c6336c$var$bindClasses(el, value);
            break;
        case "selected":
        case "checked":
            $caa9439642c6336c$var$bindAttributeAndProperty(el, name, value);
            break;
        default:
            $caa9439642c6336c$var$bindAttribute(el, name, value);
            break;
    }
}
function $caa9439642c6336c$var$bindInputValue(el, value) {
    if ($caa9439642c6336c$var$isRadio(el)) {
        if (el.attributes.value === void 0) el.value = value;
        if (window.fromModel) {
            if (typeof value === "boolean") el.checked = $caa9439642c6336c$var$safeParseBoolean(el.value) === value;
            else el.checked = $caa9439642c6336c$var$checkedAttrLooseCompare(el.value, value);
        }
    } else if ($caa9439642c6336c$var$isCheckbox(el)) {
        if (Number.isInteger(value)) el.value = value;
        else if (!Array.isArray(value) && typeof value !== "boolean" && ![
            null,
            void 0
        ].includes(value)) el.value = String(value);
        else if (Array.isArray(value)) el.checked = value.some((val)=>$caa9439642c6336c$var$checkedAttrLooseCompare(val, el.value));
        else el.checked = !!value;
    } else if (el.tagName === "SELECT") $caa9439642c6336c$var$updateSelect(el, value);
    else {
        if (el.value === value) return;
        el.value = value === void 0 ? "" : value;
    }
}
function $caa9439642c6336c$var$bindClasses(el, value) {
    if (el._x_undoAddedClasses) el._x_undoAddedClasses();
    el._x_undoAddedClasses = $caa9439642c6336c$var$setClasses(el, value);
}
function $caa9439642c6336c$var$bindStyles(el, value) {
    if (el._x_undoAddedStyles) el._x_undoAddedStyles();
    el._x_undoAddedStyles = $caa9439642c6336c$var$setStyles(el, value);
}
function $caa9439642c6336c$var$bindAttributeAndProperty(el, name, value) {
    $caa9439642c6336c$var$bindAttribute(el, name, value);
    $caa9439642c6336c$var$setPropertyIfChanged(el, name, value);
}
function $caa9439642c6336c$var$bindAttribute(el, name, value) {
    if ([
        null,
        void 0,
        false
    ].includes(value) && $caa9439642c6336c$var$attributeShouldntBePreservedIfFalsy(name)) el.removeAttribute(name);
    else {
        if ($caa9439642c6336c$var$isBooleanAttr(name)) value = name;
        $caa9439642c6336c$var$setIfChanged(el, name, value);
    }
}
function $caa9439642c6336c$var$setIfChanged(el, attrName, value) {
    if (el.getAttribute(attrName) != value) el.setAttribute(attrName, value);
}
function $caa9439642c6336c$var$setPropertyIfChanged(el, propName, value) {
    if (el[propName] !== value) el[propName] = value;
}
function $caa9439642c6336c$var$updateSelect(el, value) {
    const arrayWrappedValue = [].concat(value).map((value2)=>{
        return value2 + "";
    });
    Array.from(el.options).forEach((option)=>{
        option.selected = arrayWrappedValue.includes(option.value);
    });
}
function $caa9439642c6336c$var$camelCase(subject) {
    return subject.toLowerCase().replace(/-(\w)/g, (match, char)=>char.toUpperCase());
}
function $caa9439642c6336c$var$checkedAttrLooseCompare(valueA, valueB) {
    return valueA == valueB;
}
function $caa9439642c6336c$var$safeParseBoolean(rawValue) {
    if ([
        1,
        "1",
        "true",
        "on",
        "yes",
        true
    ].includes(rawValue)) return true;
    if ([
        0,
        "0",
        "false",
        "off",
        "no",
        false
    ].includes(rawValue)) return false;
    return rawValue ? Boolean(rawValue) : null;
}
var $caa9439642c6336c$var$booleanAttributes = /* @__PURE__ */ new Set([
    "allowfullscreen",
    "async",
    "autofocus",
    "autoplay",
    "checked",
    "controls",
    "default",
    "defer",
    "disabled",
    "formnovalidate",
    "inert",
    "ismap",
    "itemscope",
    "loop",
    "multiple",
    "muted",
    "nomodule",
    "novalidate",
    "open",
    "playsinline",
    "readonly",
    "required",
    "reversed",
    "selected",
    "shadowrootclonable",
    "shadowrootdelegatesfocus",
    "shadowrootserializable"
]);
function $caa9439642c6336c$var$isBooleanAttr(attrName) {
    return $caa9439642c6336c$var$booleanAttributes.has(attrName);
}
function $caa9439642c6336c$var$attributeShouldntBePreservedIfFalsy(name) {
    return ![
        "aria-pressed",
        "aria-checked",
        "aria-expanded",
        "aria-selected"
    ].includes(name);
}
function $caa9439642c6336c$var$getBinding(el, name, fallback) {
    if (el._x_bindings && el._x_bindings[name] !== void 0) return el._x_bindings[name];
    return $caa9439642c6336c$var$getAttributeBinding(el, name, fallback);
}
function $caa9439642c6336c$var$extractProp(el, name, fallback, extract = true) {
    if (el._x_bindings && el._x_bindings[name] !== void 0) return el._x_bindings[name];
    if (el._x_inlineBindings && el._x_inlineBindings[name] !== void 0) {
        let binding = el._x_inlineBindings[name];
        binding.extract = extract;
        return $caa9439642c6336c$var$dontAutoEvaluateFunctions(()=>{
            return $caa9439642c6336c$var$evaluate(el, binding.expression);
        });
    }
    return $caa9439642c6336c$var$getAttributeBinding(el, name, fallback);
}
function $caa9439642c6336c$var$getAttributeBinding(el, name, fallback) {
    let attr = el.getAttribute(name);
    if (attr === null) return typeof fallback === "function" ? fallback() : fallback;
    if (attr === "") return true;
    if ($caa9439642c6336c$var$isBooleanAttr(name)) return !![
        name,
        "true"
    ].includes(attr);
    return attr;
}
function $caa9439642c6336c$var$isCheckbox(el) {
    return el.type === "checkbox" || el.localName === "ui-checkbox" || el.localName === "ui-switch";
}
function $caa9439642c6336c$var$isRadio(el) {
    return el.type === "radio" || el.localName === "ui-radio";
}
// packages/alpinejs/src/utils/debounce.js
function $caa9439642c6336c$var$debounce(func, wait) {
    var timeout;
    return function() {
        var context = this, args = arguments;
        var later = function() {
            timeout = null;
            func.apply(context, args);
        };
        clearTimeout(timeout);
        timeout = setTimeout(later, wait);
    };
}
// packages/alpinejs/src/utils/throttle.js
function $caa9439642c6336c$var$throttle(func, limit) {
    let inThrottle;
    return function() {
        let context = this, args = arguments;
        if (!inThrottle) {
            func.apply(context, args);
            inThrottle = true;
            setTimeout(()=>inThrottle = false, limit);
        }
    };
}
// packages/alpinejs/src/entangle.js
function $caa9439642c6336c$var$entangle({ get: outerGet, set: outerSet }, { get: innerGet, set: innerSet }) {
    let firstRun = true;
    let outerHash;
    let innerHash;
    let reference = $caa9439642c6336c$var$effect(()=>{
        let outer = outerGet();
        let inner = innerGet();
        if (firstRun) {
            innerSet($caa9439642c6336c$var$cloneIfObject(outer));
            firstRun = false;
        } else {
            let outerHashLatest = JSON.stringify(outer);
            let innerHashLatest = JSON.stringify(inner);
            if (outerHashLatest !== outerHash) innerSet($caa9439642c6336c$var$cloneIfObject(outer));
            else if (outerHashLatest !== innerHashLatest) outerSet($caa9439642c6336c$var$cloneIfObject(inner));
        }
        outerHash = JSON.stringify(outerGet());
        innerHash = JSON.stringify(innerGet());
    });
    return ()=>{
        $caa9439642c6336c$var$release(reference);
    };
}
function $caa9439642c6336c$var$cloneIfObject(value) {
    return typeof value === "object" ? JSON.parse(JSON.stringify(value)) : value;
}
// packages/alpinejs/src/plugin.js
function $caa9439642c6336c$var$plugin(callback) {
    let callbacks = Array.isArray(callback) ? callback : [
        callback
    ];
    callbacks.forEach((i)=>i($caa9439642c6336c$var$alpine_default));
}
// packages/alpinejs/src/store.js
var $caa9439642c6336c$var$stores = {};
var $caa9439642c6336c$var$isReactive = false;
function $caa9439642c6336c$var$store(name, value) {
    if (!$caa9439642c6336c$var$isReactive) {
        $caa9439642c6336c$var$stores = $caa9439642c6336c$var$reactive($caa9439642c6336c$var$stores);
        $caa9439642c6336c$var$isReactive = true;
    }
    if (value === void 0) return $caa9439642c6336c$var$stores[name];
    $caa9439642c6336c$var$stores[name] = value;
    $caa9439642c6336c$var$initInterceptors($caa9439642c6336c$var$stores[name]);
    if (typeof value === "object" && value !== null && value.hasOwnProperty("init") && typeof value.init === "function") $caa9439642c6336c$var$stores[name].init();
}
function $caa9439642c6336c$var$getStores() {
    return $caa9439642c6336c$var$stores;
}
// packages/alpinejs/src/binds.js
var $caa9439642c6336c$var$binds = {};
function $caa9439642c6336c$var$bind2(name, bindings) {
    let getBindings = typeof bindings !== "function" ? ()=>bindings : bindings;
    if (name instanceof Element) return $caa9439642c6336c$var$applyBindingsObject(name, getBindings());
    else $caa9439642c6336c$var$binds[name] = getBindings;
    return ()=>{};
}
function $caa9439642c6336c$var$injectBindingProviders(obj) {
    Object.entries($caa9439642c6336c$var$binds).forEach(([name, callback])=>{
        Object.defineProperty(obj, name, {
            get () {
                return (...args)=>{
                    return callback(...args);
                };
            }
        });
    });
    return obj;
}
function $caa9439642c6336c$var$applyBindingsObject(el, obj, original) {
    let cleanupRunners = [];
    while(cleanupRunners.length)cleanupRunners.pop()();
    let attributes = Object.entries(obj).map(([name, value])=>({
            name: name,
            value: value
        }));
    let staticAttributes = $caa9439642c6336c$var$attributesOnly(attributes);
    attributes = attributes.map((attribute)=>{
        if (staticAttributes.find((attr)=>attr.name === attribute.name)) return {
            name: `x-bind:${attribute.name}`,
            value: `"${attribute.value}"`
        };
        return attribute;
    });
    $caa9439642c6336c$var$directives(el, attributes, original).map((handle)=>{
        cleanupRunners.push(handle.runCleanups);
        handle();
    });
    return ()=>{
        while(cleanupRunners.length)cleanupRunners.pop()();
    };
}
// packages/alpinejs/src/datas.js
var $caa9439642c6336c$var$datas = {};
function $caa9439642c6336c$var$data(name, callback) {
    $caa9439642c6336c$var$datas[name] = callback;
}
function $caa9439642c6336c$var$injectDataProviders(obj, context) {
    Object.entries($caa9439642c6336c$var$datas).forEach(([name, callback])=>{
        Object.defineProperty(obj, name, {
            get () {
                return (...args)=>{
                    return callback.bind(context)(...args);
                };
            },
            enumerable: false
        });
    });
    return obj;
}
// packages/alpinejs/src/alpine.js
var $caa9439642c6336c$var$Alpine = {
    get reactive () {
        return $caa9439642c6336c$var$reactive;
    },
    get release () {
        return $caa9439642c6336c$var$release;
    },
    get effect () {
        return $caa9439642c6336c$var$effect;
    },
    get raw () {
        return $caa9439642c6336c$var$raw;
    },
    version: "3.14.9",
    flushAndStopDeferringMutations: $caa9439642c6336c$var$flushAndStopDeferringMutations,
    dontAutoEvaluateFunctions: $caa9439642c6336c$var$dontAutoEvaluateFunctions,
    disableEffectScheduling: $caa9439642c6336c$var$disableEffectScheduling,
    startObservingMutations: $caa9439642c6336c$var$startObservingMutations,
    stopObservingMutations: $caa9439642c6336c$var$stopObservingMutations,
    setReactivityEngine: $caa9439642c6336c$var$setReactivityEngine,
    onAttributeRemoved: $caa9439642c6336c$var$onAttributeRemoved,
    onAttributesAdded: $caa9439642c6336c$var$onAttributesAdded,
    closestDataStack: $caa9439642c6336c$var$closestDataStack,
    skipDuringClone: $caa9439642c6336c$var$skipDuringClone,
    onlyDuringClone: $caa9439642c6336c$var$onlyDuringClone,
    addRootSelector: $caa9439642c6336c$var$addRootSelector,
    addInitSelector: $caa9439642c6336c$var$addInitSelector,
    interceptClone: $caa9439642c6336c$var$interceptClone,
    addScopeToNode: $caa9439642c6336c$var$addScopeToNode,
    deferMutations: $caa9439642c6336c$var$deferMutations,
    mapAttributes: $caa9439642c6336c$var$mapAttributes,
    evaluateLater: $caa9439642c6336c$var$evaluateLater,
    interceptInit: $caa9439642c6336c$var$interceptInit,
    setEvaluator: $caa9439642c6336c$var$setEvaluator,
    mergeProxies: $caa9439642c6336c$var$mergeProxies,
    extractProp: $caa9439642c6336c$var$extractProp,
    findClosest: $caa9439642c6336c$var$findClosest,
    onElRemoved: $caa9439642c6336c$var$onElRemoved,
    closestRoot: $caa9439642c6336c$var$closestRoot,
    destroyTree: $caa9439642c6336c$var$destroyTree,
    interceptor: $caa9439642c6336c$var$interceptor,
    transition: // INTERNAL: not public API and is subject to change without major release.
    $caa9439642c6336c$var$transition,
    setStyles: // INTERNAL
    $caa9439642c6336c$var$setStyles,
    mutateDom: // INTERNAL
    $caa9439642c6336c$var$mutateDom,
    directive: $caa9439642c6336c$var$directive,
    entangle: $caa9439642c6336c$var$entangle,
    throttle: $caa9439642c6336c$var$throttle,
    debounce: $caa9439642c6336c$var$debounce,
    evaluate: $caa9439642c6336c$var$evaluate,
    initTree: $caa9439642c6336c$var$initTree,
    nextTick: $caa9439642c6336c$var$nextTick,
    prefixed: $caa9439642c6336c$var$prefix,
    prefix: $caa9439642c6336c$var$setPrefix,
    plugin: $caa9439642c6336c$var$plugin,
    magic: $caa9439642c6336c$var$magic,
    store: $caa9439642c6336c$var$store,
    start: $caa9439642c6336c$var$start,
    clone: $caa9439642c6336c$var$clone,
    cloneNode: // INTERNAL
    $caa9439642c6336c$var$cloneNode,
    // INTERNAL
    bound: $caa9439642c6336c$var$getBinding,
    $data: $caa9439642c6336c$var$scope,
    watch: $caa9439642c6336c$var$watch,
    walk: $caa9439642c6336c$var$walk,
    data: $caa9439642c6336c$var$data,
    bind: $caa9439642c6336c$var$bind2
};
var $caa9439642c6336c$var$alpine_default = $caa9439642c6336c$var$Alpine;
// node_modules/@vue/shared/dist/shared.esm-bundler.js
function $caa9439642c6336c$var$makeMap(str, expectsLowerCase) {
    const map = /* @__PURE__ */ Object.create(null);
    const list = str.split(",");
    for(let i = 0; i < list.length; i++)map[list[i]] = true;
    return expectsLowerCase ? (val)=>!!map[val.toLowerCase()] : (val)=>!!map[val];
}
var $caa9439642c6336c$var$specialBooleanAttrs = `itemscope,allowfullscreen,formnovalidate,ismap,nomodule,novalidate,readonly`;
var $caa9439642c6336c$var$isBooleanAttr2 = /* @__PURE__ */ $caa9439642c6336c$var$makeMap($caa9439642c6336c$var$specialBooleanAttrs + `,async,autofocus,autoplay,controls,default,defer,disabled,hidden,loop,open,required,reversed,scoped,seamless,checked,muted,multiple,selected`);
var $caa9439642c6336c$var$EMPTY_OBJ = Object.freeze({});
var $caa9439642c6336c$var$EMPTY_ARR = Object.freeze([]);
var $caa9439642c6336c$var$hasOwnProperty = Object.prototype.hasOwnProperty;
var $caa9439642c6336c$var$hasOwn = (val, key)=>$caa9439642c6336c$var$hasOwnProperty.call(val, key);
var $caa9439642c6336c$var$isArray = Array.isArray;
var $caa9439642c6336c$var$isMap = (val)=>$caa9439642c6336c$var$toTypeString(val) === "[object Map]";
var $caa9439642c6336c$var$isString = (val)=>typeof val === "string";
var $caa9439642c6336c$var$isSymbol = (val)=>typeof val === "symbol";
var $caa9439642c6336c$var$isObject = (val)=>val !== null && typeof val === "object";
var $caa9439642c6336c$var$objectToString = Object.prototype.toString;
var $caa9439642c6336c$var$toTypeString = (value)=>$caa9439642c6336c$var$objectToString.call(value);
var $caa9439642c6336c$var$toRawType = (value)=>{
    return $caa9439642c6336c$var$toTypeString(value).slice(8, -1);
};
var $caa9439642c6336c$var$isIntegerKey = (key)=>$caa9439642c6336c$var$isString(key) && key !== "NaN" && key[0] !== "-" && "" + parseInt(key, 10) === key;
var $caa9439642c6336c$var$cacheStringFunction = (fn)=>{
    const cache = /* @__PURE__ */ Object.create(null);
    return (str)=>{
        const hit = cache[str];
        return hit || (cache[str] = fn(str));
    };
};
var $caa9439642c6336c$var$camelizeRE = /-(\w)/g;
var $caa9439642c6336c$var$camelize = $caa9439642c6336c$var$cacheStringFunction((str)=>{
    return str.replace($caa9439642c6336c$var$camelizeRE, (_, c)=>c ? c.toUpperCase() : "");
});
var $caa9439642c6336c$var$hyphenateRE = /\B([A-Z])/g;
var $caa9439642c6336c$var$hyphenate = $caa9439642c6336c$var$cacheStringFunction((str)=>str.replace($caa9439642c6336c$var$hyphenateRE, "-$1").toLowerCase());
var $caa9439642c6336c$var$capitalize = $caa9439642c6336c$var$cacheStringFunction((str)=>str.charAt(0).toUpperCase() + str.slice(1));
var $caa9439642c6336c$var$toHandlerKey = $caa9439642c6336c$var$cacheStringFunction((str)=>str ? `on${$caa9439642c6336c$var$capitalize(str)}` : ``);
var $caa9439642c6336c$var$hasChanged = (value, oldValue)=>value !== oldValue && (value === value || oldValue === oldValue);
// node_modules/@vue/reactivity/dist/reactivity.esm-bundler.js
var $caa9439642c6336c$var$targetMap = /* @__PURE__ */ new WeakMap();
var $caa9439642c6336c$var$effectStack = [];
var $caa9439642c6336c$var$activeEffect;
var $caa9439642c6336c$var$ITERATE_KEY = Symbol("iterate");
var $caa9439642c6336c$var$MAP_KEY_ITERATE_KEY = Symbol("Map key iterate");
function $caa9439642c6336c$var$isEffect(fn) {
    return fn && fn._isEffect === true;
}
function $caa9439642c6336c$var$effect2(fn, options = $caa9439642c6336c$var$EMPTY_OBJ) {
    if ($caa9439642c6336c$var$isEffect(fn)) fn = fn.raw;
    const effect3 = $caa9439642c6336c$var$createReactiveEffect(fn, options);
    if (!options.lazy) effect3();
    return effect3;
}
function $caa9439642c6336c$var$stop(effect3) {
    if (effect3.active) {
        $caa9439642c6336c$var$cleanup(effect3);
        if (effect3.options.onStop) effect3.options.onStop();
        effect3.active = false;
    }
}
var $caa9439642c6336c$var$uid = 0;
function $caa9439642c6336c$var$createReactiveEffect(fn, options) {
    const effect3 = function reactiveEffect() {
        if (!effect3.active) return fn();
        if (!$caa9439642c6336c$var$effectStack.includes(effect3)) {
            $caa9439642c6336c$var$cleanup(effect3);
            try {
                $caa9439642c6336c$var$enableTracking();
                $caa9439642c6336c$var$effectStack.push(effect3);
                $caa9439642c6336c$var$activeEffect = effect3;
                return fn();
            } finally{
                $caa9439642c6336c$var$effectStack.pop();
                $caa9439642c6336c$var$resetTracking();
                $caa9439642c6336c$var$activeEffect = $caa9439642c6336c$var$effectStack[$caa9439642c6336c$var$effectStack.length - 1];
            }
        }
    };
    effect3.id = $caa9439642c6336c$var$uid++;
    effect3.allowRecurse = !!options.allowRecurse;
    effect3._isEffect = true;
    effect3.active = true;
    effect3.raw = fn;
    effect3.deps = [];
    effect3.options = options;
    return effect3;
}
function $caa9439642c6336c$var$cleanup(effect3) {
    const { deps: deps } = effect3;
    if (deps.length) {
        for(let i = 0; i < deps.length; i++)deps[i].delete(effect3);
        deps.length = 0;
    }
}
var $caa9439642c6336c$var$shouldTrack = true;
var $caa9439642c6336c$var$trackStack = [];
function $caa9439642c6336c$var$pauseTracking() {
    $caa9439642c6336c$var$trackStack.push($caa9439642c6336c$var$shouldTrack);
    $caa9439642c6336c$var$shouldTrack = false;
}
function $caa9439642c6336c$var$enableTracking() {
    $caa9439642c6336c$var$trackStack.push($caa9439642c6336c$var$shouldTrack);
    $caa9439642c6336c$var$shouldTrack = true;
}
function $caa9439642c6336c$var$resetTracking() {
    const last = $caa9439642c6336c$var$trackStack.pop();
    $caa9439642c6336c$var$shouldTrack = last === void 0 ? true : last;
}
function $caa9439642c6336c$var$track(target, type, key) {
    if (!$caa9439642c6336c$var$shouldTrack || $caa9439642c6336c$var$activeEffect === void 0) return;
    let depsMap = $caa9439642c6336c$var$targetMap.get(target);
    if (!depsMap) $caa9439642c6336c$var$targetMap.set(target, depsMap = /* @__PURE__ */ new Map());
    let dep = depsMap.get(key);
    if (!dep) depsMap.set(key, dep = /* @__PURE__ */ new Set());
    if (!dep.has($caa9439642c6336c$var$activeEffect)) {
        dep.add($caa9439642c6336c$var$activeEffect);
        $caa9439642c6336c$var$activeEffect.deps.push(dep);
        if ($caa9439642c6336c$var$activeEffect.options.onTrack) $caa9439642c6336c$var$activeEffect.options.onTrack({
            effect: $caa9439642c6336c$var$activeEffect,
            target: target,
            type: type,
            key: key
        });
    }
}
function $caa9439642c6336c$var$trigger(target, type, key, newValue, oldValue, oldTarget) {
    const depsMap = $caa9439642c6336c$var$targetMap.get(target);
    if (!depsMap) return;
    const effects = /* @__PURE__ */ new Set();
    const add2 = (effectsToAdd)=>{
        if (effectsToAdd) effectsToAdd.forEach((effect3)=>{
            if (effect3 !== $caa9439642c6336c$var$activeEffect || effect3.allowRecurse) effects.add(effect3);
        });
    };
    if (type === "clear") depsMap.forEach(add2);
    else if (key === "length" && $caa9439642c6336c$var$isArray(target)) depsMap.forEach((dep, key2)=>{
        if (key2 === "length" || key2 >= newValue) add2(dep);
    });
    else {
        if (key !== void 0) add2(depsMap.get(key));
        switch(type){
            case "add":
                if (!$caa9439642c6336c$var$isArray(target)) {
                    add2(depsMap.get($caa9439642c6336c$var$ITERATE_KEY));
                    if ($caa9439642c6336c$var$isMap(target)) add2(depsMap.get($caa9439642c6336c$var$MAP_KEY_ITERATE_KEY));
                } else if ($caa9439642c6336c$var$isIntegerKey(key)) add2(depsMap.get("length"));
                break;
            case "delete":
                if (!$caa9439642c6336c$var$isArray(target)) {
                    add2(depsMap.get($caa9439642c6336c$var$ITERATE_KEY));
                    if ($caa9439642c6336c$var$isMap(target)) add2(depsMap.get($caa9439642c6336c$var$MAP_KEY_ITERATE_KEY));
                }
                break;
            case "set":
                if ($caa9439642c6336c$var$isMap(target)) add2(depsMap.get($caa9439642c6336c$var$ITERATE_KEY));
                break;
        }
    }
    const run = (effect3)=>{
        if (effect3.options.onTrigger) effect3.options.onTrigger({
            effect: effect3,
            target: target,
            key: key,
            type: type,
            newValue: newValue,
            oldValue: oldValue,
            oldTarget: oldTarget
        });
        if (effect3.options.scheduler) effect3.options.scheduler(effect3);
        else effect3();
    };
    effects.forEach(run);
}
var $caa9439642c6336c$var$isNonTrackableKeys = /* @__PURE__ */ $caa9439642c6336c$var$makeMap(`__proto__,__v_isRef,__isVue`);
var $caa9439642c6336c$var$builtInSymbols = new Set(Object.getOwnPropertyNames(Symbol).map((key)=>Symbol[key]).filter($caa9439642c6336c$var$isSymbol));
var $caa9439642c6336c$var$get2 = /* @__PURE__ */ $caa9439642c6336c$var$createGetter();
var $caa9439642c6336c$var$readonlyGet = /* @__PURE__ */ $caa9439642c6336c$var$createGetter(true);
var $caa9439642c6336c$var$arrayInstrumentations = /* @__PURE__ */ $caa9439642c6336c$var$createArrayInstrumentations();
function $caa9439642c6336c$var$createArrayInstrumentations() {
    const instrumentations = {};
    [
        "includes",
        "indexOf",
        "lastIndexOf"
    ].forEach((key)=>{
        instrumentations[key] = function(...args) {
            const arr = $caa9439642c6336c$var$toRaw(this);
            for(let i = 0, l = this.length; i < l; i++)$caa9439642c6336c$var$track(arr, "get", i + "");
            const res = arr[key](...args);
            if (res === -1 || res === false) return arr[key](...args.map($caa9439642c6336c$var$toRaw));
            else return res;
        };
    });
    [
        "push",
        "pop",
        "shift",
        "unshift",
        "splice"
    ].forEach((key)=>{
        instrumentations[key] = function(...args) {
            $caa9439642c6336c$var$pauseTracking();
            const res = $caa9439642c6336c$var$toRaw(this)[key].apply(this, args);
            $caa9439642c6336c$var$resetTracking();
            return res;
        };
    });
    return instrumentations;
}
function $caa9439642c6336c$var$createGetter(isReadonly = false, shallow = false) {
    return function get3(target, key, receiver) {
        if (key === "__v_isReactive") return !isReadonly;
        else if (key === "__v_isReadonly") return isReadonly;
        else if (key === "__v_raw" && receiver === (isReadonly ? shallow ? $caa9439642c6336c$var$shallowReadonlyMap : $caa9439642c6336c$var$readonlyMap : shallow ? $caa9439642c6336c$var$shallowReactiveMap : $caa9439642c6336c$var$reactiveMap).get(target)) return target;
        const targetIsArray = $caa9439642c6336c$var$isArray(target);
        if (!isReadonly && targetIsArray && $caa9439642c6336c$var$hasOwn($caa9439642c6336c$var$arrayInstrumentations, key)) return Reflect.get($caa9439642c6336c$var$arrayInstrumentations, key, receiver);
        const res = Reflect.get(target, key, receiver);
        if ($caa9439642c6336c$var$isSymbol(key) ? $caa9439642c6336c$var$builtInSymbols.has(key) : $caa9439642c6336c$var$isNonTrackableKeys(key)) return res;
        if (!isReadonly) $caa9439642c6336c$var$track(target, "get", key);
        if (shallow) return res;
        if ($caa9439642c6336c$var$isRef(res)) {
            const shouldUnwrap = !targetIsArray || !$caa9439642c6336c$var$isIntegerKey(key);
            return shouldUnwrap ? res.value : res;
        }
        if ($caa9439642c6336c$var$isObject(res)) return isReadonly ? $caa9439642c6336c$var$readonly(res) : $caa9439642c6336c$var$reactive2(res);
        return res;
    };
}
var $caa9439642c6336c$var$set2 = /* @__PURE__ */ $caa9439642c6336c$var$createSetter();
function $caa9439642c6336c$var$createSetter(shallow = false) {
    return function set3(target, key, value, receiver) {
        let oldValue = target[key];
        if (!shallow) {
            value = $caa9439642c6336c$var$toRaw(value);
            oldValue = $caa9439642c6336c$var$toRaw(oldValue);
            if (!$caa9439642c6336c$var$isArray(target) && $caa9439642c6336c$var$isRef(oldValue) && !$caa9439642c6336c$var$isRef(value)) {
                oldValue.value = value;
                return true;
            }
        }
        const hadKey = $caa9439642c6336c$var$isArray(target) && $caa9439642c6336c$var$isIntegerKey(key) ? Number(key) < target.length : $caa9439642c6336c$var$hasOwn(target, key);
        const result = Reflect.set(target, key, value, receiver);
        if (target === $caa9439642c6336c$var$toRaw(receiver)) {
            if (!hadKey) $caa9439642c6336c$var$trigger(target, "add", key, value);
            else if ($caa9439642c6336c$var$hasChanged(value, oldValue)) $caa9439642c6336c$var$trigger(target, "set", key, value, oldValue);
        }
        return result;
    };
}
function $caa9439642c6336c$var$deleteProperty(target, key) {
    const hadKey = $caa9439642c6336c$var$hasOwn(target, key);
    const oldValue = target[key];
    const result = Reflect.deleteProperty(target, key);
    if (result && hadKey) $caa9439642c6336c$var$trigger(target, "delete", key, void 0, oldValue);
    return result;
}
function $caa9439642c6336c$var$has(target, key) {
    const result = Reflect.has(target, key);
    if (!$caa9439642c6336c$var$isSymbol(key) || !$caa9439642c6336c$var$builtInSymbols.has(key)) $caa9439642c6336c$var$track(target, "has", key);
    return result;
}
function $caa9439642c6336c$var$ownKeys(target) {
    $caa9439642c6336c$var$track(target, "iterate", $caa9439642c6336c$var$isArray(target) ? "length" : $caa9439642c6336c$var$ITERATE_KEY);
    return Reflect.ownKeys(target);
}
var $caa9439642c6336c$var$mutableHandlers = {
    get: $caa9439642c6336c$var$get2,
    set: $caa9439642c6336c$var$set2,
    deleteProperty: $caa9439642c6336c$var$deleteProperty,
    has: $caa9439642c6336c$var$has,
    ownKeys: $caa9439642c6336c$var$ownKeys
};
var $caa9439642c6336c$var$readonlyHandlers = {
    get: $caa9439642c6336c$var$readonlyGet,
    set (target, key) {
        console.warn(`Set operation on key "${String(key)}" failed: target is readonly.`, target);
        return true;
    },
    deleteProperty (target, key) {
        console.warn(`Delete operation on key "${String(key)}" failed: target is readonly.`, target);
        return true;
    }
};
var $caa9439642c6336c$var$toReactive = (value)=>$caa9439642c6336c$var$isObject(value) ? $caa9439642c6336c$var$reactive2(value) : value;
var $caa9439642c6336c$var$toReadonly = (value)=>$caa9439642c6336c$var$isObject(value) ? $caa9439642c6336c$var$readonly(value) : value;
var $caa9439642c6336c$var$toShallow = (value)=>value;
var $caa9439642c6336c$var$getProto = (v)=>Reflect.getPrototypeOf(v);
function $caa9439642c6336c$var$get$1(target, key, isReadonly = false, isShallow = false) {
    target = target["__v_raw"];
    const rawTarget = $caa9439642c6336c$var$toRaw(target);
    const rawKey = $caa9439642c6336c$var$toRaw(key);
    if (key !== rawKey) !isReadonly && $caa9439642c6336c$var$track(rawTarget, "get", key);
    !isReadonly && $caa9439642c6336c$var$track(rawTarget, "get", rawKey);
    const { has: has2 } = $caa9439642c6336c$var$getProto(rawTarget);
    const wrap = isShallow ? $caa9439642c6336c$var$toShallow : isReadonly ? $caa9439642c6336c$var$toReadonly : $caa9439642c6336c$var$toReactive;
    if (has2.call(rawTarget, key)) return wrap(target.get(key));
    else if (has2.call(rawTarget, rawKey)) return wrap(target.get(rawKey));
    else if (target !== rawTarget) target.get(key);
}
function $caa9439642c6336c$var$has$1(key, isReadonly = false) {
    const target = this["__v_raw"];
    const rawTarget = $caa9439642c6336c$var$toRaw(target);
    const rawKey = $caa9439642c6336c$var$toRaw(key);
    if (key !== rawKey) !isReadonly && $caa9439642c6336c$var$track(rawTarget, "has", key);
    !isReadonly && $caa9439642c6336c$var$track(rawTarget, "has", rawKey);
    return key === rawKey ? target.has(key) : target.has(key) || target.has(rawKey);
}
function $caa9439642c6336c$var$size(target, isReadonly = false) {
    target = target["__v_raw"];
    !isReadonly && $caa9439642c6336c$var$track($caa9439642c6336c$var$toRaw(target), "iterate", $caa9439642c6336c$var$ITERATE_KEY);
    return Reflect.get(target, "size", target);
}
function $caa9439642c6336c$var$add(value) {
    value = $caa9439642c6336c$var$toRaw(value);
    const target = $caa9439642c6336c$var$toRaw(this);
    const proto = $caa9439642c6336c$var$getProto(target);
    const hadKey = proto.has.call(target, value);
    if (!hadKey) {
        target.add(value);
        $caa9439642c6336c$var$trigger(target, "add", value, value);
    }
    return this;
}
function $caa9439642c6336c$var$set$1(key, value) {
    value = $caa9439642c6336c$var$toRaw(value);
    const target = $caa9439642c6336c$var$toRaw(this);
    const { has: has2, get: get3 } = $caa9439642c6336c$var$getProto(target);
    let hadKey = has2.call(target, key);
    if (!hadKey) {
        key = $caa9439642c6336c$var$toRaw(key);
        hadKey = has2.call(target, key);
    } else $caa9439642c6336c$var$checkIdentityKeys(target, has2, key);
    const oldValue = get3.call(target, key);
    target.set(key, value);
    if (!hadKey) $caa9439642c6336c$var$trigger(target, "add", key, value);
    else if ($caa9439642c6336c$var$hasChanged(value, oldValue)) $caa9439642c6336c$var$trigger(target, "set", key, value, oldValue);
    return this;
}
function $caa9439642c6336c$var$deleteEntry(key) {
    const target = $caa9439642c6336c$var$toRaw(this);
    const { has: has2, get: get3 } = $caa9439642c6336c$var$getProto(target);
    let hadKey = has2.call(target, key);
    if (!hadKey) {
        key = $caa9439642c6336c$var$toRaw(key);
        hadKey = has2.call(target, key);
    } else $caa9439642c6336c$var$checkIdentityKeys(target, has2, key);
    const oldValue = get3 ? get3.call(target, key) : void 0;
    const result = target.delete(key);
    if (hadKey) $caa9439642c6336c$var$trigger(target, "delete", key, void 0, oldValue);
    return result;
}
function $caa9439642c6336c$var$clear() {
    const target = $caa9439642c6336c$var$toRaw(this);
    const hadItems = target.size !== 0;
    const oldTarget = $caa9439642c6336c$var$isMap(target) ? new Map(target) : new Set(target);
    const result = target.clear();
    if (hadItems) $caa9439642c6336c$var$trigger(target, "clear", void 0, void 0, oldTarget);
    return result;
}
function $caa9439642c6336c$var$createForEach(isReadonly, isShallow) {
    return function forEach(callback, thisArg) {
        const observed = this;
        const target = observed["__v_raw"];
        const rawTarget = $caa9439642c6336c$var$toRaw(target);
        const wrap = isShallow ? $caa9439642c6336c$var$toShallow : isReadonly ? $caa9439642c6336c$var$toReadonly : $caa9439642c6336c$var$toReactive;
        !isReadonly && $caa9439642c6336c$var$track(rawTarget, "iterate", $caa9439642c6336c$var$ITERATE_KEY);
        return target.forEach((value, key)=>{
            return callback.call(thisArg, wrap(value), wrap(key), observed);
        });
    };
}
function $caa9439642c6336c$var$createIterableMethod(method, isReadonly, isShallow) {
    return function(...args) {
        const target = this["__v_raw"];
        const rawTarget = $caa9439642c6336c$var$toRaw(target);
        const targetIsMap = $caa9439642c6336c$var$isMap(rawTarget);
        const isPair = method === "entries" || method === Symbol.iterator && targetIsMap;
        const isKeyOnly = method === "keys" && targetIsMap;
        const innerIterator = target[method](...args);
        const wrap = isShallow ? $caa9439642c6336c$var$toShallow : isReadonly ? $caa9439642c6336c$var$toReadonly : $caa9439642c6336c$var$toReactive;
        !isReadonly && $caa9439642c6336c$var$track(rawTarget, "iterate", isKeyOnly ? $caa9439642c6336c$var$MAP_KEY_ITERATE_KEY : $caa9439642c6336c$var$ITERATE_KEY);
        return {
            // iterator protocol
            next () {
                const { value: value, done: done } = innerIterator.next();
                return done ? {
                    value: value,
                    done: done
                } : {
                    value: isPair ? [
                        wrap(value[0]),
                        wrap(value[1])
                    ] : wrap(value),
                    done: done
                };
            },
            // iterable protocol
            [Symbol.iterator] () {
                return this;
            }
        };
    };
}
function $caa9439642c6336c$var$createReadonlyMethod(type) {
    return function(...args) {
        {
            const key = args[0] ? `on key "${args[0]}" ` : ``;
            console.warn(`${$caa9439642c6336c$var$capitalize(type)} operation ${key}failed: target is readonly.`, $caa9439642c6336c$var$toRaw(this));
        }
        return type === "delete" ? false : this;
    };
}
function $caa9439642c6336c$var$createInstrumentations() {
    const mutableInstrumentations2 = {
        get (key) {
            return $caa9439642c6336c$var$get$1(this, key);
        },
        get size () {
            return $caa9439642c6336c$var$size(this);
        },
        has: $caa9439642c6336c$var$has$1,
        add: $caa9439642c6336c$var$add,
        set: $caa9439642c6336c$var$set$1,
        delete: $caa9439642c6336c$var$deleteEntry,
        clear: $caa9439642c6336c$var$clear,
        forEach: $caa9439642c6336c$var$createForEach(false, false)
    };
    const shallowInstrumentations2 = {
        get (key) {
            return $caa9439642c6336c$var$get$1(this, key, false, true);
        },
        get size () {
            return $caa9439642c6336c$var$size(this);
        },
        has: $caa9439642c6336c$var$has$1,
        add: $caa9439642c6336c$var$add,
        set: $caa9439642c6336c$var$set$1,
        delete: $caa9439642c6336c$var$deleteEntry,
        clear: $caa9439642c6336c$var$clear,
        forEach: $caa9439642c6336c$var$createForEach(false, true)
    };
    const readonlyInstrumentations2 = {
        get (key) {
            return $caa9439642c6336c$var$get$1(this, key, true);
        },
        get size () {
            return $caa9439642c6336c$var$size(this, true);
        },
        has (key) {
            return $caa9439642c6336c$var$has$1.call(this, key, true);
        },
        add: $caa9439642c6336c$var$createReadonlyMethod("add"),
        set: $caa9439642c6336c$var$createReadonlyMethod("set"),
        delete: $caa9439642c6336c$var$createReadonlyMethod("delete"),
        clear: $caa9439642c6336c$var$createReadonlyMethod("clear"),
        forEach: $caa9439642c6336c$var$createForEach(true, false)
    };
    const shallowReadonlyInstrumentations2 = {
        get (key) {
            return $caa9439642c6336c$var$get$1(this, key, true, true);
        },
        get size () {
            return $caa9439642c6336c$var$size(this, true);
        },
        has (key) {
            return $caa9439642c6336c$var$has$1.call(this, key, true);
        },
        add: $caa9439642c6336c$var$createReadonlyMethod("add"),
        set: $caa9439642c6336c$var$createReadonlyMethod("set"),
        delete: $caa9439642c6336c$var$createReadonlyMethod("delete"),
        clear: $caa9439642c6336c$var$createReadonlyMethod("clear"),
        forEach: $caa9439642c6336c$var$createForEach(true, true)
    };
    const iteratorMethods = [
        "keys",
        "values",
        "entries",
        Symbol.iterator
    ];
    iteratorMethods.forEach((method)=>{
        mutableInstrumentations2[method] = $caa9439642c6336c$var$createIterableMethod(method, false, false);
        readonlyInstrumentations2[method] = $caa9439642c6336c$var$createIterableMethod(method, true, false);
        shallowInstrumentations2[method] = $caa9439642c6336c$var$createIterableMethod(method, false, true);
        shallowReadonlyInstrumentations2[method] = $caa9439642c6336c$var$createIterableMethod(method, true, true);
    });
    return [
        mutableInstrumentations2,
        readonlyInstrumentations2,
        shallowInstrumentations2,
        shallowReadonlyInstrumentations2
    ];
}
var [$caa9439642c6336c$var$mutableInstrumentations, $caa9439642c6336c$var$readonlyInstrumentations, $caa9439642c6336c$var$shallowInstrumentations, $caa9439642c6336c$var$shallowReadonlyInstrumentations] = /* @__PURE__ */ $caa9439642c6336c$var$createInstrumentations();
function $caa9439642c6336c$var$createInstrumentationGetter(isReadonly, shallow) {
    const instrumentations = shallow ? isReadonly ? $caa9439642c6336c$var$shallowReadonlyInstrumentations : $caa9439642c6336c$var$shallowInstrumentations : isReadonly ? $caa9439642c6336c$var$readonlyInstrumentations : $caa9439642c6336c$var$mutableInstrumentations;
    return (target, key, receiver)=>{
        if (key === "__v_isReactive") return !isReadonly;
        else if (key === "__v_isReadonly") return isReadonly;
        else if (key === "__v_raw") return target;
        return Reflect.get($caa9439642c6336c$var$hasOwn(instrumentations, key) && key in target ? instrumentations : target, key, receiver);
    };
}
var $caa9439642c6336c$var$mutableCollectionHandlers = {
    get: /* @__PURE__ */ $caa9439642c6336c$var$createInstrumentationGetter(false, false)
};
var $caa9439642c6336c$var$readonlyCollectionHandlers = {
    get: /* @__PURE__ */ $caa9439642c6336c$var$createInstrumentationGetter(true, false)
};
function $caa9439642c6336c$var$checkIdentityKeys(target, has2, key) {
    const rawKey = $caa9439642c6336c$var$toRaw(key);
    if (rawKey !== key && has2.call(target, rawKey)) {
        const type = $caa9439642c6336c$var$toRawType(target);
        console.warn(`Reactive ${type} contains both the raw and reactive versions of the same object${type === `Map` ? ` as keys` : ``}, which can lead to inconsistencies. Avoid differentiating between the raw and reactive versions of an object and only use the reactive version if possible.`);
    }
}
var $caa9439642c6336c$var$reactiveMap = /* @__PURE__ */ new WeakMap();
var $caa9439642c6336c$var$shallowReactiveMap = /* @__PURE__ */ new WeakMap();
var $caa9439642c6336c$var$readonlyMap = /* @__PURE__ */ new WeakMap();
var $caa9439642c6336c$var$shallowReadonlyMap = /* @__PURE__ */ new WeakMap();
function $caa9439642c6336c$var$targetTypeMap(rawType) {
    switch(rawType){
        case "Object":
        case "Array":
            return 1;
        case "Map":
        case "Set":
        case "WeakMap":
        case "WeakSet":
            return 2;
        default:
            return 0;
    }
}
function $caa9439642c6336c$var$getTargetType(value) {
    return value["__v_skip"] || !Object.isExtensible(value) ? 0 : $caa9439642c6336c$var$targetTypeMap($caa9439642c6336c$var$toRawType(value));
}
function $caa9439642c6336c$var$reactive2(target) {
    if (target && target["__v_isReadonly"]) return target;
    return $caa9439642c6336c$var$createReactiveObject(target, false, $caa9439642c6336c$var$mutableHandlers, $caa9439642c6336c$var$mutableCollectionHandlers, $caa9439642c6336c$var$reactiveMap);
}
function $caa9439642c6336c$var$readonly(target) {
    return $caa9439642c6336c$var$createReactiveObject(target, true, $caa9439642c6336c$var$readonlyHandlers, $caa9439642c6336c$var$readonlyCollectionHandlers, $caa9439642c6336c$var$readonlyMap);
}
function $caa9439642c6336c$var$createReactiveObject(target, isReadonly, baseHandlers, collectionHandlers, proxyMap) {
    if (!$caa9439642c6336c$var$isObject(target)) {
        console.warn(`value cannot be made reactive: ${String(target)}`);
        return target;
    }
    if (target["__v_raw"] && !(isReadonly && target["__v_isReactive"])) return target;
    const existingProxy = proxyMap.get(target);
    if (existingProxy) return existingProxy;
    const targetType = $caa9439642c6336c$var$getTargetType(target);
    if (targetType === 0) return target;
    const proxy = new Proxy(target, targetType === 2 ? collectionHandlers : baseHandlers);
    proxyMap.set(target, proxy);
    return proxy;
}
function $caa9439642c6336c$var$toRaw(observed) {
    return observed && $caa9439642c6336c$var$toRaw(observed["__v_raw"]) || observed;
}
function $caa9439642c6336c$var$isRef(r) {
    return Boolean(r && r.__v_isRef === true);
}
// packages/alpinejs/src/magics/$nextTick.js
$caa9439642c6336c$var$magic("nextTick", ()=>$caa9439642c6336c$var$nextTick);
// packages/alpinejs/src/magics/$dispatch.js
$caa9439642c6336c$var$magic("dispatch", (el)=>$caa9439642c6336c$var$dispatch.bind($caa9439642c6336c$var$dispatch, el));
// packages/alpinejs/src/magics/$watch.js
$caa9439642c6336c$var$magic("watch", (el, { evaluateLater: evaluateLater2, cleanup: cleanup2 })=>(key, callback)=>{
        let evaluate2 = evaluateLater2(key);
        let getter = ()=>{
            let value;
            evaluate2((i)=>value = i);
            return value;
        };
        let unwatch = $caa9439642c6336c$var$watch(getter, callback);
        cleanup2(unwatch);
    });
// packages/alpinejs/src/magics/$store.js
$caa9439642c6336c$var$magic("store", $caa9439642c6336c$var$getStores);
// packages/alpinejs/src/magics/$data.js
$caa9439642c6336c$var$magic("data", (el)=>$caa9439642c6336c$var$scope(el));
// packages/alpinejs/src/magics/$root.js
$caa9439642c6336c$var$magic("root", (el)=>$caa9439642c6336c$var$closestRoot(el));
// packages/alpinejs/src/magics/$refs.js
$caa9439642c6336c$var$magic("refs", (el)=>{
    if (el._x_refs_proxy) return el._x_refs_proxy;
    el._x_refs_proxy = $caa9439642c6336c$var$mergeProxies($caa9439642c6336c$var$getArrayOfRefObject(el));
    return el._x_refs_proxy;
});
function $caa9439642c6336c$var$getArrayOfRefObject(el) {
    let refObjects = [];
    $caa9439642c6336c$var$findClosest(el, (i)=>{
        if (i._x_refs) refObjects.push(i._x_refs);
    });
    return refObjects;
}
// packages/alpinejs/src/ids.js
var $caa9439642c6336c$var$globalIdMemo = {};
function $caa9439642c6336c$var$findAndIncrementId(name) {
    if (!$caa9439642c6336c$var$globalIdMemo[name]) $caa9439642c6336c$var$globalIdMemo[name] = 0;
    return ++$caa9439642c6336c$var$globalIdMemo[name];
}
function $caa9439642c6336c$var$closestIdRoot(el, name) {
    return $caa9439642c6336c$var$findClosest(el, (element)=>{
        if (element._x_ids && element._x_ids[name]) return true;
    });
}
function $caa9439642c6336c$var$setIdRoot(el, name) {
    if (!el._x_ids) el._x_ids = {};
    if (!el._x_ids[name]) el._x_ids[name] = $caa9439642c6336c$var$findAndIncrementId(name);
}
// packages/alpinejs/src/magics/$id.js
$caa9439642c6336c$var$magic("id", (el, { cleanup: cleanup2 })=>(name, key = null)=>{
        let cacheKey = `${name}${key ? `-${key}` : ""}`;
        return $caa9439642c6336c$var$cacheIdByNameOnElement(el, cacheKey, cleanup2, ()=>{
            let root = $caa9439642c6336c$var$closestIdRoot(el, name);
            let id = root ? root._x_ids[name] : $caa9439642c6336c$var$findAndIncrementId(name);
            return key ? `${name}-${id}-${key}` : `${name}-${id}`;
        });
    });
$caa9439642c6336c$var$interceptClone((from, to)=>{
    if (from._x_id) to._x_id = from._x_id;
});
function $caa9439642c6336c$var$cacheIdByNameOnElement(el, cacheKey, cleanup2, callback) {
    if (!el._x_id) el._x_id = {};
    if (el._x_id[cacheKey]) return el._x_id[cacheKey];
    let output = callback();
    el._x_id[cacheKey] = output;
    cleanup2(()=>{
        delete el._x_id[cacheKey];
    });
    return output;
}
// packages/alpinejs/src/magics/$el.js
$caa9439642c6336c$var$magic("el", (el)=>el);
// packages/alpinejs/src/magics/index.js
$caa9439642c6336c$var$warnMissingPluginMagic("Focus", "focus", "focus");
$caa9439642c6336c$var$warnMissingPluginMagic("Persist", "persist", "persist");
function $caa9439642c6336c$var$warnMissingPluginMagic(name, magicName, slug) {
    $caa9439642c6336c$var$magic(magicName, (el)=>$caa9439642c6336c$var$warn(`You can't use [$${magicName}] without first installing the "${name}" plugin here: https://alpinejs.dev/plugins/${slug}`, el));
}
// packages/alpinejs/src/directives/x-modelable.js
$caa9439642c6336c$var$directive("modelable", (el, { expression: expression }, { effect: effect3, evaluateLater: evaluateLater2, cleanup: cleanup2 })=>{
    let func = evaluateLater2(expression);
    let innerGet = ()=>{
        let result;
        func((i)=>result = i);
        return result;
    };
    let evaluateInnerSet = evaluateLater2(`${expression} = __placeholder`);
    let innerSet = (val)=>evaluateInnerSet(()=>{}, {
            scope: {
                "__placeholder": val
            }
        });
    let initialValue = innerGet();
    innerSet(initialValue);
    queueMicrotask(()=>{
        if (!el._x_model) return;
        el._x_removeModelListeners["default"]();
        let outerGet = el._x_model.get;
        let outerSet = el._x_model.set;
        let releaseEntanglement = $caa9439642c6336c$var$entangle({
            get () {
                return outerGet();
            },
            set (value) {
                outerSet(value);
            }
        }, {
            get () {
                return innerGet();
            },
            set (value) {
                innerSet(value);
            }
        });
        cleanup2(releaseEntanglement);
    });
});
// packages/alpinejs/src/directives/x-teleport.js
$caa9439642c6336c$var$directive("teleport", (el, { modifiers: modifiers, expression: expression }, { cleanup: cleanup2 })=>{
    if (el.tagName.toLowerCase() !== "template") $caa9439642c6336c$var$warn("x-teleport can only be used on a <template> tag", el);
    let target = $caa9439642c6336c$var$getTarget(expression);
    let clone2 = el.content.cloneNode(true).firstElementChild;
    el._x_teleport = clone2;
    clone2._x_teleportBack = el;
    el.setAttribute("data-teleport-template", true);
    clone2.setAttribute("data-teleport-target", true);
    if (el._x_forwardEvents) el._x_forwardEvents.forEach((eventName)=>{
        clone2.addEventListener(eventName, (e)=>{
            e.stopPropagation();
            el.dispatchEvent(new e.constructor(e.type, e));
        });
    });
    $caa9439642c6336c$var$addScopeToNode(clone2, {}, el);
    let placeInDom = (clone3, target2, modifiers2)=>{
        if (modifiers2.includes("prepend")) target2.parentNode.insertBefore(clone3, target2);
        else if (modifiers2.includes("append")) target2.parentNode.insertBefore(clone3, target2.nextSibling);
        else target2.appendChild(clone3);
    };
    $caa9439642c6336c$var$mutateDom(()=>{
        placeInDom(clone2, target, modifiers);
        $caa9439642c6336c$var$skipDuringClone(()=>{
            $caa9439642c6336c$var$initTree(clone2);
        })();
    });
    el._x_teleportPutBack = ()=>{
        let target2 = $caa9439642c6336c$var$getTarget(expression);
        $caa9439642c6336c$var$mutateDom(()=>{
            placeInDom(el._x_teleport, target2, modifiers);
        });
    };
    cleanup2(()=>$caa9439642c6336c$var$mutateDom(()=>{
            clone2.remove();
            $caa9439642c6336c$var$destroyTree(clone2);
        }));
});
var $caa9439642c6336c$var$teleportContainerDuringClone = document.createElement("div");
function $caa9439642c6336c$var$getTarget(expression) {
    let target = $caa9439642c6336c$var$skipDuringClone(()=>{
        return document.querySelector(expression);
    }, ()=>{
        return $caa9439642c6336c$var$teleportContainerDuringClone;
    })();
    if (!target) $caa9439642c6336c$var$warn(`Cannot find x-teleport element for selector: "${expression}"`);
    return target;
}
// packages/alpinejs/src/directives/x-ignore.js
var $caa9439642c6336c$var$handler = ()=>{};
$caa9439642c6336c$var$handler.inline = (el, { modifiers: modifiers }, { cleanup: cleanup2 })=>{
    modifiers.includes("self") ? el._x_ignoreSelf = true : el._x_ignore = true;
    cleanup2(()=>{
        modifiers.includes("self") ? delete el._x_ignoreSelf : delete el._x_ignore;
    });
};
$caa9439642c6336c$var$directive("ignore", $caa9439642c6336c$var$handler);
// packages/alpinejs/src/directives/x-effect.js
$caa9439642c6336c$var$directive("effect", $caa9439642c6336c$var$skipDuringClone((el, { expression: expression }, { effect: effect3 })=>{
    effect3($caa9439642c6336c$var$evaluateLater(el, expression));
}));
// packages/alpinejs/src/utils/on.js
function $caa9439642c6336c$var$on(el, event, modifiers, callback) {
    let listenerTarget = el;
    let handler4 = (e)=>callback(e);
    let options = {};
    let wrapHandler = (callback2, wrapper)=>(e)=>wrapper(callback2, e);
    if (modifiers.includes("dot")) event = $caa9439642c6336c$var$dotSyntax(event);
    if (modifiers.includes("camel")) event = $caa9439642c6336c$var$camelCase2(event);
    if (modifiers.includes("passive")) options.passive = true;
    if (modifiers.includes("capture")) options.capture = true;
    if (modifiers.includes("window")) listenerTarget = window;
    if (modifiers.includes("document")) listenerTarget = document;
    if (modifiers.includes("debounce")) {
        let nextModifier = modifiers[modifiers.indexOf("debounce") + 1] || "invalid-wait";
        let wait = $caa9439642c6336c$var$isNumeric(nextModifier.split("ms")[0]) ? Number(nextModifier.split("ms")[0]) : 250;
        handler4 = $caa9439642c6336c$var$debounce(handler4, wait);
    }
    if (modifiers.includes("throttle")) {
        let nextModifier = modifiers[modifiers.indexOf("throttle") + 1] || "invalid-wait";
        let wait = $caa9439642c6336c$var$isNumeric(nextModifier.split("ms")[0]) ? Number(nextModifier.split("ms")[0]) : 250;
        handler4 = $caa9439642c6336c$var$throttle(handler4, wait);
    }
    if (modifiers.includes("prevent")) handler4 = wrapHandler(handler4, (next, e)=>{
        e.preventDefault();
        next(e);
    });
    if (modifiers.includes("stop")) handler4 = wrapHandler(handler4, (next, e)=>{
        e.stopPropagation();
        next(e);
    });
    if (modifiers.includes("once")) handler4 = wrapHandler(handler4, (next, e)=>{
        next(e);
        listenerTarget.removeEventListener(event, handler4, options);
    });
    if (modifiers.includes("away") || modifiers.includes("outside")) {
        listenerTarget = document;
        handler4 = wrapHandler(handler4, (next, e)=>{
            if (el.contains(e.target)) return;
            if (e.target.isConnected === false) return;
            if (el.offsetWidth < 1 && el.offsetHeight < 1) return;
            if (el._x_isShown === false) return;
            next(e);
        });
    }
    if (modifiers.includes("self")) handler4 = wrapHandler(handler4, (next, e)=>{
        e.target === el && next(e);
    });
    if ($caa9439642c6336c$var$isKeyEvent(event) || $caa9439642c6336c$var$isClickEvent(event)) handler4 = wrapHandler(handler4, (next, e)=>{
        if ($caa9439642c6336c$var$isListeningForASpecificKeyThatHasntBeenPressed(e, modifiers)) return;
        next(e);
    });
    listenerTarget.addEventListener(event, handler4, options);
    return ()=>{
        listenerTarget.removeEventListener(event, handler4, options);
    };
}
function $caa9439642c6336c$var$dotSyntax(subject) {
    return subject.replace(/-/g, ".");
}
function $caa9439642c6336c$var$camelCase2(subject) {
    return subject.toLowerCase().replace(/-(\w)/g, (match, char)=>char.toUpperCase());
}
function $caa9439642c6336c$var$isNumeric(subject) {
    return !Array.isArray(subject) && !isNaN(subject);
}
function $caa9439642c6336c$var$kebabCase2(subject) {
    if ([
        " ",
        "_"
    ].includes(subject)) return subject;
    return subject.replace(/([a-z])([A-Z])/g, "$1-$2").replace(/[_\s]/, "-").toLowerCase();
}
function $caa9439642c6336c$var$isKeyEvent(event) {
    return [
        "keydown",
        "keyup"
    ].includes(event);
}
function $caa9439642c6336c$var$isClickEvent(event) {
    return [
        "contextmenu",
        "click",
        "mouse"
    ].some((i)=>event.includes(i));
}
function $caa9439642c6336c$var$isListeningForASpecificKeyThatHasntBeenPressed(e, modifiers) {
    let keyModifiers = modifiers.filter((i)=>{
        return ![
            "window",
            "document",
            "prevent",
            "stop",
            "once",
            "capture",
            "self",
            "away",
            "outside",
            "passive"
        ].includes(i);
    });
    if (keyModifiers.includes("debounce")) {
        let debounceIndex = keyModifiers.indexOf("debounce");
        keyModifiers.splice(debounceIndex, $caa9439642c6336c$var$isNumeric((keyModifiers[debounceIndex + 1] || "invalid-wait").split("ms")[0]) ? 2 : 1);
    }
    if (keyModifiers.includes("throttle")) {
        let debounceIndex = keyModifiers.indexOf("throttle");
        keyModifiers.splice(debounceIndex, $caa9439642c6336c$var$isNumeric((keyModifiers[debounceIndex + 1] || "invalid-wait").split("ms")[0]) ? 2 : 1);
    }
    if (keyModifiers.length === 0) return false;
    if (keyModifiers.length === 1 && $caa9439642c6336c$var$keyToModifiers(e.key).includes(keyModifiers[0])) return false;
    const systemKeyModifiers = [
        "ctrl",
        "shift",
        "alt",
        "meta",
        "cmd",
        "super"
    ];
    const selectedSystemKeyModifiers = systemKeyModifiers.filter((modifier)=>keyModifiers.includes(modifier));
    keyModifiers = keyModifiers.filter((i)=>!selectedSystemKeyModifiers.includes(i));
    if (selectedSystemKeyModifiers.length > 0) {
        const activelyPressedKeyModifiers = selectedSystemKeyModifiers.filter((modifier)=>{
            if (modifier === "cmd" || modifier === "super") modifier = "meta";
            return e[`${modifier}Key`];
        });
        if (activelyPressedKeyModifiers.length === selectedSystemKeyModifiers.length) {
            if ($caa9439642c6336c$var$isClickEvent(e.type)) return false;
            if ($caa9439642c6336c$var$keyToModifiers(e.key).includes(keyModifiers[0])) return false;
        }
    }
    return true;
}
function $caa9439642c6336c$var$keyToModifiers(key) {
    if (!key) return [];
    key = $caa9439642c6336c$var$kebabCase2(key);
    let modifierToKeyMap = {
        "ctrl": "control",
        "slash": "/",
        "space": " ",
        "spacebar": " ",
        "cmd": "meta",
        "esc": "escape",
        "up": "arrow-up",
        "down": "arrow-down",
        "left": "arrow-left",
        "right": "arrow-right",
        "period": ".",
        "comma": ",",
        "equal": "=",
        "minus": "-",
        "underscore": "_"
    };
    modifierToKeyMap[key] = key;
    return Object.keys(modifierToKeyMap).map((modifier)=>{
        if (modifierToKeyMap[modifier] === key) return modifier;
    }).filter((modifier)=>modifier);
}
// packages/alpinejs/src/directives/x-model.js
$caa9439642c6336c$var$directive("model", (el, { modifiers: modifiers, expression: expression }, { effect: effect3, cleanup: cleanup2 })=>{
    let scopeTarget = el;
    if (modifiers.includes("parent")) scopeTarget = el.parentNode;
    let evaluateGet = $caa9439642c6336c$var$evaluateLater(scopeTarget, expression);
    let evaluateSet;
    if (typeof expression === "string") evaluateSet = $caa9439642c6336c$var$evaluateLater(scopeTarget, `${expression} = __placeholder`);
    else if (typeof expression === "function" && typeof expression() === "string") evaluateSet = $caa9439642c6336c$var$evaluateLater(scopeTarget, `${expression()} = __placeholder`);
    else evaluateSet = ()=>{};
    let getValue = ()=>{
        let result;
        evaluateGet((value)=>result = value);
        return $caa9439642c6336c$var$isGetterSetter(result) ? result.get() : result;
    };
    let setValue = (value)=>{
        let result;
        evaluateGet((value2)=>result = value2);
        if ($caa9439642c6336c$var$isGetterSetter(result)) result.set(value);
        else evaluateSet(()=>{}, {
            scope: {
                "__placeholder": value
            }
        });
    };
    if (typeof expression === "string" && el.type === "radio") $caa9439642c6336c$var$mutateDom(()=>{
        if (!el.hasAttribute("name")) el.setAttribute("name", expression);
    });
    var event = el.tagName.toLowerCase() === "select" || [
        "checkbox",
        "radio"
    ].includes(el.type) || modifiers.includes("lazy") ? "change" : "input";
    let removeListener = $caa9439642c6336c$var$isCloning ? ()=>{} : $caa9439642c6336c$var$on(el, event, modifiers, (e)=>{
        setValue($caa9439642c6336c$var$getInputValue(el, modifiers, e, getValue()));
    });
    if (modifiers.includes("fill")) {
        if ([
            void 0,
            null,
            ""
        ].includes(getValue()) || $caa9439642c6336c$var$isCheckbox(el) && Array.isArray(getValue()) || el.tagName.toLowerCase() === "select" && el.multiple) setValue($caa9439642c6336c$var$getInputValue(el, modifiers, {
            target: el
        }, getValue()));
    }
    if (!el._x_removeModelListeners) el._x_removeModelListeners = {};
    el._x_removeModelListeners["default"] = removeListener;
    cleanup2(()=>el._x_removeModelListeners["default"]());
    if (el.form) {
        let removeResetListener = $caa9439642c6336c$var$on(el.form, "reset", [], (e)=>{
            $caa9439642c6336c$var$nextTick(()=>el._x_model && el._x_model.set($caa9439642c6336c$var$getInputValue(el, modifiers, {
                    target: el
                }, getValue())));
        });
        cleanup2(()=>removeResetListener());
    }
    el._x_model = {
        get () {
            return getValue();
        },
        set (value) {
            setValue(value);
        }
    };
    el._x_forceModelUpdate = (value)=>{
        if (value === void 0 && typeof expression === "string" && expression.match(/\./)) value = "";
        window.fromModel = true;
        $caa9439642c6336c$var$mutateDom(()=>$caa9439642c6336c$var$bind(el, "value", value));
        delete window.fromModel;
    };
    effect3(()=>{
        let value = getValue();
        if (modifiers.includes("unintrusive") && document.activeElement.isSameNode(el)) return;
        el._x_forceModelUpdate(value);
    });
});
function $caa9439642c6336c$var$getInputValue(el, modifiers, event, currentValue) {
    return $caa9439642c6336c$var$mutateDom(()=>{
        if (event instanceof CustomEvent && event.detail !== void 0) return event.detail !== null && event.detail !== void 0 ? event.detail : event.target.value;
        else if ($caa9439642c6336c$var$isCheckbox(el)) {
            if (Array.isArray(currentValue)) {
                let newValue = null;
                if (modifiers.includes("number")) newValue = $caa9439642c6336c$var$safeParseNumber(event.target.value);
                else if (modifiers.includes("boolean")) newValue = $caa9439642c6336c$var$safeParseBoolean(event.target.value);
                else newValue = event.target.value;
                return event.target.checked ? currentValue.includes(newValue) ? currentValue : currentValue.concat([
                    newValue
                ]) : currentValue.filter((el2)=>!$caa9439642c6336c$var$checkedAttrLooseCompare2(el2, newValue));
            } else return event.target.checked;
        } else if (el.tagName.toLowerCase() === "select" && el.multiple) {
            if (modifiers.includes("number")) return Array.from(event.target.selectedOptions).map((option)=>{
                let rawValue = option.value || option.text;
                return $caa9439642c6336c$var$safeParseNumber(rawValue);
            });
            else if (modifiers.includes("boolean")) return Array.from(event.target.selectedOptions).map((option)=>{
                let rawValue = option.value || option.text;
                return $caa9439642c6336c$var$safeParseBoolean(rawValue);
            });
            return Array.from(event.target.selectedOptions).map((option)=>{
                return option.value || option.text;
            });
        } else {
            let newValue;
            if ($caa9439642c6336c$var$isRadio(el)) {
                if (event.target.checked) newValue = event.target.value;
                else newValue = currentValue;
            } else newValue = event.target.value;
            if (modifiers.includes("number")) return $caa9439642c6336c$var$safeParseNumber(newValue);
            else if (modifiers.includes("boolean")) return $caa9439642c6336c$var$safeParseBoolean(newValue);
            else if (modifiers.includes("trim")) return newValue.trim();
            else return newValue;
        }
    });
}
function $caa9439642c6336c$var$safeParseNumber(rawValue) {
    let number = rawValue ? parseFloat(rawValue) : null;
    return $caa9439642c6336c$var$isNumeric2(number) ? number : rawValue;
}
function $caa9439642c6336c$var$checkedAttrLooseCompare2(valueA, valueB) {
    return valueA == valueB;
}
function $caa9439642c6336c$var$isNumeric2(subject) {
    return !Array.isArray(subject) && !isNaN(subject);
}
function $caa9439642c6336c$var$isGetterSetter(value) {
    return value !== null && typeof value === "object" && typeof value.get === "function" && typeof value.set === "function";
}
// packages/alpinejs/src/directives/x-cloak.js
$caa9439642c6336c$var$directive("cloak", (el)=>queueMicrotask(()=>$caa9439642c6336c$var$mutateDom(()=>el.removeAttribute($caa9439642c6336c$var$prefix("cloak")))));
// packages/alpinejs/src/directives/x-init.js
$caa9439642c6336c$var$addInitSelector(()=>`[${$caa9439642c6336c$var$prefix("init")}]`);
$caa9439642c6336c$var$directive("init", $caa9439642c6336c$var$skipDuringClone((el, { expression: expression }, { evaluate: evaluate2 })=>{
    if (typeof expression === "string") return !!expression.trim() && evaluate2(expression, {}, false);
    return evaluate2(expression, {}, false);
}));
// packages/alpinejs/src/directives/x-text.js
$caa9439642c6336c$var$directive("text", (el, { expression: expression }, { effect: effect3, evaluateLater: evaluateLater2 })=>{
    let evaluate2 = evaluateLater2(expression);
    effect3(()=>{
        evaluate2((value)=>{
            $caa9439642c6336c$var$mutateDom(()=>{
                el.textContent = value;
            });
        });
    });
});
// packages/alpinejs/src/directives/x-html.js
$caa9439642c6336c$var$directive("html", (el, { expression: expression }, { effect: effect3, evaluateLater: evaluateLater2 })=>{
    let evaluate2 = evaluateLater2(expression);
    effect3(()=>{
        evaluate2((value)=>{
            $caa9439642c6336c$var$mutateDom(()=>{
                el.innerHTML = value;
                el._x_ignoreSelf = true;
                $caa9439642c6336c$var$initTree(el);
                delete el._x_ignoreSelf;
            });
        });
    });
});
// packages/alpinejs/src/directives/x-bind.js
$caa9439642c6336c$var$mapAttributes($caa9439642c6336c$var$startingWith(":", $caa9439642c6336c$var$into($caa9439642c6336c$var$prefix("bind:"))));
var $caa9439642c6336c$var$handler2 = (el, { value: value, modifiers: modifiers, expression: expression, original: original }, { effect: effect3, cleanup: cleanup2 })=>{
    if (!value) {
        let bindingProviders = {};
        $caa9439642c6336c$var$injectBindingProviders(bindingProviders);
        let getBindings = $caa9439642c6336c$var$evaluateLater(el, expression);
        getBindings((bindings)=>{
            $caa9439642c6336c$var$applyBindingsObject(el, bindings, original);
        }, {
            scope: bindingProviders
        });
        return;
    }
    if (value === "key") return $caa9439642c6336c$var$storeKeyForXFor(el, expression);
    if (el._x_inlineBindings && el._x_inlineBindings[value] && el._x_inlineBindings[value].extract) return;
    let evaluate2 = $caa9439642c6336c$var$evaluateLater(el, expression);
    effect3(()=>evaluate2((result)=>{
            if (result === void 0 && typeof expression === "string" && expression.match(/\./)) result = "";
            $caa9439642c6336c$var$mutateDom(()=>$caa9439642c6336c$var$bind(el, value, result, modifiers));
        }));
    cleanup2(()=>{
        el._x_undoAddedClasses && el._x_undoAddedClasses();
        el._x_undoAddedStyles && el._x_undoAddedStyles();
    });
};
$caa9439642c6336c$var$handler2.inline = (el, { value: value, modifiers: modifiers, expression: expression })=>{
    if (!value) return;
    if (!el._x_inlineBindings) el._x_inlineBindings = {};
    el._x_inlineBindings[value] = {
        expression: expression,
        extract: false
    };
};
$caa9439642c6336c$var$directive("bind", $caa9439642c6336c$var$handler2);
function $caa9439642c6336c$var$storeKeyForXFor(el, expression) {
    el._x_keyExpression = expression;
}
// packages/alpinejs/src/directives/x-data.js
$caa9439642c6336c$var$addRootSelector(()=>`[${$caa9439642c6336c$var$prefix("data")}]`);
$caa9439642c6336c$var$directive("data", (el, { expression: expression }, { cleanup: cleanup2 })=>{
    if ($caa9439642c6336c$var$shouldSkipRegisteringDataDuringClone(el)) return;
    expression = expression === "" ? "{}" : expression;
    let magicContext = {};
    $caa9439642c6336c$var$injectMagics(magicContext, el);
    let dataProviderContext = {};
    $caa9439642c6336c$var$injectDataProviders(dataProviderContext, magicContext);
    let data2 = $caa9439642c6336c$var$evaluate(el, expression, {
        scope: dataProviderContext
    });
    if (data2 === void 0 || data2 === true) data2 = {};
    $caa9439642c6336c$var$injectMagics(data2, el);
    let reactiveData = $caa9439642c6336c$var$reactive(data2);
    $caa9439642c6336c$var$initInterceptors(reactiveData);
    let undo = $caa9439642c6336c$var$addScopeToNode(el, reactiveData);
    reactiveData["init"] && $caa9439642c6336c$var$evaluate(el, reactiveData["init"]);
    cleanup2(()=>{
        reactiveData["destroy"] && $caa9439642c6336c$var$evaluate(el, reactiveData["destroy"]);
        undo();
    });
});
$caa9439642c6336c$var$interceptClone((from, to)=>{
    if (from._x_dataStack) {
        to._x_dataStack = from._x_dataStack;
        to.setAttribute("data-has-alpine-state", true);
    }
});
function $caa9439642c6336c$var$shouldSkipRegisteringDataDuringClone(el) {
    if (!$caa9439642c6336c$var$isCloning) return false;
    if ($caa9439642c6336c$var$isCloningLegacy) return true;
    return el.hasAttribute("data-has-alpine-state");
}
// packages/alpinejs/src/directives/x-show.js
$caa9439642c6336c$var$directive("show", (el, { modifiers: modifiers, expression: expression }, { effect: effect3 })=>{
    let evaluate2 = $caa9439642c6336c$var$evaluateLater(el, expression);
    if (!el._x_doHide) el._x_doHide = ()=>{
        $caa9439642c6336c$var$mutateDom(()=>{
            el.style.setProperty("display", "none", modifiers.includes("important") ? "important" : void 0);
        });
    };
    if (!el._x_doShow) el._x_doShow = ()=>{
        $caa9439642c6336c$var$mutateDom(()=>{
            if (el.style.length === 1 && el.style.display === "none") el.removeAttribute("style");
            else el.style.removeProperty("display");
        });
    };
    let hide = ()=>{
        el._x_doHide();
        el._x_isShown = false;
    };
    let show = ()=>{
        el._x_doShow();
        el._x_isShown = true;
    };
    let clickAwayCompatibleShow = ()=>setTimeout(show);
    let toggle = $caa9439642c6336c$var$once((value)=>value ? show() : hide(), (value)=>{
        if (typeof el._x_toggleAndCascadeWithTransitions === "function") el._x_toggleAndCascadeWithTransitions(el, value, show, hide);
        else value ? clickAwayCompatibleShow() : hide();
    });
    let oldValue;
    let firstTime = true;
    effect3(()=>evaluate2((value)=>{
            if (!firstTime && value === oldValue) return;
            if (modifiers.includes("immediate")) value ? clickAwayCompatibleShow() : hide();
            toggle(value);
            oldValue = value;
            firstTime = false;
        }));
});
// packages/alpinejs/src/directives/x-for.js
$caa9439642c6336c$var$directive("for", (el, { expression: expression }, { effect: effect3, cleanup: cleanup2 })=>{
    let iteratorNames = $caa9439642c6336c$var$parseForExpression(expression);
    let evaluateItems = $caa9439642c6336c$var$evaluateLater(el, iteratorNames.items);
    let evaluateKey = $caa9439642c6336c$var$evaluateLater(el, // the x-bind:key expression is stored for our use instead of evaluated.
    el._x_keyExpression || "index");
    el._x_prevKeys = [];
    el._x_lookup = {};
    effect3(()=>$caa9439642c6336c$var$loop(el, iteratorNames, evaluateItems, evaluateKey));
    cleanup2(()=>{
        Object.values(el._x_lookup).forEach((el2)=>$caa9439642c6336c$var$mutateDom(()=>{
                $caa9439642c6336c$var$destroyTree(el2);
                el2.remove();
            }));
        delete el._x_prevKeys;
        delete el._x_lookup;
    });
});
function $caa9439642c6336c$var$loop(el, iteratorNames, evaluateItems, evaluateKey) {
    let isObject2 = (i)=>typeof i === "object" && !Array.isArray(i);
    let templateEl = el;
    evaluateItems((items)=>{
        if ($caa9439642c6336c$var$isNumeric3(items) && items >= 0) items = Array.from(Array(items).keys(), (i)=>i + 1);
        if (items === void 0) items = [];
        let lookup = el._x_lookup;
        let prevKeys = el._x_prevKeys;
        let scopes = [];
        let keys = [];
        if (isObject2(items)) items = Object.entries(items).map(([key, value])=>{
            let scope2 = $caa9439642c6336c$var$getIterationScopeVariables(iteratorNames, value, key, items);
            evaluateKey((value2)=>{
                if (keys.includes(value2)) $caa9439642c6336c$var$warn("Duplicate key on x-for", el);
                keys.push(value2);
            }, {
                scope: {
                    index: key,
                    ...scope2
                }
            });
            scopes.push(scope2);
        });
        else for(let i = 0; i < items.length; i++){
            let scope2 = $caa9439642c6336c$var$getIterationScopeVariables(iteratorNames, items[i], i, items);
            evaluateKey((value)=>{
                if (keys.includes(value)) $caa9439642c6336c$var$warn("Duplicate key on x-for", el);
                keys.push(value);
            }, {
                scope: {
                    index: i,
                    ...scope2
                }
            });
            scopes.push(scope2);
        }
        let adds = [];
        let moves = [];
        let removes = [];
        let sames = [];
        for(let i = 0; i < prevKeys.length; i++){
            let key = prevKeys[i];
            if (keys.indexOf(key) === -1) removes.push(key);
        }
        prevKeys = prevKeys.filter((key)=>!removes.includes(key));
        let lastKey = "template";
        for(let i = 0; i < keys.length; i++){
            let key = keys[i];
            let prevIndex = prevKeys.indexOf(key);
            if (prevIndex === -1) {
                prevKeys.splice(i, 0, key);
                adds.push([
                    lastKey,
                    i
                ]);
            } else if (prevIndex !== i) {
                let keyInSpot = prevKeys.splice(i, 1)[0];
                let keyForSpot = prevKeys.splice(prevIndex - 1, 1)[0];
                prevKeys.splice(i, 0, keyForSpot);
                prevKeys.splice(prevIndex, 0, keyInSpot);
                moves.push([
                    keyInSpot,
                    keyForSpot
                ]);
            } else sames.push(key);
            lastKey = key;
        }
        for(let i = 0; i < removes.length; i++){
            let key = removes[i];
            if (!(key in lookup)) continue;
            $caa9439642c6336c$var$mutateDom(()=>{
                $caa9439642c6336c$var$destroyTree(lookup[key]);
                lookup[key].remove();
            });
            delete lookup[key];
        }
        for(let i = 0; i < moves.length; i++){
            let [keyInSpot, keyForSpot] = moves[i];
            let elInSpot = lookup[keyInSpot];
            let elForSpot = lookup[keyForSpot];
            let marker = document.createElement("div");
            $caa9439642c6336c$var$mutateDom(()=>{
                if (!elForSpot) $caa9439642c6336c$var$warn(`x-for ":key" is undefined or invalid`, templateEl, keyForSpot, lookup);
                elForSpot.after(marker);
                elInSpot.after(elForSpot);
                elForSpot._x_currentIfEl && elForSpot.after(elForSpot._x_currentIfEl);
                marker.before(elInSpot);
                elInSpot._x_currentIfEl && elInSpot.after(elInSpot._x_currentIfEl);
                marker.remove();
            });
            elForSpot._x_refreshXForScope(scopes[keys.indexOf(keyForSpot)]);
        }
        for(let i = 0; i < adds.length; i++){
            let [lastKey2, index] = adds[i];
            let lastEl = lastKey2 === "template" ? templateEl : lookup[lastKey2];
            if (lastEl._x_currentIfEl) lastEl = lastEl._x_currentIfEl;
            let scope2 = scopes[index];
            let key = keys[index];
            let clone2 = document.importNode(templateEl.content, true).firstElementChild;
            let reactiveScope = $caa9439642c6336c$var$reactive(scope2);
            $caa9439642c6336c$var$addScopeToNode(clone2, reactiveScope, templateEl);
            clone2._x_refreshXForScope = (newScope)=>{
                Object.entries(newScope).forEach(([key2, value])=>{
                    reactiveScope[key2] = value;
                });
            };
            $caa9439642c6336c$var$mutateDom(()=>{
                lastEl.after(clone2);
                $caa9439642c6336c$var$skipDuringClone(()=>$caa9439642c6336c$var$initTree(clone2))();
            });
            if (typeof key === "object") $caa9439642c6336c$var$warn("x-for key cannot be an object, it must be a string or an integer", templateEl);
            lookup[key] = clone2;
        }
        for(let i = 0; i < sames.length; i++)lookup[sames[i]]._x_refreshXForScope(scopes[keys.indexOf(sames[i])]);
        templateEl._x_prevKeys = keys;
    });
}
function $caa9439642c6336c$var$parseForExpression(expression) {
    let forIteratorRE = /,([^,\}\]]*)(?:,([^,\}\]]*))?$/;
    let stripParensRE = /^\s*\(|\)\s*$/g;
    let forAliasRE = /([\s\S]*?)\s+(?:in|of)\s+([\s\S]*)/;
    let inMatch = expression.match(forAliasRE);
    if (!inMatch) return;
    let res = {};
    res.items = inMatch[2].trim();
    let item = inMatch[1].replace(stripParensRE, "").trim();
    let iteratorMatch = item.match(forIteratorRE);
    if (iteratorMatch) {
        res.item = item.replace(forIteratorRE, "").trim();
        res.index = iteratorMatch[1].trim();
        if (iteratorMatch[2]) res.collection = iteratorMatch[2].trim();
    } else res.item = item;
    return res;
}
function $caa9439642c6336c$var$getIterationScopeVariables(iteratorNames, item, index, items) {
    let scopeVariables = {};
    if (/^\[.*\]$/.test(iteratorNames.item) && Array.isArray(item)) {
        let names = iteratorNames.item.replace("[", "").replace("]", "").split(",").map((i)=>i.trim());
        names.forEach((name, i)=>{
            scopeVariables[name] = item[i];
        });
    } else if (/^\{.*\}$/.test(iteratorNames.item) && !Array.isArray(item) && typeof item === "object") {
        let names = iteratorNames.item.replace("{", "").replace("}", "").split(",").map((i)=>i.trim());
        names.forEach((name)=>{
            scopeVariables[name] = item[name];
        });
    } else scopeVariables[iteratorNames.item] = item;
    if (iteratorNames.index) scopeVariables[iteratorNames.index] = index;
    if (iteratorNames.collection) scopeVariables[iteratorNames.collection] = items;
    return scopeVariables;
}
function $caa9439642c6336c$var$isNumeric3(subject) {
    return !Array.isArray(subject) && !isNaN(subject);
}
// packages/alpinejs/src/directives/x-ref.js
function $caa9439642c6336c$var$handler3() {}
$caa9439642c6336c$var$handler3.inline = (el, { expression: expression }, { cleanup: cleanup2 })=>{
    let root = $caa9439642c6336c$var$closestRoot(el);
    if (!root._x_refs) root._x_refs = {};
    root._x_refs[expression] = el;
    cleanup2(()=>delete root._x_refs[expression]);
};
$caa9439642c6336c$var$directive("ref", $caa9439642c6336c$var$handler3);
// packages/alpinejs/src/directives/x-if.js
$caa9439642c6336c$var$directive("if", (el, { expression: expression }, { effect: effect3, cleanup: cleanup2 })=>{
    if (el.tagName.toLowerCase() !== "template") $caa9439642c6336c$var$warn("x-if can only be used on a <template> tag", el);
    let evaluate2 = $caa9439642c6336c$var$evaluateLater(el, expression);
    let show = ()=>{
        if (el._x_currentIfEl) return el._x_currentIfEl;
        let clone2 = el.content.cloneNode(true).firstElementChild;
        $caa9439642c6336c$var$addScopeToNode(clone2, {}, el);
        $caa9439642c6336c$var$mutateDom(()=>{
            el.after(clone2);
            $caa9439642c6336c$var$skipDuringClone(()=>$caa9439642c6336c$var$initTree(clone2))();
        });
        el._x_currentIfEl = clone2;
        el._x_undoIf = ()=>{
            $caa9439642c6336c$var$mutateDom(()=>{
                $caa9439642c6336c$var$destroyTree(clone2);
                clone2.remove();
            });
            delete el._x_currentIfEl;
        };
        return clone2;
    };
    let hide = ()=>{
        if (!el._x_undoIf) return;
        el._x_undoIf();
        delete el._x_undoIf;
    };
    effect3(()=>evaluate2((value)=>{
            value ? show() : hide();
        }));
    cleanup2(()=>el._x_undoIf && el._x_undoIf());
});
// packages/alpinejs/src/directives/x-id.js
$caa9439642c6336c$var$directive("id", (el, { expression: expression }, { evaluate: evaluate2 })=>{
    let names = evaluate2(expression);
    names.forEach((name)=>$caa9439642c6336c$var$setIdRoot(el, name));
});
$caa9439642c6336c$var$interceptClone((from, to)=>{
    if (from._x_ids) to._x_ids = from._x_ids;
});
// packages/alpinejs/src/directives/x-on.js
$caa9439642c6336c$var$mapAttributes($caa9439642c6336c$var$startingWith("@", $caa9439642c6336c$var$into($caa9439642c6336c$var$prefix("on:"))));
$caa9439642c6336c$var$directive("on", $caa9439642c6336c$var$skipDuringClone((el, { value: value, modifiers: modifiers, expression: expression }, { cleanup: cleanup2 })=>{
    let evaluate2 = expression ? $caa9439642c6336c$var$evaluateLater(el, expression) : ()=>{};
    if (el.tagName.toLowerCase() === "template") {
        if (!el._x_forwardEvents) el._x_forwardEvents = [];
        if (!el._x_forwardEvents.includes(value)) el._x_forwardEvents.push(value);
    }
    let removeListener = $caa9439642c6336c$var$on(el, value, modifiers, (e)=>{
        evaluate2(()=>{}, {
            scope: {
                "$event": e
            },
            params: [
                e
            ]
        });
    });
    cleanup2(()=>removeListener());
}));
// packages/alpinejs/src/directives/index.js
$caa9439642c6336c$var$warnMissingPluginDirective("Collapse", "collapse", "collapse");
$caa9439642c6336c$var$warnMissingPluginDirective("Intersect", "intersect", "intersect");
$caa9439642c6336c$var$warnMissingPluginDirective("Focus", "trap", "focus");
$caa9439642c6336c$var$warnMissingPluginDirective("Mask", "mask", "mask");
function $caa9439642c6336c$var$warnMissingPluginDirective(name, directiveName, slug) {
    $caa9439642c6336c$var$directive(directiveName, (el)=>$caa9439642c6336c$var$warn(`You can't use [x-${directiveName}] without first installing the "${name}" plugin here: https://alpinejs.dev/plugins/${slug}`, el));
}
// packages/alpinejs/src/index.js
$caa9439642c6336c$var$alpine_default.setEvaluator($caa9439642c6336c$var$normalEvaluator);
$caa9439642c6336c$var$alpine_default.setReactivityEngine({
    reactive: $caa9439642c6336c$var$reactive2,
    effect: $caa9439642c6336c$var$effect2,
    release: $caa9439642c6336c$var$stop,
    raw: $caa9439642c6336c$var$toRaw
});
var $caa9439642c6336c$export$b7ee041e4ad2afec = $caa9439642c6336c$var$alpine_default;
// packages/alpinejs/builds/module.js
var $caa9439642c6336c$export$2e2bcd8739ae039 = $caa9439642c6336c$export$b7ee041e4ad2afec;


// packages/morph/src/morph.js
function $512e3a9270ec7803$var$morph(from, toHtml, options) {
    $512e3a9270ec7803$var$monkeyPatchDomSetAttributeToAllowAtSymbols();
    let fromEl;
    let toEl;
    let key, lookahead, updating, updated, removing, removed, adding, added;
    function assignOptions(options2 = {}) {
        let defaultGetKey = (el)=>el.getAttribute("key");
        let noop = ()=>{};
        updating = options2.updating || noop;
        updated = options2.updated || noop;
        removing = options2.removing || noop;
        removed = options2.removed || noop;
        adding = options2.adding || noop;
        added = options2.added || noop;
        key = options2.key || defaultGetKey;
        lookahead = options2.lookahead || false;
    }
    function patch(from2, to) {
        if (differentElementNamesTypesOrKeys(from2, to)) return swapElements(from2, to);
        let updateChildrenOnly = false;
        let skipChildren = false;
        if ($512e3a9270ec7803$var$shouldSkipChildren(updating, ()=>skipChildren = true, from2, to, ()=>updateChildrenOnly = true)) return;
        if (from2.nodeType === 1 && window.Alpine) {
            window.Alpine.cloneNode(from2, to);
            if (from2._x_teleport && to._x_teleport) patch(from2._x_teleport, to._x_teleport);
        }
        if ($512e3a9270ec7803$var$textOrComment(to)) {
            patchNodeValue(from2, to);
            updated(from2, to);
            return;
        }
        if (!updateChildrenOnly) patchAttributes(from2, to);
        updated(from2, to);
        if (!skipChildren) patchChildren(from2, to);
    }
    function differentElementNamesTypesOrKeys(from2, to) {
        return from2.nodeType != to.nodeType || from2.nodeName != to.nodeName || getKey(from2) != getKey(to);
    }
    function swapElements(from2, to) {
        if ($512e3a9270ec7803$var$shouldSkip(removing, from2)) return;
        let toCloned = to.cloneNode(true);
        if ($512e3a9270ec7803$var$shouldSkip(adding, toCloned)) return;
        from2.replaceWith(toCloned);
        removed(from2);
        added(toCloned);
    }
    function patchNodeValue(from2, to) {
        let value = to.nodeValue;
        if (from2.nodeValue !== value) from2.nodeValue = value;
    }
    function patchAttributes(from2, to) {
        if (from2._x_transitioning) return;
        if (from2._x_isShown && !to._x_isShown) return;
        if (!from2._x_isShown && to._x_isShown) return;
        let domAttributes = Array.from(from2.attributes);
        let toAttributes = Array.from(to.attributes);
        for(let i = domAttributes.length - 1; i >= 0; i--){
            let name = domAttributes[i].name;
            if (!to.hasAttribute(name)) from2.removeAttribute(name);
        }
        for(let i = toAttributes.length - 1; i >= 0; i--){
            let name = toAttributes[i].name;
            let value = toAttributes[i].value;
            if (from2.getAttribute(name) !== value) from2.setAttribute(name, value);
        }
    }
    function patchChildren(from2, to) {
        let fromKeys = keyToMap(from2.children);
        let fromKeyHoldovers = {};
        let currentTo = $512e3a9270ec7803$var$getFirstNode(to);
        let currentFrom = $512e3a9270ec7803$var$getFirstNode(from2);
        while(currentTo){
            $512e3a9270ec7803$var$seedingMatchingId(currentTo, currentFrom);
            let toKey = getKey(currentTo);
            let fromKey = getKey(currentFrom);
            if (!currentFrom) {
                if (toKey && fromKeyHoldovers[toKey]) {
                    let holdover = fromKeyHoldovers[toKey];
                    from2.appendChild(holdover);
                    currentFrom = holdover;
                    fromKey = getKey(currentFrom);
                } else {
                    if (!$512e3a9270ec7803$var$shouldSkip(adding, currentTo)) {
                        let clone = currentTo.cloneNode(true);
                        from2.appendChild(clone);
                        added(clone);
                    }
                    currentTo = $512e3a9270ec7803$var$getNextSibling(to, currentTo);
                    continue;
                }
            }
            let isIf = (node)=>node && node.nodeType === 8 && node.textContent === "[if BLOCK]><![endif]";
            let isEnd = (node)=>node && node.nodeType === 8 && node.textContent === "[if ENDBLOCK]><![endif]";
            if (isIf(currentTo) && isIf(currentFrom)) {
                let nestedIfCount = 0;
                let fromBlockStart = currentFrom;
                while(currentFrom){
                    let next = $512e3a9270ec7803$var$getNextSibling(from2, currentFrom);
                    if (isIf(next)) nestedIfCount++;
                    else if (isEnd(next) && nestedIfCount > 0) nestedIfCount--;
                    else if (isEnd(next) && nestedIfCount === 0) {
                        currentFrom = next;
                        break;
                    }
                    currentFrom = next;
                }
                let fromBlockEnd = currentFrom;
                nestedIfCount = 0;
                let toBlockStart = currentTo;
                while(currentTo){
                    let next = $512e3a9270ec7803$var$getNextSibling(to, currentTo);
                    if (isIf(next)) nestedIfCount++;
                    else if (isEnd(next) && nestedIfCount > 0) nestedIfCount--;
                    else if (isEnd(next) && nestedIfCount === 0) {
                        currentTo = next;
                        break;
                    }
                    currentTo = next;
                }
                let toBlockEnd = currentTo;
                let fromBlock = new $512e3a9270ec7803$var$Block(fromBlockStart, fromBlockEnd);
                let toBlock = new $512e3a9270ec7803$var$Block(toBlockStart, toBlockEnd);
                patchChildren(fromBlock, toBlock);
                continue;
            }
            if (currentFrom.nodeType === 1 && lookahead && !currentFrom.isEqualNode(currentTo)) {
                let nextToElementSibling = $512e3a9270ec7803$var$getNextSibling(to, currentTo);
                let found = false;
                while(!found && nextToElementSibling){
                    if (nextToElementSibling.nodeType === 1 && currentFrom.isEqualNode(nextToElementSibling)) {
                        found = true;
                        currentFrom = addNodeBefore(from2, currentTo, currentFrom);
                        fromKey = getKey(currentFrom);
                    }
                    nextToElementSibling = $512e3a9270ec7803$var$getNextSibling(to, nextToElementSibling);
                }
            }
            if (toKey !== fromKey) {
                if (!toKey && fromKey) {
                    fromKeyHoldovers[fromKey] = currentFrom;
                    currentFrom = addNodeBefore(from2, currentTo, currentFrom);
                    fromKeyHoldovers[fromKey].remove();
                    currentFrom = $512e3a9270ec7803$var$getNextSibling(from2, currentFrom);
                    currentTo = $512e3a9270ec7803$var$getNextSibling(to, currentTo);
                    continue;
                }
                if (toKey && !fromKey) {
                    if (fromKeys[toKey]) {
                        currentFrom.replaceWith(fromKeys[toKey]);
                        currentFrom = fromKeys[toKey];
                        fromKey = getKey(currentFrom);
                    }
                }
                if (toKey && fromKey) {
                    let fromKeyNode = fromKeys[toKey];
                    if (fromKeyNode) {
                        fromKeyHoldovers[fromKey] = currentFrom;
                        currentFrom.replaceWith(fromKeyNode);
                        currentFrom = fromKeyNode;
                        fromKey = getKey(currentFrom);
                    } else {
                        fromKeyHoldovers[fromKey] = currentFrom;
                        currentFrom = addNodeBefore(from2, currentTo, currentFrom);
                        fromKeyHoldovers[fromKey].remove();
                        currentFrom = $512e3a9270ec7803$var$getNextSibling(from2, currentFrom);
                        currentTo = $512e3a9270ec7803$var$getNextSibling(to, currentTo);
                        continue;
                    }
                }
            }
            let currentFromNext = currentFrom && $512e3a9270ec7803$var$getNextSibling(from2, currentFrom);
            patch(currentFrom, currentTo);
            currentTo = currentTo && $512e3a9270ec7803$var$getNextSibling(to, currentTo);
            currentFrom = currentFromNext;
        }
        let removals = [];
        while(currentFrom){
            if (!$512e3a9270ec7803$var$shouldSkip(removing, currentFrom)) removals.push(currentFrom);
            currentFrom = $512e3a9270ec7803$var$getNextSibling(from2, currentFrom);
        }
        while(removals.length){
            let domForRemoval = removals.shift();
            domForRemoval.remove();
            removed(domForRemoval);
        }
    }
    function getKey(el) {
        return el && el.nodeType === 1 && key(el);
    }
    function keyToMap(els) {
        let map = {};
        for (let el of els){
            let theKey = getKey(el);
            if (theKey) map[theKey] = el;
        }
        return map;
    }
    function addNodeBefore(parent, node, beforeMe) {
        if (!$512e3a9270ec7803$var$shouldSkip(adding, node)) {
            let clone = node.cloneNode(true);
            parent.insertBefore(clone, beforeMe);
            added(clone);
            return clone;
        }
        return node;
    }
    assignOptions(options);
    fromEl = from;
    toEl = typeof toHtml === "string" ? $512e3a9270ec7803$var$createElement(toHtml) : toHtml;
    if (window.Alpine && window.Alpine.closestDataStack && !from._x_dataStack) {
        toEl._x_dataStack = window.Alpine.closestDataStack(from);
        toEl._x_dataStack && window.Alpine.cloneNode(from, toEl);
    }
    patch(from, toEl);
    fromEl = void 0;
    toEl = void 0;
    return from;
}
$512e3a9270ec7803$var$morph.step = ()=>{};
$512e3a9270ec7803$var$morph.log = ()=>{};
function $512e3a9270ec7803$var$shouldSkip(hook, ...args) {
    let skip = false;
    hook(...args, ()=>skip = true);
    return skip;
}
function $512e3a9270ec7803$var$shouldSkipChildren(hook, skipChildren, ...args) {
    let skip = false;
    hook(...args, ()=>skip = true, skipChildren);
    return skip;
}
var $512e3a9270ec7803$var$patched = false;
function $512e3a9270ec7803$var$createElement(html) {
    const template = document.createElement("template");
    template.innerHTML = html;
    return template.content.firstElementChild;
}
function $512e3a9270ec7803$var$textOrComment(el) {
    return el.nodeType === 3 || el.nodeType === 8;
}
var $512e3a9270ec7803$var$Block = class {
    constructor(start, end){
        this.startComment = start;
        this.endComment = end;
    }
    get children() {
        let children = [];
        let currentNode = this.startComment.nextSibling;
        while(currentNode && currentNode !== this.endComment){
            children.push(currentNode);
            currentNode = currentNode.nextSibling;
        }
        return children;
    }
    appendChild(child) {
        this.endComment.before(child);
    }
    get firstChild() {
        let first = this.startComment.nextSibling;
        if (first === this.endComment) return;
        return first;
    }
    nextNode(reference) {
        let next = reference.nextSibling;
        if (next === this.endComment) return;
        return next;
    }
    insertBefore(newNode, reference) {
        reference.before(newNode);
        return newNode;
    }
};
function $512e3a9270ec7803$var$getFirstNode(parent) {
    return parent.firstChild;
}
function $512e3a9270ec7803$var$getNextSibling(parent, reference) {
    let next;
    if (parent instanceof $512e3a9270ec7803$var$Block) next = parent.nextNode(reference);
    else next = reference.nextSibling;
    return next;
}
function $512e3a9270ec7803$var$monkeyPatchDomSetAttributeToAllowAtSymbols() {
    if ($512e3a9270ec7803$var$patched) return;
    $512e3a9270ec7803$var$patched = true;
    let original = Element.prototype.setAttribute;
    let hostDiv = document.createElement("div");
    Element.prototype.setAttribute = function newSetAttribute(name, value) {
        if (!name.includes("@")) return original.call(this, name, value);
        hostDiv.innerHTML = `<span ${name}="${value}"></span>`;
        let attr = hostDiv.firstElementChild.getAttributeNode(name);
        hostDiv.firstElementChild.removeAttributeNode(attr);
        this.setAttributeNode(attr);
    };
}
function $512e3a9270ec7803$var$seedingMatchingId(to, from) {
    let fromId = from && from._x_bindings && from._x_bindings.id;
    if (!fromId) return;
    if (!to.setAttribute) return;
    to.setAttribute("id", fromId);
    to.id = fromId;
}
// packages/morph/src/index.js
function $512e3a9270ec7803$export$2e5e8c41f5d4e7c7(Alpine) {
    Alpine.morph = $512e3a9270ec7803$var$morph;
}
// packages/morph/builds/module.js
var $512e3a9270ec7803$export$2e2bcd8739ae039 = $512e3a9270ec7803$export$2e5e8c41f5d4e7c7;


// packages/persist/src/index.js
function $a5acee56471cec18$export$9a6132153fba2e0(Alpine) {
    let persist = ()=>{
        let alias;
        let storage;
        try {
            storage = localStorage;
        } catch (e) {
            console.error(e);
            console.warn("Alpine: $persist is using temporary storage since localStorage is unavailable.");
            let dummy = /* @__PURE__ */ new Map();
            storage = {
                getItem: dummy.get.bind(dummy),
                setItem: dummy.set.bind(dummy)
            };
        }
        return Alpine.interceptor((initialValue, getter, setter, path, key)=>{
            let lookup = alias || `_x_${path}`;
            let initial = $a5acee56471cec18$var$storageHas(lookup, storage) ? $a5acee56471cec18$var$storageGet(lookup, storage) : initialValue;
            setter(initial);
            Alpine.effect(()=>{
                let value = getter();
                $a5acee56471cec18$var$storageSet(lookup, value, storage);
                setter(value);
            });
            return initial;
        }, (func)=>{
            func.as = (key)=>{
                alias = key;
                return func;
            }, func.using = (target)=>{
                storage = target;
                return func;
            };
        });
    };
    Object.defineProperty(Alpine, "$persist", {
        get: ()=>persist()
    });
    Alpine.magic("persist", persist);
    Alpine.persist = (key, { get: get, set: set }, storage = localStorage)=>{
        let initial = $a5acee56471cec18$var$storageHas(key, storage) ? $a5acee56471cec18$var$storageGet(key, storage) : get();
        set(initial);
        Alpine.effect(()=>{
            let value = get();
            $a5acee56471cec18$var$storageSet(key, value, storage);
            set(value);
        });
    };
}
function $a5acee56471cec18$var$storageHas(key, storage) {
    return storage.getItem(key) !== null;
}
function $a5acee56471cec18$var$storageGet(key, storage) {
    let value = storage.getItem(key, storage);
    if (value === void 0) return;
    return JSON.parse(value);
}
function $a5acee56471cec18$var$storageSet(key, value, storage) {
    storage.setItem(key, JSON.stringify(value));
}
// packages/persist/builds/module.js
var $a5acee56471cec18$export$2e2bcd8739ae039 = $a5acee56471cec18$export$9a6132153fba2e0;


var $69a8ec8dbeef3157$var$__create = Object.create;
var $69a8ec8dbeef3157$var$__defProp = Object.defineProperty;
var $69a8ec8dbeef3157$var$__getProtoOf = Object.getPrototypeOf;
var $69a8ec8dbeef3157$var$__hasOwnProp = Object.prototype.hasOwnProperty;
var $69a8ec8dbeef3157$var$__getOwnPropNames = Object.getOwnPropertyNames;
var $69a8ec8dbeef3157$var$__getOwnPropDesc = Object.getOwnPropertyDescriptor;
var $69a8ec8dbeef3157$var$__markAsModule = (target)=>$69a8ec8dbeef3157$var$__defProp(target, "__esModule", {
        value: true
    });
var $69a8ec8dbeef3157$var$__commonJS = (callback, module)=>()=>{
        if (!module) {
            module = {
                exports: {}
            };
            callback(module.exports, module);
        }
        return module.exports;
    };
var $69a8ec8dbeef3157$var$__exportStar = (target, module, desc)=>{
    if (module && typeof module === "object" || typeof module === "function") {
        for (let key of $69a8ec8dbeef3157$var$__getOwnPropNames(module))if (!$69a8ec8dbeef3157$var$__hasOwnProp.call(target, key) && key !== "default") $69a8ec8dbeef3157$var$__defProp(target, key, {
            get: ()=>module[key],
            enumerable: !(desc = $69a8ec8dbeef3157$var$__getOwnPropDesc(module, key)) || desc.enumerable
        });
    }
    return target;
};
var $69a8ec8dbeef3157$var$__toModule = (module)=>{
    return $69a8ec8dbeef3157$var$__exportStar($69a8ec8dbeef3157$var$__markAsModule($69a8ec8dbeef3157$var$__defProp(module != null ? $69a8ec8dbeef3157$var$__create($69a8ec8dbeef3157$var$__getProtoOf(module)) : {}, "default", module && module.__esModule && "default" in module ? {
        get: ()=>module.default,
        enumerable: true
    } : {
        value: module,
        enumerable: true
    })), module);
};
// node_modules/@popperjs/core/dist/cjs/popper.js
var $69a8ec8dbeef3157$var$require_popper = $69a8ec8dbeef3157$var$__commonJS((exports)=>{
    "use strict";
    Object.defineProperty(exports, "__esModule", {
        value: true
    });
    function getBoundingClientRect(element) {
        var rect = element.getBoundingClientRect();
        return {
            width: rect.width,
            height: rect.height,
            top: rect.top,
            right: rect.right,
            bottom: rect.bottom,
            left: rect.left,
            x: rect.left,
            y: rect.top
        };
    }
    function getWindow(node) {
        if (node == null) return window;
        if (node.toString() !== "[object Window]") {
            var ownerDocument = node.ownerDocument;
            return ownerDocument ? ownerDocument.defaultView || window : window;
        }
        return node;
    }
    function getWindowScroll(node) {
        var win = getWindow(node);
        var scrollLeft = win.pageXOffset;
        var scrollTop = win.pageYOffset;
        return {
            scrollLeft: scrollLeft,
            scrollTop: scrollTop
        };
    }
    function isElement(node) {
        var OwnElement = getWindow(node).Element;
        return node instanceof OwnElement || node instanceof Element;
    }
    function isHTMLElement(node) {
        var OwnElement = getWindow(node).HTMLElement;
        return node instanceof OwnElement || node instanceof HTMLElement;
    }
    function isShadowRoot(node) {
        if (typeof ShadowRoot === "undefined") return false;
        var OwnElement = getWindow(node).ShadowRoot;
        return node instanceof OwnElement || node instanceof ShadowRoot;
    }
    function getHTMLElementScroll(element) {
        return {
            scrollLeft: element.scrollLeft,
            scrollTop: element.scrollTop
        };
    }
    function getNodeScroll(node) {
        if (node === getWindow(node) || !isHTMLElement(node)) return getWindowScroll(node);
        else return getHTMLElementScroll(node);
    }
    function getNodeName(element) {
        return element ? (element.nodeName || "").toLowerCase() : null;
    }
    function getDocumentElement(element) {
        return ((isElement(element) ? element.ownerDocument : element.document) || window.document).documentElement;
    }
    function getWindowScrollBarX(element) {
        return getBoundingClientRect(getDocumentElement(element)).left + getWindowScroll(element).scrollLeft;
    }
    function getComputedStyle(element) {
        return getWindow(element).getComputedStyle(element);
    }
    function isScrollParent(element) {
        var _getComputedStyle = getComputedStyle(element), overflow = _getComputedStyle.overflow, overflowX = _getComputedStyle.overflowX, overflowY = _getComputedStyle.overflowY;
        return /auto|scroll|overlay|hidden/.test(overflow + overflowY + overflowX);
    }
    function getCompositeRect(elementOrVirtualElement, offsetParent, isFixed) {
        if (isFixed === void 0) isFixed = false;
        var documentElement = getDocumentElement(offsetParent);
        var rect = getBoundingClientRect(elementOrVirtualElement);
        var isOffsetParentAnElement = isHTMLElement(offsetParent);
        var scroll = {
            scrollLeft: 0,
            scrollTop: 0
        };
        var offsets = {
            x: 0,
            y: 0
        };
        if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
            if (getNodeName(offsetParent) !== "body" || isScrollParent(documentElement)) scroll = getNodeScroll(offsetParent);
            if (isHTMLElement(offsetParent)) {
                offsets = getBoundingClientRect(offsetParent);
                offsets.x += offsetParent.clientLeft;
                offsets.y += offsetParent.clientTop;
            } else if (documentElement) offsets.x = getWindowScrollBarX(documentElement);
        }
        return {
            x: rect.left + scroll.scrollLeft - offsets.x,
            y: rect.top + scroll.scrollTop - offsets.y,
            width: rect.width,
            height: rect.height
        };
    }
    function getLayoutRect(element) {
        var clientRect = getBoundingClientRect(element);
        var width = element.offsetWidth;
        var height = element.offsetHeight;
        if (Math.abs(clientRect.width - width) <= 1) width = clientRect.width;
        if (Math.abs(clientRect.height - height) <= 1) height = clientRect.height;
        return {
            x: element.offsetLeft,
            y: element.offsetTop,
            width: width,
            height: height
        };
    }
    function getParentNode(element) {
        if (getNodeName(element) === "html") return element;
        return element.assignedSlot || element.parentNode || (isShadowRoot(element) ? element.host : null) || getDocumentElement(element);
    }
    function getScrollParent(node) {
        if ([
            "html",
            "body",
            "#document"
        ].indexOf(getNodeName(node)) >= 0) return node.ownerDocument.body;
        if (isHTMLElement(node) && isScrollParent(node)) return node;
        return getScrollParent(getParentNode(node));
    }
    function listScrollParents(element, list) {
        var _element$ownerDocumen;
        if (list === void 0) list = [];
        var scrollParent = getScrollParent(element);
        var isBody = scrollParent === ((_element$ownerDocumen = element.ownerDocument) == null ? void 0 : _element$ownerDocumen.body);
        var win = getWindow(scrollParent);
        var target = isBody ? [
            win
        ].concat(win.visualViewport || [], isScrollParent(scrollParent) ? scrollParent : []) : scrollParent;
        var updatedList = list.concat(target);
        return isBody ? updatedList : updatedList.concat(listScrollParents(getParentNode(target)));
    }
    function isTableElement(element) {
        return [
            "table",
            "td",
            "th"
        ].indexOf(getNodeName(element)) >= 0;
    }
    function getTrueOffsetParent(element) {
        if (!isHTMLElement(element) || getComputedStyle(element).position === "fixed") return null;
        return element.offsetParent;
    }
    function getContainingBlock(element) {
        var isFirefox = navigator.userAgent.toLowerCase().indexOf("firefox") !== -1;
        var isIE = navigator.userAgent.indexOf("Trident") !== -1;
        if (isIE && isHTMLElement(element)) {
            var elementCss = getComputedStyle(element);
            if (elementCss.position === "fixed") return null;
        }
        var currentNode = getParentNode(element);
        while(isHTMLElement(currentNode) && [
            "html",
            "body"
        ].indexOf(getNodeName(currentNode)) < 0){
            var css = getComputedStyle(currentNode);
            if (css.transform !== "none" || css.perspective !== "none" || css.contain === "paint" || [
                "transform",
                "perspective"
            ].indexOf(css.willChange) !== -1 || isFirefox && css.willChange === "filter" || isFirefox && css.filter && css.filter !== "none") return currentNode;
            else currentNode = currentNode.parentNode;
        }
        return null;
    }
    function getOffsetParent(element) {
        var window2 = getWindow(element);
        var offsetParent = getTrueOffsetParent(element);
        while(offsetParent && isTableElement(offsetParent) && getComputedStyle(offsetParent).position === "static")offsetParent = getTrueOffsetParent(offsetParent);
        if (offsetParent && (getNodeName(offsetParent) === "html" || getNodeName(offsetParent) === "body" && getComputedStyle(offsetParent).position === "static")) return window2;
        return offsetParent || getContainingBlock(element) || window2;
    }
    var top = "top";
    var bottom = "bottom";
    var right = "right";
    var left = "left";
    var auto = "auto";
    var basePlacements = [
        top,
        bottom,
        right,
        left
    ];
    var start = "start";
    var end = "end";
    var clippingParents = "clippingParents";
    var viewport = "viewport";
    var popper = "popper";
    var reference = "reference";
    var variationPlacements = /* @__PURE__ */ basePlacements.reduce(function(acc, placement) {
        return acc.concat([
            placement + "-" + start,
            placement + "-" + end
        ]);
    }, []);
    var placements = /* @__PURE__ */ [].concat(basePlacements, [
        auto
    ]).reduce(function(acc, placement) {
        return acc.concat([
            placement,
            placement + "-" + start,
            placement + "-" + end
        ]);
    }, []);
    var beforeRead = "beforeRead";
    var read = "read";
    var afterRead = "afterRead";
    var beforeMain = "beforeMain";
    var main = "main";
    var afterMain = "afterMain";
    var beforeWrite = "beforeWrite";
    var write = "write";
    var afterWrite = "afterWrite";
    var modifierPhases = [
        beforeRead,
        read,
        afterRead,
        beforeMain,
        main,
        afterMain,
        beforeWrite,
        write,
        afterWrite
    ];
    function order(modifiers) {
        var map = new Map();
        var visited = new Set();
        var result = [];
        modifiers.forEach(function(modifier) {
            map.set(modifier.name, modifier);
        });
        function sort(modifier) {
            visited.add(modifier.name);
            var requires = [].concat(modifier.requires || [], modifier.requiresIfExists || []);
            requires.forEach(function(dep) {
                if (!visited.has(dep)) {
                    var depModifier = map.get(dep);
                    if (depModifier) sort(depModifier);
                }
            });
            result.push(modifier);
        }
        modifiers.forEach(function(modifier) {
            if (!visited.has(modifier.name)) sort(modifier);
        });
        return result;
    }
    function orderModifiers(modifiers) {
        var orderedModifiers = order(modifiers);
        return modifierPhases.reduce(function(acc, phase) {
            return acc.concat(orderedModifiers.filter(function(modifier) {
                return modifier.phase === phase;
            }));
        }, []);
    }
    function debounce(fn) {
        var pending;
        return function() {
            if (!pending) pending = new Promise(function(resolve) {
                Promise.resolve().then(function() {
                    pending = void 0;
                    resolve(fn());
                });
            });
            return pending;
        };
    }
    function format(str) {
        for(var _len = arguments.length, args = new Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++)args[_key - 1] = arguments[_key];
        return [].concat(args).reduce(function(p, c) {
            return p.replace(/%s/, c);
        }, str);
    }
    var INVALID_MODIFIER_ERROR = 'Popper: modifier "%s" provided an invalid %s property, expected %s but got %s';
    var MISSING_DEPENDENCY_ERROR = 'Popper: modifier "%s" requires "%s", but "%s" modifier is not available';
    var VALID_PROPERTIES = [
        "name",
        "enabled",
        "phase",
        "fn",
        "effect",
        "requires",
        "options"
    ];
    function validateModifiers(modifiers) {
        modifiers.forEach(function(modifier) {
            Object.keys(modifier).forEach(function(key) {
                switch(key){
                    case "name":
                        if (typeof modifier.name !== "string") console.error(format(INVALID_MODIFIER_ERROR, String(modifier.name), '"name"', '"string"', '"' + String(modifier.name) + '"'));
                        break;
                    case "enabled":
                        if (typeof modifier.enabled !== "boolean") console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"enabled"', '"boolean"', '"' + String(modifier.enabled) + '"'));
                    case "phase":
                        if (modifierPhases.indexOf(modifier.phase) < 0) console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"phase"', "either " + modifierPhases.join(", "), '"' + String(modifier.phase) + '"'));
                        break;
                    case "fn":
                        if (typeof modifier.fn !== "function") console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"fn"', '"function"', '"' + String(modifier.fn) + '"'));
                        break;
                    case "effect":
                        if (typeof modifier.effect !== "function") console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"effect"', '"function"', '"' + String(modifier.fn) + '"'));
                        break;
                    case "requires":
                        if (!Array.isArray(modifier.requires)) console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"requires"', '"array"', '"' + String(modifier.requires) + '"'));
                        break;
                    case "requiresIfExists":
                        if (!Array.isArray(modifier.requiresIfExists)) console.error(format(INVALID_MODIFIER_ERROR, modifier.name, '"requiresIfExists"', '"array"', '"' + String(modifier.requiresIfExists) + '"'));
                        break;
                    case "options":
                    case "data":
                        break;
                    default:
                        console.error('PopperJS: an invalid property has been provided to the "' + modifier.name + '" modifier, valid properties are ' + VALID_PROPERTIES.map(function(s) {
                            return '"' + s + '"';
                        }).join(", ") + '; but "' + key + '" was provided.');
                }
                modifier.requires && modifier.requires.forEach(function(requirement) {
                    if (modifiers.find(function(mod) {
                        return mod.name === requirement;
                    }) == null) console.error(format(MISSING_DEPENDENCY_ERROR, String(modifier.name), requirement, requirement));
                });
            });
        });
    }
    function uniqueBy(arr, fn) {
        var identifiers = new Set();
        return arr.filter(function(item) {
            var identifier = fn(item);
            if (!identifiers.has(identifier)) {
                identifiers.add(identifier);
                return true;
            }
        });
    }
    function getBasePlacement(placement) {
        return placement.split("-")[0];
    }
    function mergeByName(modifiers) {
        var merged = modifiers.reduce(function(merged2, current) {
            var existing = merged2[current.name];
            merged2[current.name] = existing ? Object.assign({}, existing, current, {
                options: Object.assign({}, existing.options, current.options),
                data: Object.assign({}, existing.data, current.data)
            }) : current;
            return merged2;
        }, {});
        return Object.keys(merged).map(function(key) {
            return merged[key];
        });
    }
    function getViewportRect(element) {
        var win = getWindow(element);
        var html = getDocumentElement(element);
        var visualViewport = win.visualViewport;
        var width = html.clientWidth;
        var height = html.clientHeight;
        var x = 0;
        var y = 0;
        if (visualViewport) {
            width = visualViewport.width;
            height = visualViewport.height;
            if (!/^((?!chrome|android).)*safari/i.test(navigator.userAgent)) {
                x = visualViewport.offsetLeft;
                y = visualViewport.offsetTop;
            }
        }
        return {
            width: width,
            height: height,
            x: x + getWindowScrollBarX(element),
            y: y
        };
    }
    var max = Math.max;
    var min = Math.min;
    var round = Math.round;
    function getDocumentRect(element) {
        var _element$ownerDocumen;
        var html = getDocumentElement(element);
        var winScroll = getWindowScroll(element);
        var body = (_element$ownerDocumen = element.ownerDocument) == null ? void 0 : _element$ownerDocumen.body;
        var width = max(html.scrollWidth, html.clientWidth, body ? body.scrollWidth : 0, body ? body.clientWidth : 0);
        var height = max(html.scrollHeight, html.clientHeight, body ? body.scrollHeight : 0, body ? body.clientHeight : 0);
        var x = -winScroll.scrollLeft + getWindowScrollBarX(element);
        var y = -winScroll.scrollTop;
        if (getComputedStyle(body || html).direction === "rtl") x += max(html.clientWidth, body ? body.clientWidth : 0) - width;
        return {
            width: width,
            height: height,
            x: x,
            y: y
        };
    }
    function contains(parent, child) {
        var rootNode = child.getRootNode && child.getRootNode();
        if (parent.contains(child)) return true;
        else if (rootNode && isShadowRoot(rootNode)) {
            var next = child;
            do {
                if (next && parent.isSameNode(next)) return true;
                next = next.parentNode || next.host;
            }while (next);
        }
        return false;
    }
    function rectToClientRect(rect) {
        return Object.assign({}, rect, {
            left: rect.x,
            top: rect.y,
            right: rect.x + rect.width,
            bottom: rect.y + rect.height
        });
    }
    function getInnerBoundingClientRect(element) {
        var rect = getBoundingClientRect(element);
        rect.top = rect.top + element.clientTop;
        rect.left = rect.left + element.clientLeft;
        rect.bottom = rect.top + element.clientHeight;
        rect.right = rect.left + element.clientWidth;
        rect.width = element.clientWidth;
        rect.height = element.clientHeight;
        rect.x = rect.left;
        rect.y = rect.top;
        return rect;
    }
    function getClientRectFromMixedType(element, clippingParent) {
        return clippingParent === viewport ? rectToClientRect(getViewportRect(element)) : isHTMLElement(clippingParent) ? getInnerBoundingClientRect(clippingParent) : rectToClientRect(getDocumentRect(getDocumentElement(element)));
    }
    function getClippingParents(element) {
        var clippingParents2 = listScrollParents(getParentNode(element));
        var canEscapeClipping = [
            "absolute",
            "fixed"
        ].indexOf(getComputedStyle(element).position) >= 0;
        var clipperElement = canEscapeClipping && isHTMLElement(element) ? getOffsetParent(element) : element;
        if (!isElement(clipperElement)) return [];
        return clippingParents2.filter(function(clippingParent) {
            return isElement(clippingParent) && contains(clippingParent, clipperElement) && getNodeName(clippingParent) !== "body";
        });
    }
    function getClippingRect(element, boundary, rootBoundary) {
        var mainClippingParents = boundary === "clippingParents" ? getClippingParents(element) : [].concat(boundary);
        var clippingParents2 = [].concat(mainClippingParents, [
            rootBoundary
        ]);
        var firstClippingParent = clippingParents2[0];
        var clippingRect = clippingParents2.reduce(function(accRect, clippingParent) {
            var rect = getClientRectFromMixedType(element, clippingParent);
            accRect.top = max(rect.top, accRect.top);
            accRect.right = min(rect.right, accRect.right);
            accRect.bottom = min(rect.bottom, accRect.bottom);
            accRect.left = max(rect.left, accRect.left);
            return accRect;
        }, getClientRectFromMixedType(element, firstClippingParent));
        clippingRect.width = clippingRect.right - clippingRect.left;
        clippingRect.height = clippingRect.bottom - clippingRect.top;
        clippingRect.x = clippingRect.left;
        clippingRect.y = clippingRect.top;
        return clippingRect;
    }
    function getVariation(placement) {
        return placement.split("-")[1];
    }
    function getMainAxisFromPlacement(placement) {
        return [
            "top",
            "bottom"
        ].indexOf(placement) >= 0 ? "x" : "y";
    }
    function computeOffsets(_ref) {
        var reference2 = _ref.reference, element = _ref.element, placement = _ref.placement;
        var basePlacement = placement ? getBasePlacement(placement) : null;
        var variation = placement ? getVariation(placement) : null;
        var commonX = reference2.x + reference2.width / 2 - element.width / 2;
        var commonY = reference2.y + reference2.height / 2 - element.height / 2;
        var offsets;
        switch(basePlacement){
            case top:
                offsets = {
                    x: commonX,
                    y: reference2.y - element.height
                };
                break;
            case bottom:
                offsets = {
                    x: commonX,
                    y: reference2.y + reference2.height
                };
                break;
            case right:
                offsets = {
                    x: reference2.x + reference2.width,
                    y: commonY
                };
                break;
            case left:
                offsets = {
                    x: reference2.x - element.width,
                    y: commonY
                };
                break;
            default:
                offsets = {
                    x: reference2.x,
                    y: reference2.y
                };
        }
        var mainAxis = basePlacement ? getMainAxisFromPlacement(basePlacement) : null;
        if (mainAxis != null) {
            var len = mainAxis === "y" ? "height" : "width";
            switch(variation){
                case start:
                    offsets[mainAxis] = offsets[mainAxis] - (reference2[len] / 2 - element[len] / 2);
                    break;
                case end:
                    offsets[mainAxis] = offsets[mainAxis] + (reference2[len] / 2 - element[len] / 2);
                    break;
            }
        }
        return offsets;
    }
    function getFreshSideObject() {
        return {
            top: 0,
            right: 0,
            bottom: 0,
            left: 0
        };
    }
    function mergePaddingObject(paddingObject) {
        return Object.assign({}, getFreshSideObject(), paddingObject);
    }
    function expandToHashMap(value, keys) {
        return keys.reduce(function(hashMap, key) {
            hashMap[key] = value;
            return hashMap;
        }, {});
    }
    function detectOverflow(state, options) {
        if (options === void 0) options = {};
        var _options = options, _options$placement = _options.placement, placement = _options$placement === void 0 ? state.placement : _options$placement, _options$boundary = _options.boundary, boundary = _options$boundary === void 0 ? clippingParents : _options$boundary, _options$rootBoundary = _options.rootBoundary, rootBoundary = _options$rootBoundary === void 0 ? viewport : _options$rootBoundary, _options$elementConte = _options.elementContext, elementContext = _options$elementConte === void 0 ? popper : _options$elementConte, _options$altBoundary = _options.altBoundary, altBoundary = _options$altBoundary === void 0 ? false : _options$altBoundary, _options$padding = _options.padding, padding = _options$padding === void 0 ? 0 : _options$padding;
        var paddingObject = mergePaddingObject(typeof padding !== "number" ? padding : expandToHashMap(padding, basePlacements));
        var altContext = elementContext === popper ? reference : popper;
        var referenceElement = state.elements.reference;
        var popperRect = state.rects.popper;
        var element = state.elements[altBoundary ? altContext : elementContext];
        var clippingClientRect = getClippingRect(isElement(element) ? element : element.contextElement || getDocumentElement(state.elements.popper), boundary, rootBoundary);
        var referenceClientRect = getBoundingClientRect(referenceElement);
        var popperOffsets2 = computeOffsets({
            reference: referenceClientRect,
            element: popperRect,
            strategy: "absolute",
            placement: placement
        });
        var popperClientRect = rectToClientRect(Object.assign({}, popperRect, popperOffsets2));
        var elementClientRect = elementContext === popper ? popperClientRect : referenceClientRect;
        var overflowOffsets = {
            top: clippingClientRect.top - elementClientRect.top + paddingObject.top,
            bottom: elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom,
            left: clippingClientRect.left - elementClientRect.left + paddingObject.left,
            right: elementClientRect.right - clippingClientRect.right + paddingObject.right
        };
        var offsetData = state.modifiersData.offset;
        if (elementContext === popper && offsetData) {
            var offset2 = offsetData[placement];
            Object.keys(overflowOffsets).forEach(function(key) {
                var multiply = [
                    right,
                    bottom
                ].indexOf(key) >= 0 ? 1 : -1;
                var axis = [
                    top,
                    bottom
                ].indexOf(key) >= 0 ? "y" : "x";
                overflowOffsets[key] += offset2[axis] * multiply;
            });
        }
        return overflowOffsets;
    }
    var INVALID_ELEMENT_ERROR = "Popper: Invalid reference or popper argument provided. They must be either a DOM element or virtual element.";
    var INFINITE_LOOP_ERROR = "Popper: An infinite loop in the modifiers cycle has been detected! The cycle has been interrupted to prevent a browser crash.";
    var DEFAULT_OPTIONS = {
        placement: "bottom",
        modifiers: [],
        strategy: "absolute"
    };
    function areValidElements() {
        for(var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++)args[_key] = arguments[_key];
        return !args.some(function(element) {
            return !(element && typeof element.getBoundingClientRect === "function");
        });
    }
    function popperGenerator(generatorOptions) {
        if (generatorOptions === void 0) generatorOptions = {};
        var _generatorOptions = generatorOptions, _generatorOptions$def = _generatorOptions.defaultModifiers, defaultModifiers2 = _generatorOptions$def === void 0 ? [] : _generatorOptions$def, _generatorOptions$def2 = _generatorOptions.defaultOptions, defaultOptions = _generatorOptions$def2 === void 0 ? DEFAULT_OPTIONS : _generatorOptions$def2;
        return function createPopper2(reference2, popper2, options) {
            if (options === void 0) options = defaultOptions;
            var state = {
                placement: "bottom",
                orderedModifiers: [],
                options: Object.assign({}, DEFAULT_OPTIONS, defaultOptions),
                modifiersData: {},
                elements: {
                    reference: reference2,
                    popper: popper2
                },
                attributes: {},
                styles: {}
            };
            var effectCleanupFns = [];
            var isDestroyed = false;
            var instance = {
                state: state,
                setOptions: function setOptions(options2) {
                    cleanupModifierEffects();
                    state.options = Object.assign({}, defaultOptions, state.options, options2);
                    state.scrollParents = {
                        reference: isElement(reference2) ? listScrollParents(reference2) : reference2.contextElement ? listScrollParents(reference2.contextElement) : [],
                        popper: listScrollParents(popper2)
                    };
                    var orderedModifiers = orderModifiers(mergeByName([].concat(defaultModifiers2, state.options.modifiers)));
                    state.orderedModifiers = orderedModifiers.filter(function(m) {
                        return m.enabled;
                    });
                    var modifiers = uniqueBy([].concat(orderedModifiers, state.options.modifiers), function(_ref) {
                        var name = _ref.name;
                        return name;
                    });
                    validateModifiers(modifiers);
                    if (getBasePlacement(state.options.placement) === auto) {
                        var flipModifier = state.orderedModifiers.find(function(_ref2) {
                            var name = _ref2.name;
                            return name === "flip";
                        });
                        if (!flipModifier) console.error([
                            'Popper: "auto" placements require the "flip" modifier be',
                            "present and enabled to work."
                        ].join(" "));
                    }
                    var _getComputedStyle = getComputedStyle(popper2), marginTop = _getComputedStyle.marginTop, marginRight = _getComputedStyle.marginRight, marginBottom = _getComputedStyle.marginBottom, marginLeft = _getComputedStyle.marginLeft;
                    if ([
                        marginTop,
                        marginRight,
                        marginBottom,
                        marginLeft
                    ].some(function(margin) {
                        return parseFloat(margin);
                    })) console.warn([
                        'Popper: CSS "margin" styles cannot be used to apply padding',
                        "between the popper and its reference element or boundary.",
                        "To replicate margin, use the `offset` modifier, as well as",
                        "the `padding` option in the `preventOverflow` and `flip`",
                        "modifiers."
                    ].join(" "));
                    runModifierEffects();
                    return instance.update();
                },
                forceUpdate: function forceUpdate() {
                    if (isDestroyed) return;
                    var _state$elements = state.elements, reference3 = _state$elements.reference, popper3 = _state$elements.popper;
                    if (!areValidElements(reference3, popper3)) {
                        console.error(INVALID_ELEMENT_ERROR);
                        return;
                    }
                    state.rects = {
                        reference: getCompositeRect(reference3, getOffsetParent(popper3), state.options.strategy === "fixed"),
                        popper: getLayoutRect(popper3)
                    };
                    state.reset = false;
                    state.placement = state.options.placement;
                    state.orderedModifiers.forEach(function(modifier) {
                        return state.modifiersData[modifier.name] = Object.assign({}, modifier.data);
                    });
                    var __debug_loops__ = 0;
                    for(var index = 0; index < state.orderedModifiers.length; index++){
                        __debug_loops__ += 1;
                        if (__debug_loops__ > 100) {
                            console.error(INFINITE_LOOP_ERROR);
                            break;
                        }
                        if (state.reset === true) {
                            state.reset = false;
                            index = -1;
                            continue;
                        }
                        var _state$orderedModifie = state.orderedModifiers[index], fn = _state$orderedModifie.fn, _state$orderedModifie2 = _state$orderedModifie.options, _options = _state$orderedModifie2 === void 0 ? {} : _state$orderedModifie2, name = _state$orderedModifie.name;
                        if (typeof fn === "function") state = fn({
                            state: state,
                            options: _options,
                            name: name,
                            instance: instance
                        }) || state;
                    }
                },
                update: debounce(function() {
                    return new Promise(function(resolve) {
                        instance.forceUpdate();
                        resolve(state);
                    });
                }),
                destroy: function destroy() {
                    cleanupModifierEffects();
                    isDestroyed = true;
                }
            };
            if (!areValidElements(reference2, popper2)) {
                console.error(INVALID_ELEMENT_ERROR);
                return instance;
            }
            instance.setOptions(options).then(function(state2) {
                if (!isDestroyed && options.onFirstUpdate) options.onFirstUpdate(state2);
            });
            function runModifierEffects() {
                state.orderedModifiers.forEach(function(_ref3) {
                    var name = _ref3.name, _ref3$options = _ref3.options, options2 = _ref3$options === void 0 ? {} : _ref3$options, effect2 = _ref3.effect;
                    if (typeof effect2 === "function") {
                        var cleanupFn = effect2({
                            state: state,
                            name: name,
                            instance: instance,
                            options: options2
                        });
                        var noopFn = function noopFn2() {};
                        effectCleanupFns.push(cleanupFn || noopFn);
                    }
                });
            }
            function cleanupModifierEffects() {
                effectCleanupFns.forEach(function(fn) {
                    return fn();
                });
                effectCleanupFns = [];
            }
            return instance;
        };
    }
    var passive = {
        passive: true
    };
    function effect$2(_ref) {
        var state = _ref.state, instance = _ref.instance, options = _ref.options;
        var _options$scroll = options.scroll, scroll = _options$scroll === void 0 ? true : _options$scroll, _options$resize = options.resize, resize = _options$resize === void 0 ? true : _options$resize;
        var window2 = getWindow(state.elements.popper);
        var scrollParents = [].concat(state.scrollParents.reference, state.scrollParents.popper);
        if (scroll) scrollParents.forEach(function(scrollParent) {
            scrollParent.addEventListener("scroll", instance.update, passive);
        });
        if (resize) window2.addEventListener("resize", instance.update, passive);
        return function() {
            if (scroll) scrollParents.forEach(function(scrollParent) {
                scrollParent.removeEventListener("scroll", instance.update, passive);
            });
            if (resize) window2.removeEventListener("resize", instance.update, passive);
        };
    }
    var eventListeners = {
        name: "eventListeners",
        enabled: true,
        phase: "write",
        fn: function fn() {},
        effect: effect$2,
        data: {}
    };
    function popperOffsets(_ref) {
        var state = _ref.state, name = _ref.name;
        state.modifiersData[name] = computeOffsets({
            reference: state.rects.reference,
            element: state.rects.popper,
            strategy: "absolute",
            placement: state.placement
        });
    }
    var popperOffsets$1 = {
        name: "popperOffsets",
        enabled: true,
        phase: "read",
        fn: popperOffsets,
        data: {}
    };
    var unsetSides = {
        top: "auto",
        right: "auto",
        bottom: "auto",
        left: "auto"
    };
    function roundOffsetsByDPR(_ref) {
        var x = _ref.x, y = _ref.y;
        var win = window;
        var dpr = win.devicePixelRatio || 1;
        return {
            x: round(round(x * dpr) / dpr) || 0,
            y: round(round(y * dpr) / dpr) || 0
        };
    }
    function mapToStyles(_ref2) {
        var _Object$assign2;
        var popper2 = _ref2.popper, popperRect = _ref2.popperRect, placement = _ref2.placement, offsets = _ref2.offsets, position = _ref2.position, gpuAcceleration = _ref2.gpuAcceleration, adaptive = _ref2.adaptive, roundOffsets = _ref2.roundOffsets;
        var _ref3 = roundOffsets === true ? roundOffsetsByDPR(offsets) : typeof roundOffsets === "function" ? roundOffsets(offsets) : offsets, _ref3$x = _ref3.x, x = _ref3$x === void 0 ? 0 : _ref3$x, _ref3$y = _ref3.y, y = _ref3$y === void 0 ? 0 : _ref3$y;
        var hasX = offsets.hasOwnProperty("x");
        var hasY = offsets.hasOwnProperty("y");
        var sideX = left;
        var sideY = top;
        var win = window;
        if (adaptive) {
            var offsetParent = getOffsetParent(popper2);
            var heightProp = "clientHeight";
            var widthProp = "clientWidth";
            if (offsetParent === getWindow(popper2)) {
                offsetParent = getDocumentElement(popper2);
                if (getComputedStyle(offsetParent).position !== "static") {
                    heightProp = "scrollHeight";
                    widthProp = "scrollWidth";
                }
            }
            offsetParent;
            if (placement === top) {
                sideY = bottom;
                y -= offsetParent[heightProp] - popperRect.height;
                y *= gpuAcceleration ? 1 : -1;
            }
            if (placement === left) {
                sideX = right;
                x -= offsetParent[widthProp] - popperRect.width;
                x *= gpuAcceleration ? 1 : -1;
            }
        }
        var commonStyles = Object.assign({
            position: position
        }, adaptive && unsetSides);
        if (gpuAcceleration) {
            var _Object$assign;
            return Object.assign({}, commonStyles, (_Object$assign = {}, _Object$assign[sideY] = hasY ? "0" : "", _Object$assign[sideX] = hasX ? "0" : "", _Object$assign.transform = (win.devicePixelRatio || 1) < 2 ? "translate(" + x + "px, " + y + "px)" : "translate3d(" + x + "px, " + y + "px, 0)", _Object$assign));
        }
        return Object.assign({}, commonStyles, (_Object$assign2 = {}, _Object$assign2[sideY] = hasY ? y + "px" : "", _Object$assign2[sideX] = hasX ? x + "px" : "", _Object$assign2.transform = "", _Object$assign2));
    }
    function computeStyles(_ref4) {
        var state = _ref4.state, options = _ref4.options;
        var _options$gpuAccelerat = options.gpuAcceleration, gpuAcceleration = _options$gpuAccelerat === void 0 ? true : _options$gpuAccelerat, _options$adaptive = options.adaptive, adaptive = _options$adaptive === void 0 ? true : _options$adaptive, _options$roundOffsets = options.roundOffsets, roundOffsets = _options$roundOffsets === void 0 ? true : _options$roundOffsets;
        var transitionProperty = getComputedStyle(state.elements.popper).transitionProperty || "";
        if (adaptive && [
            "transform",
            "top",
            "right",
            "bottom",
            "left"
        ].some(function(property) {
            return transitionProperty.indexOf(property) >= 0;
        })) console.warn([
            "Popper: Detected CSS transitions on at least one of the following",
            'CSS properties: "transform", "top", "right", "bottom", "left".',
            "\n\n",
            'Disable the "computeStyles" modifier\'s `adaptive` option to allow',
            "for smooth transitions, or remove these properties from the CSS",
            "transition declaration on the popper element if only transitioning",
            "opacity or background-color for example.",
            "\n\n",
            "We recommend using the popper element as a wrapper around an inner",
            "element that can have any CSS property transitioned for animations."
        ].join(" "));
        var commonStyles = {
            placement: getBasePlacement(state.placement),
            popper: state.elements.popper,
            popperRect: state.rects.popper,
            gpuAcceleration: gpuAcceleration
        };
        if (state.modifiersData.popperOffsets != null) state.styles.popper = Object.assign({}, state.styles.popper, mapToStyles(Object.assign({}, commonStyles, {
            offsets: state.modifiersData.popperOffsets,
            position: state.options.strategy,
            adaptive: adaptive,
            roundOffsets: roundOffsets
        })));
        if (state.modifiersData.arrow != null) state.styles.arrow = Object.assign({}, state.styles.arrow, mapToStyles(Object.assign({}, commonStyles, {
            offsets: state.modifiersData.arrow,
            position: "absolute",
            adaptive: false,
            roundOffsets: roundOffsets
        })));
        state.attributes.popper = Object.assign({}, state.attributes.popper, {
            "data-popper-placement": state.placement
        });
    }
    var computeStyles$1 = {
        name: "computeStyles",
        enabled: true,
        phase: "beforeWrite",
        fn: computeStyles,
        data: {}
    };
    function applyStyles(_ref) {
        var state = _ref.state;
        Object.keys(state.elements).forEach(function(name) {
            var style = state.styles[name] || {};
            var attributes = state.attributes[name] || {};
            var element = state.elements[name];
            if (!isHTMLElement(element) || !getNodeName(element)) return;
            Object.assign(element.style, style);
            Object.keys(attributes).forEach(function(name2) {
                var value = attributes[name2];
                if (value === false) element.removeAttribute(name2);
                else element.setAttribute(name2, value === true ? "" : value);
            });
        });
    }
    function effect$1(_ref2) {
        var state = _ref2.state;
        var initialStyles = {
            popper: {
                position: state.options.strategy,
                left: "0",
                top: "0",
                margin: "0"
            },
            arrow: {
                position: "absolute"
            },
            reference: {}
        };
        Object.assign(state.elements.popper.style, initialStyles.popper);
        state.styles = initialStyles;
        if (state.elements.arrow) Object.assign(state.elements.arrow.style, initialStyles.arrow);
        return function() {
            Object.keys(state.elements).forEach(function(name) {
                var element = state.elements[name];
                var attributes = state.attributes[name] || {};
                var styleProperties = Object.keys(state.styles.hasOwnProperty(name) ? state.styles[name] : initialStyles[name]);
                var style = styleProperties.reduce(function(style2, property) {
                    style2[property] = "";
                    return style2;
                }, {});
                if (!isHTMLElement(element) || !getNodeName(element)) return;
                Object.assign(element.style, style);
                Object.keys(attributes).forEach(function(attribute) {
                    element.removeAttribute(attribute);
                });
            });
        };
    }
    var applyStyles$1 = {
        name: "applyStyles",
        enabled: true,
        phase: "write",
        fn: applyStyles,
        effect: effect$1,
        requires: [
            "computeStyles"
        ]
    };
    function distanceAndSkiddingToXY(placement, rects, offset2) {
        var basePlacement = getBasePlacement(placement);
        var invertDistance = [
            left,
            top
        ].indexOf(basePlacement) >= 0 ? -1 : 1;
        var _ref = typeof offset2 === "function" ? offset2(Object.assign({}, rects, {
            placement: placement
        })) : offset2, skidding = _ref[0], distance = _ref[1];
        skidding = skidding || 0;
        distance = (distance || 0) * invertDistance;
        return [
            left,
            right
        ].indexOf(basePlacement) >= 0 ? {
            x: distance,
            y: skidding
        } : {
            x: skidding,
            y: distance
        };
    }
    function offset(_ref2) {
        var state = _ref2.state, options = _ref2.options, name = _ref2.name;
        var _options$offset = options.offset, offset2 = _options$offset === void 0 ? [
            0,
            0
        ] : _options$offset;
        var data = placements.reduce(function(acc, placement) {
            acc[placement] = distanceAndSkiddingToXY(placement, state.rects, offset2);
            return acc;
        }, {});
        var _data$state$placement = data[state.placement], x = _data$state$placement.x, y = _data$state$placement.y;
        if (state.modifiersData.popperOffsets != null) {
            state.modifiersData.popperOffsets.x += x;
            state.modifiersData.popperOffsets.y += y;
        }
        state.modifiersData[name] = data;
    }
    var offset$1 = {
        name: "offset",
        enabled: true,
        phase: "main",
        requires: [
            "popperOffsets"
        ],
        fn: offset
    };
    var hash$1 = {
        left: "right",
        right: "left",
        bottom: "top",
        top: "bottom"
    };
    function getOppositePlacement(placement) {
        return placement.replace(/left|right|bottom|top/g, function(matched) {
            return hash$1[matched];
        });
    }
    var hash = {
        start: "end",
        end: "start"
    };
    function getOppositeVariationPlacement(placement) {
        return placement.replace(/start|end/g, function(matched) {
            return hash[matched];
        });
    }
    function computeAutoPlacement(state, options) {
        if (options === void 0) options = {};
        var _options = options, placement = _options.placement, boundary = _options.boundary, rootBoundary = _options.rootBoundary, padding = _options.padding, flipVariations = _options.flipVariations, _options$allowedAutoP = _options.allowedAutoPlacements, allowedAutoPlacements = _options$allowedAutoP === void 0 ? placements : _options$allowedAutoP;
        var variation = getVariation(placement);
        var placements$1 = variation ? flipVariations ? variationPlacements : variationPlacements.filter(function(placement2) {
            return getVariation(placement2) === variation;
        }) : basePlacements;
        var allowedPlacements = placements$1.filter(function(placement2) {
            return allowedAutoPlacements.indexOf(placement2) >= 0;
        });
        if (allowedPlacements.length === 0) {
            allowedPlacements = placements$1;
            console.error([
                "Popper: The `allowedAutoPlacements` option did not allow any",
                "placements. Ensure the `placement` option matches the variation",
                "of the allowed placements.",
                'For example, "auto" cannot be used to allow "bottom-start".',
                'Use "auto-start" instead.'
            ].join(" "));
        }
        var overflows = allowedPlacements.reduce(function(acc, placement2) {
            acc[placement2] = detectOverflow(state, {
                placement: placement2,
                boundary: boundary,
                rootBoundary: rootBoundary,
                padding: padding
            })[getBasePlacement(placement2)];
            return acc;
        }, {});
        return Object.keys(overflows).sort(function(a, b) {
            return overflows[a] - overflows[b];
        });
    }
    function getExpandedFallbackPlacements(placement) {
        if (getBasePlacement(placement) === auto) return [];
        var oppositePlacement = getOppositePlacement(placement);
        return [
            getOppositeVariationPlacement(placement),
            oppositePlacement,
            getOppositeVariationPlacement(oppositePlacement)
        ];
    }
    function flip(_ref) {
        var state = _ref.state, options = _ref.options, name = _ref.name;
        if (state.modifiersData[name]._skip) return;
        var _options$mainAxis = options.mainAxis, checkMainAxis = _options$mainAxis === void 0 ? true : _options$mainAxis, _options$altAxis = options.altAxis, checkAltAxis = _options$altAxis === void 0 ? true : _options$altAxis, specifiedFallbackPlacements = options.fallbackPlacements, padding = options.padding, boundary = options.boundary, rootBoundary = options.rootBoundary, altBoundary = options.altBoundary, _options$flipVariatio = options.flipVariations, flipVariations = _options$flipVariatio === void 0 ? true : _options$flipVariatio, allowedAutoPlacements = options.allowedAutoPlacements;
        var preferredPlacement = state.options.placement;
        var basePlacement = getBasePlacement(preferredPlacement);
        var isBasePlacement = basePlacement === preferredPlacement;
        var fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipVariations ? [
            getOppositePlacement(preferredPlacement)
        ] : getExpandedFallbackPlacements(preferredPlacement));
        var placements2 = [
            preferredPlacement
        ].concat(fallbackPlacements).reduce(function(acc, placement2) {
            return acc.concat(getBasePlacement(placement2) === auto ? computeAutoPlacement(state, {
                placement: placement2,
                boundary: boundary,
                rootBoundary: rootBoundary,
                padding: padding,
                flipVariations: flipVariations,
                allowedAutoPlacements: allowedAutoPlacements
            }) : placement2);
        }, []);
        var referenceRect = state.rects.reference;
        var popperRect = state.rects.popper;
        var checksMap = new Map();
        var makeFallbackChecks = true;
        var firstFittingPlacement = placements2[0];
        for(var i = 0; i < placements2.length; i++){
            var placement = placements2[i];
            var _basePlacement = getBasePlacement(placement);
            var isStartVariation = getVariation(placement) === start;
            var isVertical = [
                top,
                bottom
            ].indexOf(_basePlacement) >= 0;
            var len = isVertical ? "width" : "height";
            var overflow = detectOverflow(state, {
                placement: placement,
                boundary: boundary,
                rootBoundary: rootBoundary,
                altBoundary: altBoundary,
                padding: padding
            });
            var mainVariationSide = isVertical ? isStartVariation ? right : left : isStartVariation ? bottom : top;
            if (referenceRect[len] > popperRect[len]) mainVariationSide = getOppositePlacement(mainVariationSide);
            var altVariationSide = getOppositePlacement(mainVariationSide);
            var checks = [];
            if (checkMainAxis) checks.push(overflow[_basePlacement] <= 0);
            if (checkAltAxis) checks.push(overflow[mainVariationSide] <= 0, overflow[altVariationSide] <= 0);
            if (checks.every(function(check) {
                return check;
            })) {
                firstFittingPlacement = placement;
                makeFallbackChecks = false;
                break;
            }
            checksMap.set(placement, checks);
        }
        if (makeFallbackChecks) {
            var numberOfChecks = flipVariations ? 3 : 1;
            var _loop = function _loop2(_i2) {
                var fittingPlacement = placements2.find(function(placement2) {
                    var checks2 = checksMap.get(placement2);
                    if (checks2) return checks2.slice(0, _i2).every(function(check) {
                        return check;
                    });
                });
                if (fittingPlacement) {
                    firstFittingPlacement = fittingPlacement;
                    return "break";
                }
            };
            for(var _i = numberOfChecks; _i > 0; _i--){
                var _ret = _loop(_i);
                if (_ret === "break") break;
            }
        }
        if (state.placement !== firstFittingPlacement) {
            state.modifiersData[name]._skip = true;
            state.placement = firstFittingPlacement;
            state.reset = true;
        }
    }
    var flip$1 = {
        name: "flip",
        enabled: true,
        phase: "main",
        fn: flip,
        requiresIfExists: [
            "offset"
        ],
        data: {
            _skip: false
        }
    };
    function getAltAxis(axis) {
        return axis === "x" ? "y" : "x";
    }
    function within(min$1, value, max$1) {
        return max(min$1, min(value, max$1));
    }
    function preventOverflow(_ref) {
        var state = _ref.state, options = _ref.options, name = _ref.name;
        var _options$mainAxis = options.mainAxis, checkMainAxis = _options$mainAxis === void 0 ? true : _options$mainAxis, _options$altAxis = options.altAxis, checkAltAxis = _options$altAxis === void 0 ? false : _options$altAxis, boundary = options.boundary, rootBoundary = options.rootBoundary, altBoundary = options.altBoundary, padding = options.padding, _options$tether = options.tether, tether = _options$tether === void 0 ? true : _options$tether, _options$tetherOffset = options.tetherOffset, tetherOffset = _options$tetherOffset === void 0 ? 0 : _options$tetherOffset;
        var overflow = detectOverflow(state, {
            boundary: boundary,
            rootBoundary: rootBoundary,
            padding: padding,
            altBoundary: altBoundary
        });
        var basePlacement = getBasePlacement(state.placement);
        var variation = getVariation(state.placement);
        var isBasePlacement = !variation;
        var mainAxis = getMainAxisFromPlacement(basePlacement);
        var altAxis = getAltAxis(mainAxis);
        var popperOffsets2 = state.modifiersData.popperOffsets;
        var referenceRect = state.rects.reference;
        var popperRect = state.rects.popper;
        var tetherOffsetValue = typeof tetherOffset === "function" ? tetherOffset(Object.assign({}, state.rects, {
            placement: state.placement
        })) : tetherOffset;
        var data = {
            x: 0,
            y: 0
        };
        if (!popperOffsets2) return;
        if (checkMainAxis || checkAltAxis) {
            var mainSide = mainAxis === "y" ? top : left;
            var altSide = mainAxis === "y" ? bottom : right;
            var len = mainAxis === "y" ? "height" : "width";
            var offset2 = popperOffsets2[mainAxis];
            var min$1 = popperOffsets2[mainAxis] + overflow[mainSide];
            var max$1 = popperOffsets2[mainAxis] - overflow[altSide];
            var additive = tether ? -popperRect[len] / 2 : 0;
            var minLen = variation === start ? referenceRect[len] : popperRect[len];
            var maxLen = variation === start ? -popperRect[len] : -referenceRect[len];
            var arrowElement = state.elements.arrow;
            var arrowRect = tether && arrowElement ? getLayoutRect(arrowElement) : {
                width: 0,
                height: 0
            };
            var arrowPaddingObject = state.modifiersData["arrow#persistent"] ? state.modifiersData["arrow#persistent"].padding : getFreshSideObject();
            var arrowPaddingMin = arrowPaddingObject[mainSide];
            var arrowPaddingMax = arrowPaddingObject[altSide];
            var arrowLen = within(0, referenceRect[len], arrowRect[len]);
            var minOffset = isBasePlacement ? referenceRect[len] / 2 - additive - arrowLen - arrowPaddingMin - tetherOffsetValue : minLen - arrowLen - arrowPaddingMin - tetherOffsetValue;
            var maxOffset = isBasePlacement ? -referenceRect[len] / 2 + additive + arrowLen + arrowPaddingMax + tetherOffsetValue : maxLen + arrowLen + arrowPaddingMax + tetherOffsetValue;
            var arrowOffsetParent = state.elements.arrow && getOffsetParent(state.elements.arrow);
            var clientOffset = arrowOffsetParent ? mainAxis === "y" ? arrowOffsetParent.clientTop || 0 : arrowOffsetParent.clientLeft || 0 : 0;
            var offsetModifierValue = state.modifiersData.offset ? state.modifiersData.offset[state.placement][mainAxis] : 0;
            var tetherMin = popperOffsets2[mainAxis] + minOffset - offsetModifierValue - clientOffset;
            var tetherMax = popperOffsets2[mainAxis] + maxOffset - offsetModifierValue;
            if (checkMainAxis) {
                var preventedOffset = within(tether ? min(min$1, tetherMin) : min$1, offset2, tether ? max(max$1, tetherMax) : max$1);
                popperOffsets2[mainAxis] = preventedOffset;
                data[mainAxis] = preventedOffset - offset2;
            }
            if (checkAltAxis) {
                var _mainSide = mainAxis === "x" ? top : left;
                var _altSide = mainAxis === "x" ? bottom : right;
                var _offset = popperOffsets2[altAxis];
                var _min = _offset + overflow[_mainSide];
                var _max = _offset - overflow[_altSide];
                var _preventedOffset = within(tether ? min(_min, tetherMin) : _min, _offset, tether ? max(_max, tetherMax) : _max);
                popperOffsets2[altAxis] = _preventedOffset;
                data[altAxis] = _preventedOffset - _offset;
            }
        }
        state.modifiersData[name] = data;
    }
    var preventOverflow$1 = {
        name: "preventOverflow",
        enabled: true,
        phase: "main",
        fn: preventOverflow,
        requiresIfExists: [
            "offset"
        ]
    };
    var toPaddingObject = function toPaddingObject2(padding, state) {
        padding = typeof padding === "function" ? padding(Object.assign({}, state.rects, {
            placement: state.placement
        })) : padding;
        return mergePaddingObject(typeof padding !== "number" ? padding : expandToHashMap(padding, basePlacements));
    };
    function arrow(_ref) {
        var _state$modifiersData$;
        var state = _ref.state, name = _ref.name, options = _ref.options;
        var arrowElement = state.elements.arrow;
        var popperOffsets2 = state.modifiersData.popperOffsets;
        var basePlacement = getBasePlacement(state.placement);
        var axis = getMainAxisFromPlacement(basePlacement);
        var isVertical = [
            left,
            right
        ].indexOf(basePlacement) >= 0;
        var len = isVertical ? "height" : "width";
        if (!arrowElement || !popperOffsets2) return;
        var paddingObject = toPaddingObject(options.padding, state);
        var arrowRect = getLayoutRect(arrowElement);
        var minProp = axis === "y" ? top : left;
        var maxProp = axis === "y" ? bottom : right;
        var endDiff = state.rects.reference[len] + state.rects.reference[axis] - popperOffsets2[axis] - state.rects.popper[len];
        var startDiff = popperOffsets2[axis] - state.rects.reference[axis];
        var arrowOffsetParent = getOffsetParent(arrowElement);
        var clientSize = arrowOffsetParent ? axis === "y" ? arrowOffsetParent.clientHeight || 0 : arrowOffsetParent.clientWidth || 0 : 0;
        var centerToReference = endDiff / 2 - startDiff / 2;
        var min2 = paddingObject[minProp];
        var max2 = clientSize - arrowRect[len] - paddingObject[maxProp];
        var center = clientSize / 2 - arrowRect[len] / 2 + centerToReference;
        var offset2 = within(min2, center, max2);
        var axisProp = axis;
        state.modifiersData[name] = (_state$modifiersData$ = {}, _state$modifiersData$[axisProp] = offset2, _state$modifiersData$.centerOffset = offset2 - center, _state$modifiersData$);
    }
    function effect(_ref2) {
        var state = _ref2.state, options = _ref2.options;
        var _options$element = options.element, arrowElement = _options$element === void 0 ? "[data-popper-arrow]" : _options$element;
        if (arrowElement == null) return;
        if (typeof arrowElement === "string") {
            arrowElement = state.elements.popper.querySelector(arrowElement);
            if (!arrowElement) return;
        }
        if (!isHTMLElement(arrowElement)) console.error([
            'Popper: "arrow" element must be an HTMLElement (not an SVGElement).',
            "To use an SVG arrow, wrap it in an HTMLElement that will be used as",
            "the arrow."
        ].join(" "));
        if (!contains(state.elements.popper, arrowElement)) {
            console.error([
                'Popper: "arrow" modifier\'s `element` must be a child of the popper',
                "element."
            ].join(" "));
            return;
        }
        state.elements.arrow = arrowElement;
    }
    var arrow$1 = {
        name: "arrow",
        enabled: true,
        phase: "main",
        fn: arrow,
        effect: effect,
        requires: [
            "popperOffsets"
        ],
        requiresIfExists: [
            "preventOverflow"
        ]
    };
    function getSideOffsets(overflow, rect, preventedOffsets) {
        if (preventedOffsets === void 0) preventedOffsets = {
            x: 0,
            y: 0
        };
        return {
            top: overflow.top - rect.height - preventedOffsets.y,
            right: overflow.right - rect.width + preventedOffsets.x,
            bottom: overflow.bottom - rect.height + preventedOffsets.y,
            left: overflow.left - rect.width - preventedOffsets.x
        };
    }
    function isAnySideFullyClipped(overflow) {
        return [
            top,
            right,
            bottom,
            left
        ].some(function(side) {
            return overflow[side] >= 0;
        });
    }
    function hide(_ref) {
        var state = _ref.state, name = _ref.name;
        var referenceRect = state.rects.reference;
        var popperRect = state.rects.popper;
        var preventedOffsets = state.modifiersData.preventOverflow;
        var referenceOverflow = detectOverflow(state, {
            elementContext: "reference"
        });
        var popperAltOverflow = detectOverflow(state, {
            altBoundary: true
        });
        var referenceClippingOffsets = getSideOffsets(referenceOverflow, referenceRect);
        var popperEscapeOffsets = getSideOffsets(popperAltOverflow, popperRect, preventedOffsets);
        var isReferenceHidden = isAnySideFullyClipped(referenceClippingOffsets);
        var hasPopperEscaped = isAnySideFullyClipped(popperEscapeOffsets);
        state.modifiersData[name] = {
            referenceClippingOffsets: referenceClippingOffsets,
            popperEscapeOffsets: popperEscapeOffsets,
            isReferenceHidden: isReferenceHidden,
            hasPopperEscaped: hasPopperEscaped
        };
        state.attributes.popper = Object.assign({}, state.attributes.popper, {
            "data-popper-reference-hidden": isReferenceHidden,
            "data-popper-escaped": hasPopperEscaped
        });
    }
    var hide$1 = {
        name: "hide",
        enabled: true,
        phase: "main",
        requiresIfExists: [
            "preventOverflow"
        ],
        fn: hide
    };
    var defaultModifiers$1 = [
        eventListeners,
        popperOffsets$1,
        computeStyles$1,
        applyStyles$1
    ];
    var createPopper$1 = /* @__PURE__ */ popperGenerator({
        defaultModifiers: defaultModifiers$1
    });
    var defaultModifiers = [
        eventListeners,
        popperOffsets$1,
        computeStyles$1,
        applyStyles$1,
        offset$1,
        flip$1,
        preventOverflow$1,
        arrow$1,
        hide$1
    ];
    var createPopper = /* @__PURE__ */ popperGenerator({
        defaultModifiers: defaultModifiers
    });
    exports.applyStyles = applyStyles$1;
    exports.arrow = arrow$1;
    exports.computeStyles = computeStyles$1;
    exports.createPopper = createPopper;
    exports.createPopperLite = createPopper$1;
    exports.defaultModifiers = defaultModifiers;
    exports.detectOverflow = detectOverflow;
    exports.eventListeners = eventListeners;
    exports.flip = flip$1;
    exports.hide = hide$1;
    exports.offset = offset$1;
    exports.popperGenerator = popperGenerator;
    exports.popperOffsets = popperOffsets$1;
    exports.preventOverflow = preventOverflow$1;
});
// node_modules/tippy.js/dist/tippy.cjs.js
var $69a8ec8dbeef3157$var$require_tippy_cjs = $69a8ec8dbeef3157$var$__commonJS((exports)=>{
    "use strict";
    Object.defineProperty(exports, "__esModule", {
        value: true
    });
    var core = $69a8ec8dbeef3157$var$require_popper();
    var ROUND_ARROW = '<svg width="16" height="6" xmlns="http://www.w3.org/2000/svg"><path d="M0 6s1.796-.013 4.67-3.615C5.851.9 6.93.006 8 0c1.07-.006 2.148.887 3.343 2.385C14.233 6.005 16 6 16 6H0z"></svg>';
    var BOX_CLASS = "tippy-box";
    var CONTENT_CLASS = "tippy-content";
    var BACKDROP_CLASS = "tippy-backdrop";
    var ARROW_CLASS = "tippy-arrow";
    var SVG_ARROW_CLASS = "tippy-svg-arrow";
    var TOUCH_OPTIONS = {
        passive: true,
        capture: true
    };
    function hasOwnProperty(obj, key) {
        return ({}).hasOwnProperty.call(obj, key);
    }
    function getValueAtIndexOrReturn(value, index, defaultValue) {
        if (Array.isArray(value)) {
            var v = value[index];
            return v == null ? Array.isArray(defaultValue) ? defaultValue[index] : defaultValue : v;
        }
        return value;
    }
    function isType(value, type) {
        var str = ({}).toString.call(value);
        return str.indexOf("[object") === 0 && str.indexOf(type + "]") > -1;
    }
    function invokeWithArgsOrReturn(value, args) {
        return typeof value === "function" ? value.apply(void 0, args) : value;
    }
    function debounce(fn, ms) {
        if (ms === 0) return fn;
        var timeout;
        return function(arg) {
            clearTimeout(timeout);
            timeout = setTimeout(function() {
                fn(arg);
            }, ms);
        };
    }
    function removeProperties(obj, keys) {
        var clone = Object.assign({}, obj);
        keys.forEach(function(key) {
            delete clone[key];
        });
        return clone;
    }
    function splitBySpaces(value) {
        return value.split(/\s+/).filter(Boolean);
    }
    function normalizeToArray(value) {
        return [].concat(value);
    }
    function pushIfUnique(arr, value) {
        if (arr.indexOf(value) === -1) arr.push(value);
    }
    function unique(arr) {
        return arr.filter(function(item, index) {
            return arr.indexOf(item) === index;
        });
    }
    function getBasePlacement(placement) {
        return placement.split("-")[0];
    }
    function arrayFrom(value) {
        return [].slice.call(value);
    }
    function removeUndefinedProps(obj) {
        return Object.keys(obj).reduce(function(acc, key) {
            if (obj[key] !== void 0) acc[key] = obj[key];
            return acc;
        }, {});
    }
    function div() {
        return document.createElement("div");
    }
    function isElement(value) {
        return [
            "Element",
            "Fragment"
        ].some(function(type) {
            return isType(value, type);
        });
    }
    function isNodeList(value) {
        return isType(value, "NodeList");
    }
    function isMouseEvent(value) {
        return isType(value, "MouseEvent");
    }
    function isReferenceElement(value) {
        return !!(value && value._tippy && value._tippy.reference === value);
    }
    function getArrayOfElements(value) {
        if (isElement(value)) return [
            value
        ];
        if (isNodeList(value)) return arrayFrom(value);
        if (Array.isArray(value)) return value;
        return arrayFrom(document.querySelectorAll(value));
    }
    function setTransitionDuration(els, value) {
        els.forEach(function(el) {
            if (el) el.style.transitionDuration = value + "ms";
        });
    }
    function setVisibilityState(els, state) {
        els.forEach(function(el) {
            if (el) el.setAttribute("data-state", state);
        });
    }
    function getOwnerDocument(elementOrElements) {
        var _element$ownerDocumen;
        var _normalizeToArray = normalizeToArray(elementOrElements), element = _normalizeToArray[0];
        return (element == null ? void 0 : (_element$ownerDocumen = element.ownerDocument) == null ? void 0 : _element$ownerDocumen.body) ? element.ownerDocument : document;
    }
    function isCursorOutsideInteractiveBorder(popperTreeData, event) {
        var clientX = event.clientX, clientY = event.clientY;
        return popperTreeData.every(function(_ref) {
            var popperRect = _ref.popperRect, popperState = _ref.popperState, props = _ref.props;
            var interactiveBorder = props.interactiveBorder;
            var basePlacement = getBasePlacement(popperState.placement);
            var offsetData = popperState.modifiersData.offset;
            if (!offsetData) return true;
            var topDistance = basePlacement === "bottom" ? offsetData.top.y : 0;
            var bottomDistance = basePlacement === "top" ? offsetData.bottom.y : 0;
            var leftDistance = basePlacement === "right" ? offsetData.left.x : 0;
            var rightDistance = basePlacement === "left" ? offsetData.right.x : 0;
            var exceedsTop = popperRect.top - clientY + topDistance > interactiveBorder;
            var exceedsBottom = clientY - popperRect.bottom - bottomDistance > interactiveBorder;
            var exceedsLeft = popperRect.left - clientX + leftDistance > interactiveBorder;
            var exceedsRight = clientX - popperRect.right - rightDistance > interactiveBorder;
            return exceedsTop || exceedsBottom || exceedsLeft || exceedsRight;
        });
    }
    function updateTransitionEndListener(box, action, listener) {
        var method = action + "EventListener";
        [
            "transitionend",
            "webkitTransitionEnd"
        ].forEach(function(event) {
            box[method](event, listener);
        });
    }
    var currentInput = {
        isTouch: false
    };
    var lastMouseMoveTime = 0;
    function onDocumentTouchStart() {
        if (currentInput.isTouch) return;
        currentInput.isTouch = true;
        if (window.performance) document.addEventListener("mousemove", onDocumentMouseMove);
    }
    function onDocumentMouseMove() {
        var now = performance.now();
        if (now - lastMouseMoveTime < 20) {
            currentInput.isTouch = false;
            document.removeEventListener("mousemove", onDocumentMouseMove);
        }
        lastMouseMoveTime = now;
    }
    function onWindowBlur() {
        var activeElement = document.activeElement;
        if (isReferenceElement(activeElement)) {
            var instance = activeElement._tippy;
            if (activeElement.blur && !instance.state.isVisible) activeElement.blur();
        }
    }
    function bindGlobalEventListeners() {
        document.addEventListener("touchstart", onDocumentTouchStart, TOUCH_OPTIONS);
        window.addEventListener("blur", onWindowBlur);
    }
    var isBrowser = typeof window !== "undefined" && typeof document !== "undefined";
    var ua = isBrowser ? navigator.userAgent : "";
    var isIE = /MSIE |Trident\//.test(ua);
    function createMemoryLeakWarning(method) {
        var txt = method === "destroy" ? "n already-" : " ";
        return [
            method + "() was called on a" + txt + "destroyed instance. This is a no-op but",
            "indicates a potential memory leak."
        ].join(" ");
    }
    function clean(value) {
        var spacesAndTabs = /[ \t]{2,}/g;
        var lineStartWithSpaces = /^[ \t]*/gm;
        return value.replace(spacesAndTabs, " ").replace(lineStartWithSpaces, "").trim();
    }
    function getDevMessage(message) {
        return clean("\n  %ctippy.js\n\n  %c" + clean(message) + "\n\n  %c\uD83D\uDC77\u200D This is a development-only message. It will be removed in production.\n  ");
    }
    function getFormattedMessage(message) {
        return [
            getDevMessage(message),
            "color: #00C584; font-size: 1.3em; font-weight: bold;",
            "line-height: 1.5",
            "color: #a6a095;"
        ];
    }
    var visitedMessages;
    resetVisitedMessages();
    function resetVisitedMessages() {
        visitedMessages = new Set();
    }
    function warnWhen(condition, message) {
        if (condition && !visitedMessages.has(message)) {
            var _console;
            visitedMessages.add(message);
            (_console = console).warn.apply(_console, getFormattedMessage(message));
        }
    }
    function errorWhen(condition, message) {
        if (condition && !visitedMessages.has(message)) {
            var _console2;
            visitedMessages.add(message);
            (_console2 = console).error.apply(_console2, getFormattedMessage(message));
        }
    }
    function validateTargets(targets) {
        var didPassFalsyValue = !targets;
        var didPassPlainObject = Object.prototype.toString.call(targets) === "[object Object]" && !targets.addEventListener;
        errorWhen(didPassFalsyValue, [
            "tippy() was passed",
            "`" + String(targets) + "`",
            "as its targets (first) argument. Valid types are: String, Element,",
            "Element[], or NodeList."
        ].join(" "));
        errorWhen(didPassPlainObject, [
            "tippy() was passed a plain object which is not supported as an argument",
            "for virtual positioning. Use props.getReferenceClientRect instead."
        ].join(" "));
    }
    var pluginProps = {
        animateFill: false,
        followCursor: false,
        inlinePositioning: false,
        sticky: false
    };
    var renderProps = {
        allowHTML: false,
        animation: "fade",
        arrow: true,
        content: "",
        inertia: false,
        maxWidth: 350,
        role: "tooltip",
        theme: "",
        zIndex: 9999
    };
    var defaultProps = Object.assign({
        appendTo: function appendTo() {
            return document.body;
        },
        aria: {
            content: "auto",
            expanded: "auto"
        },
        delay: 0,
        duration: [
            300,
            250
        ],
        getReferenceClientRect: null,
        hideOnClick: true,
        ignoreAttributes: false,
        interactive: false,
        interactiveBorder: 2,
        interactiveDebounce: 0,
        moveTransition: "",
        offset: [
            0,
            10
        ],
        onAfterUpdate: function onAfterUpdate() {},
        onBeforeUpdate: function onBeforeUpdate() {},
        onCreate: function onCreate() {},
        onDestroy: function onDestroy() {},
        onHidden: function onHidden() {},
        onHide: function onHide() {},
        onMount: function onMount() {},
        onShow: function onShow() {},
        onShown: function onShown() {},
        onTrigger: function onTrigger() {},
        onUntrigger: function onUntrigger() {},
        onClickOutside: function onClickOutside() {},
        placement: "top",
        plugins: [],
        popperOptions: {},
        render: null,
        showOnCreate: false,
        touch: true,
        trigger: "mouseenter focus",
        triggerTarget: null
    }, pluginProps, {}, renderProps);
    var defaultKeys = Object.keys(defaultProps);
    var setDefaultProps = function setDefaultProps2(partialProps) {
        validateProps(partialProps, []);
        var keys = Object.keys(partialProps);
        keys.forEach(function(key) {
            defaultProps[key] = partialProps[key];
        });
    };
    function getExtendedPassedProps(passedProps) {
        var plugins = passedProps.plugins || [];
        var pluginProps2 = plugins.reduce(function(acc, plugin) {
            var name = plugin.name, defaultValue = plugin.defaultValue;
            if (name) acc[name] = passedProps[name] !== void 0 ? passedProps[name] : defaultValue;
            return acc;
        }, {});
        return Object.assign({}, passedProps, {}, pluginProps2);
    }
    function getDataAttributeProps(reference, plugins) {
        var propKeys = plugins ? Object.keys(getExtendedPassedProps(Object.assign({}, defaultProps, {
            plugins: plugins
        }))) : defaultKeys;
        var props = propKeys.reduce(function(acc, key) {
            var valueAsString = (reference.getAttribute("data-tippy-" + key) || "").trim();
            if (!valueAsString) return acc;
            if (key === "content") acc[key] = valueAsString;
            else try {
                acc[key] = JSON.parse(valueAsString);
            } catch (e) {
                acc[key] = valueAsString;
            }
            return acc;
        }, {});
        return props;
    }
    function evaluateProps(reference, props) {
        var out = Object.assign({}, props, {
            content: invokeWithArgsOrReturn(props.content, [
                reference
            ])
        }, props.ignoreAttributes ? {} : getDataAttributeProps(reference, props.plugins));
        out.aria = Object.assign({}, defaultProps.aria, {}, out.aria);
        out.aria = {
            expanded: out.aria.expanded === "auto" ? props.interactive : out.aria.expanded,
            content: out.aria.content === "auto" ? props.interactive ? null : "describedby" : out.aria.content
        };
        return out;
    }
    function validateProps(partialProps, plugins) {
        if (partialProps === void 0) partialProps = {};
        if (plugins === void 0) plugins = [];
        var keys = Object.keys(partialProps);
        keys.forEach(function(prop) {
            var nonPluginProps = removeProperties(defaultProps, Object.keys(pluginProps));
            var didPassUnknownProp = !hasOwnProperty(nonPluginProps, prop);
            if (didPassUnknownProp) didPassUnknownProp = plugins.filter(function(plugin) {
                return plugin.name === prop;
            }).length === 0;
            warnWhen(didPassUnknownProp, [
                "`" + prop + "`",
                "is not a valid prop. You may have spelled it incorrectly, or if it's",
                "a plugin, forgot to pass it in an array as props.plugins.",
                "\n\n",
                "All props: https://atomiks.github.io/tippyjs/v6/all-props/\n",
                "Plugins: https://atomiks.github.io/tippyjs/v6/plugins/"
            ].join(" "));
        });
    }
    var innerHTML = function innerHTML2() {
        return "innerHTML";
    };
    function dangerouslySetInnerHTML(element, html) {
        element[innerHTML()] = html;
    }
    function createArrowElement(value) {
        var arrow = div();
        if (value === true) arrow.className = ARROW_CLASS;
        else {
            arrow.className = SVG_ARROW_CLASS;
            if (isElement(value)) arrow.appendChild(value);
            else dangerouslySetInnerHTML(arrow, value);
        }
        return arrow;
    }
    function setContent(content, props) {
        if (isElement(props.content)) {
            dangerouslySetInnerHTML(content, "");
            content.appendChild(props.content);
        } else if (typeof props.content !== "function") {
            if (props.allowHTML) dangerouslySetInnerHTML(content, props.content);
            else content.textContent = props.content;
        }
    }
    function getChildren(popper) {
        var box = popper.firstElementChild;
        var boxChildren = arrayFrom(box.children);
        return {
            box: box,
            content: boxChildren.find(function(node) {
                return node.classList.contains(CONTENT_CLASS);
            }),
            arrow: boxChildren.find(function(node) {
                return node.classList.contains(ARROW_CLASS) || node.classList.contains(SVG_ARROW_CLASS);
            }),
            backdrop: boxChildren.find(function(node) {
                return node.classList.contains(BACKDROP_CLASS);
            })
        };
    }
    function render(instance) {
        var popper = div();
        var box = div();
        box.className = BOX_CLASS;
        box.setAttribute("data-state", "hidden");
        box.setAttribute("tabindex", "-1");
        var content = div();
        content.className = CONTENT_CLASS;
        content.setAttribute("data-state", "hidden");
        setContent(content, instance.props);
        popper.appendChild(box);
        box.appendChild(content);
        onUpdate(instance.props, instance.props);
        function onUpdate(prevProps, nextProps) {
            var _getChildren = getChildren(popper), box2 = _getChildren.box, content2 = _getChildren.content, arrow = _getChildren.arrow;
            if (nextProps.theme) box2.setAttribute("data-theme", nextProps.theme);
            else box2.removeAttribute("data-theme");
            if (typeof nextProps.animation === "string") box2.setAttribute("data-animation", nextProps.animation);
            else box2.removeAttribute("data-animation");
            if (nextProps.inertia) box2.setAttribute("data-inertia", "");
            else box2.removeAttribute("data-inertia");
            box2.style.maxWidth = typeof nextProps.maxWidth === "number" ? nextProps.maxWidth + "px" : nextProps.maxWidth;
            if (nextProps.role) box2.setAttribute("role", nextProps.role);
            else box2.removeAttribute("role");
            if (prevProps.content !== nextProps.content || prevProps.allowHTML !== nextProps.allowHTML) setContent(content2, instance.props);
            if (nextProps.arrow) {
                if (!arrow) box2.appendChild(createArrowElement(nextProps.arrow));
                else if (prevProps.arrow !== nextProps.arrow) {
                    box2.removeChild(arrow);
                    box2.appendChild(createArrowElement(nextProps.arrow));
                }
            } else if (arrow) box2.removeChild(arrow);
        }
        return {
            popper: popper,
            onUpdate: onUpdate
        };
    }
    render.$$tippy = true;
    var idCounter = 1;
    var mouseMoveListeners = [];
    var mountedInstances = [];
    function createTippy(reference, passedProps) {
        var props = evaluateProps(reference, Object.assign({}, defaultProps, {}, getExtendedPassedProps(removeUndefinedProps(passedProps))));
        var showTimeout;
        var hideTimeout;
        var scheduleHideAnimationFrame;
        var isVisibleFromClick = false;
        var didHideDueToDocumentMouseDown = false;
        var didTouchMove = false;
        var ignoreOnFirstUpdate = false;
        var lastTriggerEvent;
        var currentTransitionEndListener;
        var onFirstUpdate;
        var listeners = [];
        var debouncedOnMouseMove = debounce(onMouseMove, props.interactiveDebounce);
        var currentTarget;
        var id = idCounter++;
        var popperInstance = null;
        var plugins = unique(props.plugins);
        var state = {
            isEnabled: true,
            isVisible: false,
            isDestroyed: false,
            isMounted: false,
            isShown: false
        };
        var instance = {
            id: id,
            reference: reference,
            popper: div(),
            popperInstance: popperInstance,
            props: props,
            state: state,
            plugins: plugins,
            clearDelayTimeouts: clearDelayTimeouts,
            setProps: setProps,
            setContent: setContent2,
            show: show,
            hide: hide,
            hideWithInteractivity: hideWithInteractivity,
            enable: enable,
            disable: disable,
            unmount: unmount,
            destroy: destroy
        };
        if (!props.render) {
            errorWhen(true, "render() function has not been supplied.");
            return instance;
        }
        var _props$render = props.render(instance), popper = _props$render.popper, onUpdate = _props$render.onUpdate;
        popper.setAttribute("data-tippy-root", "");
        popper.id = "tippy-" + instance.id;
        instance.popper = popper;
        reference._tippy = instance;
        popper._tippy = instance;
        var pluginsHooks = plugins.map(function(plugin) {
            return plugin.fn(instance);
        });
        var hasAriaExpanded = reference.hasAttribute("aria-expanded");
        addListeners();
        handleAriaExpandedAttribute();
        handleStyles();
        invokeHook("onCreate", [
            instance
        ]);
        if (props.showOnCreate) scheduleShow();
        popper.addEventListener("mouseenter", function() {
            if (instance.props.interactive && instance.state.isVisible) instance.clearDelayTimeouts();
        });
        popper.addEventListener("mouseleave", function(event) {
            if (instance.props.interactive && instance.props.trigger.indexOf("mouseenter") >= 0) {
                getDocument().addEventListener("mousemove", debouncedOnMouseMove);
                debouncedOnMouseMove(event);
            }
        });
        return instance;
        function getNormalizedTouchSettings() {
            var touch = instance.props.touch;
            return Array.isArray(touch) ? touch : [
                touch,
                0
            ];
        }
        function getIsCustomTouchBehavior() {
            return getNormalizedTouchSettings()[0] === "hold";
        }
        function getIsDefaultRenderFn() {
            var _instance$props$rende;
            return !!((_instance$props$rende = instance.props.render) == null ? void 0 : _instance$props$rende.$$tippy);
        }
        function getCurrentTarget() {
            return currentTarget || reference;
        }
        function getDocument() {
            var parent = getCurrentTarget().parentNode;
            return parent ? getOwnerDocument(parent) : document;
        }
        function getDefaultTemplateChildren() {
            return getChildren(popper);
        }
        function getDelay(isShow) {
            if (instance.state.isMounted && !instance.state.isVisible || currentInput.isTouch || lastTriggerEvent && lastTriggerEvent.type === "focus") return 0;
            return getValueAtIndexOrReturn(instance.props.delay, isShow ? 0 : 1, defaultProps.delay);
        }
        function handleStyles() {
            popper.style.pointerEvents = instance.props.interactive && instance.state.isVisible ? "" : "none";
            popper.style.zIndex = "" + instance.props.zIndex;
        }
        function invokeHook(hook, args, shouldInvokePropsHook) {
            if (shouldInvokePropsHook === void 0) shouldInvokePropsHook = true;
            pluginsHooks.forEach(function(pluginHooks) {
                if (pluginHooks[hook]) pluginHooks[hook].apply(void 0, args);
            });
            if (shouldInvokePropsHook) {
                var _instance$props;
                (_instance$props = instance.props)[hook].apply(_instance$props, args);
            }
        }
        function handleAriaContentAttribute() {
            var aria = instance.props.aria;
            if (!aria.content) return;
            var attr = "aria-" + aria.content;
            var id2 = popper.id;
            var nodes = normalizeToArray(instance.props.triggerTarget || reference);
            nodes.forEach(function(node) {
                var currentValue = node.getAttribute(attr);
                if (instance.state.isVisible) node.setAttribute(attr, currentValue ? currentValue + " " + id2 : id2);
                else {
                    var nextValue = currentValue && currentValue.replace(id2, "").trim();
                    if (nextValue) node.setAttribute(attr, nextValue);
                    else node.removeAttribute(attr);
                }
            });
        }
        function handleAriaExpandedAttribute() {
            if (hasAriaExpanded || !instance.props.aria.expanded) return;
            var nodes = normalizeToArray(instance.props.triggerTarget || reference);
            nodes.forEach(function(node) {
                if (instance.props.interactive) node.setAttribute("aria-expanded", instance.state.isVisible && node === getCurrentTarget() ? "true" : "false");
                else node.removeAttribute("aria-expanded");
            });
        }
        function cleanupInteractiveMouseListeners() {
            getDocument().removeEventListener("mousemove", debouncedOnMouseMove);
            mouseMoveListeners = mouseMoveListeners.filter(function(listener) {
                return listener !== debouncedOnMouseMove;
            });
        }
        function onDocumentPress(event) {
            if (currentInput.isTouch) {
                if (didTouchMove || event.type === "mousedown") return;
            }
            if (instance.props.interactive && popper.contains(event.target)) return;
            if (getCurrentTarget().contains(event.target)) {
                if (currentInput.isTouch) return;
                if (instance.state.isVisible && instance.props.trigger.indexOf("click") >= 0) return;
            } else invokeHook("onClickOutside", [
                instance,
                event
            ]);
            if (instance.props.hideOnClick === true) {
                instance.clearDelayTimeouts();
                instance.hide();
                didHideDueToDocumentMouseDown = true;
                setTimeout(function() {
                    didHideDueToDocumentMouseDown = false;
                });
                if (!instance.state.isMounted) removeDocumentPress();
            }
        }
        function onTouchMove() {
            didTouchMove = true;
        }
        function onTouchStart() {
            didTouchMove = false;
        }
        function addDocumentPress() {
            var doc = getDocument();
            doc.addEventListener("mousedown", onDocumentPress, true);
            doc.addEventListener("touchend", onDocumentPress, TOUCH_OPTIONS);
            doc.addEventListener("touchstart", onTouchStart, TOUCH_OPTIONS);
            doc.addEventListener("touchmove", onTouchMove, TOUCH_OPTIONS);
        }
        function removeDocumentPress() {
            var doc = getDocument();
            doc.removeEventListener("mousedown", onDocumentPress, true);
            doc.removeEventListener("touchend", onDocumentPress, TOUCH_OPTIONS);
            doc.removeEventListener("touchstart", onTouchStart, TOUCH_OPTIONS);
            doc.removeEventListener("touchmove", onTouchMove, TOUCH_OPTIONS);
        }
        function onTransitionedOut(duration, callback) {
            onTransitionEnd(duration, function() {
                if (!instance.state.isVisible && popper.parentNode && popper.parentNode.contains(popper)) callback();
            });
        }
        function onTransitionedIn(duration, callback) {
            onTransitionEnd(duration, callback);
        }
        function onTransitionEnd(duration, callback) {
            var box = getDefaultTemplateChildren().box;
            function listener(event) {
                if (event.target === box) {
                    updateTransitionEndListener(box, "remove", listener);
                    callback();
                }
            }
            if (duration === 0) return callback();
            updateTransitionEndListener(box, "remove", currentTransitionEndListener);
            updateTransitionEndListener(box, "add", listener);
            currentTransitionEndListener = listener;
        }
        function on(eventType, handler, options) {
            if (options === void 0) options = false;
            var nodes = normalizeToArray(instance.props.triggerTarget || reference);
            nodes.forEach(function(node) {
                node.addEventListener(eventType, handler, options);
                listeners.push({
                    node: node,
                    eventType: eventType,
                    handler: handler,
                    options: options
                });
            });
        }
        function addListeners() {
            if (getIsCustomTouchBehavior()) {
                on("touchstart", onTrigger, {
                    passive: true
                });
                on("touchend", onMouseLeave, {
                    passive: true
                });
            }
            splitBySpaces(instance.props.trigger).forEach(function(eventType) {
                if (eventType === "manual") return;
                on(eventType, onTrigger);
                switch(eventType){
                    case "mouseenter":
                        on("mouseleave", onMouseLeave);
                        break;
                    case "focus":
                        on(isIE ? "focusout" : "blur", onBlurOrFocusOut);
                        break;
                    case "focusin":
                        on("focusout", onBlurOrFocusOut);
                        break;
                }
            });
        }
        function removeListeners() {
            listeners.forEach(function(_ref) {
                var node = _ref.node, eventType = _ref.eventType, handler = _ref.handler, options = _ref.options;
                node.removeEventListener(eventType, handler, options);
            });
            listeners = [];
        }
        function onTrigger(event) {
            var _lastTriggerEvent;
            var shouldScheduleClickHide = false;
            if (!instance.state.isEnabled || isEventListenerStopped(event) || didHideDueToDocumentMouseDown) return;
            var wasFocused = ((_lastTriggerEvent = lastTriggerEvent) == null ? void 0 : _lastTriggerEvent.type) === "focus";
            lastTriggerEvent = event;
            currentTarget = event.currentTarget;
            handleAriaExpandedAttribute();
            if (!instance.state.isVisible && isMouseEvent(event)) mouseMoveListeners.forEach(function(listener) {
                return listener(event);
            });
            if (event.type === "click" && (instance.props.trigger.indexOf("mouseenter") < 0 || isVisibleFromClick) && instance.props.hideOnClick !== false && instance.state.isVisible) shouldScheduleClickHide = true;
            else scheduleShow(event);
            if (event.type === "click") isVisibleFromClick = !shouldScheduleClickHide;
            if (shouldScheduleClickHide && !wasFocused) scheduleHide(event);
        }
        function onMouseMove(event) {
            var target = event.target;
            var isCursorOverReferenceOrPopper = getCurrentTarget().contains(target) || popper.contains(target);
            if (event.type === "mousemove" && isCursorOverReferenceOrPopper) return;
            var popperTreeData = getNestedPopperTree().concat(popper).map(function(popper2) {
                var _instance$popperInsta;
                var instance2 = popper2._tippy;
                var state2 = (_instance$popperInsta = instance2.popperInstance) == null ? void 0 : _instance$popperInsta.state;
                if (state2) return {
                    popperRect: popper2.getBoundingClientRect(),
                    popperState: state2,
                    props: props
                };
                return null;
            }).filter(Boolean);
            if (isCursorOutsideInteractiveBorder(popperTreeData, event)) {
                cleanupInteractiveMouseListeners();
                scheduleHide(event);
            }
        }
        function onMouseLeave(event) {
            var shouldBail = isEventListenerStopped(event) || instance.props.trigger.indexOf("click") >= 0 && isVisibleFromClick;
            if (shouldBail) return;
            if (instance.props.interactive) {
                instance.hideWithInteractivity(event);
                return;
            }
            scheduleHide(event);
        }
        function onBlurOrFocusOut(event) {
            if (instance.props.trigger.indexOf("focusin") < 0 && event.target !== getCurrentTarget()) return;
            if (instance.props.interactive && event.relatedTarget && popper.contains(event.relatedTarget)) return;
            scheduleHide(event);
        }
        function isEventListenerStopped(event) {
            return currentInput.isTouch ? getIsCustomTouchBehavior() !== event.type.indexOf("touch") >= 0 : false;
        }
        function createPopperInstance() {
            destroyPopperInstance();
            var _instance$props2 = instance.props, popperOptions = _instance$props2.popperOptions, placement = _instance$props2.placement, offset = _instance$props2.offset, getReferenceClientRect = _instance$props2.getReferenceClientRect, moveTransition = _instance$props2.moveTransition;
            var arrow = getIsDefaultRenderFn() ? getChildren(popper).arrow : null;
            var computedReference = getReferenceClientRect ? {
                getBoundingClientRect: getReferenceClientRect,
                contextElement: getReferenceClientRect.contextElement || getCurrentTarget()
            } : reference;
            var tippyModifier = {
                name: "$$tippy",
                enabled: true,
                phase: "beforeWrite",
                requires: [
                    "computeStyles"
                ],
                fn: function fn(_ref2) {
                    var state2 = _ref2.state;
                    if (getIsDefaultRenderFn()) {
                        var _getDefaultTemplateCh = getDefaultTemplateChildren(), box = _getDefaultTemplateCh.box;
                        [
                            "placement",
                            "reference-hidden",
                            "escaped"
                        ].forEach(function(attr) {
                            if (attr === "placement") box.setAttribute("data-placement", state2.placement);
                            else if (state2.attributes.popper["data-popper-" + attr]) box.setAttribute("data-" + attr, "");
                            else box.removeAttribute("data-" + attr);
                        });
                        state2.attributes.popper = {};
                    }
                }
            };
            var modifiers = [
                {
                    name: "offset",
                    options: {
                        offset: offset
                    }
                },
                {
                    name: "preventOverflow",
                    options: {
                        padding: {
                            top: 2,
                            bottom: 2,
                            left: 5,
                            right: 5
                        }
                    }
                },
                {
                    name: "flip",
                    options: {
                        padding: 5
                    }
                },
                {
                    name: "computeStyles",
                    options: {
                        adaptive: !moveTransition
                    }
                },
                tippyModifier
            ];
            if (getIsDefaultRenderFn() && arrow) modifiers.push({
                name: "arrow",
                options: {
                    element: arrow,
                    padding: 3
                }
            });
            modifiers.push.apply(modifiers, (popperOptions == null ? void 0 : popperOptions.modifiers) || []);
            instance.popperInstance = core.createPopper(computedReference, popper, Object.assign({}, popperOptions, {
                placement: placement,
                onFirstUpdate: onFirstUpdate,
                modifiers: modifiers
            }));
        }
        function destroyPopperInstance() {
            if (instance.popperInstance) {
                instance.popperInstance.destroy();
                instance.popperInstance = null;
            }
        }
        function mount() {
            var appendTo = instance.props.appendTo;
            var parentNode;
            var node = getCurrentTarget();
            if (instance.props.interactive && appendTo === defaultProps.appendTo || appendTo === "parent") parentNode = node.parentNode;
            else parentNode = invokeWithArgsOrReturn(appendTo, [
                node
            ]);
            if (!parentNode.contains(popper)) parentNode.appendChild(popper);
            createPopperInstance();
            warnWhen(instance.props.interactive && appendTo === defaultProps.appendTo && node.nextElementSibling !== popper, [
                "Interactive tippy element may not be accessible via keyboard",
                "navigation because it is not directly after the reference element",
                "in the DOM source order.",
                "\n\n",
                "Using a wrapper <div> or <span> tag around the reference element",
                "solves this by creating a new parentNode context.",
                "\n\n",
                "Specifying `appendTo: document.body` silences this warning, but it",
                "assumes you are using a focus management solution to handle",
                "keyboard navigation.",
                "\n\n",
                "See: https://atomiks.github.io/tippyjs/v6/accessibility/#interactivity"
            ].join(" "));
        }
        function getNestedPopperTree() {
            return arrayFrom(popper.querySelectorAll("[data-tippy-root]"));
        }
        function scheduleShow(event) {
            instance.clearDelayTimeouts();
            if (event) invokeHook("onTrigger", [
                instance,
                event
            ]);
            addDocumentPress();
            var delay = getDelay(true);
            var _getNormalizedTouchSe = getNormalizedTouchSettings(), touchValue = _getNormalizedTouchSe[0], touchDelay = _getNormalizedTouchSe[1];
            if (currentInput.isTouch && touchValue === "hold" && touchDelay) delay = touchDelay;
            if (delay) showTimeout = setTimeout(function() {
                instance.show();
            }, delay);
            else instance.show();
        }
        function scheduleHide(event) {
            instance.clearDelayTimeouts();
            invokeHook("onUntrigger", [
                instance,
                event
            ]);
            if (!instance.state.isVisible) {
                removeDocumentPress();
                return;
            }
            if (instance.props.trigger.indexOf("mouseenter") >= 0 && instance.props.trigger.indexOf("click") >= 0 && [
                "mouseleave",
                "mousemove"
            ].indexOf(event.type) >= 0 && isVisibleFromClick) return;
            var delay = getDelay(false);
            if (delay) hideTimeout = setTimeout(function() {
                if (instance.state.isVisible) instance.hide();
            }, delay);
            else scheduleHideAnimationFrame = requestAnimationFrame(function() {
                instance.hide();
            });
        }
        function enable() {
            instance.state.isEnabled = true;
        }
        function disable() {
            instance.hide();
            instance.state.isEnabled = false;
        }
        function clearDelayTimeouts() {
            clearTimeout(showTimeout);
            clearTimeout(hideTimeout);
            cancelAnimationFrame(scheduleHideAnimationFrame);
        }
        function setProps(partialProps) {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("setProps"));
            if (instance.state.isDestroyed) return;
            invokeHook("onBeforeUpdate", [
                instance,
                partialProps
            ]);
            removeListeners();
            var prevProps = instance.props;
            var nextProps = evaluateProps(reference, Object.assign({}, instance.props, {}, partialProps, {
                ignoreAttributes: true
            }));
            instance.props = nextProps;
            addListeners();
            if (prevProps.interactiveDebounce !== nextProps.interactiveDebounce) {
                cleanupInteractiveMouseListeners();
                debouncedOnMouseMove = debounce(onMouseMove, nextProps.interactiveDebounce);
            }
            if (prevProps.triggerTarget && !nextProps.triggerTarget) normalizeToArray(prevProps.triggerTarget).forEach(function(node) {
                node.removeAttribute("aria-expanded");
            });
            else if (nextProps.triggerTarget) reference.removeAttribute("aria-expanded");
            handleAriaExpandedAttribute();
            handleStyles();
            if (onUpdate) onUpdate(prevProps, nextProps);
            if (instance.popperInstance) {
                createPopperInstance();
                getNestedPopperTree().forEach(function(nestedPopper) {
                    requestAnimationFrame(nestedPopper._tippy.popperInstance.forceUpdate);
                });
            }
            invokeHook("onAfterUpdate", [
                instance,
                partialProps
            ]);
        }
        function setContent2(content) {
            instance.setProps({
                content: content
            });
        }
        function show() {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("show"));
            var isAlreadyVisible = instance.state.isVisible;
            var isDestroyed = instance.state.isDestroyed;
            var isDisabled = !instance.state.isEnabled;
            var isTouchAndTouchDisabled = currentInput.isTouch && !instance.props.touch;
            var duration = getValueAtIndexOrReturn(instance.props.duration, 0, defaultProps.duration);
            if (isAlreadyVisible || isDestroyed || isDisabled || isTouchAndTouchDisabled) return;
            if (getCurrentTarget().hasAttribute("disabled")) return;
            invokeHook("onShow", [
                instance
            ], false);
            if (instance.props.onShow(instance) === false) return;
            instance.state.isVisible = true;
            if (getIsDefaultRenderFn()) popper.style.visibility = "visible";
            handleStyles();
            addDocumentPress();
            if (!instance.state.isMounted) popper.style.transition = "none";
            if (getIsDefaultRenderFn()) {
                var _getDefaultTemplateCh2 = getDefaultTemplateChildren(), box = _getDefaultTemplateCh2.box, content = _getDefaultTemplateCh2.content;
                setTransitionDuration([
                    box,
                    content
                ], 0);
            }
            onFirstUpdate = function onFirstUpdate2() {
                var _instance$popperInsta2;
                if (!instance.state.isVisible || ignoreOnFirstUpdate) return;
                ignoreOnFirstUpdate = true;
                popper.offsetHeight;
                popper.style.transition = instance.props.moveTransition;
                if (getIsDefaultRenderFn() && instance.props.animation) {
                    var _getDefaultTemplateCh3 = getDefaultTemplateChildren(), _box = _getDefaultTemplateCh3.box, _content = _getDefaultTemplateCh3.content;
                    setTransitionDuration([
                        _box,
                        _content
                    ], duration);
                    setVisibilityState([
                        _box,
                        _content
                    ], "visible");
                }
                handleAriaContentAttribute();
                handleAriaExpandedAttribute();
                pushIfUnique(mountedInstances, instance);
                (_instance$popperInsta2 = instance.popperInstance) == null || _instance$popperInsta2.forceUpdate();
                instance.state.isMounted = true;
                invokeHook("onMount", [
                    instance
                ]);
                if (instance.props.animation && getIsDefaultRenderFn()) onTransitionedIn(duration, function() {
                    instance.state.isShown = true;
                    invokeHook("onShown", [
                        instance
                    ]);
                });
            };
            mount();
        }
        function hide() {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("hide"));
            var isAlreadyHidden = !instance.state.isVisible;
            var isDestroyed = instance.state.isDestroyed;
            var isDisabled = !instance.state.isEnabled;
            var duration = getValueAtIndexOrReturn(instance.props.duration, 1, defaultProps.duration);
            if (isAlreadyHidden || isDestroyed || isDisabled) return;
            invokeHook("onHide", [
                instance
            ], false);
            if (instance.props.onHide(instance) === false) return;
            instance.state.isVisible = false;
            instance.state.isShown = false;
            ignoreOnFirstUpdate = false;
            isVisibleFromClick = false;
            if (getIsDefaultRenderFn()) popper.style.visibility = "hidden";
            cleanupInteractiveMouseListeners();
            removeDocumentPress();
            handleStyles();
            if (getIsDefaultRenderFn()) {
                var _getDefaultTemplateCh4 = getDefaultTemplateChildren(), box = _getDefaultTemplateCh4.box, content = _getDefaultTemplateCh4.content;
                if (instance.props.animation) {
                    setTransitionDuration([
                        box,
                        content
                    ], duration);
                    setVisibilityState([
                        box,
                        content
                    ], "hidden");
                }
            }
            handleAriaContentAttribute();
            handleAriaExpandedAttribute();
            if (instance.props.animation) {
                if (getIsDefaultRenderFn()) onTransitionedOut(duration, instance.unmount);
            } else instance.unmount();
        }
        function hideWithInteractivity(event) {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("hideWithInteractivity"));
            getDocument().addEventListener("mousemove", debouncedOnMouseMove);
            pushIfUnique(mouseMoveListeners, debouncedOnMouseMove);
            debouncedOnMouseMove(event);
        }
        function unmount() {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("unmount"));
            if (instance.state.isVisible) instance.hide();
            if (!instance.state.isMounted) return;
            destroyPopperInstance();
            getNestedPopperTree().forEach(function(nestedPopper) {
                nestedPopper._tippy.unmount();
            });
            if (popper.parentNode) popper.parentNode.removeChild(popper);
            mountedInstances = mountedInstances.filter(function(i) {
                return i !== instance;
            });
            instance.state.isMounted = false;
            invokeHook("onHidden", [
                instance
            ]);
        }
        function destroy() {
            warnWhen(instance.state.isDestroyed, createMemoryLeakWarning("destroy"));
            if (instance.state.isDestroyed) return;
            instance.clearDelayTimeouts();
            instance.unmount();
            removeListeners();
            delete reference._tippy;
            instance.state.isDestroyed = true;
            invokeHook("onDestroy", [
                instance
            ]);
        }
    }
    function tippy2(targets, optionalProps) {
        if (optionalProps === void 0) optionalProps = {};
        var plugins = defaultProps.plugins.concat(optionalProps.plugins || []);
        validateTargets(targets);
        validateProps(optionalProps, plugins);
        bindGlobalEventListeners();
        var passedProps = Object.assign({}, optionalProps, {
            plugins: plugins
        });
        var elements = getArrayOfElements(targets);
        var isSingleContentElement = isElement(passedProps.content);
        var isMoreThanOneReferenceElement = elements.length > 1;
        warnWhen(isSingleContentElement && isMoreThanOneReferenceElement, [
            "tippy() was passed an Element as the `content` prop, but more than",
            "one tippy instance was created by this invocation. This means the",
            "content element will only be appended to the last tippy instance.",
            "\n\n",
            "Instead, pass the .innerHTML of the element, or use a function that",
            "returns a cloned version of the element instead.",
            "\n\n",
            "1) content: element.innerHTML\n",
            "2) content: () => element.cloneNode(true)"
        ].join(" "));
        var instances = elements.reduce(function(acc, reference) {
            var instance = reference && createTippy(reference, passedProps);
            if (instance) acc.push(instance);
            return acc;
        }, []);
        return isElement(targets) ? instances[0] : instances;
    }
    tippy2.defaultProps = defaultProps;
    tippy2.setDefaultProps = setDefaultProps;
    tippy2.currentInput = currentInput;
    var hideAll = function hideAll2(_temp) {
        var _ref = _temp === void 0 ? {} : _temp, excludedReferenceOrInstance = _ref.exclude, duration = _ref.duration;
        mountedInstances.forEach(function(instance) {
            var isExcluded = false;
            if (excludedReferenceOrInstance) isExcluded = isReferenceElement(excludedReferenceOrInstance) ? instance.reference === excludedReferenceOrInstance : instance.popper === excludedReferenceOrInstance.popper;
            if (!isExcluded) {
                var originalDuration = instance.props.duration;
                instance.setProps({
                    duration: duration
                });
                instance.hide();
                if (!instance.state.isDestroyed) instance.setProps({
                    duration: originalDuration
                });
            }
        });
    };
    var applyStylesModifier = Object.assign({}, core.applyStyles, {
        effect: function effect(_ref) {
            var state = _ref.state;
            var initialStyles = {
                popper: {
                    position: state.options.strategy,
                    left: "0",
                    top: "0",
                    margin: "0"
                },
                arrow: {
                    position: "absolute"
                },
                reference: {}
            };
            Object.assign(state.elements.popper.style, initialStyles.popper);
            state.styles = initialStyles;
            if (state.elements.arrow) Object.assign(state.elements.arrow.style, initialStyles.arrow);
        }
    });
    var createSingleton = function createSingleton2(tippyInstances, optionalProps) {
        var _optionalProps$popper;
        if (optionalProps === void 0) optionalProps = {};
        errorWhen(!Array.isArray(tippyInstances), [
            "The first argument passed to createSingleton() must be an array of",
            "tippy instances. The passed value was",
            String(tippyInstances)
        ].join(" "));
        var individualInstances = tippyInstances;
        var references = [];
        var currentTarget;
        var overrides = optionalProps.overrides;
        var interceptSetPropsCleanups = [];
        var shownOnCreate = false;
        function setReferences() {
            references = individualInstances.map(function(instance) {
                return instance.reference;
            });
        }
        function enableInstances(isEnabled) {
            individualInstances.forEach(function(instance) {
                if (isEnabled) instance.enable();
                else instance.disable();
            });
        }
        function interceptSetProps(singleton2) {
            return individualInstances.map(function(instance) {
                var originalSetProps2 = instance.setProps;
                instance.setProps = function(props) {
                    originalSetProps2(props);
                    if (instance.reference === currentTarget) singleton2.setProps(props);
                };
                return function() {
                    instance.setProps = originalSetProps2;
                };
            });
        }
        function prepareInstance(singleton2, target) {
            var index = references.indexOf(target);
            if (target === currentTarget) return;
            currentTarget = target;
            var overrideProps = (overrides || []).concat("content").reduce(function(acc, prop) {
                acc[prop] = individualInstances[index].props[prop];
                return acc;
            }, {});
            singleton2.setProps(Object.assign({}, overrideProps, {
                getReferenceClientRect: typeof overrideProps.getReferenceClientRect === "function" ? overrideProps.getReferenceClientRect : function() {
                    return target.getBoundingClientRect();
                }
            }));
        }
        enableInstances(false);
        setReferences();
        var plugin = {
            fn: function fn() {
                return {
                    onDestroy: function onDestroy() {
                        enableInstances(true);
                    },
                    onHidden: function onHidden() {
                        currentTarget = null;
                    },
                    onClickOutside: function onClickOutside(instance) {
                        if (instance.props.showOnCreate && !shownOnCreate) {
                            shownOnCreate = true;
                            currentTarget = null;
                        }
                    },
                    onShow: function onShow(instance) {
                        if (instance.props.showOnCreate && !shownOnCreate) {
                            shownOnCreate = true;
                            prepareInstance(instance, references[0]);
                        }
                    },
                    onTrigger: function onTrigger(instance, event) {
                        prepareInstance(instance, event.currentTarget);
                    }
                };
            }
        };
        var singleton = tippy2(div(), Object.assign({}, removeProperties(optionalProps, [
            "overrides"
        ]), {
            plugins: [
                plugin
            ].concat(optionalProps.plugins || []),
            triggerTarget: references,
            popperOptions: Object.assign({}, optionalProps.popperOptions, {
                modifiers: [].concat(((_optionalProps$popper = optionalProps.popperOptions) == null ? void 0 : _optionalProps$popper.modifiers) || [], [
                    applyStylesModifier
                ])
            })
        }));
        var originalShow = singleton.show;
        singleton.show = function(target) {
            originalShow();
            if (!currentTarget && target == null) return prepareInstance(singleton, references[0]);
            if (currentTarget && target == null) return;
            if (typeof target === "number") return references[target] && prepareInstance(singleton, references[target]);
            if (individualInstances.includes(target)) {
                var ref = target.reference;
                return prepareInstance(singleton, ref);
            }
            if (references.includes(target)) return prepareInstance(singleton, target);
        };
        singleton.showNext = function() {
            var first = references[0];
            if (!currentTarget) return singleton.show(0);
            var index = references.indexOf(currentTarget);
            singleton.show(references[index + 1] || first);
        };
        singleton.showPrevious = function() {
            var last = references[references.length - 1];
            if (!currentTarget) return singleton.show(last);
            var index = references.indexOf(currentTarget);
            var target = references[index - 1] || last;
            singleton.show(target);
        };
        var originalSetProps = singleton.setProps;
        singleton.setProps = function(props) {
            overrides = props.overrides || overrides;
            originalSetProps(props);
        };
        singleton.setInstances = function(nextInstances) {
            enableInstances(true);
            interceptSetPropsCleanups.forEach(function(fn) {
                return fn();
            });
            individualInstances = nextInstances;
            enableInstances(false);
            setReferences();
            interceptSetProps(singleton);
            singleton.setProps({
                triggerTarget: references
            });
        };
        interceptSetPropsCleanups = interceptSetProps(singleton);
        return singleton;
    };
    var BUBBLING_EVENTS_MAP = {
        mouseover: "mouseenter",
        focusin: "focus",
        click: "click"
    };
    function delegate(targets, props) {
        errorWhen(!(props && props.target), [
            "You must specity a `target` prop indicating a CSS selector string matching",
            "the target elements that should receive a tippy."
        ].join(" "));
        var listeners = [];
        var childTippyInstances = [];
        var disabled = false;
        var target = props.target;
        var nativeProps = removeProperties(props, [
            "target"
        ]);
        var parentProps = Object.assign({}, nativeProps, {
            trigger: "manual",
            touch: false
        });
        var childProps = Object.assign({}, nativeProps, {
            showOnCreate: true
        });
        var returnValue = tippy2(targets, parentProps);
        var normalizedReturnValue = normalizeToArray(returnValue);
        function onTrigger(event) {
            if (!event.target || disabled) return;
            var targetNode = event.target.closest(target);
            if (!targetNode) return;
            var trigger = targetNode.getAttribute("data-tippy-trigger") || props.trigger || defaultProps.trigger;
            if (targetNode._tippy) return;
            if (event.type === "touchstart" && typeof childProps.touch === "boolean") return;
            if (event.type !== "touchstart" && trigger.indexOf(BUBBLING_EVENTS_MAP[event.type]) < 0) return;
            var instance = tippy2(targetNode, childProps);
            if (instance) childTippyInstances = childTippyInstances.concat(instance);
        }
        function on(node, eventType, handler, options) {
            if (options === void 0) options = false;
            node.addEventListener(eventType, handler, options);
            listeners.push({
                node: node,
                eventType: eventType,
                handler: handler,
                options: options
            });
        }
        function addEventListeners(instance) {
            var reference = instance.reference;
            on(reference, "touchstart", onTrigger, TOUCH_OPTIONS);
            on(reference, "mouseover", onTrigger);
            on(reference, "focusin", onTrigger);
            on(reference, "click", onTrigger);
        }
        function removeEventListeners() {
            listeners.forEach(function(_ref) {
                var node = _ref.node, eventType = _ref.eventType, handler = _ref.handler, options = _ref.options;
                node.removeEventListener(eventType, handler, options);
            });
            listeners = [];
        }
        function applyMutations(instance) {
            var originalDestroy = instance.destroy;
            var originalEnable = instance.enable;
            var originalDisable = instance.disable;
            instance.destroy = function(shouldDestroyChildInstances) {
                if (shouldDestroyChildInstances === void 0) shouldDestroyChildInstances = true;
                if (shouldDestroyChildInstances) childTippyInstances.forEach(function(instance2) {
                    instance2.destroy();
                });
                childTippyInstances = [];
                removeEventListeners();
                originalDestroy();
            };
            instance.enable = function() {
                originalEnable();
                childTippyInstances.forEach(function(instance2) {
                    return instance2.enable();
                });
                disabled = false;
            };
            instance.disable = function() {
                originalDisable();
                childTippyInstances.forEach(function(instance2) {
                    return instance2.disable();
                });
                disabled = true;
            };
            addEventListeners(instance);
        }
        normalizedReturnValue.forEach(applyMutations);
        return returnValue;
    }
    var animateFill = {
        name: "animateFill",
        defaultValue: false,
        fn: function fn(instance) {
            var _instance$props$rende;
            if (!((_instance$props$rende = instance.props.render) == null ? void 0 : _instance$props$rende.$$tippy)) {
                errorWhen(instance.props.animateFill, "The `animateFill` plugin requires the default render function.");
                return {};
            }
            var _getChildren = getChildren(instance.popper), box = _getChildren.box, content = _getChildren.content;
            var backdrop = instance.props.animateFill ? createBackdropElement() : null;
            return {
                onCreate: function onCreate() {
                    if (backdrop) {
                        box.insertBefore(backdrop, box.firstElementChild);
                        box.setAttribute("data-animatefill", "");
                        box.style.overflow = "hidden";
                        instance.setProps({
                            arrow: false,
                            animation: "shift-away"
                        });
                    }
                },
                onMount: function onMount() {
                    if (backdrop) {
                        var transitionDuration = box.style.transitionDuration;
                        var duration = Number(transitionDuration.replace("ms", ""));
                        content.style.transitionDelay = Math.round(duration / 10) + "ms";
                        backdrop.style.transitionDuration = transitionDuration;
                        setVisibilityState([
                            backdrop
                        ], "visible");
                    }
                },
                onShow: function onShow() {
                    if (backdrop) backdrop.style.transitionDuration = "0ms";
                },
                onHide: function onHide() {
                    if (backdrop) setVisibilityState([
                        backdrop
                    ], "hidden");
                }
            };
        }
    };
    function createBackdropElement() {
        var backdrop = div();
        backdrop.className = BACKDROP_CLASS;
        setVisibilityState([
            backdrop
        ], "hidden");
        return backdrop;
    }
    var mouseCoords = {
        clientX: 0,
        clientY: 0
    };
    var activeInstances = [];
    function storeMouseCoords(_ref) {
        var clientX = _ref.clientX, clientY = _ref.clientY;
        mouseCoords = {
            clientX: clientX,
            clientY: clientY
        };
    }
    function addMouseCoordsListener(doc) {
        doc.addEventListener("mousemove", storeMouseCoords);
    }
    function removeMouseCoordsListener(doc) {
        doc.removeEventListener("mousemove", storeMouseCoords);
    }
    var followCursor2 = {
        name: "followCursor",
        defaultValue: false,
        fn: function fn(instance) {
            var reference = instance.reference;
            var doc = getOwnerDocument(instance.props.triggerTarget || reference);
            var isInternalUpdate = false;
            var wasFocusEvent = false;
            var isUnmounted = true;
            var prevProps = instance.props;
            function getIsInitialBehavior() {
                return instance.props.followCursor === "initial" && instance.state.isVisible;
            }
            function addListener() {
                doc.addEventListener("mousemove", onMouseMove);
            }
            function removeListener() {
                doc.removeEventListener("mousemove", onMouseMove);
            }
            function unsetGetReferenceClientRect() {
                isInternalUpdate = true;
                instance.setProps({
                    getReferenceClientRect: null
                });
                isInternalUpdate = false;
            }
            function onMouseMove(event) {
                var isCursorOverReference = event.target ? reference.contains(event.target) : true;
                var followCursor3 = instance.props.followCursor;
                var clientX = event.clientX, clientY = event.clientY;
                var rect = reference.getBoundingClientRect();
                var relativeX = clientX - rect.left;
                var relativeY = clientY - rect.top;
                if (isCursorOverReference || !instance.props.interactive) instance.setProps({
                    getReferenceClientRect: function getReferenceClientRect() {
                        var rect2 = reference.getBoundingClientRect();
                        var x = clientX;
                        var y = clientY;
                        if (followCursor3 === "initial") {
                            x = rect2.left + relativeX;
                            y = rect2.top + relativeY;
                        }
                        var top = followCursor3 === "horizontal" ? rect2.top : y;
                        var right = followCursor3 === "vertical" ? rect2.right : x;
                        var bottom = followCursor3 === "horizontal" ? rect2.bottom : y;
                        var left = followCursor3 === "vertical" ? rect2.left : x;
                        return {
                            width: right - left,
                            height: bottom - top,
                            top: top,
                            right: right,
                            bottom: bottom,
                            left: left
                        };
                    }
                });
            }
            function create() {
                if (instance.props.followCursor) {
                    activeInstances.push({
                        instance: instance,
                        doc: doc
                    });
                    addMouseCoordsListener(doc);
                }
            }
            function destroy() {
                activeInstances = activeInstances.filter(function(data) {
                    return data.instance !== instance;
                });
                if (activeInstances.filter(function(data) {
                    return data.doc === doc;
                }).length === 0) removeMouseCoordsListener(doc);
            }
            return {
                onCreate: create,
                onDestroy: destroy,
                onBeforeUpdate: function onBeforeUpdate() {
                    prevProps = instance.props;
                },
                onAfterUpdate: function onAfterUpdate(_, _ref2) {
                    var followCursor3 = _ref2.followCursor;
                    if (isInternalUpdate) return;
                    if (followCursor3 !== void 0 && prevProps.followCursor !== followCursor3) {
                        destroy();
                        if (followCursor3) {
                            create();
                            if (instance.state.isMounted && !wasFocusEvent && !getIsInitialBehavior()) addListener();
                        } else {
                            removeListener();
                            unsetGetReferenceClientRect();
                        }
                    }
                },
                onMount: function onMount() {
                    if (instance.props.followCursor && !wasFocusEvent) {
                        if (isUnmounted) {
                            onMouseMove(mouseCoords);
                            isUnmounted = false;
                        }
                        if (!getIsInitialBehavior()) addListener();
                    }
                },
                onTrigger: function onTrigger(_, event) {
                    if (isMouseEvent(event)) mouseCoords = {
                        clientX: event.clientX,
                        clientY: event.clientY
                    };
                    wasFocusEvent = event.type === "focus";
                },
                onHidden: function onHidden() {
                    if (instance.props.followCursor) {
                        unsetGetReferenceClientRect();
                        removeListener();
                        isUnmounted = true;
                    }
                }
            };
        }
    };
    function getProps(props, modifier) {
        var _props$popperOptions;
        return {
            popperOptions: Object.assign({}, props.popperOptions, {
                modifiers: [].concat((((_props$popperOptions = props.popperOptions) == null ? void 0 : _props$popperOptions.modifiers) || []).filter(function(_ref) {
                    var name = _ref.name;
                    return name !== modifier.name;
                }), [
                    modifier
                ])
            })
        };
    }
    var inlinePositioning = {
        name: "inlinePositioning",
        defaultValue: false,
        fn: function fn(instance) {
            var reference = instance.reference;
            function isEnabled() {
                return !!instance.props.inlinePositioning;
            }
            var placement;
            var cursorRectIndex = -1;
            var isInternalUpdate = false;
            var modifier = {
                name: "tippyInlinePositioning",
                enabled: true,
                phase: "afterWrite",
                fn: function fn2(_ref2) {
                    var state = _ref2.state;
                    if (isEnabled()) {
                        if (placement !== state.placement) instance.setProps({
                            getReferenceClientRect: function getReferenceClientRect() {
                                return _getReferenceClientRect(state.placement);
                            }
                        });
                        placement = state.placement;
                    }
                }
            };
            function _getReferenceClientRect(placement2) {
                return getInlineBoundingClientRect(getBasePlacement(placement2), reference.getBoundingClientRect(), arrayFrom(reference.getClientRects()), cursorRectIndex);
            }
            function setInternalProps(partialProps) {
                isInternalUpdate = true;
                instance.setProps(partialProps);
                isInternalUpdate = false;
            }
            function addModifier() {
                if (!isInternalUpdate) setInternalProps(getProps(instance.props, modifier));
            }
            return {
                onCreate: addModifier,
                onAfterUpdate: addModifier,
                onTrigger: function onTrigger(_, event) {
                    if (isMouseEvent(event)) {
                        var rects = arrayFrom(instance.reference.getClientRects());
                        var cursorRect = rects.find(function(rect) {
                            return rect.left - 2 <= event.clientX && rect.right + 2 >= event.clientX && rect.top - 2 <= event.clientY && rect.bottom + 2 >= event.clientY;
                        });
                        cursorRectIndex = rects.indexOf(cursorRect);
                    }
                },
                onUntrigger: function onUntrigger() {
                    cursorRectIndex = -1;
                }
            };
        }
    };
    function getInlineBoundingClientRect(currentBasePlacement, boundingRect, clientRects, cursorRectIndex) {
        if (clientRects.length < 2 || currentBasePlacement === null) return boundingRect;
        if (clientRects.length === 2 && cursorRectIndex >= 0 && clientRects[0].left > clientRects[1].right) return clientRects[cursorRectIndex] || boundingRect;
        switch(currentBasePlacement){
            case "top":
            case "bottom":
                var firstRect = clientRects[0];
                var lastRect = clientRects[clientRects.length - 1];
                var isTop = currentBasePlacement === "top";
                var top = firstRect.top;
                var bottom = lastRect.bottom;
                var left = isTop ? firstRect.left : lastRect.left;
                var right = isTop ? firstRect.right : lastRect.right;
                var width = right - left;
                var height = bottom - top;
                return {
                    top: top,
                    bottom: bottom,
                    left: left,
                    right: right,
                    width: width,
                    height: height
                };
            case "left":
            case "right":
                var minLeft = Math.min.apply(Math, clientRects.map(function(rects) {
                    return rects.left;
                }));
                var maxRight = Math.max.apply(Math, clientRects.map(function(rects) {
                    return rects.right;
                }));
                var measureRects = clientRects.filter(function(rect) {
                    return currentBasePlacement === "left" ? rect.left === minLeft : rect.right === maxRight;
                });
                var _top = measureRects[0].top;
                var _bottom = measureRects[measureRects.length - 1].bottom;
                var _left = minLeft;
                var _right = maxRight;
                var _width = _right - _left;
                var _height = _bottom - _top;
                return {
                    top: _top,
                    bottom: _bottom,
                    left: _left,
                    right: _right,
                    width: _width,
                    height: _height
                };
            default:
                return boundingRect;
        }
    }
    var sticky = {
        name: "sticky",
        defaultValue: false,
        fn: function fn(instance) {
            var reference = instance.reference, popper = instance.popper;
            function getReference() {
                return instance.popperInstance ? instance.popperInstance.state.elements.reference : reference;
            }
            function shouldCheck(value) {
                return instance.props.sticky === true || instance.props.sticky === value;
            }
            var prevRefRect = null;
            var prevPopRect = null;
            function updatePosition() {
                var currentRefRect = shouldCheck("reference") ? getReference().getBoundingClientRect() : null;
                var currentPopRect = shouldCheck("popper") ? popper.getBoundingClientRect() : null;
                if (currentRefRect && areRectsDifferent(prevRefRect, currentRefRect) || currentPopRect && areRectsDifferent(prevPopRect, currentPopRect)) {
                    if (instance.popperInstance) instance.popperInstance.update();
                }
                prevRefRect = currentRefRect;
                prevPopRect = currentPopRect;
                if (instance.state.isMounted) requestAnimationFrame(updatePosition);
            }
            return {
                onMount: function onMount() {
                    if (instance.props.sticky) updatePosition();
                }
            };
        }
    };
    function areRectsDifferent(rectA, rectB) {
        if (rectA && rectB) return rectA.top !== rectB.top || rectA.right !== rectB.right || rectA.bottom !== rectB.bottom || rectA.left !== rectB.left;
        return true;
    }
    tippy2.setDefaultProps({
        render: render
    });
    exports.animateFill = animateFill;
    exports.createSingleton = createSingleton;
    exports.default = tippy2;
    exports.delegate = delegate;
    exports.followCursor = followCursor2;
    exports.hideAll = hideAll;
    exports.inlinePositioning = inlinePositioning;
    exports.roundArrow = ROUND_ARROW;
    exports.sticky = sticky;
});
// src/index.js
var $69a8ec8dbeef3157$var$import_tippy2 = $69a8ec8dbeef3157$var$__toModule($69a8ec8dbeef3157$var$require_tippy_cjs());
// src/buildConfigFromModifiers.js
var $69a8ec8dbeef3157$var$import_tippy = $69a8ec8dbeef3157$var$__toModule($69a8ec8dbeef3157$var$require_tippy_cjs());
var $69a8ec8dbeef3157$var$buildConfigFromModifiers = (modifiers)=>{
    const config = {
        plugins: []
    };
    const getModifierArgument = (modifier)=>{
        return modifiers[modifiers.indexOf(modifier) + 1];
    };
    if (modifiers.includes("animation")) config.animation = getModifierArgument("animation");
    if (modifiers.includes("duration")) config.duration = parseInt(getModifierArgument("duration"));
    if (modifiers.includes("delay")) {
        const delay = getModifierArgument("delay");
        config.delay = delay.includes("-") ? delay.split("-").map((n)=>parseInt(n)) : parseInt(delay);
    }
    if (modifiers.includes("cursor")) {
        config.plugins.push($69a8ec8dbeef3157$var$import_tippy.followCursor);
        const next = getModifierArgument("cursor");
        if ([
            "x",
            "initial"
        ].includes(next)) config.followCursor = next === "x" ? "horizontal" : "initial";
        else config.followCursor = true;
    }
    if (modifiers.includes("on")) config.trigger = getModifierArgument("on");
    if (modifiers.includes("arrowless")) config.arrow = false;
    if (modifiers.includes("html")) config.allowHTML = true;
    if (modifiers.includes("interactive")) config.interactive = true;
    if (modifiers.includes("border") && config.interactive) config.interactiveBorder = parseInt(getModifierArgument("border"));
    if (modifiers.includes("debounce") && config.interactive) config.interactiveDebounce = parseInt(getModifierArgument("debounce"));
    if (modifiers.includes("max-width")) config.maxWidth = parseInt(getModifierArgument("max-width"));
    if (modifiers.includes("theme")) config.theme = getModifierArgument("theme");
    if (modifiers.includes("placement")) config.placement = getModifierArgument("placement");
    const popperOptions = {};
    if (modifiers.includes("no-flip")) {
        popperOptions.modifiers ||= [];
        popperOptions.modifiers.push({
            name: "flip",
            enabled: false
        });
    }
    config.popperOptions = popperOptions;
    return config;
};
// src/index.js
function $69a8ec8dbeef3157$var$Tooltip(Alpine) {
    Alpine.magic("tooltip", (el)=>{
        return (content, config = {})=>{
            const timeout = config.timeout;
            delete config.timeout;
            const instance = (0, $69a8ec8dbeef3157$var$import_tippy2.default)(el, {
                content: content,
                trigger: "manual",
                ...config
            });
            instance.show();
            setTimeout(()=>{
                instance.hide();
                setTimeout(()=>instance.destroy(), config.duration || 300);
            }, timeout || 2e3);
        };
    });
    Alpine.directive("tooltip", (el, { modifiers: modifiers, expression: expression }, { evaluateLater: evaluateLater, effect: effect, cleanup: cleanup })=>{
        const config = modifiers.length > 0 ? $69a8ec8dbeef3157$var$buildConfigFromModifiers(modifiers) : {};
        if (!el.__x_tippy) el.__x_tippy = (0, $69a8ec8dbeef3157$var$import_tippy2.default)(el, config);
        cleanup(()=>{
            if (el.__x_tippy) {
                el.__x_tippy.destroy();
                delete el.__x_tippy;
            }
        });
        const enableTooltip = ()=>el.__x_tippy.enable();
        const disableTooltip = ()=>el.__x_tippy.disable();
        const setupTooltip = (content)=>{
            if (!content) disableTooltip();
            else {
                enableTooltip();
                el.__x_tippy.setContent(content);
            }
        };
        if (modifiers.includes("raw")) setupTooltip(expression);
        else {
            const getContent = evaluateLater(expression);
            effect(()=>{
                getContent((content)=>{
                    if (typeof content === "object") {
                        el.__x_tippy.setProps(content);
                        enableTooltip();
                    } else setupTooltip(content);
                });
            });
        }
    });
}
$69a8ec8dbeef3157$var$Tooltip.defaultProps = (props)=>{
    $69a8ec8dbeef3157$var$import_tippy2.default.setDefaultProps(props);
    return $69a8ec8dbeef3157$var$Tooltip;
};
var $69a8ec8dbeef3157$var$src_default = $69a8ec8dbeef3157$var$Tooltip;
// builds/module.js
var $69a8ec8dbeef3157$export$2e2bcd8739ae039 = $69a8ec8dbeef3157$var$src_default;


var $5267f0d63de538ba$exports = {};
/*
* loglevel - https://github.com/pimterry/loglevel
*
* Copyright (c) 2013 Tim Perry
* Licensed under the MIT license.
*/ (function(root, definition) {
    "use strict";
    if (typeof define === 'function' && define.amd) define(definition);
    else if ($5267f0d63de538ba$exports) $5267f0d63de538ba$exports = definition();
    else root.log = definition();
})($5267f0d63de538ba$exports, function() {
    "use strict";
    // Slightly dubious tricks to cut down minimized file size
    var noop = function() {};
    var undefinedType = "undefined";
    var isIE = typeof window !== undefinedType && typeof window.navigator !== undefinedType && /Trident\/|MSIE /.test(window.navigator.userAgent);
    var logMethods = [
        "trace",
        "debug",
        "info",
        "warn",
        "error"
    ];
    var _loggersByName = {};
    var defaultLogger = null;
    // Cross-browser bind equivalent that works at least back to IE6
    function bindMethod(obj, methodName) {
        var method = obj[methodName];
        if (typeof method.bind === 'function') return method.bind(obj);
        else try {
            return Function.prototype.bind.call(method, obj);
        } catch (e) {
            // Missing bind shim or IE8 + Modernizr, fallback to wrapping
            return function() {
                return Function.prototype.apply.apply(method, [
                    obj,
                    arguments
                ]);
            };
        }
    }
    // Trace() doesn't print the message in IE, so for that case we need to wrap it
    function traceForIE() {
        if (console.log) {
            if (console.log.apply) console.log.apply(console, arguments);
            else // In old IE, native console methods themselves don't have apply().
            Function.prototype.apply.apply(console.log, [
                console,
                arguments
            ]);
        }
        if (console.trace) console.trace();
    }
    // Build the best logging method possible for this env
    // Wherever possible we want to bind, not wrap, to preserve stack traces
    function realMethod(methodName) {
        if (methodName === 'debug') methodName = 'log';
        if (typeof console === undefinedType) return false; // No method possible, for now - fixed later by enableLoggingWhenConsoleArrives
        else if (methodName === 'trace' && isIE) return traceForIE;
        else if (console[methodName] !== undefined) return bindMethod(console, methodName);
        else if (console.log !== undefined) return bindMethod(console, 'log');
        else return noop;
    }
    // These private functions always need `this` to be set properly
    function replaceLoggingMethods() {
        /*jshint validthis:true */ var level = this.getLevel();
        // Replace the actual methods.
        for(var i = 0; i < logMethods.length; i++){
            var methodName = logMethods[i];
            this[methodName] = i < level ? noop : this.methodFactory(methodName, level, this.name);
        }
        // Define log.log as an alias for log.debug
        this.log = this.debug;
        // Return any important warnings.
        if (typeof console === undefinedType && level < this.levels.SILENT) return "No console available for logging";
    }
    // In old IE versions, the console isn't present until you first open it.
    // We build realMethod() replacements here that regenerate logging methods
    function enableLoggingWhenConsoleArrives(methodName) {
        return function() {
            if (typeof console !== undefinedType) {
                replaceLoggingMethods.call(this);
                this[methodName].apply(this, arguments);
            }
        };
    }
    // By default, we use closely bound real methods wherever possible, and
    // otherwise we wait for a console to appear, and then try again.
    function defaultMethodFactory(methodName, _level, _loggerName) {
        /*jshint validthis:true */ return realMethod(methodName) || enableLoggingWhenConsoleArrives.apply(this, arguments);
    }
    function Logger(name, factory) {
        // Private instance variables.
        var self = this;
        /**
       * The level inherited from a parent logger (or a global default). We
       * cache this here rather than delegating to the parent so that it stays
       * in sync with the actual logging methods that we have installed (the
       * parent could change levels but we might not have rebuilt the loggers
       * in this child yet).
       * @type {number}
       */ var inheritedLevel;
        /**
       * The default level for this logger, if any. If set, this overrides
       * `inheritedLevel`.
       * @type {number|null}
       */ var defaultLevel;
        /**
       * A user-specific level for this logger. If set, this overrides
       * `defaultLevel`.
       * @type {number|null}
       */ var userLevel;
        var storageKey = "loglevel";
        if (typeof name === "string") storageKey += ":" + name;
        else if (typeof name === "symbol") storageKey = undefined;
        function persistLevelIfPossible(levelNum) {
            var levelName = (logMethods[levelNum] || 'silent').toUpperCase();
            if (typeof window === undefinedType || !storageKey) return;
            // Use localStorage if available
            try {
                window.localStorage[storageKey] = levelName;
                return;
            } catch (ignore) {}
            // Use session cookie as fallback
            try {
                window.document.cookie = encodeURIComponent(storageKey) + "=" + levelName + ";";
            } catch (ignore) {}
        }
        function getPersistedLevel() {
            var storedLevel;
            if (typeof window === undefinedType || !storageKey) return;
            try {
                storedLevel = window.localStorage[storageKey];
            } catch (ignore) {}
            // Fallback to cookies if local storage gives us nothing
            if (typeof storedLevel === undefinedType) try {
                var cookie = window.document.cookie;
                var cookieName = encodeURIComponent(storageKey);
                var location = cookie.indexOf(cookieName + "=");
                if (location !== -1) storedLevel = /^([^;]+)/.exec(cookie.slice(location + cookieName.length + 1))[1];
            } catch (ignore) {}
            // If the stored level is not valid, treat it as if nothing was stored.
            if (self.levels[storedLevel] === undefined) storedLevel = undefined;
            return storedLevel;
        }
        function clearPersistedLevel() {
            if (typeof window === undefinedType || !storageKey) return;
            // Use localStorage if available
            try {
                window.localStorage.removeItem(storageKey);
            } catch (ignore) {}
            // Use session cookie as fallback
            try {
                window.document.cookie = encodeURIComponent(storageKey) + "=; expires=Thu, 01 Jan 1970 00:00:00 UTC";
            } catch (ignore) {}
        }
        function normalizeLevel(input) {
            var level = input;
            if (typeof level === "string" && self.levels[level.toUpperCase()] !== undefined) level = self.levels[level.toUpperCase()];
            if (typeof level === "number" && level >= 0 && level <= self.levels.SILENT) return level;
            else throw new TypeError("log.setLevel() called with invalid level: " + input);
        }
        /*
       *
       * Public logger API - see https://github.com/pimterry/loglevel for details
       *
       */ self.name = name;
        self.levels = {
            "TRACE": 0,
            "DEBUG": 1,
            "INFO": 2,
            "WARN": 3,
            "ERROR": 4,
            "SILENT": 5
        };
        self.methodFactory = factory || defaultMethodFactory;
        self.getLevel = function() {
            if (userLevel != null) return userLevel;
            else if (defaultLevel != null) return defaultLevel;
            else return inheritedLevel;
        };
        self.setLevel = function(level, persist) {
            userLevel = normalizeLevel(level);
            if (persist !== false) persistLevelIfPossible(userLevel);
            // NOTE: in v2, this should call rebuild(), which updates children.
            return replaceLoggingMethods.call(self);
        };
        self.setDefaultLevel = function(level) {
            defaultLevel = normalizeLevel(level);
            if (!getPersistedLevel()) self.setLevel(level, false);
        };
        self.resetLevel = function() {
            userLevel = null;
            clearPersistedLevel();
            replaceLoggingMethods.call(self);
        };
        self.enableAll = function(persist) {
            self.setLevel(self.levels.TRACE, persist);
        };
        self.disableAll = function(persist) {
            self.setLevel(self.levels.SILENT, persist);
        };
        self.rebuild = function() {
            if (defaultLogger !== self) inheritedLevel = normalizeLevel(defaultLogger.getLevel());
            replaceLoggingMethods.call(self);
            if (defaultLogger === self) for(var childName in _loggersByName)_loggersByName[childName].rebuild();
        };
        // Initialize all the internal levels.
        inheritedLevel = normalizeLevel(defaultLogger ? defaultLogger.getLevel() : "WARN");
        var initialLevel = getPersistedLevel();
        if (initialLevel != null) userLevel = normalizeLevel(initialLevel);
        replaceLoggingMethods.call(self);
    }
    /*
     *
     * Top-level API
     *
     */ defaultLogger = new Logger();
    defaultLogger.getLogger = function getLogger(name) {
        if (typeof name !== "symbol" && typeof name !== "string" || name === "") throw new TypeError("You must supply a name when creating a logger.");
        var logger = _loggersByName[name];
        if (!logger) logger = _loggersByName[name] = new Logger(name, defaultLogger.methodFactory);
        return logger;
    };
    // Grab the current global log variable in case of overwrite
    var _log = typeof window !== undefinedType ? window.log : undefined;
    defaultLogger.noConflict = function() {
        if (typeof window !== undefinedType && window.log === defaultLogger) window.log = _log;
        return defaultLogger;
    };
    defaultLogger.getLoggers = function getLoggers() {
        return _loggersByName;
    };
    // ES6 default export, for compatibility
    defaultLogger['default'] = defaultLogger;
    return defaultLogger;
});


var $1ffebed09abdb92f$exports = {};
(function(root, factory) {
    if (typeof define === 'function' && define.amd) define(factory);
    else if ($1ffebed09abdb92f$exports) $1ffebed09abdb92f$exports = factory();
    else root.prefix = factory(root);
})($1ffebed09abdb92f$exports, function(root) {
    'use strict';
    var merge = function(target) {
        var i = 1;
        var length = arguments.length;
        var key;
        for(; i < length; i++){
            for(key in arguments[i])if (Object.prototype.hasOwnProperty.call(arguments[i], key)) target[key] = arguments[i][key];
        }
        return target;
    };
    var defaults = {
        template: '[%t] %l:',
        levelFormatter: function(level) {
            return level.toUpperCase();
        },
        nameFormatter: function(name) {
            return name || 'root';
        },
        timestampFormatter: function(date) {
            return date.toTimeString().replace(/.*(\d{2}:\d{2}:\d{2}).*/, '$1');
        },
        format: undefined
    };
    var loglevel;
    var configs = {};
    var reg = function(rootLogger) {
        if (!rootLogger || !rootLogger.getLogger) throw new TypeError('Argument is not a root logger');
        loglevel = rootLogger;
    };
    var apply = function(logger, config) {
        if (!logger || !logger.setLevel) throw new TypeError('Argument is not a logger');
        /* eslint-disable vars-on-top */ var originalFactory = logger.methodFactory;
        var name = logger.name || '';
        var parent = configs[name] || configs[''] || defaults;
        /* eslint-enable vars-on-top */ function methodFactory(methodName, logLevel, loggerName) {
            var originalMethod = originalFactory(methodName, logLevel, loggerName);
            var options = configs[loggerName] || configs[''];
            var hasTimestamp = options.template.indexOf('%t') !== -1;
            var hasLevel = options.template.indexOf('%l') !== -1;
            var hasName = options.template.indexOf('%n') !== -1;
            return function() {
                var content = '';
                var length = arguments.length;
                var args = Array(length);
                var key = 0;
                for(; key < length; key++)args[key] = arguments[key];
                // skip the root method for child loggers to prevent duplicate logic
                if (name || !configs[loggerName]) {
                    /* eslint-disable vars-on-top */ var timestamp = options.timestampFormatter(new Date());
                    var level = options.levelFormatter(methodName);
                    var lname = options.nameFormatter(loggerName);
                    /* eslint-enable vars-on-top */ if (options.format) content += options.format(level, lname, timestamp);
                    else {
                        content += options.template;
                        if (hasTimestamp) content = content.replace(/%t/, timestamp);
                        if (hasLevel) content = content.replace(/%l/, level);
                        if (hasName) content = content.replace(/%n/, lname);
                    }
                    if (args.length && typeof args[0] === 'string') // concat prefix with first argument to support string substitutions
                    args[0] = content + ' ' + args[0];
                    else args.unshift(content);
                }
                originalMethod.apply(undefined, args);
            };
        }
        if (!configs[name]) logger.methodFactory = methodFactory;
        // for remove inherited format option if template option preset
        config = config || {};
        if (config.template) config.format = undefined;
        configs[name] = merge({}, parent, config);
        logger.setLevel(logger.getLevel());
        if (!loglevel) logger.warn('It is necessary to call the function reg() of loglevel-plugin-prefix before calling apply. From the next release, it will throw an error. See more: https://github.com/kutuluk/loglevel-plugin-prefix/blob/master/README.md');
        return logger;
    };
    var api = {
        reg: reg,
        apply: apply
    };
    var save;
    if (root) {
        save = root.prefix;
        api.noConflict = function() {
            if (root.prefix === api) root.prefix = save;
            return api;
        };
    }
    return api;
});


(0, (/*@__PURE__*/$parcel$interopDefault($1ffebed09abdb92f$exports))).reg((0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))));
(0, (/*@__PURE__*/$parcel$interopDefault($1ffebed09abdb92f$exports))).apply((0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))), {
    format: (level)=>`${`[${level}]`.padStart(7)} Lookbook:`
});
let $227a3c1b2ea887ad$var$logLevel = 3;
if (window.LOG_LEVEL !== undefined) $227a3c1b2ea887ad$var$logLevel = window.LOG_LEVEL;
(0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))).setLevel($227a3c1b2ea887ad$var$logLevel);
function $227a3c1b2ea887ad$export$2e2bcd8739ae039(Alpine) {
    Alpine.directive("log", (el, { modifiers: modifiers, expression: expression }, { evaluateLater: evaluateLater, effect: effect })=>{
        let logFn = typeof expression === "string" ? (callback)=>callback(expression) : evaluateLater(expression);
        effect(()=>logFn((message)=>{
                const level = modifiers[0] || "debug";
                (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports)))[level](message);
            }));
    });
    Alpine.magic("log", ()=>{
        return 0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports));
    });
    Alpine.$log = (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports)));
}


var $f4afa2ce11c8f99d$export$2e2bcd8739ae039 = {
    desktopWidth: 768,
    wideDesktopWidth: 1200,
    sidebar: {
        defaultWidth: 280,
        minWidth: 200,
        minSectionHeight: 200
    },
    main: {
        minWidth: 200
    },
    inspector: {
        drawer: {
            defaultHeight: 300,
            defaultWidth: 500,
            minWidth: 350,
            minHeight: 200
        },
        preview: {
            minHeight: 200,
            minWidth: 200
        }
    }
};


function $7ecd1fc3a6b35e5c$export$33d4bfa367d0ee08(condition, callback) {
    const mediaQueryList = window.matchMedia(condition);
    const handleChange = (mql)=>callback(mql.matches);
    handleChange(mediaQueryList);
    mediaQueryList.addEventListener("change", (mql)=>handleChange(mql));
    return mediaQueryList;
}
function $7ecd1fc3a6b35e5c$export$a2214cc2adb2dc44(element, callback = ()=>{}) {
    const observer = new ResizeObserver((entries)=>{
        const rect = entries[0].target.getBoundingClientRect();
        callback({
            width: Math.round(rect.width),
            height: Math.round(rect.height)
        });
    });
    observer.observe(element);
    return observer;
}



function $fb8f79f7dd40b68f$export$6cb344a21ca18aec(content) {
    var txt = document.createElement("textarea");
    txt.innerHTML = content;
    return txt.value;
}
function $fb8f79f7dd40b68f$export$2ce3c33e50a76e49(string, prefix = null) {
    return prefix ? `${prefix}-${string}` : string;
}
function $fb8f79f7dd40b68f$export$f720fd0ddbeb53d9(value) {
    const json = decodeURIComponent(value);
    return JSON.parse(json);
}
function $fb8f79f7dd40b68f$export$c788aab010beeaec(data) {
    const str = JSON.stringify(data);
    return encodeURIComponent(str);
}


const { sidebar: $b8cbee737d5fb22b$var$sidebar, main: $b8cbee737d5fb22b$var$main, inspector: $b8cbee737d5fb22b$var$inspector } = (0, $f4afa2ce11c8f99d$export$2e2bcd8739ae039);
function $b8cbee737d5fb22b$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        init () {
            (0, $7ecd1fc3a6b35e5c$export$33d4bfa367d0ee08)(`(min-width: ${(0, $f4afa2ce11c8f99d$export$2e2bcd8739ae039).desktopWidth}px)`, (matches)=>{
                this._isDesktop = matches;
                (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))).debug(`Media query 'desktop': ${matches ? "\u2705 match" : "\u274C no match"}`);
            });
        },
        get desktop () {
            return this._isDesktop;
        },
        get mobile () {
            return !this.desktop;
        },
        reflowing: false,
        // Main app sidebar/content layout
        main: {
            split: Alpine.$persist({
                direction: "vertical",
                sizes: [
                    `${$b8cbee737d5fb22b$var$sidebar.defaultWidth}px`,
                    "1fr"
                ]
            }).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("main-split", prefix)),
            opts: {
                minSizes: [
                    $b8cbee737d5fb22b$var$sidebar.minWidth,
                    $b8cbee737d5fb22b$var$main.minWidth
                ]
            }
        },
        // Sidebar visibility and sections
        sidebar: {
            _hiddenDesktop: Alpine.$persist(false).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("sidebar-hidden-desktop", prefix)),
            _hiddenMobile: Alpine.$persist(true).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("sidebar-hidden-mobile", prefix)),
            set hidden (value){
                if (Alpine.store("layout").desktop) this._hiddenDesktop = value;
                else this._hiddenMobile = value;
            },
            get hidden () {
                const isDesktop = Alpine.store("layout").desktop;
                return isDesktop && this._hiddenDesktop || !isDesktop && this._hiddenMobile;
            },
            split: Alpine.$persist({
                direction: "horizontal",
                sizes: [
                    "50%",
                    "50%"
                ]
            }).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("sidebar-split", prefix)),
            opts: {
                minSizes: [
                    $b8cbee737d5fb22b$var$sidebar.minSectionHeight,
                    $b8cbee737d5fb22b$var$sidebar.minSectionHeight
                ]
            }
        },
        singleSectionSidebar: {
            split: {
                direction: "horizontal",
                sizes: null
            }
        },
        // Inspector drawer/preview layout
        inspector: {
            split: Alpine.$persist({
                direction: "horizontal",
                horizontalSizes: [
                    "1fr",
                    `${$b8cbee737d5fb22b$var$inspector.drawer.defaultHeight}px`
                ],
                verticalSizes: [
                    "1fr",
                    `${$b8cbee737d5fb22b$var$inspector.drawer.defaultWidth}px`
                ]
            }).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-split", prefix)),
            opts: {
                minVerticalSizes: [
                    $b8cbee737d5fb22b$var$inspector.drawer.minWidth,
                    $b8cbee737d5fb22b$var$inspector.drawer.minWidth
                ],
                minHorizontalSizes: [
                    $b8cbee737d5fb22b$var$inspector.drawer.minHeight,
                    $b8cbee737d5fb22b$var$inspector.drawer.minHeight
                ]
            }
        },
        // protected
        _isDesktop: true
    };
}


function $c87b0f0bca2ce26b$export$2e2bcd8739ae039(Alpine, name) {
    return {
        raw: Alpine.$persist("").as(name),
        get text () {
            return this.raw.replace(/\s/g, "").toLowerCase();
        },
        get active () {
            return this.text.length > 0;
        }
    };
}



function $44e1c947423754b0$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        previews: {
            filter: (0, $c87b0f0bca2ce26b$export$2e2bcd8739ae039)(Alpine, (0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("previews-filter-text", prefix)),
            open: Alpine.$persist([]).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("previews-nav-open", prefix))
        },
        pages: {
            filter: (0, $c87b0f0bca2ce26b$export$2e2bcd8739ae039)(Alpine, (0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("pages-filter-text", prefix)),
            open: Alpine.$persist([]).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("pages-nav-open", prefix))
        }
    };
}



function $9c7d83377882e3b9$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        minVerticalSplitWidth: 800,
        main: {
            activeTab: Alpine.$persist("").as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-main-active-tab", prefix)),
            width: Alpine.$persist("100%").as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-main-width", prefix)),
            height: Alpine.$persist("100%").as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-main-height", prefix)),
            lastWidth: null,
            lastHeight: null,
            resizing: false
        },
        drawer: {
            hidden: Alpine.$persist(false).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-drawer-hidden", prefix)),
            activeTab: Alpine.$persist("").as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("inspector-drawer-active-tab", prefix))
        }
    };
}



function $1fa236e81ee747be$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        embeds: Alpine.$persist({}).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("pages-embeds", prefix))
    };
}



function $d56ec5b1270324e7$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        showTooltips: true
    };
}




function $728fb5b231175bdb$export$2e2bcd8739ae039(Alpine, { prefix: prefix }) {
    return {
        filter: (0, $c87b0f0bca2ce26b$export$2e2bcd8739ae039)(Alpine, (0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("workbench-filter", prefix)),
        nav: {
            open: Alpine.$persist([]).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("workbench-nav-open", prefix)),
            location: {
                pathname: null
            }
        },
        horizontalSplitLayout: {
            split: Alpine.$persist({
                direction: "horizontal",
                sizes: [
                    "50%",
                    "50%"
                ]
            }).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("workbench-horizontal-split", prefix))
        },
        verticalSplitLayout: {
            split: Alpine.$persist({
                direction: "vertical",
                sizes: [
                    "40%",
                    "30%",
                    "30%"
                ]
            }).as((0, $fb8f79f7dd40b68f$export$2ce3c33e50a76e49)("workbench-vertical-split", prefix))
        },
        tabbedPanels: {
            activeTab: "tab-1"
        }
    };
}


var $7d6b1fa982d8364d$exports = {};
(function(global, factory) {
    factory($7d6b1fa982d8364d$exports);
})($7d6b1fa982d8364d$exports, function(exports1) {
    "use strict";
    var adapters = {
        logger: self.console,
        WebSocket: self.WebSocket
    };
    var logger = {
        log: function log() {
            if (this.enabled) {
                var _adapters$logger;
                for(var _len = arguments.length, messages = Array(_len), _key = 0; _key < _len; _key++)messages[_key] = arguments[_key];
                messages.push(Date.now());
                (_adapters$logger = adapters.logger).log.apply(_adapters$logger, [
                    "[ActionCable]"
                ].concat(messages));
            }
        }
    };
    var _typeof = typeof Symbol === "function" && typeof Symbol.iterator === "symbol" ? function(obj) {
        return typeof obj;
    } : function(obj) {
        return obj && typeof Symbol === "function" && obj.constructor === Symbol && obj !== Symbol.prototype ? "symbol" : typeof obj;
    };
    var classCallCheck = function(instance, Constructor) {
        if (!(instance instanceof Constructor)) throw new TypeError("Cannot call a class as a function");
    };
    var createClass = function() {
        function defineProperties(target, props) {
            for(var i = 0; i < props.length; i++){
                var descriptor = props[i];
                descriptor.enumerable = descriptor.enumerable || false;
                descriptor.configurable = true;
                if ("value" in descriptor) descriptor.writable = true;
                Object.defineProperty(target, descriptor.key, descriptor);
            }
        }
        return function(Constructor, protoProps, staticProps) {
            if (protoProps) defineProperties(Constructor.prototype, protoProps);
            if (staticProps) defineProperties(Constructor, staticProps);
            return Constructor;
        };
    }();
    var now = function now() {
        return new Date().getTime();
    };
    var secondsSince = function secondsSince(time) {
        return (now() - time) / 1e3;
    };
    var clamp = function clamp(number, min, max) {
        return Math.max(min, Math.min(max, number));
    };
    var ConnectionMonitor = function() {
        function ConnectionMonitor(connection) {
            classCallCheck(this, ConnectionMonitor);
            this.visibilityDidChange = this.visibilityDidChange.bind(this);
            this.connection = connection;
            this.reconnectAttempts = 0;
        }
        ConnectionMonitor.prototype.start = function start() {
            if (!this.isRunning()) {
                this.startedAt = now();
                delete this.stoppedAt;
                this.startPolling();
                addEventListener("visibilitychange", this.visibilityDidChange);
                logger.log("ConnectionMonitor started. pollInterval = " + this.getPollInterval() + " ms");
            }
        };
        ConnectionMonitor.prototype.stop = function stop() {
            if (this.isRunning()) {
                this.stoppedAt = now();
                this.stopPolling();
                removeEventListener("visibilitychange", this.visibilityDidChange);
                logger.log("ConnectionMonitor stopped");
            }
        };
        ConnectionMonitor.prototype.isRunning = function isRunning() {
            return this.startedAt && !this.stoppedAt;
        };
        ConnectionMonitor.prototype.recordPing = function recordPing() {
            this.pingedAt = now();
        };
        ConnectionMonitor.prototype.recordConnect = function recordConnect() {
            this.reconnectAttempts = 0;
            this.recordPing();
            delete this.disconnectedAt;
            logger.log("ConnectionMonitor recorded connect");
        };
        ConnectionMonitor.prototype.recordDisconnect = function recordDisconnect() {
            this.disconnectedAt = now();
            logger.log("ConnectionMonitor recorded disconnect");
        };
        ConnectionMonitor.prototype.startPolling = function startPolling() {
            this.stopPolling();
            this.poll();
        };
        ConnectionMonitor.prototype.stopPolling = function stopPolling() {
            clearTimeout(this.pollTimeout);
        };
        ConnectionMonitor.prototype.poll = function poll() {
            var _this = this;
            this.pollTimeout = setTimeout(function() {
                _this.reconnectIfStale();
                _this.poll();
            }, this.getPollInterval());
        };
        ConnectionMonitor.prototype.getPollInterval = function getPollInterval() {
            var _constructor$pollInte = this.constructor.pollInterval, min = _constructor$pollInte.min, max = _constructor$pollInte.max, multiplier = _constructor$pollInte.multiplier;
            var interval = multiplier * Math.log(this.reconnectAttempts + 1);
            return Math.round(clamp(interval, min, max) * 1e3);
        };
        ConnectionMonitor.prototype.reconnectIfStale = function reconnectIfStale() {
            if (this.connectionIsStale()) {
                logger.log("ConnectionMonitor detected stale connection. reconnectAttempts = " + this.reconnectAttempts + ", pollInterval = " + this.getPollInterval() + " ms, time disconnected = " + secondsSince(this.disconnectedAt) + " s, stale threshold = " + this.constructor.staleThreshold + " s");
                this.reconnectAttempts++;
                if (this.disconnectedRecently()) logger.log("ConnectionMonitor skipping reopening recent disconnect");
                else {
                    logger.log("ConnectionMonitor reopening");
                    this.connection.reopen();
                }
            }
        };
        ConnectionMonitor.prototype.connectionIsStale = function connectionIsStale() {
            return secondsSince(this.pingedAt ? this.pingedAt : this.startedAt) > this.constructor.staleThreshold;
        };
        ConnectionMonitor.prototype.disconnectedRecently = function disconnectedRecently() {
            return this.disconnectedAt && secondsSince(this.disconnectedAt) < this.constructor.staleThreshold;
        };
        ConnectionMonitor.prototype.visibilityDidChange = function visibilityDidChange() {
            var _this2 = this;
            if (document.visibilityState === "visible") setTimeout(function() {
                if (_this2.connectionIsStale() || !_this2.connection.isOpen()) {
                    logger.log("ConnectionMonitor reopening stale connection on visibilitychange. visibilityState = " + document.visibilityState);
                    _this2.connection.reopen();
                }
            }, 200);
        };
        return ConnectionMonitor;
    }();
    ConnectionMonitor.pollInterval = {
        min: 3,
        max: 30,
        multiplier: 5
    };
    ConnectionMonitor.staleThreshold = 6;
    var INTERNAL = {
        message_types: {
            welcome: "welcome",
            disconnect: "disconnect",
            ping: "ping",
            confirmation: "confirm_subscription",
            rejection: "reject_subscription"
        },
        disconnect_reasons: {
            unauthorized: "unauthorized",
            invalid_request: "invalid_request",
            server_restart: "server_restart"
        },
        default_mount_path: "/cable",
        protocols: [
            "actioncable-v1-json",
            "actioncable-unsupported"
        ]
    };
    var message_types = INTERNAL.message_types, protocols = INTERNAL.protocols;
    var supportedProtocols = protocols.slice(0, protocols.length - 1);
    var indexOf = [].indexOf;
    var Connection = function() {
        function Connection(consumer) {
            classCallCheck(this, Connection);
            this.open = this.open.bind(this);
            this.consumer = consumer;
            this.subscriptions = this.consumer.subscriptions;
            this.monitor = new ConnectionMonitor(this);
            this.disconnected = true;
        }
        Connection.prototype.send = function send(data) {
            if (this.isOpen()) {
                this.webSocket.send(JSON.stringify(data));
                return true;
            } else return false;
        };
        Connection.prototype.open = function open() {
            if (this.isActive()) {
                logger.log("Attempted to open WebSocket, but existing socket is " + this.getState());
                return false;
            } else {
                logger.log("Opening WebSocket, current state is " + this.getState() + ", subprotocols: " + protocols);
                if (this.webSocket) this.uninstallEventHandlers();
                this.webSocket = new adapters.WebSocket(this.consumer.url, protocols);
                this.installEventHandlers();
                this.monitor.start();
                return true;
            }
        };
        Connection.prototype.close = function close() {
            var _ref = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : {
                allowReconnect: true
            }, allowReconnect = _ref.allowReconnect;
            if (!allowReconnect) this.monitor.stop();
            if (this.isActive()) return this.webSocket.close();
        };
        Connection.prototype.reopen = function reopen() {
            logger.log("Reopening WebSocket, current state is " + this.getState());
            if (this.isActive()) try {
                return this.close();
            } catch (error) {
                logger.log("Failed to reopen WebSocket", error);
            } finally{
                logger.log("Reopening WebSocket in " + this.constructor.reopenDelay + "ms");
                setTimeout(this.open, this.constructor.reopenDelay);
            }
            else return this.open();
        };
        Connection.prototype.getProtocol = function getProtocol() {
            if (this.webSocket) return this.webSocket.protocol;
        };
        Connection.prototype.isOpen = function isOpen() {
            return this.isState("open");
        };
        Connection.prototype.isActive = function isActive() {
            return this.isState("open", "connecting");
        };
        Connection.prototype.isProtocolSupported = function isProtocolSupported() {
            return indexOf.call(supportedProtocols, this.getProtocol()) >= 0;
        };
        Connection.prototype.isState = function isState() {
            for(var _len = arguments.length, states = Array(_len), _key = 0; _key < _len; _key++)states[_key] = arguments[_key];
            return indexOf.call(states, this.getState()) >= 0;
        };
        Connection.prototype.getState = function getState() {
            if (this.webSocket) for(var state in adapters.WebSocket){
                if (adapters.WebSocket[state] === this.webSocket.readyState) return state.toLowerCase();
            }
            return null;
        };
        Connection.prototype.installEventHandlers = function installEventHandlers() {
            for(var eventName in this.events){
                var handler = this.events[eventName].bind(this);
                this.webSocket["on" + eventName] = handler;
            }
        };
        Connection.prototype.uninstallEventHandlers = function uninstallEventHandlers() {
            for(var eventName in this.events)this.webSocket["on" + eventName] = function() {};
        };
        return Connection;
    }();
    Connection.reopenDelay = 500;
    Connection.prototype.events = {
        message: function message(event) {
            if (!this.isProtocolSupported()) return;
            var _JSON$parse = JSON.parse(event.data), identifier = _JSON$parse.identifier, message = _JSON$parse.message, reason = _JSON$parse.reason, reconnect = _JSON$parse.reconnect, type = _JSON$parse.type;
            switch(type){
                case message_types.welcome:
                    this.monitor.recordConnect();
                    return this.subscriptions.reload();
                case message_types.disconnect:
                    logger.log("Disconnecting. Reason: " + reason);
                    return this.close({
                        allowReconnect: reconnect
                    });
                case message_types.ping:
                    return this.monitor.recordPing();
                case message_types.confirmation:
                    this.subscriptions.confirmSubscription(identifier);
                    return this.subscriptions.notify(identifier, "connected");
                case message_types.rejection:
                    return this.subscriptions.reject(identifier);
                default:
                    return this.subscriptions.notify(identifier, "received", message);
            }
        },
        open: function open() {
            logger.log("WebSocket onopen event, using '" + this.getProtocol() + "' subprotocol");
            this.disconnected = false;
            if (!this.isProtocolSupported()) {
                logger.log("Protocol is unsupported. Stopping monitor and disconnecting.");
                return this.close({
                    allowReconnect: false
                });
            }
        },
        close: function close(event) {
            logger.log("WebSocket onclose event");
            if (this.disconnected) return;
            this.disconnected = true;
            this.monitor.recordDisconnect();
            return this.subscriptions.notifyAll("disconnected", {
                willAttemptReconnect: this.monitor.isRunning()
            });
        },
        error: function error() {
            logger.log("WebSocket onerror event");
        }
    };
    var extend = function extend(object, properties) {
        if (properties != null) for(var key in properties){
            var value = properties[key];
            object[key] = value;
        }
        return object;
    };
    var Subscription = function() {
        function Subscription(consumer) {
            var params = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
            var mixin = arguments[2];
            classCallCheck(this, Subscription);
            this.consumer = consumer;
            this.identifier = JSON.stringify(params);
            extend(this, mixin);
        }
        Subscription.prototype.perform = function perform(action) {
            var data = arguments.length > 1 && arguments[1] !== undefined ? arguments[1] : {};
            data.action = action;
            return this.send(data);
        };
        Subscription.prototype.send = function send(data) {
            return this.consumer.send({
                command: "message",
                identifier: this.identifier,
                data: JSON.stringify(data)
            });
        };
        Subscription.prototype.unsubscribe = function unsubscribe() {
            return this.consumer.subscriptions.remove(this);
        };
        return Subscription;
    }();
    var SubscriptionGuarantor = function() {
        function SubscriptionGuarantor(subscriptions) {
            classCallCheck(this, SubscriptionGuarantor);
            this.subscriptions = subscriptions;
            this.pendingSubscriptions = [];
        }
        SubscriptionGuarantor.prototype.guarantee = function guarantee(subscription) {
            if (this.pendingSubscriptions.indexOf(subscription) == -1) {
                logger.log("SubscriptionGuarantor guaranteeing " + subscription.identifier);
                this.pendingSubscriptions.push(subscription);
            } else logger.log("SubscriptionGuarantor already guaranteeing " + subscription.identifier);
            this.startGuaranteeing();
        };
        SubscriptionGuarantor.prototype.forget = function forget(subscription) {
            logger.log("SubscriptionGuarantor forgetting " + subscription.identifier);
            this.pendingSubscriptions = this.pendingSubscriptions.filter(function(s) {
                return s !== subscription;
            });
        };
        SubscriptionGuarantor.prototype.startGuaranteeing = function startGuaranteeing() {
            this.stopGuaranteeing();
            this.retrySubscribing();
        };
        SubscriptionGuarantor.prototype.stopGuaranteeing = function stopGuaranteeing() {
            clearTimeout(this.retryTimeout);
        };
        SubscriptionGuarantor.prototype.retrySubscribing = function retrySubscribing() {
            var _this = this;
            this.retryTimeout = setTimeout(function() {
                if (_this.subscriptions && typeof _this.subscriptions.subscribe === "function") _this.pendingSubscriptions.map(function(subscription) {
                    logger.log("SubscriptionGuarantor resubscribing " + subscription.identifier);
                    _this.subscriptions.subscribe(subscription);
                });
            }, 500);
        };
        return SubscriptionGuarantor;
    }();
    var Subscriptions = function() {
        function Subscriptions(consumer) {
            classCallCheck(this, Subscriptions);
            this.consumer = consumer;
            this.guarantor = new SubscriptionGuarantor(this);
            this.subscriptions = [];
        }
        Subscriptions.prototype.create = function create(channelName, mixin) {
            var channel = channelName;
            var params = (typeof channel === "undefined" ? "undefined" : _typeof(channel)) === "object" ? channel : {
                channel: channel
            };
            var subscription = new Subscription(this.consumer, params, mixin);
            return this.add(subscription);
        };
        Subscriptions.prototype.add = function add(subscription) {
            this.subscriptions.push(subscription);
            this.consumer.ensureActiveConnection();
            this.notify(subscription, "initialized");
            this.subscribe(subscription);
            return subscription;
        };
        Subscriptions.prototype.remove = function remove(subscription) {
            this.forget(subscription);
            if (!this.findAll(subscription.identifier).length) this.sendCommand(subscription, "unsubscribe");
            return subscription;
        };
        Subscriptions.prototype.reject = function reject(identifier) {
            var _this = this;
            return this.findAll(identifier).map(function(subscription) {
                _this.forget(subscription);
                _this.notify(subscription, "rejected");
                return subscription;
            });
        };
        Subscriptions.prototype.forget = function forget(subscription) {
            this.guarantor.forget(subscription);
            this.subscriptions = this.subscriptions.filter(function(s) {
                return s !== subscription;
            });
            return subscription;
        };
        Subscriptions.prototype.findAll = function findAll(identifier) {
            return this.subscriptions.filter(function(s) {
                return s.identifier === identifier;
            });
        };
        Subscriptions.prototype.reload = function reload() {
            var _this2 = this;
            return this.subscriptions.map(function(subscription) {
                return _this2.subscribe(subscription);
            });
        };
        Subscriptions.prototype.notifyAll = function notifyAll(callbackName) {
            var _this3 = this;
            for(var _len = arguments.length, args = Array(_len > 1 ? _len - 1 : 0), _key = 1; _key < _len; _key++)args[_key - 1] = arguments[_key];
            return this.subscriptions.map(function(subscription) {
                return _this3.notify.apply(_this3, [
                    subscription,
                    callbackName
                ].concat(args));
            });
        };
        Subscriptions.prototype.notify = function notify(subscription, callbackName) {
            for(var _len2 = arguments.length, args = Array(_len2 > 2 ? _len2 - 2 : 0), _key2 = 2; _key2 < _len2; _key2++)args[_key2 - 2] = arguments[_key2];
            var subscriptions = void 0;
            if (typeof subscription === "string") subscriptions = this.findAll(subscription);
            else subscriptions = [
                subscription
            ];
            return subscriptions.map(function(subscription) {
                return typeof subscription[callbackName] === "function" ? subscription[callbackName].apply(subscription, args) : undefined;
            });
        };
        Subscriptions.prototype.subscribe = function subscribe(subscription) {
            if (this.sendCommand(subscription, "subscribe")) this.guarantor.guarantee(subscription);
        };
        Subscriptions.prototype.confirmSubscription = function confirmSubscription(identifier) {
            var _this4 = this;
            logger.log("Subscription confirmed " + identifier);
            this.findAll(identifier).map(function(subscription) {
                return _this4.guarantor.forget(subscription);
            });
        };
        Subscriptions.prototype.sendCommand = function sendCommand(subscription, command) {
            var identifier = subscription.identifier;
            return this.consumer.send({
                command: command,
                identifier: identifier
            });
        };
        return Subscriptions;
    }();
    var Consumer = function() {
        function Consumer(url) {
            classCallCheck(this, Consumer);
            this._url = url;
            this.subscriptions = new Subscriptions(this);
            this.connection = new Connection(this);
        }
        Consumer.prototype.send = function send(data) {
            return this.connection.send(data);
        };
        Consumer.prototype.connect = function connect() {
            return this.connection.open();
        };
        Consumer.prototype.disconnect = function disconnect() {
            return this.connection.close({
                allowReconnect: false
            });
        };
        Consumer.prototype.ensureActiveConnection = function ensureActiveConnection() {
            if (!this.connection.isActive()) return this.connection.open();
        };
        createClass(Consumer, [
            {
                key: "url",
                get: function get$$1() {
                    return createWebSocketURL(this._url);
                }
            }
        ]);
        return Consumer;
    }();
    function createWebSocketURL(url) {
        if (typeof url === "function") url = url();
        if (url && !/^wss?:/i.test(url)) {
            var a = document.createElement("a");
            a.href = url;
            a.href = a.href;
            a.protocol = a.protocol.replace("http", "ws");
            return a.href;
        } else return url;
    }
    function createConsumer() {
        var url = arguments.length > 0 && arguments[0] !== undefined ? arguments[0] : getConfig("url") || INTERNAL.default_mount_path;
        return new Consumer(url);
    }
    function getConfig(name) {
        var element = document.head.querySelector("meta[name='action-cable-" + name + "']");
        if (element) return element.getAttribute("content");
    }
    exports1.Connection = Connection;
    exports1.ConnectionMonitor = ConnectionMonitor;
    exports1.Consumer = Consumer;
    exports1.INTERNAL = INTERNAL;
    exports1.Subscription = Subscription;
    exports1.Subscriptions = Subscriptions;
    exports1.SubscriptionGuarantor = SubscriptionGuarantor;
    exports1.adapters = adapters;
    exports1.createWebSocketURL = createWebSocketURL;
    exports1.logger = logger;
    exports1.createConsumer = createConsumer;
    exports1.getConfig = getConfig;
    Object.defineProperty(exports1, "__esModule", {
        value: true
    });
});


/* eslint-disable no-undefined,no-param-reassign,no-shadow */ /**
 * Throttle execution of a function. Especially useful for rate limiting
 * execution of handlers on events like resize and scroll.
 *
 * @param {number} delay -                  A zero-or-greater delay in milliseconds. For event callbacks, values around 100 or 250 (or even higher)
 *                                            are most useful.
 * @param {Function} callback -               A function to be executed after delay milliseconds. The `this` context and all arguments are passed through,
 *                                            as-is, to `callback` when the throttled-function is executed.
 * @param {object} [options] -              An object to configure options.
 * @param {boolean} [options.noTrailing] -   Optional, defaults to false. If noTrailing is true, callback will only execute every `delay` milliseconds
 *                                            while the throttled-function is being called. If noTrailing is false or unspecified, callback will be executed
 *                                            one final time after the last throttled-function call. (After the throttled-function has not been called for
 *                                            `delay` milliseconds, the internal counter is reset).
 * @param {boolean} [options.noLeading] -   Optional, defaults to false. If noLeading is false, the first throttled-function call will execute callback
 *                                            immediately. If noLeading is true, the first the callback execution will be skipped. It should be noted that
 *                                            callback will never executed if both noLeading = true and noTrailing = true.
 * @param {boolean} [options.debounceMode] - If `debounceMode` is true (at begin), schedule `clear` to execute after `delay` ms. If `debounceMode` is
 *                                            false (at end), schedule `callback` to execute after `delay` ms.
 *
 * @returns {Function} A new, throttled, function.
 */ function $c5d017602d25d050$export$de363e709c412c8a(delay, callback, options) {
    var _ref = options || {}, _ref$noTrailing = _ref.noTrailing, noTrailing = _ref$noTrailing === void 0 ? false : _ref$noTrailing, _ref$noLeading = _ref.noLeading, noLeading = _ref$noLeading === void 0 ? false : _ref$noLeading, _ref$debounceMode = _ref.debounceMode, debounceMode = _ref$debounceMode === void 0 ? undefined : _ref$debounceMode;
    /*
   * After wrapper has stopped being called, this timeout ensures that
   * `callback` is executed at the proper times in `throttle` and `end`
   * debounce modes.
   */ var timeoutID;
    var cancelled = false;
    // Keep track of the last time `callback` was executed.
    var lastExec = 0;
    // Function to clear existing timeout
    function clearExistingTimeout() {
        if (timeoutID) clearTimeout(timeoutID);
    }
    // Function to cancel next exec
    function cancel(options) {
        var _ref2 = options || {}, _ref2$upcomingOnly = _ref2.upcomingOnly, upcomingOnly = _ref2$upcomingOnly === void 0 ? false : _ref2$upcomingOnly;
        clearExistingTimeout();
        cancelled = !upcomingOnly;
    }
    /*
   * The `wrapper` function encapsulates all of the throttling / debouncing
   * functionality and when executed will limit the rate at which `callback`
   * is executed.
   */ function wrapper() {
        for(var _len = arguments.length, arguments_ = new Array(_len), _key = 0; _key < _len; _key++)arguments_[_key] = arguments[_key];
        var self = this;
        var elapsed = Date.now() - lastExec;
        if (cancelled) return;
        // Execute `callback` and update the `lastExec` timestamp.
        function exec() {
            lastExec = Date.now();
            callback.apply(self, arguments_);
        }
        /*
     * If `debounceMode` is true (at begin) this is used to clear the flag
     * to allow future `callback` executions.
     */ function clear() {
            timeoutID = undefined;
        }
        if (!noLeading && debounceMode && !timeoutID) /*
       * Since `wrapper` is being called for the first time and
       * `debounceMode` is true (at begin), execute `callback`
       * and noLeading != true.
       */ exec();
        clearExistingTimeout();
        if (debounceMode === undefined && elapsed > delay) {
            if (noLeading) {
                /*
         * In throttle mode with noLeading, if `delay` time has
         * been exceeded, update `lastExec` and schedule `callback`
         * to execute after `delay` ms.
         */ lastExec = Date.now();
                if (!noTrailing) timeoutID = setTimeout(debounceMode ? clear : exec, delay);
            } else /*
         * In throttle mode without noLeading, if `delay` time has been exceeded, execute
         * `callback`.
         */ exec();
        } else if (noTrailing !== true) /*
       * In trailing throttle mode, since `delay` time has not been
       * exceeded, schedule `callback` to execute `delay` ms after most
       * recent execution.
       *
       * If `debounceMode` is true (at begin), schedule `clear` to execute
       * after `delay` ms.
       *
       * If `debounceMode` is false (at end), schedule `callback` to
       * execute after `delay` ms.
       */ timeoutID = setTimeout(debounceMode ? clear : exec, debounceMode === undefined ? delay - elapsed : delay);
    }
    wrapper.cancel = cancel;
    // Return the wrapper function.
    return wrapper;
}
/* eslint-disable no-undefined */ /**
 * Debounce execution of a function. Debouncing, unlike throttling,
 * guarantees that a function is only executed a single time, either at the
 * very beginning of a series of calls, or at the very end.
 *
 * @param {number} delay -               A zero-or-greater delay in milliseconds. For event callbacks, values around 100 or 250 (or even higher) are most useful.
 * @param {Function} callback -          A function to be executed after delay milliseconds. The `this` context and all arguments are passed through, as-is,
 *                                        to `callback` when the debounced-function is executed.
 * @param {object} [options] -           An object to configure options.
 * @param {boolean} [options.atBegin] -  Optional, defaults to false. If atBegin is false or unspecified, callback will only be executed `delay` milliseconds
 *                                        after the last debounced-function call. If atBegin is true, callback will be executed only at the first debounced-function call.
 *                                        (After the throttled-function has not been called for `delay` milliseconds, the internal counter is reset).
 *
 * @returns {Function} A new, debounced function.
 */ function $c5d017602d25d050$export$61fc7d43ac8f84b0(delay, callback, options) {
    var _ref = options || {}, _ref$atBegin = _ref.atBegin, atBegin = _ref$atBegin === void 0 ? false : _ref$atBegin;
    return $c5d017602d25d050$export$de363e709c412c8a(delay, callback, {
        debounceMode: atBegin !== false
    });
}



function $f57397824b7ddfec$export$2e2bcd8739ae039(endpoint) {
    const uid = (Date.now() + (Math.random() * 100 | 0)).toString();
    const consumer = (0, $7d6b1fa982d8364d$exports.createConsumer)(`${endpoint}?uid=${uid}`);
    return {
        addListener (channel, callback) {
            consumer.subscriptions.create(channel, {
                received: (0, $c5d017602d25d050$export$61fc7d43ac8f84b0)(200, (data)=>{
                    (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))).debug("Lookbook files changed");
                    callback(data);
                }, {
                    atBegin: true
                }),
                connected () {
                    (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))).info("Lookbook websocket connected");
                },
                disconnected () {
                    (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports))).info("Lookbook websocket disconnected");
                }
            });
        }
    };
}


function $490552754c23ef6f$export$2e5e8c41f5d4e7c7(from, to) {
    Alpine.morph(from, to, {
        key (el) {
            return el.getAttribute("key") ? el.getAttribute("key") : el.id;
        },
        lookahead: true,
        updating (el, toEl, childrenOnly, skip) {
            if (!el.getAttribute) return;
            if (el.getAttribute("data-morph-strategy") === "replace") {
                el.innerHTML = toEl.innerHTML;
                return skip();
            } else if (el.getAttribute("data-morph-strategy") === "skip") return skip();
        }
    });
}
function $490552754c23ef6f$export$bdf7e699b242f476(el, opts = {}) {
    const style = window.getComputedStyle(el, null);
    return {
        width: opts.includeMargins ? el.offsetWidth + parseInt(style.getPropertyValue("margin-left")) + parseInt(style.getPropertyValue("margin-right")) : el.offsetWidth,
        height: opts.includeMargins ? el.offsetHeight + parseInt(style.getPropertyValue("margin-top")) + parseInt(style.getPropertyValue("margin-bottom")) : el.offsetHeight
    };
}
function $490552754c23ef6f$export$b98882f166bb7ce2(link) {
    if (link.href) return link.host !== window.location.host;
    return false;
}


async function $41e83ac737081df5$export$51c59e2af49c1a92(url, selector, options = {}) {
    const response = await fetch(url || window.document.location, options);
    const html = await response.text();
    const doc = new DOMParser().parseFromString(html, "text/html");
    return {
        ok: response.ok,
        fragment: selector ? doc.querySelector(selector).outerHTML : null,
        title: doc.title,
        response: response,
        doc: doc
    };
}


function $5792afa4170ed552$export$2e2bcd8739ae039() {
    return {
        _requestsInProgress: 0,
        version: Alpine.$persist("").as("lookbook-version"),
        location: window.location,
        get sidebarHidden () {
            return this.$store.layout.sidebar.hidden;
        },
        get loading () {
            return this._requestsInProgress > 0;
        },
        init () {
            if (window.SOCKET_PATH) {
                this.debug(`Lookbook socket created`);
                const socket = (0, $f57397824b7ddfec$export$2e2bcd8739ae039)(window.SOCKET_PATH);
                socket.addListener("Lookbook::ReloadChannel", ()=>this.updateDOM());
            }
            this.$watch("$store.layout.mobile", (mobile)=>{
                if (!mobile) this.$store.layout.sidebar.hidden = true;
            });
        },
        navigateTo (path) {
            this.debug(`Navigating to ${path}`);
            history.pushState({}, null, path);
            this.$dispatch("popstate");
        },
        async handleNavigation () {
            this.debug("Navigating to ", window.location.pathname);
            this.$dispatch("navigation:start");
            this.location = window.location;
            await this.updateDOM("#app-main", {
                headers: {
                    "X-Lookbook-Frame": "main"
                }
            });
            this.$dispatch("navigation:complete");
        },
        hijax (evt) {
            const link = evt.target.closest("a[href]");
            if (link) {
                const external = (0, $490552754c23ef6f$export$b98882f166bb7ce2)(link);
                const embedded = this.isEmbedded();
                if (embedded && (!link.hasAttribute("target") || external)) {
                    evt.preventDefault();
                    window.top.location = link.href;
                    return;
                } else if (!embedded && !external && !link.hasAttribute("target")) {
                    evt.preventDefault();
                    this.navigateTo(link.href);
                    return;
                }
            }
        },
        async updateDOM (rootSelector = `#${this.$root.id}`, options = {}) {
            this.debug("Starting DOM update");
            this.$dispatch("dom:update-start");
            this.requestStart();
            try {
                const { fragment: fragment, title: title } = await (0, $41e83ac737081df5$export$51c59e2af49c1a92)(window.location, rootSelector, options);
                (0, $490552754c23ef6f$export$2e5e8c41f5d4e7c7)(document.querySelector(rootSelector), fragment);
                document.title = title;
                this.requestEnd();
                this.$dispatch("dom:update-complete");
                this.debug("DOM update complete");
            } catch (err) {
                this.error(err);
                window.location.reload();
            }
        },
        toggleSidebar () {
            this.$store.layout.sidebar.hidden = !this.$store.layout.sidebar.hidden;
        },
        closeMobileSidebar () {
            if (this.$store.layout.mobile && !this.sidebarHidden) this.toggleSidebar();
        },
        requestStart () {
            this._requestsInProgress += 1;
        },
        requestEnd () {
            if (this._requestsInProgress > 0) this._requestsInProgress -= 1;
        },
        isEmbedded () {
            try {
                return window.self !== window.top;
            } catch (e) {
                return true;
            }
        },
        ...Alpine.$log
    };
}


function $12b7aa006b8a97e1$export$4e811121b221213b(importObject, path = []) {
    let components = {};
    Object.keys(importObject).forEach((key)=>{
        if (key === "default") components[$12b7aa006b8a97e1$var$toCamel(path.join("_"))] = importObject[key];
        else components = {
            ...components,
            ...$12b7aa006b8a97e1$export$4e811121b221213b(importObject[key], [
                ...path,
                key
            ])
        };
    });
    return components;
}
function $12b7aa006b8a97e1$var$toCamel(s) {
    return s.replace(/([-_][a-z])/gi, ($1)=>{
        return $1.toUpperCase().replace("-", "").replace("_", "");
    });
}


var $88dfd91701b4cd8b$exports = {};
var $99486586f6691564$exports = {};

$parcel$defineInteropFlag($99486586f6691564$exports);

$parcel$export($99486586f6691564$exports, "default", () => $99486586f6691564$export$2e2bcd8739ae039);
function $99486586f6691564$export$2e2bcd8739ae039() {
    return {};
}


var $cbd28b10fa9798c7$exports = {};

$parcel$defineInteropFlag($cbd28b10fa9798c7$exports);

$parcel$export($cbd28b10fa9798c7$exports, "default", () => $cbd28b10fa9798c7$export$2e2bcd8739ae039);
/**!
* tippy.js v6.3.7
* (c) 2017-2021 atomiks
* MIT License
*/ function $59d97a6bab2b727e$export$2e2bcd8739ae039(element) {
    return element ? (element.nodeName || '').toLowerCase() : null;
}


function $f41f4520bee001a7$export$2e2bcd8739ae039(node) {
    if (node == null) return window;
    if (node.toString() !== '[object Window]') {
        var ownerDocument = node.ownerDocument;
        return ownerDocument ? ownerDocument.defaultView || window : window;
    }
    return node;
}


function $1fa2a5446b18c455$export$45a5e7f76e0caa8d(node) {
    var OwnElement = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(node).Element;
    return node instanceof OwnElement || node instanceof Element;
}
function $1fa2a5446b18c455$export$1b3bfaa9684536aa(node) {
    var OwnElement = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(node).HTMLElement;
    return node instanceof OwnElement || node instanceof HTMLElement;
}
function $1fa2a5446b18c455$export$af51f0f06c0f328a(node) {
    // IE 11 has no ShadowRoot
    if (typeof ShadowRoot === 'undefined') return false;
    var OwnElement = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(node).ShadowRoot;
    return node instanceof OwnElement || node instanceof ShadowRoot;
}


// and applies them to the HTMLElements such as popper and arrow
function $dfb41fce0bddd2d8$var$applyStyles(_ref) {
    var state = _ref.state;
    Object.keys(state.elements).forEach(function(name) {
        var style = state.styles[name] || {};
        var attributes = state.attributes[name] || {};
        var element = state.elements[name]; // arrow is optional + virtual elements
        if (!(0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element) || !(0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(element)) return;
         // Flow doesn't support to extend this property, but it's the most
        // effective way to apply styles to an HTMLElement
        // $FlowFixMe[cannot-write]
        Object.assign(element.style, style);
        Object.keys(attributes).forEach(function(name) {
            var value = attributes[name];
            if (value === false) element.removeAttribute(name);
            else element.setAttribute(name, value === true ? '' : value);
        });
    });
}
function $dfb41fce0bddd2d8$var$effect(_ref2) {
    var state = _ref2.state;
    var initialStyles = {
        popper: {
            position: state.options.strategy,
            left: '0',
            top: '0',
            margin: '0'
        },
        arrow: {
            position: 'absolute'
        },
        reference: {}
    };
    Object.assign(state.elements.popper.style, initialStyles.popper);
    state.styles = initialStyles;
    if (state.elements.arrow) Object.assign(state.elements.arrow.style, initialStyles.arrow);
    return function() {
        Object.keys(state.elements).forEach(function(name) {
            var element = state.elements[name];
            var attributes = state.attributes[name] || {};
            var styleProperties = Object.keys(state.styles.hasOwnProperty(name) ? state.styles[name] : initialStyles[name]); // Set all values to an empty string to unset them
            var style = styleProperties.reduce(function(style, property) {
                style[property] = '';
                return style;
            }, {}); // arrow is optional + virtual elements
            if (!(0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element) || !(0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(element)) return;
            Object.assign(element.style, style);
            Object.keys(attributes).forEach(function(attribute) {
                element.removeAttribute(attribute);
            });
        });
    };
} // eslint-disable-next-line import/no-unused-modules
var $dfb41fce0bddd2d8$export$2e2bcd8739ae039 = {
    name: 'applyStyles',
    enabled: true,
    phase: 'write',
    fn: $dfb41fce0bddd2d8$var$applyStyles,
    effect: $dfb41fce0bddd2d8$var$effect,
    requires: [
        'computeStyles'
    ]
};


var $a435872b5ba665df$export$8960430cfd85939f = Math.max;
var $a435872b5ba665df$export$96ec731ed4dcb222 = Math.min;
var $a435872b5ba665df$export$2077e0241d6afd3c = Math.round;



function $beb42d7aceecf8c8$export$2e2bcd8739ae039() {
    var uaData = navigator.userAgentData;
    if (uaData != null && uaData.brands && Array.isArray(uaData.brands)) return uaData.brands.map(function(item) {
        return item.brand + "/" + item.version;
    }).join(' ');
    return navigator.userAgent;
}


function $f6bdda075fc14cbf$export$2e2bcd8739ae039() {
    return !/^((?!chrome|android).)*safari/i.test((0, $beb42d7aceecf8c8$export$2e2bcd8739ae039)());
}


function $b854957821c00430$export$2e2bcd8739ae039(element, includeScale, isFixedStrategy) {
    if (includeScale === void 0) includeScale = false;
    if (isFixedStrategy === void 0) isFixedStrategy = false;
    var clientRect = element.getBoundingClientRect();
    var scaleX = 1;
    var scaleY = 1;
    if (includeScale && (0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element)) {
        scaleX = element.offsetWidth > 0 ? (0, $a435872b5ba665df$export$2077e0241d6afd3c)(clientRect.width) / element.offsetWidth || 1 : 1;
        scaleY = element.offsetHeight > 0 ? (0, $a435872b5ba665df$export$2077e0241d6afd3c)(clientRect.height) / element.offsetHeight || 1 : 1;
    }
    var _ref = (0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(element) ? (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(element) : window, visualViewport = _ref.visualViewport;
    var addVisualOffsets = !(0, $f6bdda075fc14cbf$export$2e2bcd8739ae039)() && isFixedStrategy;
    var x = (clientRect.left + (addVisualOffsets && visualViewport ? visualViewport.offsetLeft : 0)) / scaleX;
    var y = (clientRect.top + (addVisualOffsets && visualViewport ? visualViewport.offsetTop : 0)) / scaleY;
    var width = clientRect.width / scaleX;
    var height = clientRect.height / scaleY;
    return {
        width: width,
        height: height,
        top: y,
        right: x + width,
        bottom: y + height,
        left: x,
        x: x,
        y: y
    };
}



function $2f82ac4f0d5b4512$export$2e2bcd8739ae039(node) {
    var win = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(node);
    var scrollLeft = win.pageXOffset;
    var scrollTop = win.pageYOffset;
    return {
        scrollLeft: scrollLeft,
        scrollTop: scrollTop
    };
}




function $3c2db27a5892c2b6$export$2e2bcd8739ae039(element) {
    return {
        scrollLeft: element.scrollLeft,
        scrollTop: element.scrollTop
    };
}


function $40149fb4267f270e$export$2e2bcd8739ae039(node) {
    if (node === (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(node) || !(0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(node)) return (0, $2f82ac4f0d5b4512$export$2e2bcd8739ae039)(node);
    else return (0, $3c2db27a5892c2b6$export$2e2bcd8739ae039)(node);
}






function $3e02d6708e2a16ac$export$2e2bcd8739ae039(element) {
    // $FlowFixMe[incompatible-return]: assume body is always available
    return (((0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(element) ? element.ownerDocument : element.document) || window.document).documentElement;
}



function $05804587c501a8a1$export$2e2bcd8739ae039(element) {
    // If <html> has a CSS width greater than the viewport, then this will be
    // incorrect for RTL.
    // Popper 1 is broken in this case and never had a bug report so let's assume
    // it's not an issue. I don't think anyone ever specifies width on <html>
    // anyway.
    // Browsers where the left scrollbar doesn't cause an issue report `0` for
    // this (e.g. Edge 2019, IE11, Safari)
    return (0, $b854957821c00430$export$2e2bcd8739ae039)((0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(element)).left + (0, $2f82ac4f0d5b4512$export$2e2bcd8739ae039)(element).scrollLeft;
}




function $392247934674b5b4$export$2e2bcd8739ae039(element) {
    return (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(element).getComputedStyle(element);
}


function $d0e76ea5ac4d8fe1$export$2e2bcd8739ae039(element) {
    // Firefox wants us to check `-x` and `-y` variations as well
    var _getComputedStyle = (0, $392247934674b5b4$export$2e2bcd8739ae039)(element), overflow = _getComputedStyle.overflow, overflowX = _getComputedStyle.overflowX, overflowY = _getComputedStyle.overflowY;
    return /auto|scroll|overlay|hidden/.test(overflow + overflowY + overflowX);
}



function $a195ad21b1cffe79$var$isElementScaled(element) {
    var rect = element.getBoundingClientRect();
    var scaleX = (0, $a435872b5ba665df$export$2077e0241d6afd3c)(rect.width) / element.offsetWidth || 1;
    var scaleY = (0, $a435872b5ba665df$export$2077e0241d6afd3c)(rect.height) / element.offsetHeight || 1;
    return scaleX !== 1 || scaleY !== 1;
} // Returns the composite rect of an element relative to its offsetParent.
function $a195ad21b1cffe79$export$2e2bcd8739ae039(elementOrVirtualElement, offsetParent, isFixed) {
    if (isFixed === void 0) isFixed = false;
    var isOffsetParentAnElement = (0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(offsetParent);
    var offsetParentIsScaled = (0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(offsetParent) && $a195ad21b1cffe79$var$isElementScaled(offsetParent);
    var documentElement = (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(offsetParent);
    var rect = (0, $b854957821c00430$export$2e2bcd8739ae039)(elementOrVirtualElement, offsetParentIsScaled, isFixed);
    var scroll = {
        scrollLeft: 0,
        scrollTop: 0
    };
    var offsets = {
        x: 0,
        y: 0
    };
    if (isOffsetParentAnElement || !isOffsetParentAnElement && !isFixed) {
        if ((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(offsetParent) !== 'body' || // https://github.com/popperjs/popper-core/issues/1078
        (0, $d0e76ea5ac4d8fe1$export$2e2bcd8739ae039)(documentElement)) scroll = (0, $40149fb4267f270e$export$2e2bcd8739ae039)(offsetParent);
        if ((0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(offsetParent)) {
            offsets = (0, $b854957821c00430$export$2e2bcd8739ae039)(offsetParent, true);
            offsets.x += offsetParent.clientLeft;
            offsets.y += offsetParent.clientTop;
        } else if (documentElement) offsets.x = (0, $05804587c501a8a1$export$2e2bcd8739ae039)(documentElement);
    }
    return {
        x: rect.left + scroll.scrollLeft - offsets.x,
        y: rect.top + scroll.scrollTop - offsets.y,
        width: rect.width,
        height: rect.height
    };
}



function $e287ac773d355028$export$2e2bcd8739ae039(element) {
    var clientRect = (0, $b854957821c00430$export$2e2bcd8739ae039)(element); // Use the clientRect sizes if it's not been transformed.
    // Fixes https://github.com/popperjs/popper-core/issues/1223
    var width = element.offsetWidth;
    var height = element.offsetHeight;
    if (Math.abs(clientRect.width - width) <= 1) width = clientRect.width;
    if (Math.abs(clientRect.height - height) <= 1) height = clientRect.height;
    return {
        x: element.offsetLeft,
        y: element.offsetTop,
        width: width,
        height: height
    };
}





function $b1adb38089003474$export$2e2bcd8739ae039(element) {
    if ((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(element) === 'html') return element;
    return(// $FlowFixMe[incompatible-return]
    // $FlowFixMe[prop-missing]
    element.assignedSlot || // step into the shadow DOM of the parent of a slotted node
    element.parentNode || ((0, $1fa2a5446b18c455$export$af51f0f06c0f328a)(element) ? element.host : null) || // ShadowRoot detected
    // $FlowFixMe[incompatible-call]: HTMLElement is a Node
    (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(element) // fallback
    );
}





function $8fec37e99f881747$export$2e2bcd8739ae039(node) {
    if ([
        'html',
        'body',
        '#document'
    ].indexOf((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(node)) >= 0) // $FlowFixMe[incompatible-return]: assume body is always available
    return node.ownerDocument.body;
    if ((0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(node) && (0, $d0e76ea5ac4d8fe1$export$2e2bcd8739ae039)(node)) return node;
    return $8fec37e99f881747$export$2e2bcd8739ae039((0, $b1adb38089003474$export$2e2bcd8739ae039)(node));
}





function $f14b4e1cd31512ee$export$2e2bcd8739ae039(element, list) {
    var _element$ownerDocumen;
    if (list === void 0) list = [];
    var scrollParent = (0, $8fec37e99f881747$export$2e2bcd8739ae039)(element);
    var isBody = scrollParent === ((_element$ownerDocumen = element.ownerDocument) == null ? void 0 : _element$ownerDocumen.body);
    var win = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(scrollParent);
    var target = isBody ? [
        win
    ].concat(win.visualViewport || [], (0, $d0e76ea5ac4d8fe1$export$2e2bcd8739ae039)(scrollParent) ? scrollParent : []) : scrollParent;
    var updatedList = list.concat(target);
    return isBody ? updatedList : updatedList.concat($f14b4e1cd31512ee$export$2e2bcd8739ae039((0, $b1adb38089003474$export$2e2bcd8739ae039)(target)));
}







function $b7f6a1d3d9524a70$export$2e2bcd8739ae039(element) {
    return [
        'table',
        'td',
        'th'
    ].indexOf((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(element)) >= 0;
}




function $4acba801a6bfbaa3$var$getTrueOffsetParent(element) {
    if (!(0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element) || // https://github.com/popperjs/popper-core/issues/837
    (0, $392247934674b5b4$export$2e2bcd8739ae039)(element).position === 'fixed') return null;
    return element.offsetParent;
} // `.offsetParent` reports `null` for fixed elements, while absolute elements
// return the containing block
function $4acba801a6bfbaa3$var$getContainingBlock(element) {
    var isFirefox = /firefox/i.test((0, $beb42d7aceecf8c8$export$2e2bcd8739ae039)());
    var isIE = /Trident/i.test((0, $beb42d7aceecf8c8$export$2e2bcd8739ae039)());
    if (isIE && (0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element)) {
        // In IE 9, 10 and 11 fixed elements containing block is always established by the viewport
        var elementCss = (0, $392247934674b5b4$export$2e2bcd8739ae039)(element);
        if (elementCss.position === 'fixed') return null;
    }
    var currentNode = (0, $b1adb38089003474$export$2e2bcd8739ae039)(element);
    if ((0, $1fa2a5446b18c455$export$af51f0f06c0f328a)(currentNode)) currentNode = currentNode.host;
    while((0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(currentNode) && [
        'html',
        'body'
    ].indexOf((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(currentNode)) < 0){
        var css = (0, $392247934674b5b4$export$2e2bcd8739ae039)(currentNode); // This is non-exhaustive but covers the most common CSS properties that
        // create a containing block.
        // https://developer.mozilla.org/en-US/docs/Web/CSS/Containing_block#identifying_the_containing_block
        if (css.transform !== 'none' || css.perspective !== 'none' || css.contain === 'paint' || [
            'transform',
            'perspective'
        ].indexOf(css.willChange) !== -1 || isFirefox && css.willChange === 'filter' || isFirefox && css.filter && css.filter !== 'none') return currentNode;
        else currentNode = currentNode.parentNode;
    }
    return null;
} // Gets the closest ancestor positioned element. Handles some edge cases,
function $4acba801a6bfbaa3$export$2e2bcd8739ae039(element) {
    var window = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(element);
    var offsetParent = $4acba801a6bfbaa3$var$getTrueOffsetParent(element);
    while(offsetParent && (0, $b7f6a1d3d9524a70$export$2e2bcd8739ae039)(offsetParent) && (0, $392247934674b5b4$export$2e2bcd8739ae039)(offsetParent).position === 'static')offsetParent = $4acba801a6bfbaa3$var$getTrueOffsetParent(offsetParent);
    if (offsetParent && ((0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(offsetParent) === 'html' || (0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(offsetParent) === 'body' && (0, $392247934674b5b4$export$2e2bcd8739ae039)(offsetParent).position === 'static')) return window;
    return offsetParent || $4acba801a6bfbaa3$var$getContainingBlock(element) || window;
}


var $9b56e55559dfbda1$export$1e95b668f3b82d = 'top';
var $9b56e55559dfbda1$export$40e543e69a8b3fbb = 'bottom';
var $9b56e55559dfbda1$export$79ffe56a765070d2 = 'right';
var $9b56e55559dfbda1$export$eabcd2c8791e7bf4 = 'left';
var $9b56e55559dfbda1$export$dfb5619354ba860 = 'auto';
var $9b56e55559dfbda1$export$aec2ce47c367b8c3 = [
    $9b56e55559dfbda1$export$1e95b668f3b82d,
    $9b56e55559dfbda1$export$40e543e69a8b3fbb,
    $9b56e55559dfbda1$export$79ffe56a765070d2,
    $9b56e55559dfbda1$export$eabcd2c8791e7bf4
];
var $9b56e55559dfbda1$export$b3571188c770cc5a = 'start';
var $9b56e55559dfbda1$export$bd5df0f255a350f8 = 'end';
var $9b56e55559dfbda1$export$390fd549c5303b4d = 'clippingParents';
var $9b56e55559dfbda1$export$d7b7311ec04a3e8f = 'viewport';
var $9b56e55559dfbda1$export$ae5ab1c730825774 = 'popper';
var $9b56e55559dfbda1$export$ca50aac9f3ba507f = 'reference';
var $9b56e55559dfbda1$export$368f9a87e87fa4e1 = /*#__PURE__*/ $9b56e55559dfbda1$export$aec2ce47c367b8c3.reduce(function(acc, placement) {
    return acc.concat([
        placement + "-" + $9b56e55559dfbda1$export$b3571188c770cc5a,
        placement + "-" + $9b56e55559dfbda1$export$bd5df0f255a350f8
    ]);
}, []);
var $9b56e55559dfbda1$export$803cd8101b6c182b = /*#__PURE__*/ [].concat($9b56e55559dfbda1$export$aec2ce47c367b8c3, [
    $9b56e55559dfbda1$export$dfb5619354ba860
]).reduce(function(acc, placement) {
    return acc.concat([
        placement,
        placement + "-" + $9b56e55559dfbda1$export$b3571188c770cc5a,
        placement + "-" + $9b56e55559dfbda1$export$bd5df0f255a350f8
    ]);
}, []); // modifiers that need to read the DOM
var $9b56e55559dfbda1$export$421679a7c3d56e = 'beforeRead';
var $9b56e55559dfbda1$export$aafa59e2e03f2942 = 'read';
var $9b56e55559dfbda1$export$6964f6c886723980 = 'afterRead'; // pure-logic modifiers
var $9b56e55559dfbda1$export$c65e99957a05207c = 'beforeMain';
var $9b56e55559dfbda1$export$f22da7240b7add18 = 'main';
var $9b56e55559dfbda1$export$bab79516f2d662fe = 'afterMain'; // modifier with the purpose to write to the DOM (or write into a framework state)
var $9b56e55559dfbda1$export$8d4d2d70e7d46032 = 'beforeWrite';
var $9b56e55559dfbda1$export$68d8715fc104d294 = 'write';
var $9b56e55559dfbda1$export$70a6e5159acce2e6 = 'afterWrite';
var $9b56e55559dfbda1$export$d087d3878fdf71d5 = [
    $9b56e55559dfbda1$export$421679a7c3d56e,
    $9b56e55559dfbda1$export$aafa59e2e03f2942,
    $9b56e55559dfbda1$export$6964f6c886723980,
    $9b56e55559dfbda1$export$c65e99957a05207c,
    $9b56e55559dfbda1$export$f22da7240b7add18,
    $9b56e55559dfbda1$export$bab79516f2d662fe,
    $9b56e55559dfbda1$export$8d4d2d70e7d46032,
    $9b56e55559dfbda1$export$68d8715fc104d294,
    $9b56e55559dfbda1$export$70a6e5159acce2e6
];


function $6e11c0a2f23600d6$var$order(modifiers) {
    var map = new Map();
    var visited = new Set();
    var result = [];
    modifiers.forEach(function(modifier) {
        map.set(modifier.name, modifier);
    }); // On visiting object, check for its dependencies and visit them recursively
    function sort(modifier) {
        visited.add(modifier.name);
        var requires = [].concat(modifier.requires || [], modifier.requiresIfExists || []);
        requires.forEach(function(dep) {
            if (!visited.has(dep)) {
                var depModifier = map.get(dep);
                if (depModifier) sort(depModifier);
            }
        });
        result.push(modifier);
    }
    modifiers.forEach(function(modifier) {
        if (!visited.has(modifier.name)) // check for visited object
        sort(modifier);
    });
    return result;
}
function $6e11c0a2f23600d6$export$2e2bcd8739ae039(modifiers) {
    // order based on dependencies
    var orderedModifiers = $6e11c0a2f23600d6$var$order(modifiers); // order based on phase
    return (0, $9b56e55559dfbda1$export$d087d3878fdf71d5).reduce(function(acc, phase) {
        return acc.concat(orderedModifiers.filter(function(modifier) {
            return modifier.phase === phase;
        }));
    }, []);
}


function $d6d1d118731c5c9c$export$2e2bcd8739ae039(fn) {
    var pending;
    return function() {
        if (!pending) pending = new Promise(function(resolve) {
            Promise.resolve().then(function() {
                pending = undefined;
                resolve(fn());
            });
        });
        return pending;
    };
}


function $6af99e74d4c8a734$export$2e2bcd8739ae039(modifiers) {
    var merged = modifiers.reduce(function(merged, current) {
        var existing = merged[current.name];
        merged[current.name] = existing ? Object.assign({}, existing, current, {
            options: Object.assign({}, existing.options, current.options),
            data: Object.assign({}, existing.data, current.data)
        }) : current;
        return merged;
    }, {}); // IE11 does not support Object.values
    return Object.keys(merged).map(function(key) {
        return merged[key];
    });
}




var $8e357be334f3fad9$var$DEFAULT_OPTIONS = {
    placement: 'bottom',
    modifiers: [],
    strategy: 'absolute'
};
function $8e357be334f3fad9$var$areValidElements() {
    for(var _len = arguments.length, args = new Array(_len), _key = 0; _key < _len; _key++)args[_key] = arguments[_key];
    return !args.some(function(element) {
        return !(element && typeof element.getBoundingClientRect === 'function');
    });
}
function $8e357be334f3fad9$export$ed5e13716264f202(generatorOptions) {
    if (generatorOptions === void 0) generatorOptions = {};
    var _generatorOptions = generatorOptions, _generatorOptions$def = _generatorOptions.defaultModifiers, defaultModifiers = _generatorOptions$def === void 0 ? [] : _generatorOptions$def, _generatorOptions$def2 = _generatorOptions.defaultOptions, defaultOptions = _generatorOptions$def2 === void 0 ? $8e357be334f3fad9$var$DEFAULT_OPTIONS : _generatorOptions$def2;
    return function createPopper(reference, popper, options) {
        if (options === void 0) options = defaultOptions;
        var state = {
            placement: 'bottom',
            orderedModifiers: [],
            options: Object.assign({}, $8e357be334f3fad9$var$DEFAULT_OPTIONS, defaultOptions),
            modifiersData: {},
            elements: {
                reference: reference,
                popper: popper
            },
            attributes: {},
            styles: {}
        };
        var effectCleanupFns = [];
        var isDestroyed = false;
        var instance = {
            state: state,
            setOptions: function setOptions(setOptionsAction) {
                var options = typeof setOptionsAction === 'function' ? setOptionsAction(state.options) : setOptionsAction;
                cleanupModifierEffects();
                state.options = Object.assign({}, defaultOptions, state.options, options);
                state.scrollParents = {
                    reference: (0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(reference) ? (0, $f14b4e1cd31512ee$export$2e2bcd8739ae039)(reference) : reference.contextElement ? (0, $f14b4e1cd31512ee$export$2e2bcd8739ae039)(reference.contextElement) : [],
                    popper: (0, $f14b4e1cd31512ee$export$2e2bcd8739ae039)(popper)
                }; // Orders the modifiers based on their dependencies and `phase`
                // properties
                var orderedModifiers = (0, $6e11c0a2f23600d6$export$2e2bcd8739ae039)((0, $6af99e74d4c8a734$export$2e2bcd8739ae039)([].concat(defaultModifiers, state.options.modifiers))); // Strip out disabled modifiers
                state.orderedModifiers = orderedModifiers.filter(function(m) {
                    return m.enabled;
                });
                runModifierEffects();
                return instance.update();
            },
            // Sync update – it will always be executed, even if not necessary. This
            // is useful for low frequency updates where sync behavior simplifies the
            // logic.
            // For high frequency updates (e.g. `resize` and `scroll` events), always
            // prefer the async Popper#update method
            forceUpdate: function forceUpdate() {
                if (isDestroyed) return;
                var _state$elements = state.elements, reference = _state$elements.reference, popper = _state$elements.popper; // Don't proceed if `reference` or `popper` are not valid elements
                // anymore
                if (!$8e357be334f3fad9$var$areValidElements(reference, popper)) return;
                 // Store the reference and popper rects to be read by modifiers
                state.rects = {
                    reference: (0, $a195ad21b1cffe79$export$2e2bcd8739ae039)(reference, (0, $4acba801a6bfbaa3$export$2e2bcd8739ae039)(popper), state.options.strategy === 'fixed'),
                    popper: (0, $e287ac773d355028$export$2e2bcd8739ae039)(popper)
                }; // Modifiers have the ability to reset the current update cycle. The
                // most common use case for this is the `flip` modifier changing the
                // placement, which then needs to re-run all the modifiers, because the
                // logic was previously ran for the previous placement and is therefore
                // stale/incorrect
                state.reset = false;
                state.placement = state.options.placement; // On each update cycle, the `modifiersData` property for each modifier
                // is filled with the initial data specified by the modifier. This means
                // it doesn't persist and is fresh on each update.
                // To ensure persistent data, use `${name}#persistent`
                state.orderedModifiers.forEach(function(modifier) {
                    return state.modifiersData[modifier.name] = Object.assign({}, modifier.data);
                });
                for(var index = 0; index < state.orderedModifiers.length; index++){
                    if (state.reset === true) {
                        state.reset = false;
                        index = -1;
                        continue;
                    }
                    var _state$orderedModifie = state.orderedModifiers[index], fn = _state$orderedModifie.fn, _state$orderedModifie2 = _state$orderedModifie.options, _options = _state$orderedModifie2 === void 0 ? {} : _state$orderedModifie2, name = _state$orderedModifie.name;
                    if (typeof fn === 'function') state = fn({
                        state: state,
                        options: _options,
                        name: name,
                        instance: instance
                    }) || state;
                }
            },
            // Async and optimistically optimized update – it will not be executed if
            // not necessary (debounced to run at most once-per-tick)
            update: (0, $d6d1d118731c5c9c$export$2e2bcd8739ae039)(function() {
                return new Promise(function(resolve) {
                    instance.forceUpdate();
                    resolve(state);
                });
            }),
            destroy: function destroy() {
                cleanupModifierEffects();
                isDestroyed = true;
            }
        };
        if (!$8e357be334f3fad9$var$areValidElements(reference, popper)) return instance;
        instance.setOptions(options).then(function(state) {
            if (!isDestroyed && options.onFirstUpdate) options.onFirstUpdate(state);
        }); // Modifiers have the ability to execute arbitrary code before the first
        // update cycle runs. They will be executed in the same order as the update
        // cycle. This is useful when a modifier adds some persistent data that
        // other modifiers need to use, but the modifier is run after the dependent
        // one.
        function runModifierEffects() {
            state.orderedModifiers.forEach(function(_ref) {
                var name = _ref.name, _ref$options = _ref.options, options = _ref$options === void 0 ? {} : _ref$options, effect = _ref.effect;
                if (typeof effect === 'function') {
                    var cleanupFn = effect({
                        state: state,
                        name: name,
                        instance: instance,
                        options: options
                    });
                    var noopFn = function noopFn() {};
                    effectCleanupFns.push(cleanupFn || noopFn);
                }
            });
        }
        function cleanupModifierEffects() {
            effectCleanupFns.forEach(function(fn) {
                return fn();
            });
            effectCleanupFns = [];
        }
        return instance;
    };
}
var $8e357be334f3fad9$export$8f7491d57c8f97a9 = /*#__PURE__*/ $8e357be334f3fad9$export$ed5e13716264f202(); // eslint-disable-next-line import/no-unused-modules



var $e3348dc516600e8b$var$passive = {
    passive: true
};
function $e3348dc516600e8b$var$effect(_ref) {
    var state = _ref.state, instance = _ref.instance, options = _ref.options;
    var _options$scroll = options.scroll, scroll = _options$scroll === void 0 ? true : _options$scroll, _options$resize = options.resize, resize = _options$resize === void 0 ? true : _options$resize;
    var window = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(state.elements.popper);
    var scrollParents = [].concat(state.scrollParents.reference, state.scrollParents.popper);
    if (scroll) scrollParents.forEach(function(scrollParent) {
        scrollParent.addEventListener('scroll', instance.update, $e3348dc516600e8b$var$passive);
    });
    if (resize) window.addEventListener('resize', instance.update, $e3348dc516600e8b$var$passive);
    return function() {
        if (scroll) scrollParents.forEach(function(scrollParent) {
            scrollParent.removeEventListener('scroll', instance.update, $e3348dc516600e8b$var$passive);
        });
        if (resize) window.removeEventListener('resize', instance.update, $e3348dc516600e8b$var$passive);
    };
} // eslint-disable-next-line import/no-unused-modules
var $e3348dc516600e8b$export$2e2bcd8739ae039 = {
    name: 'eventListeners',
    enabled: true,
    phase: 'write',
    fn: function fn() {},
    effect: $e3348dc516600e8b$var$effect,
    data: {}
};



function $923eec132c8d334b$export$2e2bcd8739ae039(placement) {
    return placement.split('-')[0];
}


function $6572b8fb6297a772$export$2e2bcd8739ae039(placement) {
    return placement.split('-')[1];
}


function $d388da57f90fb762$export$2e2bcd8739ae039(placement) {
    return [
        'top',
        'bottom'
    ].indexOf(placement) >= 0 ? 'x' : 'y';
}



function $05d4a7bd7e0110bf$export$2e2bcd8739ae039(_ref) {
    var reference = _ref.reference, element = _ref.element, placement = _ref.placement;
    var basePlacement = placement ? (0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement) : null;
    var variation = placement ? (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(placement) : null;
    var commonX = reference.x + reference.width / 2 - element.width / 2;
    var commonY = reference.y + reference.height / 2 - element.height / 2;
    var offsets;
    switch(basePlacement){
        case 0, $9b56e55559dfbda1$export$1e95b668f3b82d:
            offsets = {
                x: commonX,
                y: reference.y - element.height
            };
            break;
        case 0, $9b56e55559dfbda1$export$40e543e69a8b3fbb:
            offsets = {
                x: commonX,
                y: reference.y + reference.height
            };
            break;
        case 0, $9b56e55559dfbda1$export$79ffe56a765070d2:
            offsets = {
                x: reference.x + reference.width,
                y: commonY
            };
            break;
        case 0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4:
            offsets = {
                x: reference.x - element.width,
                y: commonY
            };
            break;
        default:
            offsets = {
                x: reference.x,
                y: reference.y
            };
    }
    var mainAxis = basePlacement ? (0, $d388da57f90fb762$export$2e2bcd8739ae039)(basePlacement) : null;
    if (mainAxis != null) {
        var len = mainAxis === 'y' ? 'height' : 'width';
        switch(variation){
            case 0, $9b56e55559dfbda1$export$b3571188c770cc5a:
                offsets[mainAxis] = offsets[mainAxis] - (reference[len] / 2 - element[len] / 2);
                break;
            case 0, $9b56e55559dfbda1$export$bd5df0f255a350f8:
                offsets[mainAxis] = offsets[mainAxis] + (reference[len] / 2 - element[len] / 2);
                break;
            default:
        }
    }
    return offsets;
}


function $4aa27a7a3db85746$var$popperOffsets(_ref) {
    var state = _ref.state, name = _ref.name;
    // Offsets are the actual position the popper needs to have to be
    // properly positioned near its reference element
    // This is the most basic placement, and will be adjusted by
    // the modifiers in the next step
    state.modifiersData[name] = (0, $05d4a7bd7e0110bf$export$2e2bcd8739ae039)({
        reference: state.rects.reference,
        element: state.rects.popper,
        strategy: 'absolute',
        placement: state.placement
    });
} // eslint-disable-next-line import/no-unused-modules
var $4aa27a7a3db85746$export$2e2bcd8739ae039 = {
    name: 'popperOffsets',
    enabled: true,
    phase: 'read',
    fn: $4aa27a7a3db85746$var$popperOffsets,
    data: {}
};










var $03e421bdaa8eda14$var$unsetSides = {
    top: 'auto',
    right: 'auto',
    bottom: 'auto',
    left: 'auto'
}; // Round the offsets to the nearest suitable subpixel based on the DPR.
// Zooming can change the DPR, but it seems to report a value that will
// cleanly divide the values into the appropriate subpixels.
function $03e421bdaa8eda14$var$roundOffsetsByDPR(_ref, win) {
    var x = _ref.x, y = _ref.y;
    var dpr = win.devicePixelRatio || 1;
    return {
        x: (0, $a435872b5ba665df$export$2077e0241d6afd3c)(x * dpr) / dpr || 0,
        y: (0, $a435872b5ba665df$export$2077e0241d6afd3c)(y * dpr) / dpr || 0
    };
}
function $03e421bdaa8eda14$export$378fa78a8fea596f(_ref2) {
    var _Object$assign2;
    var popper = _ref2.popper, popperRect = _ref2.popperRect, placement = _ref2.placement, variation = _ref2.variation, offsets = _ref2.offsets, position = _ref2.position, gpuAcceleration = _ref2.gpuAcceleration, adaptive = _ref2.adaptive, roundOffsets = _ref2.roundOffsets, isFixed = _ref2.isFixed;
    var _offsets$x = offsets.x, x = _offsets$x === void 0 ? 0 : _offsets$x, _offsets$y = offsets.y, y = _offsets$y === void 0 ? 0 : _offsets$y;
    var _ref3 = typeof roundOffsets === 'function' ? roundOffsets({
        x: x,
        y: y
    }) : {
        x: x,
        y: y
    };
    x = _ref3.x;
    y = _ref3.y;
    var hasX = offsets.hasOwnProperty('x');
    var hasY = offsets.hasOwnProperty('y');
    var sideX = (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4);
    var sideY = (0, $9b56e55559dfbda1$export$1e95b668f3b82d);
    var win = window;
    if (adaptive) {
        var offsetParent = (0, $4acba801a6bfbaa3$export$2e2bcd8739ae039)(popper);
        var heightProp = 'clientHeight';
        var widthProp = 'clientWidth';
        if (offsetParent === (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(popper)) {
            offsetParent = (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(popper);
            if ((0, $392247934674b5b4$export$2e2bcd8739ae039)(offsetParent).position !== 'static' && position === 'absolute') {
                heightProp = 'scrollHeight';
                widthProp = 'scrollWidth';
            }
        } // $FlowFixMe[incompatible-cast]: force type refinement, we compare offsetParent with window above, but Flow doesn't detect it
        offsetParent;
        if (placement === (0, $9b56e55559dfbda1$export$1e95b668f3b82d) || (placement === (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4) || placement === (0, $9b56e55559dfbda1$export$79ffe56a765070d2)) && variation === (0, $9b56e55559dfbda1$export$bd5df0f255a350f8)) {
            sideY = (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb);
            var offsetY = isFixed && offsetParent === win && win.visualViewport ? win.visualViewport.height : offsetParent[heightProp];
            y -= offsetY - popperRect.height;
            y *= gpuAcceleration ? 1 : -1;
        }
        if (placement === (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4) || (placement === (0, $9b56e55559dfbda1$export$1e95b668f3b82d) || placement === (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb)) && variation === (0, $9b56e55559dfbda1$export$bd5df0f255a350f8)) {
            sideX = (0, $9b56e55559dfbda1$export$79ffe56a765070d2);
            var offsetX = isFixed && offsetParent === win && win.visualViewport ? win.visualViewport.width : offsetParent[widthProp];
            x -= offsetX - popperRect.width;
            x *= gpuAcceleration ? 1 : -1;
        }
    }
    var commonStyles = Object.assign({
        position: position
    }, adaptive && $03e421bdaa8eda14$var$unsetSides);
    var _ref4 = roundOffsets === true ? $03e421bdaa8eda14$var$roundOffsetsByDPR({
        x: x,
        y: y
    }, (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(popper)) : {
        x: x,
        y: y
    };
    x = _ref4.x;
    y = _ref4.y;
    if (gpuAcceleration) {
        var _Object$assign;
        return Object.assign({}, commonStyles, (_Object$assign = {}, _Object$assign[sideY] = hasY ? '0' : '', _Object$assign[sideX] = hasX ? '0' : '', _Object$assign.transform = (win.devicePixelRatio || 1) <= 1 ? "translate(" + x + "px, " + y + "px)" : "translate3d(" + x + "px, " + y + "px, 0)", _Object$assign));
    }
    return Object.assign({}, commonStyles, (_Object$assign2 = {}, _Object$assign2[sideY] = hasY ? y + "px" : '', _Object$assign2[sideX] = hasX ? x + "px" : '', _Object$assign2.transform = '', _Object$assign2));
}
function $03e421bdaa8eda14$var$computeStyles(_ref5) {
    var state = _ref5.state, options = _ref5.options;
    var _options$gpuAccelerat = options.gpuAcceleration, gpuAcceleration = _options$gpuAccelerat === void 0 ? true : _options$gpuAccelerat, _options$adaptive = options.adaptive, adaptive = _options$adaptive === void 0 ? true : _options$adaptive, _options$roundOffsets = options.roundOffsets, roundOffsets = _options$roundOffsets === void 0 ? true : _options$roundOffsets;
    var commonStyles = {
        placement: (0, $923eec132c8d334b$export$2e2bcd8739ae039)(state.placement),
        variation: (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(state.placement),
        popper: state.elements.popper,
        popperRect: state.rects.popper,
        gpuAcceleration: gpuAcceleration,
        isFixed: state.options.strategy === 'fixed'
    };
    if (state.modifiersData.popperOffsets != null) state.styles.popper = Object.assign({}, state.styles.popper, $03e421bdaa8eda14$export$378fa78a8fea596f(Object.assign({}, commonStyles, {
        offsets: state.modifiersData.popperOffsets,
        position: state.options.strategy,
        adaptive: adaptive,
        roundOffsets: roundOffsets
    })));
    if (state.modifiersData.arrow != null) state.styles.arrow = Object.assign({}, state.styles.arrow, $03e421bdaa8eda14$export$378fa78a8fea596f(Object.assign({}, commonStyles, {
        offsets: state.modifiersData.arrow,
        position: 'absolute',
        adaptive: false,
        roundOffsets: roundOffsets
    })));
    state.attributes.popper = Object.assign({}, state.attributes.popper, {
        'data-popper-placement': state.placement
    });
} // eslint-disable-next-line import/no-unused-modules
var $03e421bdaa8eda14$export$2e2bcd8739ae039 = {
    name: 'computeStyles',
    enabled: true,
    phase: 'beforeWrite',
    fn: $03e421bdaa8eda14$var$computeStyles,
    data: {}
};





function $b2dec03e76957d70$export$7fa02d8595b015ed(placement, rects, offset) {
    var basePlacement = (0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement);
    var invertDistance = [
        (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4),
        (0, $9b56e55559dfbda1$export$1e95b668f3b82d)
    ].indexOf(basePlacement) >= 0 ? -1 : 1;
    var _ref = typeof offset === 'function' ? offset(Object.assign({}, rects, {
        placement: placement
    })) : offset, skidding = _ref[0], distance = _ref[1];
    skidding = skidding || 0;
    distance = (distance || 0) * invertDistance;
    return [
        (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4),
        (0, $9b56e55559dfbda1$export$79ffe56a765070d2)
    ].indexOf(basePlacement) >= 0 ? {
        x: distance,
        y: skidding
    } : {
        x: skidding,
        y: distance
    };
}
function $b2dec03e76957d70$var$offset(_ref2) {
    var state = _ref2.state, options = _ref2.options, name = _ref2.name;
    var _options$offset = options.offset, offset = _options$offset === void 0 ? [
        0,
        0
    ] : _options$offset;
    var data = (0, $9b56e55559dfbda1$export$803cd8101b6c182b).reduce(function(acc, placement) {
        acc[placement] = $b2dec03e76957d70$export$7fa02d8595b015ed(placement, state.rects, offset);
        return acc;
    }, {});
    var _data$state$placement = data[state.placement], x = _data$state$placement.x, y = _data$state$placement.y;
    if (state.modifiersData.popperOffsets != null) {
        state.modifiersData.popperOffsets.x += x;
        state.modifiersData.popperOffsets.y += y;
    }
    state.modifiersData[name] = data;
} // eslint-disable-next-line import/no-unused-modules
var $b2dec03e76957d70$export$2e2bcd8739ae039 = {
    name: 'offset',
    enabled: true,
    phase: 'main',
    requires: [
        'popperOffsets'
    ],
    fn: $b2dec03e76957d70$var$offset
};


var $e21601d0082602f5$var$hash = {
    left: 'right',
    right: 'left',
    bottom: 'top',
    top: 'bottom'
};
function $e21601d0082602f5$export$2e2bcd8739ae039(placement) {
    return placement.replace(/left|right|bottom|top/g, function(matched) {
        return $e21601d0082602f5$var$hash[matched];
    });
}



var $e23a845ff98433e2$var$hash = {
    start: 'end',
    end: 'start'
};
function $e23a845ff98433e2$export$2e2bcd8739ae039(placement) {
    return placement.replace(/start|end/g, function(matched) {
        return $e23a845ff98433e2$var$hash[matched];
    });
}







function $ed6afea5d5a4d314$export$2e2bcd8739ae039(element, strategy) {
    var win = (0, $f41f4520bee001a7$export$2e2bcd8739ae039)(element);
    var html = (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(element);
    var visualViewport = win.visualViewport;
    var width = html.clientWidth;
    var height = html.clientHeight;
    var x = 0;
    var y = 0;
    if (visualViewport) {
        width = visualViewport.width;
        height = visualViewport.height;
        var layoutViewport = (0, $f6bdda075fc14cbf$export$2e2bcd8739ae039)();
        if (layoutViewport || !layoutViewport && strategy === 'fixed') {
            x = visualViewport.offsetLeft;
            y = visualViewport.offsetTop;
        }
    }
    return {
        width: width,
        height: height,
        x: x + (0, $05804587c501a8a1$export$2e2bcd8739ae039)(element),
        y: y
    };
}







function $048158ac5222e515$export$2e2bcd8739ae039(element) {
    var _element$ownerDocumen;
    var html = (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(element);
    var winScroll = (0, $2f82ac4f0d5b4512$export$2e2bcd8739ae039)(element);
    var body = (_element$ownerDocumen = element.ownerDocument) == null ? void 0 : _element$ownerDocumen.body;
    var width = (0, $a435872b5ba665df$export$8960430cfd85939f)(html.scrollWidth, html.clientWidth, body ? body.scrollWidth : 0, body ? body.clientWidth : 0);
    var height = (0, $a435872b5ba665df$export$8960430cfd85939f)(html.scrollHeight, html.clientHeight, body ? body.scrollHeight : 0, body ? body.clientHeight : 0);
    var x = -winScroll.scrollLeft + (0, $05804587c501a8a1$export$2e2bcd8739ae039)(element);
    var y = -winScroll.scrollTop;
    if ((0, $392247934674b5b4$export$2e2bcd8739ae039)(body || html).direction === 'rtl') x += (0, $a435872b5ba665df$export$8960430cfd85939f)(html.clientWidth, body ? body.clientWidth : 0) - width;
    return {
        width: width,
        height: height,
        x: x,
        y: y
    };
}










function $d1f185f47d247fa7$export$2e2bcd8739ae039(parent, child) {
    var rootNode = child.getRootNode && child.getRootNode(); // First, attempt with faster native method
    if (parent.contains(child)) return true;
    else if (rootNode && (0, $1fa2a5446b18c455$export$af51f0f06c0f328a)(rootNode)) {
        var next = child;
        do {
            if (next && parent.isSameNode(next)) return true;
             // $FlowFixMe[prop-missing]: need a better way to handle this...
            next = next.parentNode || next.host;
        }while (next);
    } // Give up, the result is false
    return false;
}



function $611b7cfc3d40c8f5$export$2e2bcd8739ae039(rect) {
    return Object.assign({}, rect, {
        left: rect.x,
        top: rect.y,
        right: rect.x + rect.width,
        bottom: rect.y + rect.height
    });
}



function $1ae21a55ad42cc80$var$getInnerBoundingClientRect(element, strategy) {
    var rect = (0, $b854957821c00430$export$2e2bcd8739ae039)(element, false, strategy === 'fixed');
    rect.top = rect.top + element.clientTop;
    rect.left = rect.left + element.clientLeft;
    rect.bottom = rect.top + element.clientHeight;
    rect.right = rect.left + element.clientWidth;
    rect.width = element.clientWidth;
    rect.height = element.clientHeight;
    rect.x = rect.left;
    rect.y = rect.top;
    return rect;
}
function $1ae21a55ad42cc80$var$getClientRectFromMixedType(element, clippingParent, strategy) {
    return clippingParent === (0, $9b56e55559dfbda1$export$d7b7311ec04a3e8f) ? (0, $611b7cfc3d40c8f5$export$2e2bcd8739ae039)((0, $ed6afea5d5a4d314$export$2e2bcd8739ae039)(element, strategy)) : (0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(clippingParent) ? $1ae21a55ad42cc80$var$getInnerBoundingClientRect(clippingParent, strategy) : (0, $611b7cfc3d40c8f5$export$2e2bcd8739ae039)((0, $048158ac5222e515$export$2e2bcd8739ae039)((0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(element)));
} // A "clipping parent" is an overflowable container with the characteristic of
// clipping (or hiding) overflowing elements with a position different from
// `initial`
function $1ae21a55ad42cc80$var$getClippingParents(element) {
    var clippingParents = (0, $f14b4e1cd31512ee$export$2e2bcd8739ae039)((0, $b1adb38089003474$export$2e2bcd8739ae039)(element));
    var canEscapeClipping = [
        'absolute',
        'fixed'
    ].indexOf((0, $392247934674b5b4$export$2e2bcd8739ae039)(element).position) >= 0;
    var clipperElement = canEscapeClipping && (0, $1fa2a5446b18c455$export$1b3bfaa9684536aa)(element) ? (0, $4acba801a6bfbaa3$export$2e2bcd8739ae039)(element) : element;
    if (!(0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(clipperElement)) return [];
     // $FlowFixMe[incompatible-return]: https://github.com/facebook/flow/issues/1414
    return clippingParents.filter(function(clippingParent) {
        return (0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(clippingParent) && (0, $d1f185f47d247fa7$export$2e2bcd8739ae039)(clippingParent, clipperElement) && (0, $59d97a6bab2b727e$export$2e2bcd8739ae039)(clippingParent) !== 'body';
    });
} // Gets the maximum area that the element is visible in due to any number of
function $1ae21a55ad42cc80$export$2e2bcd8739ae039(element, boundary, rootBoundary, strategy) {
    var mainClippingParents = boundary === 'clippingParents' ? $1ae21a55ad42cc80$var$getClippingParents(element) : [].concat(boundary);
    var clippingParents = [].concat(mainClippingParents, [
        rootBoundary
    ]);
    var firstClippingParent = clippingParents[0];
    var clippingRect = clippingParents.reduce(function(accRect, clippingParent) {
        var rect = $1ae21a55ad42cc80$var$getClientRectFromMixedType(element, clippingParent, strategy);
        accRect.top = (0, $a435872b5ba665df$export$8960430cfd85939f)(rect.top, accRect.top);
        accRect.right = (0, $a435872b5ba665df$export$96ec731ed4dcb222)(rect.right, accRect.right);
        accRect.bottom = (0, $a435872b5ba665df$export$96ec731ed4dcb222)(rect.bottom, accRect.bottom);
        accRect.left = (0, $a435872b5ba665df$export$8960430cfd85939f)(rect.left, accRect.left);
        return accRect;
    }, $1ae21a55ad42cc80$var$getClientRectFromMixedType(element, firstClippingParent, strategy));
    clippingRect.width = clippingRect.right - clippingRect.left;
    clippingRect.height = clippingRect.bottom - clippingRect.top;
    clippingRect.x = clippingRect.left;
    clippingRect.y = clippingRect.top;
    return clippingRect;
}








function $d245fd553c91b4b7$export$2e2bcd8739ae039() {
    return {
        top: 0,
        right: 0,
        bottom: 0,
        left: 0
    };
}


function $4867192599152955$export$2e2bcd8739ae039(paddingObject) {
    return Object.assign({}, (0, $d245fd553c91b4b7$export$2e2bcd8739ae039)(), paddingObject);
}


function $f5b522f3e076d616$export$2e2bcd8739ae039(value, keys) {
    return keys.reduce(function(hashMap, key) {
        hashMap[key] = value;
        return hashMap;
    }, {});
}


function $223e3075705edc49$export$2e2bcd8739ae039(state, options) {
    if (options === void 0) options = {};
    var _options = options, _options$placement = _options.placement, placement = _options$placement === void 0 ? state.placement : _options$placement, _options$strategy = _options.strategy, strategy = _options$strategy === void 0 ? state.strategy : _options$strategy, _options$boundary = _options.boundary, boundary = _options$boundary === void 0 ? (0, $9b56e55559dfbda1$export$390fd549c5303b4d) : _options$boundary, _options$rootBoundary = _options.rootBoundary, rootBoundary = _options$rootBoundary === void 0 ? (0, $9b56e55559dfbda1$export$d7b7311ec04a3e8f) : _options$rootBoundary, _options$elementConte = _options.elementContext, elementContext = _options$elementConte === void 0 ? (0, $9b56e55559dfbda1$export$ae5ab1c730825774) : _options$elementConte, _options$altBoundary = _options.altBoundary, altBoundary = _options$altBoundary === void 0 ? false : _options$altBoundary, _options$padding = _options.padding, padding = _options$padding === void 0 ? 0 : _options$padding;
    var paddingObject = (0, $4867192599152955$export$2e2bcd8739ae039)(typeof padding !== 'number' ? padding : (0, $f5b522f3e076d616$export$2e2bcd8739ae039)(padding, (0, $9b56e55559dfbda1$export$aec2ce47c367b8c3)));
    var altContext = elementContext === (0, $9b56e55559dfbda1$export$ae5ab1c730825774) ? (0, $9b56e55559dfbda1$export$ca50aac9f3ba507f) : (0, $9b56e55559dfbda1$export$ae5ab1c730825774);
    var popperRect = state.rects.popper;
    var element = state.elements[altBoundary ? altContext : elementContext];
    var clippingClientRect = (0, $1ae21a55ad42cc80$export$2e2bcd8739ae039)((0, $1fa2a5446b18c455$export$45a5e7f76e0caa8d)(element) ? element : element.contextElement || (0, $3e02d6708e2a16ac$export$2e2bcd8739ae039)(state.elements.popper), boundary, rootBoundary, strategy);
    var referenceClientRect = (0, $b854957821c00430$export$2e2bcd8739ae039)(state.elements.reference);
    var popperOffsets = (0, $05d4a7bd7e0110bf$export$2e2bcd8739ae039)({
        reference: referenceClientRect,
        element: popperRect,
        strategy: 'absolute',
        placement: placement
    });
    var popperClientRect = (0, $611b7cfc3d40c8f5$export$2e2bcd8739ae039)(Object.assign({}, popperRect, popperOffsets));
    var elementClientRect = elementContext === (0, $9b56e55559dfbda1$export$ae5ab1c730825774) ? popperClientRect : referenceClientRect; // positive = overflowing the clipping rect
    // 0 or negative = within the clipping rect
    var overflowOffsets = {
        top: clippingClientRect.top - elementClientRect.top + paddingObject.top,
        bottom: elementClientRect.bottom - clippingClientRect.bottom + paddingObject.bottom,
        left: clippingClientRect.left - elementClientRect.left + paddingObject.left,
        right: elementClientRect.right - clippingClientRect.right + paddingObject.right
    };
    var offsetData = state.modifiersData.offset; // Offsets can be applied only to the popper element
    if (elementContext === (0, $9b56e55559dfbda1$export$ae5ab1c730825774) && offsetData) {
        var offset = offsetData[placement];
        Object.keys(overflowOffsets).forEach(function(key) {
            var multiply = [
                (0, $9b56e55559dfbda1$export$79ffe56a765070d2),
                (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb)
            ].indexOf(key) >= 0 ? 1 : -1;
            var axis = [
                (0, $9b56e55559dfbda1$export$1e95b668f3b82d),
                (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb)
            ].indexOf(key) >= 0 ? 'y' : 'x';
            overflowOffsets[key] += offset[axis] * multiply;
        });
    }
    return overflowOffsets;
}






function $4ec2b0d0092c1820$export$2e2bcd8739ae039(state, options) {
    if (options === void 0) options = {};
    var _options = options, placement = _options.placement, boundary = _options.boundary, rootBoundary = _options.rootBoundary, padding = _options.padding, flipVariations = _options.flipVariations, _options$allowedAutoP = _options.allowedAutoPlacements, allowedAutoPlacements = _options$allowedAutoP === void 0 ? (0, $9b56e55559dfbda1$export$803cd8101b6c182b) : _options$allowedAutoP;
    var variation = (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(placement);
    var placements = variation ? flipVariations ? (0, $9b56e55559dfbda1$export$368f9a87e87fa4e1) : (0, $9b56e55559dfbda1$export$368f9a87e87fa4e1).filter(function(placement) {
        return (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(placement) === variation;
    }) : (0, $9b56e55559dfbda1$export$aec2ce47c367b8c3);
    var allowedPlacements = placements.filter(function(placement) {
        return allowedAutoPlacements.indexOf(placement) >= 0;
    });
    if (allowedPlacements.length === 0) allowedPlacements = placements;
     // $FlowFixMe[incompatible-type]: Flow seems to have problems with two array unions...
    var overflows = allowedPlacements.reduce(function(acc, placement) {
        acc[placement] = (0, $223e3075705edc49$export$2e2bcd8739ae039)(state, {
            placement: placement,
            boundary: boundary,
            rootBoundary: rootBoundary,
            padding: padding
        })[(0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement)];
        return acc;
    }, {});
    return Object.keys(overflows).sort(function(a, b) {
        return overflows[a] - overflows[b];
    });
}




function $d886080699dc4994$var$getExpandedFallbackPlacements(placement) {
    if ((0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement) === (0, $9b56e55559dfbda1$export$dfb5619354ba860)) return [];
    var oppositePlacement = (0, $e21601d0082602f5$export$2e2bcd8739ae039)(placement);
    return [
        (0, $e23a845ff98433e2$export$2e2bcd8739ae039)(placement),
        oppositePlacement,
        (0, $e23a845ff98433e2$export$2e2bcd8739ae039)(oppositePlacement)
    ];
}
function $d886080699dc4994$var$flip(_ref) {
    var state = _ref.state, options = _ref.options, name = _ref.name;
    if (state.modifiersData[name]._skip) return;
    var _options$mainAxis = options.mainAxis, checkMainAxis = _options$mainAxis === void 0 ? true : _options$mainAxis, _options$altAxis = options.altAxis, checkAltAxis = _options$altAxis === void 0 ? true : _options$altAxis, specifiedFallbackPlacements = options.fallbackPlacements, padding = options.padding, boundary = options.boundary, rootBoundary = options.rootBoundary, altBoundary = options.altBoundary, _options$flipVariatio = options.flipVariations, flipVariations = _options$flipVariatio === void 0 ? true : _options$flipVariatio, allowedAutoPlacements = options.allowedAutoPlacements;
    var preferredPlacement = state.options.placement;
    var basePlacement = (0, $923eec132c8d334b$export$2e2bcd8739ae039)(preferredPlacement);
    var isBasePlacement = basePlacement === preferredPlacement;
    var fallbackPlacements = specifiedFallbackPlacements || (isBasePlacement || !flipVariations ? [
        (0, $e21601d0082602f5$export$2e2bcd8739ae039)(preferredPlacement)
    ] : $d886080699dc4994$var$getExpandedFallbackPlacements(preferredPlacement));
    var placements = [
        preferredPlacement
    ].concat(fallbackPlacements).reduce(function(acc, placement) {
        return acc.concat((0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement) === (0, $9b56e55559dfbda1$export$dfb5619354ba860) ? (0, $4ec2b0d0092c1820$export$2e2bcd8739ae039)(state, {
            placement: placement,
            boundary: boundary,
            rootBoundary: rootBoundary,
            padding: padding,
            flipVariations: flipVariations,
            allowedAutoPlacements: allowedAutoPlacements
        }) : placement);
    }, []);
    var referenceRect = state.rects.reference;
    var popperRect = state.rects.popper;
    var checksMap = new Map();
    var makeFallbackChecks = true;
    var firstFittingPlacement = placements[0];
    for(var i = 0; i < placements.length; i++){
        var placement = placements[i];
        var _basePlacement = (0, $923eec132c8d334b$export$2e2bcd8739ae039)(placement);
        var isStartVariation = (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(placement) === (0, $9b56e55559dfbda1$export$b3571188c770cc5a);
        var isVertical = [
            (0, $9b56e55559dfbda1$export$1e95b668f3b82d),
            (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb)
        ].indexOf(_basePlacement) >= 0;
        var len = isVertical ? 'width' : 'height';
        var overflow = (0, $223e3075705edc49$export$2e2bcd8739ae039)(state, {
            placement: placement,
            boundary: boundary,
            rootBoundary: rootBoundary,
            altBoundary: altBoundary,
            padding: padding
        });
        var mainVariationSide = isVertical ? isStartVariation ? (0, $9b56e55559dfbda1$export$79ffe56a765070d2) : (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4) : isStartVariation ? (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb) : (0, $9b56e55559dfbda1$export$1e95b668f3b82d);
        if (referenceRect[len] > popperRect[len]) mainVariationSide = (0, $e21601d0082602f5$export$2e2bcd8739ae039)(mainVariationSide);
        var altVariationSide = (0, $e21601d0082602f5$export$2e2bcd8739ae039)(mainVariationSide);
        var checks = [];
        if (checkMainAxis) checks.push(overflow[_basePlacement] <= 0);
        if (checkAltAxis) checks.push(overflow[mainVariationSide] <= 0, overflow[altVariationSide] <= 0);
        if (checks.every(function(check) {
            return check;
        })) {
            firstFittingPlacement = placement;
            makeFallbackChecks = false;
            break;
        }
        checksMap.set(placement, checks);
    }
    if (makeFallbackChecks) {
        // `2` may be desired in some cases – research later
        var numberOfChecks = flipVariations ? 3 : 1;
        var _loop = function _loop(_i) {
            var fittingPlacement = placements.find(function(placement) {
                var checks = checksMap.get(placement);
                if (checks) return checks.slice(0, _i).every(function(check) {
                    return check;
                });
            });
            if (fittingPlacement) {
                firstFittingPlacement = fittingPlacement;
                return "break";
            }
        };
        for(var _i = numberOfChecks; _i > 0; _i--){
            var _ret = _loop(_i);
            if (_ret === "break") break;
        }
    }
    if (state.placement !== firstFittingPlacement) {
        state.modifiersData[name]._skip = true;
        state.placement = firstFittingPlacement;
        state.reset = true;
    }
} // eslint-disable-next-line import/no-unused-modules
var $d886080699dc4994$export$2e2bcd8739ae039 = {
    name: 'flip',
    enabled: true,
    phase: 'main',
    fn: $d886080699dc4994$var$flip,
    requiresIfExists: [
        'offset'
    ],
    data: {
        _skip: false
    }
};





function $635c62073241bcfb$export$2e2bcd8739ae039(axis) {
    return axis === 'x' ? 'y' : 'x';
}



function $bced921644bd7e12$export$f28d906d67a997f3(min, value, max) {
    return (0, $a435872b5ba665df$export$8960430cfd85939f)(min, (0, $a435872b5ba665df$export$96ec731ed4dcb222)(value, max));
}
function $bced921644bd7e12$export$86c8af6d3ef0b4a(min, value, max) {
    var v = $bced921644bd7e12$export$f28d906d67a997f3(min, value, max);
    return v > max ? max : v;
}








function $59ad2e7a9286a2b9$var$preventOverflow(_ref) {
    var state = _ref.state, options = _ref.options, name = _ref.name;
    var _options$mainAxis = options.mainAxis, checkMainAxis = _options$mainAxis === void 0 ? true : _options$mainAxis, _options$altAxis = options.altAxis, checkAltAxis = _options$altAxis === void 0 ? false : _options$altAxis, boundary = options.boundary, rootBoundary = options.rootBoundary, altBoundary = options.altBoundary, padding = options.padding, _options$tether = options.tether, tether = _options$tether === void 0 ? true : _options$tether, _options$tetherOffset = options.tetherOffset, tetherOffset = _options$tetherOffset === void 0 ? 0 : _options$tetherOffset;
    var overflow = (0, $223e3075705edc49$export$2e2bcd8739ae039)(state, {
        boundary: boundary,
        rootBoundary: rootBoundary,
        padding: padding,
        altBoundary: altBoundary
    });
    var basePlacement = (0, $923eec132c8d334b$export$2e2bcd8739ae039)(state.placement);
    var variation = (0, $6572b8fb6297a772$export$2e2bcd8739ae039)(state.placement);
    var isBasePlacement = !variation;
    var mainAxis = (0, $d388da57f90fb762$export$2e2bcd8739ae039)(basePlacement);
    var altAxis = (0, $635c62073241bcfb$export$2e2bcd8739ae039)(mainAxis);
    var popperOffsets = state.modifiersData.popperOffsets;
    var referenceRect = state.rects.reference;
    var popperRect = state.rects.popper;
    var tetherOffsetValue = typeof tetherOffset === 'function' ? tetherOffset(Object.assign({}, state.rects, {
        placement: state.placement
    })) : tetherOffset;
    var normalizedTetherOffsetValue = typeof tetherOffsetValue === 'number' ? {
        mainAxis: tetherOffsetValue,
        altAxis: tetherOffsetValue
    } : Object.assign({
        mainAxis: 0,
        altAxis: 0
    }, tetherOffsetValue);
    var offsetModifierState = state.modifiersData.offset ? state.modifiersData.offset[state.placement] : null;
    var data = {
        x: 0,
        y: 0
    };
    if (!popperOffsets) return;
    if (checkMainAxis) {
        var _offsetModifierState$;
        var mainSide = mainAxis === 'y' ? (0, $9b56e55559dfbda1$export$1e95b668f3b82d) : (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4);
        var altSide = mainAxis === 'y' ? (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb) : (0, $9b56e55559dfbda1$export$79ffe56a765070d2);
        var len = mainAxis === 'y' ? 'height' : 'width';
        var offset = popperOffsets[mainAxis];
        var min = offset + overflow[mainSide];
        var max = offset - overflow[altSide];
        var additive = tether ? -popperRect[len] / 2 : 0;
        var minLen = variation === (0, $9b56e55559dfbda1$export$b3571188c770cc5a) ? referenceRect[len] : popperRect[len];
        var maxLen = variation === (0, $9b56e55559dfbda1$export$b3571188c770cc5a) ? -popperRect[len] : -referenceRect[len]; // We need to include the arrow in the calculation so the arrow doesn't go
        // outside the reference bounds
        var arrowElement = state.elements.arrow;
        var arrowRect = tether && arrowElement ? (0, $e287ac773d355028$export$2e2bcd8739ae039)(arrowElement) : {
            width: 0,
            height: 0
        };
        var arrowPaddingObject = state.modifiersData['arrow#persistent'] ? state.modifiersData['arrow#persistent'].padding : (0, $d245fd553c91b4b7$export$2e2bcd8739ae039)();
        var arrowPaddingMin = arrowPaddingObject[mainSide];
        var arrowPaddingMax = arrowPaddingObject[altSide]; // If the reference length is smaller than the arrow length, we don't want
        // to include its full size in the calculation. If the reference is small
        // and near the edge of a boundary, the popper can overflow even if the
        // reference is not overflowing as well (e.g. virtual elements with no
        // width or height)
        var arrowLen = (0, $bced921644bd7e12$export$f28d906d67a997f3)(0, referenceRect[len], arrowRect[len]);
        var minOffset = isBasePlacement ? referenceRect[len] / 2 - additive - arrowLen - arrowPaddingMin - normalizedTetherOffsetValue.mainAxis : minLen - arrowLen - arrowPaddingMin - normalizedTetherOffsetValue.mainAxis;
        var maxOffset = isBasePlacement ? -referenceRect[len] / 2 + additive + arrowLen + arrowPaddingMax + normalizedTetherOffsetValue.mainAxis : maxLen + arrowLen + arrowPaddingMax + normalizedTetherOffsetValue.mainAxis;
        var arrowOffsetParent = state.elements.arrow && (0, $4acba801a6bfbaa3$export$2e2bcd8739ae039)(state.elements.arrow);
        var clientOffset = arrowOffsetParent ? mainAxis === 'y' ? arrowOffsetParent.clientTop || 0 : arrowOffsetParent.clientLeft || 0 : 0;
        var offsetModifierValue = (_offsetModifierState$ = offsetModifierState == null ? void 0 : offsetModifierState[mainAxis]) != null ? _offsetModifierState$ : 0;
        var tetherMin = offset + minOffset - offsetModifierValue - clientOffset;
        var tetherMax = offset + maxOffset - offsetModifierValue;
        var preventedOffset = (0, $bced921644bd7e12$export$f28d906d67a997f3)(tether ? (0, $a435872b5ba665df$export$96ec731ed4dcb222)(min, tetherMin) : min, offset, tether ? (0, $a435872b5ba665df$export$8960430cfd85939f)(max, tetherMax) : max);
        popperOffsets[mainAxis] = preventedOffset;
        data[mainAxis] = preventedOffset - offset;
    }
    if (checkAltAxis) {
        var _offsetModifierState$2;
        var _mainSide = mainAxis === 'x' ? (0, $9b56e55559dfbda1$export$1e95b668f3b82d) : (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4);
        var _altSide = mainAxis === 'x' ? (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb) : (0, $9b56e55559dfbda1$export$79ffe56a765070d2);
        var _offset = popperOffsets[altAxis];
        var _len = altAxis === 'y' ? 'height' : 'width';
        var _min = _offset + overflow[_mainSide];
        var _max = _offset - overflow[_altSide];
        var isOriginSide = [
            (0, $9b56e55559dfbda1$export$1e95b668f3b82d),
            (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4)
        ].indexOf(basePlacement) !== -1;
        var _offsetModifierValue = (_offsetModifierState$2 = offsetModifierState == null ? void 0 : offsetModifierState[altAxis]) != null ? _offsetModifierState$2 : 0;
        var _tetherMin = isOriginSide ? _min : _offset - referenceRect[_len] - popperRect[_len] - _offsetModifierValue + normalizedTetherOffsetValue.altAxis;
        var _tetherMax = isOriginSide ? _offset + referenceRect[_len] + popperRect[_len] - _offsetModifierValue - normalizedTetherOffsetValue.altAxis : _max;
        var _preventedOffset = tether && isOriginSide ? (0, $bced921644bd7e12$export$86c8af6d3ef0b4a)(_tetherMin, _offset, _tetherMax) : (0, $bced921644bd7e12$export$f28d906d67a997f3)(tether ? _tetherMin : _min, _offset, tether ? _tetherMax : _max);
        popperOffsets[altAxis] = _preventedOffset;
        data[altAxis] = _preventedOffset - _offset;
    }
    state.modifiersData[name] = data;
} // eslint-disable-next-line import/no-unused-modules
var $59ad2e7a9286a2b9$export$2e2bcd8739ae039 = {
    name: 'preventOverflow',
    enabled: true,
    phase: 'main',
    fn: $59ad2e7a9286a2b9$var$preventOverflow,
    requiresIfExists: [
        'offset'
    ]
};











var $84962ce4645f8891$var$toPaddingObject = function toPaddingObject(padding, state) {
    padding = typeof padding === 'function' ? padding(Object.assign({}, state.rects, {
        placement: state.placement
    })) : padding;
    return (0, $4867192599152955$export$2e2bcd8739ae039)(typeof padding !== 'number' ? padding : (0, $f5b522f3e076d616$export$2e2bcd8739ae039)(padding, (0, $9b56e55559dfbda1$export$aec2ce47c367b8c3)));
};
function $84962ce4645f8891$var$arrow(_ref) {
    var _state$modifiersData$;
    var state = _ref.state, name = _ref.name, options = _ref.options;
    var arrowElement = state.elements.arrow;
    var popperOffsets = state.modifiersData.popperOffsets;
    var basePlacement = (0, $923eec132c8d334b$export$2e2bcd8739ae039)(state.placement);
    var axis = (0, $d388da57f90fb762$export$2e2bcd8739ae039)(basePlacement);
    var isVertical = [
        (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4),
        (0, $9b56e55559dfbda1$export$79ffe56a765070d2)
    ].indexOf(basePlacement) >= 0;
    var len = isVertical ? 'height' : 'width';
    if (!arrowElement || !popperOffsets) return;
    var paddingObject = $84962ce4645f8891$var$toPaddingObject(options.padding, state);
    var arrowRect = (0, $e287ac773d355028$export$2e2bcd8739ae039)(arrowElement);
    var minProp = axis === 'y' ? (0, $9b56e55559dfbda1$export$1e95b668f3b82d) : (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4);
    var maxProp = axis === 'y' ? (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb) : (0, $9b56e55559dfbda1$export$79ffe56a765070d2);
    var endDiff = state.rects.reference[len] + state.rects.reference[axis] - popperOffsets[axis] - state.rects.popper[len];
    var startDiff = popperOffsets[axis] - state.rects.reference[axis];
    var arrowOffsetParent = (0, $4acba801a6bfbaa3$export$2e2bcd8739ae039)(arrowElement);
    var clientSize = arrowOffsetParent ? axis === 'y' ? arrowOffsetParent.clientHeight || 0 : arrowOffsetParent.clientWidth || 0 : 0;
    var centerToReference = endDiff / 2 - startDiff / 2; // Make sure the arrow doesn't overflow the popper if the center point is
    // outside of the popper bounds
    var min = paddingObject[minProp];
    var max = clientSize - arrowRect[len] - paddingObject[maxProp];
    var center = clientSize / 2 - arrowRect[len] / 2 + centerToReference;
    var offset = (0, $bced921644bd7e12$export$f28d906d67a997f3)(min, center, max); // Prevents breaking syntax highlighting...
    var axisProp = axis;
    state.modifiersData[name] = (_state$modifiersData$ = {}, _state$modifiersData$[axisProp] = offset, _state$modifiersData$.centerOffset = offset - center, _state$modifiersData$);
}
function $84962ce4645f8891$var$effect(_ref2) {
    var state = _ref2.state, options = _ref2.options;
    var _options$element = options.element, arrowElement = _options$element === void 0 ? '[data-popper-arrow]' : _options$element;
    if (arrowElement == null) return;
     // CSS selector
    if (typeof arrowElement === 'string') {
        arrowElement = state.elements.popper.querySelector(arrowElement);
        if (!arrowElement) return;
    }
    if (!(0, $d1f185f47d247fa7$export$2e2bcd8739ae039)(state.elements.popper, arrowElement)) return;
    state.elements.arrow = arrowElement;
} // eslint-disable-next-line import/no-unused-modules
var $84962ce4645f8891$export$2e2bcd8739ae039 = {
    name: 'arrow',
    enabled: true,
    phase: 'main',
    fn: $84962ce4645f8891$var$arrow,
    effect: $84962ce4645f8891$var$effect,
    requires: [
        'popperOffsets'
    ],
    requiresIfExists: [
        'preventOverflow'
    ]
};




function $c7da519ecac238a3$var$getSideOffsets(overflow, rect, preventedOffsets) {
    if (preventedOffsets === void 0) preventedOffsets = {
        x: 0,
        y: 0
    };
    return {
        top: overflow.top - rect.height - preventedOffsets.y,
        right: overflow.right - rect.width + preventedOffsets.x,
        bottom: overflow.bottom - rect.height + preventedOffsets.y,
        left: overflow.left - rect.width - preventedOffsets.x
    };
}
function $c7da519ecac238a3$var$isAnySideFullyClipped(overflow) {
    return [
        (0, $9b56e55559dfbda1$export$1e95b668f3b82d),
        (0, $9b56e55559dfbda1$export$79ffe56a765070d2),
        (0, $9b56e55559dfbda1$export$40e543e69a8b3fbb),
        (0, $9b56e55559dfbda1$export$eabcd2c8791e7bf4)
    ].some(function(side) {
        return overflow[side] >= 0;
    });
}
function $c7da519ecac238a3$var$hide(_ref) {
    var state = _ref.state, name = _ref.name;
    var referenceRect = state.rects.reference;
    var popperRect = state.rects.popper;
    var preventedOffsets = state.modifiersData.preventOverflow;
    var referenceOverflow = (0, $223e3075705edc49$export$2e2bcd8739ae039)(state, {
        elementContext: 'reference'
    });
    var popperAltOverflow = (0, $223e3075705edc49$export$2e2bcd8739ae039)(state, {
        altBoundary: true
    });
    var referenceClippingOffsets = $c7da519ecac238a3$var$getSideOffsets(referenceOverflow, referenceRect);
    var popperEscapeOffsets = $c7da519ecac238a3$var$getSideOffsets(popperAltOverflow, popperRect, preventedOffsets);
    var isReferenceHidden = $c7da519ecac238a3$var$isAnySideFullyClipped(referenceClippingOffsets);
    var hasPopperEscaped = $c7da519ecac238a3$var$isAnySideFullyClipped(popperEscapeOffsets);
    state.modifiersData[name] = {
        referenceClippingOffsets: referenceClippingOffsets,
        popperEscapeOffsets: popperEscapeOffsets,
        isReferenceHidden: isReferenceHidden,
        hasPopperEscaped: hasPopperEscaped
    };
    state.attributes.popper = Object.assign({}, state.attributes.popper, {
        'data-popper-reference-hidden': isReferenceHidden,
        'data-popper-escaped': hasPopperEscaped
    });
} // eslint-disable-next-line import/no-unused-modules
var $c7da519ecac238a3$export$2e2bcd8739ae039 = {
    name: 'hide',
    enabled: true,
    phase: 'main',
    requiresIfExists: [
        'preventOverflow'
    ],
    fn: $c7da519ecac238a3$var$hide
};




var $d3ca9c4a635d8f8b$export$d34966752335dd47 = [
    (0, $e3348dc516600e8b$export$2e2bcd8739ae039),
    (0, $4aa27a7a3db85746$export$2e2bcd8739ae039),
    (0, $03e421bdaa8eda14$export$2e2bcd8739ae039),
    (0, $dfb41fce0bddd2d8$export$2e2bcd8739ae039),
    (0, $b2dec03e76957d70$export$2e2bcd8739ae039),
    (0, $d886080699dc4994$export$2e2bcd8739ae039),
    (0, $59ad2e7a9286a2b9$export$2e2bcd8739ae039),
    (0, $84962ce4645f8891$export$2e2bcd8739ae039),
    (0, $c7da519ecac238a3$export$2e2bcd8739ae039)
];
var $d3ca9c4a635d8f8b$export$8f7491d57c8f97a9 = /*#__PURE__*/ (0, $8e357be334f3fad9$export$ed5e13716264f202)({
    defaultModifiers: $d3ca9c4a635d8f8b$export$d34966752335dd47
}); // eslint-disable-next-line import/no-unused-modules


var $b013befce1f6217f$export$c96c811c44a42da5 = '<svg width="16" height="6" xmlns="http://www.w3.org/2000/svg"><path d="M0 6s1.796-.013 4.67-3.615C5.851.9 6.93.006 8 0c1.07-.006 2.148.887 3.343 2.385C14.233 6.005 16 6 16 6H0z"></svg>';
var $b013befce1f6217f$var$BOX_CLASS = "tippy-box";
var $b013befce1f6217f$var$CONTENT_CLASS = "tippy-content";
var $b013befce1f6217f$var$BACKDROP_CLASS = "tippy-backdrop";
var $b013befce1f6217f$var$ARROW_CLASS = "tippy-arrow";
var $b013befce1f6217f$var$SVG_ARROW_CLASS = "tippy-svg-arrow";
var $b013befce1f6217f$var$TOUCH_OPTIONS = {
    passive: true,
    capture: true
};
var $b013befce1f6217f$var$TIPPY_DEFAULT_APPEND_TO = function TIPPY_DEFAULT_APPEND_TO() {
    return document.body;
};
function $b013befce1f6217f$var$hasOwnProperty(obj, key) {
    return ({}).hasOwnProperty.call(obj, key);
}
function $b013befce1f6217f$var$getValueAtIndexOrReturn(value, index, defaultValue) {
    if (Array.isArray(value)) {
        var v = value[index];
        return v == null ? Array.isArray(defaultValue) ? defaultValue[index] : defaultValue : v;
    }
    return value;
}
function $b013befce1f6217f$var$isType(value, type) {
    var str = ({}).toString.call(value);
    return str.indexOf('[object') === 0 && str.indexOf(type + "]") > -1;
}
function $b013befce1f6217f$var$invokeWithArgsOrReturn(value, args) {
    return typeof value === 'function' ? value.apply(void 0, args) : value;
}
function $b013befce1f6217f$var$debounce(fn, ms) {
    // Avoid wrapping in `setTimeout` if ms is 0 anyway
    if (ms === 0) return fn;
    var timeout;
    return function(arg) {
        clearTimeout(timeout);
        timeout = setTimeout(function() {
            fn(arg);
        }, ms);
    };
}
function $b013befce1f6217f$var$removeProperties(obj, keys) {
    var clone = Object.assign({}, obj);
    keys.forEach(function(key) {
        delete clone[key];
    });
    return clone;
}
function $b013befce1f6217f$var$splitBySpaces(value) {
    return value.split(/\s+/).filter(Boolean);
}
function $b013befce1f6217f$var$normalizeToArray(value) {
    return [].concat(value);
}
function $b013befce1f6217f$var$pushIfUnique(arr, value) {
    if (arr.indexOf(value) === -1) arr.push(value);
}
function $b013befce1f6217f$var$unique(arr) {
    return arr.filter(function(item, index) {
        return arr.indexOf(item) === index;
    });
}
function $b013befce1f6217f$var$getBasePlacement(placement) {
    return placement.split('-')[0];
}
function $b013befce1f6217f$var$arrayFrom(value) {
    return [].slice.call(value);
}
function $b013befce1f6217f$var$removeUndefinedProps(obj) {
    return Object.keys(obj).reduce(function(acc, key) {
        if (obj[key] !== undefined) acc[key] = obj[key];
        return acc;
    }, {});
}
function $b013befce1f6217f$var$div() {
    return document.createElement('div');
}
function $b013befce1f6217f$var$isElement(value) {
    return [
        'Element',
        'Fragment'
    ].some(function(type) {
        return $b013befce1f6217f$var$isType(value, type);
    });
}
function $b013befce1f6217f$var$isNodeList(value) {
    return $b013befce1f6217f$var$isType(value, 'NodeList');
}
function $b013befce1f6217f$var$isMouseEvent(value) {
    return $b013befce1f6217f$var$isType(value, 'MouseEvent');
}
function $b013befce1f6217f$var$isReferenceElement(value) {
    return !!(value && value._tippy && value._tippy.reference === value);
}
function $b013befce1f6217f$var$getArrayOfElements(value) {
    if ($b013befce1f6217f$var$isElement(value)) return [
        value
    ];
    if ($b013befce1f6217f$var$isNodeList(value)) return $b013befce1f6217f$var$arrayFrom(value);
    if (Array.isArray(value)) return value;
    return $b013befce1f6217f$var$arrayFrom(document.querySelectorAll(value));
}
function $b013befce1f6217f$var$setTransitionDuration(els, value) {
    els.forEach(function(el) {
        if (el) el.style.transitionDuration = value + "ms";
    });
}
function $b013befce1f6217f$var$setVisibilityState(els, state) {
    els.forEach(function(el) {
        if (el) el.setAttribute('data-state', state);
    });
}
function $b013befce1f6217f$var$getOwnerDocument(elementOrElements) {
    var _element$ownerDocumen;
    var _normalizeToArray = $b013befce1f6217f$var$normalizeToArray(elementOrElements), element = _normalizeToArray[0]; // Elements created via a <template> have an ownerDocument with no reference to the body
    return element != null && (_element$ownerDocumen = element.ownerDocument) != null && _element$ownerDocumen.body ? element.ownerDocument : document;
}
function $b013befce1f6217f$var$isCursorOutsideInteractiveBorder(popperTreeData, event) {
    var clientX = event.clientX, clientY = event.clientY;
    return popperTreeData.every(function(_ref) {
        var popperRect = _ref.popperRect, popperState = _ref.popperState, props = _ref.props;
        var interactiveBorder = props.interactiveBorder;
        var basePlacement = $b013befce1f6217f$var$getBasePlacement(popperState.placement);
        var offsetData = popperState.modifiersData.offset;
        if (!offsetData) return true;
        var topDistance = basePlacement === 'bottom' ? offsetData.top.y : 0;
        var bottomDistance = basePlacement === 'top' ? offsetData.bottom.y : 0;
        var leftDistance = basePlacement === 'right' ? offsetData.left.x : 0;
        var rightDistance = basePlacement === 'left' ? offsetData.right.x : 0;
        var exceedsTop = popperRect.top - clientY + topDistance > interactiveBorder;
        var exceedsBottom = clientY - popperRect.bottom - bottomDistance > interactiveBorder;
        var exceedsLeft = popperRect.left - clientX + leftDistance > interactiveBorder;
        var exceedsRight = clientX - popperRect.right - rightDistance > interactiveBorder;
        return exceedsTop || exceedsBottom || exceedsLeft || exceedsRight;
    });
}
function $b013befce1f6217f$var$updateTransitionEndListener(box, action, listener) {
    var method = action + "EventListener"; // some browsers apparently support `transition` (unprefixed) but only fire
    // `webkitTransitionEnd`...
    [
        'transitionend',
        'webkitTransitionEnd'
    ].forEach(function(event) {
        box[method](event, listener);
    });
}
/**
 * Compared to xxx.contains, this function works for dom structures with shadow
 * dom
 */ function $b013befce1f6217f$var$actualContains(parent, child) {
    var target = child;
    while(target){
        var _target$getRootNode;
        if (parent.contains(target)) return true;
        target = target.getRootNode == null ? void 0 : (_target$getRootNode = target.getRootNode()) == null ? void 0 : _target$getRootNode.host;
    }
    return false;
}
var $b013befce1f6217f$var$currentInput = {
    isTouch: false
};
var $b013befce1f6217f$var$lastMouseMoveTime = 0;
/**
 * When a `touchstart` event is fired, it's assumed the user is using touch
 * input. We'll bind a `mousemove` event listener to listen for mouse input in
 * the future. This way, the `isTouch` property is fully dynamic and will handle
 * hybrid devices that use a mix of touch + mouse input.
 */ function $b013befce1f6217f$var$onDocumentTouchStart() {
    if ($b013befce1f6217f$var$currentInput.isTouch) return;
    $b013befce1f6217f$var$currentInput.isTouch = true;
    if (window.performance) document.addEventListener('mousemove', $b013befce1f6217f$var$onDocumentMouseMove);
}
/**
 * When two `mousemove` event are fired consecutively within 20ms, it's assumed
 * the user is using mouse input again. `mousemove` can fire on touch devices as
 * well, but very rarely that quickly.
 */ function $b013befce1f6217f$var$onDocumentMouseMove() {
    var now = performance.now();
    if (now - $b013befce1f6217f$var$lastMouseMoveTime < 20) {
        $b013befce1f6217f$var$currentInput.isTouch = false;
        document.removeEventListener('mousemove', $b013befce1f6217f$var$onDocumentMouseMove);
    }
    $b013befce1f6217f$var$lastMouseMoveTime = now;
}
/**
 * When an element is in focus and has a tippy, leaving the tab/window and
 * returning causes it to show again. For mouse users this is unexpected, but
 * for keyboard use it makes sense.
 * TODO: find a better technique to solve this problem
 */ function $b013befce1f6217f$var$onWindowBlur() {
    var activeElement = document.activeElement;
    if ($b013befce1f6217f$var$isReferenceElement(activeElement)) {
        var instance = activeElement._tippy;
        if (activeElement.blur && !instance.state.isVisible) activeElement.blur();
    }
}
function $b013befce1f6217f$var$bindGlobalEventListeners() {
    document.addEventListener('touchstart', $b013befce1f6217f$var$onDocumentTouchStart, $b013befce1f6217f$var$TOUCH_OPTIONS);
    window.addEventListener('blur', $b013befce1f6217f$var$onWindowBlur);
}
var $b013befce1f6217f$var$isBrowser = typeof window !== 'undefined' && typeof document !== 'undefined';
var $b013befce1f6217f$var$isIE11 = $b013befce1f6217f$var$isBrowser ? !!window.msCrypto : false;
function $b013befce1f6217f$var$createMemoryLeakWarning(method) {
    var txt = method === 'destroy' ? 'n already-' : ' ';
    return [
        method + "() was called on a" + txt + "destroyed instance. This is a no-op but",
        'indicates a potential memory leak.'
    ].join(' ');
}
function $b013befce1f6217f$var$clean(value) {
    var spacesAndTabs = /[ \t]{2,}/g;
    var lineStartWithSpaces = /^[ \t]*/gm;
    return value.replace(spacesAndTabs, ' ').replace(lineStartWithSpaces, '').trim();
}
function $b013befce1f6217f$var$getDevMessage(message) {
    return $b013befce1f6217f$var$clean("\n  %ctippy.js\n\n  %c" + $b013befce1f6217f$var$clean(message) + "\n\n  %c\uD83D\uDC77\u200D This is a development-only message. It will be removed in production.\n  ");
}
function $b013befce1f6217f$var$getFormattedMessage(message) {
    return [
        $b013befce1f6217f$var$getDevMessage(message),
        'color: #00C584; font-size: 1.3em; font-weight: bold;',
        'line-height: 1.5',
        'color: #a6a095;'
    ];
} // Assume warnings and errors never have the same message
var $b013befce1f6217f$var$visitedMessages;
function $b013befce1f6217f$var$resetVisitedMessages() {
    $b013befce1f6217f$var$visitedMessages = new Set();
}
function $b013befce1f6217f$var$warnWhen(condition, message) {
    if (condition && !$b013befce1f6217f$var$visitedMessages.has(message)) {
        var _console;
        $b013befce1f6217f$var$visitedMessages.add(message);
        (_console = console).warn.apply(_console, $b013befce1f6217f$var$getFormattedMessage(message));
    }
}
function $b013befce1f6217f$var$errorWhen(condition, message) {
    if (condition && !$b013befce1f6217f$var$visitedMessages.has(message)) {
        var _console2;
        $b013befce1f6217f$var$visitedMessages.add(message);
        (_console2 = console).error.apply(_console2, $b013befce1f6217f$var$getFormattedMessage(message));
    }
}
function $b013befce1f6217f$var$validateTargets(targets) {
    var didPassFalsyValue = !targets;
    var didPassPlainObject = Object.prototype.toString.call(targets) === '[object Object]' && !targets.addEventListener;
    $b013befce1f6217f$var$errorWhen(didPassFalsyValue, [
        'tippy() was passed',
        '`' + String(targets) + '`',
        'as its targets (first) argument. Valid types are: String, Element,',
        'Element[], or NodeList.'
    ].join(' '));
    $b013befce1f6217f$var$errorWhen(didPassPlainObject, [
        'tippy() was passed a plain object which is not supported as an argument',
        'for virtual positioning. Use props.getReferenceClientRect instead.'
    ].join(' '));
}
var $b013befce1f6217f$var$pluginProps = {
    animateFill: false,
    followCursor: false,
    inlinePositioning: false,
    sticky: false
};
var $b013befce1f6217f$var$renderProps = {
    allowHTML: false,
    animation: 'fade',
    arrow: true,
    content: '',
    inertia: false,
    maxWidth: 350,
    role: 'tooltip',
    theme: '',
    zIndex: 9999
};
var $b013befce1f6217f$var$defaultProps = Object.assign({
    appendTo: $b013befce1f6217f$var$TIPPY_DEFAULT_APPEND_TO,
    aria: {
        content: 'auto',
        expanded: 'auto'
    },
    delay: 0,
    duration: [
        300,
        250
    ],
    getReferenceClientRect: null,
    hideOnClick: true,
    ignoreAttributes: false,
    interactive: false,
    interactiveBorder: 2,
    interactiveDebounce: 0,
    moveTransition: '',
    offset: [
        0,
        10
    ],
    onAfterUpdate: function onAfterUpdate() {},
    onBeforeUpdate: function onBeforeUpdate() {},
    onCreate: function onCreate() {},
    onDestroy: function onDestroy() {},
    onHidden: function onHidden() {},
    onHide: function onHide() {},
    onMount: function onMount() {},
    onShow: function onShow() {},
    onShown: function onShown() {},
    onTrigger: function onTrigger() {},
    onUntrigger: function onUntrigger() {},
    onClickOutside: function onClickOutside() {},
    placement: 'top',
    plugins: [],
    popperOptions: {},
    render: null,
    showOnCreate: false,
    touch: true,
    trigger: 'mouseenter focus',
    triggerTarget: null
}, $b013befce1f6217f$var$pluginProps, $b013befce1f6217f$var$renderProps);
var $b013befce1f6217f$var$defaultKeys = Object.keys($b013befce1f6217f$var$defaultProps);
var $b013befce1f6217f$var$setDefaultProps = function setDefaultProps(partialProps) {
    var keys = Object.keys(partialProps);
    keys.forEach(function(key) {
        $b013befce1f6217f$var$defaultProps[key] = partialProps[key];
    });
};
function $b013befce1f6217f$var$getExtendedPassedProps(passedProps) {
    var plugins = passedProps.plugins || [];
    var pluginProps = plugins.reduce(function(acc, plugin) {
        var name = plugin.name, defaultValue = plugin.defaultValue;
        if (name) {
            var _name;
            acc[name] = passedProps[name] !== undefined ? passedProps[name] : (_name = $b013befce1f6217f$var$defaultProps[name]) != null ? _name : defaultValue;
        }
        return acc;
    }, {});
    return Object.assign({}, passedProps, pluginProps);
}
function $b013befce1f6217f$var$getDataAttributeProps(reference, plugins) {
    var propKeys = plugins ? Object.keys($b013befce1f6217f$var$getExtendedPassedProps(Object.assign({}, $b013befce1f6217f$var$defaultProps, {
        plugins: plugins
    }))) : $b013befce1f6217f$var$defaultKeys;
    var props = propKeys.reduce(function(acc, key) {
        var valueAsString = (reference.getAttribute("data-tippy-" + key) || '').trim();
        if (!valueAsString) return acc;
        if (key === 'content') acc[key] = valueAsString;
        else try {
            acc[key] = JSON.parse(valueAsString);
        } catch (e) {
            acc[key] = valueAsString;
        }
        return acc;
    }, {});
    return props;
}
function $b013befce1f6217f$var$evaluateProps(reference, props) {
    var out = Object.assign({}, props, {
        content: $b013befce1f6217f$var$invokeWithArgsOrReturn(props.content, [
            reference
        ])
    }, props.ignoreAttributes ? {} : $b013befce1f6217f$var$getDataAttributeProps(reference, props.plugins));
    out.aria = Object.assign({}, $b013befce1f6217f$var$defaultProps.aria, out.aria);
    out.aria = {
        expanded: out.aria.expanded === 'auto' ? props.interactive : out.aria.expanded,
        content: out.aria.content === 'auto' ? props.interactive ? null : 'describedby' : out.aria.content
    };
    return out;
}
function $b013befce1f6217f$var$validateProps(partialProps, plugins) {
    if (partialProps === void 0) partialProps = {};
    if (plugins === void 0) plugins = [];
    var keys = Object.keys(partialProps);
    keys.forEach(function(prop) {
        var nonPluginProps = $b013befce1f6217f$var$removeProperties($b013befce1f6217f$var$defaultProps, Object.keys($b013befce1f6217f$var$pluginProps));
        var didPassUnknownProp = !$b013befce1f6217f$var$hasOwnProperty(nonPluginProps, prop); // Check if the prop exists in `plugins`
        if (didPassUnknownProp) didPassUnknownProp = plugins.filter(function(plugin) {
            return plugin.name === prop;
        }).length === 0;
        $b013befce1f6217f$var$warnWhen(didPassUnknownProp, [
            "`" + prop + "`",
            "is not a valid prop. You may have spelled it incorrectly, or if it's",
            'a plugin, forgot to pass it in an array as props.plugins.',
            '\n\n',
            'All props: https://atomiks.github.io/tippyjs/v6/all-props/\n',
            'Plugins: https://atomiks.github.io/tippyjs/v6/plugins/'
        ].join(' '));
    });
}
var $b013befce1f6217f$var$innerHTML = function innerHTML() {
    return 'innerHTML';
};
function $b013befce1f6217f$var$dangerouslySetInnerHTML(element, html) {
    element[$b013befce1f6217f$var$innerHTML()] = html;
}
function $b013befce1f6217f$var$createArrowElement(value) {
    var arrow = $b013befce1f6217f$var$div();
    if (value === true) arrow.className = $b013befce1f6217f$var$ARROW_CLASS;
    else {
        arrow.className = $b013befce1f6217f$var$SVG_ARROW_CLASS;
        if ($b013befce1f6217f$var$isElement(value)) arrow.appendChild(value);
        else $b013befce1f6217f$var$dangerouslySetInnerHTML(arrow, value);
    }
    return arrow;
}
function $b013befce1f6217f$var$setContent(content, props) {
    if ($b013befce1f6217f$var$isElement(props.content)) {
        $b013befce1f6217f$var$dangerouslySetInnerHTML(content, '');
        content.appendChild(props.content);
    } else if (typeof props.content !== 'function') {
        if (props.allowHTML) $b013befce1f6217f$var$dangerouslySetInnerHTML(content, props.content);
        else content.textContent = props.content;
    }
}
function $b013befce1f6217f$var$getChildren(popper) {
    var box = popper.firstElementChild;
    var boxChildren = $b013befce1f6217f$var$arrayFrom(box.children);
    return {
        box: box,
        content: boxChildren.find(function(node) {
            return node.classList.contains($b013befce1f6217f$var$CONTENT_CLASS);
        }),
        arrow: boxChildren.find(function(node) {
            return node.classList.contains($b013befce1f6217f$var$ARROW_CLASS) || node.classList.contains($b013befce1f6217f$var$SVG_ARROW_CLASS);
        }),
        backdrop: boxChildren.find(function(node) {
            return node.classList.contains($b013befce1f6217f$var$BACKDROP_CLASS);
        })
    };
}
function $b013befce1f6217f$var$render(instance) {
    var popper = $b013befce1f6217f$var$div();
    var box = $b013befce1f6217f$var$div();
    box.className = $b013befce1f6217f$var$BOX_CLASS;
    box.setAttribute('data-state', 'hidden');
    box.setAttribute('tabindex', '-1');
    var content = $b013befce1f6217f$var$div();
    content.className = $b013befce1f6217f$var$CONTENT_CLASS;
    content.setAttribute('data-state', 'hidden');
    $b013befce1f6217f$var$setContent(content, instance.props);
    popper.appendChild(box);
    box.appendChild(content);
    onUpdate(instance.props, instance.props);
    function onUpdate(prevProps, nextProps) {
        var _getChildren = $b013befce1f6217f$var$getChildren(popper), box = _getChildren.box, content = _getChildren.content, arrow = _getChildren.arrow;
        if (nextProps.theme) box.setAttribute('data-theme', nextProps.theme);
        else box.removeAttribute('data-theme');
        if (typeof nextProps.animation === 'string') box.setAttribute('data-animation', nextProps.animation);
        else box.removeAttribute('data-animation');
        if (nextProps.inertia) box.setAttribute('data-inertia', '');
        else box.removeAttribute('data-inertia');
        box.style.maxWidth = typeof nextProps.maxWidth === 'number' ? nextProps.maxWidth + "px" : nextProps.maxWidth;
        if (nextProps.role) box.setAttribute('role', nextProps.role);
        else box.removeAttribute('role');
        if (prevProps.content !== nextProps.content || prevProps.allowHTML !== nextProps.allowHTML) $b013befce1f6217f$var$setContent(content, instance.props);
        if (nextProps.arrow) {
            if (!arrow) box.appendChild($b013befce1f6217f$var$createArrowElement(nextProps.arrow));
            else if (prevProps.arrow !== nextProps.arrow) {
                box.removeChild(arrow);
                box.appendChild($b013befce1f6217f$var$createArrowElement(nextProps.arrow));
            }
        } else if (arrow) box.removeChild(arrow);
    }
    return {
        popper: popper,
        onUpdate: onUpdate
    };
} // Runtime check to identify if the render function is the default one; this
// way we can apply default CSS transitions logic and it can be tree-shaken away
$b013befce1f6217f$var$render.$$tippy = true;
var $b013befce1f6217f$var$idCounter = 1;
var $b013befce1f6217f$var$mouseMoveListeners = []; // Used by `hideAll()`
var $b013befce1f6217f$var$mountedInstances = [];
function $b013befce1f6217f$var$createTippy(reference, passedProps) {
    var props = $b013befce1f6217f$var$evaluateProps(reference, Object.assign({}, $b013befce1f6217f$var$defaultProps, $b013befce1f6217f$var$getExtendedPassedProps($b013befce1f6217f$var$removeUndefinedProps(passedProps)))); // ===========================================================================
    // 🔒 Private members
    // ===========================================================================
    var showTimeout;
    var hideTimeout;
    var scheduleHideAnimationFrame;
    var isVisibleFromClick = false;
    var didHideDueToDocumentMouseDown = false;
    var didTouchMove = false;
    var ignoreOnFirstUpdate = false;
    var lastTriggerEvent;
    var currentTransitionEndListener;
    var onFirstUpdate;
    var listeners = [];
    var debouncedOnMouseMove = $b013befce1f6217f$var$debounce(onMouseMove, props.interactiveDebounce);
    var currentTarget; // ===========================================================================
    // 🔑 Public members
    // ===========================================================================
    var id = $b013befce1f6217f$var$idCounter++;
    var popperInstance = null;
    var plugins = $b013befce1f6217f$var$unique(props.plugins);
    var state = {
        // Is the instance currently enabled?
        isEnabled: true,
        // Is the tippy currently showing and not transitioning out?
        isVisible: false,
        // Has the instance been destroyed?
        isDestroyed: false,
        // Is the tippy currently mounted to the DOM?
        isMounted: false,
        // Has the tippy finished transitioning in?
        isShown: false
    };
    var instance = {
        // properties
        id: id,
        reference: reference,
        popper: $b013befce1f6217f$var$div(),
        popperInstance: popperInstance,
        props: props,
        state: state,
        plugins: plugins,
        // methods
        clearDelayTimeouts: clearDelayTimeouts,
        setProps: setProps,
        setContent: setContent,
        show: show,
        hide: hide,
        hideWithInteractivity: hideWithInteractivity,
        enable: enable,
        disable: disable,
        unmount: unmount,
        destroy: destroy
    }; // TODO: Investigate why this early return causes a TDZ error in the tests —
    // it doesn't seem to happen in the browser
    /* istanbul ignore if */ if (!props.render) return instance;
     // ===========================================================================
    // Initial mutations
    // ===========================================================================
    var _props$render = props.render(instance), popper = _props$render.popper, onUpdate = _props$render.onUpdate;
    popper.setAttribute('data-tippy-root', '');
    popper.id = "tippy-" + instance.id;
    instance.popper = popper;
    reference._tippy = instance;
    popper._tippy = instance;
    var pluginsHooks = plugins.map(function(plugin) {
        return plugin.fn(instance);
    });
    var hasAriaExpanded = reference.hasAttribute('aria-expanded');
    addListeners();
    handleAriaExpandedAttribute();
    handleStyles();
    invokeHook('onCreate', [
        instance
    ]);
    if (props.showOnCreate) scheduleShow();
     // Prevent a tippy with a delay from hiding if the cursor left then returned
    // before it started hiding
    popper.addEventListener('mouseenter', function() {
        if (instance.props.interactive && instance.state.isVisible) instance.clearDelayTimeouts();
    });
    popper.addEventListener('mouseleave', function() {
        if (instance.props.interactive && instance.props.trigger.indexOf('mouseenter') >= 0) getDocument().addEventListener('mousemove', debouncedOnMouseMove);
    });
    return instance; // ===========================================================================
    // 🔒 Private methods
    // ===========================================================================
    function getNormalizedTouchSettings() {
        var touch = instance.props.touch;
        return Array.isArray(touch) ? touch : [
            touch,
            0
        ];
    }
    function getIsCustomTouchBehavior() {
        return getNormalizedTouchSettings()[0] === 'hold';
    }
    function getIsDefaultRenderFn() {
        var _instance$props$rende;
        // @ts-ignore
        return !!((_instance$props$rende = instance.props.render) != null && _instance$props$rende.$$tippy);
    }
    function getCurrentTarget() {
        return currentTarget || reference;
    }
    function getDocument() {
        var parent = getCurrentTarget().parentNode;
        return parent ? $b013befce1f6217f$var$getOwnerDocument(parent) : document;
    }
    function getDefaultTemplateChildren() {
        return $b013befce1f6217f$var$getChildren(popper);
    }
    function getDelay(isShow) {
        // For touch or keyboard input, force `0` delay for UX reasons
        // Also if the instance is mounted but not visible (transitioning out),
        // ignore delay
        if (instance.state.isMounted && !instance.state.isVisible || $b013befce1f6217f$var$currentInput.isTouch || lastTriggerEvent && lastTriggerEvent.type === 'focus') return 0;
        return $b013befce1f6217f$var$getValueAtIndexOrReturn(instance.props.delay, isShow ? 0 : 1, $b013befce1f6217f$var$defaultProps.delay);
    }
    function handleStyles(fromHide) {
        if (fromHide === void 0) fromHide = false;
        popper.style.pointerEvents = instance.props.interactive && !fromHide ? '' : 'none';
        popper.style.zIndex = "" + instance.props.zIndex;
    }
    function invokeHook(hook, args, shouldInvokePropsHook) {
        if (shouldInvokePropsHook === void 0) shouldInvokePropsHook = true;
        pluginsHooks.forEach(function(pluginHooks) {
            if (pluginHooks[hook]) pluginHooks[hook].apply(pluginHooks, args);
        });
        if (shouldInvokePropsHook) {
            var _instance$props;
            (_instance$props = instance.props)[hook].apply(_instance$props, args);
        }
    }
    function handleAriaContentAttribute() {
        var aria = instance.props.aria;
        if (!aria.content) return;
        var attr = "aria-" + aria.content;
        var id = popper.id;
        var nodes = $b013befce1f6217f$var$normalizeToArray(instance.props.triggerTarget || reference);
        nodes.forEach(function(node) {
            var currentValue = node.getAttribute(attr);
            if (instance.state.isVisible) node.setAttribute(attr, currentValue ? currentValue + " " + id : id);
            else {
                var nextValue = currentValue && currentValue.replace(id, '').trim();
                if (nextValue) node.setAttribute(attr, nextValue);
                else node.removeAttribute(attr);
            }
        });
    }
    function handleAriaExpandedAttribute() {
        if (hasAriaExpanded || !instance.props.aria.expanded) return;
        var nodes = $b013befce1f6217f$var$normalizeToArray(instance.props.triggerTarget || reference);
        nodes.forEach(function(node) {
            if (instance.props.interactive) node.setAttribute('aria-expanded', instance.state.isVisible && node === getCurrentTarget() ? 'true' : 'false');
            else node.removeAttribute('aria-expanded');
        });
    }
    function cleanupInteractiveMouseListeners() {
        getDocument().removeEventListener('mousemove', debouncedOnMouseMove);
        $b013befce1f6217f$var$mouseMoveListeners = $b013befce1f6217f$var$mouseMoveListeners.filter(function(listener) {
            return listener !== debouncedOnMouseMove;
        });
    }
    function onDocumentPress(event) {
        // Moved finger to scroll instead of an intentional tap outside
        if ($b013befce1f6217f$var$currentInput.isTouch) {
            if (didTouchMove || event.type === 'mousedown') return;
        }
        var actualTarget = event.composedPath && event.composedPath()[0] || event.target; // Clicked on interactive popper
        if (instance.props.interactive && $b013befce1f6217f$var$actualContains(popper, actualTarget)) return;
         // Clicked on the event listeners target
        if ($b013befce1f6217f$var$normalizeToArray(instance.props.triggerTarget || reference).some(function(el) {
            return $b013befce1f6217f$var$actualContains(el, actualTarget);
        })) {
            if ($b013befce1f6217f$var$currentInput.isTouch) return;
            if (instance.state.isVisible && instance.props.trigger.indexOf('click') >= 0) return;
        } else invokeHook('onClickOutside', [
            instance,
            event
        ]);
        if (instance.props.hideOnClick === true) {
            instance.clearDelayTimeouts();
            instance.hide(); // `mousedown` event is fired right before `focus` if pressing the
            // currentTarget. This lets a tippy with `focus` trigger know that it
            // should not show
            didHideDueToDocumentMouseDown = true;
            setTimeout(function() {
                didHideDueToDocumentMouseDown = false;
            }); // The listener gets added in `scheduleShow()`, but this may be hiding it
            // before it shows, and hide()'s early bail-out behavior can prevent it
            // from being cleaned up
            if (!instance.state.isMounted) removeDocumentPress();
        }
    }
    function onTouchMove() {
        didTouchMove = true;
    }
    function onTouchStart() {
        didTouchMove = false;
    }
    function addDocumentPress() {
        var doc = getDocument();
        doc.addEventListener('mousedown', onDocumentPress, true);
        doc.addEventListener('touchend', onDocumentPress, $b013befce1f6217f$var$TOUCH_OPTIONS);
        doc.addEventListener('touchstart', onTouchStart, $b013befce1f6217f$var$TOUCH_OPTIONS);
        doc.addEventListener('touchmove', onTouchMove, $b013befce1f6217f$var$TOUCH_OPTIONS);
    }
    function removeDocumentPress() {
        var doc = getDocument();
        doc.removeEventListener('mousedown', onDocumentPress, true);
        doc.removeEventListener('touchend', onDocumentPress, $b013befce1f6217f$var$TOUCH_OPTIONS);
        doc.removeEventListener('touchstart', onTouchStart, $b013befce1f6217f$var$TOUCH_OPTIONS);
        doc.removeEventListener('touchmove', onTouchMove, $b013befce1f6217f$var$TOUCH_OPTIONS);
    }
    function onTransitionedOut(duration, callback) {
        onTransitionEnd(duration, function() {
            if (!instance.state.isVisible && popper.parentNode && popper.parentNode.contains(popper)) callback();
        });
    }
    function onTransitionedIn(duration, callback) {
        onTransitionEnd(duration, callback);
    }
    function onTransitionEnd(duration, callback) {
        var box = getDefaultTemplateChildren().box;
        function listener(event) {
            if (event.target === box) {
                $b013befce1f6217f$var$updateTransitionEndListener(box, 'remove', listener);
                callback();
            }
        } // Make callback synchronous if duration is 0
        // `transitionend` won't fire otherwise
        if (duration === 0) return callback();
        $b013befce1f6217f$var$updateTransitionEndListener(box, 'remove', currentTransitionEndListener);
        $b013befce1f6217f$var$updateTransitionEndListener(box, 'add', listener);
        currentTransitionEndListener = listener;
    }
    function on(eventType, handler, options) {
        if (options === void 0) options = false;
        var nodes = $b013befce1f6217f$var$normalizeToArray(instance.props.triggerTarget || reference);
        nodes.forEach(function(node) {
            node.addEventListener(eventType, handler, options);
            listeners.push({
                node: node,
                eventType: eventType,
                handler: handler,
                options: options
            });
        });
    }
    function addListeners() {
        if (getIsCustomTouchBehavior()) {
            on('touchstart', onTrigger, {
                passive: true
            });
            on('touchend', onMouseLeave, {
                passive: true
            });
        }
        $b013befce1f6217f$var$splitBySpaces(instance.props.trigger).forEach(function(eventType) {
            if (eventType === 'manual') return;
            on(eventType, onTrigger);
            switch(eventType){
                case 'mouseenter':
                    on('mouseleave', onMouseLeave);
                    break;
                case 'focus':
                    on($b013befce1f6217f$var$isIE11 ? 'focusout' : 'blur', onBlurOrFocusOut);
                    break;
                case 'focusin':
                    on('focusout', onBlurOrFocusOut);
                    break;
            }
        });
    }
    function removeListeners() {
        listeners.forEach(function(_ref) {
            var node = _ref.node, eventType = _ref.eventType, handler = _ref.handler, options = _ref.options;
            node.removeEventListener(eventType, handler, options);
        });
        listeners = [];
    }
    function onTrigger(event) {
        var _lastTriggerEvent;
        var shouldScheduleClickHide = false;
        if (!instance.state.isEnabled || isEventListenerStopped(event) || didHideDueToDocumentMouseDown) return;
        var wasFocused = ((_lastTriggerEvent = lastTriggerEvent) == null ? void 0 : _lastTriggerEvent.type) === 'focus';
        lastTriggerEvent = event;
        currentTarget = event.currentTarget;
        handleAriaExpandedAttribute();
        if (!instance.state.isVisible && $b013befce1f6217f$var$isMouseEvent(event)) // If scrolling, `mouseenter` events can be fired if the cursor lands
        // over a new target, but `mousemove` events don't get fired. This
        // causes interactive tooltips to get stuck open until the cursor is
        // moved
        $b013befce1f6217f$var$mouseMoveListeners.forEach(function(listener) {
            return listener(event);
        });
         // Toggle show/hide when clicking click-triggered tooltips
        if (event.type === 'click' && (instance.props.trigger.indexOf('mouseenter') < 0 || isVisibleFromClick) && instance.props.hideOnClick !== false && instance.state.isVisible) shouldScheduleClickHide = true;
        else scheduleShow(event);
        if (event.type === 'click') isVisibleFromClick = !shouldScheduleClickHide;
        if (shouldScheduleClickHide && !wasFocused) scheduleHide(event);
    }
    function onMouseMove(event) {
        var target = event.target;
        var isCursorOverReferenceOrPopper = getCurrentTarget().contains(target) || popper.contains(target);
        if (event.type === 'mousemove' && isCursorOverReferenceOrPopper) return;
        var popperTreeData = getNestedPopperTree().concat(popper).map(function(popper) {
            var _instance$popperInsta;
            var instance = popper._tippy;
            var state = (_instance$popperInsta = instance.popperInstance) == null ? void 0 : _instance$popperInsta.state;
            if (state) return {
                popperRect: popper.getBoundingClientRect(),
                popperState: state,
                props: props
            };
            return null;
        }).filter(Boolean);
        if ($b013befce1f6217f$var$isCursorOutsideInteractiveBorder(popperTreeData, event)) {
            cleanupInteractiveMouseListeners();
            scheduleHide(event);
        }
    }
    function onMouseLeave(event) {
        var shouldBail = isEventListenerStopped(event) || instance.props.trigger.indexOf('click') >= 0 && isVisibleFromClick;
        if (shouldBail) return;
        if (instance.props.interactive) {
            instance.hideWithInteractivity(event);
            return;
        }
        scheduleHide(event);
    }
    function onBlurOrFocusOut(event) {
        if (instance.props.trigger.indexOf('focusin') < 0 && event.target !== getCurrentTarget()) return;
         // If focus was moved to within the popper
        if (instance.props.interactive && event.relatedTarget && popper.contains(event.relatedTarget)) return;
        scheduleHide(event);
    }
    function isEventListenerStopped(event) {
        return $b013befce1f6217f$var$currentInput.isTouch ? getIsCustomTouchBehavior() !== event.type.indexOf('touch') >= 0 : false;
    }
    function createPopperInstance() {
        destroyPopperInstance();
        var _instance$props2 = instance.props, popperOptions = _instance$props2.popperOptions, placement = _instance$props2.placement, offset = _instance$props2.offset, getReferenceClientRect = _instance$props2.getReferenceClientRect, moveTransition = _instance$props2.moveTransition;
        var arrow = getIsDefaultRenderFn() ? $b013befce1f6217f$var$getChildren(popper).arrow : null;
        var computedReference = getReferenceClientRect ? {
            getBoundingClientRect: getReferenceClientRect,
            contextElement: getReferenceClientRect.contextElement || getCurrentTarget()
        } : reference;
        var tippyModifier = {
            name: '$$tippy',
            enabled: true,
            phase: 'beforeWrite',
            requires: [
                'computeStyles'
            ],
            fn: function fn(_ref2) {
                var state = _ref2.state;
                if (getIsDefaultRenderFn()) {
                    var _getDefaultTemplateCh = getDefaultTemplateChildren(), box = _getDefaultTemplateCh.box;
                    [
                        'placement',
                        'reference-hidden',
                        'escaped'
                    ].forEach(function(attr) {
                        if (attr === 'placement') box.setAttribute('data-placement', state.placement);
                        else if (state.attributes.popper["data-popper-" + attr]) box.setAttribute("data-" + attr, '');
                        else box.removeAttribute("data-" + attr);
                    });
                    state.attributes.popper = {};
                }
            }
        };
        var modifiers = [
            {
                name: 'offset',
                options: {
                    offset: offset
                }
            },
            {
                name: 'preventOverflow',
                options: {
                    padding: {
                        top: 2,
                        bottom: 2,
                        left: 5,
                        right: 5
                    }
                }
            },
            {
                name: 'flip',
                options: {
                    padding: 5
                }
            },
            {
                name: 'computeStyles',
                options: {
                    adaptive: !moveTransition
                }
            },
            tippyModifier
        ];
        if (getIsDefaultRenderFn() && arrow) modifiers.push({
            name: 'arrow',
            options: {
                element: arrow,
                padding: 3
            }
        });
        modifiers.push.apply(modifiers, (popperOptions == null ? void 0 : popperOptions.modifiers) || []);
        instance.popperInstance = (0, $d3ca9c4a635d8f8b$export$8f7491d57c8f97a9)(computedReference, popper, Object.assign({}, popperOptions, {
            placement: placement,
            onFirstUpdate: onFirstUpdate,
            modifiers: modifiers
        }));
    }
    function destroyPopperInstance() {
        if (instance.popperInstance) {
            instance.popperInstance.destroy();
            instance.popperInstance = null;
        }
    }
    function mount() {
        var appendTo = instance.props.appendTo;
        var parentNode; // By default, we'll append the popper to the triggerTargets's parentNode so
        // it's directly after the reference element so the elements inside the
        // tippy can be tabbed to
        // If there are clipping issues, the user can specify a different appendTo
        // and ensure focus management is handled correctly manually
        var node = getCurrentTarget();
        if (instance.props.interactive && appendTo === $b013befce1f6217f$var$TIPPY_DEFAULT_APPEND_TO || appendTo === 'parent') parentNode = node.parentNode;
        else parentNode = $b013befce1f6217f$var$invokeWithArgsOrReturn(appendTo, [
            node
        ]);
         // The popper element needs to exist on the DOM before its position can be
        // updated as Popper needs to read its dimensions
        if (!parentNode.contains(popper)) parentNode.appendChild(popper);
        instance.state.isMounted = true;
        createPopperInstance();
    }
    function getNestedPopperTree() {
        return $b013befce1f6217f$var$arrayFrom(popper.querySelectorAll('[data-tippy-root]'));
    }
    function scheduleShow(event) {
        instance.clearDelayTimeouts();
        if (event) invokeHook('onTrigger', [
            instance,
            event
        ]);
        addDocumentPress();
        var delay = getDelay(true);
        var _getNormalizedTouchSe = getNormalizedTouchSettings(), touchValue = _getNormalizedTouchSe[0], touchDelay = _getNormalizedTouchSe[1];
        if ($b013befce1f6217f$var$currentInput.isTouch && touchValue === 'hold' && touchDelay) delay = touchDelay;
        if (delay) showTimeout = setTimeout(function() {
            instance.show();
        }, delay);
        else instance.show();
    }
    function scheduleHide(event) {
        instance.clearDelayTimeouts();
        invokeHook('onUntrigger', [
            instance,
            event
        ]);
        if (!instance.state.isVisible) {
            removeDocumentPress();
            return;
        } // For interactive tippies, scheduleHide is added to a document.body handler
        // from onMouseLeave so must intercept scheduled hides from mousemove/leave
        // events when trigger contains mouseenter and click, and the tip is
        // currently shown as a result of a click.
        if (instance.props.trigger.indexOf('mouseenter') >= 0 && instance.props.trigger.indexOf('click') >= 0 && [
            'mouseleave',
            'mousemove'
        ].indexOf(event.type) >= 0 && isVisibleFromClick) return;
        var delay = getDelay(false);
        if (delay) hideTimeout = setTimeout(function() {
            if (instance.state.isVisible) instance.hide();
        }, delay);
        else // Fixes a `transitionend` problem when it fires 1 frame too
        // late sometimes, we don't want hide() to be called.
        scheduleHideAnimationFrame = requestAnimationFrame(function() {
            instance.hide();
        });
    } // ===========================================================================
    // 🔑 Public methods
    // ===========================================================================
    function enable() {
        instance.state.isEnabled = true;
    }
    function disable() {
        // Disabling the instance should also hide it
        // https://github.com/atomiks/tippy.js-react/issues/106
        instance.hide();
        instance.state.isEnabled = false;
    }
    function clearDelayTimeouts() {
        clearTimeout(showTimeout);
        clearTimeout(hideTimeout);
        cancelAnimationFrame(scheduleHideAnimationFrame);
    }
    function setProps(partialProps) {
        if (instance.state.isDestroyed) return;
        invokeHook('onBeforeUpdate', [
            instance,
            partialProps
        ]);
        removeListeners();
        var prevProps = instance.props;
        var nextProps = $b013befce1f6217f$var$evaluateProps(reference, Object.assign({}, prevProps, $b013befce1f6217f$var$removeUndefinedProps(partialProps), {
            ignoreAttributes: true
        }));
        instance.props = nextProps;
        addListeners();
        if (prevProps.interactiveDebounce !== nextProps.interactiveDebounce) {
            cleanupInteractiveMouseListeners();
            debouncedOnMouseMove = $b013befce1f6217f$var$debounce(onMouseMove, nextProps.interactiveDebounce);
        } // Ensure stale aria-expanded attributes are removed
        if (prevProps.triggerTarget && !nextProps.triggerTarget) $b013befce1f6217f$var$normalizeToArray(prevProps.triggerTarget).forEach(function(node) {
            node.removeAttribute('aria-expanded');
        });
        else if (nextProps.triggerTarget) reference.removeAttribute('aria-expanded');
        handleAriaExpandedAttribute();
        handleStyles();
        if (onUpdate) onUpdate(prevProps, nextProps);
        if (instance.popperInstance) {
            createPopperInstance(); // Fixes an issue with nested tippies if they are all getting re-rendered,
            // and the nested ones get re-rendered first.
            // https://github.com/atomiks/tippyjs-react/issues/177
            // TODO: find a cleaner / more efficient solution(!)
            getNestedPopperTree().forEach(function(nestedPopper) {
                // React (and other UI libs likely) requires a rAF wrapper as it flushes
                // its work in one
                requestAnimationFrame(nestedPopper._tippy.popperInstance.forceUpdate);
            });
        }
        invokeHook('onAfterUpdate', [
            instance,
            partialProps
        ]);
    }
    function setContent(content) {
        instance.setProps({
            content: content
        });
    }
    function show() {
        var isAlreadyVisible = instance.state.isVisible;
        var isDestroyed = instance.state.isDestroyed;
        var isDisabled = !instance.state.isEnabled;
        var isTouchAndTouchDisabled = $b013befce1f6217f$var$currentInput.isTouch && !instance.props.touch;
        var duration = $b013befce1f6217f$var$getValueAtIndexOrReturn(instance.props.duration, 0, $b013befce1f6217f$var$defaultProps.duration);
        if (isAlreadyVisible || isDestroyed || isDisabled || isTouchAndTouchDisabled) return;
         // Normalize `disabled` behavior across browsers.
        // Firefox allows events on disabled elements, but Chrome doesn't.
        // Using a wrapper element (i.e. <span>) is recommended.
        if (getCurrentTarget().hasAttribute('disabled')) return;
        invokeHook('onShow', [
            instance
        ], false);
        if (instance.props.onShow(instance) === false) return;
        instance.state.isVisible = true;
        if (getIsDefaultRenderFn()) popper.style.visibility = 'visible';
        handleStyles();
        addDocumentPress();
        if (!instance.state.isMounted) popper.style.transition = 'none';
         // If flipping to the opposite side after hiding at least once, the
        // animation will use the wrong placement without resetting the duration
        if (getIsDefaultRenderFn()) {
            var _getDefaultTemplateCh2 = getDefaultTemplateChildren(), box = _getDefaultTemplateCh2.box, content = _getDefaultTemplateCh2.content;
            $b013befce1f6217f$var$setTransitionDuration([
                box,
                content
            ], 0);
        }
        onFirstUpdate = function onFirstUpdate() {
            var _instance$popperInsta2;
            if (!instance.state.isVisible || ignoreOnFirstUpdate) return;
            ignoreOnFirstUpdate = true; // reflow
            popper.offsetHeight;
            popper.style.transition = instance.props.moveTransition;
            if (getIsDefaultRenderFn() && instance.props.animation) {
                var _getDefaultTemplateCh3 = getDefaultTemplateChildren(), _box = _getDefaultTemplateCh3.box, _content = _getDefaultTemplateCh3.content;
                $b013befce1f6217f$var$setTransitionDuration([
                    _box,
                    _content
                ], duration);
                $b013befce1f6217f$var$setVisibilityState([
                    _box,
                    _content
                ], 'visible');
            }
            handleAriaContentAttribute();
            handleAriaExpandedAttribute();
            $b013befce1f6217f$var$pushIfUnique($b013befce1f6217f$var$mountedInstances, instance); // certain modifiers (e.g. `maxSize`) require a second update after the
            // popper has been positioned for the first time
            (_instance$popperInsta2 = instance.popperInstance) == null || _instance$popperInsta2.forceUpdate();
            invokeHook('onMount', [
                instance
            ]);
            if (instance.props.animation && getIsDefaultRenderFn()) onTransitionedIn(duration, function() {
                instance.state.isShown = true;
                invokeHook('onShown', [
                    instance
                ]);
            });
        };
        mount();
    }
    function hide() {
        var isAlreadyHidden = !instance.state.isVisible;
        var isDestroyed = instance.state.isDestroyed;
        var isDisabled = !instance.state.isEnabled;
        var duration = $b013befce1f6217f$var$getValueAtIndexOrReturn(instance.props.duration, 1, $b013befce1f6217f$var$defaultProps.duration);
        if (isAlreadyHidden || isDestroyed || isDisabled) return;
        invokeHook('onHide', [
            instance
        ], false);
        if (instance.props.onHide(instance) === false) return;
        instance.state.isVisible = false;
        instance.state.isShown = false;
        ignoreOnFirstUpdate = false;
        isVisibleFromClick = false;
        if (getIsDefaultRenderFn()) popper.style.visibility = 'hidden';
        cleanupInteractiveMouseListeners();
        removeDocumentPress();
        handleStyles(true);
        if (getIsDefaultRenderFn()) {
            var _getDefaultTemplateCh4 = getDefaultTemplateChildren(), box = _getDefaultTemplateCh4.box, content = _getDefaultTemplateCh4.content;
            if (instance.props.animation) {
                $b013befce1f6217f$var$setTransitionDuration([
                    box,
                    content
                ], duration);
                $b013befce1f6217f$var$setVisibilityState([
                    box,
                    content
                ], 'hidden');
            }
        }
        handleAriaContentAttribute();
        handleAriaExpandedAttribute();
        if (instance.props.animation) {
            if (getIsDefaultRenderFn()) onTransitionedOut(duration, instance.unmount);
        } else instance.unmount();
    }
    function hideWithInteractivity(event) {
        getDocument().addEventListener('mousemove', debouncedOnMouseMove);
        $b013befce1f6217f$var$pushIfUnique($b013befce1f6217f$var$mouseMoveListeners, debouncedOnMouseMove);
        debouncedOnMouseMove(event);
    }
    function unmount() {
        if (instance.state.isVisible) instance.hide();
        if (!instance.state.isMounted) return;
        destroyPopperInstance(); // If a popper is not interactive, it will be appended outside the popper
        // tree by default. This seems mainly for interactive tippies, but we should
        // find a workaround if possible
        getNestedPopperTree().forEach(function(nestedPopper) {
            nestedPopper._tippy.unmount();
        });
        if (popper.parentNode) popper.parentNode.removeChild(popper);
        $b013befce1f6217f$var$mountedInstances = $b013befce1f6217f$var$mountedInstances.filter(function(i) {
            return i !== instance;
        });
        instance.state.isMounted = false;
        invokeHook('onHidden', [
            instance
        ]);
    }
    function destroy() {
        if (instance.state.isDestroyed) return;
        instance.clearDelayTimeouts();
        instance.unmount();
        removeListeners();
        delete reference._tippy;
        instance.state.isDestroyed = true;
        invokeHook('onDestroy', [
            instance
        ]);
    }
}
function $b013befce1f6217f$var$tippy(targets, optionalProps) {
    if (optionalProps === void 0) optionalProps = {};
    var plugins = $b013befce1f6217f$var$defaultProps.plugins.concat(optionalProps.plugins || []);
    $b013befce1f6217f$var$bindGlobalEventListeners();
    var passedProps = Object.assign({}, optionalProps, {
        plugins: plugins
    });
    var elements = $b013befce1f6217f$var$getArrayOfElements(targets);
    var isSingleContentElement, isMoreThanOneReferenceElement;
    var instances = elements.reduce(function(acc, reference) {
        var instance = reference && $b013befce1f6217f$var$createTippy(reference, passedProps);
        if (instance) acc.push(instance);
        return acc;
    }, []);
    return $b013befce1f6217f$var$isElement(targets) ? instances[0] : instances;
}
$b013befce1f6217f$var$tippy.defaultProps = $b013befce1f6217f$var$defaultProps;
$b013befce1f6217f$var$tippy.setDefaultProps = $b013befce1f6217f$var$setDefaultProps;
$b013befce1f6217f$var$tippy.currentInput = $b013befce1f6217f$var$currentInput;
var $b013befce1f6217f$export$a9608aab345f7e75 = function hideAll(_temp) {
    var _ref = _temp === void 0 ? {} : _temp, excludedReferenceOrInstance = _ref.exclude, duration = _ref.duration;
    $b013befce1f6217f$var$mountedInstances.forEach(function(instance) {
        var isExcluded = false;
        if (excludedReferenceOrInstance) isExcluded = $b013befce1f6217f$var$isReferenceElement(excludedReferenceOrInstance) ? instance.reference === excludedReferenceOrInstance : instance.popper === excludedReferenceOrInstance.popper;
        if (!isExcluded) {
            var originalDuration = instance.props.duration;
            instance.setProps({
                duration: duration
            });
            instance.hide();
            if (!instance.state.isDestroyed) instance.setProps({
                duration: originalDuration
            });
        }
    });
};
// every time the popper is destroyed (i.e. a new target), removing the styles
// and causing transitions to break for singletons when the console is open, but
// most notably for non-transform styles being used, `gpuAcceleration: false`.
var $b013befce1f6217f$var$applyStylesModifier = Object.assign({}, (0, $dfb41fce0bddd2d8$export$2e2bcd8739ae039), {
    effect: function effect(_ref) {
        var state = _ref.state;
        var initialStyles = {
            popper: {
                position: state.options.strategy,
                left: '0',
                top: '0',
                margin: '0'
            },
            arrow: {
                position: 'absolute'
            },
            reference: {}
        };
        Object.assign(state.elements.popper.style, initialStyles.popper);
        state.styles = initialStyles;
        if (state.elements.arrow) Object.assign(state.elements.arrow.style, initialStyles.arrow);
         // intentionally return no cleanup function
    // return () => { ... }
    }
});
var $b013befce1f6217f$export$374c483667c1ea9b = function createSingleton(tippyInstances, optionalProps) {
    var _optionalProps$popper;
    if (optionalProps === void 0) optionalProps = {};
    var individualInstances = tippyInstances;
    var references = [];
    var triggerTargets = [];
    var currentTarget;
    var overrides = optionalProps.overrides;
    var interceptSetPropsCleanups = [];
    var shownOnCreate = false;
    function setTriggerTargets() {
        triggerTargets = individualInstances.map(function(instance) {
            return $b013befce1f6217f$var$normalizeToArray(instance.props.triggerTarget || instance.reference);
        }).reduce(function(acc, item) {
            return acc.concat(item);
        }, []);
    }
    function setReferences() {
        references = individualInstances.map(function(instance) {
            return instance.reference;
        });
    }
    function enableInstances(isEnabled) {
        individualInstances.forEach(function(instance) {
            if (isEnabled) instance.enable();
            else instance.disable();
        });
    }
    function interceptSetProps(singleton) {
        return individualInstances.map(function(instance) {
            var originalSetProps = instance.setProps;
            instance.setProps = function(props) {
                originalSetProps(props);
                if (instance.reference === currentTarget) singleton.setProps(props);
            };
            return function() {
                instance.setProps = originalSetProps;
            };
        });
    } // have to pass singleton, as it maybe undefined on first call
    function prepareInstance(singleton, target) {
        var index = triggerTargets.indexOf(target); // bail-out
        if (target === currentTarget) return;
        currentTarget = target;
        var overrideProps = (overrides || []).concat('content').reduce(function(acc, prop) {
            acc[prop] = individualInstances[index].props[prop];
            return acc;
        }, {});
        singleton.setProps(Object.assign({}, overrideProps, {
            getReferenceClientRect: typeof overrideProps.getReferenceClientRect === 'function' ? overrideProps.getReferenceClientRect : function() {
                var _references$index;
                return (_references$index = references[index]) == null ? void 0 : _references$index.getBoundingClientRect();
            }
        }));
    }
    enableInstances(false);
    setReferences();
    setTriggerTargets();
    var plugin = {
        fn: function fn() {
            return {
                onDestroy: function onDestroy() {
                    enableInstances(true);
                },
                onHidden: function onHidden() {
                    currentTarget = null;
                },
                onClickOutside: function onClickOutside(instance) {
                    if (instance.props.showOnCreate && !shownOnCreate) {
                        shownOnCreate = true;
                        currentTarget = null;
                    }
                },
                onShow: function onShow(instance) {
                    if (instance.props.showOnCreate && !shownOnCreate) {
                        shownOnCreate = true;
                        prepareInstance(instance, references[0]);
                    }
                },
                onTrigger: function onTrigger(instance, event) {
                    prepareInstance(instance, event.currentTarget);
                }
            };
        }
    };
    var singleton = $b013befce1f6217f$var$tippy($b013befce1f6217f$var$div(), Object.assign({}, $b013befce1f6217f$var$removeProperties(optionalProps, [
        'overrides'
    ]), {
        plugins: [
            plugin
        ].concat(optionalProps.plugins || []),
        triggerTarget: triggerTargets,
        popperOptions: Object.assign({}, optionalProps.popperOptions, {
            modifiers: [].concat(((_optionalProps$popper = optionalProps.popperOptions) == null ? void 0 : _optionalProps$popper.modifiers) || [], [
                $b013befce1f6217f$var$applyStylesModifier
            ])
        })
    }));
    var originalShow = singleton.show;
    singleton.show = function(target) {
        originalShow(); // first time, showOnCreate or programmatic call with no params
        // default to showing first instance
        if (!currentTarget && target == null) return prepareInstance(singleton, references[0]);
         // triggered from event (do nothing as prepareInstance already called by onTrigger)
        // programmatic call with no params when already visible (do nothing again)
        if (currentTarget && target == null) return;
         // target is index of instance
        if (typeof target === 'number') return references[target] && prepareInstance(singleton, references[target]);
         // target is a child tippy instance
        if (individualInstances.indexOf(target) >= 0) {
            var ref = target.reference;
            return prepareInstance(singleton, ref);
        } // target is a ReferenceElement
        if (references.indexOf(target) >= 0) return prepareInstance(singleton, target);
    };
    singleton.showNext = function() {
        var first = references[0];
        if (!currentTarget) return singleton.show(0);
        var index = references.indexOf(currentTarget);
        singleton.show(references[index + 1] || first);
    };
    singleton.showPrevious = function() {
        var last = references[references.length - 1];
        if (!currentTarget) return singleton.show(last);
        var index = references.indexOf(currentTarget);
        var target = references[index - 1] || last;
        singleton.show(target);
    };
    var originalSetProps = singleton.setProps;
    singleton.setProps = function(props) {
        overrides = props.overrides || overrides;
        originalSetProps(props);
    };
    singleton.setInstances = function(nextInstances) {
        enableInstances(true);
        interceptSetPropsCleanups.forEach(function(fn) {
            return fn();
        });
        individualInstances = nextInstances;
        enableInstances(false);
        setReferences();
        setTriggerTargets();
        interceptSetPropsCleanups = interceptSetProps(singleton);
        singleton.setProps({
            triggerTarget: triggerTargets
        });
    };
    interceptSetPropsCleanups = interceptSetProps(singleton);
    return singleton;
};
var $b013befce1f6217f$var$BUBBLING_EVENTS_MAP = {
    mouseover: 'mouseenter',
    focusin: 'focus',
    click: 'click'
};
/**
 * Creates a delegate instance that controls the creation of tippy instances
 * for child elements (`target` CSS selector).
 */ function $b013befce1f6217f$export$10b1921597150314(targets, props) {
    var listeners = [];
    var childTippyInstances = [];
    var disabled = false;
    var target = props.target;
    var nativeProps = $b013befce1f6217f$var$removeProperties(props, [
        'target'
    ]);
    var parentProps = Object.assign({}, nativeProps, {
        trigger: 'manual',
        touch: false
    });
    var childProps = Object.assign({
        touch: $b013befce1f6217f$var$defaultProps.touch
    }, nativeProps, {
        showOnCreate: true
    });
    var returnValue = $b013befce1f6217f$var$tippy(targets, parentProps);
    var normalizedReturnValue = $b013befce1f6217f$var$normalizeToArray(returnValue);
    function onTrigger(event) {
        if (!event.target || disabled) return;
        var targetNode = event.target.closest(target);
        if (!targetNode) return;
         // Get relevant trigger with fallbacks:
        // 1. Check `data-tippy-trigger` attribute on target node
        // 2. Fallback to `trigger` passed to `delegate()`
        // 3. Fallback to `defaultProps.trigger`
        var trigger = targetNode.getAttribute('data-tippy-trigger') || props.trigger || $b013befce1f6217f$var$defaultProps.trigger; // @ts-ignore
        if (targetNode._tippy) return;
        if (event.type === 'touchstart' && typeof childProps.touch === 'boolean') return;
        if (event.type !== 'touchstart' && trigger.indexOf($b013befce1f6217f$var$BUBBLING_EVENTS_MAP[event.type]) < 0) return;
        var instance = $b013befce1f6217f$var$tippy(targetNode, childProps);
        if (instance) childTippyInstances = childTippyInstances.concat(instance);
    }
    function on(node, eventType, handler, options) {
        if (options === void 0) options = false;
        node.addEventListener(eventType, handler, options);
        listeners.push({
            node: node,
            eventType: eventType,
            handler: handler,
            options: options
        });
    }
    function addEventListeners(instance) {
        var reference = instance.reference;
        on(reference, 'touchstart', onTrigger, $b013befce1f6217f$var$TOUCH_OPTIONS);
        on(reference, 'mouseover', onTrigger);
        on(reference, 'focusin', onTrigger);
        on(reference, 'click', onTrigger);
    }
    function removeEventListeners() {
        listeners.forEach(function(_ref) {
            var node = _ref.node, eventType = _ref.eventType, handler = _ref.handler, options = _ref.options;
            node.removeEventListener(eventType, handler, options);
        });
        listeners = [];
    }
    function applyMutations(instance) {
        var originalDestroy = instance.destroy;
        var originalEnable = instance.enable;
        var originalDisable = instance.disable;
        instance.destroy = function(shouldDestroyChildInstances) {
            if (shouldDestroyChildInstances === void 0) shouldDestroyChildInstances = true;
            if (shouldDestroyChildInstances) childTippyInstances.forEach(function(instance) {
                instance.destroy();
            });
            childTippyInstances = [];
            removeEventListeners();
            originalDestroy();
        };
        instance.enable = function() {
            originalEnable();
            childTippyInstances.forEach(function(instance) {
                return instance.enable();
            });
            disabled = false;
        };
        instance.disable = function() {
            originalDisable();
            childTippyInstances.forEach(function(instance) {
                return instance.disable();
            });
            disabled = true;
        };
        addEventListeners(instance);
    }
    normalizedReturnValue.forEach(applyMutations);
    return returnValue;
}
var $b013befce1f6217f$export$dd8ded329c01db79 = {
    name: 'animateFill',
    defaultValue: false,
    fn: function fn(instance) {
        var _instance$props$rende;
        // @ts-ignore
        if (!((_instance$props$rende = instance.props.render) != null && _instance$props$rende.$$tippy)) return {};
        var _getChildren = $b013befce1f6217f$var$getChildren(instance.popper), box = _getChildren.box, content = _getChildren.content;
        var backdrop = instance.props.animateFill ? $b013befce1f6217f$var$createBackdropElement() : null;
        return {
            onCreate: function onCreate() {
                if (backdrop) {
                    box.insertBefore(backdrop, box.firstElementChild);
                    box.setAttribute('data-animatefill', '');
                    box.style.overflow = 'hidden';
                    instance.setProps({
                        arrow: false,
                        animation: 'shift-away'
                    });
                }
            },
            onMount: function onMount() {
                if (backdrop) {
                    var transitionDuration = box.style.transitionDuration;
                    var duration = Number(transitionDuration.replace('ms', '')); // The content should fade in after the backdrop has mostly filled the
                    // tooltip element. `clip-path` is the other alternative but is not
                    // well-supported and is buggy on some devices.
                    content.style.transitionDelay = Math.round(duration / 10) + "ms";
                    backdrop.style.transitionDuration = transitionDuration;
                    $b013befce1f6217f$var$setVisibilityState([
                        backdrop
                    ], 'visible');
                }
            },
            onShow: function onShow() {
                if (backdrop) backdrop.style.transitionDuration = '0ms';
            },
            onHide: function onHide() {
                if (backdrop) $b013befce1f6217f$var$setVisibilityState([
                    backdrop
                ], 'hidden');
            }
        };
    }
};
function $b013befce1f6217f$var$createBackdropElement() {
    var backdrop = $b013befce1f6217f$var$div();
    backdrop.className = $b013befce1f6217f$var$BACKDROP_CLASS;
    $b013befce1f6217f$var$setVisibilityState([
        backdrop
    ], 'hidden');
    return backdrop;
}
var $b013befce1f6217f$var$mouseCoords = {
    clientX: 0,
    clientY: 0
};
var $b013befce1f6217f$var$activeInstances = [];
function $b013befce1f6217f$var$storeMouseCoords(_ref) {
    var clientX = _ref.clientX, clientY = _ref.clientY;
    $b013befce1f6217f$var$mouseCoords = {
        clientX: clientX,
        clientY: clientY
    };
}
function $b013befce1f6217f$var$addMouseCoordsListener(doc) {
    doc.addEventListener('mousemove', $b013befce1f6217f$var$storeMouseCoords);
}
function $b013befce1f6217f$var$removeMouseCoordsListener(doc) {
    doc.removeEventListener('mousemove', $b013befce1f6217f$var$storeMouseCoords);
}
var $b013befce1f6217f$export$ac81526b64504ab6 = {
    name: 'followCursor',
    defaultValue: false,
    fn: function fn(instance) {
        var reference = instance.reference;
        var doc = $b013befce1f6217f$var$getOwnerDocument(instance.props.triggerTarget || reference);
        var isInternalUpdate = false;
        var wasFocusEvent = false;
        var isUnmounted = true;
        var prevProps = instance.props;
        function getIsInitialBehavior() {
            return instance.props.followCursor === 'initial' && instance.state.isVisible;
        }
        function addListener() {
            doc.addEventListener('mousemove', onMouseMove);
        }
        function removeListener() {
            doc.removeEventListener('mousemove', onMouseMove);
        }
        function unsetGetReferenceClientRect() {
            isInternalUpdate = true;
            instance.setProps({
                getReferenceClientRect: null
            });
            isInternalUpdate = false;
        }
        function onMouseMove(event) {
            // If the instance is interactive, avoid updating the position unless it's
            // over the reference element
            var isCursorOverReference = event.target ? reference.contains(event.target) : true;
            var followCursor = instance.props.followCursor;
            var clientX = event.clientX, clientY = event.clientY;
            var rect = reference.getBoundingClientRect();
            var relativeX = clientX - rect.left;
            var relativeY = clientY - rect.top;
            if (isCursorOverReference || !instance.props.interactive) instance.setProps({
                // @ts-ignore - unneeded DOMRect properties
                getReferenceClientRect: function getReferenceClientRect() {
                    var rect = reference.getBoundingClientRect();
                    var x = clientX;
                    var y = clientY;
                    if (followCursor === 'initial') {
                        x = rect.left + relativeX;
                        y = rect.top + relativeY;
                    }
                    var top = followCursor === 'horizontal' ? rect.top : y;
                    var right = followCursor === 'vertical' ? rect.right : x;
                    var bottom = followCursor === 'horizontal' ? rect.bottom : y;
                    var left = followCursor === 'vertical' ? rect.left : x;
                    return {
                        width: right - left,
                        height: bottom - top,
                        top: top,
                        right: right,
                        bottom: bottom,
                        left: left
                    };
                }
            });
        }
        function create() {
            if (instance.props.followCursor) {
                $b013befce1f6217f$var$activeInstances.push({
                    instance: instance,
                    doc: doc
                });
                $b013befce1f6217f$var$addMouseCoordsListener(doc);
            }
        }
        function destroy() {
            $b013befce1f6217f$var$activeInstances = $b013befce1f6217f$var$activeInstances.filter(function(data) {
                return data.instance !== instance;
            });
            if ($b013befce1f6217f$var$activeInstances.filter(function(data) {
                return data.doc === doc;
            }).length === 0) $b013befce1f6217f$var$removeMouseCoordsListener(doc);
        }
        return {
            onCreate: create,
            onDestroy: destroy,
            onBeforeUpdate: function onBeforeUpdate() {
                prevProps = instance.props;
            },
            onAfterUpdate: function onAfterUpdate(_, _ref2) {
                var followCursor = _ref2.followCursor;
                if (isInternalUpdate) return;
                if (followCursor !== undefined && prevProps.followCursor !== followCursor) {
                    destroy();
                    if (followCursor) {
                        create();
                        if (instance.state.isMounted && !wasFocusEvent && !getIsInitialBehavior()) addListener();
                    } else {
                        removeListener();
                        unsetGetReferenceClientRect();
                    }
                }
            },
            onMount: function onMount() {
                if (instance.props.followCursor && !wasFocusEvent) {
                    if (isUnmounted) {
                        onMouseMove($b013befce1f6217f$var$mouseCoords);
                        isUnmounted = false;
                    }
                    if (!getIsInitialBehavior()) addListener();
                }
            },
            onTrigger: function onTrigger(_, event) {
                if ($b013befce1f6217f$var$isMouseEvent(event)) $b013befce1f6217f$var$mouseCoords = {
                    clientX: event.clientX,
                    clientY: event.clientY
                };
                wasFocusEvent = event.type === 'focus';
            },
            onHidden: function onHidden() {
                if (instance.props.followCursor) {
                    unsetGetReferenceClientRect();
                    removeListener();
                    isUnmounted = true;
                }
            }
        };
    }
};
function $b013befce1f6217f$var$getProps(props, modifier) {
    var _props$popperOptions;
    return {
        popperOptions: Object.assign({}, props.popperOptions, {
            modifiers: [].concat((((_props$popperOptions = props.popperOptions) == null ? void 0 : _props$popperOptions.modifiers) || []).filter(function(_ref) {
                var name = _ref.name;
                return name !== modifier.name;
            }), [
                modifier
            ])
        })
    };
}
var $b013befce1f6217f$export$e2b668424a9c728 = {
    name: 'inlinePositioning',
    defaultValue: false,
    fn: function fn(instance) {
        var reference = instance.reference;
        function isEnabled() {
            return !!instance.props.inlinePositioning;
        }
        var placement;
        var cursorRectIndex = -1;
        var isInternalUpdate = false;
        var triedPlacements = [];
        var modifier = {
            name: 'tippyInlinePositioning',
            enabled: true,
            phase: 'afterWrite',
            fn: function fn(_ref2) {
                var state = _ref2.state;
                if (isEnabled()) {
                    if (triedPlacements.indexOf(state.placement) !== -1) triedPlacements = [];
                    if (placement !== state.placement && triedPlacements.indexOf(state.placement) === -1) {
                        triedPlacements.push(state.placement);
                        instance.setProps({
                            // @ts-ignore - unneeded DOMRect properties
                            getReferenceClientRect: function getReferenceClientRect() {
                                return _getReferenceClientRect(state.placement);
                            }
                        });
                    }
                    placement = state.placement;
                }
            }
        };
        function _getReferenceClientRect(placement) {
            return $b013befce1f6217f$var$getInlineBoundingClientRect($b013befce1f6217f$var$getBasePlacement(placement), reference.getBoundingClientRect(), $b013befce1f6217f$var$arrayFrom(reference.getClientRects()), cursorRectIndex);
        }
        function setInternalProps(partialProps) {
            isInternalUpdate = true;
            instance.setProps(partialProps);
            isInternalUpdate = false;
        }
        function addModifier() {
            if (!isInternalUpdate) setInternalProps($b013befce1f6217f$var$getProps(instance.props, modifier));
        }
        return {
            onCreate: addModifier,
            onAfterUpdate: addModifier,
            onTrigger: function onTrigger(_, event) {
                if ($b013befce1f6217f$var$isMouseEvent(event)) {
                    var rects = $b013befce1f6217f$var$arrayFrom(instance.reference.getClientRects());
                    var cursorRect = rects.find(function(rect) {
                        return rect.left - 2 <= event.clientX && rect.right + 2 >= event.clientX && rect.top - 2 <= event.clientY && rect.bottom + 2 >= event.clientY;
                    });
                    var index = rects.indexOf(cursorRect);
                    cursorRectIndex = index > -1 ? index : cursorRectIndex;
                }
            },
            onHidden: function onHidden() {
                cursorRectIndex = -1;
            }
        };
    }
};
function $b013befce1f6217f$var$getInlineBoundingClientRect(currentBasePlacement, boundingRect, clientRects, cursorRectIndex) {
    // Not an inline element, or placement is not yet known
    if (clientRects.length < 2 || currentBasePlacement === null) return boundingRect;
     // There are two rects and they are disjoined
    if (clientRects.length === 2 && cursorRectIndex >= 0 && clientRects[0].left > clientRects[1].right) return clientRects[cursorRectIndex] || boundingRect;
    switch(currentBasePlacement){
        case 'top':
        case 'bottom':
            var firstRect = clientRects[0];
            var lastRect = clientRects[clientRects.length - 1];
            var isTop = currentBasePlacement === 'top';
            var top = firstRect.top;
            var bottom = lastRect.bottom;
            var left = isTop ? firstRect.left : lastRect.left;
            var right = isTop ? firstRect.right : lastRect.right;
            var width = right - left;
            var height = bottom - top;
            return {
                top: top,
                bottom: bottom,
                left: left,
                right: right,
                width: width,
                height: height
            };
        case 'left':
        case 'right':
            var minLeft = Math.min.apply(Math, clientRects.map(function(rects) {
                return rects.left;
            }));
            var maxRight = Math.max.apply(Math, clientRects.map(function(rects) {
                return rects.right;
            }));
            var measureRects = clientRects.filter(function(rect) {
                return currentBasePlacement === 'left' ? rect.left === minLeft : rect.right === maxRight;
            });
            var _top = measureRects[0].top;
            var _bottom = measureRects[measureRects.length - 1].bottom;
            var _left = minLeft;
            var _right = maxRight;
            var _width = _right - _left;
            var _height = _bottom - _top;
            return {
                top: _top,
                bottom: _bottom,
                left: _left,
                right: _right,
                width: _width,
                height: _height
            };
        default:
            return boundingRect;
    }
}
var $b013befce1f6217f$export$4bd4b47501432316 = {
    name: 'sticky',
    defaultValue: false,
    fn: function fn(instance) {
        var reference = instance.reference, popper = instance.popper;
        function getReference() {
            return instance.popperInstance ? instance.popperInstance.state.elements.reference : reference;
        }
        function shouldCheck(value) {
            return instance.props.sticky === true || instance.props.sticky === value;
        }
        var prevRefRect = null;
        var prevPopRect = null;
        function updatePosition() {
            var currentRefRect = shouldCheck('reference') ? getReference().getBoundingClientRect() : null;
            var currentPopRect = shouldCheck('popper') ? popper.getBoundingClientRect() : null;
            if (currentRefRect && $b013befce1f6217f$var$areRectsDifferent(prevRefRect, currentRefRect) || currentPopRect && $b013befce1f6217f$var$areRectsDifferent(prevPopRect, currentPopRect)) {
                if (instance.popperInstance) instance.popperInstance.update();
            }
            prevRefRect = currentRefRect;
            prevPopRect = currentPopRect;
            if (instance.state.isMounted) requestAnimationFrame(updatePosition);
        }
        return {
            onMount: function onMount() {
                if (instance.props.sticky) updatePosition();
            }
        };
    }
};
function $b013befce1f6217f$var$areRectsDifferent(rectA, rectB) {
    if (rectA && rectB) return rectA.top !== rectB.top || rectA.right !== rectB.right || rectA.bottom !== rectB.bottom || rectA.left !== rectB.left;
    return true;
}
$b013befce1f6217f$var$tippy.setDefaultProps({
    render: $b013befce1f6217f$var$render
});
var $b013befce1f6217f$export$2e2bcd8739ae039 = $b013befce1f6217f$var$tippy;


(0, $b013befce1f6217f$export$2e2bcd8739ae039).setDefaultProps({
    allowHTML: true,
    theme: "tooltip",
    appendTo: document.getElementById("app")
});
var $789b7d27a7c715a6$export$2e2bcd8739ae039 = (0, $b013befce1f6217f$export$2e2bcd8739ae039);


var $7a759511c361f2bd$exports = {};

$parcel$defineInteropFlag($7a759511c361f2bd$exports);

$parcel$export($7a759511c361f2bd$exports, "initTooltip", () => $7a759511c361f2bd$export$353372104066311a);
$parcel$export($7a759511c361f2bd$exports, "default", () => $7a759511c361f2bd$export$2e2bcd8739ae039);

function $7a759511c361f2bd$var$tooltipCreator({ target: target }) {
    const content = this.$el.dataset.tooltipText || (this.$refs.tooltip ? this.$refs.tooltip.innerHTML : null);
    if (content) return (0, $789b7d27a7c715a6$export$2e2bcd8739ae039)(target || this.$refs.tooltipTarget || this.$el, {
        delay: [
            200,
            0
        ],
        content: content,
        theme: "tooltip",
        triggerTarget: this.$el,
        onShow: ()=>this.$store.settings.showTooltips
    });
}
function $7a759511c361f2bd$export$353372104066311a(context, opts) {
    return $7a759511c361f2bd$var$tooltipCreator.bind(context)(opts || {});
}
function $7a759511c361f2bd$export$2e2bcd8739ae039() {
    return {
        init () {
            $7a759511c361f2bd$export$353372104066311a(this);
        }
    };
}


function $cbd28b10fa9798c7$export$2e2bcd8739ae039() {
    let tooltip = null;
    let dropdown = null;
    return {
        init () {
            if (this.$refs.tooltip) tooltip = (0, $7a759511c361f2bd$export$353372104066311a)(this, {
                target: this.$refs.icon
            });
            if (this.dropdownContent) this.initDropdown();
        },
        initDropdown () {
            dropdown = (0, $789b7d27a7c715a6$export$2e2bcd8739ae039)(this.$el, {
                content: this.dropdownContent,
                trigger: "click",
                theme: "menu",
                triggerTarget: this.$el,
                interactive: true,
                zIndex: 99999,
                onShow: ()=>{
                    if (!this.$store.settings.showTooltips) return false;
                    this.$dispatch("dropdown:show", {
                        dropdown: this
                    });
                },
                onHide: ()=>this.$dispatch("dropdown:hide", {
                        dropdown: this
                    })
            });
        },
        get dropdownContent () {
            if (this.$root && this.$root.id) {
                const dropdown = document.querySelector(`[data-dropdown-id="${this.$root.id}"]`);
                return dropdown ? dropdown.innerHTML : null;
            }
            return null;
        },
        hideDropdown () {
            if (dropdown) dropdown.hide();
        },
        startSpin () {
            this._spinning = true;
        },
        stopSpin (delay = 0) {
            setTimeout(()=>this._spinning = false, delay);
        },
        get _tooltip () {
            return tooltip;
        },
        _spinning: false
    };
}


var $e398acaded942bbe$exports = {};

$parcel$defineInteropFlag($e398acaded942bbe$exports);

$parcel$export($e398acaded942bbe$exports, "default", () => $e398acaded942bbe$export$2e2bcd8739ae039);

function $e398acaded942bbe$export$2e2bcd8739ae039(targetSelector) {
    return {
        width: 0,
        height: 0,
        resizing: false,
        target: null,
        init () {
            this.target = document.querySelector(targetSelector);
            if (this.target) {
                this.width = Math.round(this.target.clientWidth);
                this.height = Math.round(this.target.clientHeight);
                this.createObserver();
            }
        },
        createObserver () {
            if (this.target) this.observer = (0, $7ecd1fc3a6b35e5c$export$a2214cc2adb2dc44)(this.target, ({ width: width, height: height })=>{
                this.width = width;
                this.height = height;
            });
        },
        tearDown () {
            if (this.observer) this.observer.disconnect();
        }
    };
}


var $47a1c62621be0c54$exports = {};

$parcel$defineInteropFlag($47a1c62621be0c54$exports);

$parcel$export($47a1c62621be0c54$exports, "default", () => $47a1c62621be0c54$export$2e2bcd8739ae039);
var $4e31c85e11272811$exports = {};

$parcel$defineInteropFlag($4e31c85e11272811$exports);

$parcel$export($4e31c85e11272811$exports, "initClipboard", () => $4e31c85e11272811$export$c6684e6159b21de3);
$parcel$export($4e31c85e11272811$exports, "default", () => $4e31c85e11272811$export$2e2bcd8739ae039);

function $4e31c85e11272811$export$c6684e6159b21de3(context = {}) {
    let copyTimeout = null;
    return Object.assign(context, {
        copied: false,
        async copyToClipboard (target = null) {
            let targetEl;
            if (this.$refs.copyTarget) targetEl = this.$refs.copyTarget;
            else if (typeof target === "string") targetEl = document.querySelector(target);
            if (!targetEl) {
                this.warn("Could not find copy target");
                return false;
            }
            const content = (0, $fb8f79f7dd40b68f$export$6cb344a21ca18aec)(targetEl.innerHTML.trim());
            await window.navigator.clipboard.writeText(content);
            this.copied = true;
            if (copyTimeout) clearTimeout(copyTimeout);
            copyTimeout = setTimeout(()=>{
                this.copied = false;
                this.onCopyComplete();
            }, 1000);
            return content;
        },
        onCopyComplete () {}
    });
}
function $4e31c85e11272811$export$2e2bcd8739ae039() {
    return $4e31c85e11272811$export$c6684e6159b21de3({});
}



function $47a1c62621be0c54$export$2e2bcd8739ae039() {
    const button = (0, $cbd28b10fa9798c7$export$2e2bcd8739ae039)();
    return {
        ...button,
        copied: false,
        init () {
            button.init.bind(this)();
            (0, $4e31c85e11272811$export$c6684e6159b21de3)(this);
        }
    };
}


var $216ef7001f59f21d$exports = {};

$parcel$defineInteropFlag($216ef7001f59f21d$exports);

$parcel$export($216ef7001f59f21d$exports, "default", () => $216ef7001f59f21d$export$2e2bcd8739ae039);
function $216ef7001f59f21d$export$2e2bcd8739ae039() {
    return {};
}


var $e9904a14dabf652d$exports = {};

$parcel$defineInteropFlag($e9904a14dabf652d$exports);

$parcel$export($e9904a14dabf652d$exports, "default", () => $e9904a14dabf652d$export$2e2bcd8739ae039);
function $e9904a14dabf652d$export$2e2bcd8739ae039(store) {
    return {
        focussed: false,
        get active () {
            return store.active;
        },
        get text () {
            return store.text;
        },
        clear () {
            if (store.raw === "") this.$refs.input.blur();
            else store.raw = "";
        },
        focus () {
            this.$refs.input.focus();
        }
    };
}


var $d92d9d5253f84566$exports = {};

$parcel$defineInteropFlag($d92d9d5253f84566$exports);

$parcel$export($d92d9d5253f84566$exports, "default", () => $d92d9d5253f84566$export$2e2bcd8739ae039);
function $d92d9d5253f84566$export$2e2bcd8739ae039(store) {
    return {
        empty: false,
        children: [],
        init () {
            this.children = this.$refs.items ? Array.from(this.$refs.items.children) : [];
        },
        isOpen (id) {
            return store.open.includes(id);
        },
        setOpen (id) {
            store.open.push(id);
        },
        setClosed (id) {
            const index = store.open.indexOf(id);
            if (index > -1) store.open.splice(index, 1);
        },
        closeAll () {
            store.open.length = 0;
        },
        toggleOpen (id) {
            this.isOpen(id) ? this.setClosed(id) : this.setOpen(id);
        },
        async filter (text) {
            this.debug(`Filter text: ${text}`);
            await this.$nextTick();
            const filteredStates = await Promise.all(this.children.map(async (child)=>{
                const data = Alpine.$data(child);
                await data.filter(text);
                return data.filteredOut;
            }));
            const matchedChildCount = filteredStates.filter((s)=>!s).length;
            this.empty = matchedChildCount === 0;
            this.debug(`Children matching filter: ${matchedChildCount}/${this.children.length}`);
        }
    };
}


var $506dabb2bf255b38$exports = {};

$parcel$defineInteropFlag($506dabb2bf255b38$exports);

$parcel$export($506dabb2bf255b38$exports, "default", () => $506dabb2bf255b38$export$2e2bcd8739ae039);
var $7cac9a0d4b75bf4e$var$numeric = function(value, unit) {
    return Number(value.slice(0, -1 * unit.length));
};
var $7cac9a0d4b75bf4e$var$parseValue = function(value) {
    if (value.endsWith('px')) return {
        value: value,
        type: 'px',
        numeric: $7cac9a0d4b75bf4e$var$numeric(value, 'px')
    };
    if (value.endsWith('fr')) return {
        value: value,
        type: 'fr',
        numeric: $7cac9a0d4b75bf4e$var$numeric(value, 'fr')
    };
    if (value.endsWith('%')) return {
        value: value,
        type: '%',
        numeric: $7cac9a0d4b75bf4e$var$numeric(value, '%')
    };
    if (value === 'auto') return {
        value: value,
        type: 'auto'
    };
    return null;
};
var $7cac9a0d4b75bf4e$var$parse = function(rule) {
    return rule.split(' ').map($7cac9a0d4b75bf4e$var$parseValue);
};
var $7cac9a0d4b75bf4e$var$getSizeAtTrack = function(index, tracks, gap, end) {
    if (gap === void 0) gap = 0;
    if (end === void 0) end = false;
    var newIndex = end ? index + 1 : index;
    var trackSum = tracks.slice(0, newIndex).reduce(function(accum, value) {
        return accum + value.numeric;
    }, 0);
    var gapSum = gap ? index * gap : 0;
    return trackSum + gapSum;
};
var $7cac9a0d4b75bf4e$var$getStyles = function(rule, ownRules, matchedRules) {
    return ownRules.concat(matchedRules).map(function(r) {
        return r.style[rule];
    }).filter(function(style) {
        return style !== undefined && style !== '';
    });
};
var $7cac9a0d4b75bf4e$var$getGapValue = function(unit, size) {
    if (size.endsWith(unit)) return Number(size.slice(0, -1 * unit.length));
    return null;
};
var $7cac9a0d4b75bf4e$var$firstNonZero = function(tracks) {
    // eslint-disable-next-line no-plusplus
    for(var i = 0; i < tracks.length; i++){
        if (tracks[i].numeric > 0) return i;
    }
    return null;
};
var $7cac9a0d4b75bf4e$var$NOOP = function() {
    return false;
};
var $7cac9a0d4b75bf4e$var$defaultWriteStyle = function(element, gridTemplateProp, style) {
    // eslint-disable-next-line no-param-reassign
    element.style[gridTemplateProp] = style;
};
var $7cac9a0d4b75bf4e$var$getOption = function(options, propName, def) {
    var value = options[propName];
    if (value !== undefined) return value;
    return def;
};
function $7cac9a0d4b75bf4e$var$getMatchedCSSRules(el) {
    var ref;
    return (ref = []).concat.apply(ref, Array.from(el.ownerDocument.styleSheets).map(function(s) {
        var rules = [];
        try {
            rules = Array.from(s.cssRules || []);
        } catch (e) {
        // Ignore results on security error
        }
        return rules;
    })).filter(function(r) {
        var matches = false;
        try {
            matches = el.matches(r.selectorText);
        } catch (e) {
        // Ignore matching erros
        }
        return matches;
    });
}
var $7cac9a0d4b75bf4e$var$gridTemplatePropColumns = 'grid-template-columns';
var $7cac9a0d4b75bf4e$var$gridTemplatePropRows = 'grid-template-rows';
var $7cac9a0d4b75bf4e$var$Gutter = function Gutter(direction, options, parentOptions) {
    this.direction = direction;
    this.element = options.element;
    this.track = options.track;
    if (direction === 'column') {
        this.gridTemplateProp = $7cac9a0d4b75bf4e$var$gridTemplatePropColumns;
        this.gridGapProp = 'grid-column-gap';
        this.cursor = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'columnCursor', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'cursor', 'col-resize'));
        this.snapOffset = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'columnSnapOffset', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'snapOffset', 30));
        this.dragInterval = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'columnDragInterval', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'dragInterval', 1));
        this.clientAxis = 'clientX';
        this.optionStyle = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'gridTemplateColumns');
    } else if (direction === 'row') {
        this.gridTemplateProp = $7cac9a0d4b75bf4e$var$gridTemplatePropRows;
        this.gridGapProp = 'grid-row-gap';
        this.cursor = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'rowCursor', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'cursor', 'row-resize'));
        this.snapOffset = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'rowSnapOffset', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'snapOffset', 30));
        this.dragInterval = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'rowDragInterval', $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'dragInterval', 1));
        this.clientAxis = 'clientY';
        this.optionStyle = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'gridTemplateRows');
    }
    this.onDragStart = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'onDragStart', $7cac9a0d4b75bf4e$var$NOOP);
    this.onDragEnd = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'onDragEnd', $7cac9a0d4b75bf4e$var$NOOP);
    this.onDrag = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'onDrag', $7cac9a0d4b75bf4e$var$NOOP);
    this.writeStyle = $7cac9a0d4b75bf4e$var$getOption(parentOptions, 'writeStyle', $7cac9a0d4b75bf4e$var$defaultWriteStyle);
    this.startDragging = this.startDragging.bind(this);
    this.stopDragging = this.stopDragging.bind(this);
    this.drag = this.drag.bind(this);
    this.minSizeStart = options.minSizeStart;
    this.minSizeEnd = options.minSizeEnd;
    if (options.element) {
        this.element.addEventListener('mousedown', this.startDragging);
        this.element.addEventListener('touchstart', this.startDragging);
    }
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getDimensions = function getDimensions() {
    var ref = this.grid.getBoundingClientRect();
    var width = ref.width;
    var height = ref.height;
    var top = ref.top;
    var bottom = ref.bottom;
    var left = ref.left;
    var right = ref.right;
    if (this.direction === 'column') {
        this.start = top;
        this.end = bottom;
        this.size = height;
    } else if (this.direction === 'row') {
        this.start = left;
        this.end = right;
        this.size = width;
    }
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getSizeAtTrack = function getSizeAtTrack$1(track, end) {
    return $7cac9a0d4b75bf4e$var$getSizeAtTrack(track, this.computedPixels, this.computedGapPixels, end);
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getSizeOfTrack = function getSizeOfTrack(track) {
    return this.computedPixels[track].numeric;
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getRawTracks = function getRawTracks() {
    var tracks = $7cac9a0d4b75bf4e$var$getStyles(this.gridTemplateProp, [
        this.grid
    ], $7cac9a0d4b75bf4e$var$getMatchedCSSRules(this.grid));
    if (!tracks.length) {
        if (this.optionStyle) return this.optionStyle;
        throw Error('Unable to determine grid template tracks from styles.');
    }
    return tracks[0];
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getGap = function getGap() {
    var gap = $7cac9a0d4b75bf4e$var$getStyles(this.gridGapProp, [
        this.grid
    ], $7cac9a0d4b75bf4e$var$getMatchedCSSRules(this.grid));
    if (!gap.length) return null;
    return gap[0];
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getRawComputedTracks = function getRawComputedTracks() {
    return window.getComputedStyle(this.grid)[this.gridTemplateProp];
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getRawComputedGap = function getRawComputedGap() {
    return window.getComputedStyle(this.grid)[this.gridGapProp];
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.setTracks = function setTracks(raw) {
    this.tracks = raw.split(' ');
    this.trackValues = $7cac9a0d4b75bf4e$var$parse(raw);
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.setComputedTracks = function setComputedTracks(raw) {
    this.computedTracks = raw.split(' ');
    this.computedPixels = $7cac9a0d4b75bf4e$var$parse(raw);
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.setGap = function setGap(raw) {
    this.gap = raw;
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.setComputedGap = function setComputedGap(raw) {
    this.computedGap = raw;
    this.computedGapPixels = $7cac9a0d4b75bf4e$var$getGapValue('px', this.computedGap) || 0;
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.getMousePosition = function getMousePosition(e) {
    if ('touches' in e) return e.touches[0][this.clientAxis];
    return e[this.clientAxis];
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.startDragging = function startDragging(e) {
    if ('button' in e && e.button !== 0) return;
    // Don't actually drag the element. We emulate that in the drag function.
    e.preventDefault();
    if (this.element) this.grid = this.element.parentNode;
    else this.grid = e.target.parentNode;
    this.getDimensions();
    this.setTracks(this.getRawTracks());
    this.setComputedTracks(this.getRawComputedTracks());
    this.setGap(this.getGap());
    this.setComputedGap(this.getRawComputedGap());
    var trackPercentage = this.trackValues.filter(function(track) {
        return track.type === '%';
    });
    var trackFr = this.trackValues.filter(function(track) {
        return track.type === 'fr';
    });
    this.totalFrs = trackFr.length;
    if (this.totalFrs) {
        var track = $7cac9a0d4b75bf4e$var$firstNonZero(trackFr);
        if (track !== null) this.frToPixels = this.computedPixels[track].numeric / trackFr[track].numeric;
    }
    if (trackPercentage.length) {
        var track$1 = $7cac9a0d4b75bf4e$var$firstNonZero(trackPercentage);
        if (track$1 !== null) this.percentageToPixels = this.computedPixels[track$1].numeric / trackPercentage[track$1].numeric;
    }
    // get start of gutter track
    var gutterStart = this.getSizeAtTrack(this.track, false) + this.start;
    this.dragStartOffset = this.getMousePosition(e) - gutterStart;
    this.aTrack = this.track - 1;
    if (this.track < this.tracks.length - 1) this.bTrack = this.track + 1;
    else throw Error("Invalid track index: " + this.track + ". Track must be between two other tracks and only " + this.tracks.length + " tracks were found.");
    this.aTrackStart = this.getSizeAtTrack(this.aTrack, false) + this.start;
    this.bTrackEnd = this.getSizeAtTrack(this.bTrack, true) + this.start;
    // Set the dragging property of the pair object.
    this.dragging = true;
    // All the binding. `window` gets the stop events in case we drag out of the elements.
    window.addEventListener('mouseup', this.stopDragging);
    window.addEventListener('touchend', this.stopDragging);
    window.addEventListener('touchcancel', this.stopDragging);
    window.addEventListener('mousemove', this.drag);
    window.addEventListener('touchmove', this.drag);
    // Disable selection. Disable!
    this.grid.addEventListener('selectstart', $7cac9a0d4b75bf4e$var$NOOP);
    this.grid.addEventListener('dragstart', $7cac9a0d4b75bf4e$var$NOOP);
    this.grid.style.userSelect = 'none';
    this.grid.style.webkitUserSelect = 'none';
    this.grid.style.MozUserSelect = 'none';
    this.grid.style.pointerEvents = 'none';
    // Set the cursor at multiple levels
    this.grid.style.cursor = this.cursor;
    window.document.body.style.cursor = this.cursor;
    this.onDragStart(this.direction, this.track);
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.stopDragging = function stopDragging() {
    this.dragging = false;
    // Remove the stored event listeners. This is why we store them.
    this.cleanup();
    this.onDragEnd(this.direction, this.track);
    if (this.needsDestroy) {
        if (this.element) {
            this.element.removeEventListener('mousedown', this.startDragging);
            this.element.removeEventListener('touchstart', this.startDragging);
        }
        this.destroyCb();
        this.needsDestroy = false;
        this.destroyCb = null;
    }
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.drag = function drag(e) {
    var mousePosition = this.getMousePosition(e);
    var gutterSize = this.getSizeOfTrack(this.track);
    var minMousePosition = this.aTrackStart + this.minSizeStart + this.dragStartOffset + this.computedGapPixels;
    var maxMousePosition = this.bTrackEnd - this.minSizeEnd - this.computedGapPixels - (gutterSize - this.dragStartOffset);
    var minMousePositionOffset = minMousePosition + this.snapOffset;
    var maxMousePositionOffset = maxMousePosition - this.snapOffset;
    if (mousePosition < minMousePositionOffset) mousePosition = minMousePosition;
    if (mousePosition > maxMousePositionOffset) mousePosition = maxMousePosition;
    if (mousePosition < minMousePosition) mousePosition = minMousePosition;
    else if (mousePosition > maxMousePosition) mousePosition = maxMousePosition;
    var aTrackSize = mousePosition - this.aTrackStart - this.dragStartOffset - this.computedGapPixels;
    var bTrackSize = this.bTrackEnd - mousePosition + this.dragStartOffset - gutterSize - this.computedGapPixels;
    if (this.dragInterval > 1) {
        var aTrackSizeIntervaled = Math.round(aTrackSize / this.dragInterval) * this.dragInterval;
        bTrackSize -= aTrackSizeIntervaled - aTrackSize;
        aTrackSize = aTrackSizeIntervaled;
    }
    if (aTrackSize < this.minSizeStart) aTrackSize = this.minSizeStart;
    if (bTrackSize < this.minSizeEnd) bTrackSize = this.minSizeEnd;
    if (this.trackValues[this.aTrack].type === 'px') this.tracks[this.aTrack] = aTrackSize + "px";
    else if (this.trackValues[this.aTrack].type === 'fr') {
        if (this.totalFrs === 1) this.tracks[this.aTrack] = '1fr';
        else {
            var targetFr = aTrackSize / this.frToPixels;
            this.tracks[this.aTrack] = targetFr + "fr";
        }
    } else if (this.trackValues[this.aTrack].type === '%') {
        var targetPercentage = aTrackSize / this.percentageToPixels;
        this.tracks[this.aTrack] = targetPercentage + "%";
    }
    if (this.trackValues[this.bTrack].type === 'px') this.tracks[this.bTrack] = bTrackSize + "px";
    else if (this.trackValues[this.bTrack].type === 'fr') {
        if (this.totalFrs === 1) this.tracks[this.bTrack] = '1fr';
        else {
            var targetFr$1 = bTrackSize / this.frToPixels;
            this.tracks[this.bTrack] = targetFr$1 + "fr";
        }
    } else if (this.trackValues[this.bTrack].type === '%') {
        var targetPercentage$1 = bTrackSize / this.percentageToPixels;
        this.tracks[this.bTrack] = targetPercentage$1 + "%";
    }
    var style = this.tracks.join(' ');
    this.writeStyle(this.grid, this.gridTemplateProp, style);
    this.onDrag(this.direction, this.track, style);
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.cleanup = function cleanup() {
    window.removeEventListener('mouseup', this.stopDragging);
    window.removeEventListener('touchend', this.stopDragging);
    window.removeEventListener('touchcancel', this.stopDragging);
    window.removeEventListener('mousemove', this.drag);
    window.removeEventListener('touchmove', this.drag);
    if (this.grid) {
        this.grid.removeEventListener('selectstart', $7cac9a0d4b75bf4e$var$NOOP);
        this.grid.removeEventListener('dragstart', $7cac9a0d4b75bf4e$var$NOOP);
        this.grid.style.userSelect = '';
        this.grid.style.webkitUserSelect = '';
        this.grid.style.MozUserSelect = '';
        this.grid.style.pointerEvents = '';
        this.grid.style.cursor = '';
    }
    window.document.body.style.cursor = '';
};
$7cac9a0d4b75bf4e$var$Gutter.prototype.destroy = function destroy(immediate, cb) {
    if (immediate === void 0) immediate = true;
    if (immediate || this.dragging === false) {
        this.cleanup();
        if (this.element) {
            this.element.removeEventListener('mousedown', this.startDragging);
            this.element.removeEventListener('touchstart', this.startDragging);
        }
        if (cb) cb();
    } else {
        this.needsDestroy = true;
        if (cb) this.destroyCb = cb;
    }
};
var $7cac9a0d4b75bf4e$var$getTrackOption = function(options, track, defaultValue) {
    if (track in options) return options[track];
    return defaultValue;
};
var $7cac9a0d4b75bf4e$var$createGutter = function(direction, options) {
    return function(gutterOptions) {
        if (gutterOptions.track < 1) throw Error("Invalid track index: " + gutterOptions.track + ". Track must be between two other tracks.");
        var trackMinSizes = direction === 'column' ? options.columnMinSizes || {} : options.rowMinSizes || {};
        var trackMinSize = direction === 'column' ? 'columnMinSize' : 'rowMinSize';
        return new $7cac9a0d4b75bf4e$var$Gutter(direction, Object.assign({}, {
            minSizeStart: $7cac9a0d4b75bf4e$var$getTrackOption(trackMinSizes, gutterOptions.track - 1, $7cac9a0d4b75bf4e$var$getOption(options, trackMinSize, $7cac9a0d4b75bf4e$var$getOption(options, 'minSize', 0))),
            minSizeEnd: $7cac9a0d4b75bf4e$var$getTrackOption(trackMinSizes, gutterOptions.track + 1, $7cac9a0d4b75bf4e$var$getOption(options, trackMinSize, $7cac9a0d4b75bf4e$var$getOption(options, 'minSize', 0)))
        }, gutterOptions), options);
    };
};
var $7cac9a0d4b75bf4e$var$Grid = function Grid(options) {
    var this$1 = this;
    this.columnGutters = {};
    this.rowGutters = {};
    this.options = Object.assign({}, {
        columnGutters: options.columnGutters || [],
        rowGutters: options.rowGutters || [],
        columnMinSizes: options.columnMinSizes || {},
        rowMinSizes: options.rowMinSizes || {}
    }, options);
    this.options.columnGutters.forEach(function(gutterOptions) {
        this$1.columnGutters[gutterOptions.track] = $7cac9a0d4b75bf4e$var$createGutter('column', this$1.options)(gutterOptions);
    });
    this.options.rowGutters.forEach(function(gutterOptions) {
        this$1.rowGutters[gutterOptions.track] = $7cac9a0d4b75bf4e$var$createGutter('row', this$1.options)(gutterOptions);
    });
};
$7cac9a0d4b75bf4e$var$Grid.prototype.addColumnGutter = function addColumnGutter(element, track) {
    if (this.columnGutters[track]) this.columnGutters[track].destroy();
    this.columnGutters[track] = $7cac9a0d4b75bf4e$var$createGutter('column', this.options)({
        element: element,
        track: track
    });
};
$7cac9a0d4b75bf4e$var$Grid.prototype.addRowGutter = function addRowGutter(element, track) {
    if (this.rowGutters[track]) this.rowGutters[track].destroy();
    this.rowGutters[track] = $7cac9a0d4b75bf4e$var$createGutter('row', this.options)({
        element: element,
        track: track
    });
};
$7cac9a0d4b75bf4e$var$Grid.prototype.removeColumnGutter = function removeColumnGutter(track, immediate) {
    var this$1 = this;
    if (immediate === void 0) immediate = true;
    if (this.columnGutters[track]) this.columnGutters[track].destroy(immediate, function() {
        delete this$1.columnGutters[track];
    });
};
$7cac9a0d4b75bf4e$var$Grid.prototype.removeRowGutter = function removeRowGutter(track, immediate) {
    var this$1 = this;
    if (immediate === void 0) immediate = true;
    if (this.rowGutters[track]) this.rowGutters[track].destroy(immediate, function() {
        delete this$1.rowGutters[track];
    });
};
$7cac9a0d4b75bf4e$var$Grid.prototype.handleDragStart = function handleDragStart(e, direction, track) {
    if (direction === 'column') {
        if (this.columnGutters[track]) this.columnGutters[track].destroy();
        this.columnGutters[track] = $7cac9a0d4b75bf4e$var$createGutter('column', this.options)({
            track: track
        });
        this.columnGutters[track].startDragging(e);
    } else if (direction === 'row') {
        if (this.rowGutters[track]) this.rowGutters[track].destroy();
        this.rowGutters[track] = $7cac9a0d4b75bf4e$var$createGutter('row', this.options)({
            track: track
        });
        this.rowGutters[track].startDragging(e);
    }
};
$7cac9a0d4b75bf4e$var$Grid.prototype.destroy = function destroy(immediate) {
    var this$1 = this;
    if (immediate === void 0) immediate = true;
    Object.keys(this.columnGutters).forEach(function(track) {
        return this$1.columnGutters[track].destroy(immediate, function() {
            delete this$1.columnGutters[track];
        });
    });
    Object.keys(this.rowGutters).forEach(function(track) {
        return this$1.rowGutters[track].destroy(immediate, function() {
            delete this$1.rowGutters[track];
        });
    });
};
function $7cac9a0d4b75bf4e$var$index(options) {
    return new $7cac9a0d4b75bf4e$var$Grid(options);
}
var $7cac9a0d4b75bf4e$export$2e2bcd8739ae039 = $7cac9a0d4b75bf4e$var$index;



function $506dabb2bf255b38$export$2e2bcd8739ae039({ split: split, opts: opts = {} }) {
    let splitter = null;
    const shouldSplit = split.sizes !== null;
    return {
        layoutResizing: false,
        layoutWidth: null,
        layoutHeight: null,
        forceOrientation: null,
        get vertical () {
            if (this.forceOrientation) return this.forceOrientation === "vertical";
            return split.direction === "vertical";
        },
        get horizontal () {
            if (this.forceOrientation) return this.forceOrientation === "horizontal";
            return split.direction === "horizontal";
        },
        get splits () {
            if (this.horizontal && split.horizontalSizes) return split.horizontalSizes;
            else if (this.vertical && split.verticalSizes) return split.verticalSizes;
            else return split.sizes || [];
        },
        get minSizes () {
            if (this.horizontal && opts.minHorizontalSizes) return opts.minHorizontalSizes;
            else if (this.vertical && opts.minVerticalSizes) return opts.minVerticalSizes;
            else return opts.minSizes || [];
        },
        init () {
            (0, $7ecd1fc3a6b35e5c$export$a2214cc2adb2dc44)(this.$el, ({ width: width, height: height })=>{
                this.layoutWidth = width;
                this.layoutHeight = height;
            });
        },
        switchOrientation () {
            split.direction = this.vertical ? "horizontal" : "vertical";
        },
        registerGutter () {
            this._gutters.push(this.$el);
        },
        initSplit () {
            if (shouldSplit && this._gutters.length) {
                this._destroySplit();
                const dir = this.horizontal ? "row" : "column";
                splitter = (0, $7cac9a0d4b75bf4e$export$2e2bcd8739ae039)({
                    [`${dir}Gutters`]: $506dabb2bf255b38$var$gutterSplits(this._gutters),
                    [`${dir}MinSizes`]: $506dabb2bf255b38$var$sizeSplits(this.minSizes),
                    snapOffset: 0,
                    dragInterval: 1,
                    writeStyle () {},
                    onDrag: (dir, gutterTrack, style)=>{
                        const splits = style.split(" ").map((value, i)=>i % 2 == 0 ? value : null).filter((v)=>v);
                        this._setSplits(splits);
                    },
                    onDragStart: ()=>{
                        this.layoutResizing = true;
                        this.$dispatch("layout:resize-start", {
                            layout: this
                        });
                    },
                    onDragEnd: ()=>{
                        this.layoutResizing = false;
                        this.$dispatch("layout:resize-end", {
                            layout: this
                        });
                    }
                });
            }
        },
        bindings: {
            root: {
                [":style"] () {
                    return {
                        "grid-template-columns": shouldSplit && this.vertical && $506dabb2bf255b38$var$sizeStr(this.splits),
                        "grid-template-rows": shouldSplit && this.horizontal && $506dabb2bf255b38$var$sizeStr(this.splits)
                    };
                }
            }
        },
        // protected
        _gutters: [],
        _destroySplit () {
            if (splitter) splitter.destroy();
        },
        _setSplits (splits) {
            if (this.horizontal && split.horizontalSizes) split.horizontalSizes = splits;
            else if (this.vertical && split.verticalSizes) split.verticalSizes = splits;
            else split.sizes = splits;
        }
    };
}
// utils
function $506dabb2bf255b38$var$sizeStr(sizes) {
    const values = [];
    sizes.forEach((size)=>values.push(size, "1px"));
    return values.slice(0, -1).join(" ");
}
function $506dabb2bf255b38$var$gutterSplits(gutters) {
    return gutters.map((element, i)=>{
        return {
            track: i * 2 + 1,
            element: element
        };
    });
}
function $506dabb2bf255b38$var$sizeSplits(sizes) {
    const splits = {};
    sizes.forEach((value, i)=>{
        if (value !== null) splits[i * 2] = value;
    });
    return splits;
}


var $a87dacf5139b5e2f$exports = {};

$parcel$defineInteropFlag($a87dacf5139b5e2f$exports);

$parcel$export($a87dacf5139b5e2f$exports, "default", () => $a87dacf5139b5e2f$export$2e2bcd8739ae039);
function $a87dacf5139b5e2f$export$2e2bcd8739ae039(store) {
    return {
        get store () {
            return store || this;
        },
        get id () {
            return this.$root.id;
        },
        get panels () {
            return Array.from(this.$refs.panels.children);
        },
        isActive (el) {
            return this.store.activeTab === this._getRef(el);
        },
        // protected
        _getRef (el) {
            return el.getAttribute("x-ref");
        }
    };
}


var $0db07828cadc68e0$exports = {};

$parcel$defineInteropFlag($0db07828cadc68e0$exports);

$parcel$export($0db07828cadc68e0$exports, "default", () => $0db07828cadc68e0$export$2e2bcd8739ae039);




function $0db07828cadc68e0$export$2e2bcd8739ae039(store) {
    const initial = store ? store.activeTab : null;
    let dropdown = null;
    return {
        visibleTabsCount: 0,
        triggerLeft: 0,
        get store () {
            return store || this;
        },
        get tabs () {
            return this.$refs.tabs ? Array.from(this.$refs.tabs.children) : [];
        },
        get dropdownTabs () {
            return Array.from(this.$refs.tabsDropdown ? this.$refs.tabsDropdown.children : []);
        },
        get tabWidths () {
            return this.tabs.map((tab)=>(0, $490552754c23ef6f$export$bdf7e699b242f476)(tab, {
                    includeMargins: true
                }).width);
        },
        init () {
            this.$nextTick(()=>{
                if (this.$root.parentElement.offsetWidth === this.$root.offsetWidth) this.visibleTabsCount = this.tabs.length;
                dropdown = (0, $789b7d27a7c715a6$export$2e2bcd8739ae039)(this.$refs.dropdownTrigger, {
                    content: this.$refs.tabsDropdown,
                    theme: "menu",
                    interactive: true,
                    trigger: "click",
                    placement: "bottom",
                    appendTo: this.$root
                });
                const initialTab = initial ? this.tabs.find((t)=>this._getRef(t) === initial) : this.tabs[0];
                this.selectTab(initialTab || this.tabs[0], true);
                this.parentObserver = (0, $7ecd1fc3a6b35e5c$export$a2214cc2adb2dc44)(this.$root.parentElement, (0, $c5d017602d25d050$export$61fc7d43ac8f84b0)(10, this.handleResize.bind(this)));
                this.$watch("visibleTabsCount", (value)=>{
                    this.debug(`'#${this.$root.id}' visible tabs count:`, value);
                });
            });
        },
        handleResize ({ width: width }) {
            if (width === this._lastMeasuredWidth) return;
            if (width === this.$root.offsetWidth) {
                this.visibleTabsCount = this.tabs.length;
                return;
            }
            let sumTabWidths = 60;
            let triggerLeft = 20;
            let visibleTabsCount = 0;
            this.tabWidths.forEach((tabWidth)=>{
                sumTabWidths += tabWidth;
                if (sumTabWidths < width) {
                    triggerLeft += tabWidth;
                    visibleTabsCount++;
                }
            });
            this.visibleTabsCount = visibleTabsCount;
            this.triggerLeft = triggerLeft;
            this._lastMeasuredWidth = width;
        },
        selectTab (el, initial = false) {
            this.store.activeTab = this._getRef(el);
            dropdown.hide();
            if (!initial) this.$dispatch("tabs:change", {
                tabs: this
            });
        },
        isSelected (el) {
            return this.store.activeTab === this._getRef(el);
        },
        isDisabled (el) {
            return el.getAttribute("data-disabled") == "true";
        },
        hasHiddenTabs () {
            return this.visibleTabsCount < this.tabs.length;
        },
        // protected
        _lastMeasuredWidth: 0,
        _getRef (el) {
            return el ? el.getAttribute("x-ref").replace("dropdown-", "") : null;
        }
    };
}


var $6d64716f0b34fdf4$exports = {};

$parcel$defineInteropFlag($6d64716f0b34fdf4$exports);

$parcel$export($6d64716f0b34fdf4$exports, "default", () => $6d64716f0b34fdf4$export$2e2bcd8739ae039);
function $6d64716f0b34fdf4$export$2e2bcd8739ae039(store) {
    store = store || {
        width: "100%",
        height: "100%"
    };
    store.resizing = false;
    return {
        store: store,
        get maxWidth () {
            return this.store.width === "100%" ? "100%" : `${store.width}px`;
        },
        get maxHeight () {
            return this.store.height === "100%" ? "100%" : `${store.height}px`;
        },
        get parentWidth () {
            return Math.round(this.$root.clientWidth);
        },
        get parentHeight () {
            return Math.round(this.$root.clientHeight);
        },
        get reflowing () {
            return this.$store.layout.reflowing;
        },
        reloadIframe () {
            this.$refs.iframe.contentWindow.location.reload();
        },
        start () {
            this.$dispatch("viewport:resize-start", this._resizeData);
            this.$store.layout.reflowing = true;
            this.store.resizing = true;
        },
        end () {
            this.$store.layout.reflowing = false;
            this.store.resizing = false;
            this.$dispatch("viewport:resize-complete", this._resizeData);
        },
        onResizeStart (e) {
            this.onResizeWidthStart(e);
            this.onResizeHeightStart(e);
        },
        toggleFullSize () {
            const { height: height, width: width } = store;
            if (height === "100%" && width === "100%") {
                this.toggleFullHeight();
                this.toggleFullWidth();
            } else {
                if (height !== "100%") this.toggleFullHeight();
                if (width !== "100%") this.toggleFullWidth();
            }
        },
        onResizeWidth (e) {
            const width = this.resizeStartWidth - (this.resizeStartPositionX - e.pageX) * 2;
            const boundedWidth = Math.min(Math.max(Math.round(width), 200), this.parentWidth);
            this.store.width = boundedWidth === this.parentWidth ? "100%" : boundedWidth;
            this.$dispatch("viewport:resize-progress", this._resizeData);
        },
        onResizeWidthStart (e) {
            this.start();
            this.onResizeWidth = this.onResizeWidth.bind(this);
            this.onResizeWidthEnd = this.onResizeWidthEnd.bind(this);
            this.resizeStartPositionX = e.pageX;
            this.resizeStartWidth = this.$refs.wrapper.clientWidth;
            window.addEventListener("pointermove", this.onResizeWidth);
            window.addEventListener("pointerup", this.onResizeWidthEnd);
        },
        onResizeWidthEnd () {
            window.removeEventListener("pointermove", this.onResizeWidth);
            window.removeEventListener("pointerup", this.onResizeWidthEnd);
            this.end();
        },
        toggleFullWidth () {
            this.$dispatch("viewport:resize-start", this._resizeData);
            const { width: width, lastWidth: lastWidth } = store;
            if (width === "100%" && lastWidth) this.store.width = lastWidth;
            else {
                this.store.lastWidth = width;
                this.store.width = "100%";
            }
            this.$dispatch("viewport:resize-complete", this._resizeData);
        },
        onResizeHeight (e) {
            const height = this.resizeStartHeight - (this.resizeStartPositionY - e.pageY);
            const boundedHeight = Math.min(Math.max(Math.round(height), 200), this.parentHeight);
            this.store.height = boundedHeight === this.parentHeight ? "100%" : boundedHeight;
            this.$dispatch("viewport:resize-progress", this._resizeData);
        },
        onResizeHeightStart (e) {
            this.start();
            this.onResizeHeight = this.onResizeHeight.bind(this);
            this.onResizeHeightEnd = this.onResizeHeightEnd.bind(this);
            this.resizeStartPositionY = e.pageY;
            this.resizeStartHeight = this.$refs.wrapper.clientHeight;
            window.addEventListener("pointermove", this.onResizeHeight);
            window.addEventListener("pointerup", this.onResizeHeightEnd);
        },
        onResizeHeightEnd () {
            window.removeEventListener("pointermove", this.onResizeHeight);
            window.removeEventListener("pointerup", this.onResizeHeightEnd);
            this.end();
        },
        toggleFullHeight () {
            this.$dispatch("viewport:resize-start", this._resizeData);
            const { height: height, lastHeight: lastHeight } = store;
            if (height === "100%" && lastHeight) this.store.height = lastHeight;
            else {
                this.store.lastHeight = height;
                this.store.height = "100%";
            }
            this.$dispatch("viewport:resize-complete", this._resizeData);
        },
        // protected
        get _resizeData () {
            return {
                width: this.store.width,
                height: this.store.height,
                viewport: this
            };
        }
    };
}


$88dfd91701b4cd8b$exports = {
    "code": $99486586f6691564$exports,
    "button": $cbd28b10fa9798c7$exports,
    "dimensions_display": $e398acaded942bbe$exports,
    "copy_button": $47a1c62621be0c54$exports,
    "embed_code_dropdown": $216ef7001f59f21d$exports,
    "filter": $e9904a14dabf652d$exports,
    "nav": $d92d9d5253f84566$exports,
    "split_layout": $506dabb2bf255b38$exports,
    "tab_panels": $a87dacf5139b5e2f$exports,
    "tabs": $0db07828cadc68e0$exports,
    "viewport": $6d64716f0b34fdf4$exports
};


var $5d1c9207cb730903$exports = {};
var $6a9b69d9cc7f810f$exports = {};

$parcel$defineInteropFlag($6a9b69d9cc7f810f$exports);

$parcel$export($6a9b69d9cc7f810f$exports, "default", () => $6a9b69d9cc7f810f$export$2e2bcd8739ae039);
var $cdfeaa1e0e8d642c$exports = {};
/*! js-cookie v3.0.5 | MIT */ (function(global, factory) {
    $cdfeaa1e0e8d642c$exports = factory();
})($cdfeaa1e0e8d642c$exports, function() {
    'use strict';
    /* eslint-disable no-var */ function assign(target) {
        for(var i = 1; i < arguments.length; i++){
            var source = arguments[i];
            for(var key in source)target[key] = source[key];
        }
        return target;
    }
    /* eslint-enable no-var */ /* eslint-disable no-var */ var defaultConverter = {
        read: function(value) {
            if (value[0] === '"') value = value.slice(1, -1);
            return value.replace(/(%[\dA-F]{2})+/gi, decodeURIComponent);
        },
        write: function(value) {
            return encodeURIComponent(value).replace(/%(2[346BF]|3[AC-F]|40|5[BDE]|60|7[BCD])/g, decodeURIComponent);
        }
    };
    /* eslint-enable no-var */ /* eslint-disable no-var */ function init(converter, defaultAttributes) {
        function set(name, value, attributes) {
            if (typeof document === 'undefined') return;
            attributes = assign({}, defaultAttributes, attributes);
            if (typeof attributes.expires === 'number') attributes.expires = new Date(Date.now() + attributes.expires * 864e5);
            if (attributes.expires) attributes.expires = attributes.expires.toUTCString();
            name = encodeURIComponent(name).replace(/%(2[346B]|5E|60|7C)/g, decodeURIComponent).replace(/[()]/g, escape);
            var stringifiedAttributes = '';
            for(var attributeName in attributes){
                if (!attributes[attributeName]) continue;
                stringifiedAttributes += '; ' + attributeName;
                if (attributes[attributeName] === true) continue;
                // Considers RFC 6265 section 5.2:
                // ...
                // 3.  If the remaining unparsed-attributes contains a %x3B (";")
                //     character:
                // Consume the characters of the unparsed-attributes up to,
                // not including, the first %x3B (";") character.
                // ...
                stringifiedAttributes += '=' + attributes[attributeName].split(';')[0];
            }
            return document.cookie = name + '=' + converter.write(value, name) + stringifiedAttributes;
        }
        function get(name) {
            if (typeof document === 'undefined' || arguments.length && !name) return;
            // To prevent the for loop in the first place assign an empty array
            // in case there are no cookies at all.
            var cookies = document.cookie ? document.cookie.split('; ') : [];
            var jar = {};
            for(var i = 0; i < cookies.length; i++){
                var parts = cookies[i].split('=');
                var value = parts.slice(1).join('=');
                try {
                    var found = decodeURIComponent(parts[0]);
                    jar[found] = converter.read(value, found);
                    if (name === found) break;
                } catch (e) {}
            }
            return name ? jar[name] : jar;
        }
        return Object.create({
            set: set,
            get: get,
            remove: function(name, attributes) {
                set(name, '', assign({}, attributes, {
                    expires: -1
                }));
            },
            withAttributes: function(attributes) {
                return init(this.converter, assign({}, this.attributes, attributes));
            },
            withConverter: function(converter) {
                return init(assign({}, this.converter, converter), this.attributes);
            }
        }, {
            attributes: {
                value: Object.freeze(defaultAttributes)
            },
            converter: {
                value: Object.freeze(converter)
            }
        });
    }
    var api = init(defaultConverter, {
        path: '/'
    });
    /* eslint-enable no-var */ return api;
});



function $6a9b69d9cc7f810f$export$2e2bcd8739ae039({ name: name, value: value }) {
    return {
        name: name,
        value: value,
        init () {
            this.$watch("value", ()=>this.update());
        },
        update () {
            (0, (/*@__PURE__*/$parcel$interopDefault($cdfeaa1e0e8d642c$exports))).set(`lookbook-display-${name}`, this.value);
            const searchParams = new URLSearchParams(window.location.search);
            const display = searchParams.get("_display");
            const displayParams = display ? (0, $fb8f79f7dd40b68f$export$f720fd0ddbeb53d9)(display) : {};
            displayParams[this.name] = this.value;
            searchParams.set("_display", (0, $fb8f79f7dd40b68f$export$c788aab010beeaec)(displayParams));
            const path = location.href.replace(location.search, "");
            this.navigateTo(`${path}?${searchParams.toString()}`);
        }
    };
}


var $c299e36fa9e271bc$exports = {};

$parcel$defineInteropFlag($c299e36fa9e271bc$exports);

$parcel$export($c299e36fa9e271bc$exports, "default", () => $c299e36fa9e271bc$export$2e2bcd8739ae039);
var $ef5e88eaa61efd95$exports = {};
/*
 * File: iframeResizer.js
 * Desc: Force iframes to size to content.
 * Requires: iframeResizer.contentWindow.js to be loaded into the target frame.
 * Doc: https://iframe-resizer.com
 * Author: David J. Bradshaw - info@iframe-resizer.com
 */ console.info(`
IFRAME-RESIZER

Iframe-Resizer 5 is now available via the following two packages:

 * @iframe-resizer/parent
 * @iframe-resizer/child

Additionally their are also new versions of iframe-resizer for React, Vue, and jQuery.

Version 5 of iframe-resizer has been extensively rewritten to use modern browser APIs, which has enabled significantly better performance and greater accuracy in the detection of content resizing events.

Please see https://iframe-resizer.com/upgrade for more details.
`);
(function(undefined) {
    if (typeof window === 'undefined') return; // don't run for server side render
    // var VERSION = '4.3.11'
    var count = 0, destroyObserver, logEnabled = false, hiddenCheckEnabled = false, msgHeader = 'message', msgHeaderLen = msgHeader.length, msgId = '[iFrameSizer]', msgIdLen = msgId.length, pagePosition = null, requestAnimationFrame = window.requestAnimationFrame, resetRequiredMethods = Object.freeze({
        max: 1,
        scroll: 1,
        bodyScroll: 1,
        documentElementScroll: 1
    }), settings = {}, timer = null, defaults = Object.freeze({
        autoResize: true,
        bodyBackground: null,
        bodyMargin: null,
        bodyMarginV1: 8,
        bodyPadding: null,
        checkOrigin: true,
        inPageLinks: false,
        enablePublicMethods: true,
        heightCalculationMethod: 'bodyOffset',
        id: 'iFrameResizer',
        interval: 32,
        license: '1jqr0si6pnt',
        log: false,
        maxHeight: Infinity,
        maxWidth: Infinity,
        minHeight: 0,
        minWidth: 0,
        mouseEvents: true,
        resizeFrom: 'parent',
        scrolling: false,
        sizeHeight: true,
        sizeWidth: false,
        warningTimeout: 5000,
        tolerance: 0,
        widthCalculationMethod: 'scroll',
        onClose: function() {
            return true;
        },
        onClosed: function() {},
        onInit: function() {},
        onMessage: function() {
            warn('onMessage function not defined');
        },
        onMouseEnter: function() {},
        onMouseLeave: function() {},
        onResized: function() {},
        onScroll: function() {
            return true;
        }
    });
    function getMutationObserver() {
        return window.MutationObserver || window.WebKitMutationObserver || window.MozMutationObserver;
    }
    function addEventListener(el, evt, func) {
        el.addEventListener(evt, func, false);
    }
    function removeEventListener(el, evt, func) {
        el.removeEventListener(evt, func, false);
    }
    function setupRequestAnimationFrame() {
        var vendors = [
            'moz',
            'webkit',
            'o',
            'ms'
        ];
        var x;
        // Remove vendor prefixing if prefixed and break early if not
        for(x = 0; x < vendors.length && !requestAnimationFrame; x += 1)requestAnimationFrame = window[vendors[x] + 'RequestAnimationFrame'];
        if (requestAnimationFrame) // Firefox extension content-scripts have a globalThis object that is not the same as window.
        // Binding `requestAnimationFrame` to window allows the function to work and prevents errors
        // being thrown when run in that context, and should be a no-op in every other context.
        requestAnimationFrame = requestAnimationFrame.bind(window);
        else log('setup', 'RequestAnimationFrame not supported');
    }
    function getMyID(iframeId) {
        var retStr = 'Host page: ' + iframeId;
        if (window.top !== window.self) retStr = window.parentIFrame && window.parentIFrame.getId ? window.parentIFrame.getId() + ': ' + iframeId : 'Nested host page: ' + iframeId;
        return retStr;
    }
    function formatLogHeader(iframeId) {
        return msgId + '[' + getMyID(iframeId) + ']';
    }
    function isLogEnabled(iframeId) {
        return settings[iframeId] ? settings[iframeId].log : logEnabled;
    }
    function log(iframeId, msg) {
        output('log', iframeId, msg, isLogEnabled(iframeId));
    }
    function info(iframeId, msg) {
        output('info', iframeId, msg, isLogEnabled(iframeId));
    }
    function warn(iframeId, msg) {
        output('warn', iframeId, msg, true);
    }
    function output(type, iframeId, msg, enabled) {
        if (true === enabled && 'object' === typeof window.console) // eslint-disable-next-line no-console
        console[type](formatLogHeader(iframeId), msg);
    }
    function iFrameListener(event) {
        function resizeIFrame() {
            function resize() {
                setSize(messageData);
                setPagePosition(iframeId);
                on('onResized', messageData);
            }
            ensureInRange('Height');
            ensureInRange('Width');
            syncResize(resize, messageData, 'init');
        }
        function processMsg() {
            var data = msg.slice(msgIdLen).split(':');
            var height = data[1] ? parseInt(data[1], 10) : 0;
            var iframe = settings[data[0]] && settings[data[0]].iframe;
            var compStyle = getComputedStyle(iframe);
            return {
                iframe: iframe,
                id: data[0],
                height: height + getPaddingEnds(compStyle) + getBorderEnds(compStyle),
                width: data[2],
                type: data[3]
            };
        }
        function getPaddingEnds(compStyle) {
            if (compStyle.boxSizing !== 'border-box') return 0;
            var top = compStyle.paddingTop ? parseInt(compStyle.paddingTop, 10) : 0;
            var bot = compStyle.paddingBottom ? parseInt(compStyle.paddingBottom, 10) : 0;
            return top + bot;
        }
        function getBorderEnds(compStyle) {
            if (compStyle.boxSizing !== 'border-box') return 0;
            var top = compStyle.borderTopWidth ? parseInt(compStyle.borderTopWidth, 10) : 0;
            var bot = compStyle.borderBottomWidth ? parseInt(compStyle.borderBottomWidth, 10) : 0;
            return top + bot;
        }
        function ensureInRange(Dimension) {
            var max = Number(settings[iframeId]['max' + Dimension]), min = Number(settings[iframeId]['min' + Dimension]), dimension = Dimension.toLowerCase(), size = Number(messageData[dimension]);
            log(iframeId, 'Checking ' + dimension + ' is in range ' + min + '-' + max);
            if (size < min) {
                size = min;
                log(iframeId, 'Set ' + dimension + ' to min value');
            }
            if (size > max) {
                size = max;
                log(iframeId, 'Set ' + dimension + ' to max value');
            }
            messageData[dimension] = '' + size;
        }
        function isMessageFromIFrame() {
            function checkAllowedOrigin() {
                function checkList() {
                    var i = 0, retCode = false;
                    log(iframeId, 'Checking connection is from allowed list of origins: ' + checkOrigin);
                    for(; i < checkOrigin.length; i++)if (checkOrigin[i] === origin) {
                        retCode = true;
                        break;
                    }
                    return retCode;
                }
                function checkSingle() {
                    var remoteHost = settings[iframeId] && settings[iframeId].remoteHost;
                    log(iframeId, 'Checking connection is from: ' + remoteHost);
                    return origin === remoteHost;
                }
                return checkOrigin.constructor === Array ? checkList() : checkSingle();
            }
            var origin = event.origin, checkOrigin = settings[iframeId] && settings[iframeId].checkOrigin;
            if (checkOrigin && '' + origin !== 'null' && !checkAllowedOrigin()) throw new Error('Unexpected message received from: ' + origin + ' for ' + messageData.iframe.id + '. Message was: ' + event.data + '. This error can be disabled by setting the checkOrigin: false option or by providing of array of trusted domains.');
            return true;
        }
        function isMessageForUs() {
            return msgId === ('' + msg).slice(0, msgIdLen) && msg.slice(msgIdLen).split(':')[0] in settings // ''+Protects against non-string msg
            ;
        }
        function isMessageFromMetaParent() {
            // Test if this message is from a parent above us. This is an ugly test, however, updating
            // the message format would break backwards compatibility.
            var retCode = messageData.type in {
                true: 1,
                false: 1,
                undefined: 1
            };
            if (retCode) log(iframeId, 'Ignoring init message from meta parent page');
            return retCode;
        }
        function getMsgBody(offset) {
            return msg.slice(msg.indexOf(':') + msgHeaderLen + offset);
        }
        function forwardMsgFromIFrame(msgBody) {
            log(iframeId, 'onMessage passed: {iframe: ' + messageData.iframe.id + ', message: ' + msgBody + '}');
            on('onMessage', {
                iframe: messageData.iframe,
                message: JSON.parse(msgBody)
            });
            log(iframeId, '--');
        }
        function getPageInfo() {
            var bodyPosition = document.body.getBoundingClientRect(), iFramePosition = messageData.iframe.getBoundingClientRect();
            return JSON.stringify({
                iframeHeight: iFramePosition.height,
                iframeWidth: iFramePosition.width,
                clientHeight: Math.max(document.documentElement.clientHeight, window.innerHeight || 0),
                clientWidth: Math.max(document.documentElement.clientWidth, window.innerWidth || 0),
                offsetTop: parseInt(iFramePosition.top - bodyPosition.top, 10),
                offsetLeft: parseInt(iFramePosition.left - bodyPosition.left, 10),
                scrollTop: window.pageYOffset,
                scrollLeft: window.pageXOffset,
                documentHeight: document.documentElement.clientHeight,
                documentWidth: document.documentElement.clientWidth,
                windowHeight: window.innerHeight,
                windowWidth: window.innerWidth
            });
        }
        function sendPageInfoToIframe(iframe, iframeId) {
            function debouncedTrigger() {
                trigger('Send Page Info', 'pageInfo:' + getPageInfo(), iframe, iframeId);
            }
            debounceFrameEvents(debouncedTrigger, 32, iframeId);
        }
        function startPageInfoMonitor() {
            function setListener(type, func) {
                function sendPageInfo() {
                    if (settings[id]) sendPageInfoToIframe(settings[id].iframe, id);
                    else stop();
                }
                [
                    'scroll',
                    'resize'
                ].forEach(function(evt) {
                    log(id, type + evt + ' listener for sendPageInfo');
                    func(window, evt, sendPageInfo);
                });
            }
            function stop() {
                setListener('Remove ', removeEventListener);
            }
            function start() {
                setListener('Add ', addEventListener);
            }
            var id = iframeId // Create locally scoped copy of iFrame ID
            ;
            start();
            if (settings[id]) settings[id].stopPageInfo = stop;
        }
        function stopPageInfoMonitor() {
            if (settings[iframeId] && settings[iframeId].stopPageInfo) {
                settings[iframeId].stopPageInfo();
                delete settings[iframeId].stopPageInfo;
            }
        }
        function checkIFrameExists() {
            var retBool = true;
            if (null === messageData.iframe) {
                warn(iframeId, 'IFrame (' + messageData.id + ') not found');
                retBool = false;
            }
            return retBool;
        }
        function getElementPosition(target) {
            var iFramePosition = target.getBoundingClientRect();
            getPagePosition(iframeId);
            return {
                x: Math.floor(Number(iFramePosition.left) + Number(pagePosition.x)),
                y: Math.floor(Number(iFramePosition.top) + Number(pagePosition.y))
            };
        }
        function scrollRequestFromChild(addOffset) {
            /* istanbul ignore next */ // Not testable in Karma
            function reposition() {
                pagePosition = newPosition;
                scrollTo();
                log(iframeId, '--');
            }
            function calcOffset() {
                return {
                    x: Number(messageData.width) + offset.x,
                    y: Number(messageData.height) + offset.y
                };
            }
            function scrollParent() {
                if (window.parentIFrame) window.parentIFrame['scrollTo' + (addOffset ? 'Offset' : '')](newPosition.x, newPosition.y);
                else warn(iframeId, 'Unable to scroll to requested position, window.parentIFrame not found');
            }
            var offset = addOffset ? getElementPosition(messageData.iframe) : {
                x: 0,
                y: 0
            }, newPosition = calcOffset();
            log(iframeId, 'Reposition requested from iFrame (offset x:' + offset.x + ' y:' + offset.y + ')');
            if (window.top === window.self) reposition();
            else scrollParent();
        }
        function scrollTo() {
            if (false === on('onScroll', pagePosition)) unsetPagePosition();
            else setPagePosition(iframeId);
        }
        function findTarget(location) {
            function jumpToTarget() {
                var jumpPosition = getElementPosition(target);
                log(iframeId, 'Moving to in page link (#' + hash + ') at x: ' + jumpPosition.x + ' y: ' + jumpPosition.y);
                pagePosition = {
                    x: jumpPosition.x,
                    y: jumpPosition.y
                };
                scrollTo();
                log(iframeId, '--');
            }
            function jumpToParent() {
                if (window.parentIFrame) window.parentIFrame.moveToAnchor(hash);
                else log(iframeId, 'In page link #' + hash + ' not found and window.parentIFrame not found');
            }
            var hash = location.split('#')[1] || '', hashData = decodeURIComponent(hash), target = document.getElementById(hashData) || document.getElementsByName(hashData)[0];
            if (target) jumpToTarget();
            else if (window.top === window.self) log(iframeId, 'In page link #' + hash + ' not found');
            else jumpToParent();
        }
        function onMouse(event) {
            var mousePos = {};
            if (Number(messageData.width) === 0 && Number(messageData.height) === 0) {
                var data = getMsgBody(9).split(':');
                mousePos = {
                    x: data[1],
                    y: data[0]
                };
            } else mousePos = {
                x: messageData.width,
                y: messageData.height
            };
            on(event, {
                iframe: messageData.iframe,
                screenX: Number(mousePos.x),
                screenY: Number(mousePos.y),
                type: messageData.type
            });
        }
        function on(funcName, val) {
            return chkEvent(iframeId, funcName, val);
        }
        function actionMsg() {
            if (settings[iframeId] && settings[iframeId].firstRun) firstRun();
            switch(messageData.type){
                case 'close':
                    closeIFrame(messageData.iframe);
                    break;
                case 'message':
                    forwardMsgFromIFrame(getMsgBody(6));
                    break;
                case 'mouseenter':
                    onMouse('onMouseEnter');
                    break;
                case 'mouseleave':
                    onMouse('onMouseLeave');
                    break;
                case 'autoResize':
                    settings[iframeId].autoResize = JSON.parse(getMsgBody(9));
                    break;
                case 'scrollTo':
                    scrollRequestFromChild(false);
                    break;
                case 'scrollToOffset':
                    scrollRequestFromChild(true);
                    break;
                case 'pageInfo':
                    sendPageInfoToIframe(settings[iframeId] && settings[iframeId].iframe, iframeId);
                    startPageInfoMonitor();
                    break;
                case 'pageInfoStop':
                    stopPageInfoMonitor();
                    break;
                case 'inPageLink':
                    findTarget(getMsgBody(9));
                    break;
                case 'reset':
                    resetIFrame(messageData);
                    break;
                case 'init':
                    resizeIFrame();
                    on('onInit', messageData.iframe);
                    break;
                default:
                    if (Number(messageData.width) === 0 && Number(messageData.height) === 0) warn('Unsupported message received (' + messageData.type + '), this is likely due to the iframe containing a later ' + 'version of iframe-resizer than the parent page');
                    else resizeIFrame();
            }
        }
        function hasSettings(iframeId) {
            var retBool = true;
            if (!settings[iframeId]) {
                retBool = false;
                warn(messageData.type + ' No settings for ' + iframeId + '. Message was: ' + msg);
            }
            return retBool;
        }
        function iFrameReadyMsgReceived() {
            // eslint-disable-next-line no-restricted-syntax, guard-for-in
            for(var iframeId in settings)trigger('iFrame requested init', createOutgoingMsg(iframeId), settings[iframeId].iframe, iframeId);
        }
        function firstRun() {
            if (settings[iframeId]) settings[iframeId].firstRun = false;
        }
        var msg = event.data, messageData = {}, iframeId = null;
        if ('[iFrameResizerChild]Ready' === msg) iFrameReadyMsgReceived();
        else if (isMessageForUs()) {
            messageData = processMsg();
            iframeId = messageData.id;
            if (settings[iframeId]) settings[iframeId].loaded = true;
            if (!isMessageFromMetaParent() && hasSettings(iframeId)) {
                log(iframeId, 'Received: ' + msg);
                if (checkIFrameExists() && isMessageFromIFrame()) actionMsg();
            }
        } else info(iframeId, 'Ignored: ' + msg);
    }
    function chkEvent(iframeId, funcName, val) {
        var func = null, retVal = null;
        if (settings[iframeId]) {
            func = settings[iframeId][funcName];
            if ('function' === typeof func) retVal = func(val);
            else throw new TypeError(funcName + ' on iFrame[' + iframeId + '] is not a function');
        }
        return retVal;
    }
    function removeIframeListeners(iframe) {
        var iframeId = iframe.id;
        delete settings[iframeId];
    }
    function closeIFrame(iframe) {
        var iframeId = iframe.id;
        if (chkEvent(iframeId, 'onClose', iframeId) === false) {
            log(iframeId, 'Close iframe cancelled by onClose event');
            return;
        }
        log(iframeId, 'Removing iFrame: ' + iframeId);
        try {
            // Catch race condition error with React
            if (iframe.parentNode) iframe.parentNode.removeChild(iframe);
        } catch (error) {
            warn(error);
        }
        chkEvent(iframeId, 'onClosed', iframeId);
        log(iframeId, '--');
        removeIframeListeners(iframe);
        if (destroyObserver) {
            destroyObserver.disconnect();
            destroyObserver = null;
        }
    }
    function getPagePosition(iframeId) {
        if (null === pagePosition) {
            pagePosition = {
                x: window.pageXOffset === undefined ? document.documentElement.scrollLeft : window.pageXOffset,
                y: window.pageYOffset === undefined ? document.documentElement.scrollTop : window.pageYOffset
            };
            log(iframeId, 'Get page position: ' + pagePosition.x + ',' + pagePosition.y);
        }
    }
    function setPagePosition(iframeId) {
        if (null !== pagePosition) {
            window.scrollTo(pagePosition.x, pagePosition.y);
            log(iframeId, 'Set page position: ' + pagePosition.x + ',' + pagePosition.y);
            unsetPagePosition();
        }
    }
    function unsetPagePosition() {
        pagePosition = null;
    }
    function resetIFrame(messageData) {
        function reset() {
            setSize(messageData);
            trigger('reset', 'reset', messageData.iframe, messageData.id);
        }
        log(messageData.id, 'Size reset requested by ' + ('init' === messageData.type ? 'host page' : 'iFrame'));
        getPagePosition(messageData.id);
        syncResize(reset, messageData, 'reset');
    }
    function setSize(messageData) {
        function setDimension(dimension) {
            if (!messageData.id) {
                log('undefined', 'messageData id not set');
                return;
            }
            messageData.iframe.style[dimension] = messageData[dimension] + 'px';
            log(messageData.id, 'IFrame (' + iframeId + ') ' + dimension + ' set to ' + messageData[dimension] + 'px');
        }
        function chkZero(dimension) {
            // FireFox sets dimension of hidden iFrames to zero.
            // So if we detect that set up an event to check for
            // when iFrame becomes visible.
            /* istanbul ignore next */ // Not testable in PhantomJS
            if (!hiddenCheckEnabled && '0' === messageData[dimension]) {
                hiddenCheckEnabled = true;
                log(iframeId, 'Hidden iFrame detected, creating visibility listener');
                fixHiddenIFrames();
            }
        }
        function processDimension(dimension) {
            setDimension(dimension);
            chkZero(dimension);
        }
        var iframeId = messageData.iframe.id;
        if (settings[iframeId]) {
            if (settings[iframeId].sizeHeight) processDimension('height');
            if (settings[iframeId].sizeWidth) processDimension('width');
        }
    }
    function syncResize(func, messageData, doNotSync) {
        /* istanbul ignore if */ // Not testable in PhantomJS
        if (doNotSync !== messageData.type && requestAnimationFrame && // including check for jasmine because had trouble getting spy to work in unit test using requestAnimationFrame
        !window.jasmine) {
            log(messageData.id, 'Requesting animation frame');
            requestAnimationFrame(func);
        } else func();
    }
    function trigger(calleeMsg, msg, iframe, id, noResponseWarning) {
        function postMessageToIFrame() {
            var target = settings[id] && settings[id].targetOrigin;
            log(id, '[' + calleeMsg + '] Sending msg to iframe[' + id + '] (' + msg + ') targetOrigin: ' + target);
            iframe.contentWindow.postMessage(msgId + msg, target);
        }
        function iFrameNotFound() {
            warn(id, '[' + calleeMsg + '] IFrame(' + id + ') not found');
        }
        function chkAndSend() {
            if (iframe && 'contentWindow' in iframe && null !== iframe.contentWindow) // Null test for PhantomJS
            postMessageToIFrame();
            else iFrameNotFound();
        }
        function warnOnNoResponse() {
            function warning() {
                if (settings[id] && !settings[id].loaded && !errorShown) {
                    errorShown = true;
                    warn(id, 'IFrame has not responded within ' + settings[id].warningTimeout / 1000 + ' seconds. Check iFrameResizer.contentWindow.js has been loaded in iFrame. This message can be ignored if everything is working, or you can set the warningTimeout option to a higher value or zero to suppress this warning.');
                }
            }
            if (!!noResponseWarning && settings[id] && !!settings[id].warningTimeout) settings[id].msgTimeout = setTimeout(warning, settings[id].warningTimeout);
        }
        var errorShown = false;
        id = id || iframe.id;
        if (settings[id]) {
            chkAndSend();
            warnOnNoResponse();
        }
    }
    function createOutgoingMsg(iframeId) {
        return iframeId + ':' + settings[iframeId].bodyMarginV1 + ':' + settings[iframeId].sizeWidth + ':' + settings[iframeId].log + ':' + settings[iframeId].interval + ':' + settings[iframeId].enablePublicMethods + ':' + settings[iframeId].autoResize + ':' + settings[iframeId].bodyMargin + ':' + settings[iframeId].heightCalculationMethod + ':' + settings[iframeId].bodyBackground + ':' + settings[iframeId].bodyPadding + ':' + settings[iframeId].tolerance + ':' + settings[iframeId].inPageLinks + ':' + settings[iframeId].resizeFrom + ':' + settings[iframeId].widthCalculationMethod + ':' + settings[iframeId].mouseEvents;
    }
    function isNumber(value) {
        return typeof value === 'number';
    }
    function setupIFrame(iframe, options) {
        function setLimits() {
            function addStyle(style) {
                var styleValue = settings[iframeId][style];
                if (Infinity !== styleValue && 0 !== styleValue) {
                    iframe.style[style] = isNumber(styleValue) ? styleValue + 'px' : styleValue;
                    log(iframeId, 'Set ' + style + ' = ' + iframe.style[style]);
                }
            }
            function chkMinMax(dimension) {
                if (settings[iframeId]['min' + dimension] > settings[iframeId]['max' + dimension]) throw new Error('Value for min' + dimension + ' can not be greater than max' + dimension);
            }
            chkMinMax('Height');
            chkMinMax('Width');
            addStyle('maxHeight');
            addStyle('minHeight');
            addStyle('maxWidth');
            addStyle('minWidth');
        }
        function newId() {
            var id = options && options.id || defaults.id + count++;
            if (null !== document.getElementById(id)) id += count++;
            return id;
        }
        function ensureHasId(iframeId) {
            if (typeof iframeId !== 'string') throw new TypeError('Invaild id for iFrame. Expected String');
            if ('' === iframeId) {
                // eslint-disable-next-line no-multi-assign
                iframe.id = iframeId = newId();
                logEnabled = (options || {}).log;
                log(iframeId, 'Added missing iframe ID: ' + iframeId + ' (' + iframe.src + ')');
            }
            return iframeId;
        }
        function setScrolling() {
            log(iframeId, 'IFrame scrolling ' + (settings[iframeId] && settings[iframeId].scrolling ? 'enabled' : 'disabled') + ' for ' + iframeId);
            iframe.style.overflow = false === (settings[iframeId] && settings[iframeId].scrolling) ? 'hidden' : 'auto';
            switch(settings[iframeId] && settings[iframeId].scrolling){
                case 'omit':
                    break;
                case true:
                    iframe.scrolling = 'yes';
                    break;
                case false:
                    iframe.scrolling = 'no';
                    break;
                default:
                    iframe.scrolling = settings[iframeId] ? settings[iframeId].scrolling : 'no';
            }
        }
        // The V1 iFrame script expects an int, where as in V2 expects a CSS
        // string value such as '1px 3em', so if we have an int for V2, set V1=V2
        // and then convert V2 to a string PX value.
        function setupBodyMarginValues() {
            if ('number' === typeof (settings[iframeId] && settings[iframeId].bodyMargin) || '0' === (settings[iframeId] && settings[iframeId].bodyMargin)) {
                settings[iframeId].bodyMarginV1 = settings[iframeId].bodyMargin;
                settings[iframeId].bodyMargin = '' + settings[iframeId].bodyMargin + 'px';
            }
        }
        function checkReset() {
            // Reduce scope of firstRun to function, because IE8's JS execution
            // context stack is borked and this value gets externally
            // changed midway through running this function!!!
            var firstRun = settings[iframeId] && settings[iframeId].firstRun, resetRequertMethod = settings[iframeId] && settings[iframeId].heightCalculationMethod in resetRequiredMethods;
            if (!firstRun && resetRequertMethod) resetIFrame({
                iframe: iframe,
                height: 0,
                width: 0,
                type: 'init'
            });
        }
        function setupIFrameObject() {
            if (settings[iframeId]) settings[iframeId].iframe.iFrameResizer = {
                close: closeIFrame.bind(null, settings[iframeId].iframe),
                removeListeners: removeIframeListeners.bind(null, settings[iframeId].iframe),
                resize: trigger.bind(null, 'Window resize', 'resize', settings[iframeId].iframe),
                moveToAnchor: function(anchor) {
                    trigger('Move to anchor', 'moveToAnchor:' + anchor, settings[iframeId].iframe, iframeId);
                },
                sendMessage: function(message) {
                    message = JSON.stringify(message);
                    trigger('Send Message', 'message:' + message, settings[iframeId].iframe, iframeId);
                }
            };
        }
        // We have to call trigger twice, as we can not be sure if all
        // iframes have completed loading when this code runs. The
        // event listener also catches the page changing in the iFrame.
        function init(msg) {
            function iFrameLoaded() {
                trigger('iFrame.onload', msg, iframe, undefined, true);
                checkReset();
            }
            function createDestroyObserver(MutationObserver) {
                if (!iframe.parentNode) return null;
                var destroyObserver = new MutationObserver(function(mutations) {
                    mutations.forEach(function(mutation) {
                        var removedNodes = Array.prototype.slice.call(mutation.removedNodes) // Transform NodeList into an Array
                        ;
                        removedNodes.forEach(function(removedNode) {
                            if (removedNode === iframe) closeIFrame(iframe);
                        });
                    });
                });
                destroyObserver.observe(iframe.parentNode, {
                    childList: true
                });
                return destroyObserver;
            }
            var MutationObserver = getMutationObserver();
            if (MutationObserver) destroyObserver = createDestroyObserver(MutationObserver);
            addEventListener(iframe, 'load', iFrameLoaded);
            trigger('init', msg, iframe, undefined, true);
        }
        function checkOptions(options) {
            if ('object' !== typeof options) throw new TypeError('Options is not an object');
        }
        function copyOptions(options) {
            // eslint-disable-next-line no-restricted-syntax
            for(var option in defaults)if (Object.prototype.hasOwnProperty.call(defaults, option)) settings[iframeId][option] = Object.prototype.hasOwnProperty.call(options, option) ? options[option] : defaults[option];
        }
        function getTargetOrigin(remoteHost) {
            return '' === remoteHost || null !== remoteHost.match(/^(about:blank|javascript:|file:\/\/)/) ? '*' : remoteHost;
        }
        function depricate(key) {
            var splitName = key.split('Callback');
            if (splitName.length === 2) {
                var name = 'on' + splitName[0].charAt(0).toUpperCase() + splitName[0].slice(1);
                this[name] = this[key];
                delete this[key];
                warn(iframeId, "Deprecated: '" + key + "' has been renamed '" + name + "'. The old method will be removed in the next major version.");
            }
        }
        function processOptions(options) {
            options = options || {};
            settings[iframeId] = Object.create(null) // Protect against prototype attacks
            ;
            settings[iframeId].iframe = iframe;
            settings[iframeId].firstRun = true;
            settings[iframeId].remoteHost = iframe.src && iframe.src.split('/').slice(0, 3).join('/');
            checkOptions(options);
            Object.keys(options).forEach(depricate, options);
            copyOptions(options);
            if (settings[iframeId]) settings[iframeId].targetOrigin = true === settings[iframeId].checkOrigin ? getTargetOrigin(settings[iframeId].remoteHost) : '*';
        }
        function beenHere() {
            return iframeId in settings && 'iFrameResizer' in iframe;
        }
        var iframeId = ensureHasId(iframe.id);
        if (beenHere()) warn(iframeId, 'Ignored iFrame, already setup.');
        else {
            processOptions(options);
            setScrolling();
            setLimits();
            setupBodyMarginValues();
            init(createOutgoingMsg(iframeId));
            setupIFrameObject();
        }
    }
    function debouce(fn, time) {
        if (null === timer) timer = setTimeout(function() {
            timer = null;
            fn();
        }, time);
    }
    var frameTimer = {};
    function debounceFrameEvents(fn, time, frameId) {
        if (!frameTimer[frameId]) frameTimer[frameId] = setTimeout(function() {
            frameTimer[frameId] = null;
            fn();
        }, time);
    }
    // Not testable in PhantomJS
    /* istanbul ignore next */ function fixHiddenIFrames() {
        function checkIFrames() {
            function checkIFrame(settingId) {
                function chkDimension(dimension) {
                    return '0px' === (settings[settingId] && settings[settingId].iframe.style[dimension]);
                }
                function isVisible(el) {
                    return null !== el.offsetParent;
                }
                if (settings[settingId] && isVisible(settings[settingId].iframe) && (chkDimension('height') || chkDimension('width'))) trigger('Visibility change', 'resize', settings[settingId].iframe, settingId);
            }
            Object.keys(settings).forEach(function(key) {
                checkIFrame(key);
            });
        }
        function mutationObserved(mutations) {
            log('window', 'Mutation observed: ' + mutations[0].target + ' ' + mutations[0].type);
            debouce(checkIFrames, 16);
        }
        function createMutationObserver() {
            var target = document.querySelector('body'), config = {
                attributes: true,
                attributeOldValue: false,
                characterData: true,
                characterDataOldValue: false,
                childList: true,
                subtree: true
            }, observer = new MutationObserver(mutationObserved);
            observer.observe(target, config);
        }
        var MutationObserver = getMutationObserver();
        if (MutationObserver) createMutationObserver();
    }
    function resizeIFrames(event) {
        function resize() {
            sendTriggerMsg('Window ' + event, 'resize');
        }
        log('window', 'Trigger event: ' + event);
        debouce(resize, 16);
    }
    // Not testable in PhantomJS
    /* istanbul ignore next */ function tabVisible() {
        function resize() {
            sendTriggerMsg('Tab Visible', 'resize');
        }
        if ('hidden' !== document.visibilityState) {
            log('document', 'Trigger event: Visibility change');
            debouce(resize, 16);
        }
    }
    function sendTriggerMsg(eventName, event) {
        function isIFrameResizeEnabled(iframeId) {
            return settings[iframeId] && 'parent' === settings[iframeId].resizeFrom && settings[iframeId].autoResize && !settings[iframeId].firstRun;
        }
        Object.keys(settings).forEach(function(iframeId) {
            if (isIFrameResizeEnabled(iframeId)) trigger(eventName, event, settings[iframeId].iframe, iframeId);
        });
    }
    function setupEventListeners() {
        addEventListener(window, 'message', iFrameListener);
        addEventListener(window, 'resize', function() {
            resizeIFrames('resize');
        });
        addEventListener(document, 'visibilitychange', tabVisible);
        addEventListener(document, '-webkit-visibilitychange', tabVisible);
    }
    function factory() {
        function init(options, element) {
            function chkType() {
                if (!element.tagName) throw new TypeError('Object is not a valid DOM element');
                else if ('IFRAME' !== element.tagName.toUpperCase()) throw new TypeError('Expected <IFRAME> tag, found <' + element.tagName + '>');
            }
            if (element) {
                chkType();
                setupIFrame(element, options);
                iFrames.push(element);
            }
        }
        function warnDeprecatedOptions(options) {
            if (options && options.enablePublicMethods) warn('enablePublicMethods option has been removed, public methods are now always available in the iFrame');
        }
        var iFrames;
        setupRequestAnimationFrame();
        setupEventListeners();
        return function iFrameResizeF(options, target) {
            iFrames = [] // Only return iFrames past in on this call
            ;
            warnDeprecatedOptions(options);
            switch(typeof target){
                case 'undefined':
                case 'string':
                    Array.prototype.forEach.call(document.querySelectorAll(target || 'iframe'), init.bind(undefined, options));
                    break;
                case 'object':
                    init(options, target);
                    break;
                default:
                    throw new TypeError('Unexpected data type (' + typeof target + ')');
            }
            return iFrames;
        };
    }
    function createJQueryPublicMethod($) {
        if (!$.fn) info('', 'Unable to bind to jQuery, it is not fully loaded.');
        else if (!$.fn.iFrameResize) $.fn.iFrameResize = function $iFrameResizeF(options) {
            function init(index, element) {
                setupIFrame(element, options);
            }
            return this.filter('iframe').each(init).end();
        };
    }
    if (window.jQuery !== undefined) createJQueryPublicMethod(window.jQuery);
    if (typeof define === 'function' && define.amd) define([], factory);
    else if (typeof $ef5e88eaa61efd95$exports === 'object') // Node for browserfy
    $ef5e88eaa61efd95$exports = factory();
    window.iFrameResize = window.iFrameResize || factory();
})();


function $c299e36fa9e271bc$export$2e2bcd8739ae039(id, embedStore) {
    if (!embedStore[id]) embedStore[id] = {
        width: "100%",
        height: "100%"
    };
    return {
        iframe: null,
        viewportHeight: 0,
        targetPath: window.location.pathname,
        get viewportCssHeight () {
            return this.viewportHeight ? `${this.viewportHeight}px` : "100%";
        },
        get store () {
            return embedStore[id];
        },
        init () {
            const onResized = this.onResized.bind(this);
            this.iframe = this.$el.querySelector("iframe");
            window.iFrameResize({
                onResized: onResized,
                checkOrigin: false
            }, this.iframe);
            this.$watch("targetPath", (value)=>this.switchTarget(value));
        },
        switchTarget (newTargetPath) {
            this.navigateTo(`${newTargetPath}${window.location.search}`);
        },
        onResized ({ height: height }) {
            if (height) {
                this.viewportHeight = height;
                // Notify parent window of height resize so the parent window can implement
                // its own iframe resize strategy if not using the Lookbook JS script.
                // Uses Embedly-compatible postMessage format: https://docs.embed.ly/reference/provider-height-resizing
                window.parent.postMessage(JSON.stringify({
                    src: window.location.toString(),
                    context: "iframe.resize",
                    height: height
                }), "*");
            }
        },
        resizeIframe () {
            this.iframe.iFrameResizer.resize();
        }
    };
}


var $1a7a7298eec5b755$exports = {};

$parcel$defineInteropFlag($1a7a7298eec5b755$exports);

$parcel$export($1a7a7298eec5b755$exports, "default", () => $1a7a7298eec5b755$export$2e2bcd8739ae039);

function $1a7a7298eec5b755$export$2e2bcd8739ae039() {
    return {
        narrow: false,
        init () {
            (0, $7ecd1fc3a6b35e5c$export$a2214cc2adb2dc44)(this.$el, ({ width: width })=>{
                this.narrow = width < 500;
            });
        }
    };
}


var $e773f8ef556b41ff$exports = {};

$parcel$defineInteropFlag($e773f8ef556b41ff$exports);

$parcel$export($e773f8ef556b41ff$exports, "default", () => $e773f8ef556b41ff$export$2e2bcd8739ae039);
function $e773f8ef556b41ff$export$2e2bcd8739ae039() {
    return {
        get isNarrowLayout () {
            return this.narrow || false;
        }
    };
}


var $9b24cbeb3a465447$exports = {};

$parcel$defineInteropFlag($9b24cbeb3a465447$exports);

$parcel$export($9b24cbeb3a465447$exports, "default", () => $9b24cbeb3a465447$export$2e2bcd8739ae039);
function $9b24cbeb3a465447$export$2e2bcd8739ae039({ id: id, matchers: matchers }) {
    matchers = matchers.map((matcher)=>matcher.replace(/\s/g, "").toLowerCase());
    return {
        filteredOut: false,
        active: false,
        get open () {
            return this.isCollection && this.isOpen(id);
        },
        get children () {
            return this.$refs.items ? Array.from(this.$refs.items.children) : [];
        },
        get isCollection () {
            return !this.$refs.link;
        },
        checkActive () {
            this.active = this.$refs.link && window.location.pathname === this.$refs.link.getAttribute("href");
        },
        toggle () {
            this.toggleOpen(id);
        },
        async filter (text) {
            if (this.isCollection) {
                this.filteredOut = true;
                this.children.forEach(async (child)=>{
                    const data = Alpine.$data(child);
                    await data.filter(text);
                    if (!data.filteredOut) this.filteredOut = false;
                });
            } else this.filteredOut = !this.match(text);
            return this;
        },
        match (text) {
            if (text.length) {
                const matched = (matchers || []).map((m)=>m.includes(text));
                return matched.filter((m)=>m).length;
            }
            return true;
        },
        bindings: {
            toggle: {
                ["x-on:click.stop"]: "toggle",
                ["x-ref"]: "toggle"
            },
            link: {
                [":class"]: "{'!bg-lookbook-nav-item-active':active}",
                ["x-ref"]: "link"
            }
        }
    };
}


$5d1c9207cb730903$exports = {
    "display_options": {
        "field": $6a9b69d9cc7f810f$exports
    },
    "embed": {
        "inspector": $c299e36fa9e271bc$exports
    },
    "params": {
        "editor": $1a7a7298eec5b755$exports,
        "field": $e773f8ef556b41ff$exports
    },
    "nav": {
        "item": $9b24cbeb3a465447$exports
    }
};


var $d56e5cced44001d2$exports = {};

var $f13f118be065081c$exports = {};

$parcel$defineInteropFlag($f13f118be065081c$exports);

$parcel$export($f13f118be065081c$exports, "default", () => $f13f118be065081c$export$2e2bcd8739ae039);
function $f13f118be065081c$export$2e2bcd8739ae039({ name: name, value: value }) {
    return {
        name: name,
        value: value,
        init () {
            this.$watch("value", ()=>this.update());
        },
        update () {
            if (this.validate()) {
                const searchParams = new URLSearchParams(window.location.search);
                searchParams.set(this.name, this.value);
                const path = location.href.replace(location.search, "");
                this.navigateTo(`${path}?${searchParams.toString()}`);
            }
        },
        validate () {
            return this.$root.reportValidity ? this.$root.reportValidity() : true;
        }
    };
}



$d56e5cced44001d2$exports = {
    "clipboard": $4e31c85e11272811$exports,
    "params_input": $f13f118be065081c$exports,
    "tooltip": $7a759511c361f2bd$exports
};


// Plugins
(0, $caa9439642c6336c$export$2e2bcd8739ae039).plugin((0, $512e3a9270ec7803$export$2e2bcd8739ae039));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).plugin((0, $a5acee56471cec18$export$2e2bcd8739ae039));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).plugin((0, $512e3a9270ec7803$export$2e2bcd8739ae039));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).plugin((0, $69a8ec8dbeef3157$export$2e2bcd8739ae039));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).plugin((0, $227a3c1b2ea887ad$export$2e2bcd8739ae039));
// Stores
const $22969b543678f572$var$prefix = window.APP_NAME;
(0, $caa9439642c6336c$export$2e2bcd8739ae039).store("layout", (0, $b8cbee737d5fb22b$export$2e2bcd8739ae039)((0, $caa9439642c6336c$export$2e2bcd8739ae039), {
    prefix: $22969b543678f572$var$prefix
}));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).store("nav", (0, $44e1c947423754b0$export$2e2bcd8739ae039)((0, $caa9439642c6336c$export$2e2bcd8739ae039), {
    prefix: $22969b543678f572$var$prefix
}));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).store("inspector", (0, $9c7d83377882e3b9$export$2e2bcd8739ae039)((0, $caa9439642c6336c$export$2e2bcd8739ae039), {
    prefix: $22969b543678f572$var$prefix
}));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).store("pages", (0, $1fa236e81ee747be$export$2e2bcd8739ae039)((0, $caa9439642c6336c$export$2e2bcd8739ae039), {
    prefix: $22969b543678f572$var$prefix
}));
(0, $caa9439642c6336c$export$2e2bcd8739ae039).store("settings", (0, $d56ec5b1270324e7$export$2e2bcd8739ae039)((0, $caa9439642c6336c$export$2e2bcd8739ae039), {
    prefix: $22969b543678f572$var$prefix
}));
// Components
(0, $caa9439642c6336c$export$2e2bcd8739ae039).data("app", (0, $5792afa4170ed552$export$2e2bcd8739ae039));
[
    $88dfd91701b4cd8b$exports,
    $5d1c9207cb730903$exports,
    $d56e5cced44001d2$exports
].forEach((scripts)=>{
    const components = (0, $12b7aa006b8a97e1$export$4e811121b221213b)(scripts);
    Object.keys(components).forEach((name)=>{
        (0, $caa9439642c6336c$export$2e2bcd8739ae039).data(`${name}Component`, components[name]);
    });
});
// Init
window.log = (0, (/*@__PURE__*/$parcel$interopDefault($5267f0d63de538ba$exports)));
window.Alpine = (0, $caa9439642c6336c$export$2e2bcd8739ae039);
(0, $caa9439642c6336c$export$2e2bcd8739ae039).start();

})();
//# sourceMappingURL=index.js.map
