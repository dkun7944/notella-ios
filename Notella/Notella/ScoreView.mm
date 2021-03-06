//
//  ScoreView.m
//  Crescendo
//
//  Created by Daniel Kuntz on 5/18/17.
//  Copyright © 2017 Pulse Technologies. All rights reserved.
//

#import <MusicKit/MusicKit.h>

#include <mxml/geometry/PageScoreGeometry.h>
#include <mxml/parsing/ScoreHandler.h>
#include <mxml/SpanFactory.h>
#include <lxml/lxml.h>

#include <iostream>
#include <fstream>

#import "ScoreView.h"

@interface ScoreView ()
@property(nonatomic, strong) VMKScrollScoreLayout* scoreLayout;
@property(nonatomic, strong) VMKScrollScoreDataSource* dataSource;
@property(nonatomic, strong) UITapGestureRecognizer* tapGR;
@property(nonatomic, weak) id <ScoreViewDelegate> delegate;
@end

@implementation ScoreView {
    std::unique_ptr<mxml::dom::Score> _score;
    std::unique_ptr<mxml::ScrollScoreGeometry> _geometry;
    
    struct {
        unsigned int measureTappedAtIndex:1;
    } delegateRespondsTo;
}
@synthesize delegate;

- (void)setupWithXmlPath:(NSString *)xmlPath {
    self.scoreLayout = [[VMKScrollScoreLayout alloc] init];
    self.dataSource = [[VMKScrollScoreDataSource alloc] init];
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.scoreLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKMeasureReuseIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKDirectionReuseIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKTieReuseIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKCursorReuseIdentifier];
    self.collectionView.dataSource = self.dataSource;
    
    mxml::parsing::ScoreHandler handler;
    std::ifstream is([xmlPath UTF8String]);
    lxml::parse(is, [xmlPath UTF8String], handler);
    _score = handler.result();
    
    if (!_score->parts().empty() && !_score->parts().front()->measures().empty()) {
        _geometry.reset(new mxml::ScrollScoreGeometry(*_score, self.frame.size.width));
    } else {
        _geometry.reset();
    }
    
    self.scoreLayout.scoreGeometry = _geometry.get();
    self.scoreLayout.cursorStyle = VMKCursorStyleNote;
    
    self.dataSource.scoreGeometry = _geometry.get();
    self.dataSource.cursorStyle = VMKCursorStyleNote;
    self.dataSource.cursorColor = [[UIColor alloc] initWithRed:8/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
    
    self.collectionView.frame = CGRectMake(0, 0, _geometry->frame().size.width, _geometry->frame().size.height*2);
    self.frame = self.collectionView.frame;
    
    [self addSubview:self.collectionView];
    [self.collectionView reloadData];
    
    self.tapGR = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(viewTapped:)];
    [self addGestureRecognizer:self.tapGR];
}

- (void)setDelegate:(id <ScoreViewDelegate>)aDelegate {
    if (delegate != aDelegate) {
        delegate = aDelegate;
        delegateRespondsTo.measureTappedAtIndex = [delegate respondsToSelector:@selector(measureTappedAtIndex:)];
    }
}

- (void)moveCursorToMeasureIndex:(int)index measureTime:(int)time {
    self.dataSource.cursorOpacity = 0.15;
    self.scoreLayout.cursorMeasureIndex = index;
    self.scoreLayout.cursorMeasureTime = time;
    [self.collectionView reloadData];
}

- (void)viewTapped:(UITapGestureRecognizer *)gestureRecognizer {
    CGPoint point = [gestureRecognizer locationInView:self];
    int measureIndex = 0;
    
    if (delegateRespondsTo.measureTappedAtIndex == 1 && measureIndex != -1) {
        [self.delegate measureTappedAtIndex:measureIndex];
    }
}

- (void)hideCursor {
    self.dataSource.cursorOpacity = 0;
    [self.collectionView reloadData];
}

@end
