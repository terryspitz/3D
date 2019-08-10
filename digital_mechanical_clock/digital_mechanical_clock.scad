// digital_mechanical_clock.scad
// terryspitz@gmail.com July 2019

$fn=12;

//unit = 5; // mm
//layer_height = 2; // mm

// components:
// pin_r, pin_l: pins on right and left
// bar_a, bar_b: horizontal bars carrying signal
// control_l, control_r: vertical sliders controlling pins
// push_a, push_b: horizontal sliders controlling bars
// frame_back, frame_front


module pin() {
    color("red") translate([0.5,0.5,0]) {
        translate([0,0,1]) cylinder(2, d=1);
        cylinder(d=2);
    }
}

bar_a_width = 8;
bar_a_height = 3;

module bar_a() {
    color("blue") 
        //difference() {
            //cube([bar_a_width,bar_a_height,1]);
            linear_extrude(height=1)
                difference() {
                    polygon([[0,0],[0,3],[1,3], [2,2], [2,1], [3,1], [3,2], [4,3],
                            [bar_a_width,3], [bar_a_width,0],[bar_a_width-3,0]]);
                    translate([bar_a_width-4,0]) square();
                    translate([bar_a_width-2,0]) square();
                }
            //translate([6,0,0]) cube();
        //}
}
module bar_b() {
    color("#0000aa") 
    translate([bar_a_width,0,0]) mirror([1,0,0]) bar_a();
}

time = $t*12;
echo(time);
signals = [-1,1,-1,1,-1];
for(bar=[1:3]) {
    ramps = [for(i=[0:6]) time<i*2 ? 0 : time<i*2+1 ? (time-i*2) : 1];
    // Position logic:
    // step 1
    //    push_a(); //moves bar_a and pins to -/+1
    // step 2
    //    control_r_down(); //resets bar_b to 0, pin_r down/centre
    // step 3
    //    control_l_up(); //pin_l to bar_b +1/-1 slot
    // step 4
    //    push_b();
    // step visa-versa
    bar_a_x = ramps[1] * signals[bar];
    pin_r_x = ramps[1] * signals[bar] + bar_a_width-4;
    pin_r_y = 2;
    pin_l_x = ramps[1] * signals[bar] + 2;
    pin_l_y = 1;
    bar_b_x = signals[bar-1];
    control_l_pos = ramps[0];
    control_r_pos = ramps[1];

    translate([0,bar_a_height*(bar-1)*2,0]) {
        translate([bar_a_x, 0, 0]) bar_a();
        translate([bar_b_x,bar_a_height,0]) bar_b();
        translate([pin_r_x,pin_r_y-2,-1]) pin();
        translate([pin_l_x,pin_l_y,-1]) pin();
    }
}