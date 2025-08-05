/* 
 * (C)opyright 2007-2009 Robert Manea <rob dot manea at gmail dot com>
 * See LICENSE file for license details.
 *
 */

#include "../config.h"

#ifdef __APPLE__
/* macOS includes */
#include <CoreGraphics/CoreGraphics.h>
#include <CoreText/CoreText.h>
#include <Cocoa/Cocoa.h>
#else
/* X11 includes */
#include <X11/Xlib.h>
#include <X11/Xutil.h>
#include <X11/Xresource.h>
#include <X11/cursorfont.h>
#ifdef HAVE_XCURSOR
#include <X11/Xcursor/Xcursor.h>
#endif
#ifdef HAVE_XINERAMA
#include <X11/extensions/Xinerama.h>
#endif
#ifdef HAVE_XFT
#include <X11/Xft/Xft.h>
#endif
#ifdef HAVE_XPM
#include <X11/xpm.h>
#endif
#endif /* __APPLE__ */

#define FONT     "-*-fixed-*-*-*-*-*-*-*-*-*-*-*-*"
#define BGCOLOR  "#111111"
#define FGCOLOR  "grey70"
#define ESC_CHAR '^'

#ifdef __APPLE__
/* macOS compatibility definitions */
#define Bool                         bool
#define True                         true
#define False                        false
#define DefaultScreen(dpy)           0
#define DefaultVisual(dpy, screen)   NULL
#define DefaultColormap(dpy, screen) NULL
#else
/* X11 already provides these */
#endif

#define ALIGNCENTER 0
#define ALIGNLEFT   1
#define ALIGNRIGHT  2

#define TOPWINDOW   0
#define SLAVEWINDOW 1

#define MIN_BUF_SIZE 1024
#ifndef MAX_LINE_LEN
#define MAX_LINE_LEN 262144
#endif
#define MAX_CLICKABLE_AREAS 256

#ifndef Button6
#define Button6 6
#endif

#ifndef Button7
#define Button7 7
#endif

enum { ColFG, ColBG, ColLast };

/* exapansion directions */
enum { noexpand, left, right, both };

typedef struct DZEN   Dzen;
typedef struct Fnt    Fnt;
typedef struct TW     TWIN;
typedef struct SW     SWIN;
typedef struct _Sline Sline;

struct Fnt {
#ifdef __APPLE__
    CTFontRef font;
    CGFloat   ascent;
    CGFloat   descent;
    CGFloat   height;
    CGFloat   width;
#else
    XFontStruct *xfont;
    XFontSet     set;
    int          ascent;
    int          descent;
    int          height;
#ifdef HAVE_XFT
    XftFont   *xftfont;
    XGlyphInfo extents;
    int        width;
#endif
#endif /* __APPLE__ */
};

typedef struct {
#ifdef __APPLE__
    CGImageRef   image;
    unsigned int w;
    unsigned int h;
    Bool         is_xbm;
#else
    Pixmap       pm;
    unsigned int w;
    unsigned int h;
    Bool         is_xbm;
    Pixmap       mask_pm;
#ifdef HAVE_XPM
    /* We keep a copy of the attributes so we can call XFreeColors + XpmFreeAttributes */
    /* Possibly track a flag to know if we actually had to allocate colormap cells */
    XpmAttributes xpma;
#endif
#endif /* __APPLE__ */
} Icon;

/* clickable areas */
typedef struct _CLICK_A {
    int active;
    int button;
    int start_x;
    int end_x;
    int start_y;
    int end_y;
#ifdef __APPLE__
    void *win; /* NSWindow* for macOS */
#else
    Window win; //(line)window to which the action is attached
#endif
    char cmd[1024];
} click_a;

typedef struct _SENS_PER_WINDOW {
    click_a sens_areas[MAX_CLICKABLE_AREAS];
    int     sens_areas_cnt;
} sens_w;

//0: top window, 1: slave window
extern sens_w window_sens[2];

/* title window */
struct TW {
    int x, y, width, height;

    char *name;
#ifdef __APPLE__
    void *win; /* NSWindow* */
    void *drawable; /* CGContextRef or similar */
#else
    Window   win;
    Drawable drawable;
#endif
    char alignment;
    int  expand;
    int  x_right_corner;
    Bool ishidden;
};

/* slave window */
struct SW {
    int x, y, width, height;

    char *name;
#ifdef __APPLE__
    void  *win; /* NSWindow* */
    void **line; /* Array of NSWindow* pointers */
    void **drawable; /* Array of CGContextRef or similar */
#else
    Window    win;
    Window   *line;
    Drawable *drawable;
#endif

    /* input buffer */
    char **tbuf;
    int    tsize;
    int    tcnt;
    /* line fg colors */
    unsigned long *tcol;

    int max_lines;
    int first_line_vis;
    int last_line_vis;
    int sel_line;

    char alignment;
    Bool ismenu;
    Bool ishmenu;
    Bool issticky;
    Bool ismapped;
};

struct DZEN {
    int           x, y, w, h;
    Bool          running;
    unsigned long norm[ColLast];

    TWIN title_win;
    SWIN slave_win;

#ifdef __APPLE__
    /* macOS-specific members */
    void           *app; /* NSApplication* */
    CGColorRef      bg_color;
    CGColorRef      fg_color;
    CGColorSpaceRef colorspace;
#else
    /* sensitive areas */
    Window sa_win;

    Display     *dpy;
    int          screen;
    unsigned int depth;

    Visual *visual;
    GC      gc, rgc, tgc;
#endif

    const char *fnt;
    const char *bg;
    const char *fg;
    int         line_height;

    Fnt font;
    Fnt fnpl[64];

    Bool          ispersistent;
    Bool          tsupdate;
    Bool          colorize;
    unsigned long timeout;
    long          cur_line;
    int           ret_val;

    /* should always be 0 if HAVE_XINERAMA not defined */
    int xinescreen;

#ifndef __APPLE__
    Cursor cursor_arrow;
    Cursor cursor_hand;
#endif
};

extern Dzen dzen;

void free_buffer(void);
#ifdef __APPLE__
void macos_draw_body(void);
#else
void x_draw_body(void);
#endif

/* draw.c */
extern void         drawtext(const char *text, int reverse, int line, int align);
extern char        *parse_line(const char *text, int linenr, int align, int reverse, int nodraw);
extern void         setfont(const char *fontstr); /* sets global font */
extern unsigned int textw(const char *text); /* returns width of text in px */
extern void         drawheader(const char *text);
extern void         drawbody(char *text);

#ifdef __APPLE__
/* macOS-specific functions */
extern void       macos_init(void);
extern void       macos_cleanup(void);
extern void       macos_create_window(void);
extern void       macos_event_loop(void);
extern CGColorRef macos_get_color(const char *str);
extern void       macos_set_window_position(int x, int y);
extern void       macos_show_window(void);
extern void       macos_hide_window(void);
extern void       macos_update_display_text(const char *text);
#endif

/* util.c */
extern void *emalloc(unsigned int size); /* allocates memory, exits on error */
extern void  eprint(const char *errstr, ...); /* prints errstr and exits with 1 */
extern char *estrdup(const char *str); /* duplicates str, exits on allocation error */
extern void  spawn(const char *arg); /* execute arg */

/* caches.c */
Fnt  *find_or_create_font(const char *str);
long  get_color(const char *str); /* returns color of colstr */
Icon *get_icon(const char *str);

void init_all_caches();
void free_all_caches();
