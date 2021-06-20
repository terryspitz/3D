// One Button Game on PIC10F322

#include "mcc_generated_files/mcc.h"

void xorshift(unsigned* rand)
{
    *rand ^= *rand << 7;
    *rand ^= *rand >> 9;
    *rand ^= *rand << 8;
}

typedef struct { uint8_t r; uint8_t g; uint8_t b; } RGB;
typedef struct { uint8_t h; uint8_t s; uint8_t v; } HSV;

//const RGB Red = {255, 0, 0};
//const RGB Green = {0, 255, 0};
//const RGB Blue = {0, 0, 255};
//const RGB DarkRed = {128, 0, 0};
//const RGB DarkGreen = {0, 128, 0};
//const RGB DarkBlue = {0, 0, 128};
//const RGB Black = {0, 0, 0};

RGB HsvToRgb(uint8_t h, uint8_t s, uint8_t v);

void delay_ms(unsigned long ms) {
    for(unsigned long i = 0; i<ms; ++i)
        __delay_ms(1);
}


void main(void)
{
    SYSTEM_Initialize();

    uint8_t hue = 0;
    while (1) {
        RGB rgb = HsvToRgb(hue++, 255, 128);
        LED_RA0_PORT = 1;
        for(uint8_t i=rgb.r; i; --i);
        LED_RA0_PORT = 0;
        for(uint8_t i=-rgb.r; i; --i);
        __delay_ms(1);
    }
    
//    uint16_t rand1 = 1;
//    uint16_t steps = 1;
//    uint16_t dit_ms = 600;
//
//	while (1) {
//        // show pattern
//        unsigned rand2 = rand1;
//        for(char step = 0; step<steps; ++step) {
//            xorshift(&rand2);
//            LED_RA2_PORT = 1;
//            delay_ms(dit_ms * (rand2 & 1) ? 3 : 1);
//            LED_RA2_PORT = 0;
//            if(step < steps-1)
//                delay_ms(dit_ms*3);
//        }
//
//        // read and check response
//        rand2 = rand1;  //reset
//        for(char step = 0; step<steps; ++step) {
//            xorshift(&rand2);
//            LED_RA2_PORT = 1;
//            delay_ms(dit_ms * (rand2 & 1) ? 3 : 1);
//            LED_RA2_PORT = 0;
//            if(step < steps-1)
//                delay_ms(dit_ms*3);
//        }
//        ++steps;
//	}
}

//from https://stackoverflow.com/a/22120275/1991573
RGB HsvToRgb(uint8_t h, uint8_t s, uint8_t v) {
    RGB ret;
    if (s == 0) {
        ret.r = v; ret.g = v; ret.b = v;
    } else {

        // converting to 16 bit to prevent overflow
        uint8_t region = h / 43;
        uint16_t remainder = (uint16_t)(h - (region * 43)) * 6;

        uint8_t p = ((uint16_t)v * (255 - s)) >> 8;
        uint8_t q = ((uint16_t)v * (255 - ((s * remainder) >> 8))) >> 8;
        uint8_t t = ((uint16_t)v * (255 - ((s * (255 - remainder)) >> 8))) >> 8;

        switch (region) {
            case 0: 
                ret.r = v; ret.g = t; ret.b = p; 
                break;
            case 1: 
                ret.r = q; ret.g = v; ret.b = p;
                break;
            case 2:
                ret.r = p; ret.g = v; ret.b = t;
                break;
            case 3:
                ret.r = p; ret.g = q; ret.b = v;
                break;
            case 4:
                ret.r = t; ret.g = p; ret.b = v;
                break;
            default:
                ret.r = v; ret.g = p; ret.b = q;
                break;
        }
    }
    return ret;
}

/**
 End of File
*/