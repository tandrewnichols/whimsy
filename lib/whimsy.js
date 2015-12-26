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

whimsy.generated = [];

whimsy.interpolate = function(original, match) {
  var context = {
    match: match.trim()
  };
  var appliedFilters = whimsy.makeFilters(context);
  appliedFilters = whimsy.getFilterSets(appliedFilters);
  var word = filters._refs[ context.match ] || whimsy.generate(context.match.trim(), appliedFilters.preFilters);
  return whimsy.applyFilters(word, appliedFilters.postFilters);
};

whimsy.makeFilters = function(context) {
  var parts = context.match.split('|');
  var filters = parts.slice(1);
  context.match = parts[0].trim();
  return _(filters).map(_.trim).map(whimsy.parse).value();
};

whimsy.getFilterSets = function(list) {
  return _.groupBy(list, function(filter) {
    return filters.preFilters.indexOf(filter.name) > -1 ? 'preFilters' : 'postFilters';
  });
};

whimsy.parse = function(filter) {
  var invocation = filter.split('(');
  var func = {
    name: invocation[0],
    params: []
  };

  if (invocation[1]) {
    var rawArgs = invocation[1].split(')')[0];
    var regex = /(\[(.*?)\])|(\{(.*?)\})|(["'](.*?)["'])|(\d+)/g; 
    var match;
    while((match = regex.exec(rawArgs)) !== null) {
      // match[1] is anything inside []
      // match[3] is anything inside {}
      if (match[1] || match[3]) {
        // Parse these into arrays/objects
        func.params.push(JSON.parse(match[1] || match[3]));
      }
      // match[7] is numbers
      else if (match[7]) {
        // Make them into real numbers instead of string numbers
        func.params.push(Number(match[7]));
      }
      // match[6] is strings
      else {
        // push it as is
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
  var params = _.clone(filter.params || []);
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
    var existing = _.get(whimsy.generated, path) || [];
    list = _.difference(list, existing);
    var word = whimsy.get(list);
    _.set(whimsy.generated, path, existing.concat(word));
    memo.push(word);
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
  whimsy[key] = function(subtype, opts) {
    if (typeof subtype === 'object') {
      opts = subtype;
      subtype = null;
    }
    opts = opts || {};
    var appliedFilters = opts.filters ? whimsy.getFilterSets(opts.filters) : {};
    var type = whimsy.concat(key, subtype);
    var word = whimsy.generate(type, opts, appliedFilters.preFilters);
    return whimsy.applyFilters(word, appliedFilters.postFilters);
  };
});
