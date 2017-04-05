// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket, Presence} from "phoenix"

window.root = global || window

require('./autogrow')
import Messages from "./messages"
import Typing from "./typing"
import RoomManager from "./room_manager"
import MessagePopup from "./message_popup"
import MessageCog from "./message_cog"
import SideNav from "./side_nav"
import Admin from "./admin"
import AdminFlexBar from "./admin_flex_bar"
import RoomHistoryManager from "./room_history_manager"
import DesktopNotification from "./desktop_notification"
import Menu from './menu'
import * as main from "./main"
import * as flexbar from "./flex_bar"
import * as cc from "./chat_channel"
import hljs from "highlight.js"
import toastr from 'toastr'
import * as sweet from "./sweetalert.min"
import * as utils from "./utils"
import FileUpload from "./file_upload"
import MessageInput from './message_input'
window.moment = require('moment');
require('./chat_dropzone')
const chan_user = "user:"
const chan_room = "room:"
const chan_system = "system:"

const debug = false;

let socket = new Socket("/socket", {params: {token: window.user_token, tz_offset: new Date().getTimezoneOffset() / -60}})

window.userchan = false
window.roomchan = false
window.systemchan = false

hljs.initHighlightingOnLoad();

// new presence stuff
let presences = {}

let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}

let listBy = (user, {metas: metas, username: username}) => {
  // console.log('listBy user', user, 'metas', metas)
  return {
    user: user,
    username: metas[0].username,
    status: metas[0].status
  }
}

let userList = document.getElementById("UserList")

function update_presence(elem, status) {
  if (typeof elem === "object" &&  elem.length > 0) {
    elem.attr('class', elem.attr('class').replace(/status-([a-z]+)/, 'status-' + status))
  }
}

let render = (presences) => {
  Presence.list(presences, listBy)
    .map(presence => {
      let status = presence.status
      let elem = $(`.info[data-status-name="${presence.username}"]`)
      if (typeof elem === "object" &&  elem.length > 0) {
        elem.children(':first-child').data('status', status)
      }
      update_presence($(`[data-status-name="${presence.username}"]`), status)
    })
}
// end of presence stuff

$(document).ready(function() {


  setTimeout(() => {
    $('#initial-page-loading').remove()
    utils.remove_page_loading()
  }, 1000)

  let ucxchat = window.ucxchat
  let typing = new Typing(ucxchat.typing)

  window.roomManager = new RoomManager()
  window.scroll_to = roomManager.scroll_to
  window.desktop_notifier = new DesktopNotification()
  window.roomHistoryManager = new RoomHistoryManager()
  window.fileUpload = new FileUpload()

  new Messages()

  new SideNav()
  new Admin()
  new AdminFlexBar()
  new MessageInput()
  window.messageCog = new MessageCog()
  window.navMenu = new Menu()

  socket.connect()
  socket.onError( () => {
    console.log("!! there was an error with the connection!")
    handleOffLine()
    UcxChat.onLine = false
  })
  socket.onClose( () => {
    console.log("!! the connection dropped")
    handleOffLine()
    UcxChat.onLine = false
  })

  UcxChat.onLine = true

  if (flash_error != "")
    toastr.error(flash_error)

  $('textarea.message-form-text').focus()

  start_system_channel()
  start_user_channel()
  start_room_channel(typing)

  $('body').on('submit', '.message-form', e => {
    if (debug) { console.log('message-form submit', e) }
  })
  .on('keydown', '.message-form-text', e => {
    let event = new jQuery.Event('user:input')
    switch(e.keyCode) {
      case 38: // up arrow
      case 40: // down arrow
      case 9:  // TAB
        event.keyCode = e.keyCode
        $("body").trigger(event)
        return false
      case 8:  // BS
        event.keyCode = e.keyCode
        $("body").trigger(event)
      default:
        return true
    }
  })
  .on('keypress', '.message-form-text', e => {
    if (debug) { console.log('message-form-text keypress', e) }
    if (e.keyCode == 13 && e.shiftKey) {
      return true
    }
    if(e.keyCode == 13) {
      if (message_popup.handle_enter()) {
        // console.log('return ', $('.message-form-text').hasClass('editing'))
        if ($('.message-form-text').hasClass('editing')) {
          // console.log('editing submit...', $('li.message.editing').attr('id'))
          Messages.send_message({update: $('li.message.editing').attr('id'), value: $('.message-form-text').val()})
        } else {
          Messages.send_message($('.message-form-text').val())
        }
      }
      typing.clear()
      return false
    } //else if (e.keyCode == 64) {
    //   message_popup.open_users()
    //   return true
    // }
    let event = new jQuery.Event('user:input')
    event.keyCode = e.keyCode
    $("body").trigger(event)

    typing.start_typing()
    return true
  })
  .on('restart-socket', () => {
    start_room_channel(typing)
  })

  navMenu.setup()

  $('#initial-page-loading').remove()
  utils.remove_page_loading()
})

function start_system_channel() {
  systemchan = socket.channel(chan_system, {user: ucxchat.username, channel_id: ucxchat.channel_id})
  let chan = systemchan
  chan.onError( () => true )
  chan.onClose( () => true )

  chan.on('presence_state', state => {
    // console.log('presence_state', state)
    presences = Presence.syncState(presences, state)
    render(presences)
  })
  chan.on('presence_diff', diff => {
    // console.log('presence_diff', diff)
    presences = Presence.syncDiff(presences, diff)
    render(presences)
  })

  chan.join()
    .receive("ok", resp => {
      console.log('Joined system channel successfully', resp)
      handleOnLine()
    })
    .receive("error", resp => {
      console.error('Unable to join system channel', resp)
      handleOffLine()
    })
}

function start_user_channel() {
  userchan = socket.channel(chan_user + ucxchat.user_id, {user: ucxchat.username, channel_id: ucxchat.channel_id})
  let chan = userchan

  chan.onError( () => true )
  chan.onClose( () => true )

  chan.on('room:update:name', resp => {
    if (debug) { console.log('room:update', resp) }
    $('li.link-room-' + resp.old_name)
      .removeClass('.room-link-' + resp.old_name)
      .addClass('.room-link-' + resp.new_name)
      .children(':first-child')
      .attr('title', resp.new_name).attr('data-room', resp.new_name)
      .attr('data-name', resp.new_name)
      .children(':first-child').attr('class', resp.icon + ' off-line')
      .next('span').html(resp.new_name)
  })
  chan.on('room:join', resp => {
    console.log('room:join', resp)
  })
  chan.on('room:leave', resp => {
    console.log('room:leave', resp)
  })
  chan.on('code:update', resp => {
    console.log('code:update', resp)
    utils.code_update(resp)
  })
  chan.on('window:reload', resp => {
    console.log('location')
    if (resp.mode == undefined || resp.mode == false)
      window.location.reload()
    else
      window.location = '/home'
  })

  chan.on("toastr:success", resp => {
    toastr.success(resp.message)
  })

  chan.on("toastr:error", resp => {
    toastr.error(resp.message)
  })
  chan.on("room:mention", resp => {
    roomManager.room_mention(resp)
  })
  chan.on("notification:new", resp => {
    roomManager.notification(resp)
  })
  chan.on('message:preview', msg => {
    message_preview(msg)
  })
  chan.on('update:alerts', msg => {
    roomManager.update_burger_alert()
  })

  chan.join()
    .receive("ok", resp => { console.log('Joined user successfully', resp)})
    .receive("error", resp => { console.log('Unable to user lobby', resp)})

  chan.push('subscribe', {})
}

function message_preview(msg) {
  setTimeout(() => {
    let bottom = utils.is_scroll_bottom()
    if (msg.html)
      $('#' + msg.message_id + ' div.body').append(msg.html)
    if  (bottom) {
      utils.scroll_bottom()
    }
  }, 100)
}
export function restart_socket() {
  let event = jQuery.Event( "restart-socket" );
  $("body").trigger(event)
}

function start_room_channel(typing) {
  let room = ucxchat.room
  // Now that you are connected, you can join channels with a topic:
  roomchan = socket.channel(chan_room + room, {user: ucxchat.username, user_id: ucxchat.user_id})

  let chan = roomchan

  if (debug) { console.log('start socket', ucxchat) }

  chan.onError( () => true )
  chan.onClose( () => true )

  chan.join()
    .receive("ok", resp => {
      utils.push_history()
      console.log("Joined successfully", resp)
    })
    .receive("error", resp => { console.log("Unable to join", resp) })

  chan.on("user:entered", msg => {
    // console.warn("user:entered", msg)

  })

  chan.on("user:leave", msg => {
    // console.warn("user:leave", msg)

  })

  chan.on("message:new", msg => {
    if (debug) { console.log('message:new current id, msg.user_id', msg, ucxchat.user_id, msg.user_id) }
    Messages.new_message(msg)
  })
  chan.on("message:update", msg => {
    if (debug) { console.log('message:update current id, msg.user_id', msg, ucxchat.user_id, msg.user_id) }
    Messages.update_message(msg)
  })

  chan.on("typing:update", msg => {
    if (debug) { console.log('typing:update', msg) }
    typing.update_typing(msg.typing)
  })

  chan.on("room:update", msg => {
    roomManager.update(msg)
  })

  chan.on("toastr:success", resp => {
    toastr.success(resp.message)
  })

  chan.on("toastr:error", resp => {
    toastr.error(resp.message)
  })

  chan.on("sweet:open", resp => {
    $('.sweet-container').html(resp.html)
  })

  chan.on('update:Members List', msg => {
    //console.log('update:Members List', msg)
    // console.log('update:Members List', msg, $('.tab-button[title="Members List"]').hasClass('active'))
  })
  chan.on('code:update', resp => {
    console.log('code:update', resp)
    utils.code_update(resp)
  })
  chan.on('code:update:reaction', resp => {
    utils.code_update(resp)
  })
  chan.on('reload', msg => {
    let loc = msg.location
    if (!loc) { loc = "/" }
    console.log('location', loc)
    window.location = loc
  })
  chan.on('message:preview', msg => {
    message_preview(msg)
  })

  if (!window.flexbar) {
    flexbar.init_flexbar()
  }
  roomManager.clear_unread()
  roomManager.new_room()
  roomHistoryManager.scroll_new_window()

  main.run()
  roomManager.updateMentionsMarksOfRoom()

  navMenu.close()
}

function checkVisible(elm, threshold, mode) {
  threshold = threshold || 0;
  mode = mode || 'visible';
  // elm = elm[0]
  var rect = elm.getBoundingClientRect();
  var wr = $('.wrapper.has-more-next')[0].getBoundingClientRect()
  var viewHeight = wr.top + wr.bottom
  var above = rect.bottom - threshold < 0;
  var below = rect.top - viewHeight + threshold >= 0;

  return mode === 'above' ? above : (mode === 'below' ? below : !above && !below);
}
function isOnScreen(element)
{
    var curPos = element.offset();
    var curTop = curPos.top;
    var screenHeight = $(window).height();
    return (curTop > screenHeight) ? false : true;
}

const offlineContent = `
  <div class="alert alert-warning text-center" role="alert">
    <strong>
      <span class="glyphicon glyphicon-warning-sign"></span>
      Waiting for server connection,
    </stong>
    <a href="/" class="alert-link">Try now</a>
  </div>`

function handleOffLine() {
  if (UcxChat.onLine) {
    $('.connection-status').html('').append(offlineContent).removeClass('status-online')

    UcxChat.onLine = false
  }
}
function handleOnLine() {
  if (!UcxChat.onLine) {
    UcxChat.onLine = true
    window.location.reload()
    $('.connection-status').html('').addClass('status-online')
  }

}
window.cv = checkVisible

export default socket
