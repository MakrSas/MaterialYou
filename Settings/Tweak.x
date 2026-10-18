// Places the Material You entry right after "Display & Brightness" (id DISPLAY) in the
// Settings root list. Only reorders existing specifiers; nothing else is changed.
#import <UIKit/UIKit.h>

@interface PSSpecifier : NSObject
@property (nonatomic, retain) NSString *identifier;
- (NSString *)name;
- (void)setProperty:(id)value forKey:(NSString *)key;
@end

static UIColor *ThemeColor(NSDictionary *c, NSString *token, BOOL dark, unsigned fallback) {
    NSString *h = c[[NSString stringWithFormat:@"system_%@_%@", token, dark ? @"dark" : @"light"]];
    unsigned v = fallback;
    if ([h isKindOfClass:NSString.class]) [[NSScanner scannerWithString:[h stringByReplacingOccurrencesOfString:@"#" withString:@""]] scanHexInt:&v];
    return [UIColor colorWithRed:((v >> 16) & 0xff) / 255.0 green:((v >> 8) & 0xff) / 255.0 blue:(v & 0xff) / 255.0 alpha:1];
}

// Settings icon in the current Material You colours: iOS icon squircle in primary with an
// M3 Expressive "Sunny" shape (8 soft lobes, androidx.graphics.shapes MaterialShapes;
// approximated as r = R(0.86 + 0.14 cos 8t)) in on_primary and a primary_container core.
static UIImage *ThemedIcon(void) {
    CFPreferencesAppSynchronize(CFSTR("com.makr.materialyou"));
    id pd = CFBridgingRelease(CFPreferencesCopyAppValue(CFSTR("themeJSON"), CFSTR("com.makr.materialyou")));
    NSData *d = [pd isKindOfClass:NSData.class] ? pd : [NSData dataWithContentsOfFile:@"/var/mobile/Library/MaterialYou/theme.json"];
    NSDictionary *t = d ? [NSJSONSerialization JSONObjectWithData:d options:0 error:nil] : nil;
    NSDictionary *c = [t[@"colors"] isKindOfClass:NSDictionary.class] ? t[@"colors"] : @{};
    BOOL dark = UIScreen.mainScreen.traitCollection.userInterfaceStyle == UIUserInterfaceStyleDark;
    UIColor *bg = ThemeColor(c, @"primary", NO, 0x4C5E8B), *fg = ThemeColor(c, @"accent1_200", dark, 0xB8C6EE); // lighter accent (tone 80)
    CGFloat S = 29;
    UIGraphicsImageRenderer *r = [[UIGraphicsImageRenderer alloc] initWithSize:CGSizeMake(S, S)];
    return [r imageWithActions:^(UIGraphicsImageRendererContext *ctx) {
        UIBezierPath *sq = [UIBezierPath bezierPathWithRoundedRect:CGRectMake(0, 0, S, S) cornerRadius:S * 0.225];
        [bg setFill]; [sq fill];
        UIBezierPath *p = [UIBezierPath bezierPath];
        CGFloat R = S * 0.36, cx = S / 2, cy = S / 2;
        for (int i = 0; i <= 360; i++) {
            CGFloat a = i * M_PI / 180.0, rr = R * (0.92 + 0.08 * cos(8 * a)); // softer lobes
            CGPoint pt = CGPointMake(cx + rr * cos(a - M_PI_2), cy + rr * sin(a - M_PI_2));
            if (i == 0) [p moveToPoint:pt]; else [p addLineToPoint:pt];
        }
        [p closePath];
        [fg setFill]; [p fill];
    }];
}
@interface PSListController : UIViewController
- (NSMutableArray *)specifiers;
@end
@interface PSUIPrefsListController : PSListController
@end

%hook PSUIPrefsListController
- (NSMutableArray *)specifiers {
    NSMutableArray *specs = %orig;
    @try {
        if (![specs isKindOfClass:NSMutableArray.class]) return specs;
        PSSpecifier *mine = nil, *display = nil;
        for (PSSpecifier *s in specs) {
            if ([s.name isEqualToString:@"Material You"]) mine = s;
            if ([s.identifier isEqualToString:@"DISPLAY"]) display = s;
        }
        if (mine) [mine setProperty:ThemedIcon() forKey:@"iconImage"];
        if (mine && display && mine != display) {
            [specs removeObjectIdenticalTo:mine];
            NSUInteger i = [specs indexOfObjectIdenticalTo:display];
            if (i != NSNotFound) [specs insertObject:mine atIndex:i + 1];
            else [specs addObject:mine];
        }
    } @catch (NSException *e) {}
    return specs;
}
%end
