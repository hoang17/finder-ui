#import "main_window_controller.h"
#import "sidebar_view_controller.h"
#import "content_view_controller.h"

// Define a unique identifier for the toolbar.
static const NSToolbarIdentifier kMainToolbarIdentifier = @"MainToolbar";

// Define unique identifiers for toolbar items (use constants for safety).
static const NSToolbarItemIdentifier kToggleSidebarItemIdentifier =
    @"NSToolbarToggleSidebarItemIdentifier"; // Fixed identifier
static const NSToolbarItemIdentifier kSidebarTrackingSeparatorItemIdentifier =
    @"NSToolbarSidebarTrackingSeparatorItemIdentifier"; // Fixed identifier
static const NSToolbarItemIdentifier kNewTabItemIdentifier = @"NewTabItem";

@interface MainWindowController ()

// Private helper to configure the NSSplitViewController.
- (void)setupSplitViewController;
// Private helper to configure the NSToolbar.
- (void)setupToolbar;
// Action to create a new tab
- (void)newTab:(id)sender;
// Helper to set up the main menu for tab support
- (void)setupMainMenu;

@end


@implementation MainWindowController

// Designated initializer.
- (instancetype)init {
    // Define initial window size and style mask.
    NSRect contentRect = NSMakeRect(100, 100, 900, 700); // Decent starting size
    NSWindowStyleMask styleMask = (NSWindowStyleMaskTitled |
                                   NSWindowStyleMaskClosable |
                                   NSWindowStyleMaskMiniaturizable |
                                   NSWindowStyleMaskResizable |
                                   // Key styles for the unified/full-height look:
                                   NSWindowStyleMaskUnifiedTitleAndToolbar |
                                   NSWindowStyleMaskFullSizeContentView);

    // Create the window instance.
    NSWindow* window = [[NSWindow alloc] initWithContentRect:contentRect
                                                  styleMask:styleMask
                                                    backing:NSBackingStoreBuffered
                                                      defer:NO];

    // Call the superclass initializer with the created window.
    self = [super initWithWindow:window];
    if (self) {
        // Further window configuration for the desired appearance.
        window.titleVisibility = NSWindowTitleHidden; // Hide the title text
        window.titlebarAppearsTransparent = YES;      // Allow content under titlebar

        // Enable native window tabbing.
        window.tabbingMode = NSWindowTabbingModePreferred;
        window.tabbingIdentifier = @"MainWindowTabs"; // Group windows of this type
        
        // Force the tab bar to be visible by creating a second tab immediately
        // This will make the tab bar appear
        [self performSelector:@selector(createInitialTab) withObject:nil afterDelay:0.1];
        
        // Setup a main menu for tab creation keyboard shortcut
        [self setupMainMenu];

        // Configure the split view controller (sidebar and content).
        [self setupSplitViewController];

        // Configure the toolbar.
        [self setupToolbar];
    }
    return self;
}

// Create an initial tab to make the tab bar appear
- (void)createInitialTab {
    // Create a temporary window and add it as a tab to force the tab bar to appear
    // This is a workaround for macOS versions where tabGroup.isTabBarVisible isn't available
    [self newTab:nil];
}

// Set up the NSSplitViewController with sidebar and content panes.
- (void)setupSplitViewController {
    // Create the main split view controller.
    self.splitViewController_ = [[NSSplitViewController alloc] init];

    // Create the sidebar view controller and its split view item.
    SidebarViewController* sidebarVC = [[SidebarViewController alloc] init];
    NSSplitViewItem* sidebarItem = [NSSplitViewItem sidebarWithViewController:sidebarVC];
    sidebarItem.minimumThickness = 180; // Minimum width for the sidebar
    sidebarItem.maximumThickness = 400; // Maximum width for the sidebar
    sidebarItem.canCollapse = YES;      // Allow user to collapse the sidebar
    // CRITICAL: Enable full height layout for the sidebar item.
    sidebarItem.allowsFullHeightLayout = YES;
    [self.splitViewController_ addSplitViewItem:sidebarItem];

    // Create the main content view controller and its split view item.
    ContentViewController* contentVC = [[ContentViewController alloc] init];
    NSSplitViewItem* contentItem = [NSSplitViewItem splitViewItemWithViewController:contentVC];
    // Content typically doesn't need a minimum size enforced here,
    // but can be set if required.
    contentItem.minimumThickness = 300;
    [self.splitViewController_ addSplitViewItem:contentItem];

    // Set the split view controller as the window's content view controller.
    self.window.contentViewController = self.splitViewController_;
}

// Set up the main menu with File > New Tab
- (void)setupMainMenu {
    // Get the main menu or create one if it doesn't exist
    NSMenu* mainMenu = [NSApp mainMenu];
    if (!mainMenu) {
        mainMenu = [[NSMenu alloc] init];
        [NSApp setMainMenu:mainMenu];
    }
    
    // Look for the File menu
    NSMenuItem* fileMenuItem = nil;
    for (NSMenuItem* item in [mainMenu itemArray]) {
        if ([[item title] isEqualToString:@"File"]) {
            fileMenuItem = item;
            break;
        }
    }
    
    // Create the File menu if it doesn't exist
    if (!fileMenuItem) {
        fileMenuItem = [[NSMenuItem alloc] initWithTitle:@"File" 
                                                  action:nil 
                                           keyEquivalent:@""];
        NSMenu* fileMenu = [[NSMenu alloc] initWithTitle:@"File"];
        [fileMenuItem setSubmenu:fileMenu];
        [mainMenu addItem:fileMenuItem];
    }
    
    // Add New Tab item to the File menu
    NSMenu* fileMenu = [fileMenuItem submenu];
    NSMenuItem* newTabItem = [[NSMenuItem alloc] initWithTitle:@"New Tab" 
                                                       action:@selector(newTab:) 
                                                keyEquivalent:@"t"];
    [newTabItem setTarget:self];
    [fileMenu insertItem:newTabItem atIndex:0]; // Add at the top of the File menu
    
    // Add a separator after the New Tab item
    [fileMenu insertItem:[NSMenuItem separatorItem] atIndex:1];
}

// Action to create a new tab
- (void)newTab:(id)sender {
    // Create content for the new tab - use the same setup as the initial window
    NSSplitViewController* splitVC = [[NSSplitViewController alloc] init];
    
    // Create the sidebar for the new tab
    SidebarViewController* sidebarVC = [[SidebarViewController alloc] init];
    NSSplitViewItem* sidebarItem = [NSSplitViewItem sidebarWithViewController:sidebarVC];
    sidebarItem.minimumThickness = 180;
    sidebarItem.maximumThickness = 400;
    sidebarItem.canCollapse = YES;
    sidebarItem.allowsFullHeightLayout = YES;
    [splitVC addSplitViewItem:sidebarItem];
    
    // Create the content area for the new tab
    ContentViewController* contentVC = [[ContentViewController alloc] init];
    NSSplitViewItem* contentItem = [NSSplitViewItem splitViewItemWithViewController:contentVC];
    contentItem.minimumThickness = 300;
    [splitVC addSplitViewItem:contentItem];
    
    // Create a temporary window to hold the new tab content
    NSWindow* newTabWindow = [[NSWindow alloc] initWithContentRect:self.window.frame
                                                        styleMask:self.window.styleMask
                                                          backing:NSBackingStoreBuffered
                                                            defer:YES];
    newTabWindow.contentViewController = splitVC;
    
    // Add it as a tab to the current window
    [self.window addTabbedWindow:newTabWindow ordered:NSWindowAbove];
}

// Set up the NSToolbar with standard sidebar controls.
- (void)setupToolbar {
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier:kMainToolbarIdentifier];
    toolbar.delegate = self; // This controller will provide toolbar items.
    toolbar.displayMode = NSToolbarDisplayModeIconOnly;
    toolbar.allowsUserCustomization = NO; // Typically false for this style

    // Assign the toolbar to the window.
    self.window.toolbar = toolbar;

    // Ensure the toolbar style is unified (standard on Big Sur+).
    // Redundant if using NSWindowStyleMaskUnifiedTitleAndToolbar, but safe to set.
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
}

#pragma mark - NSToolbarDelegate Methods

// Returns the identifiers for items allowed in the toolbar.
- (NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    // Define all possible items, including system and custom ones.
    return @[
        kToggleSidebarItemIdentifier,
        kSidebarTrackingSeparatorItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        kNewTabItemIdentifier
    ];
}

// Returns the identifiers for items included in the toolbar by default.
- (NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    // Define the standard layout: toggle, separator, flexible space (pushes items right).
    return @[
        kToggleSidebarItemIdentifier,
        kSidebarTrackingSeparatorItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        kNewTabItemIdentifier
    ];
}

// Creates and returns toolbar items based on their identifiers.
- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar
    itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag {

    NSToolbarItem* toolbarItem = nil;

    // Handle the standard system toggle sidebar item.
    if ([itemIdentifier isEqual:kToggleSidebarItemIdentifier]) {
        // Use the standard constructor; AppKit handles the icon, action, and target.
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        // No need to set image, target, or action manually.
        toolbarItem.label = @"Toggle Sidebar"; // Tooltip
        toolbarItem.paletteLabel = @"Toggle Sidebar";
        toolbarItem.toolTip = @"Show/Hide Sidebar";
    }
    // Handle the standard system sidebar tracking separator item.
    else if ([itemIdentifier isEqual:kSidebarTrackingSeparatorItemIdentifier]) {
        // Create a regular toolbar item for the separator
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        // Create a separator view
        NSBox* separatorView = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 1, 24)];
        separatorView.boxType = NSBoxSeparator;
        
        // Set the separator view as the toolbar item's view
        toolbarItem.view = separatorView;
        toolbarItem.label = @"Sidebar Separator";
        toolbarItem.paletteLabel = @"Sidebar Separator";
    }
    else if ([itemIdentifier isEqual:kNewTabItemIdentifier]) {
        // Create a new tab button
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        toolbarItem.label = @"New Tab";
        toolbarItem.paletteLabel = @"New Tab";
        toolbarItem.toolTip = @"Create a new tab";
        toolbarItem.image = [NSImage imageNamed:NSImageNameAddTemplate];
        toolbarItem.target = self;
        toolbarItem.action = @selector(newTab:);
    }
    
    // Return the created item (or nil if identifier is unknown).
    return toolbarItem;
}

@end 