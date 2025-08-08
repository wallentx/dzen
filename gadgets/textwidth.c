/*
 * (C)opyright 2007-2009 Robert Manea <rob dot manea at gmail dot com>
 * See LICENSE file for license details. 
 * 
 */

#include "../src/dzen.h"
#include "../src/font.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

#ifdef __APPLE__
#include <CoreText/CoreText.h>

Dzen dzen;

int main(int argc, char *argv[]) {
    if (argc < 3) {
        fprintf(stderr, "usage: %s <font> <text>\n", argv[0]);
        return 1;
    }

    char *font_str = argv[1];
    char *text_str = argv[2];

    font_init();
    setfont(font_str);

    unsigned int width = textnw(&dzen.font, text_str, strlen(text_str));
    printf("%u\n", width);

    font_cleanup();

    return 0;
}

#else

#include <X11/Xlib.h>

Dzen dzen;
void eprint(const char *errstr, ...);

int main(int argc, char *argv[]) {
    if (argc < 3)
        eprint("usage: %s <font> <text>\n", argv[0]);

    dzen.dpy = XOpenDisplay(0);
    if (!dzen.dpy)
        eprint("cannot open display\n");
    dzen.screen = DefaultScreen(dzen.dpy);

    setfont(argv[1]);

    printf("%d\n", textw(argv[2]));

    XCloseDisplay(dzen.dpy);

    return 0;
}
#endif