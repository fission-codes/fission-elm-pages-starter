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
