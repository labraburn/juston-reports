// HUETON
// https://github.com/ethereum/EIPs/blob/master/EIPS/eip-1193.md#sample-class-implementation

class Errors extends Error {

    constructor(code, message) {
        super(message);
        this.code = code;
    }

    /* EIP-1193 */

    /* Other */

    static undefined() {
        return new Errors(5001, "The undefined error.");
    }

    static invalidMethodName() {
        return new Errors(5002, "Method is not a valid string.");
    }

    static invalidParameters() {
        return new Errors(5002, "Params is not a valid array.");
    }
}

class Dispatcher {

    constructor() {
        this.promises = {};
    }

    async run(name, parameters) {
        if (!name || !parameters) {
            return;
        }

        let handler = window.webkit.messageHandlers[name];
        if (!handler) {
            handler = window.webkit.messageHandlers._undefined;
        }

        const id = `${Math.random().toString(36).slice(2, 7)}-${Math.random().toString(36).slice(2, 7)}`;
        const promise = new Promise((resolve, reject) => {
            this.promises[id] = { resolve, reject };
        });

        handler.postMessage({
            id,
            method: name,
            request: btoa(JSON.stringify(parameters))
        });

        return promise;
    }

    process(event) {
        const detail = event.detail;
        if (!detail.id) {
            return;
        }

        const promise = this.promises[detail.id];
        if (!promise) {
            return;
        }

        if (detail.error) {
            promise.reject(new Errors(detail.error.code, detail.error.message));
        } else if (detail.result) {
            const decoded = JSON.parse(atob(detail.result));
            if (decoded) {
                promise.resolve(decoded);
            } else {
                promise.reject(Errors.undefined());
            }
        } else {
            promise.reject(Errors.undefined());
        }
    }
}

class Provider {

    constructor() {
        this.dispatcher = new Dispatcher();
        this.listeners = {};

        this.type = "HUETON";

        this.isTonWallet = true;
        this.isHUETON = true;
    }

    on(method, listener) {
        let methodListeners = this.listeners[method];
        if (!methodListeners) {
            methodListeners = [];
            this.listeners[method] = methodListeners;
        }
        if (methodListeners.indexOf(listener) === -1) {
            methodListeners.push(listener);
        }
        return this;
    }

    removeListener(method, listener) {
        const methodListeners = this.listeners[method];
        if (!methodListeners) return;
        const index = methodListeners.indexOf(listener);
        if (index > -1) {
            methodListeners.splice(index, 1);
        }
    }

    emit(method, ...args) {
        const methodListeners = this.listeners[method];
        if (!methodListeners || !methodListeners.length) return false;
        methodListeners.forEach(listener => listener(...args));
        return true;
    }

    /* Methods */

    send(method, parameters = []) {
        if (!method || typeof method !== 'string') {
            return Promise.error(Errors.invalidMethodName());
        }

        if (!(parameters instanceof Array)) {
            return Promise.error(Errors.invalidParameters());
        }

        // TODO: Handle all array parameters, btw wtf
        let converted = {};
        if (parameters.length > 0) {
            const first = parameters[0];
            if (parameters instanceof Object) {
                converted = first;
            } else {
                converted = { first };
            }
        }

        const promise = this.dispatcher.run(method, converted);
        return promise;
    }

    /* Internal */

    _emit(event) {
        const detail = event.detail;
        if (!detail.name || !detail.body) {
            return;
        }

        const decoded = JSON.parse(atob(detail.body));
        if (!decoded) {
            return;
        }

        this.emit(detail.name, ...decoded);
    }
}

const provider = new Provider();

window.ton = provider;
window.tonProtocolVersion = 1;

window.hueton = provider;

window.addEventListener("WKWeb3EventResponse", function(event) {
    window.ton.dispatcher.process(event);
});

window.addEventListener("WKWeb3EventEmit", function(event) {
    window.ton._emit(event);
});
