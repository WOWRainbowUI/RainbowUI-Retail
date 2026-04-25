# RGX Foundation Decisions

This document answers a simple question:

What is actually required for `RGX-Framework` to be a real addon framework, and what is just legacy Ace3-style implementation detail?

## Core Rule

RGX should be elite-simple for addon authors:

- one dependency addon
- one clear API surface
- strong built-in defaults
- no unnecessary library chains
- no historical baggage unless it solves a real current problem

That means we only keep a foundation piece if it is required by real addon behavior, not because Ace3 happened to package it.

## What Is Actually Required

These are real framework requirements for the RGX direction.

### 1. Core addon object and module registry

RGX needs:

- one global framework object
- named module registration
- module lookup
- predictable initialization order
- a small lifecycle model
- BLU-style native runtime helpers for shared framework behaviors

Why this matters:

- every serious framework needs a stable place for shared systems to live

### 2. Shared media registries

RGX needs native registries for:

- fonts
- textures
- colors
- sounds

Why this matters:

- addon suites need one canonical source of shared media
- this is the part of LibSharedMedia that is genuinely useful

Design note:

- RGX can keep compatibility with BLU-style shared media behavior
- RGX does not need to literally become Ace/LSM internally to achieve that

### 3. Event and message dispatch

RGX needs:

- Blizzard event registration
- framework-wide messages
- module-local callback signaling when shared registries change

Why this matters:

- modules and consuming addons need a reliable way to react to game state and framework changes

Design note:

- this is why AceEvent and CallbackHandler exist
- RGX can solve the same problem natively

Related note:

- BLU already proved this direction with its own event/runtime layer, and RGX should absorb that style of native framework capability where it improves simplicity

### 4. SavedVariables and defaults

RGX needs a clean persistence layer for:

- global settings
- character settings
- optional profile-style settings if the suite really uses them
- default application and reset behavior

Why this matters:

- any reusable framework eventually owns saved settings and defaults

Design note:

- full AceDB complexity is not automatically required on day one
- simple defaults and clear storage rules matter more than feature count

### 5. Reusable option controls

RGX needs shared controls for:

- dropdowns
- color pickers
- font selectors
- texture selectors
- sound selectors
- toggles, sliders, edit boxes, tabs, grouped settings layouts

Why this matters:

- this is the difference between a media pack and a framework

### 6. Safe apply helpers

RGX needs one-line helpers that apply settings cleanly to:

- `FontString`s
- status bars
- textures
- frames
- sounds

Why this matters:

- addon authors should not rebuild glue code every time they use RGX data

## What Is Not Automatically Required

These are not mandatory just because Ace3 ships them.

### LibStub

`LibStub` is not required for RGX itself.

Why Ace used it:

- Ace libraries were designed to be embedded independently into many addons
- that created runtime version conflicts
- `LibStub` solved library discovery and version negotiation

Why RGX does not need it:

- RGX is one dependency addon
- RGX owns its own module registry
- RGX does not need multiple copies of independently embedded internal libraries fighting over version precedence

Decision:

- do not make `LibStub` a core RGX dependency
- prefer BLU-style native module/runtime services inside RGX over separately embedded version stubs

### CallbackHandler

`CallbackHandler-1.0` is not required as an external dependency if RGX already provides strong native event/message/callback dispatch.

Why Ace used it:

- reusable observer pattern
- event registration API generation
- secure dispatch and callback bookkeeping

Why RGX does not need the external library:

- the pattern is useful
- the dependency is optional if RGX already implements the pattern internally

Decision:

- keep the capability
- do not require the external Ace implementation

### AceSerializer

Serialization is only required if RGX needs:

- import/export
- addon-to-addon structured comms
- copy/paste data payloads
- future RGX-Mod data packaging

Decision:

- not a foundation requirement for early media/UI RGX
- becomes important when import/export or addon comm becomes real scope

### AceComm

Addon comm helpers are only required if RGX needs:

- addon-to-addon messaging
- chunked transmission
- synced data sharing

Decision:

- not a first-wave requirement
- becomes required when real cross-addon communication arrives

### AceGUI / AceConfig scale

A fully generic mega-GUI layer is not automatically required on day one.

What is required instead:

- a small set of elite-simple, polished RGX controls
- shared layout primitives
- predictable settings wiring

Decision:

- build the small shared controls first
- grow only from real addon needs

## Why Addon Authors Use Ace3

Ace3 became popular because it bundled a lot of common pain points in one place:

- addon object/lifecycle helpers
- event handling
- timers
- hooks
- database/profile handling
- slash commands
- options UI
- comm and serialization

That made it practical and familiar.

The key lesson is not "copy Ace3 exactly."

The real lesson is:

- frameworks win when they remove boring repeated work

RGX should keep that outcome while simplifying the implementation and API.

For the fuller breakdown of why Ace3 gets adopted and how RGX should beat it:

- see [ACE3-ANALYSIS.md](ACE3-ANALYSIS.md)

## RGX Direction

RGX should keep three categories separate:

### Required now

- module system
- shared media registries
- event/message/callback system
- native runtime helpers like timers, hooks, and slash registration
- defaults and saved settings
- reusable option controls
- one-line apply helpers

### Required soon

- sounds
- more complete dropdown/tab/frame primitives
- better settings composition
- simple timers or deferred work helpers if real addons need them

### Required later

- serialization
- addon comm
- import/export
- RGX-Mod-specific higher-level systems

## Final Decision

If RGX's native event and message systems are good enough, then:

- RGX does not need `LibStub`
- RGX does not need external `CallbackHandler-1.0`
- RGX does not need Ace3 as a dependency

But RGX still needs the actual capabilities those libraries were solving:

- module organization
- dispatch
- persistence
- controls
- media registries
- optional comm/serialization when the framework truly needs them

That is the standard to hold:

- keep the capability
- simplify the architecture
- remove the dependency unless it is truly buying us something
