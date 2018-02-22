(function($) {

var methodMap = {
  'create': 'POST',
  'update': 'PUT',
  'patch':  'PATCH',
  'delete': 'DELETE',
  'read':   'GET'
};

var getUrl = function(object) {
  if (!(object && object.url)) return null;
  return _.isFunction(object.url) ? object.url() : object.url;
};

// Throw an error when a URL is needed, and none is supplied.
var urlError = function() {
  throw new Error('A "url" property or function must be specified');
};

// Override this function to change the manner in which Backbone persists
// models to the server. You will be passed the type of request, and the
// model in question. By default, makes a RESTful Ajax request
// to the model's `url()`. Some possible customizations could be:
//
// * Use `setTimeout` to batch rapid-fire updates into a single request.
// * Send up the models as XML instead of JSON.
// * Persist models via WebSockets instead of Ajax.
//
// Turn on `Backbone.emulateHTTP` in order to send `PUT` and `DELETE` requests
// as `POST`, with a `_method` parameter containing the true HTTP method,
// as well as all requests with the body as `application/x-www-form-urlencoded`
// instead of `application/json` with the model in a param named `model`.
// Useful when interfacing with server-side languages like **PHP** that make
// it difficult to read the body of `PUT` requests.
Backbone.sync = function(method, model, options) {
  var type = methodMap[method];

  // Default options, unless specified.
  _.defaults(options || (options = {}), {
    emulateHTTP: Backbone.emulateHTTP,
    emulateJSON: Backbone.emulateJSON
  });

  // Default JSON-request options.
  var params = { type: type, dataType: 'json' };

  // Ensure that we have a URL.
  if (!options.url) {
    params.url = getUrl(model) || urlError();
  }

  // Ensure that we have the appropriate request data.
  if (options.data == null && model && (method === 'create' || method === 'update' || method === 'patch')) {
    params.contentType = 'application/json';

    var data = {};
    var attrs = options.attrs || model.toJSON(options);
    if (model.paramRoot) {
      data[model.paramRoot] = attrs;
    } else {
      data = attrs;
    }

    params.data = JSON.stringify(data);
  }

  // For older servers, emulate JSON by encoding the request into an HTML-form.
  if (options.emulateJSON) {
    params.contentType = 'application/x-www-form-urlencoded';
    params.data = params.data ? {model: params.data} : {};
  }

  // For older servers, emulate HTTP by mimicking the HTTP method with `_method`
  // And an `X-HTTP-Method-Override` header.
  if (options.emulateHTTP && (type === 'PUT' || type === 'DELETE' || type === 'PATCH')) {
    params.type = 'POST';
    if (options.emulateJSON) params.data._method = type;
    var beforeSend = options.beforeSend;
    options.beforeSend = function(xhr) {
      xhr.setRequestHeader('X-HTTP-Method-Override', type);
      if (beforeSend) return beforeSend.apply(this, arguments);
    };
  }

  // Don't process data on a non-GET request.
  if (params.type !== 'GET' && !options.emulateJSON) {
    params.processData = false;
  }

  // If we're sending a `PATCH` request, and we're in an old Internet Explorer
  // that still has ActiveX enabled by default, override jQuery to use that
  // for XHR instead. Remove this line when jQuery supports `PATCH` on IE8.
  if (params.type === 'PATCH' && noXhrPatch) {
    params.xhr = function() {
      return new ActiveXObject("Microsoft.XMLHTTP");
    };
  }

  // Set Rails csrf-token.
  options.beforeSend = _.wrap(options.beforeSend, function(func, xhr) {
    if (!options.noCSRF) {
      var token = $('meta[name="csrf-token"]').attr('content');
      if (token) {
        xhr.setRequestHeader('X-CSRF-Token', token);  
      }
    }
    if (func) {
      return func(this, xhr);
    }
  });

  // Make the request, allowing the user to override any Ajax options.
  var xhr = options.xhr = Backbone.ajax(_.extend(params, options));
  model.trigger('request', model, xhr, options);
  return xhr;
};

})(Backbone.$);

