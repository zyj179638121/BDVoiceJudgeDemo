//
//  ViewController.m
//  JudgeVoiceDemo
//
//  Created by 赵永杰 on 2017/7/17.
//  Copyright © 2017年 zhaoyongjie. All rights reserved.
//

#import "ViewController.h"
#import "BDRecognizerViewController.h"
#import "BDVRSConfig.h"

#define APPID @"9898366"
#define API_KEY @"LaBU6fzudSC3HXCrLukKGm0V"
#define SECRET_KEY @"61edd4ee9b84311f43f6d9cc037712a8"

@interface ViewController ()<BDRecognizerViewDelegate>

@property (nonatomic, strong) BDRecognizerViewController *recognizerViewController;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
}

// 识别语音
- (IBAction)beginRecord:(UIButton *)sender {
    
    
    // 创建识别控件
    BDRecognizerViewController *tmpRecognizerViewController = [[BDRecognizerViewController alloc] initWithOrigin:CGPointMake(40, 128) withTheme:[BDVRSConfig sharedInstance].theme];
    
    // 全屏UI
    if ([[BDVRSConfig sharedInstance].theme.name isEqualToString:@"全屏亮蓝"]) {
        tmpRecognizerViewController.enableFullScreenMode = YES;
    }
    
    tmpRecognizerViewController.delegate = self;
    
    self.recognizerViewController = tmpRecognizerViewController;

    
    // 设置识别参数
    BDRecognizerViewParamsObject *paramsObject = [[BDRecognizerViewParamsObject alloc] init];
    
    // 开发者信息，必须修改API_KEY和SECRET_KEY为在百度开发者平台申请得到的值，否则示例不能工作
    paramsObject.apiKey = API_KEY;
    paramsObject.secretKey = SECRET_KEY;
    
    // 设置是否需要语义理解，只在搜索模式有效
    paramsObject.isNeedNLU = [BDVRSConfig sharedInstance].isNeedNLU;
    
    // 设置识别语言
    paramsObject.language = [BDVRSConfig sharedInstance].recognitionLanguage;
    
    // 设置识别模式，分为搜索和输入
    paramsObject.recogPropList = @[[BDVRSConfig sharedInstance].recognitionProperty];
    
    // 设置城市ID，当识别属性包含EVoiceRecognitionPropertyMap时有效
    paramsObject.cityID = 1;
    
    // 开启联系人识别
    //    paramsObject.enableContacts = YES;
    
    // 设置显示效果，是否开启连续上屏
    if ([BDVRSConfig sharedInstance].resultContinuousShow)
    {
        paramsObject.resultShowMode = BDRecognizerResultShowModeContinuousShow;
    }
    else
    {
        paramsObject.resultShowMode = BDRecognizerResultShowModeWholeShow;
    }
    
    // 设置提示音开关，是否打开，默认打开
    if ([BDVRSConfig sharedInstance].uiHintMusicSwitch)
    {
        paramsObject.recordPlayTones = EBDRecognizerPlayTonesRecordPlay;
    }
    else
    {
        paramsObject.recordPlayTones = EBDRecognizerPlayTonesRecordForbidden;
    }
    
    paramsObject.isShowTipAfter3sSilence = NO;
    paramsObject.isShowHelpButtonWhenSilence = NO;
    paramsObject.tipsTitle = @"可以使用如下指令记账";
    paramsObject.tipsList = [NSArray arrayWithObjects:@"我要记账", @"买苹果花了十块钱", @"买牛奶五块钱", @"第四行滚动后可见", @"第五行是最后一行", nil];
    
    paramsObject.appCode = APPID;
//    paramsObject.licenseFilePath= [[NSBundle mainBundle] pathForResource:@"temp_license_2017-07-17" ofType:@""];
    paramsObject.datFilePath = [[NSBundle mainBundle] pathForResource:@"s_1" ofType:@""];
    if ([[BDVRSConfig sharedInstance].recognitionProperty intValue] == EVoiceRecognitionPropertyMap) {
        paramsObject.LMDatFilePath = [[NSBundle mainBundle] pathForResource:@"s_2_Navi" ofType:@""];
    } else if ([[BDVRSConfig sharedInstance].recognitionProperty intValue] == EVoiceRecognitionPropertyInput) {
        paramsObject.LMDatFilePath = [[NSBundle mainBundle] pathForResource:@"s_2_InputMethod" ofType:@""];
    }
    
    paramsObject.recogGrammSlot = @{@"$name_CORE" : @"张三\n李四\n",
                                    @"$song_CORE" : @"小苹果\n朋友\n",
                                    @"$app_CORE" : @"QQ\n百度\n微信\n百度地图\n",
                                    @"$artist_CORE" : @"刘德华\n周华健\n"};
    
    [self.recognizerViewController startWithParams:paramsObject];

}

- (void)onEndWithViews:(BDRecognizerViewController *)aBDRecognizerViewController withResults:(NSArray *)aResults
{
    
    if ([[BDVoiceRecognitionClient sharedInstance] getRecognitionProperty] != EVoiceRecognitionPropertyInput)
    {
        // 搜索模式下的结果为数组，示例为
        // ["公园", "公元"]
        NSMutableArray *audioResultData = (NSMutableArray *)aResults;
        NSMutableString *tmpString = [[NSMutableString alloc] initWithString:@""];
        
        for (int i=0; i < [audioResultData count]; i++)
        {
            [tmpString appendFormat:@"%@\r\n",[audioResultData objectAtIndex:i]];
        }
        
        NSLog(@"resultStr = %@",tmpString);
        [self showWithResultString:tmpString];

    }
    else
    {
 
        NSString *tmpString = [[BDVRSConfig sharedInstance] composeInputModeResult:aResults];
        NSLog(@"resultStr = %@",tmpString);
        [self showWithResultString:tmpString];
    }
}


- (void)showWithResultString:(NSString *)resultStr {
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:nil message:resultStr preferredStyle:UIAlertControllerStyleAlert];
    [alert addAction:[UIAlertAction actionWithTitle:@"确定" style:UIAlertActionStyleCancel handler:nil]];
    [self presentViewController:alert animated:YES completion:nil];
}

@end
