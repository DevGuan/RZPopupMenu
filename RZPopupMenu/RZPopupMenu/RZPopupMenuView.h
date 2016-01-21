//
//  RZPopupMenuView.h
//  RZPopupMenu
//
//  Created by Zrocky on 16/1/20.
//  Copyright (c) 2016年 Zrocky. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol RZPopupMenuViewDelegate;

@interface RZPopupMenuView : UIView

@property (nonatomic, weak) id<RZPopupMenuViewDelegate> delegate;

+ (instancetype)showWithDelegate:(id)delegate;

@end

@protocol RZPopupMenuViewDelegate <NSObject>

@optional
- (void)popupMenuView:(RZPopupMenuView *)view selectedIndex:(NSInteger)index;

@end