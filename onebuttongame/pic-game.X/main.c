// One Button Game on PIC10F322

#include "mcc_generated_files/mcc.h"

// gamma correction table, from https://learn.adafruit.com/led-tricks-gamma-correction/the-quick-fix
//const uint8_t gamma8[] = {
//    0,1,2,5,10,16,25,36,50,68,89,114,142,175,213,255
//};

//typedef struct { uint8_t r; uint8_t g; uint8_t b; } RGB;
//const RGB Red = {255, 0, 0};
//const RGB Green = {0, 255, 0};
//const RGB Blue = {0, 0, 255};
//const RGB DarkRed = {128, 0, 0};
//const RGB DarkGreen = {0, 128, 0};
//const RGB DarkBlue = {0, 0, 128};
//const RGB Black = {0, 0, 0};

#define black (unsigned char)~0
#define red (unsigned char)~1
#define green (unsigned char)~4
#define blue (unsigned char)~2
#define magenta (unsigned char)~(2+1)
#define cyan (unsigned char)~(4+2)
#define yellow (unsigned char)~(4+1)

#define SET_BLACK PORTA = black
#define SET_RED PORTA = red
#define SET_GREEN PORTA = green
#define SET_BLUE PORTA = blue
#define SET_MAGENTA PORTA = magenta
#define SET_CYAN PORTA = cyan
#define SET_YELLOW PORTA = yellow

//not: black, red, green, blue
const unsigned char distract_colour[] = { magenta, cyan, yellow };
const unsigned char distract_colours = 3;

//typedef struct { uint8_t h; uint8_t s; uint8_t v; } HSV;
//RGB HsvToRgb(uint8_t h, uint8_t s, uint8_t v);

void delay_100ms(char hundred_ms) {
    for(char i = 0; i<hundred_ms; ++i)
        __delay_ms(100);
}

void xorshift(uint16_t *rand) {
    //Can't find a single 8 bit version 
    //(which doesn't use multiple chars, so might as well use a uint16_t)
    *rand ^= *rand << 7;
    *rand ^= *rand >> 9;
    *rand ^= *rand << 8;
}

//void set_led(RGB rgb) {
//    // LED duty cycle
//    for(uint8_t i=255; i; --i) {
//        LED0_PORT = i > gamma8[rgb.r >> 4];
//        LED1_PORT = i > gamma8[rgb.g >> 4];
//        LED2_PORT = i > gamma8[rgb.b >> 4];
//    }
//}

void sleep_for_button(void) {
    while(SWITCH3_GetValue()) {
        WDTCONbits.SWDTEN = 1;
        SLEEP();
        NOP();
        WDTCONbits.SWDTEN = 0;
    }
    SET_YELLOW;
    delay_100ms(3);
    SET_BLACK;
}


void main(void)
{
    SYSTEM_Initialize();
//    INTERRUPT_GlobalInterruptDisable();
//    INTERRUPT_PeripheralInterruptDisable();

// Test sleep
//        SET_BLACK;
//        NOP();
////        SLEEP();  //works when IOC off
//        NOP();

//#define FLASH_RGB
#ifdef FLASH_RGB
    while (1) {
        SET_RED;
        __delay_ms(1000);
//        SET_YELLOW;
//        PWM1CONbits.PWM1OE = 1;
//        __delay_ms(1000);
//        PWM1CONbits.PWM1OE = 0;
        //ORANGE
        for(int i=0; i<100; ++i) {
            SET_YELLOW;
            __delay_ms(3);
            SET_RED;
            __delay_ms(7);
        }
        SET_YELLOW;
        __delay_ms(1000);
        SET_GREEN;
        __delay_ms(1000);
        SET_BLUE;
        __delay_ms(1000);
        SET_MAGENTA;
        __delay_ms(1000);
        SET_MAGENTA;
        PWM1CONbits.PWM1OE = 1;
        __delay_ms(1000);
        PWM1CONbits.PWM1OE = 0;
        SET_CYAN;
        __delay_ms(1000);
        SET_BLACK;
        __delay_ms(500);
        sleep_for_button();
    }
#endif

#ifdef FADE
    while (1) {
        for(uint8_t i=255; i; --i) {
            RGB rgb = (RGB){ 0,i, 0};
//            for(uint8_t ii=4; ii; --ii) {
                set_led(rgb);
//            __delay_ms(5);
//            }
        }
        for(uint8_t i=0; i<255; ++i) {
            RGB rgb = (RGB){ 0,i, 0};
//            for(uint8_t ii=4; ii; --ii) {
                set_led(rgb);
//            __delay_ms(5);
//            }
        }
    }
#endif
    
#ifdef CYCLE_COLOURS
    uint8_t hue = 0;
    while (1) {
        RGB rgb = HsvToRgb(++hue, 255, 128);    
//        for(uint8_t i=255; i; --i) {
            set_led(rgb);
            __delay_ms(1);
//        }
    }
#endif

#define RHYTHM_GAMES
#ifdef RHYTHM_GAMES
    uint16_t rand = 0xB6;
    char idle_count = 0;
    char games_since_sleep = 0;
#define on_tenths 4
#define off_tenths 2

    while(1) {
        unsigned char size = (games_since_sleep>5) ? 8 : 4;
        xorshift(&rand);
        //bits of pattern define the rhythm
        unsigned char pattern = ((unsigned char)rand) | 0x1;
        ++idle_count;
        //INTRO
        for(char beats=0; beats<size; ++beats) {
            SET_RED;
            delay_100ms(on_tenths);
            SET_BLACK;
            delay_100ms(off_tenths);
        }
        //SHOW PATTERN
        for(char repeat=0; repeat<2; ++repeat) {
            for(char beats=0; beats<size; ++beats) {
                if(pattern & (1 << beats))
                    SET_GREEN;
                delay_100ms(on_tenths);
                SET_BLACK;
                delay_100ms(off_tenths);
            }
        }
        //CHECK INPUT MATCHES PATTERN
        char repeat, beats;
        for(repeat=0; repeat<2; ++repeat) {
            for(beats=0; beats<size; ++beats) {
                char tenths;
                char pressed = 0;
                char on = pattern & (1 << beats);
                for(tenths=0; tenths<on_tenths; ++tenths) {
                    if(!SWITCH3_GetValue()) {
                        pressed = 1;
                        if(on)
                            SET_BLUE;
                        else
                            break;
                        idle_count = 0;
                    }
                    else
                        SET_BLACK;
                    delay_100ms(1);
                }
                if((on && !pressed)
                        || tenths != on_tenths) {
                    //FAIL
                    SET_RED;
                    delay_100ms(10);
                    break;
                }

                SET_BLACK;
                delay_100ms(off_tenths);
            }
            if(beats!=size) break; //skip outer loop
        }
        if(beats==size && repeat==2) {
            //WIN!
            SET_GREEN;
            delay_100ms(10);
        }

        SET_BLACK;
        delay_100ms(2);
        if(idle_count>=1) {
            sleep_for_button();
            games_since_sleep = 0;
        }
        games_since_sleep++;
    } //while
#endif
//#define REACTION_TIME_GAMES
#ifdef REACTION_TIME_GAMES
    //game1: red red red pause green, show time
    //game2: red red red pause [distraction colours] green, show time
    //game3: red red red red green, show time
    uint16_t rand = 0;
    char idle_count = 0;
    char games_since_sleep = 0;
    char game;
    
    while (1) {
//        if(games_since_sleep % 10 >=5)
//            game = 2;
//        else
//            game = 1;
        game = 3;
        //intro flash red red red
        delay_100ms(10);
        ++idle_count;
        for(char i=0; i<(game < 3 ? 3 : 4); ++i) {
            SET_RED;
            delay_100ms(4);
            SET_BLACK;
            delay_100ms(2);
        }
        xorshift(&rand);
        char colours;
        if(game == 2)
            colours = ((char)rand) % 5 + 2; //distraction colour to show before green
        else if(game == 1 || game == 3)
            colours = 1; // just black before green

        unsigned char delay;
        unsigned char i, r;
        for(r=0; r<colours; ++r) 
        {
            if(r==0)
                PORTA = black;
            else {
                xorshift(&rand);
                char col = ((char)rand) % distract_colours;
                PORTA = distract_colour[col];
            }
            xorshift(&rand);
            switch(game) {
                case 1:
                    delay = ((char)rand) % 20 + 10; //tenths
                    break;
                case 2:
                    delay = ((char)rand) % 10 + 5; //tenths
                    break;
                case 3:
                    delay = 0; //tenths
                    break;
            }
            for(i=0; i<delay; ++i) {
                delay_100ms(1);
                if(!SWITCH3_GetValue()) {
                    //pressed too soon!
                    SET_RED; 
                    delay_100ms(20);
                    rand ^= i;
                    idle_count = 0;
                    break;
                }
            }
            if(i!=delay) break; //pressed too soon, break out
        }
        if(i==delay)
        {
            //light up, go!
            SET_GREEN;
            
            //measure reaction time
            for(char hundredths=0; hundredths<100; ++hundredths) {
                if(!SWITCH3_GetValue()) {
                    // yay, you did it!  show the score in blue flashes 0-10
                    SET_BLACK;
                    delay_100ms(10);
                    if(hundredths>50) hundredths=50;
                    for(char i=0; i < hundredths / 10; ++i) {
                        SET_BLUE;
                        delay_100ms(6);
                        SET_BLACK;
                        delay_100ms(2);
                    }
                    delay_100ms(10);
                    for(char i=0; i < hundredths % 10; ++i) {
                        SET_BLUE;
                        delay_100ms(4);
                        SET_BLACK;
                        delay_100ms(1);
                    }
                    rand ^= hundredths;
                    idle_count = 0;
                    break;
                }
                //1ms delay ==__delay_ms(1) == 63 instructions
                //less 19 instructions in the for():  _delay(63-19);
                //10ms delay ==__delay_ms(10) == 625 instructions
                //less 13 instructions in the for():
                _delay(625-13);
            }
        }
    
        SET_BLACK;
        if(idle_count>=1) {
            sleep_for_button();
            games_since_sleep = 0;
        }
        games_since_sleep++;
    } //while
#endif

// SIMON SAYS
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

////from https://stackoverflow.com/a/22120275/1991573
//RGB HsvToRgb(uint8_t h, uint8_t s, uint8_t v) {
//    RGB ret;
//    if (s == 0) {
//        ret.r = v; ret.g = v; ret.b = v;
//    } else {
//
//        // converting to 16 bit to prevent overflow
//        uint8_t region = h / 43;
//        uint16_t remainder = (uint16_t)(h - (region * 43)) * 6;
//
//        uint8_t p = ((uint16_t)v * (255 - s)) >> 8;
//        uint8_t q = ((uint16_t)v * (255 - ((s * remainder) >> 8))) >> 8;
//        uint8_t t = ((uint16_t)v * (255 - ((s * (255 - remainder)) >> 8))) >> 8;
//
//        switch (region) {
//            case 0: 
//                ret.r = v; ret.g = t; ret.b = p; 
//                break;
//            case 1: 
//                ret.r = q; ret.g = v; ret.b = p;
//                break;
//            case 2:
//                ret.r = p; ret.g = v; ret.b = t;
//                break;
//            case 3:
//                ret.r = p; ret.g = q; ret.b = v;
//                break;
//            case 4:
//                ret.r = t; ret.g = p; ret.b = v;
//                break;
//            default:
//                ret.r = v; ret.g = p; ret.b = q;
//                break;
//        }
//    }
//    return ret;
//}

/**
 End of File
*/
