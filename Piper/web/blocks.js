
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
    this.appendValueInput("x")
        .setCheck("Number")
        .appendField("x");
    this.appendValueInput("y")
        .setCheck("Number")
        .appendField("y");
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

