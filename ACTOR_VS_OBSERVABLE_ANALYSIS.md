# Should Domain Models Be Actors? Analysis

## Current State

You have **two different approaches** in your codebase:

1. **Current `swift-polis/app_support`**: 
   - `@Observable open class ObservingFacility: PersistentObject`
   - Uses `@Observable` for SwiftUI integration

2. **`6.2-experiment` version**:
   - `public actor ObservingFacility: @preconcurrency Persisting`
   - `public actor Artifact: @preconcurrency Persisting`
   - Uses actors for thread safety

---

## Analysis: Actors vs Observable for Domain Models

### ❌ **Generally NOT Recommended: Making Domain Models Actors**

#### Problems with Actor Domain Models:

**1. SwiftUI Integration Issues**
```swift
// ❌ This doesn't work well with SwiftUI
actor ObservingFacility { ... }

// In SwiftUI view:
struct FacilityView: View {
    let facility: ObservingFacility  // Can't observe changes
    
    var body: some View {
        Text(await facility.name)  // ❌ Can't use await in View body
    }
}
```

**2. Collection and Iteration Problems**
```swift
// ❌ Very awkward
let facilities: [ObservingFacility] = await store.facilities()
for facility in facilities {
    let name = await facility.name  // Every access requires await
    // Can't use in ForEach easily
}
```

**3. Performance Overhead**
- Every property access requires async/await
- Actors serialize all access (even reads)
- Can't batch multiple property reads efficiently

**4. Testing Complexity**
```swift
// ❌ All tests become async
func testFacilityName() async {
    let facility = await createFacility()
    let name = await facility.name
    XCTAssertEqual(name, "Test")
}
```

**5. Value Semantics Lost**
- Actors are reference types
- Can't easily compare, copy, or use in Sets/Dictionaries
- Harder to reason about equality

---

### ✅ **Recommended: Value Types + Actor Store**

#### Better Architecture:

```swift
// ✅ Value type for domain model (immutable, thread-safe)
public struct ObservingFacility: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var identity: PolisIdentity
    // ... other properties
}

// ✅ Actor for the store (manages mutable state)
public actor ObjectStore {
    private var _facilities: [UUID: ObservingFacility] = [:]
    
    public func facility(id: UUID) -> ObservingFacility? {
        _facilities[id]
    }
    
    public func updateFacility(_ facility: ObservingFacility) {
        _facilities[facility.id] = facility
    }
}

// ✅ Observable wrapper for SwiftUI
@MainActor
@Observable
public class FacilityStore {
    private let actor = ObjectStore.shared
    private var _facilities: [ObservingFacility] = []
    
    public var facilities: [ObservingFacility] {
        _facilities
    }
    
    func refresh() async {
        _facilities = await actor.allFacilities()
    }
}
```

**Benefits**:
- ✅ Domain models are simple value types
- ✅ Thread-safe by design (immutable)
- ✅ Works perfectly with SwiftUI
- ✅ Easy to test
- ✅ Can use in collections, Sets, Dictionaries
- ✅ No async/await needed for property access

---

## Why 6.2-experiment Uses Actors

Looking at the `6.2-experiment` code, they use actors because:

1. **Persistence Operations**: They need async for I/O operations
   ```swift
   public func saveChanges() async throws { ... }
   public func loadData() async throws { ... }
   ```

2. **State Management**: They manage editing state
   ```swift
   public internal(set) var isEditing = false
   public func startEditing() async throws { ... }
   ```

3. **Coordination**: They coordinate with the store
   ```swift
   let store: ObjectStore
   try await store.addOrUpdateObservingFacilityDirectoryEntry(...)
   ```

**However**, this creates the problems mentioned above.

---

## Recommended Architecture

### **Option 1: Value Types + Actor Store (Best for Most Cases)**

```swift
// Domain Model: Pure value type
public struct ObservingFacility: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    public var identity: PolisIdentity
    // ... immutable properties
}

// Store: Actor for thread safety
public actor ObjectStore {
    private var _facilities: [UUID: ObservingFacility] = [:]
    
    public func facility(id: UUID) -> ObservingFacility? {
        _facilities[id]
    }
    
    public func saveFacility(_ facility: ObservingFacility) async throws {
        // Persistence logic here
        _facilities[facility.id] = facility
    }
}

// SwiftUI Integration: Observable wrapper
@MainActor
@Observable
public class FacilityStore {
    private let store = ObjectStore.shared
    private var _facilities: [ObservingFacility] = []
    
    public var facilities: [ObservingFacility] {
        _facilities
    }
    
    func loadFacilities() async {
        _facilities = await store.allFacilities()
    }
}
```

**Pros**:
- ✅ Clean separation of concerns
- ✅ Domain models are simple and testable
- ✅ Perfect SwiftUI integration
- ✅ Thread-safe
- ✅ Easy to reason about

**Cons**:
- Need to manage state updates manually
- Slightly more boilerplate

---

### **Option 2: Observable Classes + MainActor (Simpler, SwiftUI-Focused)**

```swift
// Domain Model: Observable class
@MainActor
@Observable
public class ObservingFacility: Identifiable {
    public let id: UUID
    public var name: String
    public var identity: PolisIdentity
    
    // Persistence operations
    func save() async throws {
        // Save to store
    }
}

// Store: Also MainActor
@MainActor
@Observable
public class ObjectStore {
    public var facilities: [ObservingFacility] = []
    
    func addFacility(_ facility: ObservingFacility) {
        facilities.append(facility)
    }
}
```

**Pros**:
- ✅ Very simple
- ✅ Perfect SwiftUI integration
- ✅ Automatic reactivity
- ✅ No async/await needed for property access

**Cons**:
- ⚠️ All operations on main thread
- ⚠️ Not suitable for heavy concurrent access

---

### **Option 3: Hybrid (Actor Store + Observable Models)**

```swift
// Domain Model: Observable for SwiftUI
@MainActor
@Observable
public class ObservingFacility: Identifiable {
    public let id: UUID
    public var name: String
    
    private let store: ObjectStore
    
    func save() async throws {
        // Sync to actor store
        await store.updateFacility(self.toValueType())
    }
    
    private func toValueType() -> ObservingFacilityValue {
        // Convert to value type for storage
    }
}

// Store: Actor for thread safety
public actor ObjectStore {
    private var _facilities: [UUID: ObservingFacilityValue] = [:]
    
    func updateFacility(_ facility: ObservingFacilityValue) {
        _facilities[facility.id] = facility
    }
}
```

**Pros**:
- ✅ SwiftUI-friendly models
- ✅ Thread-safe storage
- ✅ Can handle concurrent access

**Cons**:
- ⚠️ More complex
- ⚠️ Need to sync between Observable and Actor
- ⚠️ Potential for state drift

---

## Comparison Table

| Approach | SwiftUI | Thread Safety | Complexity | Performance | Recommended For |
|----------|---------|---------------|------------|-------------|-----------------|
| **Actor Domain Models** | ❌ Poor | ✅ Excellent | ⚠️ High | ⚠️ Overhead | Heavy concurrent I/O |
| **Value Types + Actor Store** | ✅ Excellent | ✅ Excellent | ✅ Low | ✅ Good | **Most cases** |
| **Observable + MainActor** | ✅ Excellent | ⚠️ Main thread only | ✅ Very Low | ✅ Good | SwiftUI apps |
| **Hybrid** | ✅ Good | ✅ Excellent | ⚠️ Medium | ⚠️ Medium | Complex apps |

---

## Specific Recommendation for Your Codebase

### **For `swift-polis/app_support` (Current Version)**

**Recommendation**: **Option 2 (Observable + MainActor)**

**Reasoning**:
1. You're already using `@Observable`
2. SwiftUI integration is likely important
3. Simpler is better for this use case
4. Main thread is fine for UI-driven operations

**Implementation**:
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

@MainActor
@Observable
open class ObservingFacility: PersistentObject {
    public let id: UUID
    public var name: String?
    // ... other properties
    
    func save() async throws {
        // Persistence logic
        ObjectStore.shared.addObservingFacility(self)
    }
}
```

### **For `6.2-experiment` (If You Need Concurrent Access)**

**Recommendation**: **Option 1 (Value Types + Actor Store)**

**Reasoning**:
1. You need concurrent access
2. You have complex persistence operations
3. Better separation of concerns

**Implementation**:
```swift
// Value type
public struct ObservingFacility: Identifiable, Codable, Sendable {
    public let id: UUID
    public var name: String
    // ... immutable properties
}

// Actor store
public actor ObjectStore {
    private var _facilities: [UUID: ObservingFacility] = [:]
    
    public func facility(id: UUID) -> ObservingFacility? {
        _facilities[id]
    }
    
    public func saveFacility(_ facility: ObservingFacility) async throws {
        // Persistence
        _facilities[facility.id] = facility
    }
}

// Observable wrapper for SwiftUI
@MainActor
@Observable
public class FacilityStore {
    private let store = ObjectStore.shared
    private var _facilities: [ObservingFacility] = []
    
    public var facilities: [ObservingFacility] {
        _facilities
    }
    
    func refresh() async {
        _facilities = await store.allFacilities()
    }
}
```

---

## Conclusion

**❌ Don't make domain models actors** unless you have a very specific need for:
- Heavy concurrent I/O operations
- Complex state coordination
- And you're willing to accept the SwiftUI integration challenges

**✅ Instead**:
- Use **value types** for domain models (immutable, thread-safe)
- Use **actors** for stores/repositories (mutable state management)
- Use **@Observable** wrappers for SwiftUI integration

This gives you:
- ✅ Thread safety
- ✅ SwiftUI compatibility
- ✅ Simple, testable code
- ✅ Good performance

The `6.2-experiment` approach with actor domain models works, but it's fighting against SwiftUI and creates unnecessary complexity. The value type + actor store approach is cleaner and more maintainable.
