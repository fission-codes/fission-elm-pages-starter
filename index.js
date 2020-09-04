import hljs from 'highlight.js/lib/highlight';
import 'highlight.js/styles/github.css';
import elm from 'highlight.js/lib/languages/elm';
import * as webnative from 'webnative';
// we're just importing the syntaxes we want from hljs
// in order to reduce our JS bundle size
// see https://bjacobel.com/2016/12/04/highlight-bundle-size/
hljs.registerLanguage('elm', elm);

import './style.css';
// @ts-ignore
window.hljs = hljs;
const { Elm } = require('./src/Main.elm');
const pagesInit = require('elm-pages');

const fissionInit = {
  app: {
    name: 'fission-elm-pages-starter',
    creator: 'bgins',
  },
  fs: {
    privatePaths: [],
    publicPaths: [],
  },
};

pagesInit({
  mainElmModule: Elm.Main,
}).then(app => {
  webnative
    .initialize(fissionInit)
    .then(async ({ prerequisites, scenario, state }) => {
      if (scenario.authSucceeded || scenario.continuum) {
        app.ports.onFissionAuth.send({ username: state.username });
      }

      app.ports.login.subscribe(() => {
        webnative.redirectToLobby(prerequisites);
      });
    });
});
