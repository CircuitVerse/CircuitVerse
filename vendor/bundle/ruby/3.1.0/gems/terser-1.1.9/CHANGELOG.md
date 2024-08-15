## Unreleased
## 1.1.9 (04 May 2022)
- update TerserJS to [5.13.1]

## 1.1.8 (25 November 2021)
- update TerserJS to [5.10.0]

## 1.1.7 (23 September 2021)
- update TerserJS to [5.9.0]

## 1.1.6 (15 September 2021)
- update TerserJS to [5.8.0]

## 1.1.5 (29 June 2021)
- update TerserJS to [5.7.1]

## 1.1.4 (27 June 2021)
- update TerserJS to [5.7.0]
- use railtie to register compressor on Rails initialization

## 1.1.3 (23 March 2021)
- update TerserJS to [5.6.1]

## 1.1.2 (03 March 2021)
- update TerserJS to [5.6.0]

## 1.1.1 (19 November 2020)
- update TerserJS to [5.5.0]
- (bugfix) error messages
- update rubocop to 1.3.1

## 1.1.0 (17 November 2020)
- update TerserJS to [5.4.0]

## 1.0.2 (13 October 2020)
- LICENSE.txt encoding fix
- update rubocop to 0.93.1

## 1.0.1 (02 August 2020)
- share the context in order to speedup sprockets compilation

## 1.0.0 (13 July 2020)
- add sprockets wrapper
- drop Ruby < 2.3.0 support
- drop ES5 mode
- drop IE8 mode
- drop unsupported runtimes (therubyracer, therubyrhino) because they don't support ECMA6
- update tests and new options
- update SourceMap to [0.6.1](https://github.com/mozilla/source-map/compare/0.5.7...0.6.1)
- update TerserJS to [4.8.0]
- switch from UglifyJS to TerserJS (https://github.com/terser/terser)
- fork from Uglifier (https://github.com/lautis/uglifier/releases/tag/v4.2.0)
