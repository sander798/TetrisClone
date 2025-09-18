package tetrisClone

import "core:fmt"
import "core:log"
import "core:time"
import "core:math/rand"
import rl "vendor:raylib"

TITLE :: "TetrisClone"

debugMode := true

Shape :: struct {
    tiles1: [4][4]rl.Color,
    tiles2: [4][4]rl.Color,
    tiles3: [4][4]rl.Color,
    tiles4: [4][4]rl.Color,
}

/*
templateShape := Shape {
    tiles1 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}},
    tiles2 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}},
    tiles4 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}, {0, 0, 0, 0}},
}
*/

lineShape := Shape {
    tiles1 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {rl.GREEN, rl.GREEN, rl.GREEN, rl.GREEN}, {0, 0, 0, 0}},
    tiles2 = {{rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {0, 0, 0, 0}, {rl.GREEN, rl.GREEN, rl.GREEN, rl.GREEN}, {0, 0, 0, 0}},
    tiles4 = {{rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}, {rl.GREEN, 0, 0, 0}},
}

cornerRightShape := Shape {
    tiles1 = {{0, 0, 0, 0}, {rl.RED, rl.RED, rl.RED, 0}, {0, 0, rl.RED, 0}, {0, 0, 0, 0}},
    tiles2 = {{rl.RED, rl.RED, 0, 0}, {rl.RED, 0, 0, 0}, {rl.RED, 0, 0, 0}, {0, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {0, rl.RED, 0, 0}, {0, rl.RED, rl.RED, rl.RED}, {0, 0, 0, 0}},
    tiles4 = {{0, rl.RED, 0, 0}, {0, rl.RED, 0, 0}, {rl.RED, rl.RED, 0, 0}, {0, 0, 0, 0}},
}

cornerLeftShape := Shape {
    tiles1 = {{0, 0, 0, 0}, {0, 0, rl.ORANGE, 0}, {rl.ORANGE, rl.ORANGE, rl.ORANGE, 0}, {0, 0, 0, 0}},
    tiles2 = {{rl.ORANGE, rl.ORANGE, 0, 0}, {0, rl.ORANGE, 0, 0}, {0, rl.ORANGE, 0, 0}, {0, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {rl.ORANGE, rl.ORANGE, rl.ORANGE, 0}, {rl.ORANGE, 0, 0, 0}, {0, 0, 0, 0}},
    tiles4 = {{rl.ORANGE, 0, 0, 0}, {rl.ORANGE, 0, 0, 0}, {rl.ORANGE, rl.ORANGE, 0, 0}, {0, 0, 0, 0}},
}

squareShape := Shape {
    tiles1 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
    tiles2 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
    tiles4 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
}

zedShape := Shape {
    tiles1 = {{rl.PURPLE, rl.PURPLE, 0, 0}, {0, rl.PURPLE, 0, 0}, {0, rl.PURPLE, rl.PURPLE, 0}, {0, 0, 0, 0}},
    tiles2 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
    tiles3 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
    tiles4 = {{0, 0, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {rl.BLUE, rl.BLUE, 0, 0}, {0, 0, 0, 0}},
}

shapes: []Shape = {lineShape, cornerRightShape, cornerLeftShape, squareShape}

board: [10][20]rl.Color = {}    //Game board

nextUpShapes: [4]Shape          //Upcoming shapes list

currentShapeType: Shape
currentShapePoints: [16][2]u8   //Currently controlled shape (vector positions for each block)
currentShapeLength: u8          //Number of active vectors
currentShapeX, currentShapeY: int//Current relative position of the current shape
currentShapeRotation: u8

oldPoints: [16][2]u8            //Temporary storage for current shape points
blockColours: [16]rl.Color      //Temporary storage for current shape block colours
rowsRemoved: u32                //Temporary count of rows removed in a scoring check

score: u32
level: u32 = 1
gameOver := false

BASE_ROW_SCORE: u32 : 10
BASE_LEVEL_SCORE: u32 : 100 

BASE_MOVEMENT_TIME :: f64(time.Second * 2)  //Starting time in ns between shape drops at level 1
LEVEL_MOVEMENT_MOD: f64 : 0.10  //Drop time modifier per level
lastMovementTime: time.Time     //Time at which last drop occurred

Direction :: enum {
    UP,
    DOWN,
    LEFT,
    RIGHT,
}

//Moves shape one block in desired direction, returns whether it was possible
moveShape :: proc(dir: Direction) -> bool {
    //Remove current shape from the board to simplify collision
    oldPoints = currentShapePoints
    tempX, tempY := currentShapeX, currentShapeY

    for p in 0..<currentShapeLength {
        blockColours[p] = board[currentShapePoints[p].x][currentShapePoints[p].y]

        board[currentShapePoints[p].x][currentShapePoints[p].y] = 0
    }

    switch dir {
    case .UP:
        currentShapeY -= 1
    case .DOWN:
        currentShapeY += 1
    case .LEFT:
        currentShapeX -= 1
    case .RIGHT:
        currentShapeX += 1
    }

    //Ensure coords do not result in out-of-bounds when rotating
    if currentShapeX < 0 do currentShapeX = 0
    if currentShapeX > 6 do currentShapeX = 6
    if currentShapeY < 0 do currentShapeY = 0
    if currentShapeY > 16 do currentShapeY = 16

    //Move shape if possible, else restore old shape points
    for p in 0..<currentShapeLength {
        switch dir {
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
            currentShapeX, currentShapeY = tempX, tempY
            
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

    for x in 0..<len(currentShapeType.tiles1) {
        for y in 0..<len(currentShapeType.tiles1[0]) {
            //Skip blank spaces
            if currentShapeType.tiles1[x][y] != 0 {
                //Check if there is no room to spawn
                if board[3 + x][y] != 0 {
                    gameOver = true
                    return
                }

                //Add this block to the board
                board[3 + x][y] = currentShapeType.tiles1[x][y]

                //Add block to currently controlled shape
                currentShapePoints[currentShapeLength] = {u8(3 + x), u8(y)}
                currentShapeLength += 1
            }
        }
    }

    currentShapeX, currentShapeY = 3, 0
    currentShapeRotation = 0
}

//Rotates shape in desired direction, returns whether it was possible
rotateShape :: proc(clockwise: bool) -> bool {
    //Get new rotated form
    tempRotation := currentShapeRotation
    newForm: ^[4][4]rl.Color

    if clockwise {
        currentShapeRotation += 1

        if currentShapeRotation > 3 do currentShapeRotation = 0
    } else {
        currentShapeRotation -= 1

        if currentShapeRotation < 0 do currentShapeRotation = 3
    }

    switch currentShapeRotation {
        case 0:
            newForm = &currentShapeType.tiles1
        case 1:
            newForm = &currentShapeType.tiles2
        case 2:
            newForm = &currentShapeType.tiles3
        case 3:
            newForm = &currentShapeType.tiles4
    }

    //Remove old shape
    for p in 0..<currentShapeLength {
        board[currentShapePoints[p].x][currentShapePoints[p].y] = 0
    }

    //Check if the new form can be added to the board
    outer: for x in 0..<len(currentShapeType.tiles1) {
        for y in 0..<len(currentShapeType.tiles1[0]) {
            //Skip blank spaces
            if newForm^[x][y] != 0 {
                //If there is no room to spawn, set the shape back to previous values
                if board[currentShapeX + x][currentShapeY + y] != 0 {
                    //TODO: force check at different coords
                    currentShapeRotation = tempRotation
                    
                    switch currentShapeRotation {
                    case 0:
                        newForm = &currentShapeType.tiles1
                    case 1:
                        newForm = &currentShapeType.tiles2
                    case 2:
                        newForm = &currentShapeType.tiles3
                    case 3:
                        newForm = &currentShapeType.tiles4
                    }

                    break outer
                }
            }
        }
    }

    //Add new shape form to the board
    currentShapeLength = 0

    for x in 0..<len(currentShapeType.tiles1) {
        for y in 0..<len(currentShapeType.tiles1[0]) {
            //Skip blank spaces
            if newForm^[x][y] != 0 {
                //Add this block to the board
                board[currentShapeX + x][currentShapeY + y] = newForm^[x][y]

                //Add block to currently controlled shape
                currentShapePoints[currentShapeLength] = {u8(currentShapeX + x), u8(currentShapeY + y)}
                currentShapeLength += 1
            }
        }
    }

    return true
}

main :: proc() {
    context.logger = log.create_console_logger()
    defer log.destroy_console_logger(context.logger)

    fmt.println("****", TITLE, "****")

    rl.InitWindow(720, 720, TITLE)
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
        if !gameOver {
            //Get input
            if rl.IsKeyPressed(rl.KeyboardKey.DOWN) {
                moveShape(.DOWN)
            } else if rl.IsKeyPressed(rl.KeyboardKey.LEFT) {
                moveShape(.LEFT)
            } else if rl.IsKeyPressed(rl.KeyboardKey.RIGHT) {
                moveShape(.RIGHT)
            } else if rl.IsKeyPressed(rl.KeyboardKey.SPACE) { //Drop shape
                for i in 0..<20 do moveShape(.DOWN)
                lastMovementTime._nsec -= 10000000000
            }
            
            if rl.IsKeyPressed(rl.KeyboardKey.LEFT_SHIFT) { //Rotate shape
                rotateShape(true)
            }

            //Check for downward movement
            if time.diff(lastMovementTime, time.now()) > time.Duration(BASE_MOVEMENT_TIME * (1 - (LEVEL_MOVEMENT_MOD * f64(level)))) {
                lastMovementTime = time.now()

                //If the shape cannot move down, let go of it and spawn a new shape at the top
                if !moveShape(.DOWN) {
                    //Score & remove complete rows
                    rowsRemoved = 0

                    loop: for y: u8 = len(board[0]) - 1; y > 0; y -= 1 {
                        //Check if row is full
                        for x in 0..<len(board) {
                            if board[x][y] == 0 do continue loop
                        }

                        //Move everything above down one row
                        for row: u8 = y; row > 0; row -= 1 {
                            for col in 0..<len(board) {
                                board[col][row] = board[col][row - 1]
                            }
                        }

                        rowsRemoved += 1

                        y += 1 //Redo this line's check in case of multiple rows needing removal
                    }

                    score += BASE_ROW_SCORE * rowsRemoved

                    if score >= BASE_LEVEL_SCORE * level do level += 1

                    spawnShape()
                }
            }     
        }   

        //*** Rendering ***
        rl.BeginDrawing()

        rl.ClearBackground(rl.BLACK)

        //rl.DrawText("Hello World!", 100, 100, 20, rl.RED)

        //Board and stats
        rl.DrawRectangleLinesEx({296, 96, 308, 608}, 4, rl.GRAY)
        rl.DrawText(rl.TextFormat("Level: %d", level), 10, 100, 20, rl.WHITE)
        rl.DrawText(rl.TextFormat("Score: %d", score), 10, 140, 20, rl.WHITE)
        if gameOver do rl.DrawText("GAME OVER", 10, 180, 30, rl.YELLOW)

        //Shape queue
        

        //Blocks
        for x in 0..<len(board) {
            for y in 0..<len(board[0]){
                rl.DrawRectangle(i32(300 + (x * 30)), i32(100 + (y * 30)), 30, 30, board[x][y])
            }
        }

        if debugMode {
            rl.DrawFPS(0, 0)
            rl.DrawText(rl.TextFormat("%d, %d", currentShapeX, currentShapeY), 0, 30, 20, rl.WHITE)
        }

        rl.EndDrawing()
    }
}
