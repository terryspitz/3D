text = "Gogle";
$fn=10;
    
minkowski() {
    linear_extrude(3)
        //text(text, 24, "Product Sans:style=Regular");
        import("gogle-s.svg");
    //cube([20, 20, 20]);
    cylinder(10, r1=5, r2=0);
}