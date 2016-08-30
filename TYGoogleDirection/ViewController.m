//
//  ViewController.m
//  GoogleDirection
//
//  Created by Thabresh on 8/30/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "ViewController.h"
@interface ViewController ()<MKMapViewDelegate,CLLocationManagerDelegate>
@property (weak, nonatomic) IBOutlet GMSMapView *GMMap;
@property(nonatomic, retain) CLLocationManager *locationManager;
@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:BACK_LOGO style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    
    self.GMMap.settings.compassButton = YES;
    self.GMMap.settings.myLocationButton = YES;
    self.locationManager = [[CLLocationManager alloc] init];
    self.locationManager.delegate = self;
#ifdef __IPHONE_8_0
    if(IS_OS_8_OR_LATER) {
        // Use one or the other, not both. Depending on what you put in info.plist
        [self.locationManager requestWhenInUseAuthorization];
        [self.locationManager requestAlwaysAuthorization];
    }
#endif
    [self.locationManager startUpdatingLocation];    
    // Do any additional setup after loading the view, typically from a nib.
}
-(void)viewWillDisappear:(BOOL)animated
{
    [self.locationManager stopUpdatingLocation];
}
-(void) backButtonAction:(id)sender {
    GO_BACK
}
- (void)locationManager:(CLLocationManager *)manager
     didUpdateLocations:(NSArray *)locations {
    // If it's a relatively recent event, turn off updates to save power.
    CLLocation* location = [locations lastObject];
    NSDate* eventDate = location.timestamp;
    NSTimeInterval howRecent = [eventDate timeIntervalSinceNow];
    if (fabs(howRecent) < 15.0) {
        GMSMarker *marker = [[GMSMarker alloc] init];
        marker.position = CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude);
        marker.title = @"Current Location";
        marker.icon = [UIImage imageNamed:@"mark"];
        marker.map = self.GMMap;
        [self.GMMap animateToLocation:CLLocationCoordinate2DMake(location.coordinate.latitude, location.coordinate.longitude)];
        [self.GMMap animateToZoom:17];
    }
}
- (IBAction)clickSeg:(UISegmentedControl *)sender {
    switch (sender.selectedSegmentIndex) {
        case 0:
            self.GMMap.mapType = kGMSTypeNormal;
            break;
        case 1:
            self.GMMap.mapType = kGMSTypeSatellite;
            break;
        case 2:
            self.GMMap.mapType = kGMSTypeHybrid;
            break;
        case 3:
            self.GMMap.mapType = kGMSTypeTerrain;
            break;
        case 4:
            self.GMMap.mapType = kGMSTypeNone;
            break;
        default:
            break;
    }
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
