// Settings > Material You: hosts the Android 17 Colors picker (LQSColorsViewController).
#import <UIKit/UIKit.h>
#import "LQSColorsViewController.h"
#import "LQSTheme.h"
#import "LQSVectorIcon.h"
#import "LQSStrings.h"

@interface PSViewController : UIViewController
@end

@interface MYColorsController : PSViewController
@end

@implementation MYColorsController {
    LQSColorsViewController *_colors;
}
- (void)viewDidLoad {
    [super viewDidLoad];
    NSString *root = nil;
    for (NSString *p in @[@"/var/jb/Library/Application Support/MaterialYou", @"/Library/Application Support/MaterialYou"])
        if ([[NSFileManager defaultManager] fileExistsAtPath:p]) { root = p; break; }
    if (root) {
        [LQSTheme setResourceRoot:root];
        [LQSVectorIcon setResourceDirectory:[root stringByAppendingPathComponent:@"vectors"]];
        LQSStringsSetDirectory([root stringByAppendingPathComponent:@"strings"]);
    }
    _colors = [LQSColorsViewController new];
    [self addChildViewController:_colors];
    _colors.view.frame = self.view.bounds;
    _colors.view.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleHeight;
    [self.view addSubview:_colors.view];
    [_colors didMoveToParentViewController:self];
}
- (void)viewWillAppear:(BOOL)animated { [super viewWillAppear:animated]; [self.navigationController setNavigationBarHidden:YES animated:animated]; }
- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    // Edge swipe back keeps working with the bar hidden.
    self.navigationController.interactivePopGestureRecognizer.delegate = nil;
    self.navigationController.interactivePopGestureRecognizer.enabled = YES;
}
- (void)viewWillDisappear:(BOOL)animated { [super viewWillDisappear:animated]; [self.navigationController setNavigationBarHidden:NO animated:animated]; }
@end
