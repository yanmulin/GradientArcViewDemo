# 基于CALayer和仿射变换实现无限颜色的渐变色弧和色环

## 本文目标

本文实现一个如下接口的渐变色环/色弧，可以自定以起始角度、结束角度、跨度、颜色、顺时针方向等属性，并动态的增加或移除颜色。

```
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
```

实现的效果如下图：

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-5.png](https://i.loli.net/2019/06/13/5d01a6b8155b624597.png)


## 基本思路

将一个圆弧/圆环等分成很多个渐变层，令纯色层和渐变层交替出现。如下图所示，红色代表纯色层，灰色代表从上一个颜色到下一个颜色的渐变层。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-1.png](https://i.loli.net/2019/06/13/5d01a80f6d32e50492.png)

然后用仿射变换将矩形的`CAGradientLayer`映射到该色块上。仿射变换可以将矩形变换到平行四边形，学名叫剪切，shear。苹果的`CGAffineTransform`相关函数并没有提供从矩形到平行四边形的仿射变换，所以需要自己求解仿射变换矩形。下面介绍仿射变换和剪切矩阵的求解方法。

### 仿射变换

仿射变换是一个向量空间进行一次线性变换并接上一个平移，变换到另一个向量空间。简单来说，就是坐标系的任意点，乘上一个矩阵，就可以变换成另一个点；那么一个形状，乘上一个矩阵，也能变换成另一个形状。

这个矩阵要求满足一定形式，苹果仿射变换的文档作了说明：

![1](https://docs-assets.developer.apple.com/published/8a0bbde8e5/equation01_2x_fabc9070-1967-4d6f-a086-17ab5fcfef6d.png)

对于二维坐标系上的点，仿射变换后的点这样计算：

![2](https://docs-assets.developer.apple.com/published/8a0bbde8e5/equation02_2x_71f7e62f-7cbe-4670-9b34-924b49e48f72.png)

转化为线性方程：

![3](https://docs-assets.developer.apple.com/published/8a0bbde8e5/equation03_2x_b4b74916-ba29-4c3c-8fa2-ada82ad5c659.png)

### 求解剪切矩阵

求解方法用到下面的线形方程组：

![3](https://docs-assets.developer.apple.com/published/8a0bbde8e5/equation03_2x_b4b74916-ba29-4c3c-8fa2-ada82ad5c659.png)

矩形到平行四边形的仿射变换如下图：

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-2.png](https://i.loli.net/2019/06/13/5d01a6b7debb114086.png)

tx和tyb代表平移，直接赋值为0。其他变量代入上面的线性方程组：

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-3.gif](https://i.loli.net/2019/06/13/5d01a6b7d4c5356257.gif)  

得到解：

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-4.gif](https://i.loli.net/2019/06/13/5d01a6b7d6e9c89505.gif)  

将a, b, c, d的值分别代入`CGAffineTransformMake()`的各项参数，得到代码：

```
- (CGAffineTransform)shearAffineTransformForAngle:(CGFloat)angle {
return CGAffineTransformMake(1.0, 0.0, cosf(angle), sinf(angle), 0.0, 0.0);
}
```

### 应用仿射变换

如果有N种颜色，创建第i个`CAGradientLayer`，填充满整个屏幕，然后对该`CALayer`按照平移、剪切，旋转的顺序进行变换。由于矩阵运算不具有交换律，这个顺序不能改变。

写出来的代码是这样子：

```
gradientLayer.affineTransform =    
CGAffineTransformConcat(
CGAffineTransformMakeTranslation(self.boundsCenter.x, self.boundsCenter.y), 
CGAffineTransformConcat(
self.shearAffineTransform, 
CGAffineTransformMakeRotation(self.angleStep * i)
)
);
```

先进行剪切的原因是这个剪切的性质是确保与x轴平行的边不会发生变化，如果先进行旋转则两条边都会被“剪切”。

## 渐变块的划分

圆环需要在最后一个颜色后面添加一个到第一个颜色的渐变层，而圆弧则不需要。所以，假设有N种颜色需要渐变，圆环则应该划分为2N块，圆弧则应该划分为2N-1块。

编写代码时会发现，如果将笔触的线头设置为圆头，这个线头则无法被渐变层覆盖。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-6.png](https://i.loli.net/2019/06/13/5d01a6b817a2116509.png)

所以我们将圆弧划分成2N-1+2块，多出来2块用来覆盖线头。这多出来的两块角度跨度根据没有利用的角度范围决定。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-7.png](https://i.loli.net/2019/06/13/5d01a6b82ed3730779.png)


## 特殊的测试用例

本例除了要注意圆弧和圆环的不同的分块方式，此外还存在一些的无效输入或边界条件，需要特殊处理。

### 无颜色输入

不显示。

### 输入一种颜色

输入一种颜色时，本例用一个纯色块作为背景。

### 起始角度到结束角度的增长方向与顺时针方向设置不同

不显示。

## 最终效果

![基于CAla<x>yer和仿射变换实现无限颜色的渐变圆弧-5.png](https://i.loli.net/2019/06/13/5d01a6b8155b624597.png)

## 总结

本文介绍了用CALayer和仿射变换实现多种颜色渐变色弧和色环。基本思路是将圆弧/环划分成多份色块，然后通过仿射变换将`CAGradientLayer`剪切到这些色块上，在这些色块上实现交替的渐变效果。最终实现的Demo点击[这里](https://github.com/yanmulin/GradientArcViewDemo)下载。

## 更新：改进

渐变块间隔着纯色块的划分方式不能保证渐变块最大。如果有N种颜色，将圆弧划分成N-1个渐变块，圆环N个渐变块，中间没有纯色块，这样就使得渐变块最大。划分方式如下图，全部都是渐变块，无纯色块。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-8.png](https://i.loli.net/2019/06/13/5d01a6b80215b44070.png)

这种划分方式会如果划分成2块（圆弧3种颜色，圆环2种颜色），角度跨度较大，每块接近180度，则仿射变换后的CAGradientLayer形状向一条直线趋近，不能覆盖圆弧/圆弧。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-9.png](https://i.loli.net/2019/06/13/5d01a6b83a74522878.png)

所以要为圆环2种颜色，圆弧3种颜色设计新的划分方案。本文采用的方案是，无论（圆环/圆弧）2种颜色时，用一个渐变块；圆弧3种颜色且角度跨度大于270度时，添加一个纯色块。

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-10.png](https://i.loli.net/2019/06/13/5d01a6b8e22f277896.png)

![基于CAlayer和仿射变换实现无限颜色的渐变圆弧-11.png](https://i.loli.net/2019/06/13/5d01a6ba52b1911178.png)

为了代码可读性和扩展性，本文还将所有计算变换的部分提炼成函数，比如计算剪切角度、仿射矩阵等等。
