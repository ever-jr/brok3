package main

import "core:fmt"
import ray "vendor:raylib"

rectangle :: struct {
    x: f32,
    y: f32,
    w: f32,
    h: f32,
    color: ray.Color,
}

brick :: struct {
    rect: rectangle,
    is_destroyed: bool,
}

is_point_inside_rect :: proc(point_x: f32, point_y: f32, r: ^rectangle) -> bool {
    return point_x >= r.x &&
        point_x <= r.x + r.w &&
        point_y >= r.y &&
        point_y <= r.y + r.h
}

rect_draw :: proc(r: ^rectangle) {
    ray.DrawRectangle(
        cast(i32)r.x, cast(i32)r.y,
        cast(i32)r.w, cast(i32)r.h,
        r.color)
}

main :: proc() {
    fmt.println("hellow orld!")

    screen_width :: 800
    screen_height :: 450
    game_title :: "brok3"

    ray.InitWindow(screen_width, screen_height, game_title)
    ray.SetTargetFPS(60)

    player_rect: rectangle = {
        x = (screen_width / 2),
        y = (screen_height - 48),
        w = 100,
        h = 20,
        color = ray.RED,
    }
    player_speed_max: f32 = 200
    player_speed_acceleration: f32 = 10
    player_speed_current: f32

    projectile_radius: f32 = 8
    projectile_pos_x, projectile_pos_y: f32 = (screen_width / 2), (screen_height / 2)
    projectile_speed_current_x: f32
    projectile_speed_current_y: f32 = 100
    projectile_is_destroyed: bool = false

    b_width: f32 : 50
    b_height: f32 : 20
    b_padding: f32 : 24
    bricks := [30]brick{}
    for i in 0..<len(bricks) {
        b := &bricks[i]
        b_possible_x: f32 = 48 + (cast(f32)i * (b_width + b_padding))
        row_idx := cast(i32)(b_possible_x / screen_width)
        if row_idx <= 0 {
            b.rect.x = b_possible_x
        } else {
            b.rect.x = b_possible_x / (cast(f32)row_idx + 1)
        }
        fmt.printf("%d = %f | %d | %f\n", i, b_possible_x, row_idx, b.rect.x)
        b.rect.y = 48 + cast(f32)row_idx * b_height
        b.rect.w = b_width
        b.rect.h = b_height
        b.rect.color = ray.GREEN
    }

    // TODO: add bricks

    for !ray.WindowShouldClose() {
        delta_time: f32 = ray.GetFrameTime()

        if projectile_is_destroyed {
            projectile_pos_x, projectile_pos_y = (screen_width / 2), (screen_height / 2)
            projectile_speed_current_x = 0
            projectile_speed_current_y = 100
            projectile_is_destroyed = false
        }

        player_x_dir: f32
        if ray.IsKeyDown(ray.KeyboardKey.A) {
            player_x_dir -= 1
        }
        if ray.IsKeyDown(ray.KeyboardKey.D) {
            player_x_dir += 1
        }

        if player_x_dir != 0 {
            player_speed_current += player_speed_acceleration * player_x_dir
            if player_speed_current > player_speed_max {
                player_speed_current = player_speed_max
            } else if player_speed_current < -player_speed_max {
                player_speed_current = -player_speed_max
            }
        } else {
            if player_speed_current > 0 {
                player_speed_current -= player_speed_acceleration
                if player_speed_current < 0 {
                    player_speed_current = 0
                }
            } else if player_speed_current < 0 {
                player_speed_current += player_speed_acceleration
                if player_speed_current > 0 {
                    player_speed_current = 0
                }
            }
        }

        player_rect.x += player_speed_current * delta_time

        projectile_pos_y += projectile_speed_current_y * delta_time
        projectile_pos_x += projectile_speed_current_x * delta_time
        if projectile_pos_y <= 0 {
            if projectile_speed_current_y < 0 {
                projectile_speed_current_y *= -1
            }
        } else if is_point_inside_rect(projectile_pos_x, projectile_pos_y, &player_rect) {
            if projectile_speed_current_y > 0 {
                projectile_speed_current_y *= -1
                projectile_speed_current_x = player_speed_current
            }
        } else if projectile_pos_y > screen_height {
            projectile_is_destroyed = true
        }
        if projectile_pos_x - (projectile_radius / 2) <= 0 && projectile_speed_current_x < 0 {
            projectile_speed_current_x *= -1
        } else if projectile_pos_x + (projectile_radius / 2) >= screen_width && projectile_speed_current_x > 0 {
            projectile_speed_current_x *= -1
        }

        for i in 0..<len(bricks) {
            b := &bricks[i]
            if !b.is_destroyed && is_point_inside_rect(projectile_pos_x, projectile_pos_y, &b.rect) {
                b.is_destroyed = true
                projectile_speed_current_y *= -1.5
            }
        }

        ray.BeginDrawing()
        ray.ClearBackground(ray.RAYWHITE)

        ray.DrawText(
            "Congrats! You created your first window!",
            190, 200, 20, ray.LIGHTGRAY)

        for i in 0..<len(bricks) {
            b := &bricks[i]
            if !b.is_destroyed {
                rect_draw(&b.rect)
            }
        }

        rect_draw(&player_rect)
        ray.DrawCircle(
            cast(i32)player_rect.x, cast(i32)player_rect.y,
            5,
            ray.YELLOW)

        ray.DrawCircle(
            cast(i32)projectile_pos_x, cast(i32)projectile_pos_y,
            projectile_radius,
            ray.BLUE)

        ray.EndDrawing()
    }

    ray.CloseWindow()
}
