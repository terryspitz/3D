// digital_mechanical_clock.scad
// terryspitz@gmail.com July 2019

$fn=12;

part = "top";
echo("part", part);

// components:
// pin_r, pin_l: pins on right and left
// bar_a, bar_b: horizontal bars carrying signal
// vctrl_l, vctrl_r: vertical sliders vctrlling pins
// push_a, push_b: horizontal sliders vctrlling bars
// frame_back, frame_front


vctrl_width = 7;
bar_width = 12;
bar_height = 3;

base_z = 0;
pin_z = 1;
bar_z = 2;
hctrl_z = 3;
vctrl_z = 4;
vcntr_z = 5;
top_z = 6;

z_height_mm = 1.5; //mm
xy_mm_per_unit = 3;

module pin() {
    color("red") translate([0.5,0.5,0]) {
        translate([0,0,1]) cylinder(5, d=1);
        cylinder(d=2.8);
    }
}
module bar() {
    linear_extrude(height=1){
        difference() {
            polygon([[-3,0],[-3,3],[1,3], [2,2], [2,1], [3,1], [3,2], [4,3],
                    [8,3], [8,2],[bar_width+3,2], [bar_width+3,0],[bar_width-3,0]]);
            translate([bar_width-4,0]) square();
            translate([bar_width-2,0]) square();
        }
    }
}
module bar_a() {
    color("blue") {
        bar();
        linear_extrude(height=1)
            translate([bar_width,0]) square([8,1]);
        translate([bar_width+7.5,0.5,1]) cylinder(2, d=1);
    }
}
module bar_b() {
    color("darkblue")
    translate([bar_width,0,0]) mirror([1,0,0]) bar();
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
    //darkyellow
    color("#FFFFAA") vctrl();
}
module vcntr() {
    linear_extrude(height=1)
    for(bar=[0:4]) {
        translate([0, bar*bar_height*2])
        union() {
            square([1,bar_height*2]);
            polygon([[0,0],[0,3],[1,3], [3,1], [4,1], [6,3], [7,3], [7,0]]);
            translate([6,0]) square([1,bar_height*2]);
        }
    }
}
module vcntr_l() {
    color("orange") vcntr();
}
module vcntr_r() {
    color("darkorange") vcntr();
}
module hctrl_base(left, bottom=false, top=false) {
    linear_extrude(height=1) {
        translate([0,1]) square([8,1]);
        if(!bottom) {
            translate([3,0]) square([1,1]);
        }
        if(!top) {
            translate([0,3]) square([8,1]);
            translate([7,3]) square([1,5]);
            translate([0,3]) square([1,5]);
        }
        if(left)
            translate([5,2]) square([2,1]);
        else
            translate([1,2]) square([2,1]);
    }
}
module hctrl() {
    color("green") 
    for(bar=[0:4]) {
        translate([0, bar*bar_height*2]) {
            translate([0,3]) hctrl_base(left=true, top=bar==4);
            translate([7,0]) hctrl_base(left=false, bottom=bar==0, top=bar==4);
        }
    }
}
module pixel() {
    color("white")
    difference() {
        union() {
            difference() {
                cylinder(r=3, h=1);
                translate([0, 0, -1]) cube([bar_height, bar_height, 3]);
                translate([-bar_height, -bar_height, -1]) cube([bar_height, bar_height, 3]);
                cylinder(r=bar_height, h=1);
            }
            cylinder(r=2.5, h=1);
        }
        translate([0, 1, -1]) cylinder(d=2.5, h=3);
    }
}
module base() {
    color("darkgrey") translate([-2, -1, base_z]) {
        linear_extrude(height=1) {
            square([vctrl_width*2+2,bar_height*11]);
        }
        translate([0, 0, 1]) {
            linear_extrude(height=1) {
                square([1,bar_height*11]);
                translate([vctrl_width*2+1,0]) square([1,bar_height*11]);
            }
            linear_extrude(height=3) {
                for(bar=[0:4]) {
                    translate([0, bar*bar_height*2]) square([4,1]);
                    translate([vctrl_width*2-2, bar*bar_height*2+3]) square([4,1]);
                }
            }
        }
        translate([0, 0, 3])
        linear_extrude(height=4) {
            for(bar=[0:4]) {
                translate([0, bar*bar_height*2]) square([1,1]);
                //translate([2, bar*bar_height*2]) square([1,1]);
                //translate([vctrl_width*2-1, bar*bar_height*2+3]) square([1,1]);
                translate([vctrl_width*2+1, bar*bar_height*2+3]) square([1,1]);
            }
        }
    }
}
module top() {
    color("grey") {
        translate([0, 0, top_z]) {
            translate([-1, -2, 0]) vcntr_l();
            difference() {
                translate([vctrl_width-1, -5, 0]) vcntr_r();
                //remove protruding bottom
                translate([vctrl_width-1, -7, -1]) cube([vctrl_width,5,3]);
            }
            linear_extrude(height=1) {
                for(bar=[0:4]) {
                    translate([-2, bar*bar_height*2]) square([1,bar_height*2-1]);
                    translate([vctrl_width*2-1, bar*bar_height*2-3]) square([1,bar_height*2-1]);
                }
            }
            
        }
    }
}

//bits are the logical positions of the bars
bits = [1, 1, -1, -1, -1];
bits_pos = [for(b=bits) b>0 ? b : 0];
bits_neg = [for(b=bits) b<0 ? b : 0];

//turn $t in [0,1] into a step_time up to 8 steps and iterate through all the bits values
num_steps = 8;
time = $t * num_steps * len(bits);
bit_offset = floor(time/num_steps);
step_time = time % num_steps;
//spend half of each timestep stationary
scaled_time = floor(step_time) + min((step_time%1)*2, 0.99);
echo("time: ", bit_offset, scaled_time);

function interp(vec) =  let(x=scaled_time%1,
                            y0=vec[min(scaled_time, len(vec)-1)],
                            y1=vec[min(scaled_time+1, len(vec)-1)])
                        y0 + (y1-y0)*x;

function get_bit(bits, offset) = bits[(offset-bit_offset+len(bits)) % len(bits)];

scale([xy_mm_per_unit, xy_mm_per_unit, z_height_mm]) {
    if($preview) 
        translate([bar_width*2, 8, 5])
            linear_extrude(height=1) text(str(scaled_time), 5);
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
        b_1 = get_bit(bits,bar-1);
        b0 = get_bit(bits,bar);
        b0p = get_bit(bits_pos,bar);
        b1 = get_bit(bits,bar+1);
        b1p = get_bit(bits_pos,bar+1);
        //steps:   0   1       2     3   4   5       6     7,    8
        bar_a_x = [0,  b0p,    b0,   b0, b0, b0,     b0,   0];
        bar_b_x = [b1, b1,     b1,   0,  0,  b0p,    b0];
        pin_r_x = [b1, b1+b1p, b1*2, 0,  0,  b0p,    b0,   b0,   b0];
        pin_r_y = [6,  6,      6,    4,  4,  4,      4,    4,    6];
        pin_l_x = [0,  b0p,    b0,   b0, b0, b0+b0p, b0*2, 0];
        pin_l_y = [0,  0,      0,    0,  2,  2,      2,    0];
        pixel_rot=[b_1, b0p,    b0,   b0, b0, b0,     b0,   b0];

        translate([0,bar_height*(bar-1)*2,0]) {
            if(part=="all" || part=="bar_a" && bar==1)
                translate([interp(bar_a_x), 0, bar_z]) bar_a();
            if(part=="all" || part=="bar_b" && bar==1)
                translate([interp(bar_b_x), bar_height, bar_z]) bar_b();
            if(part=="all" && bar<len(bits)|| part=="pin" && bar==1)
                translate([interp(pin_r_x) + bar_width-3, interp(pin_r_y), pin_z]) pin();
            if(part=="all")
                translate([interp(pin_l_x) + 2, interp(pin_l_y) +1, pin_z]) pin();
            if(part=="all" || part=="pixel" && bar==1)
                translate([vctrl_width*2+5.5, 0.5, bar_z+1.5]) rotate([0, 0, interp(pixel_rot)*-45]) pixel();
        }
    } //for bar
    //steps:     0   1       2     3   4   5       6     7,    8
    hctrl_x=    [0,  1,      -1,   0,  0,  1,      -1,   0];
    vctrl_l_y = [0,  0,      0,    0,  2,  2,      2,    0];
    vctrl_r_y = [2,  2,      2,    0,  0,  0,      0,    0,    2];
    vcntr_l_y = [0,  0,      0,    0,  0,  0,      0,    2,    0];
    vcntr_r_y = [0,  0,      0,    2,  0,  0,      0,    0];
    translate([0, 0, vctrl_z]) {
        if(part=="all" || part=="vctrl" || part=="vctrl_l")
            translate([-1, interp(vctrl_l_y), 0]) vctrl_l();
        if(part=="all" || part=="vctrl" || part=="vctrl_r")
            translate([vctrl_width-1, interp(vctrl_r_y)-bar_height, 0]) vctrl_r();
    }
    if(part=="all" || part=="hctrl")
        translate([interp(hctrl_x)-1, 0, hctrl_z]) hctrl();
    translate([0, 0, vcntr_z]) {
        if(part=="all" || part=="vcntr_l")
            translate([-1, interp(vcntr_l_y)-2, 0]) vcntr_l();
        if(part=="all" || part=="vcntr_r")
            translate([vctrl_width-1, interp(vcntr_r_y)-2+bar_height, 0]) vcntr_r();
    }
    if(part=="all" || part=="base")
        base();
    if(part=="all" || part=="top")
        top();
}
