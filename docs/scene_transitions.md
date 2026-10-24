# Scene Transitions

How the game moves between screens. There are two real scene changes and one
overlay that does *not* change scene.

## 1. Main menu → dialogue

```
main_menu.tscn
    │  player presses Start
    ▼
camera tweens toward the desk   (0.3s, ease in-out)
    │  await tween.finished
    ▼
change_scene_to_file("res://scenes/dialogue_scene_facts.tscn")
```

- File: `scripts/mainmenu.gd`, `_on_start_game_onclick()`.
- The menu hides its UI, tweens `trans_cam` to `player_cam` (position and
  rotation), waits for the tween to finish, then switches scene.
- This is a hard `change_scene_to_file` — the whole `main_menu.tscn` is freed.

## 2. Notebook (not a scene change)

The notebook is **not** a separate scene swap. It is instanced inside
`dialogue_scene_facts.tscn` and slides up as an overlay.

```
dialogue_scene_facts.tscn
├── UI (CanvasLayer, layer 10)          dialogue box, choice box, facts box,
│                                        and the notebook button
└── NotebookOverlay (CanvasLayer, layer 20)
    ├── BackBufferCopy   copies the screen before the blur
    ├── Blur (ColorRect) full-screen blur shader
    └── NoteBook         instance of scenes/note_book.tscn
```

Flow:

```
NotebookButton pressed
    │  overlay.visible = true
    ▼
NoteBook + its text fields slide up from below the screen   (0.6s, cubic)
    │  (back buffer is blurred behind them)
    ▼
player reads the notebook
    │  NotebookButton pressed again
    ▼
slides back down, overlay.visible = false
```

- File: `scripts/notebook_button.gd`.
- The slide animates both the notebook sprites (`NoteBook.position.y`) and its
  text fields (`NoteBook/UI.offset.y`) together.
- The blur is `assets/shaders/screen_blur.gdshader`, a box blur sampling
  `SCREEN_TEXTURE` (fed by the `BackBufferCopy`). Tune the `radius` uniform.

## 3. Settings menu (planned)

Not implemented yet, but the intent is: pressing **ESC** opens
`settings menu.tscn` from anywhere, without a scene change (it will be a
modal overlay, like the notebook).
