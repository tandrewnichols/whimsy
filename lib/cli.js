var fs = require('fs');
var path = require('path');
var words = require('./words');
var lists = words.get();
var _ = require('lodash');
var chalk = require('chalk');
var pluralize = require('pluralize');
var whimsy = require('./whimsy');
var block = require('log-block');

exports._action = function(type, action, listBuilder) {
  var list = _.get(lists, type);
  var newList = listBuilder(list);
  if (newList.length !== list.length) {
    _.set(lists, type, newList);
    fs.writeFile(path.resolve(__dirname, './parts-of-speech.json'), words.stringify(lists), { encoding: 'utf8' }, function(err) {
      var count = action === 'added' ? newList.length - list.length : list.length - newList.length;
      var singular = type.split('.').shift();
      block(chalk.green(count), pluralize(singular, count), action);
    });
  } else {
    block(chalk.red(0), pluralize(type, 0), action);
  }
};

exports.add = function(type, additions) {
  exports._action(type, 'added', function(list) {
    return list.concat(_.difference(additions, list));
  });
};

exports.remove = function(type, removals) {
  exports._action(type, 'removed', function(list) {
    return _.difference(list, removals);
  });
};

exports.writeResult = function(fn) {
  return function() {
    var args = [].slice.call(arguments);
    var options = typeof _.last(args) === 'object' ? args.pop() : {};
    var whimsyOpts = {
      count: options.count,
      filters: options.filter
    };
    var result = fn.apply(null, args.concat(whimsyOpts));
    process.stdout.write(result instanceof Array ? result.join(', ') : result);
  };
};

exports.collectFilters = function(val, memo) {
  memo = memo || [];
  memo.push(whimsy.parse(val)); 
  return memo;
};
