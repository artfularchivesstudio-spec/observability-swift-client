# 🔄 Fixing Retain Cycles: The deinit + Task Problem

**A Comprehensive Guide to Memory Management in Swift**

---

## 📋 Table of Contents

1. [The Problem](#the-problem)
2. [Understanding Retain Cycles](#understanding-retain-cycles)
3. [Why deinit + Task is Dangerous](#why-deinit--task-is-dangerous)
4. [The Solution](#the-solution)
5. [Best Practices](#best-practices)
6. [Common Mistakes](#common-mistakes)
7. [Interview Takeaways](#interview-takeaways)

---

## 🚨 The Problem

### Original Problematic Code

```swift
public final class WebSocketCombineClient: ObservableObject {
    private var task: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?
    private var pingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        pingTimer?.invalidate()
        // ❌ PROBLEM: This creates a retain cycle!
        Task { @MainActor in
            self.disconnect()  // Captures 'self' strongly
        }
    }
    
    public func disconnect() {
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
        connectionState = .disconnected
        isConnected = false
        cancellables.removeAll()
    }
}
```

### The Error Message

```
Object 0x706ced900 of class WebSocketCombineClient deallocated 
with non-zero retain count 2. This object's deinit, or something 
called from it, may have created a strong reference to self which 
outlived deinit, resulting in a dangling reference.
```

---

## 🧠 Understanding Retain Cycles

### What is a Retain Cycle?

A **retain cycle** (also called a **reference cycle**) occurs when two or more objects hold strong references to each other, creating a circular dependency that prevents automatic memory deallocation.

```
┌─────────────┐         ┌─────────────┐
│  Object A   │────────>│  Object B   │
│             │<────────│             │
└─────────────┘         └─────────────┘
     ▲                         ▲
     │                         │
     └─────────────────────────┘
        Strong References
```

**Neither object can be deallocated** because each is kept alive by the other's reference.

### Swift's Reference Counting

Swift uses **Automatic Reference Counting (ARC)** to manage memory:

- **Strong Reference**: Increments retain count, prevents deallocation
- **Weak Reference**: Doesn't increment retain count, becomes `nil` when object deallocates
- **Unowned Reference**: Doesn't increment retain count, assumes object exists

```swift
class MyClass {
    var other: MyClass?  // Strong reference
    weak var weakOther: MyClass?  // Weak reference
    unowned var unownedOther: MyClass  // Unowned reference
}
```

---

## ⚠️ Why deinit + Task is Dangerous

### The Lifecycle Problem

When `deinit` is called, the object is **about to be deallocated**. Creating a `Task` that captures `self` creates a strong reference, preventing deallocation:

```swift
deinit {
    // Time 0: Object is at retain count = 1 (about to be deallocated)
    
    Task { @MainActor in
        self.disconnect()  // Time 1: Task captures 'self' strongly
        // Now retain count = 2!
    }
    
    // Time 2: deinit returns, but object CAN'T be deallocated
    // because Task still holds a strong reference!
}
```

### Visual Timeline

```
Time 0: Object created (retain count = 1)
Time 1: Some code holds reference (retain count = 2)
Time 2: Reference released (retain count = 1)
Time 3: Last reference released → deinit called
Time 4: deinit creates Task { self.disconnect() } → retain count = 2
Time 5: deinit returns → object SHOULD be deallocated
Time 6: ❌ CAN'T deallocate! Task still holds reference
Time 7: Task eventually completes → retain count = 1
Time 8: Object finally deallocated (too late!)
```

### Why This Causes the Warning

The warning indicates:
- The object was deallocated while still referenced (retain count = 2)
- The `Task` closure held a strong reference
- When `deinit` finished, the object was freed, but the `Task` still referenced it
- This creates a **dangling pointer** - a reference to deallocated memory

---

## ✅ The Solution

### Fixed Code

```swift
public final class WebSocketCombineClient: ObservableObject {
    private var task: URLSessionWebSocketTask?
    private var receiveTask: Task<Void, Never>?  // Track for cleanup
    private var pingTimer: Timer?
    private var cancellables = Set<AnyCancellable>()
    
    deinit {
        // ✅ Synchronous cleanup - no Task, no retain cycle
        
        // 1. Stop timer immediately
        pingTimer?.invalidate()
        pingTimer = nil
        
        // 2. Cancel WebSocket task synchronously
        task?.cancel(with: .goingAway, reason: nil)
        task = nil
        
        // 3. Cancel receiving task synchronously
        receiveTask?.cancel()
        receiveTask = nil
        
        // 4. Clear Combine subscriptions
        cancellables.removeAll()
        
        // deinit returns → object can be deallocated immediately
    }
    
    public func disconnect() {
        // ✅ Cancel receive task FIRST
        receiveTask?.cancel()
        receiveTask = nil
        
        // Then cancel WebSocket task
        task?.cancel(with: .normalClosure, reason: nil)
        task = nil
        
        // Update state
        connectionState = .disconnected
        isConnected = false
        
        // Clear subscriptions
        cancellables.removeAll()
        
        // Send disconnection event
        eventSubject.send(disconnectEvent)
    }
}
```

### Why This Works

1. **No async work in deinit**: All cleanup is synchronous, so no `Task` captures `self`
2. **Proper resource cleanup**: Timers, tasks, and subscriptions are cancelled before deallocation
3. **No retain cycle**: Nothing keeps `self` alive after `deinit` returns

---

## 🎯 Additional Improvements

### 1. Track Async Tasks

```swift
private var receiveTask: Task<Void, Never>?  // Track for cleanup

private func startReceiving() {
    guard let task = task else { return }
    
    // ✅ Use [weak self] to avoid retain cycle
    receiveTask = Task { [weak self] in
        guard let self = self else { return }  // Early exit if deallocated
        
        do {
            for try await message in task.messages {
                if Task.isCancelled { break }  // Check cancellation
                await MainActor.run {
                    self.handleMessage(message)
                }
            }
        } catch {
            if !Task.isCancelled {
                await self.handleError(error)
            }
        }
    }
}
```

**Benefits:**
- `[weak self]` avoids retain cycle
- Early exit if object is deallocated
- Cancellation checks prevent work after deallocation

### 2. Improved Disconnect Method

```swift
public func disconnect() {
    // ✅ Cancel receive task FIRST
    receiveTask?.cancel()
    receiveTask = nil
    
    // Then cancel WebSocket task
    task?.cancel(with: .normalClosure, reason: nil)
    task = nil
    
    // Update state
    connectionState = .disconnected
    isConnected = false
    
    // Clear subscriptions
    cancellables.removeAll()
    
    // Send disconnection event
    eventSubject.send(disconnectEvent)
}
```

### 3. Timer Cleanup

```swift
private func setupPingTimer() {
    pingTimer = Timer.scheduledTimer(withTimeInterval: 30.0, repeats: true) { [weak self] timer in
        guard let self = self else {
            timer.invalidate()  // ✅ Self-cleanup if object deallocated
            return
        }
        Task { @MainActor [weak self] in
            await self?.sendPing()
        }
    }
}
```

---

## 📚 Best Practices

### 1. Never Create Async Work in deinit

```swift
// ❌ BAD
deinit {
    Task { self.cleanup() }  // Retain cycle!
}

// ✅ GOOD
deinit {
    cleanup()  // Synchronous only
}
```

### 2. Use Weak Self in Closures

```swift
// ❌ BAD
Task {
    self.doSomething()  // Strong capture
}

// ✅ GOOD
Task { [weak self] in
    guard let self = self else { return }
    self.doSomething()
}
```

### 3. Track Async Tasks for Cleanup

```swift
private var myTask: Task<Void, Never>?

func startWork() {
    myTask = Task { [weak self] in
        // ... work
    }
}

func stopWork() {
    myTask?.cancel()
    myTask = nil
}

deinit {
    myTask?.cancel()  // Clean up tracked tasks
    myTask = nil
}
```

### 4. Clean Up Resources Synchronously

```swift
deinit {
    // ✅ All synchronous cleanup
    timer?.invalidate()
    task?.cancel()
    cancellables.removeAll()
    // No async work!
}
```

### 5. Order Matters: Cancel Before Cleanup

```swift
deinit {
    // ✅ Cancel tasks FIRST
    receiveTask?.cancel()
    task?.cancel()
    
    // Then clear references
    receiveTask = nil
    task = nil
    
    // Finally clear collections
    cancellables.removeAll()
}
```

---

## 🐛 Common Mistakes

### Mistake 1: Creating Task in deinit

```swift
// ❌ WRONG
deinit {
    Task { @MainActor in
        self.cleanup()
    }
}

// ✅ CORRECT
deinit {
    cleanup()  // Synchronous
}
```

### Mistake 2: Forgetting Weak Self

```swift
// ❌ WRONG
Task {
    self.processData()
}

// ✅ CORRECT
Task { [weak self] in
    guard let self = self else { return }
    self.processData()
}
```

### Mistake 3: Not Tracking Async Tasks

```swift
// ❌ WRONG
func startWork() {
    Task { [weak self] in
        // Can't cancel this!
    }
}

// ✅ CORRECT
private var workTask: Task<Void, Never>?

func startWork() {
    workTask = Task { [weak self] in
        // Can cancel via workTask?.cancel()
    }
}

deinit {
    workTask?.cancel()
}
```

### Mistake 4: Mixing Async and Sync Cleanup

```swift
// ❌ WRONG
deinit {
    Task { await self.asyncCleanup() }
    syncCleanup()  // Might run before async completes
}

// ✅ CORRECT
deinit {
    syncCleanup()  // All synchronous
    // asyncCleanup should be called before deinit
}
```

---

## 💡 Interview Takeaways

### Key Concepts

1. **Retain cycles prevent deallocation**: Strong references between objects keep them alive
2. **deinit must be synchronous**: Creating async work (like `Task`) can capture `self` and prevent deallocation
3. **Use weak references**: `[weak self]` in closures avoids retain cycles
4. **Track async tasks**: Store tasks so they can be cancelled during cleanup
5. **Clean up resources**: Cancel timers, tasks, and subscriptions before deallocation

### Memory Management Checklist

- [ ] All cleanup in `deinit` is synchronous
- [ ] Closures use `[weak self]` when appropriate
- [ ] Async tasks are tracked for cancellation
- [ ] Resources are cleaned up in proper order
- [ ] No `Task` creation in `deinit`
- [ ] Timers invalidate themselves if object deallocates
- [ ] Combine subscriptions are stored and cancelled

### Debugging Tips

1. **Use Instruments**: Run "Leaks" and "Allocations" instruments to find retain cycles
2. **Check retain counts**: Use `CFGetRetainCount()` in debug builds (not in production)
3. **Look for warnings**: Xcode's static analyzer catches many retain cycle issues
4. **Test deallocation**: Verify objects deallocate when expected
5. **Use weak breakpoints**: Set breakpoints on `deinit` to verify cleanup

---

## 🔍 Real-World Example

### Before (Problematic)

```swift
class NetworkManager {
    private var task: URLSessionDataTask?
    private var timer: Timer?
    
    deinit {
        // ❌ Creates retain cycle
        Task { @MainActor in
            self.task?.cancel()
            self.timer?.invalidate()
        }
    }
    
    func start() {
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { _ in
            // ❌ Strong capture of self
            self.fetchData()
        }
    }
}
```

### After (Fixed)

```swift
class NetworkManager {
    private var task: URLSessionDataTask?
    private var timer: Timer?
    private var fetchTask: Task<Void, Never>?
    
    deinit {
        // ✅ Synchronous cleanup
        timer?.invalidate()
        timer = nil
        task?.cancel()
        task = nil
        fetchTask?.cancel()
        fetchTask = nil
    }
    
    func start() {
        // ✅ Weak self in timer
        timer = Timer.scheduledTimer(withTimeInterval: 5.0, repeats: true) { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }
            self.fetchTask = Task { [weak self] in
                await self?.fetchData()
            }
        }
    }
    
    func stop() {
        timer?.invalidate()
        timer = nil
        fetchTask?.cancel()
        fetchTask = nil
    }
}
```

---

## 📖 Further Reading

- [Swift Memory Management](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/)
- [Task Cancellation](https://developer.apple.com/documentation/swift/task/cancel())
- [Weak References](https://docs.swift.org/swift-book/documentation/the-swift-programming-language/automaticreferencecounting/#Weak-References)
- [Combine Memory Management](https://developer.apple.com/documentation/combine)

---

## 🎓 Summary

**The Golden Rule**: `deinit` must be **synchronous**. Never create async work (like `Task`) in `deinit` because it will capture `self` strongly and prevent deallocation.

**The Solution**: 
1. Keep all cleanup synchronous
2. Use `[weak self]` in closures
3. Track async tasks for cancellation
4. Clean up resources before deallocation

**The Result**: Proper memory management, no retain cycles, and predictable object lifecycle.

---

*This document is part of the Observability Swift Client project documentation.*
