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
@property(nonatomic, strong) VMKPageScoreLayout* scoreLayout;
@property(nonatomic, strong) VMKPageScoreDataSource* dataSource;
@property(nonatomic, strong) NSArray* noteColors;
@property(nonatomic, strong) UITapGestureRecognizer* tapGR;
@property(nonatomic, weak) id <ScoreViewDelegate> delegate;
@end

@implementation ScoreView {
    std::unique_ptr<mxml::dom::Score> _score;
    std::unique_ptr<mxml::PageScoreGeometry> _geometry;
    
    struct {
        unsigned int measureTappedAtIndex:1;
    } delegateRespondsTo;
}
@synthesize delegate;

- (void)setupWithXml:(NSData *)xmlData noteColors:(NSArray *)noteColors {
    self.scoreLayout = [[VMKPageScoreLayout alloc] init];
    self.dataSource = [[VMKPageScoreDataSource alloc] init];
    self.noteColors = noteColors;
    self.collectionView = [[UICollectionView alloc] initWithFrame:self.frame collectionViewLayout:self.scoreLayout];
    self.collectionView.backgroundColor = [UIColor clearColor];
    [self.collectionView registerClass:[UICollectionReusableView class] forSupplementaryViewOfKind:UICollectionElementKindSectionHeader withReuseIdentifier:VMKPageHeaderReuseIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKSystemReuseIdentifier];
    [self.collectionView registerClass:[UICollectionViewCell class] forCellWithReuseIdentifier:VMKSystemCursorReuseIdentifier];
    self.collectionView.dataSource = self.dataSource;
    
    // WRITE TO FILE
    NSString *xmlString = [[NSString alloc] initWithData:xmlData encoding:NSUTF8StringEncoding];
    NSArray *paths = NSSearchPathForDirectoriesInDomains
    (NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    
    //make a file name to write the data to using the documents directory:
    NSString *path = [NSString stringWithFormat:@"%@/temp.xml", documentsDirectory];
    
    //save content to the documents directory
    [xmlString writeToFile:path atomically:NO encoding:NSStringEncodingConversionAllowLossy error:nil];
    
    mxml::parsing::ScoreHandler handler;
    std::ifstream is([path UTF8String]);
    lxml::parse(is, [path UTF8String], handler);
    _score = handler.result();
    
    if (!_score->parts().empty() && !_score->parts().front()->measures().empty()) {
        _geometry.reset(new mxml::PageScoreGeometry(*_score, self.frame.size.width*2));
    } else {
        _geometry.reset();
    }
    
    self.scoreLayout.scoreGeometry = _geometry.get();
    self.scoreLayout.cursorStyle = VMKCursorStyleNote;
    self.scoreLayout.scale = 0.5;
    
    self.dataSource.scoreGeometry = _geometry.get();
    self.dataSource.cursorStyle = VMKCursorStyleNote;
    self.dataSource.cursorColor = [[UIColor alloc] initWithRed:8/255.0 green:166/255.0 blue:166/255.0 alpha:1.0];
    
    self.dataSource.noteColors = self.noteColors;
    self.dataSource.scale = 0.5;
    
    self.collectionView.frame = CGRectMake(0, 0, _geometry->frame().size.width, _geometry->frame().size.height);
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
    int measureIndex = [self.scoreLayout measureIndexForPoint:point];
    
    if (delegateRespondsTo.measureTappedAtIndex == 1 && measureIndex != -1) {
        [self.delegate measureTappedAtIndex:measureIndex];
    }
}

- (void)hideCursor {
    self.dataSource.cursorOpacity = 0;
    [self.collectionView reloadData];
}

@end
