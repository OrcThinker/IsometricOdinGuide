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
    tileTexture: rl.Texture2D = rl.LoadTexture("./shortTilesOld.png")
    for !rl.WindowShouldClose(){
        rl.BeginDrawing()
        rl.ClearBackground({34,34,34,255})

        sinIter += 1

        mousePosText:cstring = fmt.ctprintf("MousePos: %v", rl.GetMousePosition())
        defer rl.DrawText(mousePosText, 20,20, 16, {255,255,255,255})

        //This is for z = 0
        //-tileSize.x/2 cuz origin of the tile is in the middle
        //We can either offset render by the origin or detection
        mouseTilePosition := ScreenToIsoCoord(f32(rl.GetMouseX() - tileSize.x/2), f32(rl.GetMouseY()), 0)
        isoMousePosText:cstring = fmt.ctprintf("MousePos Iso: %v", mouseTilePosition)
        defer rl.DrawText(isoMousePosText, 20,40, 16, {255,255,255,255})
        sinScaled :f32 = math.abs((f32(sinIter % 160)) - 80) / 16

        maxValInt :i32= 32
        minValInt :i32= 12

        for x in i32(minValInt)..=i32(maxValInt) {
            for y in i32(0)..=5 {

                //PI * x/6 cuz sin repeats every PI when in abs
                //+ iter / 36 is just how fast it animates
                rippleSize :f32= 6
                animationSpeed := f32(sinIter) / 25
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
    isoX := (screenX / f32(tileSize.x) * 2 + screenY * 2 / f32(tileSize.y) + f32(z))/2
    isoY := screenY * 2 / f32(tileSize.y) + f32(z) - isoX
    return {i32(isoX), i32(isoY)}
}

IsoCoordToScreen :: proc(isoX,isoY: i32, isoZ: f32) -> v2 {
    x := (isoX - isoY) * tileSize.x/2
    y := (isoX + isoY) * tileSize.y/2 - i32(isoZ * f32(levelHeight))
    return {x,y}
}
