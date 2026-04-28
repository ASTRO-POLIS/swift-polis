# Improvement Suggestions for `swift-polis/app_support`

## Overview
This document outlines code quality, safety, and design improvements for files in the `swift-polis/app_support` directory.

---

## 1. ObjectStore.swift

### Issues Found:
1. **Missing Property**: `_observingFacilities` is referenced but never declared
2. **Thread Safety**: `nonisolated(unsafe)` with `@Observable` can cause data races
3. **Inconsistent Property Access**: Public `observingFacilities` but private `_observingFacilities` usage

### Suggested Improvements:

```swift
@Observable public class ObjectStore {
    // Use MainActor for thread safety instead of nonisolated(unsafe)
    @MainActor public static let shared = ObjectStore()
    
    // Make the backing storage private
    private var _observingFacilities: [ObservingFacility] = []
    
    // Expose as computed property or use proper synchronization
    public var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    //MARK: - Internal APIs
    @MainActor func reset() {
        _observingFacilities.removeAll()
    }
    
    //MARK: - Private APIs
    @MainActor func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
}
```

**Alternative Approach** (if you need concurrent access):
- Use an actor for ObjectStore instead of @Observable
- Or use a serial queue for synchronization

---

## 2. ObjectStoreCoordinator.swift

### Issues Found:
1. **Incorrect Actor Usage**: `@MainActor` on an actor's static property is redundant and confusing
2. **Thread Safety Violation**: Calling `ObjectStore.shared.addObservingFacility` from an actor method without ensuring thread safety

### Suggested Improvements:

```swift
public actor ObjectStoreCoordinator {
    // Remove @MainActor - actors are already isolated
    public static let shared = ObjectStoreCoordinator()
    
    // Ensure ObjectStore operations are thread-safe
    public func addObservingFacility(_ facility: ObservingFacility) async {
        await MainActor.run {
            ObjectStore.shared.addObservingFacility(facility)
        }
    }
}
```

**Better Approach**: Make ObjectStore thread-safe or use proper synchronization primitives.

---

## 3. ObservingFacility.swift

### Issues Found:
1. **Unsafe Force Cast**: `as! PolisObjectRep` can crash at runtime
2. **Incomplete Implementation**: TODO comment and empty `update()` method
3. **Unchecked Sendable**: Using `@unchecked Sendable` indicates potential thread-safety issues

### Suggested Improvements:

```swift
@Observable open class ObservingFacility: PersistentObject, Sendable {
    
    public static func newObservingFacility() -> ObservingFacility {
        let identity = PolisIdentity()
        let facilityReference = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
        
        // Use proper initialization instead of force cast
        let rep = PolisObjectRep(
            polisObject: facilityReference,
            localPath: "", // Consider using proper path
            objectType: .facility
        )
        
        let facility = ObservingFacility(polisRep: rep)
        let change = ObjectChange(
            changeType: .newObject,
            changeSource: .user,
            object: facility
        )
        
        NotificationCenter.default.post(
            name: AppSupportStatusChangeNotification.ObjectChangeNotification,
            object: change
        )
        
        // TODO: Implement proper initialization logic
        // Consider: await ObjectStoreCoordinator.shared.addObservingFacility(facility)
        
        return facility
    }
    
    // Implement or remove if not needed
    func update() {
        // Implementation needed
    }
}
```

**Additional Suggestions**:
- Make `update()` async if it needs to perform async operations
- Consider making this a factory method that returns an optional or throws
- Add proper error handling

---

## 4. PolisObjectRep.swift

### Issues Found:
1. **Typo**: `ObjetChangeDispatcher` should be `ObjectChangeDispatcher`
2. **Multiple Force Casts**: Unsafe casts that can crash
3. **Hardcoded Values**: "bla" string in initialization
4. **Generic Type Confusion**: `PolisObjectRep<PolisObject>` where `PolisObject` is a protocol, not a concrete type
5. **Access Control**: Enums should have explicit access levels
6. **Memory Leak**: Notification observer never removed
7. **Unchecked Sendable**: Indicates potential thread-safety issues

### Suggested Improvements:

```swift
// Fix typo
public class ObjectChangeDispatcher {
    private var observer: NSObjectProtocol?
    
    init() {
        observer = NotificationCenter.default.addObserver(
            forName: AppSupportStatusChangeNotification.ObjectChangeNotification,
            object: nil,
            queue: .main
        ) { [weak self] notification in
            Task {
                await self?.handleNotification(notification)
            }
        }
    }
    
    deinit {
        if let observer = observer {
            NotificationCenter.default.removeObserver(observer)
        }
    }
    
    @MainActor private func handleNotification(_ notification: Notification) async {
        guard let change = notification.object as? ObjectChange,
              let facility = change.object as? ObservingFacility else {
            // Log error or handle gracefully
            return
        }
        await ObjectStoreCoordinator.shared.addObservingFacility(facility)
    }
}

// Fix access control
public enum PolisObjectType: Sendable {
    case facility
    case facilityDetail
}

public enum ChangeInitiationSource: Sendable {
    case user
    case backend
}

public enum ChangeType: Sendable {
    case newObject
    case updateObject
    case deleteObject
}

public struct ObjectChange: Sendable {
    let changeType: ChangeType
    let changeSource: ChangeInitiationSource
    let object: PersistentObject
}

// Fix generic type - use a protocol constraint
public struct PolisObjectRep<PolisObject: PolisObjectProtocol>: Sendable {
    let polisObject: PolisObject
    let localPath: String
    let objectType: PolisObjectType
}

// Fix PersistentObject initialisation
open class PersistentObject: @unchecked Sendable {
    var polisRep: PolisObjectRep<any PolisObjectProtocol>
    
    init(polisRep: PolisObjectRep<any PolisObjectProtocol>) {
        self.polisRep = polisRep
    }
}
```

**Alternative for PolisObjectRep**:
If you need to store different types, consider using an enum or protocol-based approach:

```swift
public enum PolisObjectRep: Sendable {
    case facility(PolisObservingFacilityDirectory.ObservingFacilityReference)
    case facilityDetail(/* appropriate type */)
    
    var localPath: String {
        // Return appropriate path
    }
    
    var objectType: PolisObjectType {
        switch self {
        case .facility: return .facility
        case .facilityDetail: return .facilityDetail
        }
    }
}
```

---

## Summary of Critical Issues

### High Priority:
1. ✅ **Missing `_observingFacilities` property** in ObjectStore.swift
2. ✅ **Thread safety violations** across multiple files
3. ✅ **Force casts** that can cause runtime crashes
4. ✅ **Memory leak** in ObjetChangeDispatcher (missing observer removal)

### Medium Priority:
1. ⚠️ **Typo** in class name (`ObjetChangeDispatcher`)
2. ⚠️ **Hardcoded values** ("bla" string)
3. ⚠️ **Incomplete implementations** (TODO, empty methods)
4. ⚠️ **Access control** issues (missing public/internal modifiers)

### Low Priority:
1. 📝 **Code organization** (consider splitting large files)
2. 📝 **Documentation** (add doc comments for public APIs)
3. 📝 **Error handling** (add proper error handling instead of force casts)

---

## Recommended Refactoring Order

1. Fix the missing `_observingFacilities` property (blocks compilation)
2. Fix the typo (`ObjetChangeDispatcher`)
3. Remove force casts and add proper error handling
4. Fix thread safety issues
5. Fix memory leak in notification observer
6. Improve access control
7. Complete TODO implementations
8. Add documentation

---

## Testing Recommendations

After implementing these changes:
1. Add unit tests for thread safety
2. Test notification handling and cleanup
3. Test error cases (invalid casts, nil values)
4. Test concurrent access to ObjectStore
