var fs = require('fs');
var path = require('path');
var words = require('../lib/words');
var lists = words.get();
var _ = require('lodash');
var chalk = require('chalk');
var pluralize = require('pluralize');

exports._action = function(type, action, listBuilder) {
  var list = _.get(lists, type);
  var newList = listBuilder(list);
  if (newList.length !== list.length) {
    _.set(lists, type, newList);
    fs.writeFile(path.resolve(__dirname, './parts-of-speech.json'), words.stringify(lists), { encoding: 'utf8' }, function(err) {
      var count = action === 'added' ? newList.length - list.length : list.length - newList.length;
      exports.logBlock(chalk.green(count), type, action);
    });
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
    process.stdout.write(fn.apply(null, args));
  };
};

exports.logBlock = function(count, type, verb) {
  console.log();
  console.log('  ', count, pluralize(type, count), verb);
  console.log();
};

