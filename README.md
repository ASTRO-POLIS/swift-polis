# swift-polis

This is a Swift implementation of POLIS standard. It contains mostly API types and a predefined set of well known constants.

As often as possible types are similar to types defined by [RTML](http://www.astro.physik.uni-goettingen.de/~hessman/misc/RTML-3.2b.xsd)

**Note about testing:** The tests are only to test encoding and decoding different types from and to JSON and (later) to XML formatters.  For some types the implementation of `CustomStringConvertible` will be also tested in order to support easy debugging.
