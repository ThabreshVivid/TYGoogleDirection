//
//  MultiLocationPicker.m
//  GoogleDirection
//
//  Created by Thabresh on 8/30/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "MultiLocationPicker.h"

@interface MultiLocationPicker ()<UITextFieldDelegate,TYPlaceSearchViewControllerDelegate>
{
    NSString *fromClicked;
    NSMutableArray *addArray;
}
@property (weak, nonatomic) IBOutlet GMSMapView *GMMap;
@property (weak, nonatomic) IBOutlet UITextField *locationOne;
@property (weak, nonatomic) IBOutlet UITextField *locationTwo;
@property (weak, nonatomic) IBOutlet UITextField *locationThree;
@end

@implementation MultiLocationPicker

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.GMMap setHidden:YES];
    addArray = [NSMutableArray arrayWithObjects:@"0",@"1",@"2",nil];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:BACK_LOGO style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    // Do any additional setup after loading the view.
}
-(void) backButtonAction:(id)sender {
    GO_BACK
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    fromClicked = [NSString stringWithFormat:@"%ld",(long)textField.tag];
    [textField resignFirstResponder];
    TYPlaceSearchViewController *searchViewController = [[TYPlaceSearchViewController alloc] init];
    [searchViewController setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}
#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place {
    if ([fromClicked isEqualToString:@"0"]) {
        [addArray replaceObjectAtIndex:0 withObject:place];
        self.locationOne.text = place.formatted_address;
    }else if ([fromClicked isEqualToString:@"1"]) {
        [addArray replaceObjectAtIndex:1 withObject:place];
        self.locationTwo.text = place.formatted_address;
    }else{
        [addArray replaceObjectAtIndex:2 withObject:place];
        self.locationThree.text = place.formatted_address;
    }    
}
-(BOOL)textFieldShouldReturn:(UITextField *)textField
{
    [textField resignFirstResponder];
    return YES;
}
-(void)touchesBegan:(NSSet<UITouch *> *)touches withEvent:(UIEvent *)event
{
    [self.view endEditing:YES];
}
-(IBAction)Find:(id)sender{
    if ([self CheckValidation]) {
        [self.GMMap clear];
        NSString *strUrl;
        strUrl= [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true&waypoints=%@",self.locationOne.text,self.locationThree.text,self.locationTwo.text];
        strUrl=[strUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
        NSData *data =[NSData dataWithContentsOfURL:[NSURL URLWithString:strUrl]];
        NSError* error;
        if (data) {
            NSDictionary* json = [NSJSONSerialization
                                  JSONObjectWithData:data //1
                                  options:kNilOptions
                                  error:&error];
            NSArray *arrRouts=[json objectForKey:@"routes"];
            
            GMSPolyline *polyline = nil;
            if ([arrRouts count] > 0)
            {
                [self.GMMap setHidden:NO];
                NSDictionary *routeDict = [arrRouts objectAtIndex:0];
                NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
                NSString *points = [routeOverviewPolyline objectForKey:@"points"];
                
                GMSPath *path = [GMSPath pathFromEncodedPath:points];
                polyline = [GMSPolyline polylineWithPath:path];
                polyline.strokeWidth = 2.f;
                polyline.strokeColor =  UA_rgba(0,122,255);
                polyline.map = self.GMMap;
                
                GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
                GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
                [self.GMMap moveCamera:update];
                
                for (int i = 0; i <=2; i++) {
                    TYGooglePlace *myPlace =[addArray objectAtIndex:i];
                    CLLocationCoordinate2D location =[myPlace.location coordinate];
                    GMSMarker *marker = [GMSMarker markerWithPosition:location];
                    marker.title = myPlace.name;
                    marker.icon = [UIImage imageNamed:@"mark"];
                    marker.map = self.GMMap;
                }
            }else{
                [self ShowAlert:@"didn't find direction"];
            }
        }else{        
            [self ShowAlert:@"didn't find direction"];
        }
    }
}
-(BOOL)CheckValidation
{
    if(self.locationOne.text.length==0 || self.locationTwo.text.length==0 || self.locationThree.text.length==0 ){
        [self ShowAlert:@"Please enter required fields"];
        return FALSE;
    }
    return TRUE;
}
-(void)ShowAlert:(NSString*)AlertMessage
{
    UIAlertController *alert = [UIAlertController alertControllerWithTitle:AlertMessage message:nil preferredStyle:UIAlertControllerStyleAlert];
    UIAlertAction* yesButton = [UIAlertAction
                                actionWithTitle:@"Okay"
                                style:UIAlertActionStyleDefault
                                handler:^(UIAlertAction * action) {
                                    //Handle your yes please button action here
                                }];
    [alert addAction:yesButton];
    [self presentViewController:alert animated:YES completion:nil];
    // [[[UIAlertView alloc]initWithTitle:AlertMessage message:nil delegate:self cancelButtonTitle:@"OK" otherButtonTitles:nil]show];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
