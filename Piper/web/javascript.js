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

var penX = null
var penY = null
var lastPenX = 10
var lastPenY = 10
var penForce = 1
var lines = []
function callNativeApp () {
  console.log("lines=",lines);
    try {
         var aMessage = {data:lines}
        window.webkit.messageHandlers.callbackHandler.postMessage(aMessage,false);
    } catch(err) {
        console.log('The native context does not exist yet');
    }
}


function addLine(x1,y1,x2,y2,diameter){
  console.log('drawing line at ',x1,y1,x2,y2,diameter)
  lines.push({"x1":x1,"y1":y1,"x2":x2,"y2":y2,"diameter":diameter})
}

function setPenData(pX,pY,pF){
  lines = [];
  if(penX){
  lastPenX = penX
  lastPenY = penY
  }
  else{
   lastPenX = pX
  lastPenY = pY 
  }
  penX = pX;
  penY = pY;
 
  penForce = pF;
  code = window.Blockly.JavaScript.workspaceToCode();
  console.log('code',code);
  eval(code);
  callNativeApp()
}


Blockly.JavaScript['line'] = function(block) {
  var value_x1 = Blockly.JavaScript.valueToCode(block, 'x1', Blockly.JavaScript.ORDER_ATOMIC);
  var value_y1 = Blockly.JavaScript.valueToCode(block, 'y1', Blockly.JavaScript.ORDER_ATOMIC);
  var value_x2 = Blockly.JavaScript.valueToCode(block, 'x2', Blockly.JavaScript.ORDER_ATOMIC);
  var value_y2 = Blockly.JavaScript.valueToCode(block, 'y2', Blockly.JavaScript.ORDER_ATOMIC);
  var value_diameter = Blockly.JavaScript.valueToCode(block, 'diameter', Blockly.JavaScript.ORDER_ATOMIC);
  var colour_line_color = block.getFieldValue('line_color');

  // TODO: Assemble JavaScript into code variable.
  var code = 'addLine('+value_x1+','+value_y1+','+value_x2+','+value_y2+','+value_diameter+')';
  return code;
};

Blockly.JavaScript['pen_x'] = function(block) {
  var pen_x = penX;
  return [pen_x, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['last_pen_x'] = function(block) {
  var lpen_x = lastPenX;
  return [lpen_x, Blockly.JavaScript.ORDER_NONE];
};
/*Blockly.JavaScript['pen_x'] = function(block) {
  var text_value = block.getFieldValue('value');
  // TODO: Assemble JavaScript into code variable.
  var code = '...';
  // TODO: Change ORDER_NONE to the correct strength.
  return [code, Blockly.JavaScript.ORDER_NONE];
};*/

Blockly.JavaScript['pen_y'] = function(block) {
  var pen_y = penY;
  return [pen_y, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['last_pen_y'] = function(block) {
  var lpen_y = lastPenY;
  return [lpen_y, Blockly.JavaScript.ORDER_NONE];
};


Blockly.JavaScript['pen_force'] = function(block) {
  var force = penForce;
  return [force, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['one_block'] = function(block) {
  return [1, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['two_block'] = function(block) {
  return [2, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['five_block'] = function(block) {
  return [5, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['ten_block'] = function(block) {
  return [10, Blockly.JavaScript.ORDER_NONE];
};

Blockly.JavaScript['twenty_block'] = function(block) {
  return [20, Blockly.JavaScript.ORDER_NONE];
};


Blockly.JavaScript['random'] = function(block) {
  var value_from = Blockly.JavaScript.valueToCode(block, 'from', Blockly.JavaScript.ORDER_ATOMIC);
  var value_to = Blockly.JavaScript.valueToCode(block, 'to', Blockly.JavaScript.ORDER_ATOMIC);
  // TODO: Assemble JavaScript into code variable.
  var code = Math.random() * value_to + value_from 
  // TODO: Change ORDER_NONE to the correct strength.
  return [code, Blockly.JavaScript.ORDER_NONE];
};

