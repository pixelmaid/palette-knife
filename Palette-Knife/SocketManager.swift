//
//  SocketManager.swift
//  PaletteKnife
//
//  Created by JENNIFER MARY JACOBS on 6/27/16.
//  Copyright © 2016 pixelmaid. All rights reserved.
//

import Foundation
import Starscream

//central manager for all requests to web socket
class SocketManager: WebSocketDelegate{
    var socket = WebSocket(url: NSURL(string: "ws://10.8.0.205:8080/")!, protocols: ["ipad_client"])
    var socketEvent = Event<(String)>();
    var firstConnection = true;
    var targets = [WebTransmitter](); //objects which can send or recieve data
    var startTime:NSDate?
    var dataQueue = [String]();
    var transmitComplete = true;
    
     init(){
        socket.delegate = self;
    }
    
    func connect(){
        socket.connect()
    }
    
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
        //send name of client
        socket.writeString("ipad")
        if(firstConnection){
            socketEvent.raise(("first_connection"));
        }
        else{
            socketEvent.raise("connected");
        }
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")

        }
        socketEvent.raise("disconnected");

    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {

        if(dataQueue.count>0){
           // print("websocket revieved message, sending next of \(dataQueue.count)")

            socket.writeString(dataQueue.removeAtIndex(0));
        }
        else{
            print("all messages sent")

            transmitComplete = true;
        }
        //print("ifconfig text: \(text)")
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
        print("Received data: \(data.length)")
    }
    
    
    // MARK: Disconnect Action
    
    func disconnect() {
        if socket.isConnected {
            
            socket.disconnect()
        } else {
            socket.connect()
        }
    }
    
    
    // MARK: Write Text Action
    
    /*func sendStylusData(pressure:Float,position:Point,angle:Float,delta:Point,penDown:Bool) {
        let end = NSDate();
        let timeInterval = end.timeIntervalSinceDate(startTime!);
        var string = "{"
        string+="\"time\":"+String(timeInterval)+","
        string+="\"pressure\":"+String(pressure)+","
        string+="\"angle\":"+String(angle)+","
        string+="\"penDown\":"+String(penDown)+","
        string+="\"position\":{\"x\":"+String(position.x)+",\"y\":"+String(position.y)+"},"
        string+="\"delta\":{\"x\":"+String(delta.x)+",\"y\":"+String(delta.y)+"}"
        string+="}"
        print("message: \(string)")
        dataQueue.append(string)
    }*/
    
    func initAction(target:WebTransmitter){
        let data = "{\"type\":\"new_canvas\",\"canvas_id\":\""+target.id+"\",\"canvas_name\":\""+target.name+"\"}";
        targets.append(target);
        target.event.addHandler(self,handler: SocketManager.drawingDataGenerated);
        drawingDataGenerated(data);

        
    }
    
    func drawingDataGenerated(data:(String)){
        print("drawing data generated \(data)")
        if(transmitComplete){
            transmitComplete = false;
            socket.writeString(data)
            
        }
        else{
            dataQueue.append(data)
        }
    }
    
    

    
}
