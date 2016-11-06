//
//  AcquirePicture.h
//  pintu2
//
//  Created by Brett on 29/02/16.
//  Copyright © 2016 Brett. All rights reserved.
//

@import UIKit;

@interface AcquireLib : UIViewController <UICollectionViewDataSource, UICollectionViewDelegate, UIPopoverPresentationControllerDelegate>

@property (nonatomic, retain) IBOutlet UICollectionView *collectionView;
@property (weak, nonatomic) IBOutlet NSLayoutConstraint *contentViewHeight;

@end
