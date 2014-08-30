//
//  DHCollectionViewIconCell.h
//  DHMathematicsGame
//
//  Created by DuetHealth on 8/2/14.
//  Copyright (c) 2014 DuetHealth. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface DHCollectionViewIconCell : UICollectionViewCell
@property (strong, nonatomic) IBOutlet UIImageView* image;
@property (strong, nonatomic) IBOutlet UILabel* label;
@property (assign, nonatomic) NSInteger imageNumberAssigned;

@end
