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
    var pingInterval:NSTimer!;
    let dataKey = NSUUID().UUIDString;
    
    init(){
             socket.delegate = self;


    }
    
    @objc func pingIntervalCallback(){
        socket.writeString("{\"name\":\"ping\"}")
    }
    
    func connect(){
        socket.connect()
    }
    
    
    // MARK: Websocket Delegate Methods.
    
    func websocketDidConnect(ws: WebSocket) {
        print("websocket is connected")
        //send name of client
        pingInterval = NSTimer.scheduledTimerWithTimeInterval(15, target: self, selector: #selector(SocketManager.pingIntervalCallback), userInfo: nil, repeats: true)
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
        print("text = \(text)");
         if(text == "init_data_received" || text == "message received"){
            objc_sync_enter(dataQueue)

            if(dataQueue.count>0){
                
                socket.writeString(dataQueue.removeAtIndex(0));
            }
            else{
                
                transmitComplete = true;
            }
            objc_sync_exit(dataQueue);
        }
        else if(text == "fabricator connected"){
          // self.sendFabricationConfigData();
        }
        else{
            
            print("json data")
            if let dataFromString = text.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: false) {
                let json = JSON(data: dataFromString)
                let type = json["type"].stringValue;
                print("type=\(type)");
                if(type == "fabricator_data"){
                    print("raising fabricator data")
                    socketEvent.raise(("fabricator_data",json))
                }
                else if(type == "data_request"){
                    print("data request")
                    socketEvent.raise(("data_request",json))
                }
                else if (type == "authoring_request"){
                    print("authoring request")
                    socketEvent.raise(("authoring_request",json))

                }
                
            }
        }
    }
    
    func websocketDidReceiveData(ws: WebSocket, data: NSData) {
    }
    
    
    // MARK: Disconnect Action
    
    func disconnect() {
        if socket.isConnected {
            
            socket.disconnect()
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
        self.initAction(data.0, type: data.1)
    }
    
    func dataGenerated(data:(String), key:String){
        if(transmitComplete){
            transmitComplete = false;
            socket.writeString(data)
            
        }
        else{
            objc_sync_enter(dataQueue)
            dataQueue.append(data)
            objc_sync_exit(dataQueue)
        }
    }
    
    
    func sendBehaviorData(data:(String)){
        let string = "{\"type\":\"behavior_data\",\"data\":"+data+"}"
        if(transmitComplete){
            transmitComplete = false;
            socket.writeString(string)
            
        }
        else{
            
            objc_sync_enter(dataQueue)
            dataQueue.append(string)
            objc_sync_exit(dataQueue)

        }
    }
    
    func sendData(data:String){
        
        if(transmitComplete){
            transmitComplete = false;
            socket.writeString(data)
            
        }
        else{
            
            objc_sync_enter(dataQueue)
            dataQueue.append(data)
            objc_sync_exit(dataQueue)
            
        }
    }


    
    
    
    
}
