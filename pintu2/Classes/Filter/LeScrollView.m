//
//  LeScrollView.m
//  Filtr
//
//  Created by Christoph Bretschneider on 09.02.14.
//  Copyright (c) 2014 bretto. All rights reserved.
//

#import "LeScrollView.h"

@implementation LeScrollView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        // Initialization code
    }
    return self;
}

- (void)listSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return;
    
    for (UIView *subview in subviews) {
        
        // Do what you want to do with the subview
        NSLog(@"%@", subview);
        
        // List the subviews of subview
        [self listSubviewsOfView:subview];
    }
}

- (UIView *)getFirstSubviewsOfView:(UIView *)view {
    
    // Get the subviews of the view
    NSArray *subviews = [view subviews];
    
    // Return if there are no subviews
    if ([subviews count] == 0) return nil;
    
    for (UIView *subview in subviews) {
        return subview;
    }
    return nil;
}

- (void)layoutSubviews {
    [super layoutSubviews];
    
    // center the image as it becomes smaller than the size of the screen
    CGSize boundsSize = self.bounds.size;
    UIView *centerView = [self getFirstSubviewsOfView:self];
    CGRect frameToCenter = centerView.frame;
    
    NSLog(@"scrollView frame        x:%3.0f y:%3.0f w:%3.0f h:%3.0f", self.frame.origin.x, self.frame.origin.y, self.frame.size.width, self.frame.size.height);
    NSLog(@"zoomView frame          x:%3.0f y:%3.0f w:%3.0f h:%3.0f", frameToCenter.origin.x, frameToCenter.origin.y, frameToCenter.size.width, frameToCenter.size.height);
    
    // center horizontally
    if (frameToCenter.size.width < boundsSize.width) {
        frameToCenter.origin.x = (boundsSize.width - frameToCenter.size.width) / 2;
        NSLog(@"horizontally centered, frametocenter.origin.x: %f", frameToCenter.origin.x);
    }
    else {
        frameToCenter.origin.x = 0;
    }
    // center vertically
    if (frameToCenter.size.height < boundsSize.height) {
        frameToCenter.origin.y = (boundsSize.height - frameToCenter.size.height) / 2;
        NSLog(@"vertically centered, frametocenter.origin.y: %f", frameToCenter.origin.y);
    }
    else
        frameToCenter.origin.y = 0;
    
    centerView.frame = frameToCenter;
    // NSLog(@"new viewtocenterframe: x:%f  y:%f  w:%f  h:%f", frameToCenter.origin.x, frameToCenter.origin.y, frameToCenter.size.width, frameToCenter.size.height);
}

/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    // Drawing code
}
*/

@end
