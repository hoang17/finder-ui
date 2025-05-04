#import "sidebar_view_controller.h"

@implementation SidebarViewController

- (instancetype)init {
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        [self setupView];
    }
    return self;
}

- (void)setupView {
    // Create a visual effect view with sidebar appearance.
    NSVisualEffectView* visualEffectView = [[NSVisualEffectView alloc] initWithFrame:NSZeroRect];
    visualEffectView.material = NSVisualEffectMaterialSidebar;
    visualEffectView.blendingMode = NSVisualEffectBlendingModeBehindWindow;
    visualEffectView.state = NSVisualEffectStateActive;
    
    // Set the visual effect view as our view.
    self.view = visualEffectView;
    
    // Add a simple label to demonstrate the content (for testing purposes).
    NSTextField* label = [NSTextField labelWithString:@"Sidebar Content"];
    label.font = [NSFont systemFontOfSize:13.0];
    label.textColor = [NSColor labelColor];
    label.translatesAutoresizingMaskIntoConstraints = NO;
    [visualEffectView addSubview:label];
    
    // Center the label in the view.
    [NSLayoutConstraint activateConstraints:@[
        [label.centerXAnchor constraintEqualToAnchor:visualEffectView.centerXAnchor],
        [label.centerYAnchor constraintEqualToAnchor:visualEffectView.centerYAnchor]
    ]];
    
    // In a real app, you would add an NSOutlineView or other content here.
    // This is just a placeholder for demonstration.
}

- (void)viewDidLoad {
    [super viewDidLoad];
    // Additional setup after the view is loaded (if needed).
}

@end 