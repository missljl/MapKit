//
//  ViewController.m
//  MapKit
//
//  Created by 1111 on 2017/8/15.
//  Copyright © 2017年 ljl. All rights reserved.
//

/*
 功能定位，大头针功能，导航功能
 室内导航等下实现
 
 室内定位导航是基于ibeacon开发的是的库CoreLocation
 BLE 在开发过程中使用CoreBluetooth库。
 
 2.百度地图 ：baidumap://
 3.高德地图 ：iosamap://
 4.谷歌地图 ：comgooglemaps://
 
 //检测是否安装了百度地图应用
 [UIApplication sharedApplication] canOpenURL:[NSURL URLWithString:@"baidumap://"]];
 
 ／／导航功能分为应用内导航，和应用外导航（就是根据url scheme的方式直接跳转到第三方地图应用中）
 */



#import "ViewController.h"
//地图框架
#import <MapKit/MapKit.h>
//定位，经纬度框架
#import <CoreLocation/CoreLocation.h>

@interface ViewController ()<CLLocationManagerDelegate,MKMapViewDelegate>
{
    UILabel *_longitudeLabel;//经度
    UILabel *_latitudeLabel;//纬度
    
    CLLocationManager *_locationM;//CLLocationManager 可以用来获取经纬度
    
    
    MKMapView *mpview;
    
    
    CGFloat longitude;
    CGFloat lattiude;
    
    
    
}
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
//    self.view.backgroundColor = [UIColor redColor];
    
    NSArray *nameArray=@[@"你的经度:",@"你的纬度:"];
    for (NSInteger i=0; i<nameArray.count; i++) {
        UILabel *label=[[UILabel alloc]initWithFrame:CGRectMake(10, 100+80*i, self.view.frame.size.width-20, 30)];
        label.text=nameArray[i];
        label.font=[UIFont systemFontOfSize:20];
        [self.view addSubview:label];
    }
    
    _longitudeLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 140, self.view.frame.size.width-20, 30)];
    _longitudeLabel.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_longitudeLabel];
    
    _latitudeLabel=[[UILabel alloc]initWithFrame:CGRectMake(10, 220, self.view.frame.size.width-20, 30)];
    _latitudeLabel.font=[UIFont systemFontOfSize:20];
    [self.view addSubview:_latitudeLabel];
    //定位方法
    [self position];
    
    
    //地图
    [self CofigMap];
    //添加打头阵
    [self cfigMkPointAnnation];
    
    
    
    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)CofigMap{
    
    //地图视图
    mpview = [[MKMapView alloc]initWithFrame:CGRectMake(0, 260, self.view.frame.size.width, self.view.frame.size.height-230)];
    //下面这句话是将定位显示到地图上的
    mpview.showsUserLocation = YES;
    mpview.delegate = self;
    
    //地图一加载就显示以定位的点为原点
    [mpview setRegion:MKCoordinateRegionMakeWithDistance(CLLocationCoordinate2DMake(31.232891, 121.435398), 5000,5000) animated:YES];
    
    
    
    [self.view addSubview:mpview];
    
    
    
    
}
-(void)cfigMkPointAnnation{
    
    //系统自带的不能更改样式
    MKPointAnnotation *annnotation1 = [[MKPointAnnotation alloc]init];
    [annnotation1 setCoordinate:CLLocationCoordinate2DMake(31.232899, 121.433593)];
    [annnotation1 setTitle:@"大胡子烧烤"];
    [annnotation1 setSubtitle:@"康定路385号"];
    [mpview addAnnotation:annnotation1];
    
    //
    //
    //    MKPointAnnotation *annnotation2 = [[MKPointAnnotation alloc]init];
    //    [annnotation2 setCoordinate:CLLocationCoordinate2DMake(31.242899, 121.443593)];
    //    [annnotation2 setTitle:@"小胡子烧烤"];
    //    [annnotation2 setSubtitle:@"康定路788号"];
    //    [mpview addAnnotation:annnotation2];
    //
    
    
}

#pragma mark 定位
-(void)position{
    _locationM=[[CLLocationManager  alloc]init];
    _locationM.delegate=self;
    _locationM.distanceFilter=1.0f;//设置过滤器的距离
    _locationM.desiredAccuracy=kCLLocationAccuracyBest;//设置精确度的
    //[UIDevice currentDevice] 获取当前的机器 拿到机器的系统版本
    if ([[[UIDevice currentDevice]systemVersion] floatValue]>=8.0) {
        [_locationM requestWhenInUseAuthorization];
    }
    [_locationM startUpdatingLocation];//开始定位的意思
}

//开始定位成功和位置发生变化的时候调用的方法
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations{
    //数组locations中最后一个元素就是最后更新的位置
    CLLocation *location=[locations lastObject];
    
    
    longitude=location.coordinate.longitude;
    lattiude =location.coordinate.latitude;
    // CLLocationCoordinate2D这个类定义的对象，是用来存经度和纬度
    //location.coordinate.latitude 拿到纬度
    _latitudeLabel.text=[NSString stringWithFormat:@"%f",location.coordinate.latitude];
    _longitudeLabel.text=[NSString stringWithFormat:@"%f",location.coordinate.longitude];
    
    //根据经纬度反向地理编译出地址信息
    //初始化
    CLGeocoder *geocoder=[[CLGeocoder alloc]init];
    [geocoder reverseGeocodeLocation:location completionHandler:^(NSArray *placemarks, NSError *error) {
        CLPlacemark *placeMark=placemarks[0];
        NSLog(@"省:%@ 市:%@ 街道:%@",placeMark.administrativeArea,placeMark.locality,placeMark.thoroughfare);
    }];
}
//-122.406417  37.785834
//定位失败的时候调用的方法
-(void)locationManager:(CLLocationManager *)manager didFailWithError:(NSError *)error{
    NSLog(@"%@",error);
}

////大头阵样式2可以点击详情
-(MKAnnotationView *)mapView:(MKMapView *)mapView viewForAnnotation:(id<MKAnnotation>)annotation{
    //判断是不是用户定位
    if ([annotation isKindOfClass:[MKUserLocation class]]) {
        return nil;
        
    }if ([annotation isKindOfClass:[MKPointAnnotation class]]) {
        
        MKPinAnnotationView *customPinView = (MKPinAnnotationView*)[mapView
                                                                    dequeueReusableAnnotationViewWithIdentifier:@"CustomPinAnnotationView"];
        
        if (!customPinView) {
            
            customPinView = [[MKPinAnnotationView alloc] initWithAnnotation:annotation
                                                            reuseIdentifier:@"CustomPinAnnotationView"];
            
        }
        
        customPinView.pinTintColor = [UIColor blueColor];
        customPinView.animatesDrop = YES;
        customPinView.canShowCallout = YES;
        
        UIButton *rightButton = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 80, 50)];
        rightButton.backgroundColor = [UIColor grayColor];
        [rightButton setTitle:@"查看详情" forState:UIControlStateNormal];
        customPinView.rightCalloutAccessoryView = rightButton;
        
        
        UIImageView *myCustomImage = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"myimage"]];
        customPinView.leftCalloutAccessoryView = myCustomImage;
        return customPinView;
        
        
        
    }
    
    
    return nil;
    
    
    
}


//点击详情的时候调用
-(void)mapView:(MKMapView *)mapView annotationView:(MKAnnotationView *)view calloutAccessoryControlTapped:(UIControl *)control{
    
    
    NSLog(@"开启导航");
    
    
    
    UIAlertController *alertdialog = [UIAlertController alertControllerWithTitle:@"规划路线" message:@"导航选择" preferredStyle:UIAlertControllerStyleActionSheet];
    
    
    
    UIAlertAction *laterAction = [UIAlertAction actionWithTitle:@"系统地图导航" style:UIAlertActionStyleDefault handler:^(UIAlertAction *action) {
        
        // 普通按键
        [self Reactmap];
        
        
    }];
  
    UIAlertAction *neverAction = [UIAlertAction actionWithTitle:@"高德地图导航" style:UIAlertActionStyleDestructive handler:^(UIAlertAction *action) {
        
        // 红色按键
        
        NSLog(@"跳转高德地图");
        
    }];
    
    [alertdialog addAction:laterAction];
    
    
    [alertdialog addAction:neverAction];
    
    // 呈现警告视图
    
    [self presentViewController:alertdialog animated:YES completion:nil];
    

    
    
    
    
    
    
    
    
    
}
-(void)Reactmap{

    //目的
    CLLocationCoordinate2D coords2 = CLLocationCoordinate2DMake(31.232899,121.433593);
    
    
    //目的地的位置
    
    MKMapItem *toLocation = [[MKMapItem alloc] initWithPlacemark:[[MKPlacemark alloc] initWithCoordinate:coords2 addressDictionary:nil]];
    
    
    toLocation.name = @"大胡子烧烤";
    
    
    NSArray *items = [NSArray arrayWithObjects:toLocation, nil];
    
    
    NSDictionary *options = @{ MKLaunchOptionsDirectionsModeKey:MKLaunchOptionsDirectionsModeDriving, MKLaunchOptionsMapTypeKey: [NSNumber numberWithInteger:MKMapTypeStandard], MKLaunchOptionsShowsTrafficKey:@YES };
    //打开苹果自身地图应用，并呈现特定的item
    
    
    [MKMapItem openMapsWithItems:items launchOptions:options];

}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
