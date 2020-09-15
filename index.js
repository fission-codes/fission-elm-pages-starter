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

let fs;

const fissionInit = {
  app: {
    name: 'fission-elm-pages-starter',
    creator: 'bgins'
  },
  fs: {
    privatePaths: [],
    publicPaths: []
  }
};

pagesInit({
  mainElmModule: Elm.Main
}).then(app => {
  webnative
    .initialize(fissionInit)
    .then(async ({ prerequisites, scenario, state }) => {
      if (scenario.authSucceeded || scenario.continuum) {
        app.ports.onFissionAuth.send({ username: state.username });

        fs = state.fs;

        // Create the filesystem if it does not exist
        const appPath = fs.appPath();
        const filesystemExists = await fs.exists(appPath);

        if (!filesystemExists) {
          await fs.mkdir(appPath);
          await fs.publicise();
        }

        // Load an annotation or send an empty one
        app.ports.loadAnnotation.subscribe(async ({ title }) => {
          const path = fs.appPath(['annotations', `${title}.json`]);
          if (await fs.exists(path)) {
            const annotation = JSON.parse(await fs.read(path));
            app.ports.onFissionAnnotation.send({
              title: annotation.title,
              notes: annotation.notes
            });
          } else {
            app.ports.onFissionAnnotation.send({
              title,
              notes: ''
            });
          }
        });

        // Save an annotation to the local filesystem and IPFS
        app.ports.storeAnnotation.subscribe(async annotation => {
          if (annotation !== null) {
            const path = fs.appPath([
              'annotations',
              `${annotation.title}.json`
            ]);
            await transaction(fs.write, path, JSON.stringify(annotation));
            // await fs.write(path, JSON.stringify(annotation));
            // await fs.publicise();
          }
        });
      }

      app.ports.login.subscribe(() => {
        webnative.redirectToLobby(prerequisites);
      });
    });
});

// TRANSACTIONS
// ⚠️ Will be removed soon

const transactionQueue = [];

/**
 * Process the next item in the transaction queue.
 */
function nextTransaction() {
  const nextAction = transactionQueue.shift();
  if (nextAction) setTimeout(nextAction, 16);
  else fs.publicise();
}

/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param method The filesystem method to run
 * @param methodArguments The arguments for the given filesystem method
 */
async function transaction(method, ...methodArguments) {
  transactionQueue.push(async () => {
    await method.apply(fs, methodArguments);
    nextTransaction();
  });

  if (transactionQueue.length === 1) {
    nextTransaction();
  }
}
