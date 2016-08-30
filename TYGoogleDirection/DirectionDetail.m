//
//  DirectionDetail.m
//  GoogleDirection
//
//  Created by Thabresh on 8/30/16.
//  Copyright © 2016 VividInfotech. All rights reserved.
//

#import "DirectionDetail.h"

@interface DirectionDetail ()<UITextFieldDelegate,TYPlaceSearchViewControllerDelegate,UITableViewDelegate,UITableViewDataSource>
{
    NSString *fromClicked;
    NSMutableArray *addArray;
    NSDictionary *dictRouteInfo;
}
@property (weak, nonatomic) IBOutlet UITableView *directionTbl;
@property (weak, nonatomic) IBOutlet UITextField *source;
@property (weak, nonatomic) IBOutlet UITextField *destination;
@end
@interface UITextView(HTML)
- (void)setContentToHTMLString:(id)fp8;
@end
@implementation DirectionDetail

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.directionTbl setHidden:YES];
    addArray = [NSMutableArray arrayWithObjects:@"0",@"1", nil];
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
- (IBAction)clickFind:(id)sender {
    if ([self CheckValidation]) {
        [self.directionTbl setHidden:YES];
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
        if ([arrRouts isKindOfClass:[NSArray class]]&&arrRouts.count==0) {
            [self ShowAlert:@"didn't find direction"];
            return;
        }
        NSArray *arrDistance =[[[json valueForKeyPath:@"routes.legs.steps.distance.text"] objectAtIndex:0]objectAtIndex:0];
        NSString *totalDuration = [[[json valueForKeyPath:@"routes.legs.duration.text"] objectAtIndex:0]objectAtIndex:0];
        NSString *totalDistance = [[[json valueForKeyPath:@"routes.legs.distance.text"] objectAtIndex:0]objectAtIndex:0];
        NSArray *arrDescription =[[[json valueForKeyPath:@"routes.legs.steps.html_instructions"] objectAtIndex:0] objectAtIndex:0];
        dictRouteInfo=[NSDictionary dictionaryWithObjectsAndKeys:totalDistance,@"totalDistance",totalDuration,@"totalDuration",arrDistance ,@"distance",arrDescription,@"description", nil];
        [self.directionTbl setHidden:NO];
        self.directionTbl.delegate=self;
        self.directionTbl.dataSource=self;
        [self.directionTbl reloadData];
    }else{
        [self ShowAlert:@"didn't find direction"];
    }
}
#pragma mark - table view data source and delegate
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 100;
}
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 2;
}
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    if (section==0) {
        return 1;
    }else
    {
        if (dictRouteInfo) {
            return [[dictRouteInfo objectForKey:@"distance"] count];
        }
        return 0;
    }    
}
- (NSString *)tableView:(UITableView *)tableView titleForHeaderInSection:(NSInteger)section {
    if (section == 0) {
        return NSLocalizedString(@"Driving directions Summary", nil);
    } else
        return NSLocalizedString(@"Driving directions Detail", nil);
    
}
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString *strCellIdentifier1=@"cellIdentifire1";
    static NSString *strCellIdentifier2=@"cellIdentifire2";
    
    UITableViewCell *cell =nil;
    if (indexPath.section==0) {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier1];
    }
    else if(indexPath.section==1)
    {
        cell = [tableView dequeueReusableCellWithIdentifier:strCellIdentifier2];
    }
    if (cell==nil) {
        if (indexPath.section==0) {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier1];
        }
        else
        {
            cell=[[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:strCellIdentifier2];
        }
        cell.selectionStyle=UITableViewCellSelectionStyleNone;
        if (indexPath.section==0&&indexPath.row==0) {
            UILabel *lblSrcDest = [[UILabel alloc]init];
            lblSrcDest.tag=100000;
            
            lblSrcDest.backgroundColor=[UIColor clearColor];
            lblSrcDest.font=[UIFont fontWithName:@"helvetica" size:15];
            lblSrcDest.lineBreakMode=NSLineBreakByWordWrapping;
            
            lblSrcDest.frame=CGRectMake(20, 2, 290, 100);
            lblSrcDest.numberOfLines=5;
            
            [cell addSubview:lblSrcDest];
            
        }
        else if(indexPath.section==1)
        {
            UILabel *lblDistance = [[UILabel alloc]initWithFrame:CGRectMake(30, 2, 260, 20)];
            lblDistance.backgroundColor=[UIColor clearColor];
            [cell addSubview:lblDistance];
            lblDistance.tag=1;
            UITextView *textView = [[UITextView alloc] initWithFrame:CGRectMake(20.0f, 30.0f, 280.0f, 56.0f)];
            textView.editable = NO;
            textView.scrollEnabled = NO;
            textView.opaque = YES;
            textView.backgroundColor = [UIColor clearColor];
            textView.tag = 2;
            [cell addSubview:textView];
        }
    }
    if (indexPath.section==0&&indexPath.row==0) {
        UILabel *lblSrcDest=(UILabel*)[cell viewWithTag:100000];
        if (![addArray containsObject:@"0"]) {
            TYGooglePlace *myPlace = [addArray objectAtIndex:0];
            TYGooglePlace *myPlace1 = [addArray objectAtIndex:1];
            
            lblSrcDest.text=[NSString stringWithFormat:@"Driving directions from %@ to %@  \ntotal Distace = %@ \ntotal Duration = %@",myPlace.name,myPlace1.name,[dictRouteInfo objectForKey:@"totalDistance"],[dictRouteInfo objectForKey:@"totalDuration"]];
        }
        
    }
    else if(indexPath.section==1){
        if (![addArray containsObject:@"0"]) {
            UILabel *lblDist = (UILabel *)[cell viewWithTag:1];
            lblDist.text=[[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row];
            UITextView *textView = (UITextView *)[cell viewWithTag:2];
            [textView setContentToHTMLString:[[dictRouteInfo objectForKey:@"description"]objectAtIndex:indexPath.row]];
        }
        //        NSLog(@"index row==%i ,%@ , %@",indexPath.row,lblDist.text , [[dictRouteInfo objectForKey:@"distance"]objectAtIndex:indexPath.row]);
        
    }
    
    return cell;
}
-(BOOL)CheckValidation
{
    if(self.source.text.length==0){
        [self ShowAlert:@"Please Enter Source Address"];
        return FALSE;
    }else if (self.destination.text.length==0) {
        [self ShowAlert:@"Please Enter Destination Address"];
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
#pragma mark - ABCGooglePlacesSearchViewControllerDelegate Methods

-(void)searchViewController:(TYPlaceSearchViewController *)controller didReturnPlace:(TYGooglePlace *)place {
    if ([fromClicked isEqualToString:@"0"]) {
        [addArray replaceObjectAtIndex:0 withObject:place];
        self.source.text = place.formatted_address;
    }else  {
        [addArray replaceObjectAtIndex:1 withObject:place];
        self.destination.text = place.formatted_address;
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
