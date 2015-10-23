#!/usr/bin/env node

var program = module.exports = require('commander');
var cli = require('../lib/cli');
var whimsy = require('../lib/whimsy');

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
 
program
  .command('noun [count]')
  .description('Genereate a noun')
  .action(cli.writeResult(whimsy.noun));

program.parse(process.argv);
