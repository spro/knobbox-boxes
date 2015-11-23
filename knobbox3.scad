kerf = 0.1;

TW = 5.7; // wood
//TW = 3.5; // thinner wood
TA = 3.0; // acrylic

// 3h + w = 181
// 3w = 181

tn = 3;
tnb = 3;
tnt = 3;

s440 = 2.845/2;

inset = TW; // inset of acrylic in wood

middle = 100;

box_s = 5*TW*4;
P = 2; 
box_s = 59*3/2; // floor((181-2*2)/3);
box_h = TW*4;
box_h = 16;
box_h = 15 + 2*TW;

inch = 25.4;
screw_space = inch * (1-2*0.15);

//function brown(i, a=1) = [0.7-i/10, 0.4-i/10, 0, a];
function brown(i, a=1) = [0.5-i/20, 0.3-i/20, 0, a];

module tabs(n, l, o=0, v=0, tt=TW) {
    ts = l/n;
    for (i=[0:n-1]) {
        x = v ? ts*i : 0;
        y = v ? 0 : ts*i;
        w = v ? ts : tt;
        h = v ? tt : ts;
        if ((i+o)%2) {
            translate([x, y])
            square([w, h]);
        }
    }
}

module side(o) {
    translate([TW, 0])
    difference() {
        union() {
            // Base
            square([box_s-2*TW, box_h]);
            // Sides
            translate([box_s-2*TW, 0])
            tabs(tn, box_h, o=o);
            translate([-TW, 0])
            tabs(tn, box_h, o=o);
        }
        // Bottom
        translate([-TW, 0])
        tabs(tnb, box_s-0*TW, v=1);
        // Top
        translate([-TW, box_h-TW])
        tabs(tn, box_s-0*TW, v=1);
        *if (o) {
            translate([-TW, box_h-TW])
            square([box_s/3, TW]);
            translate([box_s*2/3-TW, box_h-TW])
            square([box_s/3, TW]);
        }
    }
}

module front(tn=tn) {
    union() {
        translate([TW, TW])
        square([box_s-2*TW, box_s-2*TW]);

        tabs(tn, box_s);
        translate([box_s-TW, 0])
        tabs(tn, box_s);

        tabs(tn, box_s, v=1);
        translate([0, box_s-TW])
        tabs(tn, box_s, v=1);
    }
}

screw_space = box_s-25;
screw_offset = (box_s-screw_space)/2;

module screw_holes() {
    // Screws
    $fn = pow(2, 4);
    offset(-kerf) {
        translate([screw_offset, screw_offset]) circle(r=s440);
        translate([screw_offset+screw_space, screw_offset]) circle(r=s440);
        translate([screw_offset, screw_offset+screw_space]) circle(r=s440);
        translate([screw_offset+screw_space, screw_offset+screw_space]) circle(r=s440);
    }
}

module screw() {
    circle(r=s440*2);

    translate([0, 0, -6])
    linear_extrude(height=6)
    circle(r=s440);
}

module screws() {
    // Screws
    $fn = pow(2, 4);
    translate([screw_offset, screw_offset]) screw();
    translate([screw_offset+screw_space, screw_offset]) screw();
    translate([screw_offset, screw_offset+screw_space]) screw();
    translate([screw_offset+screw_space, screw_offset+screw_space]) screw();
}

module knob() {
    cylinder(16, r=35/2);
    //cylinder(20, r=44/2);
}

module encoder() {
    cylinder(7, r=7/2);
    cylinder(20, r=6/2);
    translate([-13/2, -13/2, -6.5])
    cube([13, 13, 6.5]);
}

module board() {
    board_s = 44.5;
    translate([-board_s/2, -board_s/2, -6.5-2])
    cube([board_s, board_s, 2]);
}

module toppiece() {
    difference() {
        bottom();
        $fn=64;
        translate([box_s/2, box_s/2])
        circle(r=(box_s-4*TW)/2);
        screw_holes();
    }
}

module top() {
    difference() {
        square([box_s, box_s]);
        screw_holes();
        translate([box_s/2, box_s/2]) circle(r=7/2);
    }
}

module cleartop() {
    difference() {
        square([box_s, box_s]);
        screw_holes();
        translate([box_s/2, box_s/2]) circle(r=7/2);
        translate([box_s/2, box_s/2])
        circle(r=(box_s-4*TW)/2);
    }
}

module back() {
    difference() {
        side(0);
        $fn = 16;
        ww = 5.5;
        translate([box_s/2, TW+ww/2])
        circle(r=ww/2); // 5.5, 4.5, 3 dia
        translate([box_s/2-ww/2, TW-ww/2])
        square(ww);
    }
}

module bottom() {
    translate([TW, TW])
    square(box_s-TW*2);

    // Tabs
    translate([box_s/2, box_s/2])
    for (i=[0:3]) {
        rotate([0, 0, 90*i])
        translate([box_s/2-TW, -box_s/2, 0])
        tabs(tnb, box_s, o=(i+1)%2*((tnb+1)%2));
    }
}
module show3d() {

    // Bottom
    color(brown(0))
    translate([0, 0, 0])
    linear_extrude(height=TW)
    bottom();

    // Innards

    color([0.7,0.7,0.7])
    translate([0, 0, box_h+2*TA])
    screws();

    color([0.7,0.7,0.7])
    translate([box_s/2, box_s/2, box_h+TA+TA+1])
    knob();

    color([0.7,0.7,0.7])
    translate([box_s/2, box_s/2, box_h+TA-TA])
    encoder();
    
    color([0.3,0.2,1.0])
    translate([box_s/2, box_s/2, box_h+TA-TA])
    board();

    // Top

    color(brown(3))
    translate([0, 0, box_h-TW])
    //translate([0, 0, TW])
    linear_extrude(height=TW)
    toppiece();

    color([0.0,0.5,1.0,0.5])
    translate([0, 0, box_h])
    linear_extrude(height=TA)
    cleartop();

    color([0,0,0])
    translate([0, 0, box_h+TA])
    linear_extrude(height=TA)
    top();

    // Sides

    for (i=[1:3]) {
        o1 = floor(i/2) * box_s;
        o2 = ((i+1)%2) * -TW;
        translate([o1, o1, 0])
        rotate([90, 0, 90*i])
        translate([0, 0, o2])
        color(brown((i-1)))
        linear_extrude(height=TW)
        side(i%2);
    }

    rotate([90, 0, 0])
    translate([0, 0, -TW])
    color(brown((4)))
    linear_extrude(height=TW)
    back();
}

module show2d() {
    translate([0*(box_s+P), -1])
    bottom();

    translate([1*(box_s+P), -1])
    toppiece();

    translate([1*(box_s+P), 1*(box_s)])
    back();

    translate([0*(box_s+P), 1*(box_s)])
    side(1);

    translate([1*(box_s+P), 1*(box_s)+1*(box_h+P)])
    side(0);

    translate([0*(box_s+P), 1*(box_s)+1*(box_h+P)])
    side(1);
}

show3d();
//linear_extrude(height=TW)
offset(kerf)
//cleartop();
show2d();
translate([0,0,-1])
color([0.3,0.3,0.3])
*square([181,181]);
//linear_extrude(height=TA)
//front(tnt);

