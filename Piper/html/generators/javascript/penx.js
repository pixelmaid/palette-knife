'use strict';

goog.provide('Blockly.JavaScript.math');

goog.require('Blockly.JavaScript');

Blockly.JavaScript['penx'] = function(block) {
    var variable_penx = Blockly.JavaScript.variableDB_.getName(block.getFieldValue('penX'), Blockly.Variables.NAME_TYPE);
    // TODO: Assemble JavaScript into code variable.
    var code = '...';
    // TODO: Change ORDER_NONE to the correct strength.
    return [code, Blockly.JavaScript.ORDER_NONE];
};