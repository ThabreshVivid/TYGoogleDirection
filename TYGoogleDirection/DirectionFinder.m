//
//  DirectionFinder.m
//  GoogleDirection
//
//  Created by Thabresh on 8/30/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "DirectionFinder.h"

@interface DirectionFinder ()<UITextFieldDelegate,TYPlaceSearchViewControllerDelegate>
{
    BOOL fromClicked;
    NSDictionary *dictRouteInfo;
    NSMutableArray *addArray;
}
@property (weak, nonatomic) IBOutlet GMSMapView *GMSMap;

@end

@implementation DirectionFinder

- (void)viewDidLoad {
    [super viewDidLoad];
    self.navigationItem.title = @"Find Direction";
    addArray = [NSMutableArray arrayWithObjects:@"0",@"1", nil];
    [self.GMSMap setHidden:YES];
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:BACK_LOGO style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    // Do any additional setup after loading the view.
}
-(void) backButtonAction:(id)sender {
    GO_BACK
}
- (IBAction)clickGO:(id)sender {
    if ([self CheckValidation]) {
        [_GMSMap clear];
        TYGooglePlace *myPlace = [addArray objectAtIndex:0];
        TYGooglePlace *myPlace1 = [addArray objectAtIndex:1];
        [self LoadMapRoute:myPlace.name andDestinationAddress:myPlace1.name];
    }
}
-(void)LoadMapRoute:(NSString*)SourceAddress andDestinationAddress:(NSString*)DestinationAdds
{
    NSString *strUrl;
    strUrl= [NSString stringWithFormat:@"http://maps.googleapis.com/maps/api/directions/json?origin=%@&destination=%@&sensor=true",SourceAddress,DestinationAdds];
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
            [self.GMSMap setHidden:NO];
            NSDictionary *routeDict = [arrRouts objectAtIndex:0];
            NSDictionary *routeOverviewPolyline = [routeDict objectForKey:@"overview_polyline"];
            NSString *points = [routeOverviewPolyline objectForKey:@"points"];
            GMSPath *path = [GMSPath pathFromEncodedPath:points];
            polyline = [GMSPolyline polylineWithPath:path];
            polyline.strokeWidth = 2.f;
            polyline.strokeColor =  UA_rgba(0,122,255);
            polyline.map = self.GMSMap;
            
            GMSCoordinateBounds *bounds = [[GMSCoordinateBounds alloc] initWithPath:path];
            GMSCameraUpdate *update = [GMSCameraUpdate fitBounds:bounds];
            [self.GMSMap moveCamera:update];
            
            for (int i = 0; i < 2; i++) {
                TYGooglePlace *myPlace =[addArray objectAtIndex:i];
                CLLocationCoordinate2D location =[myPlace.location coordinate];
                GMSMarker *marker = [GMSMarker markerWithPosition:location];
                marker.title = myPlace.name;
                marker.icon = [UIImage imageNamed:@"mark"];
                marker.map = self.GMSMap;
            }            
        }
           }else{
     
        [self ShowAlert:@"didn't find direction"];
    }
}
-(BOOL)CheckValidation
{
    if(self.txtFrom.text.length==0 && self.txtTo.text.length==0){
        [self ShowAlert:@"Please Enter Source & Destination address"];
        return FALSE;
    }else if (self.txtFrom.text.length==0) {
        [self ShowAlert:@"Please Enter Source address"];
        return FALSE;
    }else if(self.txtTo.text.length==0){
        [self ShowAlert:@"Please Enter Destination address"];
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
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    if (textField.tag==0) {
        fromClicked = YES;
    }else{
        fromClicked = NO;
    }
    [textField resignFirstResponder];
    TYPlaceSearchViewController *searchViewController = [[TYPlaceSearchViewController alloc] init];
    [searchViewController setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];
}

#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place {
    if (fromClicked) {
        [addArray replaceObjectAtIndex:0 withObject:place];
        self.txtFrom.text = place.formatted_address;
        self.navigationItem.prompt =[NSString stringWithFormat:@"From : %f , %f",place.location.coordinate.latitude, place.location.coordinate.longitude];
    }else{
        [addArray replaceObjectAtIndex:1 withObject:place];
        self.txtTo.text = place.formatted_address;
        self.navigationItem.title =[NSString stringWithFormat:@"To : %f , %f",place.location.coordinate.latitude, place.location.coordinate.longitude];
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
