var lists = require('./words').get();
var _ = require('lodash');
var filters = require('./filters');

var whimsy = module.exports = function(phrase, num) {
  num = num || 1;
  var replacements = _.map(_.range(num), function() {
    return phrase.replace(/\{\{\s*([^\}]*)\s*\}\}/g, whimsy.interpolate);
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
  var word = whimsy.generate(context.match.trim(), preFilters);
  return whimsy.applyFilters(word, postFilters);
};

whimsy.makeFilters = function(context) {
  var parts = context.match.split('|');
  var filters = parts.slice(1);
  context.match = parts[0];
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
    func.params = invocation[1].split(')')[0].replace(/"/g, '').split(',').filter(Boolean);
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

whimsy.generate = function(path, preFilters) {
  var list = _.clone(_.get(lists, path));
  if (_.isPlainObject(list)) {
    list = _(list).values().flatten().value();
  }
  list = _.reduce(preFilters, whimsy.invokeFilter, _.uniq(list));
  return whimsy.get(list);
};

whimsy.get = function(list) {
  return list[ _.random(list.length - 1) ];
};

whimsy.noun = function() {
  return whimsy.generate('noun');
};

whimsy.verb = function() {
  return whimsy.generate('verb');
};

whimsy.adjective = function() {
  return whimsy.generate('adjective');
};

whimsy.adverb = function() {
  return whimsy.generate('adverb');
};

whimsy.pronoun = function(type) {
  return whimsy.generate(whimsy.concat('pronoun', type));
};

whimsy.preposition = function() {
  return whimsy.generate('preposition');
};

whimsy.conjunction = function(type) {
  return whimsy.generate(whimsy.concat('conjunction', type));
};

whimsy.interjection = function() {
  return whimsy.generate('interjection');
};

whimsy.article = function() {
  return whimsy.generate('article');
};
