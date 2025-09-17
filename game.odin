package tetrisClone

import "core:fmt"
import "core:log"
import "core:time"
import "core:math/rand"
import rl "vendor:raylib"

TITLE :: "TetrisClone"

debugMode := true

Shape :: struct {
    tiles: [4][4]rl.Color,
}

/*
templateShape := Shape {
    tiles = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}}
}
*/

lineShape := Shape {
    tiles = {{0, 0, 0, 0}, {0, 0, 0, 0}, {rl.YELLOW, rl.YELLOW, rl.YELLOW, rl.YELLOW}, {0, 0, 0, 0}},
}

cornerRightShape := Shape {
    tiles = {{0, 0, 0, 0}, {rl.RED, rl.RED, rl.RED, 0}, {0, 0, rl.RED, 0}, {0, 0, 0, 0}},
}

cornerLeftShape := Shape {
    tiles = {{0, 0, 0, 0}, {0, 0, rl.ORANGE, 0}, {rl.ORANGE, rl.ORANGE, rl.ORANGE, 0}, {0, 0, 0, 0}},
}

squareShape := Shape {
    tiles = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
}

shapes: []Shape = {lineShape, cornerRightShape, cornerLeftShape, squareShape}

board: [10][20]rl.Color = {}    //Game board

nextUpShapes: [4]Shape          //Upcoming shapes list

currentShapeType: Shape
currentShapePoints: [16][2]u8   //Currently controlled shape (vector positions for each block)
currentShapeLength: u8          //Number of active vectors

oldPoints: [16][2]u8            //Temporary storage for current shape points
blockColours: [16]rl.Color      //Temporary storage for current shape block colours

score: u32
level: u8 = 16

BASE_MOVEMENT_TIME :: f64(time.Second * 2)  //Starting time in ns between shape drops at level 1
LEVEL_MOVEMENT_MOD: f64 : 0.05  //Drop time modifier per level
lastMovementTime: time.Time     //Time at which last drop occurred

Direction :: enum {
    NONE,
    UP,
    DOWN,
    LEFT,
    RIGHT,
}

//Moves shape one block in desired direction, returns whether it was possible
moveShape :: proc(dir: Direction) -> bool {
    //Remove current shape from the board to simplify collision
    oldPoints = currentShapePoints

    for p in 0..<currentShapeLength {
        blockColours[p] = board[currentShapePoints[p].x][currentShapePoints[p].y]

        board[currentShapePoints[p].x][currentShapePoints[p].y] = 0
    }

    //Move shape if possible, else restore old shape points
    for p in 0..<currentShapeLength {
        switch dir {
        case .NONE:
        case .UP:
            currentShapePoints[p].y -= 1
        case .DOWN:
            currentShapePoints[p].y += 1
        case .LEFT:
            currentShapePoints[p].x -= 1
        case .RIGHT:
            currentShapePoints[p].x += 1
        }

        if currentShapePoints[p].x < 0 || currentShapePoints[p].x > 9 || currentShapePoints[p].y < 0 || currentShapePoints[p].y > 19 || board[currentShapePoints[p].x][currentShapePoints[p].y] != 0 {
            currentShapePoints = oldPoints
            
            break
        }
    }

    //Add current shape back to the board
    for p in 0..<currentShapeLength {
        board[currentShapePoints[p].x][currentShapePoints[p].y] = blockColours[p]
    }

    return currentShapePoints != oldPoints
}

spawnShape :: proc() {
    //Pop next queue shape and add a new one to the start of the queue
    currentShapeType = nextUpShapes[0]

    for i in 1..<len(nextUpShapes) {
        nextUpShapes[i - 1] = nextUpShapes[i]
    }

    nextUpShapes[len(nextUpShapes) - 1] = shapes[rand.int_max(len(shapes))]

    //Add the new shape to the game
    currentShapeLength = 0

    for x in 0..<len(currentShapeType.tiles) {
        for y in 0..<len(currentShapeType.tiles[0]) {
            //Skip blank spaces
            if currentShapeType.tiles[x][y] != 0 {
                //Add this block to the board
                board[3 + x][y] = currentShapeType.tiles[x][y]

                //Add block to currently controlled shape
                currentShapePoints[currentShapeLength] = {u8(3 + x), u8(y)}
                currentShapeLength += 1
            }
        }
    }
}

rotateShape :: proc() {

}

main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    fmt.println("****", TITLE, "****")

    rl.InitWindow(1280, 720, TITLE)
    defer rl.CloseWindow()

    rl.SetTargetFPS(60)

    //Fill next-up shape queue
    for &s in nextUpShapes {
        s = shapes[rand.int_max(len(shapes))]
    }

    //Set first controlled shape
    spawnShape()

    //Set initial time
    lastMovementTime = time.now()
    
    for !rl.WindowShouldClose() {
        //Get input
        if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
            moveShape(.DOWN)
        } else if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
            moveShape(.LEFT)
        } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
            moveShape(.RIGHT)
        } else if rl.IsKeyPressed(rl.KeyboardKey.SPACE) { //Drop shape
            for i in 0..<20 do moveShape(.DOWN)
        }
        
        if rl.IsKeyPressed(rl.KeyboardKey.LEFT_SHIFT) { //Rotate shape
            rotateShape()
        }

        //Check for downward movement
        if time.diff(lastMovementTime, time.now()) > time.Duration(BASE_MOVEMENT_TIME * (1 - (LEVEL_MOVEMENT_MOD * f64(level)))) {
            lastMovementTime = time.now()

            //If the shape cannot move down, let go of it and spawn a new shape at the top
            if !moveShape(.DOWN) do spawnShape()
        }

        //*** Rendering ***
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        //rl.DrawText("Hello World!", 100, 100, 20, rl.RED)

        //Board and stats
        rl.DrawRectangleLinesEx({396, 96, 308, 608}, 4, rl.GRAY)
        rl.DrawText(rl.TextFormat("Level: %d", level), 100, 100, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Score: %d", score), 100, 140, 20, rl.WHITE)

        //Shape queue
        

        //Blocks
        for x in 0..<len(board) {
            for y in 0..<len(board[0]){
                rl.DrawRectangle(i32(400 + (x * 30)), i32(100 + (y * 30)), 30, 30, board[x][y])
            }
        }

        if debugMode do rl.DrawFPS(0, 0)

        rl.EndDrawing()
    }
}
