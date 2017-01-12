//
//  VKM3DSNetworkModel.m
//  3dskey Mac
//
//  Created by Varun Mehta on 1/5/17.
//  Copyright (c) 2017 Varun Mehta. All rights reserved.
//

#import "VKM3DSNetworkModel.h"

@implementation VKM3DSNetworkModel

-(Boolean) listenForConnections {
    NSError *error = nil;
    if (!udpSocket) {
        udpSocket = [[GCDAsyncUdpSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
        [udpSocket bindToPort:LISTEN_PORT error:&error];
    }
    else {
        [udpSocket beginReceiving:&error];
    }
    if (error)
        NSLog(@"Error on bind");
    [udpSocket beginReceiving:&error];
    if (error)
        NSLog(@"Error on start receiving");
    return true;
}

- (void)udpSocket:(GCDAsyncUdpSocket *)sock didReceiveData:(NSData *)data fromAddress:(NSData *)address withFilterContext:(id)filterContext {
    NSString *msg = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];
//    NSLog(@"Received message %@ from %@", msg, address);
    if ([self checkUDPMessage:msg fromAddress:address]) { //if it's a 3DS, let's stop this UDP business
        [sock pauseReceiving];
        NSHost *host = [NSHost hostWithAddress:[GCDAsyncSocket hostFromAddress:address]];
        int port = sock.localPort;
        [self.delegate found3DSAtHost:host port:port];
    }
//    else {
//        NSError *error;
//        [sock receiveOnce:&error];
//    }
}

/**
 * Called when the socket is closed.
 * A socket is only closed if you explicitly call one of the close methods.
 **/
- (void)udpSocketDidClose:(GCDAsyncUdpSocket *)sock withError:(NSError *)error; {
    NSLog(@"UDP Disconnected with error %@", error);
    //[delegate disconnectedFrom3DSAtHost:host port:port];
}

-(Boolean) checkUDPMessage:(NSString *)message fromAddress:(NSData *)address {
    NSLog(@"checking UDP message %@ from %@", message, address);
    if ([message compare:@"ANNOUNCE:3dskey"] != NSOrderedSame) {
        NSLog(@"Not a 3DS. Not adding %@. Recommending trying again.", address);
        return NO;
    }
    return YES;
}

- (Boolean)connectTo3DSAtHost:(NSHost *)host port:(int)port {
    if (tcpSocket.isConnected)
        return NO;
    tcpSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];
    NSError *error = nil;
//    NSString *host = [GCDAsyncSocket hostFromAddress:address];
//    NSString *hostString = [host address];
    NSString *hostString = @"192.168.1.46";
    [tcpSocket connectToHost:hostString onPort:LISTEN_PORT error:&error];
    if (error) {
        NSLog(@"Error connecting");
        return NO;
    }
    NSLog(@"Called connect, host %@, port %d", host, LISTEN_PORT);
    return YES;
}

-(void) disconnectFrom3DS {
    [tcpSocket disconnectAfterReading];
}

- (void)socket:(GCDAsyncSocket *)sender didConnectToHost:(NSString *)host port:(UInt16)port {
    NSLog(@"Connected to 3DS");
    [self.delegate connectedTo3DSAtHost:[NSHost hostWithAddress:host] port:port];
    [sender readDataToLength:24 withTimeout:-1 tag:0];
}

- (void)socket:(GCDAsyncSocket *)sender didReadData:(NSData *)data withTag:(long)tag {
//    NSLog(@"Reading in the following:");
//    NSLog(@"%@", [data description]);
    unsigned int magic, pressedKeys, heldKeys, upKeys;
    signed int circleX, circleY;
    magic = CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(0, 4)] bytes]);
    pressedKeys =CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(4, 4)] bytes]);
    heldKeys = CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(8, 4)] bytes]);
    upKeys = CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(12, 4)] bytes]);
    circleX = CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(16, 4)] bytes]);
    circleY = CFSwapInt32LittleToHost(*(int*)[[data subdataWithRange:NSMakeRange(20, 4)] bytes]);
    VKM3DSData buttonData = {0};
//    buttonData.buttons = 0; buttonData.dpadStartSelect = 0; buttonData.lTrigger = 0; buttonData.rTrigger = 0;
    if (heldKeys & BTN_DDOWN) buttonData.buttons |= USB_DDOWN;
    if (heldKeys & BTN_DUP) buttonData.buttons |= USB_DUP;
    if (heldKeys & BTN_DLEFT) buttonData.buttons |= USB_DLEFT;
    if (heldKeys & BTN_DRIGHT) buttonData.buttons |= USB_DRIGHT;
    if (heldKeys & BTN_SEL) buttonData.buttons |= USB_SEL;
    if (heldKeys & BTN_START) buttonData.buttons |= USB_START;
//    if (heldKeys & BTN_L) buttonData.buttons |= USB_L;
//    if (heldKeys & BTN_R) buttonData.buttons |= USB_R;
//    buttonData.dpadStartSelect = (heldKeys & 0xF0) >> 4;
    //face & trigger game buttons!
    if (heldKeys & BTN_A) buttonData.buttons |= USB_A;
    if (heldKeys & BTN_B) buttonData.buttons |= USB_B;
    if (heldKeys & BTN_X) buttonData.buttons |= USB_X;
    if (heldKeys & BTN_Y) buttonData.buttons |= USB_Y;
    if (heldKeys & BTN_ZL) buttonData.buttons |= USB_ZL;
    if (heldKeys & BTN_ZR) buttonData.buttons |= USB_ZR;
    buttonData.lTrigger = 127;
    buttonData.rTrigger = 127;
    if (heldKeys & BTN_L) buttonData.lTrigger = 0xFFFF;
    if (heldKeys & BTN_R) buttonData.rTrigger = 0xFFFF;
//    if (heldKeys & BTN_ZL) buttonData.buttons[0] |= USB_ZL;
//    if (heldKeys & BTN_ZR) buttonData.buttons[0] |= USB_ZR;
    
    buttonData.xAxis = (abs(circleX) > 20 ? MIN(127, MAX(-127, circleX)) + 127 : 127) * (UINT16_MAX/0xff);
    buttonData.yAxis = (abs(circleY) > 20 ? MIN(127, MAX(-127, -circleY))+ 127 : 127) * (UINT16_MAX/0xff);
    buttonData.cxAxis = UINT16_MAX/2;
    buttonData.cyAxis = UINT16_MAX/2;
    if (heldKeys & BTN_CDOWN) buttonData.cyAxis = UINT16_MAX;
    if (heldKeys & BTN_CUP) buttonData.cyAxis = 0;
    if (heldKeys & BTN_CRIGHT) buttonData.cxAxis = UINT16_MAX;
    if (heldKeys & BTN_CLEFT) buttonData.cxAxis = 0;
    
//    NSLog(@"0x%x", buttonData.buttons);
//    NSLog(@"Magic: 0x%X", magic);
//    NSLog(@"Keys Down: 0x%X", pressedKeys);
//    NSLog(@"Keys Held: 0x%X", heldKeys);
//    NSLog(@"Keys Up: 0x%X", upKeys);
//    NSLog(@"Circle X: %d", circleX);
//    get the next set of controller data
    [self.delegate receivedButtonData:&buttonData];
    [sender readDataToLength:24 withTimeout:-1 tag:0];
}

-(void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err {
    NSHost *host = [NSHost hostWithAddress:sock.connectedHost];
    int port = sock.connectedPort;
    [self.delegate disconnectedFrom3DSAtHost:host port:port];
}

@end
