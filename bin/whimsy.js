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
program.setMaxListeners(20);

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
  var command = _.isPlainObject(val) ? key + ' [type]' : key;
  program.command(command)
    .description('Generate ' + a(key))
    .option('-c, --count [count]', 'Generate multiple instances')
    .action(cli.writeResult(whimsy[key]));
});

program.on('*', function(args) {
  cli.writeResult(whimsy).apply(null, args.concat({}));
});

program.parse(process.argv);
