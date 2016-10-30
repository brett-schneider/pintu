//
//  ViewController.h
//  Imagepicker
//
//  Created by Christoph Bretschneider on 22.10.13.
//  Copyright (c) 2013 bretto. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "imageStuff.h"

@interface FilterView : UIViewController<UINavigationControllerDelegate, UIImagePickerControllerDelegate, UIActionSheetDelegate, UIScrollViewDelegate>
{
    GPUImageMovie *movieFile;
    GPUImageOutput<GPUImageInput> *filter;
    GPUImageMovieWriter *movieWriter;
    GPUImagePicture *lookupImageSource;
    NSString *pathToMovie;
    
}
@property (strong, nonatomic) IBOutlet UITapGestureRecognizer *tappy;
@property (weak, nonatomic) IBOutlet UIToolbar *tools;
@property (strong, nonatomic) IBOutlet UIView *masterView;
@property (weak, nonatomic) IBOutlet UISwitch *switchcept;
@property (weak, nonatomic) IBOutlet UISlider *slider;
@property (strong, nonatomic) IBOutlet UILongPressGestureRecognizer *pressed;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *vorherNachherButton;
- (IBAction)tap:(UITapGestureRecognizer *)sender;
- (IBAction)getImage:(UIBarButtonItem *)sender;
- (IBAction)saveImage:(UIBarButtonItem *)sender;
- (IBAction)editImage:(UIBarButtonItem *)sender;
- (IBAction)moveSlider:(UISlider *)sender;
- (IBAction)switchceptFlipped:(UISwitch *)sender;
- (IBAction)tools:(UIBarButtonItem *)sender;
- (IBAction)doHold:(UILongPressGestureRecognizer *)sender;
- (IBAction)brightness:(UIBarButtonItem *)sender;
- (IBAction)contrast:(UIBarButtonItem *)sender;
- (IBAction)highlights:(UIBarButtonItem *)sender;
- (IBAction)shadows:(UIBarButtonItem *)sender;
- (IBAction)temperature:(UIBarButtonItem *)sender;
- (IBAction)tint:(UIBarButtonItem *)sender;

// slave mode 
@property (weak, nonatomic) IBOutlet UIImage *imageIn;
@property (weak, nonatomic) IBOutlet NSURL *movieURL;
@property (weak, nonatomic) IBOutlet UIBarButtonItem *backButton;

@end
