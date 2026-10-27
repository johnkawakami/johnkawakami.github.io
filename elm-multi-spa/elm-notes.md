# Elm Notes

## Basics
- Elm is a pure functional language for building web apps. It compiles to JavaScript.
- `elm.json` defines dependencies and source directories.
- `Browser.element` is used for apps that take flags/init and have a model/update/view.
- `Browser.sandbox` is simpler for stateless/simple apps.
- `port module` is needed when using ports to communicate with JavaScript.

## Architecture (Model-Update-View)
- **Model**: Holds application state (e.g., `type alias Model = { activeTab : Tab }`).
- **Msg**: Union type of events (e.g., `TabClicked Tab`).
- **update**: Pure function `(Msg -> Model -> (Model, Cmd Msg))` returning new model and commands.
- **view**: Pure function `(Model -> Html Msg)` producing HTML; uses `Html.map` when mapping messages.
- **init**: Returns initial model and commands.

## Modules & Organization
- Split functionality into separate modules (e.g., `Home`, `Editor`, `Message`). Each module exposes what others need.
- Can compose views by calling module functions in `Main.view`.
- Multiple Browser.element apps can be compiled separately and mounted via JS/ports (like in the comments doc pattern), or combined in one app.

## HTML & Events
- `Html` package for elements; use `Html.Attributes` for attributes/classes/styles.
- `Html.Events` for events like `onClick`.
- Use `classList` for conditional classes.
- Can map messages with `Html.map` when embedding child components that have their own Msg types.

## Ports
- Define `port` functions in a `port module`. Outgoing: `port sendData : Data -> Cmd msg`. Incoming: `port receiveData : (Data -> msg) -> Sub msg`.
- Used for integrating with JS libraries (Quill) and for side effects not possible in pure Elm.

## Building
- `elm make src/Main.elm --output=app.js` compiles to JS.
- Can use `--optimize` for production builds.
- With `Browser.element`, need to initialize in JS: `Elm.Main.init({ node: document.getElementById('...'), flags: ... })`.

## Tips Learned
- Keep UI logic in Elm (tabs, state), integrate third-party WYSIWYG via ports/JS.
- For mobile-first tabbed UIs, control visibility with CSS classes on elements rendered by Elm.
- LocalStorage is easiest to access via JS interop (ports or direct JS). Managing state across tab switches requires careful coordination between Elm and JS.
- When mixing dynamic JS libraries (like Quill) with SPA navigation, need to reinitialize/mount when elements appear.
- CSS classes are cleaner than inline styles for shared styling.
- Dark mode can be toggled via JS adding classes to body, with state persisted in localStorage.
- Autosave is fragile when DOM elements get recreated/replaced by Elm; better to have JS own the integration and coordinate saves/restores.

## CSS & Styling
- Use semantic class names and CSS variables for theming (dark/light mode).
- CSS custom properties with `body.dark` overrides make theme switching cleaner than duplicating many rules.
- For mobile UIs, use `position: fixed` for bottom nav/FABs and respect safe areas with `env(safe-area-inset-bottom)`.
- Sticky headers work well for page titles.
- Avoid mixing too much inline styling in Elm; prefer CSS classes.

## JS Interop Patterns
- For third-party libraries (Quill), mount into DOM elements created by Elm and initialize via JS.
- Need to reinitialize/rebind when navigating between tabs since Elm may recreate DOM nodes.
- Use localStorage for persisting simple state (documents, dark mode).
- Event delegation on document helps when elements are dynamically created/updated.
- Coordinate saves/restores carefully when DOM elements get recreated.

## Gotchas
- When mixing Elm modules and JS, message types need to be consistent if using Html.map.
- Dialogs/modals can be done with plain JS + CSS, or fully in Elm; simple approach is JS toggling display.
- Port modules require `port module ...` and careful Cmd/Sub wiring.

## Coding Tips (For People & LLMs)
### For People
- Keep Elm types explicit; let the compiler guide you.
- Split UI into modules by screen/feature for maintainability.
- Use ports only when you need DOM/JS libraries or browser APIs not available in Elm.
- For styling, prefer CSS classes and variables over inline styles where possible.
- Test UI flows with Playwright to catch DOM/interop issues.
- When mixing JS and Elm, be defensive about DOM readiness and element existence.

### For LLMs
- Always read the relevant files before editing - Elm's type system and module dependencies matter.
- When changing module structure (adding/removing msgs), update all call sites (Main + modules).
- If Html.map is used, ensure Msg types align correctly.
- Be careful with string literals and exact formatting when using Edit tool.
- After making changes, compile with `elm make` to catch syntax/type errors early.
- For port-based interop, update both Elm ports and JS handlers together.
- Don't assume DOM elements exist immediately - use timeouts/event delegation if needed.
- When adding UI elements that JS interacts with (ids), update both Elm and JS.
- Keep changes minimal and focused; compile after each logical change.

## Positioning Tips
- Use `calc()` for combining fixed positions with spacing (e.g., `bottom: calc(70px + 1rem)`).
- When moving FABs, ensure they don't overlap with tab bars or safe areas.
- Fixed positioning is great for overlays like FABs/dialogs.

## Emoji & Fonts
- For color emojis on different platforms, include fallbacks like "Apple Color Emoji", "Segoe UI Emoji", "Noto Color Emoji".
- Load web fonts (Google Fonts) in HTML if system emoji rendering is inconsistent.
- Set emoji font family on specific elements that need consistent rendering (like tabs).

## Iterative Development
- Make small changes and compile frequently to catch errors.
- When JS manipulates DOM elements created/managed by Elm, coordinate carefully (ids, timing).
- Tests help catch regressions in interop-heavy features.

## Best Tips Table

| Category | Tip | Notes |
|----------|-----|-------|
| Elm Architecture | Keep messages simple and map with Html.map | Avoid leaking child messages to parent unnecessarily |
| Ports | Only use ports for non-Elm capabilities | DOM manipulation, localStorage, third-party libs |
| Compilation | Compile early and often with `elm make` | Catch type errors before runtime |
| CSS | Use variables + semantic classes | Easy theming and dark mode |
| Interop | Guard DOM access with null checks | Elements may not exist yet |
| Testing | Use Playwright for E2E | Great for SPAs with JS interop |
| State | Persist minimal state to localStorage | Keep it simple and serializable |
| Styling | Respect safe areas on mobile | Use env(safe-area-inset-bottom) |
| Emojis | Provide emoji font fallbacks | For consistent cross-platform rendering |
| Debugging | Log sparingly, test in browser | Playwright helps automate checks |
