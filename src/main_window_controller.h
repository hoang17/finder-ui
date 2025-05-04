#import <Cocoa/Cocoa.h>

@class NSSplitViewController;

/**
 * @brief Controller managing the main application window and its components.
 *
 * This class is responsible for setting up the window's appearance,
 * configuring the split view controller (sidebar + content),
 * and managing the toolbar (including the sidebar toggle and separator).
 */
@interface MainWindowController : NSWindowController <NSToolbarDelegate>

// Reference to the split view controller holding the sidebar and content.
@property (nonatomic, strong) NSSplitViewController* splitViewController_;

// Designated initializer.
- (instancetype)init;

@end 