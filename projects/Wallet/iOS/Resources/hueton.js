class Dispatcher {
    
    constructor() {
        this.promises = {};
    }
    
    async run(name, parameters) {
        if (!name || !parameters) {
            return;
        }
        
        const handler = window.webkit.messageHandlers[name];
        if (!handler) {
            const error = this.error(4200, "The Provider does not support the requested method.");
            return Promise.reject(error);
        }
        
        const id = `${Math.random().toString(36).slice(2, 7)}-${Math.random().toString(36).slice(2, 7)}`;
        const promise = new Promise((resolve, reject) => {
            this.promises[id] = { resolve, reject };
        });
        
        handler.postMessage({
            id,
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
            const error = this.error(detail.error.code, detail.error.message);
            promise.reject(error);
        } else if (detail.result) {
            const decoded = JSON.parse(atob(detail.result));
            if (decoded) {
                promise.resolve(decoded);
            } else {
                const error = this.error(0, "The undefined error.");
                promise.reject(error);
            }
        } else {
            const error = this.error(0, "The undefined error.");
            promise.reject(error);
        }
    }
    
    error(code, message) {
        const error = new Error(message);
        error.code = code;
        return error
    }
}

class HUETON {
    
    constructor() {
        this.dispatcher = new Dispatcher();
    }
    
    async authenticate() {
        let result = await this.dispatcher.run("authenticate", {
            value: "test"
        });
        return result;
    };
}

const hueton = new HUETON();

window.ton = hueton;
window.addEventListener("HUETON3ER", function (event) {
    hueton.dispatcher.process(event);
});
