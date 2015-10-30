var pluralize = require('pluralize');
var tensify = require('tensify');
var conjugate = require('conjugate');

var _ = require('lodash');

exports.preFilters = ['startsWith', 'endsWith', 'contains', 'matching', 'greaterThan', 'lessThan', 'include', 'exclude'];
exports.postFilters = ['pluralize', 'capitalize', 'past', 'pastParticiple', 'conjugate', 'saveAs'];
exports._refs = {};

// Default filter - do nothing
exports.noop = function(word) {
  return word;
};

/*
 * Pre filters
 */

exports.startsWith = function(letter, list) {
  return _.filter(list, function(item) {
    return _.startsWith(item, letter);
  });
};

exports.endsWith = function(letter, list) {
  return _.filter(list, function(item) {
    return _.endsWith(item, letter);
  });
};

exports.contains = function(letter, list) {
  return _.filter(list, function(item) {
    return _.contains(item, letter);
  });
};

exports.matching = function(regex, list) {
  regex = new RegExp(regex);
  return _.filter(list, function(item) {
    return regex.test(item);
  });
};

exports.greaterThan = function(count, list) {
  return _.filter(list, function(item) {
    return item.length > count;
  });
};

exports.lessThan = function(count, list) {
  return _.filter(list, function(item) {
    return item.length < count;
  });
};

exports.include = function(extras, list) {
  return list.concat(extras);
};

exports.exclude = function(exclusions, list) {
  if (typeof exclusions === 'string') {
    return _.without(list, exclusions);
  } else {
    return _.difference(list, exclusions);
  }
};

/*
 * Post filters
 */

exports.pluralize = function(word) {
  return pluralize(word);
};

exports.capitalize = _.capitalize;

exports.past = function(verb) {
  return tensify(verb).past;
};

exports.pastParticiple = function(verb) {
  return tensify(verb).past_participle;
};

exports.conjugate = conjugate;

exports.saveAs = function(key, val) {
  exports._refs[key] = val;
  return val;
};
