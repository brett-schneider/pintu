/*
Copyright (C) 2015 Apple Inc. All Rights Reserved.
See LICENSE.txt for this sample’s licensing information

Abstract:
View controller for camera interface.
*/

@import UIKit;

@interface AAPLCameraViewController : UICollectionViewController <UICollectionViewDataSource, UICollectionViewDelegate>
@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@end
