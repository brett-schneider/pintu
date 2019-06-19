//
//  ViewController.m
//  Imagepicker
//
//  Created by Christoph Bretschneider on 22.10.13.
//  Copyright (c) 2013 bretto. All rights reserved.
//

#import "FilterView.h"
#import <MobileCoreServices/MobileCoreServices.h>
#import <MobileCoreServices/UTCoreTypes.h>
#import <MediaPlayer/MediaPlayer.h>
#import "AAActivityAction/AAActivityAction.h"
#import "AAActivityAction/AAActivity.h"
#import <iAd/iAd.h>

@interface FilterView ()

@end

@implementation FilterView
const bool cAd = NO;

UIView *zoomView;
UIImageView *imageView;
UIImageView *filteredImageView;

UIImage *originalImage;
UIImage *baseImage;
UIImage *filteredImage;
UIImage *filteredId;
UIImagePickerController *imagePicker;
// NSTimeInterval maxVideoLength = 7.0;
MPMoviePlayerViewController *player;
bool movieRecording;

int currentFilter;
NSArray* currentSet;
const int cFbrightness = 100;
const int cFcontrast = 101;
const int cFtemperature = 102;
const int cFtint = 103;
const int cFhighlight = 104;
const int cFshadow = 105;

NSDictionary *appDefaults;

const int maxres = 640;

bool autosave;
bool camera;
bool replaceimage;

float alpha;
float sliderval;
const float stepper = 0.05f;
const float maxval = 0.9f;
// const float maxval = 1.0f;
NSArray *filterNames;
NSMutableArray *filterChain;
NSString *currentImage;
NSURL *video;
UIActivityIndicatorView *busy;

AAActivityAction *aa;

- (IBAction)getImage:(UIBarButtonItem *)sender {
    [_tools setHidden:YES];
    imagePicker = [[UIImagePickerController alloc] init];
    imagePicker.mediaTypes =[[NSArray alloc] initWithObjects: (NSString *) kUTTypeMovie,kUTTypeVideo,kUTTypeImage, nil];
    
    if([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
        UIActionSheet *actionSheetImageGetter = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll",@"Camera", nil];
        actionSheetImageGetter.tag = 2;
        [actionSheetImageGetter showInView:self.view];
    } else {
        UIActionSheet *actionSheetImageGetter = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Camera Roll", nil];
        actionSheetImageGetter.tag = 2;
        [actionSheetImageGetter showInView:self.view];
        NSLog(@"actionsheet getimage shown");
    }
}

- (IBAction)saveImage:(UIBarButtonItem *)sender {
    [_tools setHidden:YES];
    if (filteredImage != nil) {
        UIActionSheet *actionSheetSaveResolution;
        actionSheetSaveResolution = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"Cancel" destructiveButtonTitle:nil otherButtonTitles:@"Save to Camera Roll",nil];
        actionSheetSaveResolution.tag = 3;
        [actionSheetSaveResolution showInView:self.view];
    }
}

- (void)showTheSheet:(NSArray*)Names andCluts:(NSArray*)Cluts {
    if (imageView.image) {
        if (aa.isShowing) {
            [aa dismissActionSheet];
        } else {
            AAImageSize imageSize = AAImageSizeNormal; // AAImageSizeSmall
            UIImage *yep = (self.switchcept.on ? (currentFilter == -1 ? imageView.image : [imageStuff blendImages:imageView.image withTop:filteredImage andAlpha:(replaceimage ? 1.0f : alpha)]) : imageView.image);
            unsigned long w = CGImageGetWidth([yep CGImage]);
            unsigned long h = CGImageGetHeight([yep CGImage]);
            NSLog(@"useImage.size %fx%f, useImage.scale %f", yep.size.width, yep.size.height, yep.scale);
            CGRect cropRect = CGRectMake( h >= w ? 0 : (w - h) / 2
                                         , w >= h ? 0 : (h - w) / 2
                                         , h >= w ? w : h
                                         , h >= w ? w : h);
            NSLog(@"Creating CGRect: x:%f y:%f w:%f h:%f", cropRect.origin.x, cropRect.origin.y, cropRect.size.width, cropRect.size.height);
            CGImageRef imageRef = CGImageCreateWithImageInRect([yep CGImage], cropRect);
            yep = [UIImage imageWithCGImage:imageRef scale:yep.scale orientation:yep.imageOrientation];
            CGImageRelease(imageRef);
            NSLog(@"size after crop %fx%f, scale %f", yep.size.width, yep.size.height, yep.scale);
            UIImage *baseIcon = [imageStuff resizeImage:yep toWidth:imageSize andHeight:imageSize];
            NSLog(@"baseIcon.size %fx%f, baseIcon.scale %f", baseIcon.size.width, baseIcon.size.height, baseIcon.scale);
            NSMutableArray *actionArray = [NSMutableArray array];
            for (int i=0; i<Names.count; i++) {
                NSLog(@"preview filtre numéro %d (%@)",i,Names[i]);
                UIImage *image = [imageStuff applyFilter:baseIcon set:Cluts number:i];
                AAActivity *activity = [[AAActivity alloc] initWithTitle:Names[i]
                                                                   image:image
                                                             actionBlock:^(AAActivity *activity, NSArray *activityItems)
                                        {
                                            NSLog(@"doing activity = %@, activityItems = %@", activity, activityItems);
                                            [self filterAction:i withset:Cluts];
                                            [_tools setHidden:YES];
                                        }
                                        ];
                [actionArray addObject:activity];
            }
            
            aa = [[AAActivityAction alloc] initWithActivityItems:@[] applicationActivities:actionArray imageSize:imageSize];
            aa.title = @"select a filter";
            [aa show];
        }
    }
}

- (IBAction)editImage:(UIBarButtonItem *)sender {
    [_tools setHidden:YES];
    NSArray* set = kFilterFiles;
    NSArray* names = kFilterNames;
    [self showTheSheet:names andCluts:set];
}

- (IBAction)moveSlider:(UISlider *)sender {
    // imageView.alpha = self.slider.value;
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        alpha = round(sender.value*maxval*(1.0f/stepper))/(1.0f/stepper);
        // [imageView setImage:[imageStuff blendImages:baseImage withTop:filteredImage andAlpha:alpha]];
        [filteredImageView setAlpha:alpha];
        // NSLog(@"set alpha to %4f", alpha);
    }
}

- (IBAction)moveSliderBrightness:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        // NSLog(@"setting brightness to %f",sender.value);
        alpha = round(sender.value*(1.0f/stepper))/(1.0f/stepper);
        filteredImage = [imageStuff setBrightness:baseImage to:alpha*2.0f-1.0f];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)moveSliderContrast:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        alpha = round(sender.value*(1.0f/stepper))/(1.0f/stepper);
        filteredImage = [imageStuff setContrast:baseImage to:(alpha+0.25f)*2];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)moveSliderTemperature:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        alpha = round(sender.value*(1.0f/stepper))/(1.0f/stepper);
        // NSLog(@"Temp %0f", 4000.0f+alpha*3000.0f);
        filteredImage = [imageStuff setTemperature:baseImage to:4000.0f+alpha*3000.0f];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)moveSliderTint:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        // NSLog(@"setting brightness to %f",sender.value);
        alpha = round(sender.value*(1.0f/stepper))/(1.0f/stepper);
        filteredImage = [imageStuff setTint:baseImage to:alpha*200.0f-100.0f];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)moveSliderHighlight:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        // NSLog(@"setting brightness to %f",sender.value);
        alpha = round(sender.value*maxval*(1.0f/stepper))/(1.0f/stepper);
        filteredImage = [imageStuff setHighlight:baseImage to:1.0f-alpha];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)moveSliderShadow:(UISlider *)sender {
    if (fabsf(sender.value-alpha) >= stepper || sender.value == 1.0f || sender.value == 0.0f) {
        // NSLog(@"setting brightness to %f",sender.value);
        alpha = round(sender.value*maxval*(1.0f/stepper))/(1.0f/stepper);
        filteredImage = [imageStuff setShadow:baseImage to:alpha];
        [filteredImageView setImage:filteredImage];
        [filteredImageView setAlpha:1.0f];
    }
}

- (IBAction)switchceptFlipped:(UISwitch *)sender {
    // for debugging
    // sometimes viewDidLoad is a wee bit early
    // UIImage *jaja = [UIImage imageNamed:@"gru_n.png"];
    // [imageView setImage:jaja];
    
}

- (IBAction)tools:(UIBarButtonItem *)sender {
    if ([_tools isHidden] && imageView.image) {
        [_tools setHidden:NO];
    } else {
        [_tools setHidden:YES];
    }
}

- (IBAction)vorherNachher:(UIBarButtonItem *)sender {
}

-(void)applyChanges
{
    if (currentFilter > -1) {
        if (self.switchcept.on) {
            if (currentFilter < currentSet.count) {
                filteredId = [imageStuff blendImages:filteredId withTop:[imageStuff applyFilter:filteredId set:currentSet number:currentFilter] andAlpha:alpha];
            } else if (currentFilter == cFbrightness) {
                filteredId = [imageStuff setBrightness:filteredId to:alpha*2.0f-1.0f];
            } else if (currentFilter == cFcontrast) {
                filteredId = [imageStuff setContrast:filteredId to:(alpha+0.25f)*2];
            } else if (currentFilter == cFtemperature) {
                filteredId = [imageStuff setTemperature:filteredId to:4000.0f+alpha*3000.0f];
            } else if (currentFilter == cFtint) {
                filteredId = [imageStuff setTint:filteredId to:alpha*200.0f-100.0f];
            } else if (currentFilter == cFhighlight) {
                filteredId = [imageStuff setHighlight:filteredId to:1.0f-alpha];
            } else if (currentFilter == cFshadow) {
                filteredId = [imageStuff setShadow:filteredId to:alpha];
            }
            
            // standardbild anpassen
            // aktuelles Bild als Basis übernehmen wenn switch an ist
            if (replaceimage) {
                baseImage = filteredImage;
            } else {
                baseImage = [imageStuff blendImages:baseImage withTop:filteredImage andAlpha:alpha];
            }
            [imageView setImage:baseImage];
        }
    }
}

-(void)prepareFilter
{
    UIImage *finalId;
    if (self.switchcept.on && currentFilter > -1) {
        if (currentFilter < currentSet.count) {
            finalId = [imageStuff blendImages:filteredId withTop:[imageStuff applyFilter:filteredId set:currentSet number:currentFilter] andAlpha:alpha];
        } else if (currentFilter == cFbrightness) {
            NSLog(@"brightness finale");
            finalId = [imageStuff setBrightness:filteredId to:alpha*2.0f-1.0f];
        } else if (currentFilter == cFcontrast) {
            NSLog(@"contrast finale");
            finalId = [imageStuff setContrast:filteredId to:(alpha+0.25f)*2];
        } else if (currentFilter == cFtemperature) {
            NSLog(@"temperature finale");
            finalId = [imageStuff setTemperature:filteredId to:4000.0f+alpha*3000.0f];
        } else if (currentFilter == cFtint) {
            NSLog(@"tint finale");
            finalId = [imageStuff setTint:filteredId to:alpha*200.0f-100.0f];
        } else if (currentFilter == cFhighlight) {
            NSLog(@"highlight finale");
            finalId = [imageStuff setHighlight:filteredId to:1.0f-alpha];
        } else if (currentFilter == cFshadow) {
            NSLog(@"shadow finale");
            finalId = [imageStuff setShadow:filteredId to:alpha];
        }
        NSLog(@"final filter generated");
    } else {
        finalId = filteredId;
        NSLog(@"final filter taken from filteredId");
    }
    filteredId = finalId;
    filter = [[GPUImageLookupFilter alloc] init];
    lookupImageSource = [[GPUImagePicture alloc] initWithImage:finalId];
    [lookupImageSource addTarget:filter atTextureLocation:1];
    [lookupImageSource processImage];
}

-(void)filterAction:(int) filterIndex
{
    NSArray* set = kFilterFiles;
    [self filterAction:filterIndex withset:set];
}

-(void)filterAction:(int) filterIndex withset:(NSArray*)set
{
    [self applyChanges];
    filteredImage = [imageStuff applyFilter:baseImage set:set number:filterIndex];
    NSLog(@"filtered image dimensions: w:%f h:%f s:%f o:%ld", filteredImage.size.width, filteredImage.size.height, filteredImage.scale, (long)filteredImage.imageOrientation);
    if (maxval < 1.0f) {
        filteredImage = [imageStuff blendImages:baseImage withTop:filteredImage andAlpha:maxval];
        NSLog(@"updated filteredimage to alpha %4f", maxval);
        // NSLog(@"filtered image dimensions: w:%f h:%f s:%f o:%d", filteredImage.size.width, filteredImage.size.height, filteredImage.scale, filteredImage.imageOrientation);
    }
    [filteredImageView setImage:filteredImage];
    
    currentFilter = filterIndex;
    currentSet = set;
    self.slider.enabled = YES;
    self.slider.value = 1.0f;
    [filteredImageView setAlpha:maxval];
    alpha = maxval;
    [self.switchcept setOn:NO animated:YES];
    
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSlider:) forControlEvents:UIControlEventValueChanged];
    replaceimage = NO;
}

- (void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex
{
    NSLog(@"actionsheet tag %ld, selected %ld",(long)actionSheet.tag, (long)buttonIndex);
    if (actionSheet.tag == 1) {
        // Filter aussuchen
        if (buttonIndex != 13) {
            NSLog(@"Filter %ld selected through action sheet", (long)buttonIndex);
            [self filterAction:(int)buttonIndex];
        }
        
    } else if (actionSheet.tag == 2) {
        // Bild holen
        
        if (buttonIndex == 0)
        {
            // camera roll
            [imagePicker setSourceType:UIImagePickerControllerSourceTypePhotoLibrary];
            [imagePicker setDelegate:self];
            [imagePicker setAllowsEditing:YES];
            // [imagePicker setVideoMaximumDuration:maxVideoLength];
            [self presentViewController:imagePicker animated:YES completion:nil];
            NSLog(@"view controller imagePicker presented");
            camera = NO;
        } else if (buttonIndex == 1) {
            // camera (bzw cancel wenn keine da ist)
            if ([UIImagePickerController isSourceTypeAvailable:UIImagePickerControllerSourceTypeCamera]) {
                [imagePicker setSourceType:UIImagePickerControllerSourceTypeCamera];
                [imagePicker setDelegate:self];
                [imagePicker setAllowsEditing:NO];
                // [imagePicker setAllowsEditing:YES];
                // [imagePicker setVideoMaximumDuration:maxVideoLength];
                [self presentViewController:imagePicker animated:YES completion:nil];
                camera = YES;
            }
        }
        // NSLog(@"buttonIndex: %d", buttonIndex);
    } else if (actionSheet.tag == 3) {
        BOOL save = YES;
        if (video) {
            // Video durch Filterchain prügeln
            [self prepareFilter];
            CGSize savesize;
            if (buttonIndex == 0) {
                if (originalImage.size.width > originalImage.size.height) {
                    savesize = CGSizeMake(originalImage.size.width, originalImage.size.height);
                    NSLog(@"savesize w:%f h:%f (landscape)",originalImage.size.width, originalImage.size.height);
                } else {
                    savesize = CGSizeMake(originalImage.size.height, originalImage.size.width);
                    NSLog(@"savesize w:%f h:%f (portrait)",originalImage.size.height, originalImage.size.width);
                }
            } else {
                save = NO;
            }
            
            if (save) {
                // also nicht cancel
                if (movieRecording) {
                    //                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"Processing" message:@"still processing previous video" delegate:self cancelButtonTitle:@"okay" otherButtonTitles:nil];
                    NSLog(@"todo: alert");
                } else {
                    [self startBusy];
                    movieFile = [[GPUImageMovie alloc] initWithURL:video];
                    [movieFile addTarget:filter];
                    
                    pathToMovie = [NSHomeDirectory() stringByAppendingPathComponent:@"Documents/Movie.m4v"];
                    unlink([pathToMovie UTF8String]);
                    NSURL *movieURL = [NSURL fileURLWithPath:pathToMovie];
                    
                    movieWriter = [[GPUImageMovieWriter alloc] initWithMovieURL:movieURL size:savesize];
                    [filter addTarget:movieWriter];
                    
                    movieWriter.shouldPassthroughAudio = YES;
                    movieFile.audioEncodingTarget = movieWriter;
                    [movieFile enableSynchronizedEncodingUsingMovieWriter:movieWriter];
                    
                    // NSLog(@"%@", movieFile);
                    
                    [movieWriter startRecordingInOrientation:[imageStuff videoOrientation:video]];
                    // [movieWriter startRecordingInOrientation:CGAffineTransformIdentity];
                    // [movieWriter startRecording];
                    movieRecording = YES;
                    [movieFile startProcessing];
                    [movieWriter setCompletionBlock:^{
                        NSLog(@"Recording done");
                        [movieWriter finishRecording];
                        [filter removeTarget:movieWriter];
                        UISaveVideoAtPathToSavedPhotosAlbum(pathToMovie,nil,nil,nil);
                        movieRecording = NO;
                        [self stopBusy];
                    }];
                }
            }
            
        } else {
            // Bild speichern
            self.switchcept.on ? NSLog(@"saving filtered") : NSLog(@"saving unfiltered");
            [self prepareFilter];
            if (buttonIndex == 0)
                NSLog(@"der finale applyfilter");
            UIImageWriteToSavedPhotosAlbum([imageStuff applyFilter:originalImage withclut:filteredId], nil, nil, nil);
        }
    }
    
}


-(void) imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary *)info
{
    NSLog(@"image Picker finished");
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self.slider setEnabled:NO];
    NSLog(@"%@", info);
    currentImage = [info objectForKey: UIImagePickerControllerReferenceURL];
    
    if ([mediaType isEqual: @"public.image"]) {
        NSLog(@"image");
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self setupimg:image];
    } else if ([mediaType isEqualToString:@"public.movie"]) {
        NSLog(@"Picked a movie at URL %@",  [info objectForKey:UIImagePickerControllerMediaURL]);
        NSLog(@"movie attributes are: %@", info);
        NSURL *url =  [info objectForKey:UIImagePickerControllerMediaURL];
        [self setupvid:url];
    }
    filteredId = [UIImage imageNamed:@"id.png"];
}

-(NSString*) GetUUID
{
    CFUUIDRef theUUID = CFUUIDCreate(NULL);
    CFStringRef string = CFUUIDCreateString(NULL, theUUID);
    CFRelease(theUUID);
    return (__bridge NSString *)string;
}

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

-(void)startBusy
{
    NSLog(@"busy on");
    [self.masterView setUserInteractionEnabled:NO];
    [self.masterView setAlpha:0.3f];
    [self.masterView setBackgroundColor:[UIColor grayColor]];
    CGRect screenRect = [[UIScreen mainScreen] bounds];
    CGRect busyRect = CGRectMake((screenRect.size.width / 2) - 50 , (screenRect.size.height / 2) - 50, 100, 100);
    busy = [[UIActivityIndicatorView alloc] initWithFrame:busyRect];
    busy.transform = CGAffineTransformMakeScale(2.0f,2.0f);
    [self.masterView addSubview:busy];
    [self.masterView bringSubviewToFront:busy];
    [busy startAnimating];
}

-(void)stopBusy
{
    [busy removeFromSuperview];
    [self.masterView setBackgroundColor:[UIColor whiteColor]];
    [self.masterView setAlpha:maxval];
    [self.masterView setUserInteractionEnabled:YES];
    [self.masterView setNeedsDisplay];
    NSLog(@"busy off");
}

- (IBAction)doHold:(UILongPressGestureRecognizer *)sender {
    [_tools setHidden:YES];
    if (_pressed.state == UIGestureRecognizerStateBegan) {
        [imageView setImage:originalImage];
        [filteredImageView setAlpha:0.0f];
        NSLog(@"DOWN");
        
        NSLog(@"scrollView frame        x:%3.0f y:%3.0f w:%3.0f h:%3.0f", self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
        NSLog(@"zoomView frame          x:%3.0f y:%3.0f w:%3.0f h:%3.0f", zoomView.frame.origin.x, zoomView.frame.origin.y, zoomView.frame.size.width, zoomView.frame.size.height);
        // CGAffineTransform transform = [imageStuff videoOrientation:video];
        
    } else if (_pressed.state == UIGestureRecognizerStateEnded) {
        [imageView setImage:baseImage];
        [filteredImageView setAlpha:[self.slider value]];
        NSLog(@"BACK UP // alpha: %f", [self.slider value]);
        // NSLog(@"temp image w:%f h:%f s:%f o:%d", tempImage.size.width, tempImage.size.height, tempImage.scale, tempImage.imageOrientation);
    }
}

- (UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView{
    return zoomView;
}


- (void)viewDidLoad
{
    [super viewDidLoad];
    [self setCanDisplayBannerAds:cAd];
    // Do any additional setup after loading the view, typically from a nib.
    
    [_tools setHidden:YES];
    replaceimage = NO;
    
    autosave = [[NSUserDefaults standardUserDefaults] boolForKey:@"autosave"];
    
    if (autosave) NSLog(@"autosave is on"); else NSLog(@"autosave is off");
    
    // [self reconize];
    [self.slider setEnabled:NO];
    
    filterNames = kFilterNames;
    filteredId = [UIImage imageNamed:@"id.png"];
    
    movieRecording = NO;
    
    zoomView = [[UIView alloc] init];
    imageView = [[UIImageView alloc] init];
    filteredImageView = [[UIImageView alloc] init];
    [self.scrollView addSubview:zoomView];
    [zoomView addSubview:imageView];
    [zoomView addSubview:filteredImageView];
    
    //    [self.scrollView addGestureRecognizer:_pinch];
    //    [self.scrollView addGestureRecognizer:_pan];
    [self.scrollView addGestureRecognizer:_tappy];
    [self.scrollView setMaximumZoomScale:1.0f];
    [self.scrollView setDelegate:self];
    
    UIView *refreshButtonView = [_vorherNachherButton valueForKey:@"view"];
    [refreshButtonView addGestureRecognizer:_pressed];
    
}

- (IBAction)tap:(UITapGestureRecognizer *)sender {
    NSLog(@"whoopie");
    [_tools setHidden:YES];
}

- (IBAction)brightness:(UIBarButtonItem *)sender {
    [self applyChanges];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderBrightness:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:0.5f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFbrightness;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setBrightness:baseImage to:0.0f];
    [filteredImageView setImage:filteredImage];
}

- (IBAction)contrast:(UIBarButtonItem *)sender {
    [self applyChanges];
    // NSArray* set = kContrastFiles;
    // NSArray* names = kContrastNames;
    // [self showTheSheet:names andCluts:set];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderContrast:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:0.25f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFcontrast;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setContrast:baseImage to:1.0f];
    [filteredImageView setImage:filteredImage];
}

/*
 - (IBAction)highlights:(UIBarButtonItem *)sender {
 // NSArray* set = kHighlightsFiles;
 // NSArray* names = kHighlightsNames;
 // [self showTheSheet:names andCluts:set];
 [self filterAction:0 withset:kHighlightsFiles];
 [_tools setHidden:YES];
 }
 */

- (IBAction)highlights:(UIBarButtonItem *)sender {
    [self applyChanges];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderHighlight:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:1.0f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFhighlight;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setHighlight:baseImage to:0.0f];
    [filteredImageView setImage:filteredImage];
}

- (IBAction)shadows:(UIBarButtonItem *)sender {
    [self applyChanges];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderShadow:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:1.0f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFshadow;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setShadow:baseImage to:1.0f];
    [filteredImageView setImage:filteredImage];
}

- (IBAction)temperature:(UIBarButtonItem *)sender {
    [self applyChanges];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderTemperature:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:0.33f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFtemperature;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setTemperature:baseImage to:5000.0f];
    [filteredImageView setImage:filteredImage];
}

- (IBAction)tint:(UIBarButtonItem *)sender {
    [self applyChanges];
    
    // slider to something else
    [_slider removeTarget:self action:nil forControlEvents:UIControlEventValueChanged];
    [_slider addTarget:self action:@selector(moveSliderTint:) forControlEvents:UIControlEventValueChanged];
    [_tools setHidden:YES];
    [_slider setValue:0.5f];
    self.slider.enabled = YES;
    replaceimage = YES;
    currentFilter = cFtint;
    [self.switchcept setOn:NO animated:YES];
    
    // init
    filteredImage = [imageStuff setTint:baseImage to:0.0f];
    [filteredImageView setImage:filteredImage];
}

- (void)requestFinishThumbnail:(NSNotification*)notification
{
    NSLog(@"Thumbnail request finished");
    
    UIImage *image = [notification.userInfo objectForKey:MPMoviePlayerThumbnailImageKey];
    
    // Keep Pointer to original Image
    originalImage = image;
    NSLog(@"thumb retained");
    
    baseImage = originalImage;
    [imageView setImage:originalImage];
    
    originalImage = image;
    baseImage = originalImage;
    
    [_scrollView setZoomScale:1.0f];
    [_scrollView setMaximumZoomScale:8.0f];
    [imageView setImage:originalImage];
    [imageView sizeToFit];
    [filteredImageView setImage:originalImage];
    [filteredImageView sizeToFit];
    [filteredImageView setAlpha:(maxval/2)];
    [zoomView setFrame:imageView.frame];
    
    float zw = zoomView.frame.size.width;
    float zh = zoomView.frame.size.height;
    float sw = self.scrollView.frame.size.width;
    float sh = self.scrollView.frame.size.height;
    
    float mzs = sw/zw > sh/zh ? sh/zh : sw/zw;
    self.scrollView.minimumZoomScale = mzs; // 1.0f;
    self.scrollView.zoomScale = mzs;
    self.scrollView.maximumZoomScale = 5.0f;
    
    // [player.view removeFromSuperview];
    self.slider.enabled = NO;
}

- (void)setupimg:(UIImage *)image {
    image = [UIImage imageWithCGImage:[image CGImage] scale:UIScreen.mainScreen.scale orientation:image.imageOrientation];
    if (camera && autosave) {
        NSLog(@"autosave captured image");
        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil);
    }
    originalImage = image;
    image = [imageStuff resizeImage:image toWidth:maxres andHeight:maxres];
    
    baseImage = image;
    // NSLog(@"originalImage w:%f h:%f s:%f o:%d", originalImage.size.width, originalImage.size.height, originalImage.scale, originalImage.imageOrientation);
    
    [self.scrollView setZoomScale:1.0f];
    [imageView setImage:baseImage];
    [imageView sizeToFit];
    [filteredImageView setImage:image];
    [filteredImageView sizeToFit];
    [filteredImageView setAlpha:(maxval/2)];
    [zoomView setFrame:imageView.frame];
    
    NSLog(@"scrollView frame        x:%3.0f y:%3.0f w:%3.0f h:%3.0f", self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSLog(@"zoomView frame          x:%3.0f y:%3.0f w:%3.0f h:%3.0f", zoomView.frame.origin.x, zoomView.frame.origin.y, zoomView.frame.size.width, zoomView.frame.size.height);
    
    float zw = zoomView.frame.size.width;
    float zh = zoomView.frame.size.height;
    float sw = self.scrollView.frame.size.width;
    float sh = self.scrollView.frame.size.height;
    
    float mzs = sw/zw > sh/zh ? sh/zh : sw/zw;
    self.scrollView.minimumZoomScale = mzs; // 1.0f;
    self.scrollView.zoomScale = mzs;
    self.scrollView.maximumZoomScale = 5.0f;
    
    // DEBUG
    NSLog(@"scrollView frame        x:%3.0f y:%3.0f w:%3.0f h:%3.0f", self.scrollView.frame.origin.x, self.scrollView.frame.origin.y, self.scrollView.frame.size.width, self.scrollView.frame.size.height);
    NSLog(@"zoomView frame          x:%3.0f y:%3.0f w:%3.0f h:%3.0f", zoomView.frame.origin.x, zoomView.frame.origin.y, zoomView.frame.size.width, zoomView.frame.size.height);
    
    [self dismissViewControllerAnimated:YES completion:nil];
    self.slider.enabled = NO;
    currentFilter = -1;
    video = nil;
    filteredId = [UIImage imageNamed:@"id.png"];
}

- (void) setupvid:(NSURL*) url {
    if (camera && autosave) {
        NSLog(@"autosaving movie");
        NSString *myPath = [url path];
        UISaveVideoAtPathToSavedPhotosAlbum(myPath,nil,nil,nil);
    }
    [self dismissViewControllerAnimated:YES completion:nil];
    
    player = [[MPMoviePlayerViewController alloc] initWithContentURL: url];
    [[player moviePlayer] setShouldAutoplay:NO];
    NSLog(@"request video thumb");
    video = url;
    [[player moviePlayer] requestThumbnailImagesAtTimes:[NSArray arrayWithObject:[NSNumber numberWithFloat:0.0f]] timeOption:MPMovieTimeOptionNearestKeyFrame];
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(requestFinishThumbnail:) name:MPMoviePlayerThumbnailImageRequestDidFinishNotification object:nil];
    currentFilter = -1;
    filteredId = [UIImage imageNamed:@"id.png"];
}

- (void) setmeup {
    NSLog(@"setting up");
    
    NSString *mediaType = [info objectForKey:UIImagePickerControllerMediaType];
    [self.slider setEnabled:NO];
    
    if (self.imageIn) {
        NSLog(@"image");
        UIImage *image = [info objectForKey:UIImagePickerControllerOriginalImage];
        [self setupimg:self.imageIn];
    } else if (self.movieURL) {
        [self setupvid:self.movieURL];
    }
}

@end
