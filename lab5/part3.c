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

#define ABS(x) (((x) > 0) ? (x) : -(x))

/* Screen size. */
#define RESOLUTION_X 320
#define RESOLUTION_Y 240

/* Constants for animation */
#define BOX_LEN 2
#define NUM_BOXES 8

#define FALSE 0
#define TRUE 1

/* self defined consts */
#define BLACK 0x0000
#define increase 1
#define decrease -1

#include <stdlib.h>
#include <stdio.h>
#include <stdbool.h>

// Begin part3.c code for Lab 7
void wait_for_vsync();
void drawBox(int coor_x, int coor_y, short int color);
void draw(int coor_x[8], int coor_y[8], short int color[8]);
void updateLocation(int coor_x[8], int coor_y[8], int dir_h[8], int dir_v[8]);
void clear_screen(int pre_x[8], int pre_y[8], int pre_dirH[8], int pre_dirV[8], int pre_pre_x[8], int pre_pre_y[8], int black[10]);
void drawLine(int from_x, int to_x, int from_y, int to_y, short int color);
void draw_pixel(int x, int y, short int line_color);
void swap(int* point_one, int* point_two);
void randColor(short int color[10]);
void clear_screen_init();

volatile int pixel_buffer_start; // global variable

int main(void)
{
    volatile int * pixel_ctrl_ptr = (int *)0xFF203020;
    // declare other variables(not shown)
    short int color[10] = {WHITE, YELLOW, RED, GREEN, BLUE, CYAN, MAGENTA, GREY, PINK, ORANGE};
    short int black[10] = {BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK, BLACK};
    int coor_x[8], coor_y[8], pre_x[8], pre_y[8], dir_h[8], dir_v[8], pre_dirH[8], pre_dirV[8];
    int pre_pre_y[8], pre_pre_x[8];
    // initialize location and direction of rectangles(not shown)
    for(int i = 0; i < NUM_BOXES; i++){
        coor_x[i] = rand() % RESOLUTION_X;  //initialize the initial point coordinate randomly
        coor_y[i] = rand() % RESOLUTION_Y;
        pre_x[i] = coor_x[i];
        pre_y[i] = coor_y[i];
        dir_h[i] = rand() % (1 - (-1) + 1) + (-1);  //initialize the vertical and horizontal directions randomly
        dir_v[i] = rand() % (1 - (-1) + 1) + (-1);  //value is from 1 and -1; rand()%(ub - lb + 1) + lb
        pre_dirH[i] = dir_h[i];
        pre_dirV[i] = dir_v[i];
        pre_pre_x[i] = pre_x[i];
        pre_pre_y[i] = pre_y[i];
    }
    /* set front pixel buffer to start of FPGA On-chip memory */
    *(pixel_ctrl_ptr + 1) = FPGA_ONCHIP_BASE; // first store the address in the 
                                        // back buffer
    /* now, swap the front/back buffers, to set the front buffer location */
    wait_for_vsync();
    /* initialize a pointer to the pixel buffer, used by drawing functions */
    pixel_buffer_start = *pixel_ctrl_ptr;
    clear_screen_init(); // pixel_buffer_start points to the pixel buffer
    /* set back pixel buffer to start of SDRAM memory */
    *(pixel_ctrl_ptr + 1) = SDRAM_BASE;
    pixel_buffer_start = *(pixel_ctrl_ptr + 1); // we draw on the back buffer
    clear_screen_init(); // pixel_buffer_start points to the pixel buffer

    randColor(color);  //initilize the random color for one round

    while (1)
    {
        /* Erase any boxes and lines that were drawn in the last iteration */
        clear_screen(pre_x, pre_y, pre_dirH, pre_dirV, pre_pre_x, pre_pre_y, black);
        // code for drawing the boxes and lines (not shown)
        draw(coor_x, coor_y, color);
        // code for updating the locations of boxes (not shown)
        for(int i = 0; i < NUM_BOXES; i++){
            pre_x[i] = coor_x[i];
            pre_y[i] = coor_y[i];
            pre_dirH[i] = dir_h[i];
            pre_dirV[i] = dir_v[i];
        }
        updateLocation(coor_x, coor_y, dir_h, dir_v);
        wait_for_vsync(); // swap front and back buffers on VGA vertical sync
        pixel_buffer_start = *(pixel_ctrl_ptr + 1); // new back buffer
    }
    return 0;
}


// code for subroutines (not shown)
/* initialize the random color set */
void randColor(short int color[10]){
    for(int i = 0; i < NUM_BOXES; i++){
        int idx = rand() % 10;  //generate the color randomly
        color[i] = color[idx];
    }
}


/* given helper function from lecture */
void wait_for_vsync(){
    volatile int* pixel_ctrl_ptr = (int*) PIXEL_BUF_CTRL_BASE;  //pixel controller; address is DMA
    register int status;
    *pixel_ctrl_ptr = 1;  //start the synchronization process
    status = *(pixel_ctrl_ptr + 3);  //read status register at adress 0xFF20302C
    while ((status & 0x01) != 0){  //wait for s bit; poll IO
        status = *(pixel_ctrl_ptr + 3);
    }
}

/* draw the colored pixel */
void drawBox(int coor_x, int coor_y, short int color){  //four pixels in total
    draw_pixel(coor_x, coor_y, color);
    draw_pixel(coor_x + 1, coor_y, color);
    draw_pixel(coor_x, coor_y + 1, color);
    draw_pixel(coor_x + 1, coor_y + 1, color);
}

/* drawing the boxes and lines */
void draw(int coor_x[8], int coor_y[8], short int color[10]){
    for(int i = 0; i < NUM_BOXES; i++){
        drawBox(coor_x[i], coor_y[i], color[i]);  //drawthe vertex
        if(i == NUM_BOXES - 1){  //if last vertex
            drawLine(coor_x[i], coor_x[0], coor_y[i], coor_y[0], color[i]);
            return;  //nothing to draw
        }
        drawLine(coor_x[i], coor_x[i + 1], coor_y[i], coor_y[i + 1], color[i]);
    }
}

/* update the locations of boxes and directions */
void updateLocation(int coor_x[8], int coor_y[8], int dir_h[8], int dir_v[8]){
    for(int i = 0; i < NUM_BOXES; i++){
        //change direction if reach the edge of VGA screen
        if(coor_y[i] == RESOLUTION_Y - 1){
            dir_v[i] = decrease;
        }else if(coor_y[i] == 0){
            dir_v[i] = increase;
        }else if(coor_x[i] == RESOLUTION_X - 1){
            dir_h[i] = decrease;
        }else if(coor_x[i] == 0){
            dir_h[i] = increase;
        }
        //update location for vertices
        coor_x[i] += dir_h[i];
        coor_y[i] += dir_v[i];
    }
}

/* clean the whole screen */
void clear_screen_init(){
    for(int temp_x = 0; temp_x < RESOLUTION_X; temp_x++){
        for(int temp_y = 0; temp_y < RESOLUTION_Y; temp_y++){
            draw_pixel(temp_x, temp_y, BLACK);  //draw black everywhere
        }
    }
}

/* clean the specific screen */
void clear_screen(int pre_x[8], int pre_y[8], int pre_dirH[8], int pre_dirV[8], int pre_pre_x[8], int pre_pre_y[8], int black[10]){
    for(int i = 0; i < NUM_BOXES; i++){
        //change direction if reach the edge of VGA screen
        if(pre_y[i] == RESOLUTION_Y - 1){
            pre_dirV[i] = increase;
        }else if(pre_y[i] == 0){
            pre_dirV[i] = decrease;
        }else if(pre_x[i] == RESOLUTION_X - 1){
            pre_dirH[i] = increase;
        }else if(pre_x[i] == 0){
            pre_dirH[i] = decrease;
        }
        //update location for vertices
        pre_pre_x[i] = pre_x[i] - pre_dirH[i];
        pre_pre_y[i] = pre_y[i] - pre_dirV[i];
    }
    draw(pre_pre_x, pre_pre_y, black);
}

/* draw the colored line between two points */
void drawLine(int from_x, int to_x, int from_y, int to_y, short int color){
    bool is_steep = ABS(to_y - from_y) > ABS(to_x - from_x);
    //change to horizontal if vertical
    if(is_steep){
        swap(&from_x, &from_y);
        swap(&to_x, &to_y);
    }
    //ensure line is from left to right
    if(from_x > to_x){
        swap(&from_x, &to_x);
        swap(&from_y, &to_y);
    }
    //initialization
    int delta_x = ABS(to_x - from_x);
    int delta_y = ABS(to_y - from_y);
    int error = -(delta_x / 2);
    int y = from_y;
    int y_step = 0;
    //find out y should increase or decrease
    if(from_y < to_y){
        y_step = increase;
    }else{
        y_step = decrease;
    }
    //bresenham's Algorithm
    for(int x = from_x; x < to_x; x++){
        if(is_steep){
            draw_pixel(y, x, color);
        }else{
            draw_pixel(x, y, color);
        }
        error += delta_y;
        if(error > 0){
            y += y_step;
            error -= delta_x;
        }
    }
}

/* plot a pixel on the VGA display */
void draw_pixel(int x, int y, short int line_color){
    *(short int *)(pixel_buffer_start + (y << 10) + (x << 1)) = line_color;
}

/* swap two values by pointers; deep swap */
void swap(int* point_one, int* point_two){
    int store = *point_one;
    *point_one = *point_two;
    *point_two = store; 
}