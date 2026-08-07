# Vibe Architecture

Feature-first Flutter application. UI depends on domain contracts; data implementations are replaceable.

## Layers
- core: configuration, routing, DI, storage, networking, sync, security.
- features: auth, chats, messages, media, calls, Aurion, business, profile.
- tests: unit, widget, integration.

## Production rule
No secret, cryptographic primitive, backend credential, or production endpoint belongs in UI code or source control.
