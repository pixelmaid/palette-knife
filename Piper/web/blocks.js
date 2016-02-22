
Blockly.Blocks['pen_x'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("pen x");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};


Blockly.Blocks['pen_y'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("pen y");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};


Blockly.Blocks['one_block'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("1");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['ten_block'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("10");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['twenty_block'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("5");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['five_block'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("5");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['two_block'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("2");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};


Blockly.Blocks['last_pen_x'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("last pen x");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};


Blockly.Blocks['last_pen_y'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("last pen y");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['pen_force'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("force");
    this.setOutput(true, "Number");
    this.setColour(260);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }
};

Blockly.Blocks['line'] = {
  init: function() {
    this.appendDummyInput()
        .appendField("line");
    this.appendValueInput("x1")
        .setCheck("Number")
        .appendField("x1");
    this.appendValueInput("y1")
        .setCheck("Number")
        .appendField("y1");
         this.appendValueInput("x2")
        .setCheck("Number")
        .appendField("x2");
    this.appendValueInput("y2")
        .setCheck("Number")
        .appendField("y2");
    this.appendValueInput("diameter")
        .setCheck("Number")
        .appendField("diameter");
    this.appendDummyInput()
        .appendField("color")
        .appendField(new Blockly.FieldColour("#ff9900"), "line_color");
    this.setInputsInline(false);
    this.setPreviousStatement(true);
    this.setNextStatement(true);
    this.setColour(210);
    this.setTooltip('');
    this.setHelpUrl('http://www.example.com/');
  }

};

