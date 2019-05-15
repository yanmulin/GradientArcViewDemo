//
//  GradientArcView.h
//  GradientArcViewDemo
//
//  Created by awen on 2019/5/14.
//  Copyright © 2019 yanmulin. All rights reserved.
//

#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface GradientArcView : UIView

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat arcWidth;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) BOOL clockwise;
@property (nonatomic, strong, readonly) NSArray<UIColor *> *colors;

- (instancetype)initWithFrame:(CGRect)frame startAtAngle:(CGFloat)startAngle endAtAngle:(CGFloat)endAngle width:(CGFloat)width clockwise:(BOOL)clockwise colors:(NSArray<UIColor *> *)colors;
- (void)addColor:(UIColor *)color;
- (void)removeColorAtIndex:(NSUInteger)index;

@end


NS_ASSUME_NONNULL_END
