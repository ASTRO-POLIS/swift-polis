# swift-polis

This is a Swift implementation of POLIS standard. It contains mostly API types and a predefined set of well known constants. It also implements the entire software infrastructure needed by POLIS client software and / or POLIS provider.

Polis supports two (in future possible more) API formats - JSON and XML. Each API format could support zero, one, or more versions. This framework makes the API and version  details completely opaque. The software based on this framework should focus on the business logic (POLIS provider management or client software with primary goal to visualise the data) while the framework handles compatibility to various API formats and versions.

The simplest configuration is the Polis client. The client monitors and syncs with a predefined Polis provider and sends update notifications to the client software. The framework could also be used to create and maintain a Polis provider of any type (e.g. experimental, public, etc.). As a minimum, the framework maintains a local copy of all POLIS data needed. In case the framework is used also to maintain a POLIS provider, two independent data structures are created, and the provider is updated only when this is demanded to avoid configuration mismatches for the external clients of this Polis provider.

## Static data stored to the local file system

**Note:** If an entry is not marked by either `client` or `provider` it means that it is used in both cases (as most data structures are common to both client cache and provider data).

- .../(client/provider)root_path/... - Root path is the folder that contains all POLIS related data. In case the framework is used to maintain also a POLIS provider, two root pats (for the client and for the provider) are required.

## Dependancies 
In general we are trying to avoid dependancies to other projects. Why? We share the concerns of many other well respected developers on this subject. But in the case of `swift-polis` we decided to use software modules developed and maintained by members of our team. This guarantees that even the concrete author of the module abbandons the project, someone from our team can take over the maintenance.
Current dependences include:
- [SoftwareEtudes](https://github.com/tuparev/SoftwareEtudes)
We use this package for the `SemanticVersion` type, that helps us manage POLIS versions.

### Random notes to be sorted later
**Note about RTML:** As often as possible types are similar to types defined by [RTML](http://www.astro.physik.uni-goettingen.de/~hessman/misc/RTML-3.2b.xsd)

**Note about testing:** The tests are only to test encoding and decoding different types from and to JSON and (later) to XML formatters.  For some types the implementation of `CustomStringConvertible` will be also tested in order to support easy debugging.
