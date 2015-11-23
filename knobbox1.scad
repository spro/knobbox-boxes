T = 5.7; // thickness
TA = 3.0;
kerf = 0.2;

s440 = 2.845/2;
middle = 100;

box_s = 60;
box_inset = 12;
box_top_inset = T;
box_h = 30;

function tabSize(n_tabs, length) = length/n_tabs/2;

module tabs(n_tabs, length, vert=false, secondary=false) {
    tab_s = tabSize(n_tabs, length);

    for (i=[0:n_tabs-1]) {
        tab_y = tab_s*i*2;
        tab_offset = secondary ? tab_s : 0;
        if (vert) {
            translate([0, tab_y+tab_offset])
            square([T, tab_s]);
        } else {
            translate([tab_y+tab_offset, 0])
            square([tab_s, T]);
        }
    }
}

module outer_tab_holes() {
    translate([T+box_inset, T])
    square([T, box_h-box_top_inset-T]);
    translate([box_s-box_inset, T])
    square([T, box_h-box_top_inset-T]);
}

module tabbed_face(top_tabs) {
    union() {
        translate([T, 0])
        square([box_s, box_h]);

        translate([0, 0])
        tabs(2, box_h, vert=true, secondary=top_tabs);
        translate([box_s+T, 0])
        tabs(2, box_h, vert=true, secondary=top_tabs);

        translate([T+box_s/4, -T])
        tabs(1, box_s);
    }
}

module outer_tabbed_face(top_tabs) {
    linear_extrude(height=T)
        difference() {
            tabbed_face(top_tabs);
            outer_tab_holes();
        }
}

module single_tabbed_face() {
    union() {
        translate([T, 0])
        square([box_s, box_h-box_top_inset]);
        translate([0, T])
        square([T, box_h-box_top_inset-T]);
        translate([box_s+T, T])
        square([T, box_h-box_top_inset-T]);
    }
}

module inner_tabbed_face(top_tabs) {
    linear_extrude(height=T)
        difference() {
            single_tabbed_face();
            slice_h = (box_h-box_top_inset)/2;
            /* if (top_tabs) { */
            /*     translate([T + box_inset, slice_h]) */
            /*     square([T, slice_h]); */
            /*     translate([box_s - box_inset, slice_h]) */
            /*     square([T, slice_h]); */
            /* } else { */
            /*     translate([T + box_inset, 0]) */
            /*     square([T, slice_h]); */
            /*     translate([box_s - box_inset, 0]) */
            /*     square([T, slice_h]); */
            /* } */
            translate([box_inset+T, 0, 0])
            tabs(2, box_h-box_top_inset, vert=true, secondary=top_tabs);
            translate([box_s-box_inset, 0, 0])
            tabs(2, box_h-box_top_inset, vert=true, secondary=top_tabs);
            translate([box_inset+2*T, 0, 0])
            square([(box_s-box_inset*2)-2*T, box_h]);
        }
}

module bottom() {
    linear_extrude(height=T) {
        union() {
            square([box_s, box_s]);

            square_s = box_s/4+T;

            translate([-T, -T])
            square(square_s);

            translate([box_s-square_s+T, -T])
            square(square_s);

            translate([box_s-square_s+T, box_s-square_s+T])
            square(square_s);

            translate([-T, box_s-square_s+T])
            square(square_s);
        }
    }
}

module top() {
    //linear_extrude(height=TA)
        difference() {
            square([box_s, box_s]);
            translate([box_s/2, box_s/2]) circle(r=7/2);
        }
}

// Layed out

for (f = [0:3]) {
    translate([f*(box_s+T*3), (f%2*100)]) {
        outer_tabbed_face(f%2);
        translate([0, -box_h-T])
        inner_tabbed_face(f%2);
    }
}

translate([-box_s-2*T, 0])
bottom();

translate([-box_s-2*T, -box_s-3*T])
*top();

// In 3d

off_yellow = [0.85, 0.75, 0, 1];//0.5];
off_blue = [0, 0.75, 0.85, 1];//0.5];
off_green = [0, 0.85, 0.55, 1];//0.5];

*rotate([90, 0, 0])
translate([0,0,0]) {

    color(off_yellow)
    translate([0, 0, 0])
    outer_tabbed_face(0);

    color(off_yellow)
    translate([0, 0, box_s+T])
    outer_tabbed_face(0);

    color(off_blue)
    translate([T, 0, 0])
    rotate([0, 270, 0])
    outer_tabbed_face(1);

    color(off_blue)
    translate([box_s+2*T, 0, 0])
    rotate([0, 270, 0])
    outer_tabbed_face(1);

    color(off_green)
    translate([T, 0, T])
    rotate([90, 0, 0])
    bottom();

    translate([box_inset+2*T, 0])
    rotate([0, 270, 0])
    inner_tabbed_face();

    translate([box_s-box_inset+T, 0])
    rotate([0, 270, 0])
    inner_tabbed_face();

    color(off_yellow)
    translate([0, 0, box_inset+T])
    inner_tabbed_face(1);

    color(off_yellow)
    translate([0, 0, box_s-box_inset])
    inner_tabbed_face(1);

}
