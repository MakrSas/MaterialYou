// Foundation check for the libmonet Objective-C port. Output is compared against FCheck.java
// (Java reference, run on the same classes). Each line format is mirrored exactly in FCheck.java.
#import <Foundation/Foundation.h>
#import <stdio.h>
#import "MCUHct.h"
#import "MCUColorUtils.h"
#import "MCUTonalPalette.h"
#import "MCUContrast.h"
#import "MCUTemperatureCache.h"
#import "MCUDislikeAnalyzer.h"
#import "MCUCorePalette.h"
#import "MCUViewingConditions.h"

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    MCUHct *h = [MCUHct fromInt:0xFF1B6EF3];
    printf("hct hue %.6f chroma %.6f tone %.6f\n", [h getHue], [h getChroma], [h getTone]);
    printf("lstar %.6f\n", [MCUColorUtils lstarFromArgb:0xFF1B6EF3]);

    MCUTonalPalette *p = [MCUTonalPalette fromHueAndChroma:270 chroma:36];
    for (int t = 0; t <= 100; t += 10) {
      printf("tone %d #%08X\n", t, (unsigned)[p tone:t]);
    }

    MCUHct *from = [MCUHct from:200 chroma:40 tone:50];
    printf("from hue %.6f chroma %.6f tone %.6f argb #%08X\n", [from getHue], [from getChroma],
           [from getTone], (unsigned)[from toInt]);

    MCUTonalPalette *yellow = [MCUTonalPalette fromHueAndChroma:110 chroma:40];
    printf("yellow99 #%08X yellow98 #%08X\n", (unsigned)[yellow tone:99], (unsigned)[yellow tone:98]);

    printf("contrast lighter %.6f darker %.6f ratioOfTones %.6f\n",
           [MCUContrast lighter:50 ratio:4.5], [MCUContrast darker:50 ratio:4.5],
           [MCUContrast ratioOfTones:30 t2:70]);

    MCUHct *tcInput = [MCUHct from:30 chroma:40 tone:50];
    MCUTemperatureCache *tc = [[MCUTemperatureCache alloc] initWithInput:tcInput];
    MCUHct *comp = [tc getComplement];
    printf("complement hue %.6f chroma %.6f tone %.6f\n", [comp getHue], [comp getChroma], [comp getTone]);
    for (MCUHct *a in [tc getAnalogousColors]) {
      printf("analogous #%08X\n", (unsigned)[a toInt]);
    }
    printf("dislike %d %d\n", [MCUDislikeAnalyzer isDisliked:[MCUHct from:100 chroma:30 tone:40]] ? 1 : 0,
           [MCUDislikeAnalyzer isDisliked:[MCUHct from:270 chroma:30 tone:40]] ? 1 : 0);

    MCUCorePalette *core = [MCUCorePalette of:0xFF1B6EF3];
    printf("core a1 #%08X n2 #%08X error #%08X\n", (unsigned)[core.a1 tone:40],
           (unsigned)[core.n2 tone:60], (unsigned)[core.error tone:50]);
    MCUCorePalette *content = [MCUCorePalette contentOf:0xFF1B6EF3];
    printf("content a2 #%08X a3 #%08X\n", (unsigned)[content.a2 tone:50], (unsigned)[content.a3 tone:50]);

    MCUHct *inVc = [h inViewingConditions:[MCUViewingConditions defaultWithBackgroundLstar:30]];
    printf("inVc hue %.6f chroma %.6f tone %.6f\n", [inVc getHue], [inVc getChroma], [inVc getTone]);
  }
  return 0;
}
