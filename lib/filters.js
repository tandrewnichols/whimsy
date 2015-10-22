var pluralize = require('pluralize');
var tensify = require('tensify');

var _ = require('lodash');

exports.preFilters = ['startsWith', 'endsWith', 'contains'];
exports.postFilters = ['pluralize', 'capitalize', 'past', 'pastParticiple', 'conjugate'];

exports.noop = function(word) {
  return word;
};

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

exports.conjugate = function(person, noun) {
  if (['he', 'she', 'it'].indexOf(person) > -1) {
    return noun + 's';
  } else {
    return noun;
  }
};

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
