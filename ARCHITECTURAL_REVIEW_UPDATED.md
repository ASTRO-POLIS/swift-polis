# Architectural Review: Updated ObjectStoreCoordinator

## Overview

The `ObjectStoreCoordinator` has been significantly expanded with configuration management, file system operations, and resource finders. This is good progress, but there are still several architectural issues to address.

---

## ✅ **Improvements Made**

1. **Error Handling**: Added `ObjectStoreCoordinatorError` enum
2. **Configuration Management**: Added `setPathToPolisFolder()`, `setRemoteProvider()`, `createLocalStore()`
3. **Resource Finders**: Integration with `PolisFileResourceFinder` and `PolisRemoteResourceFinder`
4. **Logging**: Added logger integration
5. **File System Management**: Added folder creation and path management

---

## 🔴 **Critical Architectural Issues**

### 1. **Incorrect Actor Usage: @MainActor on Actor Static**

```swift
public actor ObjectStoreCoordinator {
    @MainActor public static let shared = ObjectStoreCoordinator()  // ❌ Problematic
}
```

**Problem**: 
- Actors are already isolated types
- `@MainActor` on an actor's static property is redundant and confusing
- Creates unnecessary main thread dependency

**Fix**:
```swift
public actor ObjectStoreCoordinator {
    public static let shared = ObjectStoreCoordinator()  // ✅ Correct
}
```

---

### 2. **Thread Safety Violation: Direct Access to nonisolated(unsafe) ObjectStore**

```swift
extension ObjectStoreCoordinator {
    public func addObservingFacility(_ facility: ObservingFacility) { 
        ObjectStore.shared.addObservingFacility(facility)  // ❌ Thread-unsafe
    }
}
```

**Problem**:
- `ObjectStore.shared` is `nonisolated(unsafe)`
- Actor method calling nonisolated code without synchronization
- Can cause data races

**Fix Options**:

**Option A**: Make ObjectStore thread-safe
```swift
@MainActor
@Observable
public class ObjectStore {
    public static let shared = ObjectStore()
    private var _observingFacilities: [ObservingFacility] = []
    
    public var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
}

// Then in coordinator:
extension ObjectStoreCoordinator {
    public func addObservingFacility(_ facility: ObservingFacility) async {
        await MainActor.run {
            ObjectStore.shared.addObservingFacility(facility)
        }
    }
}
```

**Option B**: Make ObjectStore an actor
```swift
public actor ObjectStore {
    public static let shared = ObjectStore()
    private var _observingFacilities: [ObservingFacility] = []
    
    func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
}

// Then in coordinator:
extension ObjectStoreCoordinator {
    public func addObservingFacility(_ facility: ObservingFacility) async {
        await ObjectStore.shared.addObservingFacility(facility)
    }
}
```

---

### 3. **Missing Property in ObjectStore**

```swift
// ObjectStore.swift
func reset() {
    _observingFacilities.removeAll()  // ❌ _observingFacilities not defined
}

func addObservingFacility(_ facility: ObservingFacility) { 
    _observingFacilities.append(facility)  // ❌ _observingFacilities not defined
}
```

**Fix**:
```swift
@Observable public class ObjectStore {
    private var _observingFacilities: [ObservingFacility] = []  // ✅ Add this
    
    public internal(set) var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    func reset() {
        _observingFacilities.removeAll()
    }
    
    func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
}
```

---

### 4. **Mixed Responsibilities: Coordinator Doing Too Much**

The `ObjectStoreCoordinator` is handling:
- ✅ Coordination (good)
- ❌ File system operations (should be in ObjectStore or separate service)
- ❌ Infrastructure setup (should be in ObjectStore or separate service)
- ❌ Path management (should be in ObjectStore or separate service)

**Problem**: Violates Single Responsibility Principle

**Recommended Structure**:

```swift
// ObjectStoreCoordinator: Only coordination
public actor ObjectStoreCoordinator {
    private let store: ObjectStore
    
    public func addObservingFacility(_ facility: ObservingFacility) async {
        await store.addObservingFacility(facility)
    }
    
    public func configureStore(path: String, remoteHost: String?) async throws {
        try await store.configure(path: path, remoteHost: remoteHost)
    }
}

// ObjectStore: Manages state and infrastructure
public actor ObjectStore {
    private var _facilities: [ObservingFacility] = []
    private var _fileResourceFinder: PolisFileResourceFinder?
    private var _remoteResourceFinder: PolisRemoteResourceFinder?
    
    func configure(path: String, remoteHost: String?) async throws {
        // Infrastructure setup here
    }
    
    func addObservingFacility(_ facility: ObservingFacility) {
        _facilities.append(facility)
    }
}
```

---

### 5. **Synchronous File Operations in Async Context**

```swift
public func setPathToPolisFolder(_ path: String) throws {  // ❌ Should be async
    if _fm.fileExists(atPath: path, isDirectory: &_isDir) && _isDir.boolValue {
        _pathToPolisFolder = path
        resetObjectStoreIfNeeded()
    }
}
```

**Problem**: File operations can block, should be async

**Fix**:
```swift
public func setPathToPolisFolder(_ path: String) async throws {
    var isDir: ObjCBool = false
    guard _fm.fileExists(atPath: path, isDirectory: &isDir) && isDir.boolValue else {
        throw ObjectStoreCoordinatorError.unaccessiblePath
    }
    _pathToPolisFolder = path
    await resetObjectStoreIfNeeded()
}
```

---

### 6. **Force Unwrapping and Implicit Optionals**

```swift
private var _pathToPolisFolder: String!  // ❌ Force unwrapping
private var _fileResourceFinder: PolisFileResourceFinder!  // ❌ Force unwrapping
```

**Problem**: Can crash at runtime

**Fix**:
```swift
private var _pathToPolisFolder: String?
private var _fileResourceFinder: PolisFileResourceFinder?

// Then check before use:
guard let path = _pathToPolisFolder else {
    throw ObjectStoreCoordinatorError.objectStoreNotConfigured
}
```

---

### 7. **Incomplete Error Handling**

```swift
public func setRemoteProvider(host: String, pathToPolisFolder: String? = nil) throws {
    //TODO: Implement me!  // ❌ Throws but doesn't implement
}
```

**Problem**: Method signature promises error handling but doesn't implement

**Fix**: Either implement or remove `throws`:
```swift
public func setRemoteProvider(host: String, pathToPolisFolder: String? = nil) async throws {
    // Validate host
    guard let hostURL = URL(string: host) else {
        throw ObjectStoreCoordinatorError.unaccessibleRemoteHost
    }
    
    // Create remote resource finder
    _remoteResourceFinder = try PolisRemoteResourceFinder(
        at: hostURL,
        supportedImplementation: PolisConstants().latestPolisFrameworkSupportedImplementation()
    )
    
    // Handle optional path
    if let path = pathToPolisFolder {
        try await setPathToPolisFolder(path)
    }
}
```

---

## 🟡 **Medium Priority Issues**

### 8. **Inconsistent Error Messages**

Some methods log errors, others throw. Should be consistent:

```swift
// In tryToEnsureFoldersExistence - logs but returns Bool
logger.error("Error: cannot access or create folder - \(error.localizedDescription)")
return false

// In createLocalInfrastructure - throws
guard let pathURL = URL(string: _pathToPolisFolder) else { 
    throw ObjectStoreCoordinatorError.unaccessiblePath 
}
```

**Recommendation**: Use Result types or consistent error handling pattern

---

### 9. **URL Creation from String**

```swift
guard let pathURL = URL(string: _pathToPolisFolder) else { 
    throw ObjectStoreCoordinatorError.unaccessiblePath 
}
```

**Problem**: `URL(string:)` is for URLs, not file paths. Use `URL(fileURLWithPath:)` for file paths.

**Fix**:
```swift
let pathURL = URL(fileURLWithPath: _pathToPolisFolder)
guard _fm.fileExists(atPath: pathURL.path) else {
    throw ObjectStoreCoordinatorError.unaccessiblePath
}
```

---

### 10. **Missing Async/Await in Some Operations**

```swift
private func resetObjectStoreIfNeeded() {
    //TODO: Implement me!
}
```

If this needs to interact with ObjectStore, it should be async.

---

## 🟢 **Low Priority / Code Quality**

### 11. **Magic Strings and Hardcoded Values**

Consider extracting constants:
- `"test.polis.observer"` (subsystem name)
- Temporary folder paths

### 12. **Documentation**

Add documentation for public APIs:
```swift
/// Sets the local path where POLIS data will be stored
/// - Parameter path: File system path to the POLIS folder
/// - Throws: `ObjectStoreCoordinatorError.unaccessiblePath` if path doesn't exist or isn't a directory
public func setPathToPolisFolder(_ path: String) async throws
```

---

## 📋 **Recommended Refactoring**

### **Phase 1: Fix Critical Issues**

1. Remove `@MainActor` from actor static property
2. Fix thread safety between ObjectStoreCoordinator and ObjectStore
3. Add missing `_observingFacilities` property
4. Make file operations async

### **Phase 2: Improve Architecture**

1. Separate responsibilities:
   - `ObjectStoreCoordinator`: Coordination only
   - `ObjectStore`: State management and infrastructure
   - Consider `ObjectStoreConfiguration`: Configuration management

2. Fix error handling consistency

3. Replace force unwrapping with optionals

### **Phase 3: Enhance**

1. Add comprehensive documentation
2. Extract constants
3. Add unit tests
4. Complete TODO implementations

---

## 🎯 **Recommended Architecture**

```swift
// 1. ObjectStore: Manages state and infrastructure
@MainActor
@Observable
public class ObjectStore {
    public static let shared = ObjectStore()
    
    private var _observingFacilities: [ObservingFacility] = []
    private var _fileResourceFinder: PolisFileResourceFinder?
    private var _remoteResourceFinder: PolisRemoteResourceFinder?
    
    public var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    // Infrastructure
    func configure(path: String, remoteHost: String?) async throws {
        // Setup file and remote resource finders
    }
    
    // State management
    func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
    
    func reset() {
        _observingFacilities.removeAll()
    }
}

// 2. ObjectStoreCoordinator: Coordinates operations
public actor ObjectStoreCoordinator {
    public static let shared = ObjectStoreCoordinator()
    
    private let store = ObjectStore.shared
    private let logger: Logging.Logger
    
    public init() {
        PolisLogger.setup(subsystem: "test.polis.observer", level: .info)
        self.logger = PolisLogger.logger()
    }
    
    // Configuration
    public func configure(path: String, remoteHost: String?) async throws {
        try await store.configure(path: path, remoteHost: remoteHost)
    }
    
    // Coordination
    public func addObservingFacility(_ facility: ObservingFacility) async {
        await store.addObservingFacility(facility)
    }
    
    public func createLocalStore(moveExistingStore: Bool = false) async throws {
        // Coordinate store creation
        try await store.createLocalStore(moveExisting: moveExistingStore)
    }
}
```

---

## Summary

**Current State**: ⚠️ **Better, but still needs work**

**Key Issues**:
1. ❌ Thread safety violations
2. ❌ Incorrect actor usage
3. ❌ Missing properties
4. ❌ Mixed responsibilities
5. ⚠️ Incomplete implementations

**Priority**: Fix thread safety and missing properties first, then refactor responsibilities.
