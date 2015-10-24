var lists = require('./words').get();
var _ = require('lodash');
var filters = require('./filters');

var whimsy = module.exports = function(phrase, num) {
  num = num || 1;
  var replacements = _.map(_.range(num), function() {
    return phrase.replace(/\{\{\s*(.*?)\s*\}\}/g, whimsy.interpolate);
  });

  if (replacements.length === 1) {
    return replacements[0];
  } else {
    return replacements;
  }
};

whimsy.interpolate = function(original, match) {
  var context = {
    match: match.trim()
  };
  var appliedFilters = whimsy.makeFilters(context);
  var preFilters = _.filter(appliedFilters, whimsy.getFilters(filters.preFilters));
  var postFilters = _.filter(appliedFilters, whimsy.getFilters(filters.postFilters));
  var word = filters._refs[ context.match ] || whimsy.generate(context.match.trim(), preFilters);
  return whimsy.applyFilters(word, postFilters);
};

whimsy.makeFilters = function(context) {
  var parts = context.match.split('|');
  var filters = parts.slice(1);
  context.match = parts[0].trim();
  return _(filters).map(_.trim).map(whimsy.parse).value();
};

whimsy.getFilters = function(list) {
  return function(f) {
    return list.indexOf(f.name) > -1;
  };
};

whimsy.parse = function(filter) {
  var invocation = filter.split('(');
  var func = {
    name: invocation[0],
    params: []
  };

  if (invocation[1]) {
    var rawArgs = invocation[1].split(')')[0];
    var regex = /(\[(.*?)\])|(\{(.*?)\})|("(.*?)")|(\d+)/g; 
    var match;
    while((match = regex.exec(rawArgs)) !== null) {
      if (match[1] || match[3]) {
        func.params.push(JSON.parse(match[1] || match[3]));
      } else if (match[7]) {
        func.params.push(Number(match[7]));
      } else {
        func.params.push(match[6]);
      }
    }
  }

  if (typeof filters[ func.name ] !== 'function') {
    func.name = 'noop';
  }

  return func;
};

whimsy.applyFilters = function(word, postFilters) {
  return _.reduce(postFilters, whimsy.invokeFilter, word);
};

whimsy.invokeFilter = function(current, filter) {
  var params = _.clone(filter.params);
  params.push(current);
  return filters[ filter.name ].apply(filter, params);
};

whimsy.concat = function(part, type) {
  return part + (type ? '.' + type : '');
};

whimsy.generate = function(path, options, preFilters) {
  if (_.isArray(options)) {
    preFilters = options;
    options = {};
  }

  options = options || {};
  options.count = options.count || 1;

  var list = _.clone(_.get(lists, path));
  if (_.isPlainObject(list)) {
    list = _(list).values().flatten().value();
  }
  list = _.reduce(preFilters, whimsy.invokeFilter, _.uniq(list));
  var items =  _.reduce(_.range(options.count), function(memo, num) {
    memo.push(whimsy.get(list));
    return memo;
  }, []);

  if (items.length > 1) {
    return items;
  } else {
    return items[0];
  }
};

whimsy.get = function(list) {
  return list[ _.random(list.length - 1) ];
};

whimsy.register = function(name, filter, before) {
  filters[ name ] = filter;
  (before ? filters.preFilters : filters.postFilters).push(name);
};

_.each(lists, function(val, key) {
  if (_.isPlainObject(val)) {
    whimsy[key] = function(type, opts) {
      if (typeof type === 'string') {
        return whimsy.generate(whimsy.concat(key, type), opts || {});
      } else {
        return whimsy.generate(key, type || {});
      }
    };
  } else {
    whimsy[key] = function(opts) {
      return whimsy.generate(key, opts || {});
    };
  }
});
