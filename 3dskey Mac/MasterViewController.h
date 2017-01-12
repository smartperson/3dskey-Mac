//
//  MasterViewController.h
//  3dskey Mac
//
//  Created by Varun Mehta on 1/5/17.
//  Copyright (c) 2017 Varun Mehta. All rights reserved.
//

#import <Cocoa/Cocoa.h>
#include <IOKit/IOKitLib.h>

#import "VKM3DSNetworkModel.h"

#define SERVICE_NAME "it_unbit_foohid"

#define FOOHID_CREATE 0  // create selector
#define FOOHID_DESTROY 1  // create selector
#define FOOHID_SEND 2  // send selector

#define DEVICE_NAME "© Microsoft Controller"
#define DEVICE_SN "3DS"

@interface MasterViewController : NSViewController <VKM3DSDelegate>{
    io_connect_t connect;
    char *deviceName;
    char *deviceSerial;
    VKM3DSNetworkModel *controllerConnection;
    
    IBOutlet id labelField;
    NSHost *foundHost; int foundPort;
}
@property Boolean connected;
@property Boolean deviceAvailable;
@property NSString *buttonLabel;
-(void) found3DSAtHost:(NSHost *)host port:(int)port;
-(void) connectedTo3DSAtHost:(NSHost *)host port:(int)port;
-(void) receivedButtonData:(VKM3DSData *)buttonData;
-(IBAction)connectToggle:(id)sender;
@end
