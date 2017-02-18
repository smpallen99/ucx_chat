import * as cc from './chat_channel'
import * as main from './main'

const debug = false;

const notifications = [
  {event: "update:pinned", title: "Pinned Messages"},
  {event: "update:stared", title: "Stared Messages"}
]

const default_settings = {
  "Info": { args: {templ: "channel_settings.html"} },
  "Search": {},
  "User Info": {},
  "Members List": {
    args: {templ: "clients_list.html"},
    show: {
      attr: "data-username",
      args: [{key: "nickname"}], // attr is optional for override -  attr: "data-username"}],
      triggers: [
        {action: "click", class: "button.user.user-card-message"},
        {action: "click", class: ".mention-link"},
        {action: "click", class: "li.user-card-room button"},
        {function: custom_show_switch_user}
      ]
    }
   },
  "Notifications": {},
  "Files List": {},
  "Mentions": { args: {templ: "mentions.html"} },
  "Stared Messages": { args: {templ: "stared_messages.html"}},
  "Knowledge Base": {hidden: true},
  "Pinned Messages": {args: {templ: "pinned_messages.html"}},
  "Past Chats": {hidden: true},
  "OTR": {hidden: true},
  "Video Chat": {hidden: true},
  "Snipped Messages": {},
  "Logout": {function: function() { window.location.href = "/logout"} },
  "Switch User": {args: {templ: "switch_user_list.html"}}
}

function open_tab(tab, elem) {
  if (debug) { console.log('open_tab', tab) }

  if (Object.keys(tab).length == 0) {
    if (debug) { console.log(tab.name + ' clicked ...') }
  } else {
    push_topic(tab.topic, tab.args)
    $('.tab-button').removeClass('active')
    $(elem).addClass('active')
  }
}


$(document).ready(function() {
  let settings = {};

  Object.keys(default_settings).forEach(function(key) {
    set_tab_defaults(settings, key)
  })

  Object.keys(settings).forEach(function(key) {
    $('body').on('click', `.tab-button[title='${key}']`, function() {
      if (debug) { console.log(`${key} button clicked...`) }
      if (settings[key].function) {
        settings[key].function()
      } else {
        let is_same = $('section.flex-tab .title h2').html() == key
        if ($('section.flex-tab').parent().hasClass('opened') && is_same) {
          close_flex_tab($(this))
        } else {
          open_tab(settings[key], $(this))
        }
      }
    })

    if (settings[key].show) {
      let show = settings[key].show;
      console.log('show', show)

      // iterate over each of the triggers
      show.triggers.forEach(function(trigger) {
        if (trigger.function) {
          console.log('using trigger function for show')
          trigger.function()
        } else {
          let topic = settings[key].topic
          if (show.topic) { topic = show.topic }
          console.log('trigger', trigger, topic)
          $('body').on(trigger.action, trigger.class, function() {
            let new_args = build_show_args($(this), settings[key].args, show)
            console.log('show, topic, new_args', show, topic, new_args)
            push_topic(topic, new_args)
          })
        }
      })
    }
  })

  notifications.forEach(function(notification) {
    roomchan.on(notification.event, msg => {
      if ($(`.tab-button[title="${notification.title}"]`).hasClass('active')) {
        let key = notification.title
        let settings = {}
        set_tab_defaults(settings, key)
        let tab = settings[key]
        let scroll_pos = $('.flex-tab-container .content').scrollTop().valueOf()
        push_topic(tab.topic, tab.args, function() {
          $('.flex-tab-container .content').scrollTop(scroll_pos)
        })
      }
    })
  })

  $('body').on('click', '.flex-tab-container .user-view nav .button.back', function() {
    $('.flex-tab-container .user-view').addClass('animated-hidden')
  })

})

//////////////////
// Custom Handlers

function custom_show_switch_user() {
  console.log('custom_show_switch_user')
  $('body').on('click', 'li.user-card-room.switch-user button', function() {
    let username = $(this).attr('data-username')
    window.location.href = "/switch_user/" + username
  })
}

////////////////
// Helpers

function set_tab_defaults(settings, key) {
  settings[key] = Object.assign({name: key}, default_settings[key])
  settings[key] = Object.assign({topic: key}, default_settings[key])
}


function close_flex_tab(elem) {
  if ($('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').html('').parent().removeClass('opened')
    $(elem).removeClass('active')
  }
}
function open_flex_tab(elem) {
  if (!$('section.flex-tab').parent().hasClass('opened')) {
    $('section.flex-tab').parent().addClass('opened')
    $('.tab-button').removeClass('active')
    $(elem).addClass('active')
  }
}

function push_topic(topic, args, callback) {
  if (topic) {
    let full_topic = "flex_bar:click:" + topic
    cc.push(full_topic, args)
      .receive("ok", resp => {
        $('section.flex-tab').html(resp.html).parent().addClass('opened')
        if (callback) { callback() }
        main.run()
      })
  }
}

function build_show_args(current, pargs, show) {
  let new_args = {}
  let args = show.args
  args.forEach(function(arg) {
    let attr = show.attr
    if (arg.attr) { attr = arg.attr }
    new_args[arg.key] = current.attr(attr)
  })
  return Object.assign(pargs, new_args);
}
