// digital_mechanical_clock.scad
// terryspitz@gmail.com July 2019

$fn=12;

//unit = 5; // mm
//layer_height = 2; // mm

// components:
// pin_r, pin_l: pins on right and left
// bar_a, bar_b: horizontal bars carrying signal
// vctrl_l, vctrl_r: vertical sliders vctrlling pins
// push_a, push_b: horizontal sliders vctrlling bars
// frame_back, frame_front


vctrl_width = 7;
bar_a_width = 12;
bar_height = 3;

pin_z = 0;
vctrl_z = 1;
bar_z = 2;
hctrl_z = 3;

z_height_mm = 2; //mm
xy_mm_per_unit = 5;

module pin() {
    color("red") translate([0.5,0.5,0]) {
        translate([0,0,1]) cylinder(5, d=1);
        cylinder(d=2);
    }
}

module bar() {
    linear_extrude(height=1){
        difference() {
            polygon([[0,0],[0,3],[1,3], [2,2], [2,1], [3,1], [3,2], [4,3],
                    [bar_a_width,3], [bar_a_width,0],[bar_a_width-3,0]]);
            translate([bar_a_width-4,0]) square();
            translate([bar_a_width-2,0]) square();
        }
    }
}
module bar_a() {
    color("blue") {
        bar();
        linear_extrude(height=1)
            translate([bar_a_width,0]) square([6,1]);
    }
}
module bar_b() {
    color("#0000aa") 
    translate([bar_a_width,0,0]) mirror([1,0,0]) bar();
}

module vctrl() {
    linear_extrude(height=1)
    for(bar=[0:4]) {
        translate([0, bar*bar_height*2])
        difference() {
            square([7,bar_height*2]);
            translate([1,1]) square([5,1]);
            translate([1,3]) square([5,3]);
        }
    }
}
module vctrl_l() {
    color("yellow") vctrl();
}
module vctrl_r() {
    color("#FFFFAA") vctrl();
}
module hctrl_base() {
    linear_extrude(height=1) {
        difference() {
            square([8,2]);
            translate([1,0]) square([2,1]);
            translate([4,0]) square([3,1]);
        }
        translate([7,2]) square([1,4]);
        translate([0,2]) square([1,4]);
    }
}
module hctrl() {
    color("green") 
    for(bar=[0:4]) {
        translate([0, bar*bar_height*2])
        {
        translate([0,3]) hctrl_base();
        translate([7,0]) hctrl_base();
        }
    }
}

//bits are the logical positions of the bars
bits = [-1, 1, 1, -1, -1];
bits_pos = [for(b=bits) b>0 ? b : 0];
bits_neg = [for(b=bits) b<0 ? b : 0];

//turn $t in [0,1] into a step_time up to 8 steps and iterate through all the bits values
num_steps = 8;
time = $t * num_steps * len(bits);
bit_offset = floor(time/num_steps);
step_time = time % num_steps;
scaled_time = floor(step_time) + min((step_time%1)*2, 1.0);
echo("time: ", scaled_time);

function interp(vec) = let(x01=scaled_time%1) vec[min(scaled_time, len(vec)-1)] +
    (vec[min(scaled_time+1, len(vec)-1)]-vec[min(scaled_time, len(vec)-1)])*x01;

function get_bit(bits, offset) = bits[(offset-bit_offset+len(bits))%len(bits)];

scale([xy_mm_per_unit, xy_mm_per_unit, z_height_mm]) {
    translate([bar_a_width*1.2, 0, 0]) text(str(scaled_time), 5);
    for(bar=[1:len(bits)]) {
        // Position logic:
        // step 0: starting with bar_a ready to go
        // step 1: push_a right, moves bar_a and pins to +1
        // step 2: push_a left, moves bar_a and pins to -1
        // step 3: vctrl_r down, resets bar_b to 0, pin_r to 0/down
        // step 4: vctrl_l up, puts pin_l in bar_b +1/-1 slot
        // step 5-6: bar_b & pins right then left
        // step 7-8: vctrl_l down, vctrl_r up
        // everything should finish in start position!
        b0 = get_bit(bits,bar);
        b0p = get_bit(bits_pos,bar);
        b1 = get_bit(bits,bar+1);
        b1p = get_bit(bits_pos,bar+1);
        b2 = get_bit(bits,bar+2);
        b2p = get_bit(bits_pos,bar+2);
        //steps:   0   1       2     3   4   5       6     7,    8
        bar_a_x = [0,  b1p,    b1,   b1, b1, b1,     b1,   0];
        bar_b_x = [b0, b0,     b0,   0,  0,  b1p,    b1];
        pin_r_x = [b1, b1+b1p, b1*2, 0,  0,  b0p,    b0];
        pin_r_y = [2,  2,      2,    0,  0,  0,      0,    0,    2];
        pin_l_x = [0,  b1p,    b1,   b1, b1, b1+b1p, b1*2, 0];
        pin_l_y = [0,  0,      0,    0,  2,  2,      2,    0];

        translate([0,bar_height*(bar-1)*2,0]) {
            translate([interp(bar_a_x), 0, bar_z]) bar_a();
            translate([interp(bar_b_x), bar_height, bar_z]) bar_b();
            translate([interp(pin_r_x) + bar_a_width-3, interp(pin_r_y)-2, pin_z]) pin();
            translate([interp(pin_l_x) + 2, interp(pin_l_y) +1, pin_z]) pin();
        }
    } //for bar
    hctrl_x=[0,  1,      -1,   0,  0,  1,      -1,   0];
    vctrl_r_y = [2,  2,      2,    0,  0,  0,      0,    0,    2];
    vctrl_l_y = [0,  0,      0,    0,  2,  2,      2,    0];
    translate([-1, interp(vctrl_l_y), vctrl_z]) vctrl_l();
    translate([vctrl_width-1, interp(vctrl_r_y)-bar_height, vctrl_z]) vctrl_r();
    translate([interp(hctrl_x)-1, 0, hctrl_z]) hctrl();
}