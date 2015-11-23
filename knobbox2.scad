TW = 5.7; // wood
//TW = 3.5; // thinner wood
TA = 3.0; // acrylic

// 3h + w = 181
// 3w = 181

tn = 3;
tnt = 3;

s440 = 2.845/2;

inset = TW; // inset of acrylic in wood

middle = 100;

box_s = 5*TW*2;
P = 2; 
box_s = 59; // floor((181-2*2)/3);
box_h = box_s * 2/3 - 1;

inch = 25.4;
screw_space = inch * (1-2*0.15);

function brown(i, a=1) = [0.7-i/10, 0.4-i/10, 0, a];

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
        tabs(tn, box_s-0*TW, v=1);
        // Top
        *translate([-TW, box_h-TW])
        tabs(tn, box_s-0*TW, v=1);
        if (o) {
            translate([-TW, box_h-TW])
            square([box_s/4, TW]);
            translate([box_s*3/4-TW, box_h-TW])
            square([box_s/4, TW]);
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

module oldbottom() {
    difference() {
        side(0);
        translate([box_s/2-TW/2, TW])
        square([TW, TW*1]);

        screw_offset = (box_s-screw_space)/2;
        $fn = pow(2, 4);
        translate([screw_offset, screw_offset]) circle(r=s440);
        translate([screw_offset+screw_space, screw_offset]) circle(r=s440);
        translate([screw_offset, screw_offset+screw_space]) circle(r=s440);
        translate([screw_offset+screw_space, screw_offset+screw_space]) circle(r=s440);
    }
}

screw_space = box_s-20;
screw_offset = (box_s-screw_space)/2;

module screw_holes() {
    // Screws
    $fn = pow(2, 4);
    translate([screw_offset, screw_offset]) circle(r=s440);
    translate([screw_offset+screw_space, screw_offset]) circle(r=s440);
    translate([screw_offset, screw_offset+screw_space]) circle(r=s440);
    translate([screw_offset+screw_space, screw_offset+screw_space]) circle(r=s440);
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

module toppiecehalf() {
    difference() {
        square([box_s, box_s/4]);
        translate([TW, 0, 0])
        square([box_s-2*TW, TW]);

        screw_holes();

    }
}

module toppiece(full=true) {
    toppiecehalf();
    if (full) {
        translate([0, box_s])
        rotate([180])
        toppiecehalf();
    } else {
        translate([0, box_s*1/3+TW])
        toppiecehalf();
    }
}

module top() {
    difference() {
    square([box_s, box_s]);
        screw_holes();
        translate([box_s/2, box_s/2])
        circle(r=16/2);
    }
}

module back() {
    ww = 5.5;
    difference() {
        side(0);
        translate([box_s/2, TW+ww/2]) {
        translate([-ww/2, -ww])
        square([ww, ww]);
        circle(r=ww/2);
        }
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
        tabs(tn, box_s, o=(i+1)%2*((tn+1)%2));
    }
}

module show3d(full=true) {

    // Bottom
    color(brown(0))
    translate([0, 0, 0])
    linear_extrude(height=TW)
    bottom();

    // Top holder
    color([0.2,0.2,0])
    translate([0, 0, box_h-TW])
    linear_extrude(height=TW)
    toppiece();

if (full) {
    color([0,0,0])
    translate([0, 0, box_h])
    linear_extrude(height=TA)
    top();

    color([0.7,0.7,0.7])
    translate([0, 0, box_h+TA])
    screws();

    *color([0.7,0.7,0.7])
    translate([box_s/2, box_s/2, box_h+TA])
    cylinder(16, r=35/2);
}

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
    bottom();

    translate([2*(box_s+P), 0*box_s/2.55])
    toppiece(false);

    translate([2*(box_s+P), 1*box_s*2/3+2*TW])
    toppiece(false);

    translate([1*(box_s+P), 1*(box_s)])
    back();

    translate([0*(box_s+P), 1*(box_s)])
    side(1);

    translate([1*(box_s+P), 1*(box_s)+1*(box_h+P)])
    back();

    translate([0*(box_s+P), 1*(box_s)+1*(box_h+P)])
    side(1);

    translate([1*(box_s+P), 1*(box_s)+2*(box_h+P)])
    side(0);

    translate([0*(box_s+P), 1*(box_s)+2*(box_h+P)])
    side(1);

    translate([2*(box_s+P), 1*(box_s)+1*(box_h+P)])
    side(0);

    translate([2*(box_s+P), 1*(box_s)+2*(box_h+P)])
    side(1);
}

show3d();
translate([box_s+P, 0, 0])
show3d(false);
//linear_extrude(height=TW)
kerf = 0.095;
!offset(kerf)
//top();
show2d();
translate([0,0,-1])
color([0,0,0])
square([181,181]);
//linear_extrude(height=TA)
//front(tnt);

