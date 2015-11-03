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
    .option('-c, --count [count]', 'Generate multiple instances', Number)
    .option('-f, --filter [filter]', 'Apply a transformation to the word', cli.collectFilters)
    .action(cli.writeResult(whimsy[key]));
});

// Only add this command if the arguments to the script don't match any
// of the commands above so that this command doesn't overwrite the
// more specific "count" options above.
if (process.argv[1].split('/').pop() === 'whimsy.js' && _.pluck(program.commands, '_name').indexOf(process.argv[2]) === -1) {
  program
    .option('-c, --count [count]', 'Generate multiple instances', Number)
    .command('*')
    .description('Generate a sentence of interpolation')
    .action(function(pattern, options) {
      cli.writeResult(whimsy)(pattern, options.parent.count);
    });
}

program.parse(process.argv);
