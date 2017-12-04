//
//  ViewController.m
//  a1
//
//  Created by uosim on 2017/11/19.
//  Copyright © 2017年 ss. All rights reserved.
//

#import "ViewController.h"
#import "FMDB.h"
#import "AFNetworking.h"
#import "SVProgressHUD.h"
#import "sw1.h"
#import "GCDAsyncSocket.h"
#import "GCDAsyncUdpSocket.h"
#import <CommonCrypto/CommonDigest.h>
#import "SwTool.h"
#import <AVFoundation/AVFoundation.h>
#import <CoreGraphics/CoreGraphics.h>
#import <CoreVideo/CoreVideo.h>
#import <CoreMedia/CoreMedia.h> 
#import "SwAudioRec.h"
#import "FrmViewDesc.h"
#import "TT1ViewController.h"
#import "V1.h"

#define dataBasePath [[(NSSearchPathForDirectoriesInDomains(NSDocumentDirectory,NSUserDomainMask,YES)) lastObject]stringByAppendingPathComponent:dataBaseName]
#define dataBaseName @"test.sqlite"


@interface ViewController ()
@property (weak, nonatomic) IBOutlet UIImageView *imgDest1;
@property (weak, nonatomic) IBOutlet UIImageView *imgSrc1;
@property (nonatomic, strong) GCDAsyncSocket *sock;

@property (nonatomic, retain) AVCaptureSession *captureSession;
@property (nonatomic, retain) UIImageView *imageView;
@property (nonatomic, retain) CALayer *customLayer;
@property (nonatomic, retain) AVCaptureVideoPreviewLayer *prevLayer;
@property (nonatomic, strong) SwAudioRec *audio_rec;
- (void)initCapture;


@end

@implementation ViewController
int ii=0;
@synthesize captureSession = _captureSession;
@synthesize imageView = _imageView;
@synthesize customLayer = _customLayer;
@synthesize prevLayer = _prevLayer;

- (AVCaptureDevice *)cameraWithPosition:(AVCaptureDevicePosition)position{
    NSArray *devices = [AVCaptureDevice devicesWithMediaType:AVMediaTypeVideo];
    for ( AVCaptureDevice *device in devices )
    {
        if ( device.position == position ){
            return device;
        }
    }
    return nil;
}

- (void)initCapture
{
    
    AVCaptureDevice *newCamera = nil;
    newCamera = [self cameraWithPosition:AVCaptureDevicePositionFront];
    AVCaptureDeviceInput *captureInput = [AVCaptureDeviceInput deviceInputWithDevice:newCamera error:nil];
    AVCaptureVideoDataOutput *captureOutput = [[AVCaptureVideoDataOutput alloc] init];
    captureOutput.alwaysDiscardsLateVideoFrames = YES;
    //captureOutput.minFrameDuration = CMTimeMake(1, 10);
    
    dispatch_queue_t queue = dispatch_queue_create("cameraQueue", NULL);
    [captureOutput setSampleBufferDelegate:self queue: queue];

    
    NSString* key = (NSString*)kCVPixelBufferPixelFormatTypeKey;
    NSNumber* value = [NSNumber numberWithUnsignedInt:kCVPixelFormatType_32BGRA];
    NSDictionary* videoSettings = [NSDictionary dictionaryWithObject:value forKey:key];
    [captureOutput setVideoSettings:videoSettings];
    self.captureSession = [[AVCaptureSession alloc] init];
    //[self.captureSession setSessionPreset:AVCaptureSessionPreset640x480];
    [self.captureSession addInput:captureInput];
    [self.captureSession addOutput:captureOutput];
    [self.captureSession startRunning];

    self.imageView = [[UIImageView alloc] init];
    self.imageView.frame = CGRectMake(0, 0, 200, 200);
    [self.view addSubview:self.imageView];
    
    self.prevLayer = [AVCaptureVideoPreviewLayer layerWithSession: self.captureSession];
    self.prevLayer.frame = CGRectMake(200, 0, 200, 200);
    self.prevLayer.videoGravity = AVLayerVideoGravityResizeAspectFill;
    [self.view.layer addSublayer: self.prevLayer];
    
}


- (void)captureOutput:(AVCaptureOutput *)captureOutput didOutputSampleBuffer:(CMSampleBufferRef)sampleBuffer fromConnection:(AVCaptureConnection *)connection
{
    
    CVImageBufferRef imageBuffer = CMSampleBufferGetImageBuffer(sampleBuffer);
    CVPixelBufferLockBaseAddress(imageBuffer,0);
    uint8_t *baseAddress = (uint8_t *)CVPixelBufferGetBaseAddress(imageBuffer);
    size_t bytesPerRow = CVPixelBufferGetBytesPerRow(imageBuffer);
    size_t width = CVPixelBufferGetWidth(imageBuffer);
    size_t height = CVPixelBufferGetHeight(imageBuffer);
    
    CGColorSpaceRef colorSpace = CGColorSpaceCreateDeviceRGB();
    CGContextRef newContext = CGBitmapContextCreate(baseAddress,
                                                    width, height, 8, bytesPerRow, colorSpace,
                                                    kCGBitmapByteOrder32Little | kCGImageAlphaPremultipliedFirst);
    CGImageRef newImage = CGBitmapContextCreateImage(newContext);
    
    CGContextRelease(newContext);
    CGColorSpaceRelease(colorSpace);
    
    
    
    UIImage *image= [UIImage imageWithCGImage:newImage scale:1.0 orientation:UIImageOrientationRight];
    
    
    [self.imageView performSelectorOnMainThread:@selector(setImage:) withObject:image waitUntilDone:YES];
    
    CGImageRelease(newImage);
    CVPixelBufferUnlockBaseAddress(imageBuffer,0);
    
}


- (void)viewDidUnload {
    self.imageView = nil;
    self.customLayer = nil;
    self.prevLayer = nil;
}




- (IBAction)btn_img_click:(id)sender
{
    
    UIImage *img=[[self imgSrc1] image];
    NSData *imageData = UIImageJPEGRepresentation(img, 1.0f);
    
    NSString *s=[NSString stringWithFormat:@"%@",
            [imageData base64EncodedStringWithOptions: 0]];
    NSLog(@"img2b64=%@",s);
    
    NSData *dtImg=[[NSData alloc] initWithBase64EncodedString:s options:0];
    UIImage *img1=[UIImage imageWithData:dtImg];
    [[self imgDest1] setImage:img1];
    
    CGAffineTransform t1= CGAffineTransformMakeRotation(M_PI*0.38);
    _imgDest1.transform=t1;

    
}
- (IBAction)btn_form_click:(id)sender {
}

- (IBAction)btn_xxx:(id)sender {
    [self msgbox:@"xxx"];
}

- (IBAction)btn_b64_click:(id)sender
{
    
    NSString *str1=@"我是大花猫123456789";
    NSData *dt1=[str1 dataUsingEncoding:NSUTF8StringEncoding];
    NSString *str2=[dt1 base64EncodedStringWithOptions:0];
    NSLog(@"base64.encode=%@",str2);
    NSData *dt2=[[NSData alloc] initWithBase64EncodedString:str2 options:0];
    NSString *str3=[[NSString alloc] initWithData:dt2 encoding:NSUTF8StringEncoding];
    [self msgbox:str3];
}

- (NSString *) md5:(NSString *) input
{
    const char *cStr = [input UTF8String];
    unsigned char digest[16];
    CC_MD5( cStr, strlen(cStr), digest ); // This is the md5 call
    
    NSMutableString *output = [NSMutableString stringWithCapacity:CC_MD5_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_MD5_DIGEST_LENGTH; i++)
    {
        [output appendFormat:@"%02x", digest[i]];
    }
    return  [output uppercaseString];
}

- (IBAction)btn_md5_click:(id)sender
{
    [self msgbox:[self md5:@"123456"]];
}

- (IBAction)btn_tcp_click:(id)sender
{
    self.sock=[[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error=nil;
    if([self.sock connectToHost:@"wxapi.dalianit.com" onPort:80 error:&error])
    {
        NSLog(@"tcp connnected");
    }
    
}

- (void)sock:(GCDAsyncSocket *)s didConnectToHost:(NSString *)host port:(uint16_t)port
{
    NSLog(@"connected");
}


- (IBAction)btn_fileio_click:(id)sender {
    [self test];
}
- (IBAction)btn_hexbcd_click:(id)sender {
    Byte b=0xae;
    NSLog(@"%x",b);
    
    NSLog(@"%d",addtest(100, 200));
    
    
    
}

-(void)test
{
    NSString *docPath = [NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES) lastObject];
    
    // 获取tmp目录
    NSString *tmpPath = NSTemporaryDirectory();
    
    // 获取Library目录
    NSString *libPath = [NSSearchPathForDirectoriesInDomains(NSLibraryDirectory, NSUserDomainMask, YES) lastObject];
    
    // 获取Library/Caches目录
    NSString *cachePath = [NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) lastObject];
    
    // 获取Library/Preferences目录
    NSString *prePath = [NSSearchPathForDirectoriesInDomains(NSPreferencePanesDirectory, NSUserDomainMask, YES) lastObject];
    //通常情况下，Preferences由系统维护，我们很少去操作TA
    
    // 获取应用程序包的路径
    NSString *path = [NSBundle mainBundle].resourcePath;
    
    NSString *txtPath = [docPath stringByAppendingPathComponent:@"objc.txt"]; // 此时仅存在路径，文件并没有真实存在
    NSString *string = @"Objective-C";
    
    // 字符串写入时执行的方法
    [string writeToFile:txtPath atomically:YES encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"txtPath is %@", txtPath);
    
    // 字符串读取的方法
    NSString *resultStr = [NSString stringWithContentsOfFile:txtPath encoding:NSUTF8StringEncoding error:nil];
    NSLog(@"resultStr is %@", resultStr);
    
    NSFileManager *fileManager = [NSFileManager defaultManager];
    
    // 创建文件夹
    [fileManager createDirectoryAtPath:[cachePath stringByAppendingPathComponent:@"test1"] withIntermediateDirectories:YES attributes:nil error:nil];
    
    BOOL isDir;
    if([fileManager fileExistsAtPath:[cachePath stringByAppendingPathComponent:@"test2"] isDirectory:&isDir])
    {
        NSLog(@"test1 dir ok");
    }
    else
    {
        NSLog(@"test1 dir not found");
    }
    
    NSString* f1=[NSString stringWithFormat:@"%@/txt1.txt",docPath];
    [fileManager createFileAtPath:f1 contents:[@"12345678" dataUsingEncoding:NSUTF8StringEncoding] attributes:nil];
    
    // 获取某个文件或者某个文件夹的大小
    NSDictionary *dic = [fileManager attributesOfItemAtPath:f1 error:nil];
    NSLog(@"%@", dic);
    
    // 创建文件对接对象
    NSFileHandle *fh1 = [NSFileHandle fileHandleForUpdatingAtPath:f1];
    [fh1 seekToFileOffset:3];
    Byte buf[]={0x31,0x32,0x33,0x34,0x35,0x45};
    
    [fh1 writeData:[[NSData alloc] initWithBytes:buf length:sizeof(buf)]];
    [fh1 seekToFileOffset:0];
    NSData *data1=[fh1 readDataOfLength:10];
    [fh1 closeFile];
    NSLog(@"data1=%@,len=%lu",data1,data1.length);
    NSString *s1=[[NSString alloc] initWithData:data1 encoding:NSUTF8StringEncoding];
    NSLog(@"%@",s1);
    
    [self msgbox:resultStr];
}

-(void)msgbox:(NSString*)str
{
    [SVProgressHUD showSuccessWithStatus:str];
}

- (IBAction)hud_click:(id)sender
{
    [SVProgressHUD showSuccessWithStatus:@"指示器OK"];
}

- (void)viewDidLoad {
    _txt_info.text=@"aaaaaaa";
    
    [self initCapture];
    
    //_audio_rec= [[SwAudioRec alloc] init];
    //[_audio_rec startRecorder];

    
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}
- (IBAction)btn_net_click:(id)sender
{

    [[UIApplication sharedApplication] setNetworkActivityIndicatorVisible:YES];
    
    AFHTTPSessionManager *manager = [AFHTTPSessionManager manager];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json",@"text/json",@"text/xml",@"text/html", nil ];
    
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Accept"];
    //[manager.requestSerializer setValue:@"application/json" forHTTPHeaderField:@"Content-Type"];
    manager.requestSerializer = [AFHTTPRequestSerializer serializer];
    manager.responseSerializer = [AFHTTPResponseSerializer serializer];
    
    NSMutableDictionary *params = [NSMutableDictionary dictionary];
    [params setObject:@"13322222222" forKey:@"phone_num"];
    [params setObject:@"123432abcde" forKey:@"user_pass"];
    params[@"username"]=@"sunway";

    
    [manager POST:@"http://wxapi.dalianit.com/t.php?a=a1&b=b1" parameters:params progress:^(NSProgress * _Nonnull uploadProgress) {
        
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable res) {
        NSString *str = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
        NSLog(@"success -- str = %@ ",str);
        
    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"bbbbbbbbbbbb %@",[error localizedDescription]);
    }];
    
    /*
    [manager GET:@"http://wxapi.dalianit.com/t.php?a=a1&b=b1" parameters:@"c=c1&d=d1" progress:^(NSProgress * _Nonnull downloadProgress) {
        NSLog(@"prog....");
    } success:^(NSURLSessionDataTask * _Nonnull task, id  _Nullable res) {
        NSString *str = [[NSString alloc] initWithData:res encoding:NSUTF8StringEncoding];
        NSLog(@"success -- str = %@ ",str);

    } failure:^(NSURLSessionDataTask * _Nullable task, NSError * _Nonnull error) {
        NSLog(@"bbbbbbbbbbbb %@",[error localizedDescription]);
    }];
     */
    
    
}
- (IBAction)btn_timer_click:(id)sender {
    NSTimer *timer = [NSTimer timerWithTimeInterval:0.1 target:self selector:@selector(timerAction) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:timer forMode:NSDefaultRunLoopMode];
}
- (IBAction)btn_cv_click:(id)sender
{
    SwTool* st=[SwTool initWithMiao];
    NSString *str1=[st getVer];
    [self msgbox:str1];
}

-(IBAction)btn1_new_c1:(id)sender
{
    [self msgbox:@"Miao!"];
}

- (IBAction)btn_new1_clk:(id)sender
{
    /*
    UIButton *btn1=[[UIButton alloc] init];
    [btn1 setTitle:@"hello" forState:UIControlStateNormal];
    btn1.frame=CGRectMake(100,300,150,50);
    btn1.backgroundColor = [UIColor redColor];
    [btn1 addTarget:self action:@selector(btn1_new_c1:) forControlEvents:UIControlEventTouchDown];
    [[self view] addSubview:btn1];
     */
    
    
    //FrmViewDesc *frm=[[FrmViewDesc alloc] initWithNibName:@"FrmViewDesc" bundle:nil];
    //TT1ViewController *frm=[[TT1ViewController alloc] initWithNibName:@"TT1ViewController" bundle:nil];
   
    //V1 *vv=[[V1 alloc] initWithFrame:CGRectMake(50, 50, 150, 100)];
    V1 *vv=[[[NSBundle mainBundle] loadNibNamed:@"viewV1" owner:self options:nil] lastObject];
    vv.bounds = CGRectMake(10, 10, 200, 80);
    [[self view] addSubview:vv];
    
    /*
    NSLog(@"try to addsubview frmviewdesc");
    //[self addChildViewController:frm];
    [self presentedViewController];
    [[self view] addSubview:[frm view]];
    */
}

-(void)timerAction
{
    ii++;
    NSString * ss = [[NSString alloc] initWithFormat:@"timer is %d",ii];
    _txt_info.text=ss;
    if(ii>20)ii=0;
    
    CGAffineTransform t1= CGAffineTransformMakeRotation(M_PI*ii/10);
    _imgDest1.transform=t1;

    
}

- (IBAction)btn_json_click:(id)sender {
    NSError * error = nil;
    // 把一个OC中的数据对象(数组或对象--在OC中类似字典)转换成JSON格式的数据
    NSDictionary * dic = @{@"to": @"壮壮",@"content":@"晚上见",@"from": @"晓宇",@"data": @"2014.04.18"};
    NSLog(@"DIC = %@",dic);
    NSData * data = [NSJSONSerialization dataWithJSONObject:dic options:NSJSONWritingPrettyPrinted error:&error];
    
    // 把一个json格式的data,解析为OC中的NSString类型对象
    // 无特殊意义,一般用来查看JSON文本封装成 数组 还是 对象(OC中为字典)
    NSString * jsonString = [[NSString alloc]initWithData:data encoding:NSUTF8StringEncoding];
    NSLog(@"-----------------------------%@",jsonString);
    
    NSDictionary *dict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:nil];
    NSLog(@"---%@",dict);

}

- (IBAction)btn_fmdb_click:(id)sender {
    FMDatabase *db=[FMDatabase databaseWithPath:dataBasePath];
    if([db open])
    {
        _txt_info.text=@"db opened";
        if(![db executeUpdate:@"create table aaa(a1 int,a2 int)"])
        {
            NSString *ee=[db lastErrorMessage];
            NSLog(@"mysql.error %@",ee);
        }
        
        FMResultSet *rs=[db executeQuery:@"select 9*9*9 as a1"];
        while([rs next])
        {
            NSString *name=[rs stringForColumn:@"a1"];
            if(name!=nil)
            {
                [SVProgressHUD showSuccessWithStatus:name];
                _txt_info.text=name;
                NSLog(@"id=%i,name=%@",123,name);
            }
            //_txt_info.text=name;
        }
        
        [rs close];
        [db close];
    }
    

}


- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
