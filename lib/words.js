var _ = require('lodash');
var lists = require('./parts-of-speech');

exports.get = function() {
  var hasArrays = _.any(lists, function(val, key) {
    return val instanceof Array;
  });
  if (hasArrays) {
    return lists;
  } else {
    return exports.parse(lists);
  }
};

exports.parse = function(lists) {
  _.each(lists, function(val, key) {
    if (typeof val === 'string') {
      lists[key] = val.split(/\s*,\s*/g);
    } else {
      exports.parse(lists[key]);
    }
  });
  return lists;
};

exports.stringify = function(obj) {
  _.each(obj, function(val, key) {
    if (val instanceof Array) {
      obj[key] = val.join(', ');
    } else {
      exports.stringify(obj[key]);
    }
  });
  return JSON.stringify(obj, null, 2);
};
