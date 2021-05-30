//use <C:\Users\terry\Downloads\Product Sans Regular.ttf>
use <C:\Users\terry\Google Drive\3D\tala-earings\Dactyl Round.ttf>
//text = "Gogle";
//letter = "£  a b c d e f o s t";
//letter = "£"; //the Cloud shape!
//handle_offset = 6;
//letter = "a";
handle_offset = 8;

module print(letter) { 
    //text(letter, 72*0.30, "Arial Rounded MT Bold:style=Regular"); 
    text(letter, 72*0.30, "Dactyl"); 
}
//text(text, 24, "Product Sans:style=Regular");
//for(i = [0:len(text)]) {
    //let(letter=text[i])
    //translate([i*200, 0, 0]) union() {
        //handle
        difference() {
            linear_extrude(3)
                print(letter);
            translate([-10, handle_offset-50-3, -1])
                cube([200,50,10]);
            translate([-10, handle_offset, -1])
                cube([200,50,10]);
        };
//        linear_extrude(3)
//            difference() {
//                offset(5) print(letter);
//                print(letter);
//            };
        linear_extrude(3)
            difference() {
                offset(2) print(letter);
                print(letter);
            };
        //thinest outline
        linear_extrude(9)
            difference() {
                offset(0.5) print(letter);
                print(letter);
            };
    //}
//}