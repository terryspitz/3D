
//text(text, 24, "Product Sans:style=Regular");
module print(letter) { text(letter, 30, "Arial Rounded MT Bold:style=Regular"); }

//text = "Gogle";
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
        linear_extrude(12)
            difference() {
                offset(1) print(letter);
                print(letter);
            };
    //}
//}