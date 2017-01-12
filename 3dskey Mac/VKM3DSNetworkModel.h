//
//  VKM3DSNetworkModel.h
//  3dskey Mac
//
//  Created by Varun Mehta on 1/5/17.
//  Copyright (c) 2017 Varun Mehta. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <CocoaAsyncSocket/GCDAsyncUdpSocket.h>
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

#define LISTEN_PORT 19050

typedef struct VKM3DSData_t {
    UInt16 buttons;
//    Byte dpadStartSelect; //up down left right start select
//    Byte buttons; // LB/ZL RB/ZR -- -- A B X Y
//    Byte lTrigger; //0 or 255
//    Byte rTrigger; //0 or 255
    uint16_t lTrigger; //0 or 255
    uint16_t rTrigger; //0 or 255
    uint16_t xAxis;
    uint16_t yAxis;
    uint16_t cxAxis;
    uint16_t cyAxis;
    Byte padding6Bytes[6];
} VKM3DSData;

typedef enum : NSUInteger {
    BTN_A = 0x1,
    BTN_B = 0x2,
    BTN_SEL = 0x4,
    BTN_START = 0x8,
    BTN_DRIGHT = 0x10,
    BTN_DLEFT = 0x20,
    BTN_DUP = 0x40,
    BTN_DDOWN = 0x80,
    BTN_R = 0x100,
    BTN_L = 0x200,
    BTN_X = 0x400,
    BTN_Y = 0x800,
    BTN_ZL = 0x4000,
    BTN_ZR = 0x8000,
    BTN_CRIGHT = 0x1000000,
    BTN_CLEFT = 0x2000000,
    BTN_CUP = 0x4000000,
    BTN_CDOWN = 0x8000000
} Network3DSButtons;

typedef enum : NSUInteger {
    USB_DRIGHT = 1 << 3,//2,//0x8,
    USB_DLEFT = 1 << 1,
    USB_DUP = 1 << 15, //0x1
    USB_DDOWN = 1 << 0, //0x2
    USB_START = 1 << 6,
    USB_SEL = 1 << 14,
    USB_L = 1 << 0,
    USB_R = 1 << 0,
    USB_A = 1 << 4, //buttons
    USB_B = 1 << 8, //buttons
    USB_X = 1 << 10,
    USB_Y = 1 << 12,
    USB_ZL = 1 << 5,
    USB_ZR = 1 << 9,
} USB3DSButtons;

@protocol VKM3DSDelegate <NSObject>
-(void) found3DSAtHost:(NSHost *)host port:(int)port;
-(void) connectedTo3DSAtHost:(NSHost *)host port:(int)port;
-(void) receivedButtonData:(VKM3DSData *)buttonData;
-(void) disconnectedFrom3DSAtHost:(NSHost *)host port:(int)port;
@end

@interface VKM3DSNetworkModel : NSObject <GCDAsyncUdpSocketDelegate, GCDAsyncSocketDelegate> {
    NSHost *consolehost;
    int consolePort;
    
    GCDAsyncSocket *tcpSocket;
    GCDAsyncUdpSocket *udpSocket;
}
@property (weak,nonatomic) id delegate;
-(Boolean) listenForConnections;
-(Boolean) connectTo3DSAtHost:(NSHost *)host port:(int)port;
-(void) disconnectFrom3DS;
//- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port;
//- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag;


@end
