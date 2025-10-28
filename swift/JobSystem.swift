import CJolt

public final class JobSystemThreadPool {
  public let raw: OpaquePointer?

  public init(
    maxJobs: UInt32 = UInt32(JoltDefaults.maxPhysicsJobs),
    maxBarriers: UInt32 = UInt32(JoltDefaults.maxPhysicsBarriers), numThreads: Int32 = -1
  ) {
    var config = JobSystemThreadPoolConfig(
      maxJobs: maxJobs, maxBarriers: maxBarriers, numThreads: numThreads)
    self.raw = JPH_JobSystemThreadPool_Create(&config)
  }

  deinit {
    if let raw {
      JPH_JobSystem_Destroy(raw)
    }
  }
}
