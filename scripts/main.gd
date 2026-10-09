extends Control

const PitchViewScript = preload("res://scripts/pitch_view.gd")

var screen: String = "home"
var match_minute: int = 0
var home_goals: int = 0
var away_goals: int = 0
var home_team := "Rivergate FC"
var away_team := "Northbridge United"
var is_playing := false
var speed_multiplier := 1.0
var event_timer := 0.0
var rng := RandomNumberGenerator.new()
var event_lines: Array[String] = []
var pitch: PitchView
var timer_label: Label
var score_label: Label
var status_label: Label
var events_box: RichTextLabel
var content: VBoxContainer
var topbar: HBoxContainer
var root_box: VBoxContainer

func _ready() -> void:
    rng.randomize()
    _build_shell()
    _show_home()

func _build_shell() -> void:
    set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    var bg := ColorRect.new()
    bg.color = Color("#101923")
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter = Control.MOUSE_FILTER_IGNORE
    add_child(bg)

    root_box = VBoxContainer.new()
    root_box.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    root_box.add_theme_constant_override("separation", 0)
    add_child(root_box)

    topbar = HBoxContainer.new()
    topbar.custom_minimum_size.y = 62
    topbar.add_theme_constant_override("separation", 14)
    topbar.add_theme_constant_override("margin_left", 20)
    topbar.add_theme_constant_override("margin_right", 20)
    topbar.add_theme_constant_override("margin_top", 10)
    topbar.add_theme_constant_override("margin_bottom", 10)
    root_box.add_child(topbar)

    var brand := Label.new()
    brand.text = "⚽ FOOTBALL LEGACY"
    brand.add_theme_font_size_override("font_size", 23)
    brand.add_theme_color_override("font_color", Color("#f8fafc"))
    brand.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    topbar.add_child(brand)

    var offline := Label.new()
    offline.text = "OFFLINE PROTOTYPE"
    offline.add_theme_color_override("font_color", Color("#7dd3a7"))
    offline.add_theme_font_size_override("font_size", 12)
    topbar.add_child(offline)

    var line := ColorRect.new()
    line.custom_minimum_size.y = 1
    line.color = Color("#2c3b49")
    root_box.add_child(line)

    content = VBoxContainer.new()
    content.size_flags_vertical = Control.SIZE_EXPAND_FILL
    content.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    content.add_theme_constant_override("separation", 12)
    content.add_theme_constant_override("margin_left", 22)
    content.add_theme_constant_override("margin_right", 22)
    content.add_theme_constant_override("margin_top", 18)
    content.add_theme_constant_override("margin_bottom", 18)
    root_box.add_child(content)

func _clear_content() -> void:
    for child in content.get_children():
        child.queue_free()

func _show_home() -> void:
    screen = "home"
    is_playing = false
    _clear_content()
    var title := Label.new()
    title.text = "ابنِ إرثك في عالم كرة القدم"
    title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    title.add_theme_font_size_override("font_size", 30)
    title.add_theme_color_override("font_color", Color("#f8fafc"))
    content.add_child(title)

    var subtitle := Label.new()
    subtitle.text = "نموذج أولي: إدارة نادٍ ومحاكاة مباراة — يعمل دون إنترنت"
    subtitle.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    subtitle.add_theme_color_override("font_color", Color("#a9b8c6"))
    subtitle.add_theme_font_size_override("font_size", 16)
    content.add_child(subtitle)

    var spacer := Control.new()
    spacer.custom_minimum_size.y = 10
    content.add_child(spacer)

    var club_card := _make_card()
    content.add_child(club_card)
    var club_title := Label.new()
    club_title.text = "مسيرتك الأولى"
    club_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    club_title.add_theme_font_size_override("font_size", 22)
    club_card.add_child(club_title)
    var club_desc := Label.new()
    club_desc.text = "Rivergate FC  •  دوري تجريبي  •  موسم 2026/27"
    club_desc.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    club_desc.add_theme_color_override("font_color", Color("#a9b8c6"))
    club_card.add_child(club_desc)

    var start := _make_button("ابدأ مباراة تجريبية", Color("#22c55e"))
    start.pressed.connect(_start_match)
    club_card.add_child(start)

    var features := GridContainer.new()
    features.columns = 2
    features.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    features.add_theme_constant_override("h_separation", 12)
    features.add_theme_constant_override("v_separation", 12)
    content.add_child(features)
    for item in [
        ["إدارة النادي", "التشكيلة والتكتيك والميزانية"],
        ["مسيرة اللاعب", "أكاديمية الناشئين والتطور — لاحقًا"],
        ["مسيرة المدرب", "التنقل بين الأندية — لاحقًا"],
        ["المنتخبات", "البطولات الدولية — لاحقًا"]
    ]:
        var card := _make_card()
        card.custom_minimum_size = Vector2(0, 78)
        features.add_child(card)
        var h := Label.new()
        h.text = item[0]
        h.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        h.add_theme_color_override("font_color", Color("#f8fafc"))
        h.add_theme_font_size_override("font_size", 17)
        card.add_child(h)
        var d := Label.new()
        d.text = item[1]
        d.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
        d.add_theme_color_override("font_color", Color("#a9b8c6"))
        d.add_theme_font_size_override("font_size", 12)
        card.add_child(d)

    var note := Label.new()
    note.text = "هذه نسخة اختبارية أولية وليست لعبة مكتملة. النتائج والبيانات تجريبية."
    note.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    note.add_theme_color_override("font_color", Color("#fbbf24"))
    note.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
    content.add_child(note)

func _start_match() -> void:
    screen = "match"
    match_minute = 0
    home_goals = 0
    away_goals = 0
    is_playing = false
    event_timer = 0.0
    event_lines.clear()
    _clear_content()

    var heading := HBoxContainer.new()
    content.add_child(heading)
    var back := _make_button("← القائمة", Color("#334155"))
    back.pressed.connect(_show_home)
    heading.add_child(back)
    var match_title := Label.new()
    match_title.text = "مباراة الدوري التجريبية"
    match_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    match_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    match_title.add_theme_font_size_override("font_size", 21)
    heading.add_child(match_title)

    var scoreboard := _make_card()
    content.add_child(scoreboard)
    var teams := HBoxContainer.new()
    scoreboard.add_child(teams)
    var home := Label.new()
    home.text = home_team
    home.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    home.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    home.add_theme_font_size_override("font_size", 17)
    teams.add_child(home)
    score_label = Label.new()
    score_label.text = "0  —  0"
    score_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    score_label.custom_minimum_size.x = 110
    score_label.add_theme_font_size_override("font_size", 25)
    score_label.add_theme_color_override("font_color", Color("#86efac"))
    teams.add_child(score_label)
    var away := Label.new()
    away.text = away_team
    away.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    away.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    away.add_theme_font_size_override("font_size", 17)
    teams.add_child(away)

    timer_label = Label.new()
    timer_label.text = "00′"
    timer_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
    timer_label.add_theme_font_size_override("font_size", 18)
    scoreboard.add_child(timer_label)

    var body := HBoxContainer.new()
    body.size_flags_vertical = Control.SIZE_EXPAND_FILL
    body.add_theme_constant_override("separation", 14)
    content.add_child(body)

    pitch = PitchViewScript.new()
    pitch.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    pitch.size_flags_vertical = Control.SIZE_EXPAND_FILL
    pitch.custom_minimum_size = Vector2(460, 280)
    body.add_child(pitch)

    var side := VBoxContainer.new()
    side.custom_minimum_size.x = 270
    side.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    body.add_child(side)
    status_label = Label.new()
    status_label.text = "استعد لبدء المباراة"
    status_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
    status_label.add_theme_color_override("font_color", Color("#86efac"))
    side.add_child(status_label)

    events_box = RichTextLabel.new()
    events_box.bbcode_enabled = true
    events_box.size_flags_vertical = Control.SIZE_EXPAND_FILL
    events_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    events_box.scroll_following = true
    events_box.custom_minimum_size = Vector2(220, 180)
    events_box.text = "[color=#a9b8c6]سيظهر سجل أحداث المباراة هنا.[/color]"
    side.add_child(events_box)

    var controls := HBoxContainer.new()
    controls.add_theme_constant_override("separation", 10)
    content.add_child(controls)
    var play_btn := _make_button("▶ تشغيل", Color("#16a34a"))
    play_btn.pressed.connect(_toggle_play)
    controls.add_child(play_btn)
    var next_btn := _make_button("دقيقة واحدة ⏭", Color("#2563eb"))
    next_btn.pressed.connect(_step_minute)
    controls.add_child(next_btn)
    var fast_btn := _make_button("إنهاء المباراة", Color("#475569"))
    fast_btn.pressed.connect(_finish_match)
    controls.add_child(fast_btn)

    _add_event("00′  انطلاق المباراة. نتمنى للفريقين التوفيق.")
    _update_score()

func _process(delta: float) -> void:
    if screen != "match" or not is_playing or match_minute >= 90:
        return
    event_timer += delta
    if event_timer >= 0.65 / speed_multiplier:
        event_timer = 0.0
        _step_minute()

func _toggle_play() -> void:
    if match_minute >= 90:
        return
    is_playing = not is_playing
    status_label.text = "المباراة جارية..." if is_playing else "المباراة متوقفة مؤقتًا"

func _step_minute() -> void:
    if screen != "match" or match_minute >= 90:
        return
    is_playing = false
    match_minute += 1
    var event := _generate_event()
    _add_event("%02d′  %s" % [match_minute, event])
    if pitch:
        pitch.animate_event(match_minute * 37 + home_goals * 11 + away_goals * 17)
    _update_score()
    if match_minute == 45:
        _add_event("45′  نهاية الشوط الأول.")
        status_label.text = "استراحة بين الشوطين"
    elif match_minute == 90:
        _add_event("90′  صافرة النهاية.")
        status_label.text = "انتهت المباراة"
    else:
        status_label.text = "تمت محاكاة الدقيقة %02d" % match_minute

func _generate_event() -> String:
    var roll := rng.randf()
    var home_attacks := rng.randf() < 0.52
    var team := home_team if home_attacks else away_team
    if roll < 0.07:
        if home_attacks:
            home_goals += 1
        else:
            away_goals += 1
        return "⚽ هدف لـ %s!" % team
    elif roll < 0.21:
        return "تسديدة من %s، والحارس يتصدى لها." % team
    elif roll < 0.32:
        return "هجمة خطيرة لـ %s، لكن الدفاع يبعد الكرة." % team
    elif roll < 0.37:
        return "بطاقة صفراء للاعب من %s." % team
    elif roll < 0.43:
        return "تبديل تكتيكي في صفوف %s." % team
    else:
        var general_events := [
            "استحواذ وتمريرات قصيرة في وسط الملعب.",
            "ضغط دفاعي ناجح واستعادة الكرة.",
            "تمريرة طويلة تصل إلى الجناح.",
            "محاولة بناء هجمة من الخلف.",
            "الكرة تخرج إلى رمية تماس.",
            "صراع قوي على الكرة في منتصف الملعب."
        ]
        return general_events[rng.randi_range(0, general_events.size() - 1)]

func _finish_match() -> void:
    if screen != "match":
        return
    is_playing = false
    while match_minute < 90:
        match_minute += 1
        var event := _generate_event()
        if event.begins_with("⚽"):
            _add_event("%02d′  %s" % [match_minute, event])
        if pitch:
            pitch.animate_event(match_minute * 37 + home_goals * 11 + away_goals * 17)
    _add_event("90′  انتهت المباراة. النتيجة النهائية: %d — %d" % [home_goals, away_goals])
    _update_score()
    status_label.text = "انتهت المباراة"

func _update_score() -> void:
    if is_instance_valid(score_label):
        score_label.text = "%d  —  %d" % [home_goals, away_goals]
    if is_instance_valid(timer_label):
        timer_label.text = "%02d′" % match_minute

func _add_event(message: String) -> void:
    event_lines.append(message)
    if event_lines.size() > 45:
        event_lines.pop_front()
    if is_instance_valid(events_box):
        events_box.clear()
        for line in event_lines:
            events_box.append_text(line + "\n")

func _make_card() -> PanelContainer:
    var panel := PanelContainer.new()
    var style := StyleBoxFlat.new()
    style.bg_color = Color("#1b2835")
    style.border_color = Color("#334155")
    style.set_border_width_all(1)
    style.set_corner_radius_all(12)
    style.content_margin_left = 14
    style.content_margin_right = 14
    style.content_margin_top = 12
    style.content_margin_bottom = 12
    panel.add_theme_stylebox_override("panel", style)
    return panel

func _make_button(text_value: String, color_value: Color) -> Button:
    var button := Button.new()
    button.text = text_value
    button.custom_minimum_size = Vector2(0, 42)
    button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
    button.add_theme_font_size_override("font_size", 15)
    var normal := StyleBoxFlat.new()
    normal.bg_color = color_value
    normal.set_corner_radius_all(8)
    normal.content_margin_left = 12
    normal.content_margin_right = 12
    normal.content_margin_top = 8
    normal.content_margin_bottom = 8
    var hover := normal.duplicate()
    hover.bg_color = color_value.lightened(0.12)
    var pressed := normal.duplicate()
    pressed.bg_color = color_value.darkened(0.15)
    button.add_theme_stylebox_override("normal", normal)
    button.add_theme_stylebox_override("hover", hover)
    button.add_theme_stylebox_override("pressed", pressed)
    return button
