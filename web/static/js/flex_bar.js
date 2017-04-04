import * as cc from './chat_channel'
import * as main from './main'
import * as fbar_form from './flex_bar_form'
import * as utils from './utils'

const debug = false;

const im_mode = "IM Mode"
const rooms_mode = "Rooms Mode"

const notifications = [
  {event: "update:pinned", title: "Pinned Messages"},
  {event: "update:stared", title: "Stared Messages"}
]

const default_settings = {
  "IM Mode": {},
  "Rooms Mode": {},
  "Info": { args: {templ: "channel_settings.html"} },
  "Search": {},
  "User Info": { args: {templ: "user_card.html"}},
  "Members List": {
    args: {templ: "users_list.html"},
    show: {
      attr: "data-username",
      args: [{key: "username"}], // attr is optional for override -  attr: "data-username"}],
      triggers: [
        {action: "click", class: "button.user.user-card-message"},
        {action: "click", class: ".mention-link:not([data-channel])"},
        {action: "click", class: "li.user-card-room button"},
        {function: custom_show_switch_user}
      ]
    }
   },
  "Notifications": { args: {templ: "notifications.html"}},
  "Files List": {args: {templ: "files_list.html"}},
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
      if (key == im_mode) {
        userchan.push("mode:set:im")
          .receive("ok", resp => {
            $(`.tab-button[title='${key}']`).addClass('hidden')
            $(`.tab-button[title='${rooms_mode}']`).removeClass('hidden')
          })
      } else if (key == rooms_mode) {
        userchan.push("mode:set:rooms")
          .receive("ok", resp => {
            $(`.tab-button[title='${key}']`).addClass('hidden')
            $(`.tab-button[title='${im_mode}']`).removeClass('hidden')
          })
      } else if (settings[key].function) {
        settings[key].function()
      } else {
        // push_click(key, settings[key].args)
        userchan.push("flex:open:" + key, settings[key].args)
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
            userchan.push("flex:item:open:" + topic, {args: new_args})
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
    userchan.push('flex:view_all:' + $('.tab-button.active').attr('title'))
  })
  $('body').on('click', '.list-view button.show-all', function(e) {
    e.preventDefault()
    console.log('see all clicked!')
    userchan.push('flex:member-list:show-all', {channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        utils.code_update(resp)

        $('button.see-all').removeClass('show-all').addClass('show-online').text("Show only online")

        update_showing_count()
      })
    // TODO: need to internationalize these strings
    return false
  })
  $('body').on('click', '.list-view button.show-online', function(e) {
    e.preventDefault()
    console.log('show-online clicked!')
    // userchan.push('flex:member-list:show-online', {channel_id: ucxchat.channel_id})
    $('.list-view ul.lines li.status-offline').remove()
    $('button.see-all').removeClass('show-online').addClass('show-all').text("Show all")
    update_showing_count()
    return false
  })
  .on('click', '.uploaded-files-list .file-delete', e => {
    let id = $(e.currentTarget).parent().data('id')
    sweetAlert({
      title: gettext.are_you_sure,
      text: gettext.you_will_not_be_able_to_recover_this_message,
      type: "warning",
      showCancelButton: true,
      confirmButtonColor: "#DD6B55",
      confirmButtonText: gettext.yes_delete_it,
      closeOnConfirm: false
    },
    function(){
      cc.delete_("/attachment/" + id)
        .receive("ok", resp => {
          swal({
            title: gettext.deleted,
            text: gettext.your_entry_has_been_deleted,
            type: 'success',
            timer: 1500,
            showConfirmButton: false,
          })
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    });
  })

  userchan.on('flex:open', msg => {
    console.log('receive flex:open', msg)
    $('section.flex-tab').html(msg.html).parent().addClass('opened')
    $('.tab-button.active').removeClass('active')
    set_tab_button_active(msg.title)
  })
  userchan.on('flex:close', msg => {
    $('section.flex-tab').parent().removeClass('opened')
    $('.tab-button.active').removeClass('active')
  })

  userchan.on('update:rooms', msg => {
    console.log('update:rooms', msg)
    $('aside .rooms-list').html(msg.html)
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

function update_showing_count() {
  $('.showing-cnt').text($('.list-view ul.lines li').length)
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

export function get_tab_button(title) {
  return $(`.tab-button[title="${title}"]`)
}

export function is_tab_button_active(title) {
  return get_tab_button().hasClass('active')
}

export function set_tab_button_active(title) {
  return get_tab_button(title).addClass('active')
}

export function set_tab_buttons_inactive() {
  $('.tab-button').removeClass('active')
}

export function is_tab_bar_open() {
  return $(`.tab-button.active`).length > 0
}

function set_tab_defaults(settings, key) {
  settings[key] = Object.assign({name: key}, default_settings[key])
  settings[key] = Object.assign({topic: key}, default_settings[key])
}

export function get_tab_container() {
  return $('.flex-tab-container')
}
export function is_tab_container_open() {
  return get_tab_container().hasClass('opened')
}
export function open_tab_container() {
  return get_tab_container().addClass('opened')
}
export function close_tab_container() {
  return get_tab_container().removeClass('opened')
}
export function toggle_tab_container() {
  return get_tab_container().toggleClass('opened', '')
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
