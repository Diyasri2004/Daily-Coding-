// LEARNING OBJECTIVE: Understand how to use NetServiceBrowser to discover Bonjour services on your local network.
// This tutorial will teach you the fundamentals of initiating a service search,
// receiving notifications when services are found or removed, and handling basic errors.
// Bonjour (also known as mDNS/DNS-SD) allows devices to find each other on a local network
// without manual configuration. NetServiceBrowser is Swift's way of interacting with this system.

import Foundation // Foundation framework provides NetServiceBrowser and related classes.

// MARK: - BonjourServiceBrowser Class Definition

/// A helper class to browse and display available Bonjour services on the local network.
/// It acts as the delegate for NetServiceBrowser to receive service discovery updates.
class BonjourServiceBrowser: NSObject, NetServiceBrowserDelegate {

    // This is the core object responsible for scanning the network for services.
    // We declare it as an optional because it might not be initialized immediately.
    private var browser: NetServiceBrowser?

    // A closure (a block of code) that will be called whenever a service is found or removed.
    // This provides a flexible way for other parts of your app to react to service updates.
    // It takes the service name, type, domain, and an enum indicating if it was added or removed.
    var onServiceUpdate: ((String, String, String, ServiceUpdateType) -> Void)?

    /// An enumeration to clearly indicate whether a service was added or removed.
    enum ServiceUpdateType {
        case added
        case removed
    }

    /// Initializes a new BonjourServiceBrowser.
    override init() {
        super.init() // Call the superclass initializer.
    }

    /// Starts browsing for services of a specific type within a given domain.
    /// - Parameters:
    ///   - serviceType: The type of service to search for (e.g., "_http._tcp", "_ipp._tcp").
    ///                  The format is "_<service>._<protocol>.", where protocol is usually "_tcp" or "_udp".
    ///                  The trailing dot is important for many service types.
    ///   - domain: The network domain to search in. Use "local." for the local network.
    ///             You can also specify specific domains if known, but "local." is common for Bonjour.
    func startBrowsing(serviceType: String, domain: String) {
        // First, stop any existing browser to ensure a clean start if this method is called multiple times.
        stopBrowsing()

        // Initialize NetServiceBrowser.
        // It's important to keep a strong reference to the browser, otherwise it might be deallocated
        // and stop searching prematurely.
        browser = NetServiceBrowser()

        // Set the delegate. This tells the browser which object will receive its updates.
        // `self` refers to the current instance of BonjourServiceBrowser.
        browser?.delegate = self

        // Begin the search for services.
        // This is where the actual network scanning starts.
        print("Starting Bonjour service browser for type: \(serviceType) in domain: \(domain)")
        browser?.searchForServices(ofType: serviceType, inDomain: domain)
    }

    /// Stops the current service browsing operation.
    /// This frees up network resources and stops receiving updates.
    func stopBrowsing() {
        // If a browser exists, tell it to stop searching.
        browser?.stop()
        // Clear the browser reference to release resources and signal it's no longer active.
        browser = nil
        print("Bonjour service browser stopped.")
    }

    // MARK: - NetServiceBrowserDelegate Methods

    /// Called when the browser is about to start searching for services.
    /// This is an informational callback, useful for logging or updating UI.
    func netServiceBrowserWillSearch(_ browser: NetServiceBrowser) {
        print("NetServiceBrowser will begin searching...")
    }

    /// Called when the browser has successfully found a new service.
    /// - Parameters:
    ///   - browser: The service browser that found the service.
    ///   - service: An instance of NetService representing the newly found service.
    ///              This object contains details like name, type, and domain.
    ///   - moreComing: A boolean indicating if more services are expected soon.
    ///                 Useful for optimizing UI updates (e.g., only reload table view once moreComing is false).
    func netServiceBrowser(_ browser: NetServiceBrowser, didFind service: NetService, moreComing: Bool) {
        // When a service is found, we typically want to know its name.
        // We also pass its type and domain for complete context.
        print("Found service: \(service.name) of type \(service.type) in domain \(service.domain)")

        // Call our custom update handler with the details.
        // We use the optional chaining `?` because `onServiceUpdate` might be nil if not set.
        onServiceUpdate?(service.name, service.type, service.domain, .added)

        // If you wanted to resolve the service (get its host and port),
        // you would typically create another NetService instance here and set its delegate
        // to handle resolution. This is a separate, more advanced step not covered in this
        // basic browsing tutorial to keep focus.
    }

    /// Called when a previously found service is no longer available.
    /// - Parameters:
    ///   - browser: The service browser that detected the service removal.
    ///   - service: An instance of NetService representing the service that disappeared.
    ///   - moreComing: A boolean indicating if more services are expected to be removed soon.
    func netServiceBrowser(_ browser: NetServiceBrowser, didRemove service: NetService, moreComing: Bool) {
        print("Removed service: \(service.name) of type \(service.type) in domain \(service.domain)")
        onServiceUpdate?(service.name, service.type, service.domain, .removed)
    }

    /// Called if the browser encounters an error during its search operation.
    /// This is crucial for debugging and handling network issues gracefully.
    /// - Parameters:
    ///   - browser: The service browser that encountered the error.
    ///   - errorDict: A dictionary containing error details (e.g., `NetService.errorCode`).
    func netServiceBrowser(_ browser: NetServiceBrowser, didNotSearch errorDict: [String : NSNumber]) {
        // Convert the error dictionary into a readable format.
        // NetService.errorCode is a common key to find the specific error code.
        let errorCode = errorDict[NetService.errorCode]?.intValue ?? -1
        print("NetServiceBrowser failed to search: Error Code \(errorCode)")
        // You might want to notify the user or attempt to restart the browser here.
    }

    /// Called when the browser has stopped searching for services, either because `stop()` was called
    /// or an error occurred that halted the search.
    func netServiceBrowserDidStopSearch(_ browser: NetServiceBrowser) {
        print("NetServiceBrowser stopped searching.")
    }
}

// MARK: - Example Usage

// To make this code runnable in a playground or a simple console application,
// we need to keep our `BonjourServiceBrowser` instance alive.
// A common way is to use a `RunLoop` or just hold a strong reference.

// Create an instance of our browser.
let browser = BonjourServiceBrowser()

// Define the service type and domain you want to browse for.
// Common types include:
// - "_http._tcp.": Web servers (often ports 80/443)
// - "_ipp._tcp.": Printers (Internet Printing Protocol)
// - "_ssh._tcp.": Secure Shell servers
// - "_ftp._tcp.": FTP servers
// - "_afp._tcp.": Apple File Protocol servers
// You can discover services running on your own machine or local network.
let myServiceType = "_http._tcp." // Example: Browse for HTTP services
let myServiceDomain = "local."   // Always use "local." for Bonjour on your local network

// Set up the closure to handle service updates.
// This is where you would update your UI (e.g., a table view) or log the findings.
browser.onServiceUpdate = { name, type, domain, updateType in
    switch updateType {
    case .added:
        print("✅ NEW SERVICE: \(name) (\(type) in \(domain))")
    case .removed:
        print("❌ SERVICE GONE: \(name) (\(type) in \(domain))")
    }
}

// Start the browsing process.
browser.startBrowsing(serviceType: myServiceType, domain: myServiceDomain)

// Keep the program running for a bit to allow the browser to find services.
// In a real app, the `browser` instance would be managed by a view controller
// or an app delegate, and would stay alive as long as needed.
// For a console application or playground, we use a RunLoop to simulate this.
// `RunLoop.current.run()` will block the main thread and keep the program alive
// until we manually stop it or a certain condition is met.
// We'll run it for 10 seconds to give it time to find services.

print("\nBrowsing for services for 10 seconds. Look for messages above...")
RunLoop.current.run(mode: .default, before: Date(timeIntervalSinceNow: 10))

// After 10 seconds, stop the browsing.
browser.stopBrowsing()
print("\nBonjour browsing example finished.")

// To test this, you might need to have some Bonjour services running on your network.
// For example, if you have a printer, a Mac sharing files, or a web server running,
// you should see them discovered.