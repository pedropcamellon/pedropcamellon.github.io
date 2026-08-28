---
layout: default
title: "The Long Way Round: A Browser Drive to Nowhere in Particular"
date: 2026-07-05
image: "threejs.jpg"
tags:
  [
    "Three.js",
    "JavaScript",
    "game dev",
    "learning",
    "WebGL",
    "personal projects",
  ]
excerpt: "A small Three.js driving game with no scoring and no opponents — just a truck, a hilly loop, some lakes, and trees to knock over. Built to relearn 3D fundamentals and to have something nostalgic and instantly playable in a browser tab."
---

<div class="tldr">

I wanted to explore Three.js, so I used it to create a nostalgic, casual game called **The Long Way Round**. There's no scoring, no opponents, no lap timer — just a truck driving a hilly loop with lakes, forests, and rocks to bump into. Something as easy to load and play as the browser games I grew up with, but built with modern WebGL under the hood. [Play it here](https://pedropcamellon.github.io/the-long-way-round/).

</div>

I've been circling the idea of "Forma-like 3D in the browser" for a while, and this was the first time I actually put my hands on Three.js instead of reading about it. Circuit Runner started as a fast, vibe-coded truck racing demo — scene, camera, lighting, materials, shadows, a Catmull-Rom spline track, heightmap terrain, and simple arcade collision rules (big rocks stop you, small rocks slide, trees topple over).

The more I played with it, the less it felt like a "racer" and more like a place to just drive around. So I kept iterating: shallower lakes you can wade through (slower, not deadly), a forest ring to give the map a natural edge, lakeside tent camps, rabbits that scatter, and logs that burst apart when a tree comes down. No goals, no pressure — just terrain to explore.

That's the part that scratches the nostalgic itch. Browser games used to be something you'd click into on a whim, mess around with for ten minutes, and close the tab. No install, no account, no loading screen longer than the game itself. This is my attempt at that same feeling, just rendered with real-time WebGL instead of a Flash plugin.

## What it's built with

- Vanilla ES modules, no bundler or framework
- Three.js loaded straight from a CDN via an import map
- `GLTFLoader` pulling in Kenney's Car Kit and Nature Kit models
- A spline-based track with heightmap-driven terrain
- Simple physics for driving, water drag, and collisions

It now lives in its own repo, [the-long-way-round](https://github.com/pedropcamellon/the-long-way-round), separate from the portfolio site so it can grow on its own without dragging blog concerns along with it.

Nothing about this was meant to be a "real" game. It was a way to get 3D fundamentals into my hands, and it turned into something I actually enjoy loading up for a couple of minutes. [Give it a spin](https://pedropcamellon.github.io/the-long-way-round/) — pick a vehicle, drive the loop, knock over a tree or two.
