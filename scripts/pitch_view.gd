extends Control
class_name PitchView

var home_positions: Array[Vector2] = []
var away_positions: Array[Vector2] = []
var ball_position := Vector2(0.5, 0.5)
var home_color := Color("#f4f4f5")
var away_color := Color("#f97316")
var ball_color := Color("#fff8db")
var pulse := 0.0

func _ready() -> void:
    custom_minimum_size = Vector2(420, 250)
    mouse_filter = Control.MOUSE_FILTER_IGNORE
    _reset_positions()

func _process(delta: float) -> void:
    pulse += delta
    queue_redraw()

func _reset_positions() -> void:
    home_positions.clear()
    away_positions.clear()
    var rows := [Vector2(0.08, 0.50), Vector2(0.22, 0.25), Vector2(0.22, 0.50), Vector2(0.22, 0.75),
        Vector2(0.38, 0.18), Vector2(0.38, 0.39), Vector2(0.38, 0.61), Vector2(0.38, 0.82),
        Vector2(0.58, 0.32), Vector2(0.58, 0.68), Vector2(0.70, 0.50)]
    for p in rows:
        home_positions.append(p)
        away_positions.append(Vector2(1.0 - p.x, p.y))

func set_match_state(home: Array, away: Array, ball: Vector2) -> void:
    home_positions.clear()
    away_positions.clear()
    for p in home:
        home_positions.append(p)
    for p in away:
        away_positions.append(p)
    ball_position = ball
    queue_redraw()

func animate_event(seed_value: int) -> void:
    var rng := RandomNumberGenerator.new()
    rng.seed = seed_value
    var team_home := rng.randf() > 0.5
    var team_positions := home_positions if team_home else away_positions
    if team_positions.is_empty():
        _reset_positions()
        team_positions = home_positions
    var player_index := rng.randi_range(0, team_positions.size() - 1)
    var p: Vector2 = team_positions[player_index]
    p.x = clampf(p.x + rng.randf_range(-0.13, 0.13), 0.04, 0.96)
    p.y = clampf(p.y + rng.randf_range(-0.18, 0.18), 0.08, 0.92)
    team_positions[player_index] = p
    ball_position = p
    queue_redraw()

func _draw() -> void:
    var rect := Rect2(Vector2(8, 8), size - Vector2(16, 16))
    draw_rect(rect, Color("#176b3a"), true)
    var stripe_width := rect.size.x / 10.0
    for i in range(10):
        if i % 2 == 0:
            draw_rect(Rect2(rect.position.x + i * stripe_width, rect.position.y, stripe_width, rect.size.y), Color("#1b7541"), true)
    var line_color := Color(0.88, 0.96, 0.89, 0.88)
    draw_rect(rect, line_color, false, 2.0)
    var mid_x := rect.position.x + rect.size.x * 0.5
    draw_line(Vector2(mid_x, rect.position.y), Vector2(mid_x, rect.end.y), line_color, 2.0)
    draw_arc(Vector2(mid_x, rect.position.y + rect.size.y * 0.5), rect.size.y * 0.15, 0, TAU, 48, line_color, 2.0)
    draw_circle(Vector2(mid_x, rect.position.y + rect.size.y * 0.5), 3.5, line_color)
    var box_h := rect.size.y * 0.48
    var box_w := rect.size.x * 0.16
    draw_rect(Rect2(rect.position, Vector2(box_w, box_h)).grow_individual(0, (rect.size.y-box_h)/2, 0, (rect.size.y-box_h)/2), line_color, false, 2.0)
    draw_rect(Rect2(Vector2(rect.end.x-box_w, rect.position.y+(rect.size.y-box_h)/2), Vector2(box_w, box_h)), line_color, false, 2.0)
    draw_rect(Rect2(Vector2(rect.position.x, rect.position.y+rect.size.y*0.35), Vector2(rect.size.x*0.05, rect.size.y*0.30)), line_color, false, 2.0)
    draw_rect(Rect2(Vector2(rect.end.x-rect.size.x*0.05, rect.position.y+rect.size.y*0.35), Vector2(rect.size.x*0.05, rect.size.y*0.30)), line_color, false, 2.0)

    for i in range(home_positions.size()):
        _draw_player(home_positions[i], rect, home_color, str(i + 1))
    for i in range(away_positions.size()):
        _draw_player(away_positions[i], rect, away_color, str(i + 1))
    var bp := Vector2(rect.position.x + ball_position.x * rect.size.x, rect.position.y + ball_position.y * rect.size.y)
    draw_circle(bp, 7.0 + sin(pulse * 4.0) * 0.6, Color("#111827"))
    draw_circle(bp, 4.5, ball_color)

func _draw_player(normalized_pos: Vector2, rect: Rect2, color: Color, label: String) -> void:
    var p := Vector2(rect.position.x + normalized_pos.x * rect.size.x, rect.position.y + normalized_pos.y * rect.size.y)
    draw_circle(p, 10.0, Color("#10251a"))
    draw_circle(p, 8.0, color)
    draw_string(ThemeDB.fallback_font, p + Vector2(-3.5, 3.5), label, HORIZONTAL_ALIGNMENT_LEFT, -1, 9, Color("#111827"))
