#!/usr/bin/env node

var program = module.exports = require('commander');
var cli = require('../lib/cli');

program.version = require('../package').version;
program.name = 'whimsy';

program
  .command('add <type> <word')
  .description('Add a new word to the list of words')
  .action(cli.add);

program.parse(process.argv);
