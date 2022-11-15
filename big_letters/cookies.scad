//use <C:\Users\terry\Downloads\Product Sans Regular.ttf>
//text = "Gogle";
letter = "A";
module print(letter) { text(letter, 72*1.5, "Product Sans:style=Bold"); }
//text(text, 24, "Product Sans:style=Regular");
//for(i = [0:len(text)]) {
    //let(letter=text[i])
    //translate([i*200, 0, 0]) union() {
        linear_extrude(3)
            offset(5) print(letter);
        linear_extrude(6)
            difference() {
                offset(3) print(letter);
                print(letter);
            };
        linear_extrude(9)
            difference() {
                offset(1) print(letter);
                print(letter);
            };
    //}
//}