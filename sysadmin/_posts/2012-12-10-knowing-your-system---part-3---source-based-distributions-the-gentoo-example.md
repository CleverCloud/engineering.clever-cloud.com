---
locale: en
layout: post

title: "Knowing your system - Part 3 - Source-based distributions: The Gentoo example"
author: "keruspe"
level: 3
---

After [a little reminder on UNIX-like systems](http://engineering.clever-cloud.com/sysadmin/2012/11/22/knowing-your-system-part-basics-on-unixlike-systems.html)
and [a quick view to the init process](http://engineering.clever-cloud.com/sysadmin/2012/11/29/knowing-your-system-part-the-init-process.html),
we'll now see the kind of distributions which I really love, where you really control everything.

## What is a source-based GNU/Linux distribution?

The principle may be a bit scary, but is actually simple.

In most distributions (called binary distributions), software are packaged to be "ready to use",
all configured by the distribution maintainers, and you then get a list of available packages that you can install.
When you ask for a package to be installed, it will download the software and its dependencies and install everything.

In source-based, the package manager will also handle all the dependencies, downloading and installing stuff. The thing
which changes with them is the thing you actually download, and what is being done between the downloading and the
installing phases of the process.

Instead of downloading the software, the package mangler will download its source code, unpack it, configure it and then
compile it. You're basically compiling your whole system with those distributions.

## Why "wasting" that much time makes sense?

As you probably know, compiling can be very long. It mostly depends on your hardware, and most of the projects will
compile in a couple of minutes, but some of them, like the compiler itself or your web browser can take up to several
hours on certain boxes.

This can be seen as a PITA but this is the price of real liberty. With source-based distributions, you can choose which
components of each software you want to build, and exactly which options you want. With binary distributions, if you're
missing a feature, you'll have to do everything by yourself outside your package manager, and this will really be a PITA
to maintain. With source-based distribution, it's way easier to contribute, as we'll see in a later post of this saga.
The package does not contain all the binaries, it's just a text file you have to edit to add an option you're missing.
Everything becomes easier to customize, you become the God of your system.

You must also keep in mind that while you're compiling stuff, your system is still fully usable, so you can just do it
in background.

## The Gentoo example: My beginning with source-based distributions

My first GNU/Linux distribution was Ubuntu, which seemed to be popular (and which still is), a binary distribution of
course. I was quite happy with it for the first months, but as soon as I wanted to explore my system more deeply, like
compiling my own kernel, or when I wanted to do really specific operations, I was immediately limited by the design of
this distribution.

I was a student at this time, and my class-mate (and now colleague) [Kevin Decherf](http://blog.kdecherf.com/) told me he was using
[Gentoo](http://www.gentoo.org/). on his server. I immediately asked him if he agreed to plan an Install Party the week just after that.
During this session, I installed a minimal system, discovering the distribution. At the end of the day, it was barely booting to an xterm.

I wanted to really explore my distribution to understand exactly how everything works, so I started "playing" with it,
modifying packages, checking how things reacted. I broke my system and reinstalled it 5 times in 3 weeks, playing harder
and harder, until I knew how to make my system work again after a wanted major breakage.

You really should try source-based distributions, to really get how things work. It can take a few months to understand
them if you just play a little with them on an irregular basis, but it's really worth it. Gentoo was my choice since
it's the most popular source-based distribution, and the only one I heard of at this time. It's quite good, but you'll
see in my next post that I didn't really like its default package manager, and I no longer use Gentoo.
