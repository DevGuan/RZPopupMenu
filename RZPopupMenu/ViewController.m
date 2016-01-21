//
//  ViewController.m
//  RZPopupMenu
//
//  Created by Zrocky on 16/1/20.
//  Copyright (c) 2016年 Zrocky. All rights reserved.
//

#import "ViewController.h"
#import "RZPopupMenuView.h"
#import "UIView+AdjustFrame.h"

#define RZWindow [UIApplication sharedApplication].keyWindow

@interface ViewController ()<RZPopupMenuViewDelegate>

@property (nonatomic, strong) UILabel *displayLabel;

@property (nonatomic, strong) UIButton *openBtn;
@property (nonatomic, strong) RZPopupMenuView *popupMenu;
@end

@implementation ViewController

#pragma mark - life cycle

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor whiteColor];
    
    [self.view addSubview:self.displayLabel];
    [self.view addSubview:self.openBtn];
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
    
    self.displayLabel.frame = self.view.bounds;
    
    self.openBtn.width = 50.0f;
    self.openBtn.height = 50.0f;
    self.openBtn.center = CGPointMake(180, 400);
}

#pragma mark - delegate

#pragma mark - RZPopupMenuViewDelegate
- (void)popupMenuView:(RZPopupMenuView *)view selectedIndex:(NSInteger)index
{
    self.displayLabel.text = [NSString stringWithFormat:@"%d", index];
}

#pragma mark - event response
- (void)openBtnClick
{
    [RZPopupMenuView showWithDelegate:self];
}

#pragma mark - public methods

#pragma mark - private methods

#pragma mark - setter and getter
- (UIButton *)openBtn
{
    if (!_openBtn) {
        _openBtn = [UIButton buttonWithType:UIButtonTypeCustom];
        [_openBtn addTarget:self action:@selector(openBtnClick) forControlEvents:UIControlEventTouchUpInside];
        [_openBtn setBackgroundImage:[UIImage imageNamed:@"bg-addbutton"] forState:UIControlStateNormal];
        [_openBtn setImage:[UIImage imageNamed:@"icon-plus"] forState:UIControlStateNormal];
    }
    return _openBtn;
}

- (UILabel *)displayLabel
{
    if (!_displayLabel) {
        _displayLabel = [[UILabel alloc] init];
        _displayLabel.font = [UIFont systemFontOfSize:50];
        _displayLabel.textAlignment = NSTextAlignmentCenter;
    }
    return _displayLabel;
}

@end
