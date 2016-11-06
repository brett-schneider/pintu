/*
 Copyright (C) 2015 Apple Inc. All Rights Reserved.
 See LICENSE.txt for this sample’s licensing information
 
 Abstract:
 View controller for camera interface.
 */

@import AVFoundation;
@import Photos;
@import AssetsLibrary;

#import "AcquireLib.h"
#import "AssetsDataIsInaccessibleViewController.h"
#import "pintu3-Swift.h"

#define kMinVisibleHeightImageView 20.0

static void * CapturingStillImageContext = &CapturingStillImageContext;
static void * SessionRunningContext = &SessionRunningContext;

static NSString* albumSelectorSegue = @"albumSelectorSegue";
static NSString* libLocationSelectorSegue = @"libLocationSelectorSegue";

typedef NS_ENUM( NSInteger, AVCamSetupResult ) {
    AVCamSetupResultSuccess,
    AVCamSetupResultCameraNotAuthorized,
    AVCamSetupResultSessionConfigurationFailed
};

@interface AcquireLib () <AlbumSelectorDelegate>

// Camera Roll Collection
@property (nonatomic, strong) ALAssetsLibrary *assetsLibrary;
@property (nonatomic, strong) NSMutableArray *assets;
@property (nonatomic, strong) ALAssetsGroup *assetsGroup;
@property (nonatomic, strong) NSMutableArray *groups;

// Navigation and Preview
@property (weak, nonatomic) IBOutlet UIImageView *bigImageView;
@property (weak, nonatomic) IBOutlet UINavigationItem *topNav;
@property (strong, nonatomic) IBOutlet AVPlayer* player;
@property (weak, nonatomic) IBOutlet AVPlayerLayer* playerLayer;

// Scrollview
@property (strong, nonatomic) IBOutlet UIView *rootView;
@property (weak, nonatomic) IBOutlet UIScrollView *scrollView;
@property (weak, nonatomic) IBOutlet UIView *contentView;

@end

@implementation AcquireLib

static NSString *const reuseIdentifierPhotoCell = @"photoCell";
CGImageRef selected;
NSDictionary* metadata;
NSURL* selectedurl;

- (void)viewDidLoad
{
    [super viewDidLoad];
    NSLog(@"viewDidLoad");
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    NSLog(@"viewWillAppear:%d", animated);
    if (!self.assetsLibrary) [self initPhotoGrid];
}

-(void)calcAllSizes {
    NSLog(@"sizing views");
    // size it all
    [self.scrollView setZoomScale:1.0];
    CGFloat w = self.rootView.frame.size.width;
    CGFloat h = self.rootView.frame.size.height;
    [self.scrollView setFrame:CGRectMake(0.0, 0.0, w, h)];
    self.scrollView.contentSize = CGSizeMake(w, w+h-kMinVisibleHeightImageView);
    self.contentView.autoresizesSubviews = YES;
    [self.contentView setFrame:CGRectMake(0.0, 0.0, w, w+h-kMinVisibleHeightImageView)];
    [self.contentViewHeight setConstant:w+h-kMinVisibleHeightImageView];
}

-(void)adjustContentViewHeight {
    NSLog(@"adjusting contentview height to match collectionView content height (%.1f) plus imageview height (%.1f)", self.collectionView.contentSize.height, self.bigImageView.frame.size.height);
    CGFloat newheight = self.collectionView.contentSize.height+self.bigImageView.frame.size.height;
    if (newheight < self.contentViewHeight.constant) {
        if (newheight > self.rootView.frame.size.height) {
            [self.contentViewHeight setConstant:self.collectionView.contentSize.height+self.bigImageView.frame.size.height];
        } else {
            [self.contentViewHeight setConstant:self.rootView.frame.size.height];
        }
    }
}

- (void)enumAssets:(ALAssetsGroup*)group {
    // (re-)init collection
    if (!self.assets) {
        _assets = [[NSMutableArray alloc] init];
    } else {
        [self.assets removeAllObjects];
    }
    
    ALAssetsGroupEnumerationResultsBlock assetsEnumerationBlock = ^(ALAsset *result, NSUInteger index, BOOL *stop) {
        if (result) {
            [self.assets insertObject:result atIndex:0];
        } else {
            NSLog(@"done enumerating, time to reload collectionview and set preview");
            [self.collectionView reloadData];
            if (!self.bigImageView.image) {
                if ([self.assets objectAtIndex:0])
                    [self showPreview:[self.assets objectAtIndex:0]];
            }
            [self.collectionView layoutIfNeeded];
            [self calcAllSizes];
            [self adjustContentViewHeight];
        }
    };
    
    // ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
    // NSLog(@"prepare assets from assetsgroup %@", group);
    // [group setAssetsFilter:onlyPhotosFilter];
    ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
    [group setAssetsFilter:allAssetsFilter];
    [group enumerateAssetsUsingBlock:assetsEnumerationBlock];
}

- (void)selectAssetsGroup:(ALAssetsGroup*)assetsGroup {
    NSLog(@"setting the assetsGroup to %@", assetsGroup);
    self.assetsGroup = assetsGroup;
    self.navigationItem.title = [self.assetsGroup valueForProperty:ALAssetsGroupPropertyName];
    self.bigImageView.image = nil;
    [self enumAssets:self.assetsGroup];
}

- (void)initPhotoGrid {
    NSLog(@"initialising... library, groups, etc");
    // do everything to get the photos in the collection view
    // init assetsLibrary
    if (self.assetsLibrary == nil) {
        _assetsLibrary = [[ALAssetsLibrary alloc] init];
    }
    // init groups
    if (self.groups == nil) {
        _groups = [[NSMutableArray alloc] init];
    } else {
        [self.groups removeAllObjects];
    }

    // setup our failure view controller in case enumerateGroupsWithTypes fails
    ALAssetsLibraryAccessFailureBlock failureBlock = ^(NSError *error) {
        
        AssetsDataIsInaccessibleViewController *assetsDataInaccessibleViewController =
        [self.storyboard instantiateViewControllerWithIdentifier:@"inaccessibleViewController"];
        
        NSString *errorMessage = nil;
        switch ([error code]) {
            case ALAssetsLibraryAccessUserDeniedError:
            case ALAssetsLibraryAccessGloballyDeniedError:
                errorMessage = @"The user has declined access to it.";
                break;
            default:
                errorMessage = @"Reason unknown.";
                break;
        }
        
        assetsDataInaccessibleViewController.explanation = errorMessage;
        [self presentViewController:assetsDataInaccessibleViewController animated:NO completion:nil];
        
    };
    
    // emumerate through our groups and only add groups that contain photos
    ALAssetsLibraryGroupsEnumerationResultsBlock listGroupBlock = ^(ALAssetsGroup *group, BOOL *stop) {
        
        // ALAssetsFilter *onlyPhotosFilter = [ALAssetsFilter allPhotos];
        // [group setAssetsFilter:onlyPhotosFilter];
        ALAssetsFilter *allAssetsFilter = [ALAssetsFilter allAssets];
        [group setAssetsFilter:allAssetsFilter];
        if (group) {
            // NSLog(@"adding alassetsgroup %@", group);
            [self.groups addObject:group];
        } else {
            NSLog(@"done enumerating assetsgroups. assetsgroup is set to %@", self.assetsGroup);
            if (self.assetsGroup) {
                NSLog(@"assetgroup is %@, so not setting", self.assetsGroup);
            } else {
                NSLog(@"assetsgroup not set, setting to %@", self.groups[self.groups.count-1]);
                [self selectAssetsGroup:self.groups[self.groups.count-1]];
            }
        }
    };

    // enumerate only photos
    // NSUInteger groupTypes = ALAssetsGroupAlbum | ALAssetsGroupEvent | ALAssetsGroupFaces | ALAssetsGroupSavedPhotos;
    NSUInteger groupTypes = ALAssetsGroupAll;
    [self.assetsLibrary enumerateGroupsWithTypes:groupTypes usingBlock:listGroupBlock failureBlock:failureBlock];
    NSLog(@"done initialising");
}

- (void)viewDidAppear:(BOOL)animated {
    [super viewDidAppear:animated];
    NSLog(@"viewDidAppear:%d", animated);
//    NSLog(@"rootviewsize: %.1fx%.1f", self.rootView.frame.size.width, self.rootView.frame.size.height);
//    NSLog(@"scrollviewcontentsize: %.1fx%.1f", self.scrollView.contentSize.width, self.scrollView.contentSize.height);
//    NSLog(@"contentview: %.1fx%.1f", self.contentView.frame.size.width, self.contentView.frame.size.height);
//    NSLog(@"bigimageview size: %.1fx%.1f", self.bigImageView.frame.size.width, self.bigImageView.frame.size.height);
//    NSLog(@"conllectionview contentsize: %.1fx%.1f", self.collectionView.contentSize.width, self.collectionView.contentSize.height);
}

- (void)viewDidDisappear:(BOOL)animated
{
    [super viewDidDisappear:animated];
    NSLog(@"viewDidDisappear:%d", animated);
}

- (void)showPreview:(ALAsset*)asset {
    NSLog(@"show preview: %@ (asset type: %@", asset, [asset valueForProperty:ALAssetPropertyType]);
    ALAssetRepresentation *assetRep = [asset defaultRepresentation];
    
    metadata = [assetRep metadata];
    if (_player) {
        NSLog(@"remove playerlayer from suprview");
        [_playerLayer removeFromSuperlayer];
    }
    
    if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypePhoto]) {
        selectedurl = nil;
        // CGImageRef preImg = [assetRep fullScreenImage];
        selected = [assetRep fullScreenImage];
        UIImage *preUImg = [UIImage imageWithCGImage:selected];
        [self.bigImageView setImage:preUImg];
        
    } else if ([[asset valueForProperty:ALAssetPropertyType] isEqualToString:ALAssetTypeVideo]) {
        NSLog(@"bideo selected, setting selected img to nil, preparing player");
        selected = nil;
        [self.bigImageView setImage:nil];
        selectedurl = [assetRep url];
        _player = [[AVPlayer alloc] initWithURL:selectedurl];
        _playerLayer = [AVPlayerLayer playerLayerWithPlayer:_player];
        [_playerLayer setFrame:CGRectMake(0.0, 0.0, _contentView.frame.size.width, _bigImageView.frame.size.height)];
        [[_bigImageView layer] addSublayer:_playerLayer];
        [_player play];
        
        [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(playerItemDidReachEnd:) name:AVPlayerItemDidPlayToEndTimeNotification object:_player.currentItem];
    } else {
        NSLog(@"no entiendo ALAssetPropertyType %@", [asset valueForProperty:ALAssetPropertyType]);
    }
}

#pragma mark - AVPlayer
-(void) playerItemDidReachEnd:(NSNotification*) notification {
    [_player seekToTime:kCMTimeZero];
    [_player play];
}

#pragma mark - UICollectionViewDelegate
- (NSInteger)collectionView:(UICollectionView *)view numberOfItemsInSection:(NSInteger)section {
    // NSLog(@"collectionview numberofitemsinsection: %ld", self.assets.count);
    NSLog(@"numberofitemsinsection: %ld", (long)self.assets.count);
    return self.assets.count;
}

#define kImageViewTag 1 // the image view inside the collection view cell prototype is tagged with "1"
- (UICollectionViewCell *)collectionView:(UICollectionView *)cv cellForItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"generating cell for index %@", indexPath);
    
    UICollectionViewCell *cell = [cv dequeueReusableCellWithReuseIdentifier:reuseIdentifierPhotoCell forIndexPath:indexPath];
    
    // load the asset for this cell
    ALAsset *asset = self.assets[indexPath.row];
    // NSLog(@"asset %ld %@", indexPath.row, asset);
    CGImageRef thumbnailImageRef = [asset thumbnail];
    UIImage *thumbnail = [UIImage imageWithCGImage:thumbnailImageRef];
    
    // apply the image to the cell
    // NSLog(@"%@", cell);
    UIImageView *imageView = (UIImageView *)[cell viewWithTag:kImageViewTag];
    imageView.image = thumbnail;

    return cell;
}

- (void)collectionView:(UICollectionView *)collectionView didSelectItemAtIndexPath:(NSIndexPath *)indexPath {
    NSLog(@"selected: %ld", (long)indexPath.row);
    ALAsset *asset = self.assets[indexPath.row];
    [self showPreview:asset];
}

#pragma mark - AlbumSelectorDelegate
- (void)selectedAlbum:(ALAssetsGroup*)selectedAlbum {
    NSLog(@"dismissAlbumSelector %@", selectedAlbum);
    if (selectedAlbum) {
        [self selectAssetsGroup:selectedAlbum];
    }
}

#pragma mark - Navigation

- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    NSLog(@"segue %@", [segue identifier]);
    if ([[segue identifier] isEqualToString:albumSelectorSegue]) {
        // AlbumSelector *sel = [segue destinationViewController];
        UINavigationController *nc = [segue destinationViewController];
        AlbumSelector *sel = (AlbumSelector*)[nc topViewController];
        sel.groups = self.groups;
        nc.popoverPresentationController.delegate = self;
        sel.delegate = self;
        NSLog(@"sending over segue %@: %@", [segue identifier], self.groups);
    } else if ([[segue identifier] isEqualToString:libLocationSelectorSegue]) {
        UINavigationController *nc = [segue destinationViewController];
        UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"← Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
        nc.topViewController.navigationItem.leftBarButtonItem = bbi;
        CurateTabViewC *curate = (CurateTabViewC*)[nc topViewController];
        
        if (selected) {
            NSLog(@"sending %@", selected);
            curate.inPicture = [UIImage imageWithCGImage:selected];
            curate.inMetadata = metadata;
            // curate.imageView.image = [UIImage imageWithCGImage:selected];
            // NSLog(@"sent %@", fil.imageIn);
        } else if (selectedurl) {
            NSLog(@"sending %@", selectedurl);
            curate.inVideoURL = selectedurl;
            curate.inMetadata = metadata;
        }
    }
}

- (void)dismiss {
    [self dismissViewControllerAnimated:YES completion:nil];
    NSLog(@"dismiss");
}


- (UIModalPresentationStyle)adaptivePresentationStyleForPresentationController:(UIPresentationController *)controller {
    return UIModalPresentationFullScreen; // required, otherwise delegate method below is never called.
}

- (UIViewController *)presentationController:(UIPresentationController *)controller viewControllerForAdaptivePresentationStyle:(UIModalPresentationStyle)style {
    NSLog(@"presentationController");
    // If you don't want a nav controller when it's a popover, don't use one in the storyboard and instead return a nav controller here
    UIBarButtonItem *bbi = [[UIBarButtonItem alloc] initWithTitle:@"← Back" style:UIBarButtonItemStyleDone target:self action:@selector(dismiss)];
    UINavigationController *nc = (UINavigationController *)controller.presentedViewController;
    nc.topViewController.navigationItem.leftBarButtonItem = bbi;
    return controller.presentedViewController;
}

@end
