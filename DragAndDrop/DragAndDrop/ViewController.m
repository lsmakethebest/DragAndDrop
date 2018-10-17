//
//  ViewController.m
//  fsdlslsss
//
//  Created by liusong on 2018/10/17.
//  Copyright © 2018年 liusong. All rights reserved.
//
#import "ViewController.h"
#define CScreenWidth        [[UIScreen mainScreen] bounds].size.width
#define CScreenHeight       [[UIScreen mainScreen] bounds].size.height
#define ScreenHeight        self.view.frame.size.height
#define ScreenWidth         self.view.frame.size.width

@interface ViewController ()<UIDragInteractionDelegate,UIDropInteractionDelegate>

@property (nonatomic, strong)UIImageView *img;
@property (nonatomic, strong)UIImageView *img2;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.img =[[UIImageView alloc] initWithImage:[UIImage imageNamed:@"pic"]];
    self.img.frame = CGRectMake(20, 40, CScreenWidth-40, 200);
    self.img.userInteractionEnabled = YES;
    [self.view addSubview:self.img];
    //Drag发送数据，Drop接收数据
    UIDragInteraction *dragInter = [[UIDragInteraction alloc] initWithDelegate:self];
    dragInter.enabled = YES;
    [self.img addInteraction:dragInter];
    [self.view addInteraction:[[UIDropInteraction alloc] initWithDelegate:self]];
    
    self.img2 =[[UIImageView alloc] init];
    self.img2.frame = CGRectMake(20, CScreenHeight-250, CScreenWidth-40, 200);
    self.img2.userInteractionEnabled = YES;
    [self.view addSubview:self.img2];
    
}
#pragma mark -UIDragInteractionDelegate
//提供数据源  开始拖拽
- (NSArray<UIDragItem *> *)dragInteraction:(UIDragInteraction *)interaction itemsForBeginningSession:(id<UIDragSession>)session{
    NSLog(@"11111----");
    self.img2.image = nil;
    NSItemProvider *item = [[NSItemProvider alloc] initWithObject:self.img.image];
    UIDragItem *dragItem = [[UIDragItem alloc] initWithItemProvider:item];
    dragItem.localObject = self.img.image;
    return @[dragItem];
}
//提供preview相关信息
- (nullable UITargetedDragPreview *)dragInteraction:(UIDragInteraction *)interaction previewForLiftingItem:(UIDragItem *)item session:(id<UIDragSession>)session{
    NSLog(@"22222----");
    UIDragPreviewParameters *parameters = [[UIDragPreviewParameters alloc] init];
    //设置蒙版mask
    parameters.visiblePath = [UIBezierPath bezierPathWithRoundedRect:self.img.bounds cornerRadius:10];
    //设置在哪个父视图和哪个位置展示
    UIDragPreviewTarget *target = [[UIDragPreviewTarget alloc] initWithContainer:self.img.superview center:self.img.center];
    UITargetedDragPreview *dragePreview = [[UITargetedDragPreview alloc] initWithView:interaction.view parameters:parameters target:target];
    return dragePreview;
}
//drag进行时
- (void)dragInteraction:(UIDragInteraction *)interaction willAnimateLiftWithAnimator:(id<UIDragAnimating>)animator session:(id<UIDragSession>)session{
    NSLog(@"33333----");
    [animator addCompletion:^(UIViewAnimatingPosition finalPosition) {
        if (finalPosition == UIViewAnimatingPositionEnd) {
            self.img.alpha = 0.5;
        }
    }];
}
//drag将要结束时调用
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session willEndWithOperation:(UIDropOperation)operation{
    NSLog(@"44444----");
    [UIView animateWithDuration:0.5 animations:^{
        self.img.alpha = 1;
    }];
}
//drag动画将要取消时
- (void)dragInteraction:(UIDragInteraction *)interaction item:(UIDragItem *)item willAnimateCancelWithAnimator:(id<UIDragAnimating>)animator{
    NSLog(@"55555----");
    [animator addAnimations:^{
        self.img.alpha = .1;
    }];
}
//drag已经结束时调用
- (void)dragInteraction:(UIDragInteraction *)interaction session:(id<UIDragSession>)session didEndWithOperation:(UIDropOperation)operation{
    NSLog(@"66666----");
    [UIView animateWithDuration:0.5 animations:^{
        self.img.alpha = 1;
    }];
}

#pragma mark --UIDropInteractionDelegate
//是否可以接收来自Drag数据
- (BOOL)dropInteraction:(UIDropInteraction *)interaction canHandleSession:(id<UIDropSession>)session{
    if(session.localDragSession == nil){//说明数据来自外界
    }
    return [session canLoadObjectsOfClass:[UIImage class]];
}

//第二次判断是否可以接收 无法接收用UIDropOperationCancel
- (UIDropProposal *)dropInteraction:(UIDropInteraction *)interaction sessionDidUpdate:(id<UIDropSession>)session{
    UIDropOperation opera = session.localDragSession? UIDropOperationCopy:UIDropOperationCancel;
    return [[UIDropProposal alloc] initWithDropOperation:opera];
}

//取出来自drag的数据
- (void)dropInteraction:(UIDropInteraction *)interaction performDrop:(id<UIDropSession>)session{
    if (session.localDragSession) {
        NSProgress *pregesss  = [session loadObjectsOfClass:[UIImage class] completion:^(NSArray<__kindof id<NSItemProviderReading>> * _Nonnull objects) {
            // 回调的代码块默认就在主线程
            for (id objc in objects) {
                UIImage *image = (UIImage *)objc;
                if (image) {
                    self.img2.image = image;
                }
            }
        }];
    }
}

@end


