//
//  RibbonPull.m
//  RibbonControl
//
//  Created by Adusa on 15/9/6.
//  Copyright (c) 2015年 Adusa. All rights reserved.
//

#import "RibbonPull.h"
#import <AudioToolbox/AudioToolbox.h>

static NSUInteger alphaOffset(NSUInteger x,NSUInteger y,NSUInteger w)
{
    return y*w*4+x*4+0;
}

NSData *getBitmapFromImage(UIImage *sourceImage)
{
    if (!sourceImage) {
        return nil;
    }
    CGColorSpaceRef colorSpace=CGColorSpaceCreateDeviceRGB();
    if (colorSpace==NULL) {
        NSLog(@"Error creating RGB color space");
        return nil;
    }
    int width=sourceImage.size.width;
    int height=sourceImage.size.height;
    /*
    CGContextRef CGBitmapContextCreate (
                                        
                                        void *data,
                                        size_t width,
                                        size_t height,
                                        size_t bitsPerComponent,
                                        size_t bytesPerRow,
                                        CGColorSpaceRef colorspace,
                                        CGBitmapInfo bitmapInfo
                                        );
    data                                    指向要渲染的绘制内存的地址。这个内存块的大小至少是（bytesPerRow*height）个字节
    
    width                                  bitmap的宽度,单位为像素
    height                                bitmap的高度,单位为像素
    
    bitsPerComponent        内存中像素的每个组件的位数.例如，对于32位像素格式和RGB 颜色空间，你应该将这个值设为8.
    
    bytesPerRow                  bitmap的每一行在内存所占的比特数
    
    colorspace                      bitmap上下文使用的颜色空间。
    
    bitmapInfo                       指定bitmap是否包含alpha通道，像素中alpha通道的相对位置，像素组件是整形还是浮点型等信息的字符串。
    当你调用这个函数的时候，Quartz创建一个位图绘制环境，也就是位图上下文。当你向上下文中绘制信息时，Quartz把你要绘制的信息作为位图数据绘制到指定的内存块。一个新的位图上下文的像素格式由三个参数决定：每个组件的位数，颜色空间，alpha选项。alpha值决定了绘制像素的透明性。
     */
    CGContextRef context=CGBitmapContextCreate(NULL, width, height, 8, width*4, colorSpace, (CGBitmapInfo)kCGImageAlphaPremultipliedFirst);
    CGColorSpaceRelease(colorSpace);
    if(context==NULL)
    {
        NSLog(@"Error creating context");
        return nil;
    }
    CGRect rect=(CGRect){.size=sourceImage.size};
    CGContextDrawImage(context, rect, sourceImage.CGImage);
    
    NSData *data=[NSData dataWithBytes:CGBitmapContextGetData(context) length:width*height*4];
    CGContextRelease(context);
    
    return data;
}

@implementation RibbonPull
{
    NSData *ribbonData;
    UIImage *ribbonImage;
    UIImageView *pullImageView;
    CGPoint touchDownPoint;
    int wiggleCount;
    UIMotionEffectGroup *motionEffectsGroup;
}

-(instancetype)initWithFrame:(CGRect)aframe
{
    self=[super initWithFrame:aframe];
    if (self) {
        CGRect f=aframe;
        f.size=self.intrinsicContentSize;
        self.frame=f;
        self.backgroundColor=[UIColor clearColor];
        self.clipsToBounds=YES;
        
        ribbonImage=[UIImage imageNamed:@"Ribbon.png"];
        ribbonData=getBitmapFromImage(ribbonImage);
        
        pullImageView=[[UIImageView alloc]initWithImage:ribbonImage];
        pullImageView.frame=CGRectMake(10.0f, 75.0f-ribbonImage.size.height, ribbonImage.size.width, ribbonImage.size.height);
        
        [self startMotionEffects];
        wiggleCount=0;
        [self addSubview:pullImageView];
        [self performSelector:@selector(wiggle) withObject:nil afterDelay:4.0f];
    }
    return self;
}

-(CGSize)intrinsicContentSize
{
    return CGSizeMake(80.0f, 175.0f);
}

-(void)startMotionEffects
{
    UIInterpolatingMotionEffect *motionEffectX=[[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.x" type:UIInterpolatingMotionEffectTypeTiltAlongHorizontalAxis];
    UIInterpolatingMotionEffect *motionEffectY=[[UIInterpolatingMotionEffect alloc]initWithKeyPath:@"center.y" type:UIInterpolatingMotionEffectTypeTiltAlongVerticalAxis];
    motionEffectX.minimumRelativeValue=@-15.0;
    motionEffectX.maximumRelativeValue=@15.0;
    motionEffectY.minimumRelativeValue=@-15.0;
    motionEffectY.maximumRelativeValue=@15.0f;
    motionEffectsGroup=[[UIMotionEffectGroup alloc]init];
    motionEffectsGroup.motionEffects=@[motionEffectX,motionEffectY];
    [pullImageView addMotionEffect:motionEffectsGroup];
}

-(void)stopMotionEffects
{
    [pullImageView  removeMotionEffect:motionEffectsGroup];
    motionEffectsGroup=nil;
}

-(void)wiggle
{
    if (++wiggleCount>3) {
        return;
    }
    [self stopMotionEffects];
    [UIView animateWithDuration:0.25f animations:^(){
        pullImageView.center=CGPointMake(pullImageView.center.x, pullImageView.center.y+10.0f);
    }completion:^(BOOL finished){
        [UIView animateWithDuration:0.25f animations:^(){
            pullImageView.center=CGPointMake(pullImageView.center.x, pullImageView.center.y-10.0f);
        }completion:^(BOOL finished){
            [self startMotionEffects];
        }];
    }];
    [self performSelector:@selector(wiggle) withObject:nil afterDelay:4.0f];
}

void _systemSoundDidComplete(SystemSoundID ssID,void *clientData)
{
    AudioServicesDisposeSystemSoundID(ssID);
}

//音效
-(void)playClick
{
    NSString *sndpath=[[NSBundle mainBundle]pathForResource:@"click" ofType:@"wav"];
    CFURLRef baseURL=(CFURLRef)CFBridgingRetain([NSURL fileURLWithPath:sndpath]);
    
    SystemSoundID sysSound;
    AudioServicesCreateSystemSoundID(baseURL, &sysSound);
    CFRelease(baseURL);
    
    AudioServicesAddSystemSoundCompletion(sysSound, NULL, NULL, _systemSoundDidComplete, NULL);
    AudioServicesPlaySystemSound(sysSound);
}

-(BOOL)beginTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    Byte *bytes=(Byte*)ribbonData.bytes;
    
    CGPoint touchPoint=[touch locationInView:self];
    CGPoint ribbonPoint=[touch locationInView:pullImageView];
    uint offset=alphaOffset(ribbonPoint.x, ribbonPoint.y, pullImageView.bounds.size.width);
    if (CGRectContainsPoint(pullImageView.frame, touchPoint)&&(bytes[offset]>85)) {
        [self sendActionsForControlEvents:UIControlEventTouchDown];
        touchDownPoint=touchPoint;
        return YES;
    }
    return NO;
}

-(BOOL)continueTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    wiggleCount=CGFLOAT_MAX;
    CGPoint touchPoint=[touch locationInView:self];
    if (CGRectContainsPoint(self.frame, touchPoint)) {
        [self sendActionsForControlEvents:UIControlEventTouchDragInside];
    }
    else
    {
        [self sendActionsForControlEvents:UIControlEventTouchDragOutside];
    }
    CGFloat dy=MAX(touchPoint.y-touchDownPoint.y, 0.0f);
    dy=MIN(dy, self.bounds.size.height-75.0f);
    
    pullImageView.frame=CGRectMake(10.0f, dy+75.0f-ribbonImage.size.height, ribbonImage.size.width, ribbonImage.size.height);
    if (dy>75.0f) {
        [self playClick];
        [UIView animateWithDuration:0.3f animations:^(){
            pullImageView.frame=CGRectMake(10.0f, 75.0f-ribbonImage.size.height, ribbonImage.size.width, ribbonImage.size.height);
        }completion:^(BOOL finished){
            [self sendActionsForControlEvents:UIControlEventValueChanged];
        }];
        return NO;
    }
    return YES;
}

-(void)endTrackingWithTouch:(UITouch *)touch withEvent:(UIEvent *)event
{
    CGPoint touchPoint=[touch locationInView:self];
    if (CGRectContainsPoint(self.bounds, touchPoint)) {
        [self sendActionsForControlEvents:UIControlEventTouchUpInside];
    }else
    {
        [self sendActionsForControlEvents:UIControlEventTouchUpOutside];
    }
    [UIView animateWithDuration:0.3f animations:^(){
        pullImageView.frame=CGRectMake(10.0f, 75.0f-ribbonImage.size.height, ribbonImage.size.width, ribbonImage.size.height);
    }];
}
-(void)cancelTrackingWithEvent:(UIEvent *)event
{
    [self sendActionsForControlEvents:UIControlEventTouchCancel];
}
/*
// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect {
    // Drawing code
}
*/

@end
