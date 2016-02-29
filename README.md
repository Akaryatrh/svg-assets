#svg-assets [![Build Status](https://travis-ci.org/Akaryatrh/svg-assets.svg?branch=master)](https://travis-ci.org/Akaryatrh/svg-assets) [![Coverage Status](https://coveralls.io/repos/github/Akaryatrh/svg-assets/badge.svg?branch=master)](https://coveralls.io/github/Akaryatrh/svg-assets?branch=master)
---------

**_Warning_** :
This project is still a work in progress. Feel free to report any issues encountered or any possible enhancements.

**_Future of project_** :
The main goal is to offer Brunch, Grunt, and Gulp plugins.



## Why would you need it ?
--------------------------

Using **svg** in a project is great for many reasons (scalable size, all elements are editable with css, etc.). But a svg file can be sometimes **huge**, and including its source directly in your template file makes it **unreadable**.

That's where **svg-assets** comes to the rescue !
It'll parse any template file to find `<svga>` tags and replace them with related assets files.

Let's say you have a file called `my-pretty-chart.svg` located in your `/path-of-your-assets` folder.
Now you can add a new tag `<svga>my-pretty-chart.svg</svga>` in one of your template file and **svg-assets** will find and replace it with the orginal `svg` file. That way, you don't need to pollute your template files with svg sources.


## Installation
---------------

Installing globally will give you access to the `svg-assets` command anywhere on your system
```
npm install -g svg-assets
```

## Options
------------------

svg-assets comes with a few **options**. These options will be used by default (except `directory` and `assets`), and any of them will be replaced by defined ones.

|Option  | Default value | Notes|
:------------- | :------------------------- | :-----------|
| directory  | none | default value will be the root of project if `preserve-root` is set to false  |
| templates-ext | ['html', 'htm', 'hbs', 'handlebars'] | none |
| output-directory | null | if no output directory is set, It will override source template files |
| assets  | none | default value will be the root of project if `preserve-root` is set to false |
| assets-ext | ['svg'] | none |
| preserve-root | true  | none |
| logLevels | ['warning', 'error', 'info'] | none |

---

### directory
**Command:** `-d`, `--directory`
**Option format:** `string` (`Array` support in a further release)

Defines where svg-assets will look for files containing `<svga>` tags.
If not defined, the **root directory** of your project will be used, except if `preserve-root` option has been set to `true` (default behavior).

---

### templates-ext
**Command:** `-t`, `--templates-ext`
**Option format:** `string` or `Array`

Defines what kind of template files svg-assets will look for.
If not defined, the following extensions will be used : `html`, `htm`, `hbs`, `handlebars`

---

### output-directory
**Command:** `-o`, `--output-directory`
**Option format:** `string`

Defines where the processed template files will be saved.
:warning: If not defined, source templates files will be overwritten

---

### assets
**Command:** `-a`, `--assets`
**Option format:** `string` (`Array` support in a further release)

Defines where svg-assets will look for files matching the value contained by a `<svga>` tag.
If not defined, the **root directory** of your project will be used, except if `preserve-root` option has been set to `true` (default behavior).

---

### assets-ext
**Command:** `-A`, `--assets-ext`
**Option format:** `string` or `Array`

Defines what kind of assets files svg-assets will look for.
If not defined, the following extension will be used : `svg`

---

### log-levels
**Command:** `-l`, `--log-levels`
**Option format:** `string` or `Array`

Defines what kind of logs will be displayed on console output.
If not defined, the following log levels will be used : `warning`, `error`, `info`

---

### preserve-root
**Command:** `-p`, `--preserve-root`
**Option format:** `boolean`

When set to `true`, preserve the root directory of your project to be used for finding matching files.
This option is set to `true` by default.


## Example
----------
The following command will process template files in `foo/` folder, and look for assets in `bar/` folder. Processed templates will be saved to `foobar/` folder

```
svg-assets -d foo -a bar -o foobar
```

If you forked the project, you can also use the following commands to run an example:
```
npm install
grunt example

```

## License
----------
svg-assets is released under the MIT license
