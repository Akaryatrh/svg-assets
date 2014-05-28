#svgAssets
---------

**_Warning_** :
This project is relatively new and still a work in progress. Feel free to report any issues encountered or any possible enhancements.

**_Future of project_** :
The main goal is to offer Brunch, Grunt, and Gulp plugins.



## Why would you need it ?
--------------------------

Using **svg** in a project is great for many reasons (scalable size, all elements are editable with css, etc.). But a svg file can be sometimes **huge**, and including its source directly in your template file makes it **unreadable**.

That's where **svgAssets** comes to the rescue !
It'll parse any template file to find `<svga>` tags and replace them with related assets files.






## How to use it ?
------------------

svgAssets comes with a few **options**. These options (except `directory` and `assets`) will be used by default, and any of them will be replaced by defined ones.

```javascript
    directory: './templates'
    assets: './assets'
	templatesExt: ['html', 'htm', 'hbs', 'handlebars']
	assetsExt: ['svg']
	logLevels: ['warning', 'error', 'info']
	preserveRoot: true
```

### directory
**Option format:** `string`

Defines where svgAssets will look for files containing `<svga>` tags.
If not defined, the **root directory** of your project will be used, except if `preserveRoot` option has been set to `true` (default behavior).

---

### assets
**Option format:** `string`

Defines where svgAssets will look for files matching the value contained by a `<svga>` tag.
If not defined, the **root directory** of your project will be used, except if `preserveRoot` option has been set to `true` (default behavior).

---

### templatesExt
**Option format:** `string` or `Array`

Defines what kind of template files svgAssets will look for.
If not defined, the following extensions will be used : `.html`, `.htm`, `.hbs`, `.handlebars`

---


### assetsExt
**Option format:** `string` or `Array`

Defines what kind of assets files svgAssets will look for.
If not defined, the following extension will be used : `.svg`


---


### logLevels
**Option format:** `string` or `Array`

Defines what kind of logs will be displayed on console output.
If not defined, the following log levels will be used : `warning`, `error`, `info`


---


### preserveRoot
**Option format:** `boolean`

When set to `true`, will preserve the root directory of your project to be used to find matching files.
This option is set to `true` by default.