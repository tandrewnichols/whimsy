#!/usr/bin/env node

var program = module.exports = require('commander');
var cli = require('../lib/cli');
var whimsy = require('../lib/whimsy');
var words = require('../lib/words');
var lists = words.get();
var a = require('indefinite');
var _ = require('lodash');

program.version = require('../package').version;
program.name = 'whimsy';

program
  .command('add <type> <words...>')
  .description('Add a new word to the list of words')
  .action(cli.add);

program
  .command('remove <type> <words...>')
  .alias('rm')
  .description('Remove a word from the list of words')
  .action(cli.remove);
 
_.each(lists, function(val, key) {
  var command = _.isPlainObject(val) ? key + ' [type] [count]' : key + ' [count]';
  program.command(command)
    .description('Generate ' + a(key))
    .action(cli.writeResult(whimsy[key]));
});

program.parse(process.argv);
