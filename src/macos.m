/*
 * macOS-specific implementation for dzen2
 * (C)opyright 2025 - macOS port
 * See LICENSE file for license details.
 */

#ifdef __APPLE__

#import <Cocoa/Cocoa.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreText/CoreText.h>
#include "dzen.h"

/* DzenWindow - Custom NSWindow for borderless status bar */
@interface DzenWindow : NSWindow
@end

@implementation DzenWindow

- (id)initWithContentRect:(NSRect)contentRect {
    self = [super initWithContentRect:contentRect
                            styleMask:NSWindowStyleMaskBorderless
                              backing:NSBackingStoreBuffered
                                defer:NO];
    if (self) {
        [self setLevel:NSStatusWindowLevel];
        [self setOpaque:NO];
        [self setBackgroundColor:[NSColor clearColor]];
        [self setIgnoresMouseEvents:NO];
        [self setAcceptsMouseMovedEvents:YES];
    }
    return self;
}

- (BOOL)canBecomeKeyWindow {
    return YES;
}

@end

/* DzenView - Custom NSView for content rendering */
@interface DzenView : NSView
@property (nonatomic, strong) NSString *displayText;
@property (nonatomic, strong) NSColor *backgroundColor;
@property (nonatomic, strong) NSColor *foregroundColor;
@property (nonatomic, strong) NSFont *textFont;
@end

@implementation DzenView

- (id)initWithFrame:(NSRect)frame {
    self = [super initWithFrame:frame];
    if (self) {
        self.displayText = @"";
        self.backgroundColor = [NSColor colorWithRed:0.067 green:0.067 blue:0.067 alpha:1.0]; // #111111
        self.foregroundColor = [NSColor colorWithRed:0.7 green:0.7 blue:0.7 alpha:1.0]; // grey70
        self.textFont = [NSFont fontWithName:@"Monaco" size:12.0];
        if (!self.textFont) {
            self.textFont = [NSFont systemFontOfSize:12.0];
        }
    }
    return self;
}

- (void)drawRect:(NSRect)dirtyRect {
    // Fill background
    [self.backgroundColor setFill];
    NSRectFill(dirtyRect);
    
    // Draw text if present
    if (self.displayText && [self.displayText length] > 0) {
        NSDictionary *attributes = @{
            NSFontAttributeName: self.textFont,
            NSForegroundColorAttributeName: self.foregroundColor
        };
        
        NSSize textSize = [self.displayText sizeWithAttributes:attributes];
        NSRect textRect = NSMakeRect(5, (self.bounds.size.height - textSize.height) / 2, 
                                   self.bounds.size.width - 10, textSize.height);
        
        [self.displayText drawInRect:textRect withAttributes:attributes];
    }
}

- (void)mouseDown:(NSEvent *)event {
    // Handle mouse clicks - for now just print to console
    NSPoint location = [event locationInWindow];
    NSLog(@"Mouse clicked at: %.0f, %.0f", location.x, location.y);
    
    // TODO: Handle clickable areas and execute commands
}

@end

/* Global variables for macOS implementation */
static DzenWindow *main_window = nil;
static DzenView *main_view = nil;
static NSApplication *app = nil;

void macos_init(void) {
    @autoreleasepool {
        // Initialize NSApplication
        app = [NSApplication sharedApplication];
        [app setActivationPolicy:NSApplicationActivationPolicyAccessory];
        
        // Store reference in dzen structure
        dzen.app = (__bridge void*)app;
        
        // Initialize color space
        dzen.colorspace = CGColorSpaceCreateDeviceRGB();
        
        // Set default colors
        dzen.bg_color = macos_get_color(dzen.bg ? dzen.bg : BGCOLOR);
        dzen.fg_color = macos_get_color(dzen.fg ? dzen.fg : FGCOLOR);
        
        NSLog(@"macOS dzen2 initialized");
    }
}

void macos_cleanup(void) {
    @autoreleasepool {
        if (main_window) {
            [main_window close];
            main_window = nil;
        }
        
        if (dzen.colorspace) {
            CGColorSpaceRelease(dzen.colorspace);
            dzen.colorspace = NULL;
        }
        
        if (dzen.bg_color) {
            CGColorRelease(dzen.bg_color);
            dzen.bg_color = NULL;
        }
        
        if (dzen.fg_color) {
            CGColorRelease(dzen.fg_color);
            dzen.fg_color = NULL;
        }
        
        NSLog(@"macOS dzen2 cleanup completed");
    }
}

void macos_create_window(void) {
    @autoreleasepool {
        // Get screen dimensions for default positioning
        NSScreen *screen = [NSScreen mainScreen];
        NSRect screenFrame = [screen frame];
        
        // Set default dimensions if not specified
        if (dzen.w == 0) dzen.w = (int)screenFrame.size.width;
        if (dzen.h == 0) dzen.h = 20; // Default status bar height
        
        // Create window
        NSRect windowFrame = NSMakeRect(dzen.x, screenFrame.size.height - dzen.y - dzen.h, 
                                      dzen.w, dzen.h);
        
        main_window = [[DzenWindow alloc] initWithContentRect:windowFrame];
        
        // Create and setup view
        main_view = [[DzenView alloc] initWithFrame:windowFrame];
        [main_window setContentView:main_view];
        
        // Store window reference
        dzen.title_win.win = (__bridge void*)main_window;
        
        NSLog(@"Created window: %.0fx%.0f at (%.0f,%.0f)", 
              windowFrame.size.width, windowFrame.size.height,
              windowFrame.origin.x, windowFrame.origin.y);
    }
}

void macos_show_window(void) {
    @autoreleasepool {
        if (main_window) {
            [main_window makeKeyAndOrderFront:nil];
        }
    }
}

void macos_hide_window(void) {
    @autoreleasepool {
        if (main_window) {
            [main_window orderOut:nil];
        }
    }
}

void macos_set_window_position(int x, int y) {
    @autoreleasepool {
        if (main_window) {
            NSScreen *screen = [NSScreen mainScreen];
            NSRect screenFrame = [screen frame];
            
            // Convert from X11 coordinates (top-left) to Cocoa coordinates (bottom-left)
            NSPoint newOrigin = NSMakePoint(x, screenFrame.size.height - y - dzen.h);
            [main_window setFrameOrigin:newOrigin];
        }
    }
}

CGColorRef macos_get_color(const char *str) {
    if (!str || !dzen.colorspace) return NULL;
    
    CGFloat components[4] = {0.0, 0.0, 0.0, 1.0}; // Default to black, opaque
    
    if (str[0] == '#' && strlen(str) == 7) {
        // Parse hex color #RRGGBB
        unsigned int r, g, b;
        if (sscanf(str + 1, "%02x%02x%02x", &r, &g, &b) == 3) {
            components[0] = r / 255.0;
            components[1] = g / 255.0;
            components[2] = b / 255.0;
        }
    } else {
        // Handle named colors (simplified set)
        if (strcmp(str, "black") == 0) {
            // Already default black
        } else if (strcmp(str, "white") == 0) {
            components[0] = components[1] = components[2] = 1.0;
        } else if (strcmp(str, "red") == 0) {
            components[0] = 1.0;
        } else if (strcmp(str, "green") == 0) {
            components[1] = 1.0;
        } else if (strcmp(str, "blue") == 0) {
            components[2] = 1.0;
        } else if (strcmp(str, "grey70") == 0) {
            components[0] = components[1] = components[2] = 0.7;
        }
    }
    
    return CGColorCreate(dzen.colorspace, components);
}

void macos_draw_body(void) {
    // This will be called to update the display
    @autoreleasepool {
        if (main_view) {
            [main_view setNeedsDisplay:YES];
        }
    }
}

void macos_event_loop(void) {
    @autoreleasepool {
        NSLog(@"Starting macOS event loop");
        
        // Run the application event loop
        // Note: This is a simplified approach. In a full implementation,
        // we'd need to integrate this with stdin reading
        [app run];
    }
}

void macos_update_display_text(const char *text) {
    @autoreleasepool {
        if (main_view && text) {
            NSString *nsText = [NSString stringWithUTF8String:text];
            [main_view setDisplayText:nsText];
            [main_view setNeedsDisplay:YES];
        }
    }
}

#endif /* __APPLE__ */