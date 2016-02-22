/*Blockly.JavaScript['line'] = function(block) {
  var statements_page_header = Blockly.JavaScript.statementToCode(block, 'page_header');
  var value_color = Blockly.JavaScript.valueToCode(block, 'page_color', Blockly.JavaScript.ORDER_ATOMIC);
  var value_background = Blockly.JavaScript.valueToCode(block, 'page_background', Blockly.JavaScript.ORDER_ATOMIC);
  var value_paragraph = Blockly.JavaScript.valueToCode(block, 'page_paragraph', Blockly.JavaScript.ORDER_ATOMIC);

  var code = 'document.body.style.color = "' + value_color + '";\n';
  code +=    'document.body.style.backgroundColor = "' + value_background + '";\n';
  code +=    'document.getElementById("description").innerHTML = "' + value_paragraph + '";\n';
  code +=    statements_page_header;
  return code;
};*/

var penX = 10
var penY = 10
var penForce = 1

function callNativeApp () {
    try {
         var aMessage = {'command':'hello', data:[5,6,7,8,9]}
          //window.webkit.messageHandlers.callbackHandlerpostMessage(aMessage);
        //webkit.messageHandlers.callbackHandler.postMessage(aMessage);
      var messageToPost = {'ButtonId':'clickMeButton'};
      window.webkit.messageHandlers.callbackHandler.postMessage(aMessage,false);
      // webkit.messageHandlers.callbackHandler.postMessage(String(penX));
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}


function addLine(x,y,diameter){
  console.log('drawing line at ',x,y,diameter)
}

function setPenData(pX,pY,pF){
  penX = pX;
  penY = pY;
  penForce = pF;
  code = window.Blockly.JavaScript.workspaceToCode();
  console.log('code',code);
  eval(code);
  callNativeApp()
}


Blockly.JavaScript['line'] = function(block) {
  var value_x = Blockly.JavaScript.valueToCode(block, 'x', Blockly.JavaScript.ORDER_ATOMIC);
  var value_y = Blockly.JavaScript.valueToCode(block, 'y', Blockly.JavaScript.ORDER_ATOMIC);
  var value_diameter = Blockly.JavaScript.valueToCode(block, 'diameter', Blockly.JavaScript.ORDER_ATOMIC);
  var colour_line_color = block.getFieldValue('line_color');

  // TODO: Assemble JavaScript into code variable.
  var code = 'addLine('+value_x+','+value_y+','+value_diameter+')';
  return code;
};

Blockly.JavaScript['pen_x'] = function(block) {
  var pen_x = penX;
  return [pen_x, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['pen_y'] = function(block) {
  var pen_y = penY;
  return [pen_y, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['pen_force'] = function(block) {
  var force = penForce;
  return [force, Blockly.JavaScript.ORDER_NONE];
};
