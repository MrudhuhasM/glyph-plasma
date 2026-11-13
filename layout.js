function applyGlyphLayout(replacePanels) {
    const home = "io.github.glyphplasma.home";
    const railWidgets = [
        ["org.kde.plasma.kickoff"],
        [home, "pager"],
        ["org.kde.plasma.icontasks"],
        ["org.kde.plasma.panelspacer"],
        [home, "clock"],
        ["org.kde.plasma.panelspacer"],
        ["org.kde.plasma.systemtray"],
        [home, "quick"]
    ];
    for (const [id] of railWidgets) {
        if (!knownWidgetTypes.includes(id))
            throw new Error("Missing Plasma widget: " + id);
    }

    const desktop = desktopsForActivity(currentActivity()).find(d => d.screen === 0);
    if (!desktop)
        throw new Error("No desktop found on the primary screen.");

    function addRailWidget(panel, id, role) {
        const widget = panel.addWidget(id);
        if (!widget || !widget.id)
            throw new Error("Could not add " + (role || id));
        if (role) {
            widget.currentConfigGroup = ["General"];
            widget.writeConfig("railRole", role);
        }
        return widget;
    }

    const screen = screenGeometry(0);
    if (!desktop.widgets(home).length) {
        const width = Math.min(1380, Math.round(screen.width * 0.85));
        const height = Math.min(Math.round(width * 490 / 1050), Math.round(screen.height * 0.74));
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
            for (const [id, role] of railWidgets)
                addRailWidget(rail, id, role);
            rail.writeConfig("GlyphPlasmaRail", true);
        } catch (error) {
            rail.remove();
            throw error;
        }
    }
    rail.floating = true;
    rail.opacity = "opaque";
    const roles = {};
    for (const widget of rail.widgets(home)) {
        widget.currentConfigGroup = ["General"];
        roles[widget.readConfig("railRole", "quick")] = widget;
    }
    for (const [role, oldType] of [
        ["pager", "org.kde.plasma.pager"],
        ["clock", "org.kde.plasma.digitalclock"],
        ["quick", ""]
    ]) {
        const oldWidget = oldType ? rail.widgets(oldType)[0] : null;
        if (!roles[role])
            roles[role] = addRailWidget(rail, home, role);
        if (oldWidget) {
            roles[role].index = oldWidget.index;
            oldWidget.remove();
        }
    }
    if (replacePanels) {
        for (const panel of existing) {
            if (panel.id !== rail.id && panel.screen === 0)
                panel.remove();
        }
    }
    if (rail.widgets("org.kde.plasma.panelspacer").length === 0) {
        const position = roles.clock.index;
        addRailWidget(rail, "org.kde.plasma.panelspacer").index = position;
        addRailWidget(rail, "org.kde.plasma.panelspacer").index = position + 2;
    }
    roles.quick.globalShortcut = "Meta+A";
    print("GLYPH_LAYOUT_APPLIED");
}
