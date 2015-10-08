var pluralize = require('pluralize');
var tensify = require('tensify');

var _ = require('lodash');

exports.pluralize = function(word) {
  return pluralize(word);
};

exports.capitalize = _.capitalize;
