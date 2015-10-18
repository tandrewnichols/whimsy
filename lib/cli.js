var fs = require('fs');
var path = require('path');
var words = require('../lib/words');
var lists = words.get();
var _ = require('lodash');
var chalk = require('chalk');
var pluralize = require('pluralize');

exports.add = function(type, additions, options) {
  var list = _.get(lists, type);
  var newList = list.concat(_.difference(additions, list));
  if (newList.length !== list.length) {
    _.set(lists, type, newList);
    fs.writeFile(path.resolve(__dirname, './parts-of-speech.json'), words.stringify(lists), { encoding: 'utf8' }, function(err) {
      exports.logBlock(chalk.green(newList.length - list.length), type, 'added');
    });
  }
};

exports.remove = function() {

};

exports.logBlock = function(count, type, verb) {
  console.log();
  console.log('  ', count, pluralize(type, count), verb);
  console.log();
};

