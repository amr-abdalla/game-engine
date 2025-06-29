package main

//IMPORTS
	import "core:fmt"
	import "vendor:sdl2"
	import "vendor:sdl2/image"
	import "core:sys/windows"
	import "core:time"

//CONSTANTS
	TARGET_FRAMERATE :: 60
	TARGET_DELTA_TIME :: 1./f64(TARGET_FRAMERATE)*1000.
	NATIVE_WIDTH :: 480
	NATIVE_HEIGHT :: 270
	WINDOW_SCALE :: 2

//Time proc
	time_get :: proc() -> f64{ 
		return f64(sdl2.GetPerformanceCounter())*1000/f64(sdl2.GetPerformanceFrequency())
	}

Game :: struct {
    window         : ^sdl2.Window,
    renderer       : ^sdl2.Renderer,
    target_texture : ^sdl2.Texture,
    player_texture : ^sdl2.Texture,
    draw_rect      : sdl2.Rect,
    quit           : bool,
	frame		   : i32,
}

init :: proc() -> Game {
    // ── SDL & image ──────────────────────────────
    sdl2.SetHint(sdl2.HINT_RENDER_SCALE_QUALITY, "0");
    if sdl2.Init(sdl2.INIT_VIDEO | sdl2.INIT_JOYSTICK) < 0 {
        fmt.printf("SDL init failed: %s\n", sdl2.GetError());
        return Game{}; // empty struct signals failure
    }
    image.Init(image.INIT_PNG);

    // ── window + renderer ─────────────────────────
    window   := sdl2.CreateWindow("Test App",
                                  sdl2.WINDOWPOS_CENTERED,
                                  sdl2.WINDOWPOS_CENTERED,
                                  NATIVE_WIDTH*WINDOW_SCALE,
                                  NATIVE_HEIGHT*WINDOW_SCALE,
                                  sdl2.WINDOW_SHOWN);
    renderer := sdl2.CreateRenderer(window, -1, sdl2.RENDERER_ACCELERATED);

    // ── render-to-texture target ──────────────────
    target := sdl2.CreateTexture(renderer,
                                 sdl2.PixelFormatEnum.RGBA8888,
                                 sdl2.TextureAccess.TARGET,
                                 NATIVE_WIDTH, NATIVE_HEIGHT);

    // ── sprite texture ────────────────────────────
    player := image.LoadTexture(renderer, "../resources/basic.png");
    if player == nil {
        fmt.printf("Texture load failed: %s\n", sdl2.GetError());
        return Game{};
    }

    rect := sdl2.Rect{20, 120, 0, 0};
    sdl2.QueryTexture(player, nil, nil, &rect.w, &rect.h);

    return Game{
        window, renderer,
        target, player,
        rect, false, 0
    };
}

update :: proc(game: ^Game) {
    frame_start := time_get();

    // ── events ───────────────────────────
    ev : sdl2.Event;
    for sdl2.PollEvent(&ev) {
        #partial switch ev.type {
            case .QUIT: game.quit = true;
        }
    }

    // ── input ────────────────────────────
    keys := sdl2.GetKeyboardState(nil);
    game.draw_rect.x += 7 * (i32(keys[sdl2.SCANCODE_RIGHT]) -
                              i32(keys[sdl2.SCANCODE_LEFT]));
    game.draw_rect.y += 7 * (i32(keys[sdl2.SCANCODE_DOWN]) -
                              i32(keys[sdl2.SCANCODE_UP]));

    // ── render pass on target texture ────
    sdl2.SetRenderDrawColor(game.renderer, 0xBD, 0xE3, 255, 255);
    sdl2.SetRenderTarget(game.renderer, game.target_texture);
    sdl2.RenderClear(game.renderer);
    sdl2.RenderCopy(game.renderer, game.player_texture, nil,
                    &game.draw_rect);

    // ── present to window ────────────────
    sdl2.SetRenderTarget(game.renderer, nil);
    sdl2.RenderCopy(game.renderer, game.target_texture, nil, nil);
    sdl2.RenderPresent(game.renderer);

    // ── frame cap ────────────────────────
    windows.timeBeginPeriod(1);
    wait := TARGET_DELTA_TIME - (time_get() - frame_start);
    if wait > 0 {
        time.accurate_sleep(time.Duration(wait * 1_000_000));
    }
    windows.timeEndPeriod(1);
}

shutdown :: proc(game: ^Game) {
    if game.player_texture != nil  do sdl2.DestroyTexture(game.player_texture);
    if game.target_texture != nil  do sdl2.DestroyTexture(game.target_texture);
    if game.renderer       != nil  do sdl2.DestroyRenderer(game.renderer);
    if game.window         != nil  do sdl2.DestroyWindow(game.window);
    sdl2.Quit();
}

main :: proc() {
    game := init();
    if game.window == nil { // init failed
        return;
    }
    defer shutdown(&game);

    for !game.quit {
        update(&game);
		game.frame += 1
    }
}
