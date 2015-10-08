var partsOfSpeech = require('./parts-of-speech');
var _ = require('lodash');
var filters = require('./filters');

var whimsy = module.exports = function(phrase) {
  return phrase.replace(/\{\{\s*([^\}]*)\s*\}\}/g, whimsy.interpolate);
};

whimsy.interpolate = function(original, match) {
  var context = {
    match: match.trim()
  };
  context.postFilters = whimsy.makeFilters(context, '|');
  context.preFilters = whimsy.makeFilters(context, ':');
  var word = whimsy.generate(context.match.trim());
  return whimsy.applyFilters(word, context);
};

whimsy.makeFilters = function(context, separator) {
  var parts = context.match.split(separator);
  var filters = parts.slice(1);
  context.match = parts[0];
  return _(filters).map(_.trim).map(whimsy.standardizeFilter).map(function(body) {
    return new Function('filters', 'word', body);  
  }).value();
};

whimsy.standardizeFilter = function(filter) {
  var funcName = filter.split('(')[0];
  if (typeof filters[funcName] === 'function') {
    if (filter.indexOf('(') === -1) {
      filter += '(word)';
    }
    return 'return filters.' + filter;
  } else {
    return 'return filters.noop()';
  }
};

whimsy.applyFilters = function(word, context) {
  return _.reduce(context.postFilters, function(memo, filter) {
    return filter(filters, memo);
  }, word);
};

whimsy.concat = function(part, type) {
  return part + (type ? '.' + type : '');
};

whimsy.generate = function(path) {
  var list = _.clone(_.get(partsOfSpeech, path));
  if (list instanceof Object) {
    list = _(list).values().flatten().value();
  }
  return whimsy.get(_.uniq(list));
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
