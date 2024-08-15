# Change Log

## [v1.2.4](https://github.com/glejeune/Ruby-Graphviz/tree/v1.2.4) (2018-11-13)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.2.3...v1.2.4)

**Closed issues:**

- sametail and samehead not working? [\#132](https://github.com/glejeune/Ruby-Graphviz/issues/132)

**Merged pull requests:**

- Add support for the 'class' attribute [\#138](https://github.com/glejeune/Ruby-Graphviz/pull/138) ([moracca](https://github.com/moracca))
- Added explicitly declaration for Open3 module on GraphVizTest. [\#130](https://github.com/glejeune/Ruby-Graphviz/pull/130) ([hsbt](https://github.com/hsbt))

## [v1.2.3](https://github.com/glejeune/Ruby-Graphviz/tree/v1.2.3) (2017-03-21)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.2.2...v1.2.3)

**Closed issues:**

- Link to https://lejeun.es/ doesn't work [\#114](https://github.com/glejeune/Ruby-Graphviz/issues/114)
- How to unflatten the graph? [\#67](https://github.com/glejeune/Ruby-Graphviz/issues/67)

**Merged pull requests:**

- Add gemspec requirements attribute [\#128](https://github.com/glejeune/Ruby-Graphviz/pull/128) ([guilhermesimoes](https://github.com/guilhermesimoes))
- Update links to HTTPS [\#127](https://github.com/glejeune/Ruby-Graphviz/pull/127) ([guilhermesimoes](https://github.com/guilhermesimoes))
- README: Use SVG badge icons [\#126](https://github.com/glejeune/Ruby-Graphviz/pull/126) ([olleolleolle](https://github.com/olleolleolle))
- Managed to get rubinius-3.69 to build with Travis-CI [\#123](https://github.com/glejeune/Ruby-Graphviz/pull/123) ([khalilfazal](https://github.com/khalilfazal))
- ruby 2.4.0 merged Fixnum and Bignum into Integer [\#121](https://github.com/glejeune/Ruby-Graphviz/pull/121) ([khalilfazal](https://github.com/khalilfazal))
- Make it obvious which gem this is [\#119](https://github.com/glejeune/Ruby-Graphviz/pull/119) ([nathanl](https://github.com/nathanl))
- Adding license info to gempsec [\#118](https://github.com/glejeune/Ruby-Graphviz/pull/118) ([reiz](https://github.com/reiz))

## [v1.2.2](https://github.com/glejeune/Ruby-Graphviz/tree/v1.2.2) (2015-05-13)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.2.1...v1.2.2)

**Fixed bugs:**

- Can no longer create binary strings [\#92](https://github.com/glejeune/Ruby-Graphviz/issues/92)

**Closed issues:**

- uninitialized constant GraphViz \(NameError\) [\#95](https://github.com/glejeune/Ruby-Graphviz/issues/95)
- labelfontcolor [\#86](https://github.com/glejeune/Ruby-Graphviz/issues/86)

**Merged pull requests:**

- Remove duplication in utils/colors.rb [\#103](https://github.com/glejeune/Ruby-Graphviz/pull/103) ([OrelSokolov](https://github.com/OrelSokolov))

## [v1.2.1](https://github.com/glejeune/Ruby-Graphviz/tree/v1.2.1) (2014-07-02)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.2.0...v1.2.1)

## [v1.2.0](https://github.com/glejeune/Ruby-Graphviz/tree/v1.2.0) (2014-06-09)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.1.0...v1.2.0)

**Fixed bugs:**

- Force label to be HTML [\#89](https://github.com/glejeune/Ruby-Graphviz/issues/89)

**Closed issues:**

- Drawing a graph fails when a node is called "node" [\#90](https://github.com/glejeune/Ruby-Graphviz/issues/90)
- Node IDs are not escaped for reserved keywords [\#87](https://github.com/glejeune/Ruby-Graphviz/issues/87)
- time for another gem? [\#85](https://github.com/glejeune/Ruby-Graphviz/issues/85)
- Theory\#moore\_dijkstra doesn't play nice with escaping [\#83](https://github.com/glejeune/Ruby-Graphviz/issues/83)
- Rename project and gem on rubygems [\#80](https://github.com/glejeune/Ruby-Graphviz/issues/80)

## [v1.1.0](https://github.com/glejeune/Ruby-Graphviz/tree/v1.1.0) (2014-06-09)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.9...v1.1.0)

**Fixed bugs:**

- Dot2Ruby Subgraph of subgraph [\#74](https://github.com/glejeune/Ruby-Graphviz/issues/74)
- RGB color list - supported? [\#70](https://github.com/glejeune/Ruby-Graphviz/issues/70)

**Closed issues:**

- Duplicate [\#75](https://github.com/glejeune/Ruby-Graphviz/issues/75)
- don't treat dot's output into stderr as error. check dot's return code [\#72](https://github.com/glejeune/Ruby-Graphviz/issues/72)
- Trouble with dot2ruby [\#71](https://github.com/glejeune/Ruby-Graphviz/issues/71)
- HTML-like labels supported [\#64](https://github.com/glejeune/Ruby-Graphviz/issues/64)
- How to combine graphviz instances? [\#61](https://github.com/glejeune/Ruby-Graphviz/issues/61)
- man pages for the commandline programs [\#57](https://github.com/glejeune/Ruby-Graphviz/issues/57)

**Merged pull requests:**

- Node name error [\#91](https://github.com/glejeune/Ruby-Graphviz/pull/91) ([joaozeni](https://github.com/joaozeni))
- Escape reserved words in node IDs [\#88](https://github.com/glejeune/Ruby-Graphviz/pull/88) ([joaomsa](https://github.com/joaomsa))
- only escape Edge\#node\_one and Edge\#node\_two when output [\#84](https://github.com/glejeune/Ruby-Graphviz/pull/84) ([josephholsten](https://github.com/josephholsten))
- Avoid constructing shell commands as strings [\#73](https://github.com/glejeune/Ruby-Graphviz/pull/73) ([AndrewKvalheim](https://github.com/AndrewKvalheim))

## [v1.0.9](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.9) (2013-04-24)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.8...v1.0.9)

**Fixed bugs:**

- ruby2gv is failing [\#56](https://github.com/glejeune/Ruby-Graphviz/issues/56)

**Closed issues:**

- ruby-graphviz breaks autoloading of ActiveSupport::Concerns [\#65](https://github.com/glejeune/Ruby-Graphviz/issues/65)
- Can't convert Fixnum to String \(TypeError\) [\#59](https://github.com/glejeune/Ruby-Graphviz/issues/59)
- tests are failing to run in a chroot environment [\#58](https://github.com/glejeune/Ruby-Graphviz/issues/58)
- Avoid autoload [\#55](https://github.com/glejeune/Ruby-Graphviz/issues/55)
- why deprecate add\_node\(\) and add\_edge\(\)? [\#53](https://github.com/glejeune/Ruby-Graphviz/issues/53)
- feature request: title on graph [\#23](https://github.com/glejeune/Ruby-Graphviz/issues/23)

**Merged pull requests:**

- Fix typo [\#63](https://github.com/glejeune/Ruby-Graphviz/pull/63) ([kachick](https://github.com/kachick))
- Remove some warnings [\#62](https://github.com/glejeune/Ruby-Graphviz/pull/62) ([kachick](https://github.com/kachick))
- Fix for numberic labels, tested.  Fixes \#59. [\#60](https://github.com/glejeune/Ruby-Graphviz/pull/60) ([gkop](https://github.com/gkop))
- Fixes a couple of typos and spacing [\#54](https://github.com/glejeune/Ruby-Graphviz/pull/54) ([miketheman](https://github.com/miketheman))
- Extracted xDOTScript to DOTScript class [\#52](https://github.com/glejeune/Ruby-Graphviz/pull/52) ([markus1189](https://github.com/markus1189))

## [v1.0.8](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.8) (2012-07-03)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.7...v1.0.8)

**Fixed bugs:**

- add\_graph fails when passed a GraphViz object [\#48](https://github.com/glejeune/Ruby-Graphviz/issues/48)

**Closed issues:**

- \(undefined local variable or method `file' \) [\#49](https://github.com/glejeune/Ruby-Graphviz/issues/49)

**Merged pull requests:**

- Fix issue \#49 [\#51](https://github.com/glejeune/Ruby-Graphviz/pull/51) ([markus1189](https://github.com/markus1189))
- Cleanup format [\#50](https://github.com/glejeune/Ruby-Graphviz/pull/50) ([markus1189](https://github.com/markus1189))

## [v1.0.7](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.7) (2012-07-02)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.6...v1.0.7)

**Merged pull requests:**

- Find executable [\#47](https://github.com/glejeune/Ruby-Graphviz/pull/47) ([markus1189](https://github.com/markus1189))

## [v1.0.6](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.6) (2012-07-01)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.5...v1.0.6)

**Fixed bugs:**

- escaped dot in label, backslash showing up [\#42](https://github.com/glejeune/Ruby-Graphviz/issues/42)
- cannot load such file -- xml/xslt [\#39](https://github.com/glejeune/Ruby-Graphviz/issues/39)

**Closed issues:**

- some tests fail because it cannot find 'dot' [\#46](https://github.com/glejeune/Ruby-Graphviz/issues/46)
- GraphML importation doesn't work... [\#40](https://github.com/glejeune/Ruby-Graphviz/issues/40)
- Can't assign nil to node attributes [\#38](https://github.com/glejeune/Ruby-Graphviz/issues/38)

**Merged pull requests:**

- Fix for copy/paste error [\#45](https://github.com/glejeune/Ruby-Graphviz/pull/45) ([coding46](https://github.com/coding46))
- characters escaping [\#44](https://github.com/glejeune/Ruby-Graphviz/pull/44) ([nevenh](https://github.com/nevenh))
- Added lib/ruby-graphviz to match the gem name. [\#43](https://github.com/glejeune/Ruby-Graphviz/pull/43) ([postmodern](https://github.com/postmodern))

## [v1.0.5](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.5) (2012-02-06)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.4...v1.0.5)

**Fixed bugs:**

- About the acquisition of graphml \<data\> tags with ruby 1.9.2p290, ruby-graphviz 1.0.3 [\#34](https://github.com/glejeune/Ruby-Graphviz/issues/34)

## [v1.0.4](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.4) (2012-01-29)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.3...v1.0.4)

**Merged pull requests:**

- Correct spelling of 'attribute' in node documentation [\#37](https://github.com/glejeune/Ruby-Graphviz/pull/37) ([shepmaster](https://github.com/shepmaster))
- Update example to reflect deprecation of methods [\#36](https://github.com/glejeune/Ruby-Graphviz/pull/36) ([shepmaster](https://github.com/shepmaster))

## [v1.0.3](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.3) (2011-12-17)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.2...v1.0.3)

**Merged pull requests:**

- Removed definition of Array\#all? from core\_ext.rb [\#33](https://github.com/glejeune/Ruby-Graphviz/pull/33) ([ronen](https://github.com/ronen))

## [v1.0.2](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.2) (2011-12-11)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/v1.0.1...v1.0.2)

**Closed issues:**

- Instead of outputting an image, is it possible to get the x,y coordinates of each of the nodes? [\#28](https://github.com/glejeune/Ruby-Graphviz/issues/28)

**Merged pull requests:**

- fix utils/colors.rb's case syntax [\#32](https://github.com/glejeune/Ruby-Graphviz/pull/32) ([hirochachacha](https://github.com/hirochachacha))

## [v1.0.1](https://github.com/glejeune/Ruby-Graphviz/tree/v1.0.1) (2011-12-08)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/1.0.0...v1.0.1)

**Closed issues:**

- How can I add named edges? [\#31](https://github.com/glejeune/Ruby-Graphviz/issues/31)

**Merged pull requests:**

- Fix a few typos in the README. [\#30](https://github.com/glejeune/Ruby-Graphviz/pull/30) ([jergason](https://github.com/jergason))
- Changed deprecated Config to RbConfig in util.rb [\#29](https://github.com/glejeune/Ruby-Graphviz/pull/29) ([ronen](https://github.com/ronen))
- Add rubygems-test .gemrc file to enable easy testing of the installed gem [\#26](https://github.com/glejeune/Ruby-Graphviz/pull/26) ([dznz](https://github.com/dznz))
- Update gem creation [\#25](https://github.com/glejeune/Ruby-Graphviz/pull/25) ([dznz](https://github.com/dznz))

## [1.0.0](https://github.com/glejeune/Ruby-Graphviz/tree/1.0.0) (2011-05-02)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.21...1.0.0)

## [0.9.21](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.21) (2011-03-26)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.20...0.9.21)

## [0.9.20](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.20) (2010-11-20)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.19...0.9.20)

## [0.9.19](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.19) (2010-10-30)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.18...0.9.19)

## [0.9.18](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.18) (2010-10-07)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.17...0.9.18)

## [0.9.17](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.17) (2010-08-29)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.16...0.9.17)

## [0.9.16](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.16) (2010-08-02)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.15...0.9.16)

## [0.9.15](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.15) (2010-07-19)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.14...0.9.15)

## [0.9.14](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.14) (2010-07-12)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.13...0.9.14)

## [0.9.13](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.13) (2010-07-06)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.12...0.9.13)

## [0.9.12](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.12) (2010-06-24)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.11...0.9.12)

## [0.9.11](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.11) (2010-03-28)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.9...0.9.11)

## [0.9.9](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.9) (2010-02-12)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.8...0.9.9)

## [0.9.8](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.8) (2010-01-16)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.7...0.9.8)

## [0.9.7](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.7) (2009-12-18)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.5...0.9.7)

## [0.9.5](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.5) (2009-11-15)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.4...0.9.5)

## [0.9.4](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.4) (2009-10-20)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.3...0.9.4)

## [0.9.3](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.3) (2009-10-19)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.2...0.9.3)

## [0.9.2](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.2) (2009-10-15)
[Full Changelog](https://github.com/glejeune/Ruby-Graphviz/compare/0.9.1...0.9.2)

## [0.9.1](https://github.com/glejeune/Ruby-Graphviz/tree/0.9.1) (2009-10-10)


\* *This Change Log was automatically generated by [github_changelog_generator](https://github.com/skywinder/Github-Changelog-Generator)*