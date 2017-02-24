import * as cc from './chat_channel'
import * as main from './main'
import * as fbar_form from './flex_bar_form'

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

// function open_tab(tab, elem) {
//   if (debug) { console.log('open_tab', tab) }

//   if (Object.keys(tab).length == 0) {
//     if (debug) { console.log(tab.name + ' clicked ...') }
//   } else {
//     push_topic(tab.topic, tab.args)
//     $('.tab-button').removeClass('active')
//     $(elem).addClass('active')
//   }
// }


export function init_flexbar() {
  let settings = {};

  window.flexbar = true;

  Object.keys(default_settings).forEach(function(key) {
    set_tab_defaults(settings, key)
  })

  Object.keys(settings).forEach(function(key) {
    $('body').on('click', `.tab-button[title='${key}']`, function() {
      if (debug) { console.log(`${key} button clicked...`) }
      if (settings[key].function) {
        settings[key].function()
      } else {
        // push_click(key, settings[key].args)
        clientchan.push("flex:open:" + key, settings[key].args)
      }
    })

    if (settings[key].show) {
      let show = settings[key].show;
      // console.log('show', show)

      // iterate over each of the triggers
      show.triggers.forEach(function(trigger) {
        if (trigger.function) {
          // console.log('using trigger function for show')
          trigger.function()
        } else {
          let topic = settings[key].topic
          if (show.topic) { topic = show.topic }
          // console.log('trigger', trigger, topic)
          $('body').on(trigger.action, trigger.class, function() {
            let new_args = build_show_args($(this), settings[key].args, show)
            console.log('show, topic, new_args', show, topic, new_args)
            // push_click(topic, new_args)
            clientchan.push("flex:item:open:" + topic, {args: new_args})
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
        push_click(tab.topic, tab.args, function() {
          $('.flex-tab-container .content').scrollTop(scroll_pos)
        })
      }
    })
  })

  $('body').on('click', '.flex-tab-container .user-view nav .button.back', function() {
    $('.flex-tab-container .user-view').addClass('animated-hidden')
    clientchan.push('flex:view_all:' + $('.tab-button.active').attr('title'))
  })

  clientchan.on('flex:open', msg => {
    $('section.flex-tab').html(msg.html).parent().addClass('opened')
    $('.tab-button.active').removeClass('active')
    set_tab_button_active(msg.title)
  })
  clientchan.on('flex:close', msg => {
    $('section.flex-tab').parent().removeClass('opened')
    $('.tab-button.active').removeClass('active')
  })

  // fbar_form.init()
}

function push_click(title, args, callback) {
  // console.log('push_click', title, args)
  if (title) {
    let full_topic = "flex_bar:click:" + title
    cc.push(full_topic, args)
      .receive("ok", resp => {
        // console.log('push_click resp', resp)
        if (resp.open) {
          $('section.flex-tab').html(resp.html).parent().addClass('opened')
          $('.tab-button.active').removeClass('active')
          set_tab_button_active(title)
        } else if (resp.close) {
          $('section.flex-tab').parent().removeClass('opened')
          $('.tab-button.active').removeClass('active')
        }
        if (callback) { callback() }
        // main.run()
      })
  }
}
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

function get_tab_button(title) {
  return $(`.tab-button[title="${title}"]`)
}

function is_tab_button_active(title) {
  return get_tab_button().hasClass('active')
}

function set_tab_button_active(title) {
  return get_tab_button(title).addClass('active')
}

function set_tab_buttons_inactive() {
  $('.tab-button').removeClass('active')
}

function is_tab_bar_open() {
  return $(`.tab-button.active`).length > 0
}

function set_tab_defaults(settings, key) {
  settings[key] = Object.assign({name: key}, default_settings[key])
  settings[key] = Object.assign({topic: key}, default_settings[key])
}

function get_tab_container() {
  return $('.flex-tab-container')
}
function is_tab_container_open() {
  return get_tab_container().hasClass('opened')
}
function open_tab_container() {
  return get_tab_container().addClass('opened')
}
function close_tab_container() {
  return get_tab_container().removeClass('opened')
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

export function update_flexbar() {
  console.log('flex_bar.update_flexbar')
  cc.push('flex_bar:get_open')
    .receive("ok", resp => {
       // console.log('flex_bar.update_flexbar after resp', resp)
      let ftab = resp.ftab
      if (ftab) {
        // console.log('flex_bar.update_flexbar after if', ftab)
        // console.log('checking...', is_tab_bar_open(), is_tab_button_active(ftab.title))
        if (!is_tab_container_open() || !is_tab_button_active(ftab.title)) {
          set_tab_button_active(ftab.title)
          open_tab_container();
        } else {
          let settings = {}
          set_tab_defaults(settings, ftab.title)
          // console.log('update_flexbar resp', resp)
          // set_tab_button_active(ftab.title)
          push_click(ftab.title, Object.assign(ftab.args, settings[ftab.title].args))
        }
      // } else {
        console.log('flex_bar.update_flexbar after else', resp, is_tab_bar_open())
        if (is_tab_bar_open()) {
          $('section.flex-tab').parent().removeClass('opened')
          set_tab_buttons_inactive()
        }
        // console.log('update_flexbar resp not open', resp)
      }
    })
}
