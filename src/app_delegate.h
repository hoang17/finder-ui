#import <Cocoa/Cocoa.h>

@class MainWindowController;

/**
 * @brief Application delegate responsible for managing the application lifecycle.
 *
 * This class handles application launch, termination, and window management.
 */
@interface AppDelegate : NSObject <NSApplicationDelegate>

// Strong reference to the main window controller.
// We keep it alive for the duration of the application.
@property (nonatomic, strong) MainWindowController* mainWindowController_;

@end 