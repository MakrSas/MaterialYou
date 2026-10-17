// Reproduces the "score" section of tests/ref.tsv (generator: s8build:~/lqs-monetref/src/Dump.java).
// Pixel generation: 64-bit wrapping LCG, QuantizerCelebi.quantize(px, 128), Score.score(q).
// Build: xcrun clang -fobjc-arc -framework Foundation -I. MCU*.m tests/score_check.m -o /tmp/scheck

#import <Foundation/Foundation.h>
#import "MCUQuantizerCelebi.h"
#import "MCUQuantizerResult.h"
#import "MCUScore.h"

int main(int argc, const char *argv[]) {
  @autoreleasepool {
    static const uint32_t kBases[4] = {0xFF1B6EF3u, 0xFF00A86Bu, 0xFF2E7D32u, 0xFF795548u};
    for (int img = 0; img < 4; img++) {
      uint64_t x = 12345ULL + (uint64_t)img * 777ULL;
      NSMutableArray<NSNumber *> *px = [NSMutableArray arrayWithCapacity:128 * 128];
      uint32_t base = kBases[img];
      for (int k = 0; k < 128 * 128; k++) {
        x = x * 6364136223846793005ULL + 1442695040888963407ULL;
        int r = (int)((x >> 33) & 0xff);
        int g = (int)((x >> 41) & 0xff);
        int b = (int)((x >> 49) & 0xff);
        if ((k / 128) < 80) {
          r = (int)(((base >> 16) & 0xff) * 3 / 4 + r / 4);
          g = (int)(((base >> 8) & 0xff) * 3 / 4 + g / 4);
          b = (int)((base & 0xff) * 3 / 4 + b / 4);
        }
        uint32_t argb = 0xFF000000u | ((uint32_t)r << 16) | ((uint32_t)g << 8) | (uint32_t)b;
        [px addObject:@((int)(int32_t)argb)];
      }
      MCUQuantizerResult *q = [MCUQuantizerCelebi quantize:px maxColors:128];
      NSArray<NSNumber *> *sc = [MCUScore score:q.colorToCount
                                       keyOrder:q.colorOrder
                                        desired:4
                              fallbackColorArgb:(int)0xff4285f4u
                                         filter:YES];
      NSMutableString *line = [NSMutableString stringWithFormat:@"score\t%d\t-\t-\t", img];
      for (NSUInteger i = 0; i < sc.count; i++) {
        if (i > 0) {
          [line appendString:@" "];
        }
        [line appendFormat:@"#%08X", (unsigned)[sc[i] intValue]];
      }
      printf("%s\n", [line UTF8String]);
    }
  }
  return 0;
}
