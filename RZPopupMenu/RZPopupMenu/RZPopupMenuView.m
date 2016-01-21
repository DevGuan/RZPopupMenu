//
//  RZPopupMenuView.m
//  RZPopupMenu
//
//  Created by Zrocky on 16/1/20.
//  Copyright (c) 2016年 Zrocky. All rights reserved.
//

#import "RZPopupMenuView.h"
#import "RZPopupMenuItem.h"
#import "UIView+AdjustFrame.h"

#define RZWindow [UIApplication sharedApplication].keyWindow

CGFloat const kRZPopupMenuItemFarRadius = 110.0f;
CGFloat const kRZPopupMenuItemNearRadius = 140.0f;
CGFloat const kRZPopupMenuItemEndRadius = 120.0f;
CGFloat const kRZPopupMenuItemWholeAngle = M_PI * 0.6;
CGFloat const kRZPopupMenuItemStartAngle = M_PI * 1.2;
CGFloat const kRZPopupMenuItemExpandRotation = M_PI;
CGFloat const kRZPopupMenuItemCloseRotation = M_2_PI;
CGFloat const kRZPopupMenuCenterBtnCenterX = 180.0f;
CGFloat const kRZPopupMenuCenterBtnCenterY = 400.0f;
CGFloat const kRZPopupMenuCenterBtnWidth = 50.0f;
CGFloat const kRZPopupMenuAnimationDuration = 0.5f;

static CGPoint RotateCGPointAroundCenter(CGPoint point, CGPoint center, float angle)
{
    CGAffineTransform translation = CGAffineTransformMakeTranslation(center.x, center.y);
    CGAffineTransform rotation = CGAffineTransformMakeRotation(angle);
    CGAffineTransform transformGroup = CGAffineTransformConcat(CGAffineTransformConcat(CGAffineTransformInvert(translation), rotation), translation);
    return CGPointApplyAffineTransform(point, transformGroup);
}

@interface RZPopupMenuView ()<RZPopupMenuItemDelegate>

@property (nonatomic, strong) RZPopupMenuItem *centerBtn;
@property (nonatomic, strong) NSMutableArray *menuItems;

@property (nonatomic, assign) CGPoint startPoint;

@property (nonatomic, assign, getter=isExpanded) BOOL expanded;
@property (nonatomic, assign, getter=isAnimation) BOOL animation;
@end
@implementation RZPopupMenuView

- (instancetype)initWithFrame:(CGRect)frame
{
    if (self = [super initWithFrame:frame]) {
        
        self.startPoint = CGPointMake(kRZPopupMenuCenterBtnCenterX, kRZPopupMenuCenterBtnCenterY);
        
        [self setupSubviews];
    }
    return self;
}

- (void)setupSubviews
{
    self.backgroundColor = [UIColor colorWithWhite:0 alpha:0.5];
    
    [self addSubview:self.centerBtn];
}

- (void)layoutSubviews
{
    [super layoutSubviews];
    
    self.centerBtn.width = kRZPopupMenuCenterBtnWidth;
    self.centerBtn.height = kRZPopupMenuCenterBtnWidth;
    self.centerBtn.center = self.startPoint;
}


#pragma mark - delegate
#pragma mark - RZPopupMenuItemDelegate
- (void)popupMenuItemTouchesBegan:(RZPopupMenuItem *)item
{
    if (self.isAnimation) return;
    
    if (item == self.centerBtn) {
        
        self.expanded = !self.isExpanded;
        return;
    }
    [self blowupWithItem:item];
    
    for (RZPopupMenuItem *otherItem in self.menuItems) {
        if (otherItem.tag == item.tag) {
            continue;
        }
        
        [self shrinkWithItem:otherItem];
    }
    
}

- (void)animationDidStart:(CAAnimation *)anim
{
    self.animation = YES;
}

- (void)animationDidStop:(CAAnimation *)anim finished:(BOOL)flag
{
    self.animation = NO;
    
    if ([[anim valueForKey:@"id"] isEqualToString:@"closeAni"]) {
        [self removeFromSuperview];
    }else if ([[anim valueForKey:@"id"] isEqualToString:@"blowupAni"]) {
        [self removeFromSuperview];
        if ([self.delegate respondsToSelector:@selector(popupMenuView:selectedIndex:)]) {
            [self.delegate popupMenuView:self selectedIndex:[[anim valueForKey:@"selectedIndex"] integerValue]];
        }
    }
}



#pragma mark - event response

#pragma mark - public methods
+ (instancetype)showWithDelegate:(id)delegate
{
    RZPopupMenuView *popupMenuView = [[RZPopupMenuView alloc] initWithFrame:RZWindow.bounds];
    popupMenuView.delegate = delegate;
    [RZWindow addSubview:popupMenuView];
    
    [popupMenuView setupMenuItems];
    
    popupMenuView.expanded = YES;
    
    
    return popupMenuView;
}


#pragma mark - private methods
- (void)setupMenuItems
{
    CGFloat gapAngle = kRZPopupMenuItemWholeAngle / (self.menuItems.count - 1);
    for (RZPopupMenuItem *item in self.menuItems) {
        
        CGFloat angle = kRZPopupMenuItemStartAngle + item.tag * gapAngle;
        
        item.startPoint = CGPointMake(kRZPopupMenuCenterBtnCenterX, kRZPopupMenuCenterBtnCenterY);
        
        CGPoint farPoint = CGPointMake(kRZPopupMenuCenterBtnCenterX + kRZPopupMenuItemFarRadius * cosf(angle), kRZPopupMenuCenterBtnCenterY + kRZPopupMenuItemFarRadius * sinf(angle));
        item.farPoint = RotateCGPointAroundCenter(farPoint, self.startPoint, kRZPopupMenuItemStartAngle);
        item.farPoint = farPoint;
        
         CGPoint nearPoint = CGPointMake(kRZPopupMenuCenterBtnCenterX + kRZPopupMenuItemNearRadius * cosf(angle), kRZPopupMenuCenterBtnCenterY + kRZPopupMenuItemNearRadius * sinf(angle));
        item.nearPoint = RotateCGPointAroundCenter(nearPoint, self.startPoint, kRZPopupMenuItemStartAngle);
        item.nearPoint = nearPoint;
        
        CGPoint endPoint = CGPointMake(kRZPopupMenuCenterBtnCenterX + kRZPopupMenuItemEndRadius * cosf(angle), kRZPopupMenuCenterBtnCenterY + kRZPopupMenuItemEndRadius * sinf(angle));
        item.endPoint = RotateCGPointAroundCenter(endPoint, self.startPoint, kRZPopupMenuItemStartAngle);;
        item.endPoint = endPoint;
        
        item.center = self.startPoint;
        item.width = kRZPopupMenuCenterBtnWidth;
        item.height = kRZPopupMenuCenterBtnWidth;
        
        [self insertSubview:item belowSubview:self.centerBtn];
    }
}


- (void)open
{
    for (RZPopupMenuItem *item in self.menuItems) {
        [self expandWithTag:item.tag];
    }
}

- (void)close
{
    for (RZPopupMenuItem *item in self.menuItems) {
        [self closeWithTag:item.tag];
    }
}

- (void)expandWithTag:(NSInteger)tag
{
    RZPopupMenuItem *item = self.menuItems[tag];
    
    CAKeyframeAnimation *rotationAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAni.values = @[@(kRZPopupMenuItemExpandRotation * 3), @0.0f];
    //    rotationAni.duration = kRZPopupMenuAnimationDuration;
    //    rotationAni.keyTimes = @[@(.3), @(.4)];
    
    CAKeyframeAnimation *postionAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    //    postionAni.duration = kRZPopupMenuAnimationDuration;
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, kRZPopupMenuCenterBtnCenterX, kRZPopupMenuCenterBtnCenterY);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y);
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    postionAni.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[rotationAni, postionAni];
    group.duration = kRZPopupMenuAnimationDuration;
    group.fillMode = kCAFillModeForwards;
    //    group.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    group.delegate = self;
    
    [group setValue:@"expandAni" forKey:@"id"];
    
    [item.layer addAnimation:group forKey:@"expandAni"];
    
    item.center = item.endPoint;
    
}

- (void)closeWithTag:(NSInteger)tag
{
    RZPopupMenuItem *item = self.menuItems[tag];
    
    CAKeyframeAnimation *rotationAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAni.values = @[@0, @(kRZPopupMenuItemCloseRotation * 3) ,@0];
//    rotationAni.keyTimes = @[@.0f, @.4f, @.5f];
    
    CAKeyframeAnimation *positionAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    positionAni.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[rotationAni, positionAni];
    group.duration = kRZPopupMenuAnimationDuration;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [group setValue:@"closeAni" forKey:@"id"];
    
    [item.layer addAnimation:group forKey:@"closeAni"];
    
    item.center = item.startPoint;
}

- (void)blowupWithItem:(RZPopupMenuItem *)item
{
    CAKeyframeAnimation *positionAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAni.values = @[[NSValue valueWithCGPoint:item.center]];
    positionAni.keyTimes = @[@.3f];
    
    CABasicAnimation *scaleAni = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAni.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAni.toValue = @[@0.0f];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionAni, scaleAni, opacityAni];
    group.duration = kRZPopupMenuAnimationDuration;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    [group setValue:@"blowupAni" forKey:@"id"];
    [group setValue:@(item.tag) forKey:@"selectedIndex"];
    
    [item.layer addAnimation:group forKey:@"blowupAni"];
    
    item.center = item.startPoint;
}

- (void)shrinkWithItem:(RZPopupMenuItem *)item
{
    CAKeyframeAnimation *positionAni = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAni.values = @[[NSValue valueWithCGPoint:item.center]];
    positionAni.keyTimes = @[@.3f];
    
    CABasicAnimation *scaleAni = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAni.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAni = [CABasicAnimation animationWithKeyPath:@"opactiy"];
    opacityAni.toValue = @[@0.0f];
    
    CAAnimationGroup *group = [CAAnimationGroup animation];
    group.animations = @[positionAni, scaleAni, opacityAni];
    group.duration = kRZPopupMenuAnimationDuration;
    group.fillMode = kCAFillModeForwards;
    group.delegate = self;
    
    [group setValue:@"shrinkAni" forKey:@"id"];
    
    [item.layer addAnimation:group forKey:@"shrinkAni"];
    
    item.center = item.startPoint;
}

#pragma mark - setter and getter

- (RZPopupMenuItem *)centerBtn
{
    if (!_centerBtn) {
        _centerBtn = [[RZPopupMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-addbutton"] highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted"] contentImage:[UIImage imageNamed:@"icon-plus"] contentHighlightedImage:[UIImage imageNamed:@"icon-`-highlighted"]];
        _centerBtn.delegate = self;
    }
    return _centerBtn;
}

- (NSMutableArray *)menuItems
{
    if (!_menuItems) {
        _menuItems = [NSMutableArray array];
        for (int i = 0; i < 4; i ++) {
            RZPopupMenuItem *item = [[RZPopupMenuItem alloc] initWithImage:[UIImage imageNamed:@"bg-menuitem"] highlightedImage:[UIImage imageNamed:@"bg-menuitem-highlighted"] contentImage:[UIImage imageNamed:@"icon-star"] contentHighlightedImage:nil];
            item.delegate = self;
            item.tag = _menuItems.count;
            [_menuItems addObject:item];
        }
    }
    return _menuItems;
}

- (void)setExpanded:(BOOL)expand
{
    if (self.isAnimation) return;
    
    if (expand) {
        [self open];
    }else {
        [self close];
    }
    
    CGFloat angle = expand ? - M_PI_4 : 0.0f;
    CAKeyframeAnimation *rotationAni = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotationAni.values = @[@(angle)];
    rotationAni.duration = kRZPopupMenuAnimationDuration;
    rotationAni.fillMode = kCAFillModeForwards;
    rotationAni.removedOnCompletion = NO;
    [self.centerBtn.layer addAnimation:rotationAni forKey:@"centerAni"];
    
    _expanded = expand;
}
@end
