//
//  RZPopupMenuItem.h
//  RZPopupMenu
//
//  Created by Zrocky on 16/1/20.
//  Copyright (c) 2016年 Zrocky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RZPopupMenuItemDelegate;

@interface RZPopupMenuItem : UIImageView

@property (nonatomic, assign) CGPoint startPoint;
@property (nonatomic, assign) CGPoint farPoint;
@property (nonatomic, assign) CGPoint nearPoint;
@property (nonatomic, assign) CGPoint endPoint;

@property (nonatomic, weak) id<RZPopupMenuItemDelegate> delegate;

- (instancetype)initWithImage:(UIImage *)image
             highlightedImage:(UIImage *)highlightedImage
                 contentImage:(UIImage *)contentImage
      contentHighlightedImage:(UIImage *)contnetHighlightedImage;

@end


@protocol RZPopupMenuItemDelegate <NSObject>

@optional
- (void)popupMenuItemTouchesBegan:(RZPopupMenuItem *)item;

@end