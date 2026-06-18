package main

import "core:fmt"
import ray "vendor:raylib"

main :: proc() {
    fmt.println("hellow orld!")

    screen_width :: 800
    screen_height :: 450
    game_title :: "brok3"

    ray.InitWindow(screen_width, screen_height, game_title)
    ray.SetTargetFPS(60)

    player_rect_width: i32 = 100
    player_rect_height: i32 = 20
    player_rect_pos_x: f32 = (screen_width / 2)
    player_rect_pos_y: f32 = (screen_height - 48)
    player_speed_max: f32 = 200
    player_speed_acceleration: f32 = 10
    player_speed_current: f32

    projectile_radius: f32 = 8
    projectile_pos_x, projectile_pos_y: f32 = (screen_width / 2), (screen_height / 2)
    projectile_speed_current_x: f32
    projectile_speed_current_y: f32 = 50

    // TODO: fix y collision when projectile is below the bar
    // TODO: add bricks

    for !ray.WindowShouldClose() {
        delta_time: f32 = ray.GetFrameTime()

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

        player_rect_pos_x += player_speed_current * delta_time

        projectile_pos_y += projectile_speed_current_y * delta_time
        projectile_pos_x += projectile_speed_current_x * delta_time
        if projectile_pos_y <= 0 {
            if projectile_speed_current_y < 0 {
                projectile_speed_current_y *= -1
            }
        } else if projectile_pos_x >= player_rect_pos_x &&
            projectile_pos_x <= player_rect_pos_x + cast(f32)player_rect_width &&
            projectile_pos_y >= player_rect_pos_y {
            if projectile_speed_current_y > 0 {
                projectile_speed_current_y *= -1
                projectile_speed_current_x = player_speed_current
            }
        }
        if projectile_pos_x <= 0 && projectile_speed_current_x < 0 {
            projectile_speed_current_x *= -1
        } else if projectile_pos_x >= screen_width && projectile_speed_current_x > 0 {
            projectile_speed_current_x *= -1
        }

        ray.BeginDrawing()
        ray.ClearBackground(ray.RAYWHITE)

        ray.DrawText(
            "Congrats! You created your first window!",
            190, 200, 20, ray.LIGHTGRAY)

        ray.DrawRectangle(
            cast(i32)player_rect_pos_x, cast(i32)player_rect_pos_y,
            player_rect_width, player_rect_height,
            ray.RED)
        ray.DrawCircle(
            cast(i32)player_rect_pos_x, cast(i32)player_rect_pos_y,
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
