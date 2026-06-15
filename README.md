# `swift-polis` framework

## Programatically working with POLIS Service Provider

The main type to be used to manage a POLIS Service Provider is `ObjectStoreCoordinator`. This (actor) class could be use to work with the POLIS provider. No other types should be used to create, sync, or update Provider's data. `ObjectStoreCoordinator` is a singleton that could be always accessed like this:

```swift
   let coordinator = ObjectStoreCoordinator.share
```
   
Before using `ObjectStoreCoordinator`'s shared instance it is recommended to set few static variables of the class. One can set them later too, but this will cause a complete reset of the POLIS Object Store.

```swift
    ObjectStoreCoordinator.isBigBangServiceProvider = true // Should be yes in case this is the initial (primordial) Service Provider 

    // Configure the logger
    try await storeCoordinator.setLogFilePath("/tmp/astro/polis.log") // This should be set only on macOS! Default value is /tmp/polis.log
    logger = await storeCoordinator.logger()
    logger.info("Polis tool started")

    // Set the local polis root path
    do    { try await storeCoordinator.setPathToPolisFolder("/tmp/polis_root") }
    catch { logger.error("Cannot access POLIS Root Path!") }

    // Set the remote POLIS provider. 
    // THIS SHOULD NOT BE SET IN CASE A BIG BANG PROVIDER IS BEING CREATED!
    do    { try await storeCoordinator.setRemoteProvider(host: "https://polis.observer") }
    catch { logger.error("Cannot access POLIS Remote Host!") }
    
    logger.info("Polis tool configuration complete")
```


## Finalising version 0.2-beta
### `static_data_types`
- `PolisCommonTypes.swift`
- `PolisConstants.swift`
- `PolisDirection.swift`
- `PolisIdentity.swift`
- `PolisManufacturer.swift`
- `PolisMediaSource.swift`
- `PolisParty.swift`
- `PolisPropertyValue.swift`
- `PolisVisitingHours.swift`
