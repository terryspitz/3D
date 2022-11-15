//use <C:\Users\terry\Downloads\Product Sans Regular.ttf>
text = "Gogle";
//text(text, 24, "Product Sans:style=Regular");
for(i = [0:len(text)]) {
    let(letter=text[i])
    translate([i*30, 0, 0]) union() {
        difference() {
            hull() {
                linear_extrude(2) offset(2) text(letter, 24, "Product Sans:style=Bold");
                translate([0, 0, 10]) linear_extrude(1) text(letter, 24, "Product Sans:style=Bold");
            };
            translate([0, 0, 3]) linear_extrude(10) text(letter, 24, "Product Sans:style=Bold");
        }
    }
}