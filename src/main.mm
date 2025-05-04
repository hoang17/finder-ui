#import <Cocoa/Cocoa.h>

/**
 * @brief Main entry point for the application.
 */
int main(int argc, const char* argv[]) {
    // Autorelease pool for memory management under ARC.
    @autoreleasepool {
        // Initialize the shared NSApplication instance.
        [NSApplication sharedApplication];

        // Create and assign the application delegate.
        // Note: The delegate class name should match the one specified in Info.plist
        // (or set programmatically here if not using Info.plist for NPrincipalClass).
        // We'll use "AppDelegate" as defined in our header/implementation.
        id delegate = [[NSClassFromString(@"AppDelegate") alloc] init];
        if (!delegate) {
            NSLog(@"Error: Could not create AppDelegate instance.");
            return 1; // Exit if delegate creation fails
        }
        [NSApp setDelegate:delegate];

        // Start the main application event loop.
        // This call blocks until the application terminates.
        [NSApp run];

        // Although [NSApp run] typically doesn't return until quit,
        // include a return statement for completeness.
        return 0;
    }
} 