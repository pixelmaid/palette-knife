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
    //var socket = WebSocket(url: NSURL(string: "ws://pure-beach-75578.herokuapp.com/")!, protocols: ["ipad_client"])
    var socket = WebSocket(url: NSURL(string: "ws://localhost:5000")!, protocols: ["ipad_client"])
    var socketEvent = Event<(String)>();
    var firstConnection = true;
    var targets = [WebTransmitter](); //objects which can send or recieve data
    var startTime:NSDate?
    var dataQueue = [String]();
    var transmitComplete = true;
    let dataKey = NSUUID().UUIDString;

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
        socket.writeString("{\"name\":\"ipad\"}")
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

            socket.writeString(dataQueue.removeAtIndex(0));
        }
        else{
            print("all messages sent \(text)")

            transmitComplete = true;
        }
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
    
    func sendStylusData() {
        var string = "{\"type\":\"stylus_data\",\"canvas_id\":\""+stylus.id;
        string += "\",\"stylusData\":{"
        string+="\"time\":"+String(stylus.getTimeElapsed())+","
        string+="\"pressure\":"+String(stylus.force)+","
        string+="\"angle\":"+String(stylus.angle)+","
        string+="\"penDown\":"+String(stylus.penDown)+","
        string+="\"speed\":"+String(stylus.speed)+","
        string+="\"position\":{\"x\":"+String(stylus.position.x)+",\"y\":"+String(stylus.position.y)+"}"
       // string+="\"delta\":{\"x\":"+String(delta.x)+",\"y\":"+String(delta.y)+"}"
        string+="}}"
        dataGenerated(string,key:"_")
    }
    
    func initAction(target:WebTransmitter, type:String){
        let data = "{\"type\":\""+type+"\",\"id\":\""+target.id+"\",\"name\":\""+target.name+"\"}";
        targets.append(target);
        target.transmitEvent.addHandler(self,handler: SocketManager.dataGenerated, key:dataKey);
        self.dataGenerated(data,key:"_");

        
    }
    
    func dataGenerated(data:(String), key:String){
        print("data generated \(data)")
        if(transmitComplete){
            transmitComplete = false;
            socket.writeString(data)
            
        }
        else{
            dataQueue.append(data)
        }
    }
    
    func sendBehaviorData(data:(String)){
        let string = "{\"type\":\"behavior_data\",\"data\":"+data+"}"
        if(transmitComplete){
            transmitComplete = false;
            print("sending data")
            socket.writeString(string)
            
        }
        else{
            print("appending data")

            
            dataQueue.append(string)
        }
    }
    
    

    
}
