/* This files provides address values that exist in the system */

#define SDRAM_BASE            0xC0000000
#define FPGA_ONCHIP_BASE      0xC8000000
#define FPGA_CHAR_BASE        0xC9000000

/* Cyclone V FPGA devices */
#define LEDR_BASE             0xFF200000
#define HEX3_HEX0_BASE        0xFF200020
#define HEX5_HEX4_BASE        0xFF200030
#define SW_BASE               0xFF200040
#define KEY_BASE              0xFF200050
#define TIMER_BASE            0xFF202000
#define PIXEL_BUF_CTRL_BASE   0xFF203020
#define CHAR_BUF_CTRL_BASE    0xFF203030

/* VGA colors */
#define WHITE 0xFFFF
#define YELLOW 0xFFE0
#define RED 0xF800
#define GREEN 0x07E0
#define BLUE 0x001F
#define CYAN 0x07FF
#define MAGENTA 0xF81F
#define GREY 0xC618
#define PINK 0xFC18
#define ORANGE 0xFC00
#define BLANK 0x0000

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>


void swap(int *num1, int *num2);
void draw_line(int x0, int y0, int x1, int y1, short int line_colour);
void clear_screen();
void wait_animation();

volatile int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    /* Read location of the pixel buffer from the pixel buffer controller */
    pixel_buffer_start = *pixel_ctrl_ptr;
    // clear screen
    clear_screen();
    // initialize the direction and position
    bool direction_up = true;
    int y = RESOLUTION_Y;

    /*Currently line goes from bottom to to*/

    /* If we want the line to go from top to bottom
    
    change the following lines to the given code:
    
    63          bool direction_up = false;
    64          int y = 0;
    
    91          y++
    93          y--
    // everything else remains the same
    */

    while (1){
        // clears the previous line
        draw_line(106, y, 213, y, BLANK);
        // checks the direction
        if (y == 0){
            direction_up = false;
        } else if (y == RESOLUTION_Y){
            direction_up = true;
        }
        // increments y coordinate according to the direction
        if(direction_up){
            y--;
        } else{
            y++;
        }
        // draw the new line
		draw_line(106, y, 213, y, WHITE);
        // "wait" code that changes the status register and does the sync
        wait_animation();
    }


}

// code not shown for clear_screen() and draw_line() subroutines

void plot_pixel(int x, int y, short int line_color)
{
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

// Draws the line to the display given the starting coordinates and colour
// Implemented the given pseudo code
void draw_line(int x0, int y0, int x1, int y1, short int line_colour){
    bool is_steep = abs(y1-y0) > abs(x1-x0);
    if(is_steep == TRUE){
        swap(&x0, &y0);
        swap(&x1, &y1);
    }
    if (x0 > x1){
        swap(&x0, &x1);
        swap(&y0, &y1);
    }

    int deltax = x1 - x0;
    int deltay = abs(y1 - y0);
    int error = -1*(deltax/2);
    int y = y0;
    int y_step = 0;
    if (y0 < y1){
        y_step = 1;
    } else {
        y_step = -1;
    }

    for (int x = x0; x <= x1; x++){
        if(is_steep == TRUE){
            plot_pixel(y, x, line_colour);
        } else {
            plot_pixel(x, y, line_colour);
        }
        error = error + deltay;
        if (error > 0){
            y = y + y_step;
            error = error - deltax;
        }
    }

}

void swap(int *num1, int *num2){
    int temp = *num1;
    *num1 = *num2;
    *num2 = temp;
}

void clear_screen(){
    for(int y = 0; y < RESOLUTION_Y; y++){
        for(int x = 0; x < RESOLUTION_X; x++){
            plot_pixel(x, y, BLANK);
        }
    }
}

// Code from lecture 17-18 
void wait_animation(){
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020; // pixel (DMA) controller (I/O)
    register int status;
    *pixel_ctrl_ptr = 1; // start synchronization; s bit is set to 1
    status = *(pixel_ctrl_ptr + 3); // read status register at address
    while ((status & 0x01) != 0){
        status = *(pixel_ctrl_ptr+3);
    }
}