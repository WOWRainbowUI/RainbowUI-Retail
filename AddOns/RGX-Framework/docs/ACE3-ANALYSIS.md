# Why Authors Use Ace3

This document is not here to dismiss Ace3.

Ace3 became popular because it solved a real problem:

- WoW addon authors kept rebuilding the same boring infrastructure

If RGX wants to be better, it needs to beat Ace3 at the outcome, not just replace names.

BLU already points in the right direction here:

- one addon-owned runtime
- one addon-owned module registry
- one addon-owned event system

RGX should build on that style of framework design instead of rebuilding Ace's embedded-library architecture.

## The Real Reason People Use Ace3

Most authors do not use Ace3 because they love `LibStub` or because they specifically want `CallbackHandler`.

They use Ace3 because it gives them a fast way to get this list of problems off their plate:

- addon lifecycle
- module organization
- event handling
- timers
- hooks
- saved variables and profiles
- slash commands
- options UI
- addon communication
- serialization
- localization

Ace3 also became a social default because:

- many example addons already use it
- many developers already know its patterns
- it reduces decision-making
- it feels safer to depend on something familiar

That means RGX does not need to copy Ace3 line-for-line.

It does need to make addon development feel easier, safer, and faster than Ace3 does.

## What Each Ace3 Piece Is Actually Solving

### `AceAddon-3.0`

Problem solved:

- addon object creation
- module registration
- lifecycle callbacks like `OnInitialize` and `OnEnable`

What RGX should keep:

- one clean addon/module lifecycle
- easy module registration
- predictable startup order

What RGX should avoid:

- unnecessary embed complexity
- making every addon author think about framework internals

### `AceEvent-3.0` + `CallbackHandler-1.0`

Problem solved:

- event registration
- message dispatch
- callback bookkeeping

What RGX should keep:

- Blizzard event handling
- framework messages
- local callback emitters

What RGX should avoid:

- external dependency chains when native RGX dispatch already solves it

### `AceTimer-3.0`

Problem solved:

- delayed and repeating work

What RGX should keep:

- a simple timer/defer utility if real addons need it

What RGX should avoid:

- adding timer machinery before the suite actually depends on it

### `AceHook-3.0`

Problem solved:

- safe function hooking
- hook cleanup

What RGX should keep:

- a lightweight hook helper only if the suite repeatedly needs it

What RGX should avoid:

- shipping hook infrastructure just because frameworks usually do

### `AceDB-3.0`

Problem solved:

- SavedVariables handling
- defaults
- namespaces
- profile support

What RGX should keep:

- strong defaults
- simple storage model
- optional profile support only if the suite truly benefits from profiles

What RGX should avoid:

- database complexity that authors do not actually need

### `AceConsole-3.0`

Problem solved:

- slash commands
- command routing
- formatted framework output

What RGX should keep:

- a tiny command registration helper

What RGX should avoid:

- over-engineered command parsing unless real addons need it

### `AceGUI-3.0` + `AceConfig-3.0`

Problem solved:

- reusable settings widgets
- options layout generation
- standard configuration flow

What RGX should keep:

- shared widgets
- shared layout primitives
- one-line control binding
- live preview behavior

What RGX should avoid:

- giant declarative config tables that are harder to maintain than the UI they generate

This is one of the biggest places RGX can be better.

### `AceComm-3.0` + `AceSerializer-3.0`

Problem solved:

- addon communication
- chunked message transport
- structured data transport

What RGX should keep:

- comm + serialization only when RGX or RGX-Mod truly need cross-addon traffic or import/export

What RGX should avoid:

- carrying comm infrastructure before that use case exists

### `AceLocale-3.0`

Problem solved:

- localization tables

What RGX should keep:

- a straightforward localization pattern if the suite needs multi-language support

What RGX should avoid:

- localization framework weight before localization work actually begins

### `LibStub`

Problem solved:

- runtime version negotiation for separately embedded libraries

What RGX should keep:

- nothing from this unless RGX starts shipping as separately embedded versioned sub-libraries

What RGX should avoid:

- pretending a single dependency addon needs embedded-library version arbitration

Preferred RGX replacement:

- BLU-style native framework services inside RGX itself

## What Is Actually Required For RGX

If the goal is "Ace3 but better and simpler," the real required foundation is:

### Required now

- core framework object
- module registry and lifecycle
- shared media registries for fonts, textures, colors, then sounds
- event/message/callback dispatch
- native runtime services such as timers, hooks, and slash helpers
- defaults + SavedVariables helpers
- shared option controls
- one-line apply helpers
- simple command helpers

### Required soon

- timer/defer helpers if the suite needs them
- tab/group/frame layout primitives
- better settings binding
- sound preview and sound registry support
- BLU-compatible shared media bridging where useful

### Required later

- hook helpers if repeated real use appears
- serialization
- addon comm
- import/export
- localization support
- RGX-Mod-oriented higher-level systems

## How RGX Beats Ace3

RGX should not try to win by having more tiny libraries.

RGX should win by being easier to consume.

### 1. One dependency, not a library pile

Ace3 often feels powerful because it is broad.

It also feels fragmented because authors end up thinking in terms of many small library names and embedding patterns.

RGX should feel like:

- install one addon
- depend on one addon
- call one family of APIs

### 2. Better defaults

Ace3 gives capability.

RGX should give capability plus polished defaults:

- curated media
- ready-made controls
- consistent styling
- built-in preview behavior

### 3. Less boilerplate

Ace3 often reduces raw implementation work but still leaves a lot of structure for the author to assemble.

RGX should prefer APIs like:

- `AttachFontSelector`
- `AttachBarSelector`
- `AttachColorSelector`
- `ApplyTextStyle`

instead of pushing authors toward big generic setup tables whenever a direct helper would be clearer.

### 4. Better visual integration

Ace3 is often used because it is functional.

RGX should be functional and visually opinionated in a good way:

- good media
- good previews
- good selector behavior
- consistent suite identity

### 5. Fewer accidental architecture decisions for addon authors

Ace3 gives a lot of flexibility, which is useful, but it can also spread complexity into consumer addons.

RGX should keep more of the complexity internal so authors do not have to reinvent patterns.

### 6. Build from real suite needs

RGX should only grow when real addons need the feature:

- SQP
- PB2
- BLU
- future RGX-Mod

That keeps the framework honest.

## The Best RGX Position

The strongest position for RGX is not:

- "we replaced Ace3 with our own Ace3 clone"

The strongest position is:

- RGX keeps the handful of framework capabilities addon authors actually need
- RGX removes the dependency clutter and historical baggage
- RGX gives much better shared media and shared controls
- RGX makes addon integration faster than Ace-style assembly

## Final Standard

When deciding whether a new RGX subsystem belongs in the framework, ask:

1. What real addon problem is this solving?
2. Is that problem already showing up in SQP, PB2, BLU, or planned RGX-Mod work?
3. Can RGX solve it with one clean native system instead of another external-style compatibility layer?
4. Will this make addon authors faster, or just make RGX look more like Ace3?

If the answer is "faster and simpler for real addons," it belongs.

If the answer is "Ace3 had one, so we should too," it probably does not.
