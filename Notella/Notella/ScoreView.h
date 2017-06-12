//
//  ScoreView.h
//  Crescendo
//
//  Created by Daniel Kuntz on 5/18/17.
//  Copyright © 2017 Pulse Technologies. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol ScoreViewDelegate <NSObject>
@optional
- (void)measureTappedAtIndex:(int)index;
@end

@interface ScoreView : UIView

@property(nonatomic, strong) UICollectionView* collectionView;

- (void)setupWithXmlPath:(NSString *)xmlPath;
- (void)setDelegate:(id <ScoreViewDelegate>)aDelegate;
- (void)moveCursorToMeasureIndex:(int)index measureTime:(int)time;
- (void)hideCursor;

@end
