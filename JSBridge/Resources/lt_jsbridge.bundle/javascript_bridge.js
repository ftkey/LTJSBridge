(function() {
  if (!window.JSB) { (function() {
      var responseCallbacks = {};
      var uniqueId = 1;

      function inject(modules) {
        Object.keys(modules).forEach(function(moduleName, index, moduleNames) { (function(moduleName, methods) {
            window[moduleName] = {};
            var jsObj = window[moduleName];
            methods.forEach(function(methodName) {
              var jsMethod = methodName.split(":")[0];
              jsObj[jsMethod] = function() {
                var finalArgs = Array.prototype.slice.call(arguments).map(function(argument) {
                  return normalize(argument);
                });
                window.webkit.messageHandlers.JSB.postMessage({
                  module: moduleName,
                  method: methodName,
                  args: finalArgs
                });
              }
            });
          })(moduleName, modules[moduleName]);
        });
      }

      function normalize(v) {
        var type = typof(v);
        switch (type) {
        case 'undefined':
        case 'null':
          return ''
        case 'regexp':
          return v.toString()
        case 'date':
          return v.toISOString()
        case 'number':
        case 'string':
        case 'boolean':
        case 'array':
        case 'object':
          return v
        case 'function':
          var callbackId = 'jsb_' + (uniqueId++) + '_' + new Date().getTime();
          responseCallbacks[callbackId] = v;
          return callbackId.toString();
        default:
          return JSON.stringify(v);
        }
      }

      function typof(v) {
        var s = Object.prototype.toString.call(v);
        return s.substring(8, s.length - 1).toLowerCase();
      }

      function _dispatchMessageFromNative(messageJSON) {
        setTimeout(function _timeoutDispatchMessageFromObjC() {
          var message = JSON.parse(messageJSON);
          var responseCallback;
          if (message.callbackId) {
            responseCallback = responseCallbacks[message.callbackId];
            if (!responseCallback) {
              return;
            }
            responseCallback(message.jsFunctionArgsData);
            delete responseCallbacks[message.callbackId];
          }
        })
      }

      function handleMessageFromNative(messageJSON) {
        _dispatchMessageFromNative(messageJSON);
      }

      window.JSB = {
        inject: inject,
        handleMessageFromNative: handleMessageFromNative
      };
    })()
  }
})()
