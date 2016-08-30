//
//  LocationCapture.m
//  GoogleDirection
//
//  Created by Thabresh on 8/30/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "LocationCapture.h"

@interface LocationCapture ()<UITextFieldDelegate,TYPlaceSearchViewControllerDelegate>
@property (weak, nonatomic) IBOutlet UITextField *txtLocation;
@property (weak, nonatomic) IBOutlet UIImageView *locationImg;

@end

@implementation LocationCapture

- (void)viewDidLoad {
    [super viewDidLoad];
    self.title = @"Location Capture";
    self.navigationItem.leftBarButtonItem = [[UIBarButtonItem alloc] initWithImage:BACK_LOGO style:UIBarButtonItemStylePlain target:self action:@selector(backButtonAction:)];
    // Do any additional setup after loading the view.
}
-(void) backButtonAction:(id)sender {
    GO_BACK
}
-(void)textFieldDidBeginEditing:(UITextField *)textField
{
    [textField resignFirstResponder];
    TYPlaceSearchViewController *searchViewController = [[TYPlaceSearchViewController alloc] init];
    [searchViewController setDelegate:self];
    UINavigationController *navigationController = [[UINavigationController alloc] initWithRootViewController:searchViewController];
    [self presentViewController:navigationController animated:YES completion:nil];

}
#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place {
    self.txtLocation.text = place.formatted_address;
    self.navigationItem.prompt =place.formatted_address;
    NSString *staticMapUrl = [NSString stringWithFormat:@"http://maps.google.com/maps/api/staticmap?markers=color:red|%f,%f&sensor=true&zoom=10&size=%dx%d",place.location.coordinate.latitude, place.location.coordinate.longitude,(int)self.locationImg.frame.size.width,(int)self.locationImg.frame.size.height];
    NSURL *mapUrl = [NSURL URLWithString:[staticMapUrl stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding]];
    
    NSURLSessionTask *task = [[NSURLSession sharedSession] dataTaskWithURL:mapUrl completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (data) {
            UIImage *image = [UIImage imageWithData:data];
            if (image) {
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.locationImg.image = image;
                });
            }else{
                [self ShowAlert:@"Not Available"];
            }
        }else{
            [self ShowAlert:@"Not Available"];
        }
    }];
    [task resume];
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
