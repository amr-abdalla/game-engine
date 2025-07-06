package main

import "vectors"
import "core:fmt"
import "vendor:sdl2"
import "vendor:sdl2/image"

//CONSTANTS
	ACCELERATION_RATE :: 20
	DECELERATION_RATE :: 10
    STARTING_POSITION_X :: 240
    STARTING_POSITION_Y :: 0

Player :: struct {
    pos : vectors.Vector2,
    vel : vectors.Vector2,
    acc : vectors.Vector2,
    tex : ^sdl2.Texture,
    draw_rect : sdl2.Rect,
}

player_init :: proc(renderer: ^sdl2.Renderer) -> Player {

    player_tex := image.LoadTexture(renderer, "../resources/basic-shrunk.png");
    if player_tex == nil {
        fmt.printf("Texture load failed: %s\n", sdl2.GetError());
        return Player{};
    }

    tex_w, tex_h: i32
    sdl2.QueryTexture(player_tex, nil, nil, &tex_w, &tex_h)

    scaled_w := i32(f32(tex_w) * PLAYER_SCALE)
    scaled_h := i32(f32(tex_h) * PLAYER_SCALE)

    return Player{
        pos  = vectors.Vector2{STARTING_POSITION_X,STARTING_POSITION_Y},
        vel  = vectors.Vector2{},
        acc  = vectors.Vector2{},
        tex  = player_tex,
        draw_rect = sdl2.Rect{STARTING_POSITION_X, STARTING_POSITION_Y, scaled_w, scaled_h},
    };
}

player_update :: proc(p: ^Player, delta_time_ms: f64, input_x: i32, input_y: i32) {
    delta_time_in_seconds := delta_time_ms * 0.001;
    input := vectors.Vector2{f64(input_x), f64(input_y)};

    if input_x != 0 || input_y != 0 
    {
        p.acc = vectors.multiply(input, ACCELERATION_RATE);
    }
    else if p.vel.x != 0 && p.vel.y != 0
    {
        decelerate(p);
    }
    else
    {
        p.acc = vectors.Vector2{};
    }

    p.vel = vectors.sum(p.vel, vectors.multiply(p.acc, delta_time_in_seconds));
    p.pos = vectors.sum(p.pos, vectors.multiply(p.vel, delta_time_in_seconds));

    p.draw_rect.x = i32(p.pos.x);
    p.draw_rect.y = i32(p.pos.y);
}

decelerate :: proc(p: ^Player) {
    p.acc.x = - DECELERATION_RATE if p.vel.x > 0 else DECELERATION_RATE
    p.acc.y = - DECELERATION_RATE if p.vel.y > 0 else DECELERATION_RATE 
}


player_draw :: proc(p: ^Player, renderer: ^sdl2.Renderer) {
    sdl2.RenderCopy(renderer, p.tex, nil, &p.draw_rect);
}
