# Architectural Analysis: `swift-polis/app_support`

## Executive Summary

The current architecture in `swift-polis/app_support` has **several significant architectural issues** that need to be addressed. While the overall intent (separation of concerns, state management, coordination) is reasonable, the implementation has problems with:

1. **Unclear separation of responsibilities** between components
2. **Mixed concurrency models** causing thread-safety issues
3. **Tight coupling** through NotificationCenter
4. **Redundant abstraction layers**
5. **Inconsistent state management patterns**

---

## Current Architecture Overview

```
┌──────────────────────────────────────────────────────────────┐
│                    ObservingFacility                         │
│  (Domain Model - @Observable, PersistentObject)              │
│  - Creates itself via factory method                         │
│  - Posts NotificationCenter events                           │
└──────────────────────┬───────────────────────────────────────┘
                       │
                       │ NotificationCenter
                       │ (Loose Coupling)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              ObjetChangeDispatcher                          │
│  (Notification Handler)                                     │
│  - Listens to ObjectChange notifications                    │
│  - Forwards to ObjectStoreCoordinator                       │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ async call
                       ▼
┌─────────────────────────────────────────────────────────────┐
│           ObjectStoreCoordinator (Actor)                    │
│  - Thin wrapper around ObjectStore                          │
│  - @MainActor static (redundant)                            │
└──────────────────────┬──────────────────────────────────────┘
                       │
                       │ Direct call (thread-unsafe)
                       ▼
┌─────────────────────────────────────────────────────────────┐
│              ObjectStore (@Observable)                      │
│  - nonisolated(unsafe) shared instance                      │
│  - Stores observingFacilities array                         │
└─────────────────────────────────────────────────────────────┘
```

---

## Architectural Issues

### 🔴 **Critical Issues**

#### 1. **Unclear Separation of Concerns**

**Problem**: The responsibilities of `ObjectStore` and `ObjectStoreCoordinator` are blurred.

- `ObjectStoreCoordinator` is just a thin wrapper that calls `ObjectStore.shared` directly
- No clear benefit from having both layers
- The "Coordinator" pattern suggests orchestration, but it's just a pass-through

**Impact**: 
- Confusing for developers
- Makes testing harder
- Adds unnecessary indirection

**Recommendation**: 
- **Option A**: Remove `ObjectStoreCoordinator` and make `ObjectStore` handle coordination directly
- **Option B**: Make `ObjectStoreCoordinator` actually coordinate (handle transactions, validation, error recovery, etc.)

#### 2. **Mixed Concurrency Models**

**Problem**: The code mixes three different concurrency approaches:

1. `@Observable` (SwiftUI observation) - expects `@MainActor`
2. `actor` (structured concurrency) - isolated execution
3. `nonisolated(unsafe)` (unsafe global state) - no protection

**Current Flow**:
```
ObservingFacility (synchronous, any thread)
  → NotificationCenter (synchronous, any thread)
    → ObjetChangeDispatcher (@MainActor method)
      → Task { await ObjectStoreCoordinator (actor) }
        → ObjectStore.shared (nonisolated(unsafe), any thread) ❌
```

**Impact**: 
- Data races are possible
- Undefined behavior
- Hard to reason about thread safety

**Recommendation**: Choose ONE concurrency model:
- **For SwiftUI**: Use `@Observable` with `@MainActor` throughout
- **For concurrent access**: Use `actor` throughout (like the 6.2-experiment version)
- **For simple cases**: Use `@MainActor` class with proper synchronization

#### 3. **NotificationCenter as Primary Communication Channel**

**Problem**: Using NotificationCenter for core business logic creates:

- **Loose coupling that's too loose**: No compile-time guarantees
- **Hard to trace**: No clear call stack
- **Type safety issues**: Force casts required (`as! ObservingFacility`)
- **Testing difficulties**: Hard to mock or verify
- **Memory leaks**: Observer not removed

**Current Pattern**:
```swift
// In ObservingFacility
NotificationCenter.default.post(name: ..., object: change)

// In ObjetChangeDispatcher  
notification.object as! ObservingFacility  // ❌ Unsafe
```

**Impact**: 
- Runtime crashes possible
- Hard to debug
- No compile-time safety

**Recommendation**: 
- **Option A**: Use direct method calls with dependency injection
- **Option B**: Use a proper event bus/mediator pattern with type safety
- **Option C**: If keeping notifications, use strongly-typed notification payloads

#### 4. **Redundant Abstraction Layer**

**Problem**: `ObjectStoreCoordinator` adds no value:

```swift
// ObjectStoreCoordinator just calls ObjectStore directly
public func addObservingFacility(_ facility: ObservingFacility) { 
    ObjectStore.shared.addObservingFacility(facility) 
}
```

**Impact**: 
- Unnecessary complexity
- Confusion about which class to use
- Extra indirection with no benefit

**Recommendation**: Remove `ObjectStoreCoordinator` or give it real responsibilities (validation, transaction management, error handling, etc.)

---

### 🟡 **Medium Priority Issues**

#### 5. **Inconsistent State Management**

**Problem**: Mixing `@Observable` (reactive) with imperative patterns:

- `ObjectStore` is `@Observable` but accessed imperatively
- `ObservingFacility` is `@Observable` but created via factory method
- No clear reactive data flow

**Impact**: 
- SwiftUI views might not update correctly
- Unclear when state changes propagate

**Recommendation**: 
- If using `@Observable`, ensure all state changes go through the observable properties
- Consider using Combine or async sequences for reactive updates
- Document the reactive flow clearly

#### 6. **Factory Method in Domain Model**

**Problem**: `ObservingFacility.newObservingFacility()` is a factory method that:
- Creates the object
- Posts notifications
- Has incomplete implementation (TODO)

**Impact**: 
- Domain model knows about infrastructure (NotificationCenter)
- Hard to test
- Violates Single Responsibility Principle

**Recommendation**: 
- Move factory to a separate `ObservingFacilityFactory` or `ObjectStore` method
- Keep domain model pure
- Use dependency injection

#### 7. **Generic Type Confusion**

**Problem**: `PolisObjectRep<PolisObject>` where `PolisObject` is a protocol:

```swift
struct PolisObjectRep<PolisObject> {  // Protocol as generic parameter
    let polisObject: PolisObject
    // ...
}
```

**Impact**: 
- Type erasure issues
- Force casts required
- Unclear type relationships

**Recommendation**: 
- Use `any PolisObject` (existential) or associated types
- Consider enum-based approach for different object types
- Use type-safe wrappers

---

### 🟢 **Low Priority Issues**

#### 8. **Missing Error Handling**

- Force casts without error handling
- No validation in factory methods
- No error propagation

#### 9. **Incomplete Implementation**

- TODO comments
- Empty `update()` method
- Hardcoded values ("bla")

---

## Recommended Architecture

### **Option 1: SwiftUI-Optimized (Simple, Main Thread)**

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
    
    func reset() {
        _observingFacilities.removeAll()
    }
}

// Factory in ObjectStore
extension ObjectStore {
    public func createObservingFacility() -> ObservingFacility {
        let identity = PolisIdentity()
        let facilityReference = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
        let rep = PolisObjectRep(polisObject: facilityReference, localPath: "", objectType: .facility)
        let facility = ObservingFacility(polisRep: rep)
        
        addObservingFacility(facility)
        return facility
    }
}
```

**Pros**: Simple, thread-safe, SwiftUI-friendly  
**Cons**: All operations on main thread

---

### **Option 2: Actor-Based (Concurrent, Structured)**

```swift
public actor ObjectStore: Sendable {
    public static let shared = ObjectStore()
    
    private var _observingFacilities: [ObservingFacility] = []
    
    public var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    public func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
    
    public func createObservingFacility() async -> ObservingFacility {
        let identity = PolisIdentity()
        let facilityReference = PolisObservingFacilityDirectory.ObservingFacilityReference(identity: identity)
        let rep = PolisObjectRep(polisObject: facilityReference, localPath: "", objectType: .facility)
        let facility = ObservingFacility(polisRep: rep)
        
        addObservingFacility(facility)
        return facility
    }
}
```

**Pros**: Thread-safe, concurrent, modern Swift  
**Cons**: Requires async/await, more complex for SwiftUI

---

### **Option 3: Hybrid (Actor + Observable Wrapper)**

```swift
// Internal: Actor for thread safety
public actor ObjectStoreActor: Sendable {
    private var _observingFacilities: [ObservingFacility] = []
    
    func addObservingFacility(_ facility: ObservingFacility) {
        _observingFacilities.append(facility)
    }
    
    func observingFacilities() -> [ObservingFacility] {
        _observingFacilities
    }
}

// Public: Observable wrapper for SwiftUI
@MainActor
@Observable
public class ObjectStore {
    public static let shared = ObjectStore()
    
    private let actor = ObjectStoreActor()
    private var _observingFacilities: [ObservingFacility] = []
    
    public var observingFacilities: [ObservingFacility] {
        _observingFacilities
    }
    
    func addObservingFacility(_ facility: ObservingFacility) async {
        await actor.addObservingFacility(facility)
        await refresh()
    }
    
    private func refresh() async {
        _observingFacilities = await actor.observingFacilities()
    }
}
```

**Pros**: Best of both worlds  
**Cons**: More complex, requires sync mechanism

---

## Comparison with 6.2-experiment Version

The `6.2-experiment` version shows a more mature architecture:

✅ **Uses `actor` for ObjectStore** - proper thread safety  
✅ **Has proper error types** - `ObjectStoreError` enum  
✅ **Resource finders** - separation of concerns  
✅ **Configuration management** - proper initialization  
✅ **Lifecycle management** - `createLocalStore()`, `close()`  
✅ **Notification pattern** - but still uses NotificationCenter (could be improved)

**Recommendation**: Consider adopting patterns from `6.2-experiment` while addressing the NotificationCenter issues.

---

## Migration Path

### Phase 1: Fix Critical Issues
1. Remove or properly implement `ObjectStoreCoordinator`
2. Fix thread safety (choose one concurrency model)
3. Remove force casts, add proper error handling

### Phase 2: Improve Architecture
1. Remove NotificationCenter for core operations
2. Move factory methods to appropriate location
3. Fix generic types

### Phase 3: Enhance
1. Add proper error handling
2. Complete TODO implementations
3. Add documentation
4. Add tests

---

## Conclusion

**Current State**: ⚠️ **Needs Significant Improvement**

The architecture has good intentions but suffers from:
- Mixed concurrency models
- Unclear responsibilities
- Unsafe patterns (force casts, nonisolated(unsafe))
- Redundant abstractions

**Recommendation**: 
1. **Short term**: Fix thread safety and remove force casts
2. **Medium term**: Consolidate to one concurrency model and remove redundant layers
3. **Long term**: Consider adopting patterns from `6.2-experiment` version

The `6.2-experiment` version appears to be a more mature implementation that addresses many of these issues.
