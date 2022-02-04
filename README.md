[![Built by FISSION](https://img.shields.io/badge/⌘-Built_by_FISSION-purple.svg)](https://fission.codes)
[![Built by FISSION](https://img.shields.io/badge/webnative-v0.21.3-purple.svg )](https://github.com/fission-suite/webnative)
[![Discord](https://img.shields.io/discord/478735028319158273.svg)](https://discord.gg/zAQBDEq)
[![Discourse](https://img.shields.io/discourse/https/talk.fission.codes/topics)](https://talk.fission.codes)


# fission-elm-pages-starter

This repo is an adapted version of the [elm-pages-starter](https://github.com/dillonkearns/elm-pages-starter) that demonstrates Fission auth and storage.

## Setup Instructions

Clone the repo

```
git clone git@github.com:fission-suite/fission-elm-pages-starter.git
```

Install and run the dev server

```
cd elm-pages-starter
npm install
npm start
```

## Create an App, Publishing to Fission

You can create an app and publish to Fission after you've [installed the CLI](https://guide.fission.codes/developers/).

```
fission app register
```

This will create a new app with a subdomain like `benevolent-senior-pink-yeti.fission.app/`, including a `fission.yaml` file in the root directory. The build directory is `dist`. You can go ahead and check your fission.yaml file into git -- only you have the keys to allow publishing.

You can publish a new version of your app whenever you like. First, make a new production build:

`npm run build`

Now, publish:

`fission app publish`

If you want to see detailed messages, you can also run `fission app publish --verbose`.

## Guide

The `guide/` directory has walkthroughs for publishing this app, auth, and storage.