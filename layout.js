function applyGlyphLayout(replacePanels) {
    const home = "io.github.glyphplasma.home";
    const railWidgets = [
        "org.kde.plasma.kickoff",
        "org.kde.plasma.pager",
        "org.kde.plasma.icontasks",
        "org.kde.plasma.systemtray",
        "org.kde.plasma.digitalclock"
    ];
    for (const id of [home, ...railWidgets]) {
        if (!knownWidgetTypes.includes(id))
            throw new Error("Missing Plasma widget: " + id);
    }

    const desktop = desktopsForActivity(currentActivity()).find(d => d.screen === 0);
    if (!desktop)
        throw new Error("No desktop found on the primary screen.");

    const screen = screenGeometry(0);
    if (!desktop.widgets(home).length) {
        const width = Math.min(1380, Math.round(screen.width * 0.85));
        const height = Math.min(Math.round(width * 410 / 1050), Math.round(screen.height * 0.74));
        const x = Math.max(56, Math.round(screen.width * 0.10));
        const y = Math.round(screen.height * 0.12);
        const widget = desktop.addWidget(home, x, y, width, height);
        if (!widget || !widget.id)
            throw new Error("Could not add Glyph Home.");
    }

    const existing = panels();
    let rail = existing.find(p => String(p.readConfig("GlyphPlasmaRail", false)) === "true");
    if (!rail) {
        rail = new Panel;
        try {
            rail.location = "left";
            rail.screen = 0;
            rail.height = 42;
            rail.lengthMode = "fill";
            for (const id of railWidgets) {
                const widget = rail.addWidget(id);
                if (!widget || !widget.id)
                    throw new Error("Could not add " + id);
            }
            rail.writeConfig("GlyphPlasmaRail", true);
        } catch (error) {
            rail.remove();
            throw error;
        }
    }
    if (replacePanels) {
        for (const panel of existing) {
            if (panel.id !== rail.id && panel.screen === 0)
                panel.remove();
        }
    }
    print("GLYPH_LAYOUT_APPLIED");
}
