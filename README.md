[![Build Status](https://travis-ci.org/tandrewnichols/whimsy.png)](https://travis-ci.org/tandrewnichols/whimsy) [![downloads](http://img.shields.io/npm/dm/whimsy.svg)](https://npmjs.org/package/whimsy) [![npm](http://img.shields.io/npm/v/whimsy.svg)](https://npmjs.org/package/whimsy) [![Code Climate](https://codeclimate.com/github/tandrewnichols/whimsy/badges/gpa.svg)](https://codeclimate.com/github/tandrewnichols/whimsy) [![Test Coverage](https://codeclimate.com/github/tandrewnichols/whimsy/badges/coverage.svg)](https://codeclimate.com/github/tandrewnichols/whimsy) [![dependencies](https://david-dm.org/tandrewnichols/whimsy.png)](https://david-dm.org/tandrewnichols/whimsy) ![Size](https://img.shields.io/badge/size-309.7k-brightgreen.svg)

# whimsy

Generate random words to add a touch of whimsy to your code.

## Installation

`npm install --save whimsy`

## Summary

Whimsy is a little bit like a programmatic mad lib. It will generate random words based on the part of speech you give it. But it does a lot more, including filtering the list of words (e.g. only words starting with "s" or only _reflexive_ pronouns), transforming the word selected (e.g. capitalizing and conjugating), and saving words to apply them again later.

At the moment, whimsy is fairly limited. The lists of nouns, verbs, adjective, and adverbs are not very long (though the other parts of speech are relatively complete). The goal isn't really to have a complete dictionary encompassing every word in the English language so much as to provide, as the name suggests, a little _whimsy_. I'll be adding to these lists over time, but don't expect them to ever be definitive lists. If there are words you would like to see added, feel free to open an issue or a pull request (check out the [add](#add) binary command for an easy way to do this). I won't make any promises, however, about merging your words, especially anything crass. You can always [add](#add) words to your own local copy or fork this if you want words like that.

## Usage

Whimsy replaces mustache style interpolation patterns with random words, e.g. `{{ noun }}` generates a random noun. Whimsy is not smart, however. It can't pick words that make sense given the context around them. It just picks random ones from the list. There are three ways to use whimsy:

### 1. whimsy() as a function

##### With interpolation

The main way to use `whimsy` is to call it with a string with patterns to replace.

```js
var whimsy = require('whimsy');
var phrase = whimsy('The {{ noun }} will {{ verb }}');
console.log(phrase); // Ex. The parody will resolve
```

##### With subtypes

If you need (slightly) more fine-grained control over the output, you can specify a subtype of the part of speech. Not all parts of speech have subtypes. At the moment, pronouns have the possible subtypes personal, relative, demonstrative, indefinite, reflexive, interrogative, and possessive; and conjunctions have the possible subtypes coordinating, subordinating, and correlative. If you don't know what these things mean, you can either look them up or have a look at `lib/parts-of-speech.json` to see what kind of words are in each category. Eventually, there will be more subtypes available. For instance, verbs will eventually be broken into transitive and intransitive and nouns will have various categories like foods, colors, and proper names (so that you could say `whimsy('For the love of {{ noun.proper }}!')` and get "For the love of Robin Williams!" or such).

To add a subtype, just use dot-notation in your interpolation:

```js
whimsy('{{ pronoun.personal }} is a {{ noun }}');
```

##### With filters and transformers

You can also apply filters and transformers to a `whimsy` sentence. Filters and transformers are all accessed by using the pipe character (`|`). Filters narrow the list of words from which a random word is selected, while transformers function on the word itself after it is chosen.

```js
// A filter
whimsy('{{ noun | startsWith("a") }}'); // Will return a noun that start with the letter "a"

// A transformer
whimsy('{{ noun | capitalize }}'); // Will return a capitalized noun
```

You can also combine filters and transformers (as many as you want and in any order - whimsy will figure it out).

```js
// Here, startsWith and endsWith will be applied first, followed by
// capitalize. A possible result of this phrase is "Apple."
whimsy('{{ noun | startsWith("a") | capitalize | endsWith("e") }}');
```

### Node
### Browser

### Example

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
