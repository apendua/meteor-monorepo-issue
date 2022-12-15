# meteor-pnpm-monorepo

Public repo to share with MeteorJS to identify a monorepo problem

## RUSH + Meteor

Meteor does not natively support `pnpm` yet so you will need to run `meteor` from a checkout in order for this setup to work.

Start by cloning https://github.com/apendua/meteor.git and make sure yo use the `resolve-symlinks` branch:
```
git clone -b resolve-symlinks --single-branch https://github.com/apendua/meteor.git
```
Next, create `meteor.local.sh` inside `apps/myapp/` folder, with the following content:
```
#!/bin/bash
export METEOR_MONOREPO_ROOT=/path/to/meteor-monorepo-issue
~/path/to/meteor/checkout/meteor $@
```
and make it executable. Finally:

- Make sure you have [rush](https://rushjs.io/) installed
- Go to `/path/to/meteor-monorepo-issue` and run `rush install`
- Run `rush build:watch` from the root to build and watch all projects
- Open another terminal, go to `apps/myapp/` and run `npm start` start meteor. This will use the version of meteor which `meteor.local.sh` is pointing to.

## Setup

- install [pnpm](https://pnpm.io/installation)
- install [nvm](https://github.com/nvm-sh/nvm#installing-and-updating) (or use `pnpm env`)
- run `nvm use`
- run `pnpm i`
- open a terminal and run `pnpm build` from the root to build the typescript projects
- open another terminal and run `pnpm start` from the root to start meteor

## Idea

The idea is to:

- use `pnpm` workspaces to create isolated packages which can be used by a Meteor Application
- use [typescript references](https://www.typescriptlang.org/docs/handbook/project-references.html) to make the `apps/myapp` responsible for building the dependant packages

### Structure

- apps
  - `myapp`
    - depends on: `package-a`
- packages
  - `package-a`
    - depends on `package-b`
  - `package-b`

## PNPM + Meteor

Meteor and PNPM don't play nicely together out of the box, but there is a way to make this work. Also see [this PR](https://github.com/lessonup/meteor-monorepo-issue/pull/1)

Fixes and findings are thanks to @harryadel

- Set [shared-workspace-lockfile](https://pnpm.io/workspaces#shared-workspace-lockfile) to false in root `.npmrc`.
  Basically Meteor doesn't work naturally with pnpm because it doesn't seem to understand linked node_modules. After running `pnpm install` in Meteor directory, only package-a exists in `node_modules` and the rest is linked from root pnpm-lock which Meteor doesn't like ofc so turns out this option stops this behavior.

- Set [node-linker](https://pnpm.io/npmrc#node-linker) to hoisted in meteor directory not in root `.npmrc`.
  Again, this option stops the sym linking behavior which upsets Meteor but on a more of a local scale compared to the previous one which works in regards to workspaces.

## Open issues

### React is being imported twice

After installing add `window.React1 = require('react');` to `apps/myapp/node_modules/react-dom/index.js` as described [here](https://reactjs.org/warnings/invalid-hook-call-warning.html#duplicate-react) and start the application.

You'll get the log at [MyFeature.tsx](packages/package-a/src/feature/MyFeature.tsx) which indicates that react has been loaded twice. The error implies the same.

![image](https://user-images.githubusercontent.com/710335/170228291-fa58e166-7fa7-446a-9c5f-9809585735c9.png)

My assumtion is that this is because of the `node_modules` structure which contains `react` in the root and `react` via the symlink of `package-a/node_modules/react`.

![Screenshot 2022-05-25 at 11 20 50](https://user-images.githubusercontent.com/710335/170228804-1c6ba233-3912-42ea-ba98-0dd4ab59b477.png)



### Meteor no watching changes of `package-b`

There is 1 open issue where issue doesn't auto reload changes from `package-b`, but it does do that for `package-a`.

This can be work around by using the `METEOR_DISABLE_OPTIMISTIC_CACHING=true` flag.
