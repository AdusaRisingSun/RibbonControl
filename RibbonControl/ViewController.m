//
//  ViewController.m
//  RibbonControl
//
//  Created by Adusa on 15/9/6.
//  Copyright (c) 2015年 Adusa. All rights reserved.
//

#import "ViewController.h"
#import "RibbonPull.h"
#import <QuartzCore/QuartzCore.h>
const CGFloat kDesiredHeight=120.0f;

@interface ViewController ()

@end

@implementation ViewController
{
    RibbonPull *ribbonPull;
    UIView *hiddenView;
    NSLayoutConstraint *ribbonPullTopConstraint;
    NSLayoutConstraint *hiddentViewTopConstraint;
    BOOL isHidden;
}

- (void)viewDidLoad {
    [super viewDidLoad];
    isHidden=YES;
    hiddenView=[[UIView  alloc]init];
    hiddenView.backgroundColor=[UIColor greenColor];
    //[hiddenView setBounds:CGRectMake(0, 0, self.view.bounds.size.width, 120.0)];
    [self.view addSubview:hiddenView];
    ribbonPull=[[RibbonPull alloc]init];
    [self.view addSubview:ribbonPull];
    
    [hiddenView setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:hiddenView attribute: NSLayoutAttributeLeft relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeLeft multiplier:1.0f constant:0.0f]];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:hiddenView attribute: NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:0.0f]];
    
    [hiddenView addConstraints:[NSLayoutConstraint constraintsWithVisualFormat:(@"V:[hiddenView(==120.0)]") options:0 metrics:nil views:NSDictionaryOfVariableBindings(hiddenView)]];
    hiddentViewTopConstraint =[NSLayoutConstraint constraintWithItem:hiddenView attribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:-kDesiredHeight];
    [self.view addConstraint:hiddentViewTopConstraint];
    
    [ribbonPull setTranslatesAutoresizingMaskIntoConstraints:NO];
    [self.view addConstraint:[NSLayoutConstraint constraintWithItem:ribbonPull attribute: NSLayoutAttributeRight relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeRight multiplier:1.0f constant:-30]];
    ribbonPullTopConstraint =[NSLayoutConstraint constraintWithItem:ribbonPull attribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
     [self.view addConstraint:ribbonPullTopConstraint];
 
    [ribbonPull addTarget:self action:@selector(ribbonPull:) forControlEvents:UIControlEventValueChanged];
    
    // Do any additional setup after loading the view, typically from a nib.
}

-(void)ribbonPull:(UIControl *)rp
{
    [self.view removeConstraint:hiddentViewTopConstraint];
    [self.view removeConstraint:ribbonPullTopConstraint];
    if (isHidden) {
        hiddentViewTopConstraint=[NSLayoutConstraint constraintWithItem:hiddenView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
        ribbonPullTopConstraint=[NSLayoutConstraint constraintWithItem:ribbonPull attribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:kDesiredHeight];
    }else
    {
        hiddentViewTopConstraint=[NSLayoutConstraint constraintWithItem:hiddenView attribute:NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:-kDesiredHeight];
        ribbonPullTopConstraint=[NSLayoutConstraint constraintWithItem:ribbonPull attribute: NSLayoutAttributeTop relatedBy:NSLayoutRelationEqual toItem:self.view attribute:NSLayoutAttributeTop multiplier:1.0f constant:0];
    }
    [self.view addConstraint:hiddentViewTopConstraint];
    [self.view addConstraint:ribbonPullTopConstraint];
    [UIView animateWithDuration:1.0f animations:^(){
        [self.view layoutIfNeeded];
    }];
    isHidden=!isHidden;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
