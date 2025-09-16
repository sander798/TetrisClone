package tetrisClone

import "core:fmt"
import "core:log"
import rl "vendor:raylib"

TITLE :: "TetrisClone"

debugMode := true

Shape :: struct {
    tiles: [4][4]rl.Color,
}

board: [10][20]rl.Color = {}   //Game board

currentShape: [16][2]u8     //Currently controlled shape (vector positions for each block)
currentShapeLength: u8      //Number of active vectors

score: u32
level: u8



main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    fmt.println("****", TITLE, "****")

    rl.InitWindow(1280, 720, TITLE)
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    for i in 0..<len(board){
        board[i][0] = rl.RED
    }



    for !rl.WindowShouldClose() {


    //  Rendering
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