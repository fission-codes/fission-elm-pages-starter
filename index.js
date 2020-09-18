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
  permissions: {
    app: {
      name: 'fission-elm-pages-starter',
      creator: 'bgins'
    }
  }
};

pagesInit({
  mainElmModule: Elm.Main
}).then(app => {
  webnative.initialize(fissionInit).then(async state => {
    switch (state.scenario) {
      case webnative.Scenario.AuthSucceeded:
      case webnative.Scenario.Continuation:
        app.ports.onFissionAuth.send({ username: state.username });

        fs = state.fs;

        // Create the filesystem if it does not exist
        const appPath = fs.appPath();
        const filesystemExists = await fs.exists(appPath);

        if (!filesystemExists) {
          await fs.mkdir(appPath);
          await fs.publish();
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
            // await fs.publish();
          }
        });
        break;

      case webnative.Scenario.NotAuthorised:
      case webnative.Scenario.AuthCancelled:
        break;
    }

    app.ports.login.subscribe(() => {
      webnative.redirectToLobby(state.permissions);
    });
  });
});

// TRANSACTIONS
// ⚠️ Will be removed soon

const transactions = {
  queue: [],
  finished: true
};

/**
 * Process the next item in the transaction queue.
 */
async function nextTransaction() {
  transactions.finished = false;
  if (nextTransactionWithoutPublish()) return;
  await fs.publish();
  if (nextTransactionWithoutPublish()) return;
  transactions.finished = true;
}

function nextTransactionWithoutPublish() {
  const nextAction = transactions.queue.shift();
  if (nextAction) {
    setTimeout(nextAction, 16);
    return true;
  } else {
    return false;
  }
}

/**
 * The Fission filesystem doesn't support parallel writes yet.
 * This function is a way around that.
 *
 * @param method The filesystem method to run
 * @param methodArguments The arguments for the given filesystem method
 */
async function transaction(method, ...methodArguments) {
  transactions.queue.push(async () => {
    await method.apply(fs, methodArguments);
    await nextTransaction();
  });

  if (transactions.finished) {
    nextTransaction();
  }
}
