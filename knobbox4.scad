TW = 5.7; // thickness
TA = 3.0;

kerf = 0.095;

P = kerf * 2 + 1;

s440 = 2.845/2;

box_s = 60;
box_top_inset = TW;
box_h = 30;

function tabSize(n_tabs, length) = length/n_tabs/2;

module tabs2(n, l, odd=0, vert=0, tt=TW) {
    ts = l/n;
    for (i=[0:n-1]) {
        x = vert ? 0 : ts*i;
        y = vert ? ts*i : 0;
        w = vert ? tt : ts;
        h = vert ? ts : tt;
        if ((i+odd)%2) {
            translate([x, y])
            square([w, h]);
        }
    }
}

module outer_tab_holes() {
    translate([TW*2, box_h-box_top_inset-TA])
    square([box_s-2*TW, TA]);
}

module tabbed_face(n_tabs, top_tabs) {
    translate([TW, 0])
    square([box_s, box_h]);

    translate([0, 0])
    tabs2(n_tabs, box_h, vert=1, odd=top_tabs);

    translate([box_s+TW, 0])
    tabs2(n_tabs, box_h, vert=1, odd=top_tabs);

    translate([0, -TW])
    tabs2(3, box_s+2*TW, odd=0);
}

module outer_tabbed_face(n_tabs, top_tabs) {
    difference() {
        tabbed_face(n_tabs, top_tabs);
        outer_tab_holes();
    }
}

module bottom() {
    square([box_s, box_s]);

    square_s = (box_s+2*TW)/3;

    translate([-TW, -TW])
    square(square_s);

    translate([box_s-square_s+TW, -TW])
    square(square_s);

    translate([box_s-square_s+TW, box_s-square_s+TW])
    square(square_s);

    translate([-TW, box_s-square_s+TW])
    square(square_s);
}

module top() {
    difference() {
        square([box_s, box_s]);
        offset(0*kerf)
        translate([box_s/2, box_s/2]) circle(r=7/2, $fn=32);
        translate([box_s/6, box_s/6]) circle(r=s440, $fn=32);
    }
    translate([-TW, TW])
    square([TW, box_s-2*TW]);
    translate([box_s, TW])
    square([TW, box_s-2*TW]);

    translate([TW, -TW])
    square([box_s-2*TW, TW]);
    translate([TW, box_s])
    square([box_s-2*TW, TW]);
}

// Layed out

module wired_outer_tabbed_face(n_tabs, top_tabs) {
    difference() {
        outer_tabbed_face(n_tabs, top_tabs);
        ww = 5.5;
        translate([box_s/2+TW, ww/2]) {
            translate([-ww/2, -ww/2-TW])
            square([ww, TW+ww/2]);
            circle(r=ww/2, $fn=32);
        }
    }
}

module show_2d() {
    for (f = [0:1]) {
        translate([f*(box_s+P+2*TW), TW]) {
            wired_outer_tabbed_face(2, 0);
            translate([0, box_h+TW+P])
            outer_tabbed_face(2, 1);
            translate([0, 2*(box_h+TW+P)])
            outer_tabbed_face(2, 0);
        }
    }

    translate([2*(box_s+P+2*TW)+TW+box_h, 0])
    rotate([0, 0, 90])
    translate([0, TW])
    for (f = [0:1]) {
        translate([f*(box_s+P+2*TW), 0])
        outer_tabbed_face(2, 1);
    }

    translate([TW, 3*(box_h+P+TW)+TW])
    bottom();

    translate([box_s+P+3*TW, 3*(box_h+P+TW)+TW])
    bottom();

    *translate([-box_s-2*TW, -box_s-3*TW])
    top();
}

// In 3d

off_yellow = [0.85, 0.75, 0, 1];//0.5];
off_blue = [0, 0.75, 0.85, 1];//0.5];
off_green = [0, 0.85, 0.55, 1];//0.5];

module show_3d() {
    rotate([90, 0, 0])
    translate([0,0,0]) {

        color(off_yellow)
        translate([0, 0, 0])
        linear_extrude(height=TW)
        outer_tabbed_face(2, 0);

        color(off_yellow)
        translate([0, 0, box_s+TW])
        linear_extrude(height=TW)
        outer_tabbed_face(2, 0);

        color(off_blue)
        translate([TW, 0, 0])
        rotate([0, 270, 0])
        linear_extrude(height=TW)
        outer_tabbed_face(2, 1);

        color(off_blue)
        translate([box_s+2*TW, 0, 0])
        rotate([0, 270, 0])
        linear_extrude(height=TW)
        outer_tabbed_face(2, 1);

        color(off_green)
        translate([TW, 0, TW])
        rotate([90, 0, 0])
        linear_extrude(height=TW)
        bottom();

        color([0.1, 0.1, 0.1])
        translate([TW, box_h-box_top_inset, TW])
        rotate([90, 0, 0])
        linear_extrude(height=TA)
        top();
    }
}

!offset(kerf)
show_2d();

show_3d();

//!offset(kerf)
top();
