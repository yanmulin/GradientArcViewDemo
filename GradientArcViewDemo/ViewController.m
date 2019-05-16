//
//  ViewController.m
//  GradientArcViewDemo
//
//  Created by awen on 2019/5/14.
//  Copyright © 2019 yanmulin. All rights reserved.
//

#import "ViewController.h"
#import "GradientArcView.h"

#define kColorChoices @[UIColor.greenColor, UIColor.yellowColor, UIColor.redColor, UIColor.purpleColor, UIColor.blueColor, UIColor.cyanColor, UIColor.magentaColor, UIColor.lightGrayColor, UIColor.darkGrayColor, UIColor.blackColor]

#define kStartAngleMax 2 * M_PI
#define kStartAngleMin 0
#define kEndAngleMax 2 * M_PI
#define kEndAngleMin 0
#define kColorNumMax 9
#define kColorNumMin 0
#define kArcWidthMax 50.0
#define kArcWidthMin 0
#define kDisplayNumMax 2 * kColorNumMax + 2
#define kDisplayNumMin 0

@interface ViewController ()

@property (weak, nonatomic) IBOutlet GradientArcView *gradientView;
@property (weak, nonatomic) IBOutlet UISlider *startAngleSlider;
@property (weak, nonatomic) IBOutlet UISlider *endAngleSlider;
@property (weak, nonatomic) IBOutlet UISlider *colorNumSlider;
@property (weak, nonatomic) IBOutlet UISlider *arcWidthSlider;
@property (weak, nonatomic) IBOutlet UISlider *displayNumSlider;

@property (weak, nonatomic) IBOutlet UISwitch *clockwiseSW;
@property (weak, nonatomic) IBOutlet UILabel *startAngleValueLab;
@property (weak, nonatomic) IBOutlet UILabel *endAngleValueLab;
@property (weak, nonatomic) IBOutlet UILabel *colorNumValueLab;
@property (weak, nonatomic) IBOutlet UILabel *arcWidthValueLab;
@property (weak, nonatomic) IBOutlet UILabel *displayNumLab;


@property (nonatomic, strong) NSArray *colorChoices;

@property (nonatomic, assign) CGFloat startAngle;
@property (nonatomic, assign) CGFloat endAngle;
@property (nonatomic, assign) NSUInteger colorNum;
@property (nonatomic, assign) CGFloat arcWidth;
@property (nonatomic, assign) BOOL clockwise;
@property (nonatomic, assign) NSUInteger displayNum;

@end

@implementation ViewController

- (void)setupSliders {
    self.startAngleSlider.minimumValue = kStartAngleMin;
    self.endAngleSlider.minimumValue = kEndAngleMin;
    self.startAngleSlider.maximumValue = kStartAngleMax;
    self.endAngleSlider.maximumValue = kEndAngleMax;
    self.colorNumSlider.minimumValue = kColorNumMin;
    self.colorNumSlider.maximumValue = kColorNumMax;
    
    self.arcWidthSlider.minimumValue = kArcWidthMin;
    self.arcWidthSlider.maximumValue = kArcWidthMax;
    
    self.displayNumSlider.minimumValue = kDisplayNumMin;
    self.displayNumSlider.maximumValue = kDisplayNumMax;
    
    self.startAngleSlider.continuous = self.endAngleSlider.continuous = self.colorNumSlider.continuous = self.arcWidthSlider.continuous = YES;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.colorChoices = kColorChoices;
    
    [self setupSliders];
    
    self.startAngle = kStartAngleMin;
    self.endAngle = kEndAngleMax * 2 / 3;
    self.colorNum = (kColorNumMin + kColorNumMax) / 2;
    self.arcWidth = (kArcWidthMin + kArcWidthMax) / 2;
    self.displayNum = kDisplayNumMax;
    self.clockwise = YES;
    
}

# pragma mark - getters / setters
- (void)setStartAngle:(CGFloat)startAngle {
    self.gradientView.startAngle = startAngle;
    [self.startAngleSlider setValue:startAngle];
    self.startAngleValueLab.text = [NSString stringWithFormat:@"%.1lf°", startAngle / M_PI * 180];
    _startAngle = startAngle;
}

- (void)setEndAngle:(CGFloat)endAngle {
    self.gradientView.endAngle = endAngle;
    [self.endAngleSlider setValue:endAngle];
    self.endAngleValueLab.text = [NSString stringWithFormat:@"%.1lf°", endAngle / M_PI * 180];
    _endAngle = endAngle;
}

- (void)setColorNum:(NSUInteger)colorNum {
    if (_colorNum != self.gradientView.colors.count) _colorNum = self.gradientView.colors.count;
    if (_colorNum > colorNum) {
        while (_colorNum > colorNum) {
            [self.gradientView removeColorAtIndex:self.gradientView.colors.count - 1];
            _colorNum --;
        }
    } else if (_colorNum < colorNum) {
        while (_colorNum < colorNum) {
            [self.gradientView addColor:self.colorChoices[_colorNum]];
            _colorNum ++;
        }
    }
    self.colorNumValueLab.text = [NSString stringWithFormat:@"%ld", colorNum];
    self.colorNumSlider.value = colorNum;
}

- (void)setArcWidth:(CGFloat)arcWidth {
    self.gradientView.arcWidth = arcWidth;
    self.arcWidthSlider.value = arcWidth;
    self.arcWidthValueLab.text = [NSString stringWithFormat:@"%.1lf", arcWidth];
    _arcWidth = arcWidth;
}

- (void)setClockwise:(BOOL)clockwise {
    self.gradientView.clockwise = clockwise;
    [self.clockwiseSW setOn:clockwise];
    _clockwise = clockwise;
}

- (void)setDisplayNum:(NSUInteger)displayNum {
    self.gradientView.displayNum = displayNum;
    self.displayNumSlider.value = displayNum;
    self.displayNumLab.text = [NSString stringWithFormat:@"%ld", displayNum];
    _displayNum = displayNum;
}

#pragma mark - actions
- (IBAction)changeStartAngle:(UISlider *)sender {
    self.startAngle = sender.value;
}

- (IBAction)changeEndAngle:(UISlider *)sender {
    self.endAngle = sender.value;
}

- (IBAction)changeColorNum:(UISlider *)sender {
    self.colorNum = sender.value;
}

- (IBAction)changeArcWidth:(UISlider *)sender {
    self.arcWidth = sender.value;
}

- (IBAction)changeClockwise:(UISwitch *)sender {
    self.clockwise = sender.isOn;
}

- (IBAction)changeDisplayNum:(UISlider *)sender {
    self.displayNum = sender.value;
}



@end
