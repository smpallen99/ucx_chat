exports.config = {
  // See http://brunch.io/#documentation for docs.
  files: {
    javascripts: {
      joinTo: "js/app.js"

      // To use a separate vendor.js bundle, specify two files path
      // http://brunch.io/docs/config#-files-
      // joinTo: {
      //  "js/app.js": /^(web\/static\/js)/,
      //  "js/vendor.js": /^(web\/static\/vendor)|(deps)/
      // }
      //
      // To change the order of concatenation of files, explicitly mention here
      // order: {
      //   before: [
      //     "web/static/vendor/js/jquery-2.1.1.js",
      //     "web/static/vendor/js/bootstrap.min.js"
      //   ]
      // }
    },
    stylesheets: {
      joinTo: {
        "css/app.css": [
          /^(web\/static\/css)/,
          "node_modules/highlight.js/styles/default.css",
          // "node_modules/emojionearea/dist/emojionearea.min.css",

        ],
        "css/channel_settings.css": ["web/static/scss/channel_settings.scss"],
        "css/toastr.css": ["web/static/css/toastr.css"],
        "css/emojipicker.css": ["web/static/vendor/emojiPicker.css"]
        // "css/toastr.css": ["web/static/scss/toastr.scss"]
      },
      order: {
        // after: ["web/static/css/theme/main.scss", "web/static/css/app.css"] // concat app.css last
        // after: ["web/static/css/livechat.scss", "web/static/css/app.css"] // concat app.css last
      }
    },
    templates: {
      joinTo: "js/app.js"
    }
  },

  conventions: {
    // This option sets where we should place non-css and non-js assets in.
    // By default, we set this to "/web/static/assets". Files in this directory
    // will be copied to `paths.public`, which is "priv/static" by default.
    assets: /^(web\/static\/assets)/
  },

  // Phoenix paths configuration
  paths: {
    // Dependencies and current project directories to watch
    watched: [
      "web/static",
      "test/static"
    ],

    // Where to compile files to
    public: "priv/static"
  },

  // Configure your plugins
  plugins: {
    babel: {
      // Do not use ES6 compiler in vendor code
      ignore: [/web\/static\/vendor/]
    },
    postcss: {
      processors: [
        require("autoprefixer")
      ]
    },
    sass: {
      mode: "native", // This is the important part!
      options: {
        includePaths: [ 'node_modules' ]
      }
    },
    coffeescript: {
      // bare: true
    },
    modernizr: {
      destination: 'js/modernizr.js',
      options: [
        'setClasses'
      ]
    }
  },

  modules: {
    autoRequire: {
      "js/app.js": ["web/static/js/app"]
    }
  },

  npm: {
    enabled: true,
    // whitelist: ["toastr", "highlight.js", "emojionearea"], //, "rm-emoji-picker"],
    whitelist: ["highlight.js"],
    styles: {
      // toastr: ["toastr.css"],
      "highlight.js": ['styles/default.css']
      // emojionearea: ['dist/emojionearea.min.css']
      // emojipicker: ['dist/emojipicker.css']
    },
    globals: {
      // $: 'jquery',
      // JQuery: 'jquery',
      _: 'underscore'
    }
  }
};
