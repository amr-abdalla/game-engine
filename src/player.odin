package main

import "vectors"
import "core:fmt"
import "vendor:sdl2"
import "vendor:sdl2/image"

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
        pos  = vectors.Vector2{240,0},
        vel  = vectors.Vector2{}, // zero
        acc  = vectors.Vector2{-10,0},
        tex  = player_tex,
        draw_rect = sdl2.Rect{240, 0, scaled_w, scaled_h},
    };
}

player_update :: proc(p: ^Player, delta_time_ms: f64) {
    delta_time_in_seconds := delta_time_ms * 0.001;

    p.vel = vectors.sum(p.vel, vectors.multiply(p.acc, delta_time_in_seconds));
    p.pos = vectors.sum(p.pos, vectors.multiply(p.vel, delta_time_in_seconds));

    p.draw_rect.x = i32(p.pos.x);
    p.draw_rect.y = i32(p.pos.y);
}

player_draw :: proc(p: ^Player, renderer: ^sdl2.Renderer) {
    sdl2.RenderCopy(renderer, p.tex, nil, &p.draw_rect);
}
