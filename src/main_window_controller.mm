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
static const NSToolbarItemIdentifier kBackForwardItemIdentifier = @"BackForwardItem";
static const NSToolbarItemIdentifier kAddressBarItemIdentifier = @"AddressBarItem";
static const NSToolbarItemIdentifier kReloadItemIdentifier = @"ReloadItem";
static const NSToolbarItemIdentifier kShareItemIdentifier = @"ShareItem";
static const NSToolbarItemIdentifier kBookmarksItemIdentifier = @"BookmarksItem";

@interface MainWindowController ()

// Private helper to configure the NSSplitViewController.
- (void)setupSplitViewController;
// Private helper to configure the NSToolbar.
- (void)setupToolbar;
// Action for native "+" button (NSResponder). Implementing this shows the button.
- (void)newWindowForTab:(id)sender;
// Helper to ensure File > New Tab exists
- (void)setupMainMenu;
// Action methods for toolbar items
- (void)backForwardAction:(NSSegmentedControl*)sender;
- (void)goBack:(id)sender;
- (void)goForward:(id)sender;
- (void)reload:(id)sender;
- (void)share:(id)sender;
- (void)showBookmarks:(id)sender;

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
        window.tabbingMode = NSWindowTabbingModeAutomatic; // Force tab bar to always show
        window.tabbingIdentifier = @"MainWindowTabs"; // Group windows of this type
        
        // The tab bar's "+" appears once we implement newWindowForTab:
        // No need to create an extra tab.

        // Setup a main menu for tab creation keyboard shortcut
        [self setupMainMenu];

        // Configure the split view controller (sidebar and content).
        [self setupSplitViewController];

        // Configure the toolbar.
        [self setupToolbar];
    }
    return self;
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
                                                       action:@selector(newWindowForTab:) 
                                                keyEquivalent:@"t"];
    [newTabItem setTarget:self];
    [fileMenu insertItem:newTabItem atIndex:0]; // Add at the top of the File menu
}

// Implementation for the native "+" button / Cmd+T / File > New Tab
- (void)newWindowForTab:(id)sender {
    // Create a fresh window controller for the new tab.
    MainWindowController* wc = [[MainWindowController alloc] init];
    // Ensure the new window has a reference to its controller in responder chain.
    wc.window.windowController = wc;
    // Add as new tab.
    [self.window addTabbedWindow:wc.window ordered:NSWindowAbove];
}

// Set up the NSToolbar with Safari-like controls.
- (void)setupToolbar {
    NSToolbar* toolbar = [[NSToolbar alloc] initWithIdentifier:kMainToolbarIdentifier];
    toolbar.delegate = self;
    toolbar.displayMode = NSToolbarDisplayModeIconAndLabel; // Show both icons and labels
    toolbar.allowsUserCustomization = YES; // Allow users to customize the toolbar

    // Assign the toolbar to the window.
    self.window.toolbar = toolbar;

    // Ensure the toolbar style is unified (standard on Big Sur+).
    if (@available(macOS 11.0, *)) {
        self.window.toolbarStyle = NSWindowToolbarStyleUnified;
    }
}

#pragma mark - NSToolbarDelegate Methods

// Returns the identifiers for items allowed in the toolbar.
- (NSArray<NSToolbarItemIdentifier>*)toolbarAllowedItemIdentifiers:(NSToolbar*)toolbar {
    return @[
        kToggleSidebarItemIdentifier,
        kSidebarTrackingSeparatorItemIdentifier,
        kBackForwardItemIdentifier,
        kAddressBarItemIdentifier,
        kReloadItemIdentifier,
        kShareItemIdentifier,
        kBookmarksItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier,
        NSToolbarSpaceItemIdentifier
    ];
}

// Returns the identifiers for items included in the toolbar by default.
- (NSArray<NSToolbarItemIdentifier>*)toolbarDefaultItemIdentifiers:(NSToolbar*)toolbar {
    return @[
        kToggleSidebarItemIdentifier,
        kSidebarTrackingSeparatorItemIdentifier,
        kBackForwardItemIdentifier,
        kAddressBarItemIdentifier,
        kReloadItemIdentifier,
        kShareItemIdentifier,
        kBookmarksItemIdentifier,
        NSToolbarFlexibleSpaceItemIdentifier
    ];
}

// Creates and returns toolbar items based on their identifiers.
- (NSToolbarItem*)toolbar:(NSToolbar*)toolbar
    itemForItemIdentifier:(NSToolbarItemIdentifier)itemIdentifier
    willBeInsertedIntoToolbar:(BOOL)flag {

    NSToolbarItem* toolbarItem = nil;

    if ([itemIdentifier isEqual:kToggleSidebarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        toolbarItem.label = @"Toggle Sidebar";
        toolbarItem.paletteLabel = @"Toggle Sidebar";
        toolbarItem.toolTip = @"Show/Hide Sidebar";
    }
    else if ([itemIdentifier isEqual:kSidebarTrackingSeparatorItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        NSBox* separatorView = [[NSBox alloc] initWithFrame:NSMakeRect(0, 0, 1, 24)];
        separatorView.boxType = NSBoxSeparator;
        toolbarItem.view = separatorView;
        toolbarItem.label = @"Sidebar Separator";
        toolbarItem.paletteLabel = @"Sidebar Separator";
    }
    else if ([itemIdentifier isEqual:kBackForwardItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        // Create a segmented control for back/forward
        NSSegmentedControl* segmentedControl = [[NSSegmentedControl alloc] initWithFrame:NSMakeRect(0, 0, 80, 24)];
        segmentedControl.segmentCount = 2;
        [segmentedControl setImage:[NSImage imageWithSystemSymbolName:@"chevron.left" accessibilityDescription:nil] forSegment:0];
        [segmentedControl setImage:[NSImage imageWithSystemSymbolName:@"chevron.right" accessibilityDescription:nil] forSegment:1];
        [segmentedControl setTarget:self];
        [segmentedControl setAction:@selector(backForwardAction:)];
        
        toolbarItem.view = segmentedControl;
        toolbarItem.label = @"Back/Forward";
        toolbarItem.paletteLabel = @"Back/Forward";
    }
    else if ([itemIdentifier isEqual:kAddressBarItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        // Create a search field for the address bar
        NSSearchField* searchField = [[NSSearchField alloc] initWithFrame:NSMakeRect(0, 0, 300, 24)];
        searchField.placeholderString = @"Search or enter website name";
        
        toolbarItem.view = searchField;
        toolbarItem.label = @"Address";
        toolbarItem.paletteLabel = @"Address";
        toolbarItem.minSize = NSMakeSize(200, 24);
        toolbarItem.maxSize = NSMakeSize(500, 24);
    }
    else if ([itemIdentifier isEqual:kReloadItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
        button.bezelStyle = NSBezelStyleRegularSquare;
        button.image = [NSImage imageWithSystemSymbolName:@"arrow.clockwise" accessibilityDescription:nil];
        button.target = self;
        button.action = @selector(reload:);
        
        toolbarItem.view = button;
        toolbarItem.label = @"Reload";
        toolbarItem.paletteLabel = @"Reload";
    }
    else if ([itemIdentifier isEqual:kShareItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
        button.bezelStyle = NSBezelStyleRegularSquare;
        button.image = [NSImage imageWithSystemSymbolName:@"square.and.arrow.up" accessibilityDescription:nil];
        button.target = self;
        button.action = @selector(share:);
        
        toolbarItem.view = button;
        toolbarItem.label = @"Share";
        toolbarItem.paletteLabel = @"Share";
    }
    else if ([itemIdentifier isEqual:kBookmarksItemIdentifier]) {
        toolbarItem = [[NSToolbarItem alloc] initWithItemIdentifier:itemIdentifier];
        
        NSButton* button = [[NSButton alloc] initWithFrame:NSMakeRect(0, 0, 24, 24)];
        button.bezelStyle = NSBezelStyleRegularSquare;
        button.image = [NSImage imageWithSystemSymbolName:@"book" accessibilityDescription:nil];
        button.target = self;
        button.action = @selector(showBookmarks:);
        
        toolbarItem.view = button;
        toolbarItem.label = @"Bookmarks";
        toolbarItem.paletteLabel = @"Bookmarks";
    }
    
    return toolbarItem;
}

#pragma mark - Toolbar Actions

- (void)backForwardAction:(NSSegmentedControl*)sender {
    if (sender.selectedSegment == 0) {
        [self goBack:sender];
    } else {
        [self goForward:sender];
    }
}

- (void)goBack:(id)sender {
    // TODO: Implement back navigation
}

- (void)goForward:(id)sender {
    // TODO: Implement forward navigation
}

- (void)reload:(id)sender {
    // TODO: Implement reload functionality
}

- (void)share:(id)sender {
    // TODO: Implement share functionality
}

- (void)showBookmarks:(id)sender {
    // TODO: Implement bookmarks functionality
}

@end 