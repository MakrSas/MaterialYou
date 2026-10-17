// Mirrors s8build:~/lqs-monetref/src/Dump.java (scheme part): same seeds, styles,
// token list and output format, so `diff` against ref.tsv checks the port bit-exactly.
#import <Foundation/Foundation.h>
#import "MCUHct.h"
#import "MCUDynamicScheme.h"
#import "MCUDynamicColor.h"
#import "MCUSystemDynamicColors.h"
#import "MCUSchemeNeutral.h"
#import "MCUSchemeTonalSpot.h"
#import "MCUSchemeVibrant.h"
#import "MCUSchemeExpressive.h"

static MCUDynamicScheme *Scheme(NSString *style, NSArray *seeds, BOOL dark) {
    if ([style isEqualToString:@"neutral"]) return [[MCUSchemeNeutral alloc] initWithSourceColorHctList:seeds isDark:dark contrastLevel:0.0 specVersion:MCUSpecVersion2026 platform:MCUPlatformPhone];
    if ([style isEqualToString:@"tonal_spot"]) return [[MCUSchemeTonalSpot alloc] initWithSourceColorHctList:seeds isDark:dark contrastLevel:0.0 specVersion:MCUSpecVersion2026 platform:MCUPlatformPhone];
    if ([style isEqualToString:@"vibrant"]) return [[MCUSchemeVibrant alloc] initWithSourceColorHctList:seeds isDark:dark contrastLevel:0.0 specVersion:MCUSpecVersion2026 platform:MCUPlatformPhone];
    return [[MCUSchemeExpressive alloc] initWithSourceColorHctList:seeds isDark:dark contrastLevel:0.0 specVersion:MCUSpecVersion2026 platform:MCUPlatformPhone];
}

int main(void) {
    @autoreleasepool {
        NSArray *SEEDS = @[@[@0xFF1B6EF3], @[@0xFF6750A4], @[@0xFFB3261E], @[@0xFF00A86B], @[@0xFFFFC107], @[@0xFF808080], @[@0xFF2E7D32, @0xFFF06292],
                           @[@0xFF0D47A1, @0xFFFF7043, @0xFF26A69A], @[@0xFFE91E63], @[@0xFF795548], @[@0xFF00BCD4], @[@0xFF9C27B0], @[@0xFF101010], @[@0xFFF5F5F5]];
        NSArray *STYLES = @[@"neutral", @"tonal_spot", @"vibrant", @"expressive"];
        NSMutableArray *all = [NSMutableArray array];
        [all addObjectsFromArray:[MCUSystemDynamicColors getAllDynamicColorsMapped]];
        [all addObjectsFromArray:[MCUSystemDynamicColors getFixedColorsMapped]];
        [all addObjectsFromArray:[MCUSystemDynamicColors getCustomColorsMapped]];
        [all addObjectsFromArray:[MCUSystemDynamicColors getAllAccentPalette]];
        [all addObjectsFromArray:[MCUSystemDynamicColors getAllNeutralPalette]];
        [all addObjectsFromArray:[MCUSystemDynamicColors getAllErrorPalette]];
        NSMutableString *out = [NSMutableString string];
        for (NSUInteger i = 0; i < SEEDS.count; i++) {
            NSMutableArray *seeds = [NSMutableArray array];
            for (NSNumber *s in SEEDS[i]) [seeds addObject:[MCUHct fromInt:(int)s.unsignedIntValue]];
            for (NSString *st in STYLES) for (int d = 0; d < 2; d++) {
                MCUDynamicScheme *sc = Scheme(st, seeds, d == 1);
                for (NSArray *e in all) [out appendFormat:@"%lu\t%@\t%d\t%@\t#%08X\n", (unsigned long)i, st, d, e[0], (unsigned)[(MCUDynamicColor *)e[1] getArgb:sc]];
            }
        }
        fputs(out.UTF8String, stdout);
    }
    return 0;
}
