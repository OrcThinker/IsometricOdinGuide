package main

import "core:fmt"
import "core:math"
import "core:slice"
import rl "vendor:raylib"

v2 :: struct {
    x,y: i32,
}

v3 :: struct {
    x,y,z: i32
}

v4 :: struct {
    x,y,z,w: i32
}

side :: enum {
    TOP,
    LEFT,
    RIGHT
}

editMode :: enum {
    SELECT,
    CREATE,
    DELETE
}

tileInfo :: struct {
    pos: v3,
    tileTextureNr: i32
}

tileSize:v2 = {64, 32}
levelHeight:i32 = 16
windowSize:v2 = {1024,860}
targetFps:i32= 60

main :: proc() {
    fmt.println("Programs starts here")
    game()
}

game :: proc() {
    rl.InitWindow(windowSize.x, windowSize.y, "iso guide pt. 1")
    rl.SetTargetFPS(targetFps)

    sinIter : i32 = 0

    defer rl.CloseWindow()
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground({34,34,34,255})
        // rl.ClearBackground({33,35,55,255})

        sinIter += 2


        mousePosText:cstring = fmt.ctprintf("MousePos: %v", rl.GetMousePosition())
        defer rl.DrawText(mousePosText, 20,20, 16, {255,255,255,255})

        //This is for z = 0
        //-tileSize.x/2 cuz origin of the tile is in the middle
        //We can either offset render by the origin or detection
        mouseTilePosition := ScreenToIsoCoord(f32(rl.GetMouseX() - tileSize.x/2), f32(rl.GetMouseY()), 0)
        isoMousePosText:cstring = fmt.ctprintf("MousePos Iso: %v", mouseTilePosition)
        defer rl.DrawText(isoMousePosText, 20,40, 16, {255,255,255,255})

        tileTexture: rl.Texture2D = rl.LoadTexture("./shortTilesOld.png")

        //Here we will draw tile on 19,4 tile
        // isoTilePosTopRight:= IsoCoordToScreen(19,3,0)
        // RenderTile(isoTilePosTopRight, tileTexture, 4)

        // isoTilePos := IsoCoordToScreen(19,4,0)
        // RenderTile(isoTilePos, tileTexture, 4, false, false)

        // sinScaled :f32 = f32(sinIter)/ f32(targetFps) * 5
        sinScaled :f32 = math.abs((f32(sinIter % 160)) - 80) / 16

        // maxValInt :i32= 36
        // minValInt :i32= 10
        // maxValInt :i32= 32
        // minValInt :i32= 12


        //Synced 2 waves
        // for x in i32(minValInt)..=i32(maxValInt) {
        //     for y in i32(0)..=5 {
        //         maxVal :f32= f32(maxValInt)
        //         minVal :f32= f32(minValInt)
        //         // heightVal := math.sin(f32(x) + sinScaled + f32(y) / 2)
        //         //Peaks in middle
        //         midVal :f32= (maxVal + minVal) / 2
        //         //To pi -> 0 In middle now -> on sides reaches diff in max and min / 2
        //         val : = math.abs(midVal - f32(x))
        //         //This one is PI on sides
        //         toSinVal := math.sin(math.PI * val / ((maxVal - minVal) / 2))

        //         loopTilePos := IsoCoordToScreen(x,4+y,-1* (toSinVal * sinScaled + 2))
        //         RenderTile(loopTilePos, tileTexture, 4, true, false)
        //     }
        //     for y in i32(0)..=5 {
        //         maxVal :f32= f32(maxValInt)
        //         minVal :f32= f32(minValInt)
        //         // heightVal := math.sin(f32(x) + sinScaled + f32(y) / 2)
        //         //Peaks in middle
        //         midVal :f32= (maxVal + minVal) / 2
        //         //To pi -> 0 In middle now -> on sides reaches diff in max and min / 2
        //         val : = math.abs(midVal - f32(x))
        //         //This one is PI on sides
        //         toSinVal := math.sin(math.PI * val / ((maxVal - minVal) / 2))

        //         loopTilePos := IsoCoordToScreen(x,4+y,(toSinVal * sinScaled) * math.abs(f32(y)-2) / 5)
        //         RenderTile(loopTilePos, tileTexture, 2, true, false)
        //     }
        // }

        maxValInt :i32= 32
        minValInt :i32= 12

        for x in i32(minValInt)..=i32(maxValInt) {
            for y in i32(0)..=5 {

                //PI * x/6 cuz sin repeats every PI when in abs
                //+ iter / 36 is just how fast it animates
                rippleSize :f32= 6
                animationSpeed := f32(sinIter) / 50
                toSinVal := math.sin(math.PI * f32(x) / rippleSize + animationSpeed)
                rippleHeight :f32 = 2

                loopTilePos := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight)
                loopTilePos2 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight + 4)
                loopTilePos3 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight + 8)
                loopTilePos4 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight + 12)
                loopTilePos5 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight + 16)
                loopTilePos6 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight - 4)
                loopTilePos7 := IsoCoordToScreen(x,4+y, toSinVal * rippleHeight - 8)
                RenderTile(loopTilePos, tileTexture, 4, true, false)
                RenderTile(loopTilePos2, tileTexture, 1, true, false)
                RenderTile(loopTilePos3, tileTexture, 3, true, false)
                RenderTile(loopTilePos4, tileTexture, 2, true, false)
                RenderTile(loopTilePos5, tileTexture, 4, true, false)
                RenderTile(loopTilePos6, tileTexture, 1, true, false)
                RenderTile(loopTilePos7, tileTexture, 3, true, false)
            }
        }


        defer
        {
            //This one has to be rewritten
            //Main line should be from top left to bottom right
            //Sec line should be same on X but flipped Y
            for x in i32(-100) ..=100 {
                lineStart1 := IsoCoordToScreen(-100,x,0)
                lineEnd1 := IsoCoordToScreen(100, x, 0)
                // rl.DrawLineEx({f32(lineStart1.x), f32(lineStart1.y + 16)}, {f32(lineEnd1.x), f32(lineEnd1.y + 16)},3, rl.PINK)
                // rl.DrawLineEx({f32(lineStart1.x), -1 * f32(lineStart1.y + 16)}, {f32(lineEnd1.x), -1 * f32(lineEnd1.y + 16)},3, rl.PINK)
            }
        }

        rl.EndDrawing()
    }
}

RenderTile :: proc (pos:v2, tileTexture:rl.Texture, textureNr: i32 = 1,
                    renderWithGrid:bool = true, highlighted: bool = false){
    tilePlacementInAtlas:v2 = {0, (tileSize.y + levelHeight) * textureNr}
    imageRect:rl.Rectangle = {f32(tilePlacementInAtlas.x), f32(tilePlacementInAtlas.y),
                              f32(tileSize.x), f32(tileSize.y + levelHeight)}
    color:rl.Color = highlighted ? rl.SKYBLUE : rl.WHITE
    rl.DrawTextureRec(tileTexture, imageRect, {f32(pos.x), f32(pos.y)}, color)
    if renderWithGrid {
        gridRectangle:rl.Rectangle = {0,0, f32(tileSize.x), f32(tileSize.y + levelHeight)}
        rl.DrawTextureRec(tileTexture, gridRectangle, {f32(pos.x), f32(pos.y)}, color)
    }
}

ScreenToIsoCoord :: proc (screenX, screenY: f32, z:int=0) -> v2 {
    //isoX := a / tilesize.x * 2 + isoY
    //isoY := b * 2 / tilesize.y + isoZ - isoX
    //isoX := a / tilesize.x * 2 + b * 2 / tilesize.y + isoZ - isoX
    isoX := (screenX / f32(tileSize.x) * 2 + screenY * 2 / f32(tileSize.y) + f32(z))/2
    isoY := screenY * 2 / f32(tileSize.y) + f32(z) - isoX
    return {i32(isoX), i32(isoY)}
}

IsoCoordToScreen :: proc(isoX,isoY: i32, isoZ: f32) -> v2 {
    x := (isoX - isoY) * tileSize.x/2
    y := (isoX + isoY) * tileSize.y/2 - i32(isoZ * f32(levelHeight))
    return {x,y}
}

//Change in X gives us +tileWidth/2 and +tileHeight/2
//Change in Y gives us -tileWidth/2 and +tileHeight/2
//So final
//x := isoX * tileWidth/2 - isoY * tileWidth/2 -> (isoX - isoY) * tileWidth/2
//y := (isoX + isoY) * tileWidth/2
//
//Now comes the Z value -> height in our world
//So change in Z changes y coord value by levelHeight
//y := (isoX + isoY) * tileWidth/2 + isoZ * levelHeight

//x := (isoX - isoY)* tileWidth/2
//x / tileWidth * 2 := isoX - isoY
//(x / tileWidth * 2) + isoY = isoX
//isoX := x / tilesize.x * 2 + isoY
//isoY := y * 2 / tilesize.y + isoZ - isoX
//isoX := x / tilesize.x * 2 + y * 2 / tilesize.y + isoZ - isoX
//
//Now lets use mouse over do see what tile we are on
