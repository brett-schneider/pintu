//
//  imageStuff.h
//  Imagepicker
//
//  Created by Christoph Bretschneider on 02.11.13.
//  Copyright (c) 2013 bretto. All rights reserved.
//

#import "GPUImage.h"
#import "clutfiguration.h"

@interface imageStuff : NSObject

+ (UIImage*) blendImages:(UIImage*)back withTop:(UIImage*)front andAlpha:(float)alpha;
+ (UIImage*) resizeImage:(UIImage*)srcImage toWidth:(int)newWidth andHeight:(int)newHeight;
+ (UIImage*) fitImageInView:(UIImage*)srcImage andView:(UIImageView*)fitView;
+ (UIImage*) applyFilter:(UIImage*) srcImage number:(int)filterNo;
+ (UIImage*) applyFilter:(UIImage*) srcImage withclut:(UIImage*) filterId;
+ (UIImage*) applyFilter:(UIImage*) srcImage set:(NSArray*)set number:(int)filterNo;
+ (CGAffineTransform)videoOrientation:(NSURL *)videoURL;
+ (UIImage*)setBrightness:(UIImage*)input to:(CGFloat)brightness;
+ (UIImage*)setContrast:(UIImage*)input to:(CGFloat)contrast;
+ (UIImage*)setTemperature:(UIImage*)input to:(CGFloat)temperature;
+ (UIImage*)setTint:(UIImage*)input to:(CGFloat)tint;
+ (UIImage*)setHighlight:(UIImage*)input to:(CGFloat)highlight;
+ (UIImage*)setShadow:(UIImage*)input to:(CGFloat)shadow;

@end
