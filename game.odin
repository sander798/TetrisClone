package tetrisClone

import "core:fmt"
import "core:log"
import "core:time"
//import "core:math"
//import "core:math/rand"
import rl "vendor:raylib"

TITLE :: "TetrisClone"

debugMode := true

Shape :: struct {
    tiles: [4][4]rl.Color,
}

board: [10][20]rl.Color = {}    //Game board

nextUpShapes: [4]Shape          //Upcoming shapes list

currentShape: [16][2]u8         //Currently controlled shape (vector positions for each block)
currentShapeLength: u8          //Number of active vectors

score: u32
level: u8 = 1

BASE_MOVEMENT_TIME :: time.Second * 2  //Starting time in ns between shape drops at level 1
LEVEL_MOVEMENT_MOD: f32 : 1.05      //Drop time modifier per level
lastMovementTime: time.Time     //Time at which last drop occurred

main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    fmt.println("****", TITLE, "****")

    rl.InitWindow(1280, 720, TITLE)
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    //Fill next-up shape queue
    /*for &s in nextUpShapes {
        log.debug("Add new shape")
    }*/

    //Set first controlled shape
    

    //Set initial time
    lastMovementTime = time.now()
    
    for !rl.WindowShouldClose() {
        //Get input
        

        //Check for downward movement
        if time.diff(lastMovementTime, time.now()) > BASE_MOVEMENT_TIME * time.Duration(LEVEL_MOVEMENT_MOD * f32(level)) {
            lastMovementTime = time.now()
        }

        //*** Rendering ***
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        //rl.DrawText("Hello World!", 100, 100, 20, rl.RED)

        //Board and background
        rl.DrawRectangleLinesEx({396, 96, 308, 608}, 4, rl.GRAY)

        //Blocks
        for x in 0..<len(board) {
            for y in 0..<len(board[0]){
                rl.DrawRectangle(i32(400 + (x * 30)), i32(700 - ((y + 1) * 30)), 30, 30, board[x][y])
            }
        }

        if debugMode do rl.DrawFPS(0, 0)

        rl.EndDrawing()
    }
}