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

### 1. Via the exported function

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

The available filters are:

* `startsWith(letter)` - Include only words beginning with `letter`.
* `endsWith(letter)` - Include only words ending with `letter`.
* `contains(substring)` - Include only words containing `substring`.
* `matching(regex)` - Include only words matching `regex`.
* `greaterThan(number)` - Include only words longer than `number` letters.
* `lessThan(number)` - Include only words shorter than `number` letters.
* `include(words...)` - Extra words to include in the random calculation that aren't normally in the list.
* `exclude(words...)` - Words in the list to leave out.

The available transformations are:

* `pluralize()` - Pluralize the chosen word.
* `capitalize()` - Capitalize the chosen word.
* `past()` - Conjugate the chosen word to the past tense. Note that this only makes sense for verbs, but there's nothing preventing you from doing this with any word. I.e. `{{ noun | past }}` wouldn't throw an error and could return something nonsensical like "gnomed" . . . which may or may not be okay (like if you're writing a [Ulysses](https://en.wikipedia.org/wiki/Ulysses_(novel))-esque novel).
* `pastParticiple()` - Congjugate the chosen word to the past participle.
* `conjugate(pronoun)` - Conjugate the chosen word based on the point of view (e.g. I run/you run/he runs).
* `saveAs(key)` - Store the word generated to use again a later, e.g. `Fast {{ noun | saveAs("a") }} is the best {{ a }}`

##### Custom filters

Additionally, you can register your own filters. For example, if you wanted to reverse the chosen word (for some bizarre reason):

```js
whimsy.register('reverse', function(word) {
  return word.split('').reverse().join('');
});
whimsy('{{ noun | reverse }}');
```

### 2. Via the whimsy API

##### Parts of speech

In addition to calling whimsy directly, you have access to a few lower level APIs that are useful. Most notably, each part of speech is a function on the whimsy object, so you do the following:

```js
whimsy.noun();
whimsy.pronoun();
whimsy.pronoun('reflexive');
```

These will return you a single word of the part of speech you specify.

##### .generate()

`.generate` is the first function called by the part-of-speech functions, so you can call it directly if you want. The only required parameter to the `.generate` function is the part of speech, so calling it can be as simple as

```js
whimsy.generate('pronoun.reflexive');
```

But you can also generate multiple words:

```js
whimsy.generate('noun', { count: 2 }); // "count" is the only option at the moment
```

And apply filters to them:

```js
whimsy.generate('verb', [{ name: 'conjugate', params: ['he'] }]); // Not all filters require "params"

// Note that the list of filters is not part of the options object. If you want to pass both, it looks like this
whimsy.generate('noun', { count: 4 }, [{ name: 'capitalize' }]);
```

##### Internal API

Additionally, all of the internal methods on whimsy are accessible, so you could do some things yourself if you wanted to. Something like:

```js
var list = ['a', 'list', 'of', 'random', 'word'];
var word = whimsy.get(list); // Returns a random word from a list
var processedWord = whimsy.applyFilters(word, [{ name: 'capitalize' }, { name: 'saveAs', params: ['foo'] }]); // Runs the word through the filters supplied
```

These are all undocumented methods as they're not really intended for direct consumption, but the enterprising developer who spends some time looking at the code and the tests might find some interesting uses for them.

##### With filters

You can also call these part-of-speech functions with options.

### 3. Via the whimsy binary

### Browser

### Example

## Contributing

Please see [the contribution guidelines](CONTRIBUTING.md).
