#import "app_delegate.h"
#import "main_window_controller.h"

@implementation AppDelegate

/**
 * @brief Called when the application has finished launching.
 *
 * This is the primary point to set up the initial application state,
 * including creating and showing the main window.
 *
 * @param notification The notification object associated with the launch event.
 */
- (void)applicationDidFinishLaunching:(NSNotification*)notification {
    NSLog(@"Application finished launching.");

    // Create the main window controller.
    self.mainWindowController_ = [[MainWindowController alloc] init];

    // Show the window.
    [self.mainWindowController_ showWindow:self];

    // Activate the application, bringing it to the foreground.
    // This is important if the app is launched in the background.
    [NSApp activateIgnoringOtherApps:YES];

    NSLog(@"Main window controller created and shown.");
}

/**
 * @brief Called when the application is about to terminate.
 *
 * @param notification The notification object associated with the termination event.
 */
- (void)applicationWillTerminate:(NSNotification*)notification {
    // Insert code here to tear down your application before termination.
    NSLog(@"Application will terminate.");
}

/**
 * @brief Determines if the application should terminate after the last window is closed.
 *
 * Returning YES allows the application to quit when the user closes the only open window.
 * Returning NO keeps the application running (dock icon remains active) even with no windows,
 * which is common for document-based or utility apps.
 *
 * @param sender The shared NSApplication instance.
 * @return YES to terminate after last window closed, NO otherwise.
 */
- (BOOL)applicationShouldTerminateAfterLastWindowClosed:(NSApplication*)sender {
    NSLog(@"Last window closed, allowing application termination.");
    return YES;
}

@end 