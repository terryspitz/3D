difference() {
    intersection() {
        scale([1,1,0.2])
            surface(file="C:/Users/terry/Google Drive/3D/avocado/retina-blur.png", center=true);
        cylinder(h=100, r=290, center=true);
    }
    cylinder(h=50, r1=30, r2=150, center=true);
}