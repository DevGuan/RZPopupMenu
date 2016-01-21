//
//  RZPopupMenuItem.m
//  RZPopupMenu
//
//  Created by Zrocky on 16/1/20.
//  Copyright (c) 2016年 Zrocky. All rights reserved.
//

#import "RZPopupMenuItem.h"
#import "UIView+AdjustFrame.h"

CGFloat const kRZPopupItemContentSizeRatio = .4f;

@interface RZPopupMenuItem ()

@property (nonatomic, strong) UIImageView *contentImageView;
@end
@implementation RZPopupMenuItem

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
                 contentImage:(UIImage *)contentImage
      contentHighlightedImage:(UIImage *)contnetHighlightedImage
{
    if (self = [super init]) {
        
        self.userInteractionEnabled = YES;
        
        self.image = image;
        self.highlightedImage = highlightedImage;
        
        self.contentImageView.image = contentImage;
        self.contentImageView.highlightedImage = contnetHighlightedImage;
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    [self addSubview:self.contentImageView];
    
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.contentImageView.width = self.width * kRZPopupItemContentSizeRatio;
    self.contentImageView.height = self.height * kRZPopupItemContentSizeRatio;
    self.contentImageView.center = CGPointMake(self.width * 0.5, self.height * 0.5);
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    if ([self.delegate respondsToSelector:@selector(popupMenuItemTouchesBegan:)]) {
        [self.delegate popupMenuItemTouchesBegan:self];
    }
}

- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    
}

#pragma mark - delegate

#pragma mark - event response

#pragma mark - public methods

#pragma mark - private methods

#pragma mark - setter and getter
- (UIImageView *)contentImageView
{
    if (!_contentImageView) {
        _contentImageView = [[UIImageView alloc] init];
    }
    return _contentImageView;
}

@end
