## Performance & Compatibility Controls

### Low CPU Mode

To improve performance on older computers or in high-load environments, CursorGlow introduces a **Low CPU Mode** option:

- **Reduced Update Frequency:**  
  CursorGlow's animation updates are limited to fewer times per second (e.g., every 100ms instead of every frame), lowering CPU/GPU usage.
- **Shorter Tail Length:**  
  The number of tail segments is reduced (e.g., from 60 to 20), minimizing memory and rendering workload.
- **Simplified Effects:**  
  Advanced or resource-intensive effects may be disabled or replaced with simpler alternatives when Low CPU Mode is active.
- **User Controls:**  
  You can toggle Low CPU Mode from the settings panel, and optionally adjust the update interval and tail length for granular control.

---

### Auto-disable in Raid/Party or on Low FPS

CursorGlow can automatically adjust or suspend its effects in demanding gameplay situations:

- **Auto-disable in Group Content:**  
  When you join a raid, party, or battleground, CursorGlow detects the group state and disables itself or switches to Low CPU Mode, reducing impact on overall performance.
- **Auto-disable on Low FPS:**  
  CursorGlow monitors your current framerate (using `GetFramerate()`). If FPS drops below a user-defined threshold, the addon will auto-disable or switch to Low CPU Mode until performance improves.
- **Automatic Recovery:**  
  When you leave the group or your FPS returns to normal, CursorGlow automatically re-enables its effects.
- **User Controls:**  
  You can set your preferred FPS threshold, choose whether to fully disable or just lower performance mode, and enable/disable auto-reactions for group or FPS changes.

---

#### Example Settings

- **Low CPU Mode:** [checkbox]
- **Update Interval:** [slider, ms]
- **Tail Length:** [slider]
- **Auto-disable in Raid/Party:** [checkbox]
- **Auto-disable on Low FPS:** [checkbox]
- **FPS Threshold:** [slider]
- **Fallback Mode:** [dropdown: Disable / Low CPU Mode]

---

**Benefits:**
- Ensures CursorGlow remains lightweight and unobtrusive, even in resource-intensive scenarios.
- Offers a smoother gameplay experience for all users, especially those with older hardware or during large-scale events.