//
//  GradientArcView.m
//  GradientArcViewDemo
//
//  Created by awen on 2019/5/14.
//  Copyright © 2019 yanmulin. All rights reserved.
//

#import "GradientArcView.h"

#define kDefaultStartAngle 0
#define kDefaultEndAngle (2 *  M_PI)
#define kDefaultClockwise YES
#define kDefaultColors @[UIColor.greenColor, UIColor.yellowColor]//, UIColor.redColor]
#define kDefaultArcWidth 35.0

#define kAngleOffset (M_PI / 6)

@interface GradientArcView ()

@property (nonatomic, strong) NSMutableArray<UIColor *> *privateColors;
@property (nonatomic, readonly, assign) CGFloat arcRadius;
@property (nonatomic, readonly, assign) CGPoint boundsCenter;
@property (nonatomic, readonly, assign) CGFloat halfWidth;
@property (nonatomic, readonly, assign) CGAffineTransform rotateAffineTransform;
@property (nonatomic, readonly, assign) CGFloat angleStep;
@property (nonatomic, readonly, assign) CGFloat angleSpan;
@property (nonatomic, readonly, assign) CGFloat angleOffset;
@property (nonatomic, readonly, assign) NSUInteger stepCount;

@property (nonatomic, strong) CAShapeLayer *arcLayer;
@property (nonatomic, strong) CAGradientLayer *gradientLayer;

@property (nonatomic, strong) NSMutableArray<CAGradientLayer *> *gradientLayers;

@end

@implementation GradientArcView

- (instancetype)initWithFrame:(CGRect)frame startAtAngle:(CGFloat)startAngle endAtAngle:(CGFloat)endAngle width:(CGFloat)width clockwise:(BOOL)clockwise colors:(NSArray<UIColor *> *)colors {
    self = [super initWithFrame:frame];
    if (self) {
        _startAngle = startAngle;
        _endAngle = endAngle;
        _arcWidth = width;
        _clockwise = clockwise;
        _privateColors = [[NSMutableArray alloc] initWithArray:colors];
        self.layer.delegate = self;
    }
    return self;
}

- (instancetype)initWithFrame:(CGRect)frame {
    return [self initWithFrame:frame startAtAngle:kDefaultStartAngle     endAtAngle:kDefaultEndAngle width:kDefaultArcWidth clockwise:kDefaultClockwise colors:kDefaultColors];
}

- (instancetype)initWithCoder:(NSCoder *)aDecoder {
    self = [super initWithCoder:aDecoder];
    if (self) {
        _startAngle = kDefaultStartAngle;
        _endAngle = kDefaultEndAngle;
        _arcWidth = kDefaultArcWidth;
        _clockwise = kDefaultClockwise;
        _privateColors = [[NSMutableArray alloc] initWithArray:kDefaultColors];
        self.contentMode = UIViewContentModeRedraw;
    }
    return self;
}

- (void)createArcLayer {
    [self createGradientLayers];
    [self createArcShapeLayer];
}

- (void)removeArcLayer {
    [self.arcLayer removeFromSuperlayer];
    [self.gradientLayer removeFromSuperlayer];
}

- (void)awakeFromNib {
    [self createArcLayer];
    [self.layer setNeedsDisplay];
    [super awakeFromNib];
}

- (void)displayLayer:(CALayer *)layer {
    if (self.stepCount > 0) {
        if ((self.clockwise && self.endAngle > self.startAngle) ||
            (!self.clockwise && self.startAngle > self.endAngle)) {
            [self setupGradientLayers];
            [self setupArcShapeLayer];
            [self.gradientLayer setMask:_arcLayer];
        }
    }
}

- (void)createArcShapeLayer {
    _arcLayer = [CAShapeLayer new];
    [self.layer addSublayer:_arcLayer];
}

- (void)setupArcShapeLayer {
    _arcLayer.position = self.boundsCenter;
    _arcLayer.bounds = self.bounds;
    UIBezierPath *path = [UIBezierPath bezierPathWithArcCenter:self.boundsCenter radius:self.arcRadius startAngle:self.startAngle endAngle:self.endAngle clockwise:self.clockwise];
    _arcLayer.path = path.CGPath;
    _arcLayer.strokeStart = 0.0;
    _arcLayer.strokeEnd = 1.0;
    _arcLayer.lineCap = kCALineCapRound;
    _arcLayer.lineWidth = self.arcWidth;
    _arcLayer.fillColor = UIColor.clearColor.CGColor;
    _arcLayer.strokeColor = UIColor.lightGrayColor.CGColor;
}

- (void)createGradientLayers {
    _gradientLayer = [CAGradientLayer new];
    _gradientLayers = [NSMutableArray new];
    for (int i=0;i<self.stepCount;i++) {
        CAGradientLayer *gradientlayer = [CAGradientLayer new];
        [_gradientLayers addObject:gradientlayer];
        [_gradientLayer addSublayer:gradientlayer];
    }
    [self.layer addSublayer:self.gradientLayer];
}

- (void)setupGradientLayers {
    for (int i=0;i<self.stepCount;i++) {
        CAGradientLayer *gradientLayer = self.gradientLayers[i];
        gradientLayer.position = self.boundsCenter;
        gradientLayer.bounds = self.bounds;
        gradientLayer.colors = [self colorsAtStep:i];
        gradientLayer.locations = @[@0.0, @1.0];
        gradientLayer.startPoint = CGPointMake(self.arcRadius / CGRectGetWidth(gradientLayer.bounds) * 0.8, 0.0);
        gradientLayer.endPoint = CGPointMake(0.0, self.arcRadius / CGRectGetHeight(gradientLayer.bounds) * 0.8);
        gradientLayer.affineTransform = [self gradientAffineTransformAtIndex:i];
    }
}

# pragma mark - getters/setters
- (void)setStartAngle:(CGFloat)startAngle {
    _startAngle = startAngle;
    [self.arcLayer removeFromSuperlayer];
    [self.gradientLayer removeFromSuperlayer];
    [self createGradientLayers];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}

- (void)setEndAngle:(CGFloat)endAngle {
    _endAngle = endAngle;
    [self removeArcLayer];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}

- (void)setArcWidth:(CGFloat)arcWidth {
    _arcWidth = arcWidth;
    [self removeArcLayer];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}

- (void)setClockwise:(BOOL)clockwise {
    _clockwise = clockwise;
    [self removeArcLayer];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}


- (void)addColor:(UIColor *)color {
    [_privateColors addObject:color];
    [self removeArcLayer];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}

- (void)removeColorAtIndex:(NSUInteger)index {
    [_privateColors removeObjectAtIndex:index];
    [self removeArcLayer];
    [self createArcLayer];
    [self.layer setNeedsDisplay];
}

- (NSArray<UIColor *> *)colors {
    return [_privateColors copy];
}

- (CGFloat)arcRadius {
    return (MIN(CGRectGetWidth(self.bounds), CGRectGetHeight(self.bounds)) - self.arcWidth) / 2.0;
}

- (CGPoint)boundsCenter {
    return CGPointMake(CGRectGetMidX(self.bounds), CGRectGetMidY(self.bounds));
}

- (CGAffineTransform)gradientAffineTransformAtIndex:(NSUInteger)index {

    if (self.stepCount == 1) {
        return CGAffineTransformIdentity;//CGAffineTransformConcat( CGAffineTransformMakeScale(CGRectGetHeight(self.bounds) / CGRectGetWidth(self.bounds), CGRectGetWidth(self.bounds) / CGRectGetHeight(self.bounds)), CGAffineTransformMakeRotation(self.startAngle + self.angleSpan / 2));
    } else if (fabs(self.angleStep - M_PI) < 1e-6) {
        return CGAffineTransformIdentity;
    } else if (self.angleSpan < M_PI * 2 && self.stepCount > 2){
        CGFloat shearAngle;
        CGFloat rotateAngle;
        
        if (index == 0 || index == self.stepCount - 1) {
            shearAngle = (self.clockwise?1:-1) * ((2 * M_PI - self.angleSpan ) / 2 > M_PI / 6 ? M_PI / 6 : (2 * M_PI - self.angleSpan ) / 2);
        } else {
            shearAngle = (self.clockwise?1:-1) * self.angleStep;
        }
    
        if (index == 0) {
            rotateAngle =  -shearAngle + self.startAngle;
        } else {
            rotateAngle = self.angleStep * (index - 1) + self.startAngle;
            rotateAngle = (self.clockwise?1:-1) * self.angleStep  * (index - 1) + self.startAngle;
        }
    
        CGAffineTransform shearAffineTransform = CGAffineTransformMake(1.0, 0.0, cosf(shearAngle), sinf(shearAngle), 0.0, 0.0);
        
        return CGAffineTransformConcat(
                                       CGAffineTransformMakeTranslation(self.boundsCenter.x, self.boundsCenter.y),
                                       CGAffineTransformConcat(shearAffineTransform,CGAffineTransformMakeRotation(rotateAngle)));
    } else {
        CGAffineTransform shearAffineTransform = CGAffineTransformMake(1.0, 0.0, cosf(self.angleStep), sinf(self.angleStep), 0.0, 0.0);
        return CGAffineTransformConcat(
                                CGAffineTransformMakeTranslation(self.boundsCenter.x, self.boundsCenter.y),
                                CGAffineTransformConcat(
                                                        shearAffineTransform,
                                                        CGAffineTransformMakeRotation(self.angleStep * index)
                                                        )
                                       );
    }
    
}

- (NSUInteger)stepCount {
    assert (_privateColors.count >= 0);
    if (_privateColors.count == 0) return 0;
    if (self.angleSpan < M_PI * 2) {
        if (_privateColors.count == 1) return 1;
        else return _privateColors.count * 2 - 1 + 2;
    } else {
        return _privateColors.count *  2;
    }
}

- (CGFloat)angleStep {
    if (self.angleSpan < M_PI * 2) {
        return self.angleSpan / (self.privateColors.count * 2 - 1);
    } else {
        return self.angleSpan / (self.privateColors.count * 2);
    }
}

- (CGFloat)angleSpan {
    return self.clockwise?self.endAngle - self.startAngle:self.startAngle - self.endAngle;
}

- (CGFloat)angleOffset {
    return M_PI * 2 - self.angleSpan > kAngleOffset ? M_PI * 2 - self.angleSpan : kAngleOffset;
}

- (NSArray*)colorsAtStep:(NSUInteger)index {
    assert (self.stepCount > 0 && index >= 0 && index < self.stepCount);
    if (self.stepCount == 1) {
        return @[(__bridge id)self.privateColors[0].CGColor, (__bridge id)self.privateColors[1%(self.privateColors.count)].CGColor];
    } else if (self.angleSpan < M_PI * 2) {
        if (index == self.stepCount - 1) {
            return @[(__bridge id)self.privateColors[index/2-1].CGColor, (__bridge id)self.privateColors[index/2-1].CGColor];
        } else if (index == 0) {
            return @[(__bridge id)self.privateColors[0].CGColor, (__bridge id)self.privateColors[0].CGColor];
        } else if (index % 2 == 1) {
            return @[(__bridge id)self.privateColors[index / 2].CGColor, (__bridge id)self.privateColors[index / 2].CGColor];
        } else {
            return @[(__bridge id)self.privateColors[index / 2-1].CGColor, (__bridge id)self.privateColors[index/2].CGColor];
        }
    } else {
        if (index % 2 == 1) {
            return @[(__bridge id)self.privateColors[index / 2].CGColor, (__bridge id)self.privateColors[((index) / 2 + 1)%self.privateColors.count].CGColor];
        } else {
            return @[(__bridge id)self.privateColors[(index) / 2].CGColor, (__bridge id)self.privateColors[(index) / 2].CGColor];
        }
    }
    assert(NO);
    return nil;
}

- (NSArray*)locationsAtStep:(NSUInteger)index {
    assert (self.privateColors.count > 0 && index >= 0 && index < self.stepCount);
    return nil;
}


@end
