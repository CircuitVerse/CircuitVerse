var k = KeyCode;
function simple_key(code) { return k.hot_key({ code: code }); };
function test_lower_a() { assertEquals('A', simple_key(k.key('a'))); };
function test_upper_a() { assertEquals('A', simple_key(k.key('A'))); };
function test_z() { assertEquals('Z', simple_key(k.key('z'))); };
function test_f1() { assertEquals('F1', simple_key(k.fkey(1))); };
function test_f12() { assertEquals('F12', simple_key(k.fkey(12))); };
function test_num0() { assertEquals('Num0', simple_key(k.numkey(0))); };
function test_num9() { assertEquals('Num9', simple_key(k.numkey(9))); };
function test_shift() { 
    assertEquals('Shift+X', k.hot_key({ code: k.key('x'), shift: true })); 
};
function test_ctrl_shift() {
    assertEquals('Ctrl+Shift+F12', k.hot_key({ code: k.fkey(12), 
                shift: true, ctrl: true }));
};
