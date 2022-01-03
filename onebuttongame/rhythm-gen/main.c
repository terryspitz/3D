
#include <stdio.h>
#include <windows.h>

void main()
{
    time_t t;
    srand((unsigned) time(&t));
    
    // for(int i=0; i<8; ++i) {
    //     int on = 1 << (rand() % 3);
    //     int off = rand() % 3;
    //     off = off ? (1 << off-1) : 0;
    //     printf("x"); for(int j=0; j<on-1; ++j) printf("-");
    //     for(int j=0; j<off; ++j) printf(".");
    // }

    for(int j=0; j<5; ++j)
    {
        printf("x");
        for(int i=0; i<7; ++i) {
            printf(rand() % 2 ? "x" : "-");
        }
        printf("\n");
    }
    // Sleep(1000);
    printf("\n\ndone\n\n");
}
