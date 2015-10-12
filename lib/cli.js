var fs = require('fs');
var path = require('path');
var lists = require('../lib/words').get();
var _ = require('lodash');
var chalk = require('chalk');
var pluralize = require('pluralize');

exports.add = function(type) {
  var options = [].pop.call(arguments);
  var items = [].slice.call(arguments, 1);
  var list = _.get(lists, type);
  var newList = list.concat(_.difference(items, list));
  if (newList.length !== list.length) {
    _.set(lists, type, newList);
    fs.writeFile(path.resolve(__dirname, './parts-of-speech.json'), JSON.stringify(lists, null, 2), { encoding: 'utf8' }, function(err) {
      exports.logBlock(chalk.green(newList.length - list.length), type, 'added');
    });
  }
};

//exports.remove = function(

exports.logBlock = function(count, noun, verb) {
  console.log();
  console.log('  ', count, pluralize(noun, count), verb);
  console.log();
};

