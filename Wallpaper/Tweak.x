// iOS 16+ keeps wallpapers in PosterBoard and no longer writes the SpringBoard cpbitmaps that LQSWallpaper reads, so
// "Your wallpaper colors" came out empty there. This saves the Home Screen wallpaper as a small JPEG in MaterialYou's
// own folder (nothing is written to Apple's folders) at SpringBoard start and after each wallpaper change.
// LQSWallpaper reads it first. iOS 15 is left alone: the cpbitmaps exist there.
#import <UIKit/UIKit.h>
#import <objc/message.h>

#define MYWallpaperDirectory @"/var/mobile/Library/MaterialYou"

// Stand-in observer for PaperBoardUI's poster snapshot sources (PBUIPosterReplicaSourceObserver): asks for one style.
@interface MYWallpaperObserver : NSObject
@property (nonatomic) long long effectiveStyle;
@end
@implementation MYWallpaperObserver
- (void)setNeedsSourceUpdate {}
@end

static NSString *MYSavedWallpaperID;

static void MYSaveWallpaper(void) {
    id controller = [NSClassFromString(@"SBWallpaperController") valueForKey:@"sharedInstance"];
    id poster = nil, provider = nil, source = nil;
    @try { poster = [[controller valueForKey:@"_wallpaperPresenter"] valueForKey:@"viewController"]; } @catch (id e) { return; }
    if (![poster respondsToSelector:@selector(snapshotSourceProviderForVariant:)]) return;
    provider = ((id (*)(id, SEL, long long))objc_msgSend)(poster, @selector(snapshotSourceProviderForVariant:), 1); // 1 = Home Screen
    if (![provider respondsToSelector:@selector(snapshotSourceForObserver:)]) return;
    MYWallpaperObserver *observer = [MYWallpaperObserver new];
    observer.effectiveStyle = 0; // plain: no blur, no tint
    @try { source = ((id (*)(id, SEL, id))objc_msgSend)(provider, @selector(snapshotSourceForObserver:), observer); } @catch (id e) { return; }
    UIImage *image = nil;
    @try { image = [source respondsToSelector:@selector(snapshot)] ? [source valueForKey:@"snapshot"] : nil; } @catch (id e) {}
    if (![image isKindOfClass:UIImage.class] || image.size.width < 1) return; // not rendered yet: a later try gets it
    NSString *identity = nil;
    @try { identity = [[source valueForKey:@"cacheIdentifier"] description]; } @catch (id e) {}
    NSString *path = [MYWallpaperDirectory stringByAppendingPathComponent:@"wallpaper-home.jpg"];
    if (identity && [identity isEqual:MYSavedWallpaperID] && [NSFileManager.defaultManager fileExistsAtPath:path]) return; // unchanged
    MYSavedWallpaperID = identity;
    dispatch_async(dispatch_get_global_queue(QOS_CLASS_UTILITY, 0), ^{
        // a quarter of the screen's pixels is plenty for the colour pipeline (~310x670 px)
        CGSize size = CGSizeMake(round(image.size.width * image.scale / 4), round(image.size.height * image.scale / 4));
        UIGraphicsImageRendererFormat *format = [UIGraphicsImageRendererFormat preferredFormat];
        format.scale = 1;
        format.opaque = YES;
        UIImage *small = [[[UIGraphicsImageRenderer alloc] initWithSize:size format:format] imageWithActions:^(UIGraphicsImageRendererContext *context) {
            [image drawInRect:CGRectMake(0, 0, size.width, size.height)];
        }];
        [NSFileManager.defaultManager createDirectoryAtPath:MYWallpaperDirectory withIntermediateDirectories:YES attributes:nil error:NULL];
        [UIImageJPEGRepresentation(small, 0.85) writeToFile:path atomically:YES];
    });
}

// The poster's snapshot is made after a change: look for it a few times and save it as soon as it's there.
static void MYSaveWallpaperAfter(NSArray<NSNumber *> *delays) {
    for (NSNumber *delay in delays)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(delay.doubleValue * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ MYSaveWallpaper(); });
}

%group PosterBoard
%hook SBWallpaperController
- (void)wallpaperPresenter:(id)presenter didChangeWallpaperForLocations:(long long)locations withConfiguration:(id)configuration {
    %orig;
    MYSaveWallpaperAfter(@[@0.5, @1, @2, @3.5, @6]);
}
%end
%end

%ctor {
    if (!NSClassFromString(@"PBUIPosterWallpaperRemoteViewController")) return; // iOS 15: no PosterBoard
    %init(PosterBoard);
    MYSaveWallpaperAfter(@[@6, @15, @30]); // the current wallpaper, once SpringBoard is up (saved once; later tries skip it)
}
