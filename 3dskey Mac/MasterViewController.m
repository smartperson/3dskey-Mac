//
//  MasterViewController.m
//  3dskey Mac
//
//  Created by Varun Mehta on 1/5/17.
//  Copyright (c) 2017 Varun Mehta. All rights reserved.
//

#import "MasterViewController.h"
#include <stdio.h>
#include <stdlib.h>
#include <string.h>

// \\Mac\Home\Desktop\test (Mac)\3dspad.h


char reportDescriptor[128] = {
    0x05, 0x01,                    // USAGE_PAGE (Generic Desktop)
    0x09, 0x04,                    // USAGE (Joystick)
    0xa1, 0x01,                    // COLLECTION (Application)
    0xa1, 0x00,                    //   COLLECTION (Physical)
    0x09, 0x01,                    //     USAGE (Pointer)
    0xa1, 0x00,                    //     COLLECTION (Physical)
    0x09, 0x91,                    //       USAGE (DPad Down)
    0x09, 0x90,                    //       USAGE (DPad Up)
    0x09, 0x93,                    //       USAGE (DPad Left)
    0x09, 0x92,                    //       USAGE (DPad Right)
//    0x35, 0x00,                    //       PHYSICAL_MINIMUM (0)
//    0x45, 0x01,                    //       PHYSICAL_MAXIMUM (1)
    0x15, 0x00,                    //       LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //       LOGICAL_MAXIMUM (1)
    0x75, 0x01,                    //       REPORT_SIZE (1)
    0x95, 0x04,                    //       REPORT_COUNT (4)
    0x81, 0x02,                    //       INPUT (Data,Var,Abs)
    0xc0,                          //     END_COLLECTION
    0x95, 0x01,                    //     REPORT_COUNT (1)
    0x75, 0x04,                    //     REPORT_SIZE (4)
    0x81, 0x03,                    //     INPUT (Cnst,Var,Abs)
    0x05, 0x01,                    //     USAGE_PAGE (Generic Desktop)
    0x09, 0x30,                    //     USAGE (X)
    0x09, 0x31,                    //     USAGE (Y)
    0x09, 0x32,                    //     USAGE (Z)
    0x09, 0x33,                    //     USAGE (Rx)
    0x15, 0x00,                    //     LOGICAL_MINIMUM (0)
    0x26, 0xff, 0x00,              //     LOGICAL_MAXIMUM (255)
    0x75, 0x08,                    //     REPORT_SIZE (8)
    0x95, 0x04,                    //     REPORT_COUNT (4)
    0x81, 0x02,                    //     INPUT (Data,Var,Abs)
    0x05, 0x05,                    //     USAGE_PAGE (Gaming Controls)
    0x09, 0x37,                    //     USAGE (Gamepad Fire/Jump)
    0xa1, 0x02,                    //     COLLECTION (Logical)
    0x05, 0x09,                    //       USAGE_PAGE (Button)
    0x19, 0x01,                    //       USAGE_MINIMUM (Button 1)
    0x29, 0x04,                    //       USAGE_MAXIMUM (Button 4) ABXY
    0x15, 0x00,                    //       LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //       LOGICAL_MAXIMUM (1)
    0x95, 0x04,                    //       REPORT_COUNT (4)
    0x75, 0x01,                    //       REPORT_SIZE (1)
    0x81, 0x02,                    //       INPUT (Data,Var,Abs)
    0xc0,                          //     END_COLLECTION
    0x05, 0x05,                    //     USAGE_PAGE (Gaming Controls)
    0x09, 0x39,                    //     USAGE (Gamepad Trigger)
    0xa1, 0x02,                    //     COLLECTION (Logical)
    0x05, 0x09,                    //       USAGE_PAGE (Button)
    0x19, 0x01,                    //       USAGE_MINIMUM (Button 1)
    0x29, 0x04,                    //       USAGE_MAXIMUM (Button 4) L R ZL ZR
    0x15, 0x00,                    //       LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //       LOGICAL_MAXIMUM (1)
    0x75, 0x01,                    //       REPORT_SIZE (1)
    0x95, 0x04,                    //       REPORT_COUNT (4)
    0x81, 0x02,                    //       INPUT (Data,Var,Abs)
    0xc0,                          //     END_COLLECTION
    0x05, 0x01,                    //     USAGE_PAGE (Generic Desktop)
    0x09, 0x3D,                    //     USAGE (Start)
    0x09, 0x3E,                    //     USAGE (Select)
    0x15, 0x00,                    //     LOGICAL_MINIMUM (0)
    0x25, 0x01,                    //     LOGICAL_MAXIMUM (1)
    0x75, 0x01,                    //     REPORT_SIZE (1)
    0x95, 0x02,                    //     REPORT_COUNT (2)
    0x81, 0x02,                    //     INPUT (Data,Var,Abs)
    0x95, 0x01,                    //     REPORT_COUNT (1)
    0x75, 0x06,                    //     REPORT_SIZE (6)
    0x81, 0x03,                    //     INPUT (Cnst,Var,Abs)
    0xc0,                          //   END_COLLECTION
    0xc0                           // END_COLLECTION
};

@interface MasterViewController ()

@end

@implementation MasterViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.connected = false;
    self.deviceAvailable = NO;
    self.buttonLabel = @"Connect";

    controllerConnection = [[VKM3DSNetworkModel alloc] init];
    [controllerConnection setDelegate:self];
    [controllerConnection listenForConnections];
    [labelField setStringValue:@"Listening for connections"];
}

-(IBAction)connectToggle:(id)sender {
    if (self.connected)
        [self disconnectFrom3DS];
    else
        [controllerConnection connectTo3DSAtHost:foundHost port:foundPort];
}

-(void) found3DSAtHost:(NSHost *)host port:(int)port {
    NSLog(@"Found 3DS at %@, port %d", host.address, port);
    self.deviceAvailable = YES;
    foundHost = host;
    foundPort = port;
    [labelField setStringValue:[NSString stringWithFormat:@"Found 3DS at %@, port %d", host.address, port]];
}
-(void) connectedTo3DSAtHost:(NSHost *)host port:(int)port {
    NSLog(@"Connected to 3DS at %@, port %d", host.address, port);
    // set up foohid device
    [self setUpHIDDevice];
    self.connected = YES;
    self.buttonLabel = @"Disconnect";
    [labelField setStringValue:[NSString stringWithFormat:@"Connected to %@", [host address]]];
}
-(void) disconnectFrom3DS {
    [controllerConnection disconnectFrom3DS];
}
-(void) receivedButtonData:(VKM3DSData *)buttonData {
    int ret;
    // Arguments to be passed through the HID message.
    uint32_t send_count = 4;
    uint64_t send[send_count];
    send[0] = (uint64_t)deviceName;  // device name
    send[1] = strlen(deviceName);  // name length
    send[2] = (uint64_t) buttonData;  // gamepad struct
    send[3] = sizeof(struct VKM3DSData_t);  // gamepad struct len
    
    ret = IOConnectCallScalarMethod(connect, FOOHID_SEND, send, send_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        NSLog(@"Unable to send message to HID device.\n");
    }
}

-(void)setUpHIDDevice {
    io_iterator_t iterator;
    io_service_t service;
    
    // Get a reference to the IOService
    kern_return_t ret = IOServiceGetMatchingServices(kIOMasterPortDefault, IOServiceMatching(SERVICE_NAME), &iterator);
    
    if (ret != KERN_SUCCESS) {
        NSLog(@"Unable to access IOService.\n");
        exit(1);
    }
    
    // Iterate till success
    int found = 0;
    while ((service = IOIteratorNext(iterator)) != IO_OBJECT_NULL) {
        ret = IOServiceOpen(service, mach_task_self(), 0, &connect);
        
        if (ret == KERN_SUCCESS) {
            found = 1;
            break;
        }
        
        IOObjectRelease(service);
    }
    IOObjectRelease(iterator);
    NSLog(@"Opened IOService");
    if (!found) {
        NSLog(@"Unable to open IOService.\n");
        return;
    }
    deviceName = strdup(DEVICE_NAME);
    deviceSerial = strdup(DEVICE_SN);
    // Fill up the input arguments.
    uint32_t input_count = 8;
    uint64_t input[input_count];
    input[0] = (uint64_t) deviceName;  // device name
    input[1] = strlen((char *)input[0]);  // name length
    input[2] = (uint64_t) reportDescriptor;  // report descriptor
    input[3] = sizeof(reportDescriptor);  // report descriptor len
    input[4] = (uint64_t) deviceSerial;  // serial number
    input[5] = strlen((char *)input[4]);  // serial number len
    input[6] = (uint64_t) 2;  // vendor ID
    input[7] = (uint64_t) 3;  // device ID
    
    ret = IOConnectCallScalarMethod(connect, FOOHID_CREATE, input, input_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        NSLog(@"Unable to create HID device. May be fine if created previously.\n");
    }
}

-(void)disconnectedFrom3DSAtHost:(NSHost *)host port:(int)port {
    NSLog(@"removing virtual device.");
    int ret;
    uint32_t destroy_count = 2;
    uint64_t destroy[destroy_count];
    destroy[0] = (uint64_t) strdup(DEVICE_NAME); //device name
    destroy[1] = strlen((char *)destroy[0]); //name length
    ret = IOConnectCallScalarMethod(connect, FOOHID_DESTROY, destroy, destroy_count, NULL, 0);
    if (ret != KERN_SUCCESS) {
        NSLog(@"Unable to destroy HID device. Does it still exist?\n");
    }
    free(deviceName);
    free(deviceSerial);
    
    [labelField setStringValue:@"Listening for connections…"];
    self.buttonLabel = @"Connect";
    self.connected = NO;
    self.deviceAvailable = NO;
    [controllerConnection listenForConnections];
}

-(void) viewWillDisappear {
    [self disconnectFrom3DS];
    [super viewWillDisappear];
}

@end
