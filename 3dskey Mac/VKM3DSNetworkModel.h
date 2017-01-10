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
    Byte dpad; //down up left right, 4 bits padding
    Byte xAxis;
    Byte yAxis;
    Byte cxAxis;
    Byte cyAxis;
    Byte buttons[2]; //A B X Y L R ZL ZR Start Select , 6 bits padding
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
    USB_A = 0x1,
    USB_B = 0x2,
    USB_X = 0x4,
    USB_Y = 0x8,
    USB_L = 0x10,
    USB_R = 0x20,
    USB_ZL = 0x40,
    USB_ZR = 0x80,
    USB_SEL = 0x1,
    USB_START = 0x2
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
