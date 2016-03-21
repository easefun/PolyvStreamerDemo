//
//  CameraViewController.m
//  PolyvStreamerDemo
//
//  Created by FT on 16/3/17.
//  Copyright © 2016年 polyv. All rights reserved.
//

#import "CameraViewController.h"
#import "PLVSession.h"

//遵循PVSessionDelegate的协议
@interface CameraViewController ()<PLVSessionDelegate>

@property (nonatomic ,strong)PLVSession *session;

@end

@implementation CameraViewController

- (void)viewDidLoad {
    [super viewDidLoad];
 

    CGSize videoSize = CGSizeMake(1280, 720);
    
    //1.初始化一个session
    _session = [[PLVSession alloc] initWithVideoSize:videoSize frameRate:25 bitrate:600*1024 useInterfaceOrientation:YES];
   
    //2.设置session的previewView，并添加到相应视图上
    _session.previewView.frame = self.previewView.bounds;
    [self.previewView addSubview:_session.previewView];

    //3.设置session的代理
    _session.delegate = self;
    
    
    //把直播状态label显示到最上端
    [self.previewView bringSubviewToFront:self.stateLabel];
}

#pragma mark - 点击streamButton时调用

- (IBAction)streamButton:(id)sender {
    
    switch( _session.rtmpSessionState ) {
        
        case PLVSessionStateNone:
        case PLVSessionStatePreviewStarted:
        case PLVSessionStateEnded:
        case PLVSessionStateError:

            //使用channelId（直播频道）和password（密码）参数进行推流
            [_session startRtmpSessionWithChannelId:@"99778" andPassword:@"1234567"failure:^(NSString *msg) {

                NSLog(@"--%@",msg);
            }];

            break;
            
        default:
            //结束推流
            [_session endRtmpSession];
            break;
    }
 
}


#pragma mark - PLVSessionDelegate的代理方法

- (void)connectionStatusChanged:(PLVSessionState)sessionState {

    //注意：如果使用sizeclass和aotuLayout做屏幕适配和约束，在更新UI时需要回到主线程更新

    switch( sessionState ) {
        case PLVSessionStateStarting:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"block.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在连接";
            });
        }
            break;
            
        case PLVSessionStateStarted:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"to_stop.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"正在直播";
            });
        }
            break;
            
        default:
        {
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [self.streamButton setImage:[UIImage imageNamed:@"to_start.png"] forState:UIControlStateNormal];
                self.stateLabel.text = @"未直播";
            });
        }
            break;
    }

}



- (IBAction)cancelButtonPress:(UIButton *)sender {
    

    [_session endRtmpSession];
    
    //在当前控制器销毁时（dismissViewController、popViewController等）一般加上此行代码，防止页面退出后继续再次执行代理方法
    //如果在connectionStatusChanged：代理方法中使用了回到主线程更新，此处需要设置代理人为空，否则可能因为实例对象被销毁确继续在主线程调用其方法造成崩溃
    _session.delegate = nil;

    [self dismissViewControllerAnimated:YES completion:nil];
}


#pragma mark - 视屏填充方式


- (IBAction)filterButtonpress:(UIButton *)sender {
    
    //设置视频的filter（特效）
    switch (_session.filter) {
        case PLVFilterNormal:
            [_session setFilter:PLVFilterGray];
            break;
        case PLVFilterGray:
            [_session setFilter:PLVFilterInvertColors];
            break;
        case PLVFilterInvertColors:
            [_session setFilter:PLVFilterSepia];
            break;
        case PLVFilterSepia:
            [_session setFilter:PLVFilterNormal];
            break;
            
        default:
            break;
    }
}


#pragma mark - 摄像头翻转

- (IBAction)switchButtonPress:(UIButton *)sender {
    
    if ( _session.cameraState ) {
        [_session setCameraState:PLVCameraStateFront];
    }else {
        [_session setCameraState:PLVCameraStateBack];
    }

}




- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    
    [_session endRtmpSession];
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
