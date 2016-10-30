//
//  imageStuff.m
//  Imagepicker
//
//  Created by Christoph Bretschneider on 02.11.13.
//  Copyright (c) 2013 bretto. All rights reserved.
//

#import "imageStuff.h"
#import "GPUImageLookupFilter.h"
#import "GPUImageAlphaBlendFilter.h"
#import "GPUImageBrightnessFilter.h"
#import "GPUImageExposureFilter.h"
#import "GPUImageContrastFilter.h"
#import "GPUImageSaturationFilter.h"
#import "GPUImageWhiteBalanceFilter.h"
#import "GPUImageHighlightShadowFilter.h"

@implementation imageStuff

+ (UIImage*)blendImages_brad_with_err:(UIImage*)back withTop:(UIImage*)front andAlpha:(float)alpha {
    GPUImageAlphaBlendFilter *blendFilter = [[GPUImageAlphaBlendFilter alloc] init];
    GPUImagePicture *gBack = [[GPUImagePicture alloc] initWithImage:back];
    GPUImagePicture *gFront = [[GPUImagePicture alloc] initWithImage:front];
    
    blendFilter.mix = alpha;
    [gBack addTarget:blendFilter];
    [gFront addTarget:blendFilter];
    
    [gBack processImage];
    [gFront processImage];
    
    [blendFilter useNextFrameForImageCapture];
    UIImage *newImage = [blendFilter imageFromCurrentFramebufferWithOrientation:back.imageOrientation];
    newImage = [UIImage imageWithCGImage:[newImage CGImage]
                              scale:UIScreen.mainScreen.scale
                        orientation:newImage.imageOrientation];
    return newImage;
}

+ (UIImage*)blendImages:(UIImage*)back withTop:(UIImage*)front andAlpha:(float)alpha {

    NSLog(@"alpha: %f", alpha);

    // Images must be same size. Should always be anyway
    CGSize newSize = CGSizeMake(back.size.width, back.size.height);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, back.scale);
    // CGSize newSize = CGSizeMake(back.size.width * back.scale, back.size.height * back.scale);
    // UIGraphicsBeginImageContext(newSize);
    
    // NSLog(@"checking sizes: back %f x %f x %f", back.size.width, back.size.height, back.scale);
    // NSLog(@"checking sizes: frnt %f x %f x %f", front.size.width, front.size.height, front.scale);
    
    // Use existing opacity as is
    [back drawInRect:CGRectMake(0,0,newSize.width,newSize.height)];
    // Apply supplied opacity
    [front drawInRect:CGRectMake(0,0,newSize.width,newSize.height) blendMode:kCGBlendModeNormal alpha:alpha];
    
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    // NSLog(@"checking sizes: new %f x %f x %f", newImage.size.width, newImage.size.height, newImage.scale);
    
    UIGraphicsEndImageContext();
    return newImage;

}

+ (UIImage*) resizeImage:(UIImage*)srcImage toWidth:(int)newWidth andHeight:(int)newHeight {
    
    if ((newHeight / srcImage.size.height) > (newWidth / srcImage.size.width)) {
        newHeight = srcImage.size.height*newWidth/srcImage.size.width;
    } else {
        newWidth  = srcImage.size.width*newHeight/srcImage.size.height;
    }
    NSLog(@"Resizing to %d x %d (w x h)", newWidth, newHeight);
    CGSize newSize = CGSizeMake(newWidth, newHeight);
    UIGraphicsBeginImageContextWithOptions(newSize, NO, UIScreen.mainScreen.scale);
    [srcImage drawInRect:CGRectMake(0, 0, newSize.width, newSize.height)];
    UIImage *newImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return newImage;
}

+ (UIImage*) fitImageInView:(UIImage*)srcImage andView:(UIImageView*)fitView{
    return [self resizeImage:srcImage toWidth:fitView.bounds.size.width andHeight:fitView.bounds.size.height];
}

+ (UIImage*) applyFilter:(UIImage*) srcImage set:(NSArray*)set number:(int)filterNo {
    
    UIImage *clut = [UIImage imageNamed:set[filterNo]];
    return [self applyFilter:srcImage withclut:clut];
}

+ (UIImage*) applyFilter:(UIImage*) srcImage number:(int)filterNo {

    NSArray *filterFiles = kFilterFiles;

    UIImage *clut = [UIImage imageNamed:filterFiles[filterNo]];
    return [self applyFilter:srcImage withclut:clut];
}

+ (UIImage*) applyFilter:(UIImage*) srcImage withclut:(UIImage*) filterId {
    GPUImagePicture *lookupImageSource = [[GPUImagePicture alloc] initWithImage:filterId];
    GPUImageLookupFilter *lookupFilter = [[GPUImageLookupFilter alloc] init];
    [lookupImageSource addTarget:lookupFilter atTextureLocation:1];
    [lookupImageSource processImage];
    return [self outputImageForFilter:lookupFilter andImage:srcImage];
}

+ (CGAffineTransform)videoOrientation_img:(UIImage *)thumb
{
    CGAffineTransform txf = CGAffineTransformIdentity;
    if (thumb.imageOrientation == UIImageOrientationUp) txf = CGAffineTransformMakeRotation(M_PI_2);
    if (thumb.imageOrientation == UIImageOrientationDown) txf = CGAffineTransformMakeRotation(M_PI_2 * 3);
    if (thumb.imageOrientation == UIImageOrientationLeft) txf = CGAffineTransformMakeRotation(M_PI_2 * 2);
    
    return txf;
}

+ (CGAffineTransform)videoOrientation_old:(NSURL *)videoURL
{
    NSLog(@"getting orientation: %@", videoURL.absoluteString);
    
    AVURLAsset *videoTrack = [[AVURLAsset alloc] initWithURL:videoURL options:nil];
    CGAffineTransform txf = [videoTrack preferredTransform];
    
    NSLog(@"video transform: a:%.0f b:%.0f c:%.0f d:%.0f tx:%.0f ty:%.0f", txf.a, txf.b, txf.c, txf.d, txf.tx, txf.ty);
    NSLog(@"ident transform: a:%.0f b:%.0f c:%.0f d:%.0f tx:%.0f ty:%.0f", CGAffineTransformIdentity.a, CGAffineTransformIdentity.b, CGAffineTransformIdentity.c, CGAffineTransformIdentity.d, CGAffineTransformIdentity.tx, CGAffineTransformIdentity.ty);
    
    return txf;
}

+ (CGAffineTransform)videoOrientation:(NSURL *)videoURL
{
    AVAsset *firstAsset = [AVAsset assetWithURL:videoURL];
    CGAffineTransform txf;
    txf = [[[firstAsset tracksWithMediaType:AVMediaTypeVideo] objectAtIndex:0] preferredTransform];
    return txf;
}

+ (UIImage*)setBrightness_old:(UIImage*)input to:(CGFloat)brightness
{
    UIGraphicsBeginImageContext(input.size);
    CGRect imageRect = CGRectMake(0, 0, input.size.width, input.size.height);
    CGContextRef context = UIGraphicsGetCurrentContext();
    
    // Original image
    [input drawInRect:imageRect];
    
    // Brightness overlay
    CGFloat b = brightness > 0.5 ? 1.0 : 0.0;
    NSLog(@"b: %.1f, bness: %.1f, alpha: %.2f",b,brightness,fabs(brightness-0.45)*2);
    CGContextSetFillColorWithColor(context, [UIColor colorWithRed:b green:b blue:b alpha:fabs(brightness-0.45)*2].CGColor);
    CGContextAddRect(context, imageRect);
    CGContextFillPath(context);
    
    UIImage* resultImage = UIGraphicsGetImageFromCurrentImageContext();
    UIGraphicsEndImageContext();
    
    return resultImage;
}

//output the filtered image
+ (UIImage*)outputImageForFilter:(GPUImageOutput<GPUImageInput>*)_filter andImage:(UIImage*)_image   {
    
    GPUImagePicture *filteredImage = [[GPUImagePicture alloc]initWithImage:_image];
    [filteredImage addTarget:_filter];
    [filteredImage processImage];
    [_filter useNextFrameForImageCapture];

    UIImage *retimg = [_filter imageFromCurrentFramebufferWithOrientation:_image.imageOrientation];
    retimg = [UIImage imageWithCGImage:[retimg CGImage] scale:UIScreen.mainScreen.scale orientation:retimg.imageOrientation];

    return retimg;
}

+ (UIImage*)setBrightness_brightness:(UIImage*)input to:(CGFloat)brightness
{
    // range -1.0 - 1.0 def 0.0
    GPUImageBrightnessFilter *brightnessFilter = [[GPUImageBrightnessFilter alloc] init];
    [brightnessFilter setBrightness:brightness];
    return [self outputImageForFilter:brightnessFilter andImage:input];
}

+ (UIImage*)setBrightness:(UIImage*)input to:(CGFloat)brightness
{
    // range -10.0 - 10.0 def 0.0
    GPUImageExposureFilter *exposureFilter = [[GPUImageExposureFilter alloc] init];
    [exposureFilter setExposure:brightness];
    return [self outputImageForFilter:exposureFilter andImage:input];
}

+ (UIImage*)setContrast:(UIImage*)input to:(CGFloat)contrast
{
    // range 0.0 - 4.0 def 1.0
    GPUImageContrastFilter *contrastFilter = [[GPUImageContrastFilter alloc] init];
    [contrastFilter setContrast:contrast];
    return [self outputImageForFilter:contrastFilter andImage:input];
}

+ (UIImage*)setSaturation:(UIImage*)input to:(CGFloat)saturation
{
    // range 0.0 - 2.0 def 1.0
    GPUImageSaturationFilter *saturationFilter = [[GPUImageSaturationFilter alloc] init];
    [saturationFilter setSaturation:saturation];
    return [self outputImageForFilter:saturationFilter andImage:input];
}

+ (UIImage*)setTemperature:(UIImage*)input to:(CGFloat)temperature
{
    // range 4000.0 - 7000.0 def 5000.0
    GPUImageWhiteBalanceFilter *whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    [whiteBalanceFilter setTemperature:temperature];
    return [self outputImageForFilter:whiteBalanceFilter andImage:input];
}

+ (UIImage*)setTint:(UIImage*)input to:(CGFloat)tint
{
    // range -100.0 - 100.0 def 0.0
    GPUImageWhiteBalanceFilter *whiteBalanceFilter = [[GPUImageWhiteBalanceFilter alloc] init];
    [whiteBalanceFilter setTint:tint];
    return [self outputImageForFilter:whiteBalanceFilter andImage:input];
}

+ (UIImage*)setHighlight:(UIImage*)input to:(CGFloat)highlight
{
    // range 1.0 - 0.0 def 1.0
    GPUImageHighlightShadowFilter *highlightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    [highlightShadowFilter setHighlights:highlight];
    return [self outputImageForFilter:highlightShadowFilter andImage:input];
}

+ (UIImage*)setShadow:(UIImage*)input to:(CGFloat)shadow
{
    // range 0.0 - 1.0 def 0.0
    GPUImageHighlightShadowFilter *highlightShadowFilter = [[GPUImageHighlightShadowFilter alloc] init];
    [highlightShadowFilter setShadows:shadow];
    return [self outputImageForFilter:highlightShadowFilter andImage:input];
}


@end
