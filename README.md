# swift-polis

## Framework organisation
The framework contains general sources common to all support levels and sources, specific or level 1, 2, or 3 (StaticData, DynamicStatus, or DynamicScheduling)

### Common for the entire framework sources

### Level 1 support (static resources)

### Level 2 support

### Level 3 support

## Framework Dependancies
- [SoftwareEtudes](https://github.com/tuparev/SoftwareEtudes) is a collection of useful general types developed and maintained by one of the POLIS creators.


## To be refactored...

This is a Swift implementation of the POLIS standard. It contains mostly API types and a predefined set of well known constants. It also implements the entire software infrastructure needed by POLIS client software and / or POLIS providers.

Polis supports two (more formats may be possible in the future) API formats - JSON and XML. Each API format could support zero, one, or more versions. This framework makes the API and version details completely opaque. The software based on this framework should focus on the business logic (POLIS provider management or client software with the primary goal to visualise the data) while the framework handles compatibility to various API formats and versions.

The simplest configuration is the Polis client. The client monitors and syncs with a predefined Polis provider and sends update notifications to the client software. The framework could also be used to create and maintain a Polis provider of any type (e.g. experimental, public, etc.). As a minimum, the framework maintains a local copy of all POLIS data needed. In the case that the framework is also used to maintain a POLIS provider, two independent data structures are created, and the provider is updated only when this is demanded in order to avoid configuration mismatches for the external clients of this Polis provider.

## Static data stored to the local file system

**Note:** If an entry is not marked by either `client` or `provider` it means that it is used in both cases (as most data structures are common to both client cache and provider data).

- .../(client/provider)root_path/... - Root path is the folder that contains all POLIS related data. In the case that the framework is also used to maintain a POLIS provider, two root paths (for the client and for the provider) are required.

## Dependancies 
In general we are trying to avoid dependancies to other projects. Why? We share the concerns of many other well respected developers on this subject. However, in the case of `swift-polis` we have decided to use software modules developed and maintained by members of our team. This guarantees that even in the case that the concrete author of the module abandons the project, someone from our team can take over the maintenance.
Current dependences include:
- [SoftwareEtudes](https://github.com/tuparev/SoftwareEtudes)
We use this package for the `SemanticVersion` type, that helps us manage POLIS versions.

### Random notes to be sorted later
**Note about RTML:** As often as possible types are similar to types defined by [RTML](http://www.astro.physik.uni-goettingen.de/~hessman/misc/RTML-3.2b.xsd)

**Note about testing:** The tests are only to test encoding and decoding different types from and to JSON and (later) to XML formatters.  For some types the implementation of `CustomStringConvertible` will be also tested in order to support easy debugging.

## Questions
- Should Owners be attached to Item only (possible repetitions and inconsistencies) or Item owned and Referenced (more complex implementation)?

## To Do
- General ToDo - make sure all examples have JSON data examples.
- Reimplement PolisReferences and its tests. We decided to start with, references will be only to Device Details
- Finish the implementation of the Manufacturer and back-index to shared device details. Manufacturers are referenced objects only (so no duplications)
- PolisDirection needs more documentation
- PolisCommunicationChannel needs Documentation and Tests
- PolisAddress needs Documentation and Tests
- PolisItem needs Documentation, Tests, and JSON examples.
- PolisOrganisation needs Documentation, Tests, and JSON examples
- In PolisMediaSource, correct the documentation so that it reflects the Image to Media Transition 
- Document, test, and create JSON examples for `PolisAdminContact`
- Document `PolisModeOfOperation`
- Document `PolisElectromagneticSpectrumCoverage`
- After everything else is finished, produce valid JSON schemas
