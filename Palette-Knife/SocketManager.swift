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
     var socket = WebSocket(url: NSURL(string: "ws://pure-beach-75578.herokuapp.com/")!, protocols: ["drawing"])
    //var socket = WebSocket(url: NSURL(string: "ws://localhost:5000")!, protocols: ["ipad_client"])
    var socketEvent = Event<(String,JSON?)>();
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
        socket.writeString("{\"name\":\"drawing\"}")
        if(firstConnection){
            socketEvent.raise(("first_connection",nil));
        }
        else{
            socketEvent.raise(("connected",nil));
        }
    }
    
    func websocketDidDisconnect(ws: WebSocket, error: NSError?) {
        if let e = error {
            print("websocket is disconnected: \(e.localizedDescription)")
        } else {
            print("websocket disconnected")
            
        }
        socketEvent.raise(("disconnected",nil));
        
    }
    
    func websocketDidReceiveMessage(ws: WebSocket, text: String) {
         if(text == "init_data_recieved" || text == "message recieved"){
            if(dataQueue.count>0){
                
                socket.writeString(dataQueue.removeAtIndex(0));
            }
            else{
                print("all messages sent \(text)")
                
                transmitComplete = true;
            }
        }
        else if(text == "fabricator connected"){
          // self.sendFabricationConfigData();
        }
        else{
            // print("message = \(text)")
            if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let json = JSON(data: dataFromString)
                print("json=\(json)")
                socketEvent.raise(("fabricator_data",json))
                
            }
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
    
    
    func sendFabricationConfigData(){
        var source_string = "[\"VR, .2, .1, .4, 10, .1, .4, .4, 10, 1, .200, 100, .150, 65, 0, 0, .200, .250 \",";
        source_string += "\"SW, 2, , \","
        source_string += "\"FS, C:/Users/ShopBot/Desktop/Debug/\""
        source_string+="]"
        var   data = "{\"type\":\"gcode\","
        data += "\"data\":"+source_string+"}"
        socket.writeString(data)

    }
    
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
        
        target.initEvent.addHandler(self,handler: SocketManager.initEvent, key:dataKey);
        
        self.dataGenerated(data,key:"_");
        if(type == "brush_init"){
            let b = target as! Brush
            b.setupTransition();
        }
        
    }
    
    func initEvent(data:(WebTransmitter,String), key:String){
        print("init event raised for \(data.0.name)");
        self.initAction(data.0, type: data.1)
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
            print("sending data \(data)")
            socket.writeString(string)
            
        }
        else{
            print("appending data")
            
            
            dataQueue.append(string)
        }
    }
    
    
    
    
}
