// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket, Presence} from "phoenix"

import Messages from "./messages"
import Typing from "./typing"
import RoomManager from "./room_manager"
import UnreadManager from "./unread_manager"
import MessagePopup from "./message_popup"
import MessageCog from "./message_cog"
import SideNav from "./side_nav"
import Admin from "./admin"
import * as main from "./main"
import * as flexbar from "./flex_bar"
import * as cc from "./chat_channel"
import hljs from "highlight.js"

const chan_user = "client:"
const chan_room = "room:"
const chan_system = "system:"

const debug = true;

let socket = new Socket("/socket", {params: {token: window.user_token}})

window.clientchan = false
window.roomchan = false
window.systemchan = false

hljs.initHighlightingOnLoad();

// new presence stuff
let presences = {}

let formatTimestamp = (timestamp) => {
  let date = new Date(timestamp)
  return date.toLocaleTimeString()
}

let listBy = (user, {metas: metas, nickname: nickname}) => {
  console.log('listBy user', user, 'metas', metas)
  return {
    user: user,
    // onlineAt: formatTimestamp(metas[0].online_at),
    nickname: metas[0].nickname,
    status: metas[0].status
  }
}

let userList = document.getElementById("UserList")

function update_presence(elem, status) {
  if (typeof elem === "object" &&  elem.length > 0) {
    elem.attr('class', elem.attr('class').replace(/ status-(.*)$/, ' status-' + status))
  }
}

let render = (presences) => {
  Presence.list(presences, listBy)
    .map(presence => {
      let status = presence.status
      let elem = $(`.info[data-status-name="${presence.nickname}"]`)
      if (typeof elem === "object" &&  elem.length > 0) {
        update_presence(elem, status)
        elem.children(':first-child').data('status', status)
      }
      update_presence($(`a[data-room] i[data-status-name="${presence.nickname}"]`), status)
      update_presence($(`li.user-card-room[data-status-name="${presence.nickname}"]`), status)
    })
}
// end of presence stuff

$(document).ready(function() {

  let ucxchat = window.ucxchat
  let typing = new Typing(ucxchat.typing)

  new RoomManager()
  new SideNav()
  new Admin()

  socket.connect()

  $('textarea.message-form-text').focus()

  console.log('socket...', socket)
  start_system_channel()
  start_client_channel()
  start_room_channel(typing)

  $('body').on('submit', '.message-form', e => {
    if (debug) { console.log('message-form submit', e) }
  })
  $('body').on('keydown', '.message-form-text', e => {
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

  $('body').on('keypress', '.message-form-text', e => {
    if (debug) { console.log('message-form-text keypress', e) }
    if (e.keyCode == 13 && e.shiftKey) {
      return true
    }
    if(e.keyCode == 13) {
      message_popup.handle_enter()
      Messages.send_message($('.message-form-text').val())
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


  $('body').on('click', 'a.open-room', function(e) {
    e.preventDefault();
    if (debug) { console.log('clicked a.open-room', e, $(this), $(this).attr('data-room')) }
    // roomchan.push("room:open", {client_id: ucxchat.client_id, display_name: $(this).attr('data-name'), room: $(this).attr('data-room'), old_room: ucxchat.room})
    //   .receive("ok", resp => { RoomManager.render_room(resp) })
    cc.get("/room/" + $(this).attr('data-room'), {display_name: $(this).attr('data-name'), room: ucxchat.room})
      .receive("ok", resp => { RoomManager.render_room(resp) })
  })
  $('body').on('click', 'a.toggle-favorite', e => {
    if (debug) { console.log('click a.toggle-favorite') }
    e.preventDefault();
    RoomManager.toggle_favorite()
  })
  $('body').on('click', '.button.pvt-msg', function(e) {
    if (debug) { console.log('click .button.pvt-msg') }
    e.preventDefault();
    RoomManager.add_private($(this))
  })

  $('body').on('restart-socket', () => {
    start_room_channel(typing)
  })

})

function start_system_channel() {
  systemchan = socket.channel(chan_system, {user: ucxchat.nickname, channel_id: ucxchat.channel_id})
  let chan = systemchan

  chan.on('presence_state', state => {
    console.log('presence_state', state)
    presences = Presence.syncState(presences, state)
    render(presences)
  })
  chan.on('presence_diff', diff => {
    console.log('presence_diff', diff)
    presences = Presence.syncDiff(presences, diff)
    render(presences)
  })

  chan.join()
    .receive("ok", resp => { console.log('Joined system channel successfully', resp)})
    .receive("error", resp => { console.error('Unable to join system channel', resp)})
}

function start_client_channel() {
  clientchan = socket.channel(chan_user + ucxchat.client_id, {user: ucxchat.nickname, channel_id: ucxchat.channel_id})
  let chan = clientchan

  chan.on('room:update:name', resp => {
    if (debug) { console.log('room:update', resp) }
    $('li.link-room-' + resp.old_name)
      .removeClass('.room-link-' + resp.old_name)
      .addClass('.room-link-' + resp.new_name)
      .children(':first-child')
      .attr('title', resp.new_name).attr('data-room', resp.new_name)
      .attr('data-name', resp.new_name)
      .children(':first-child').attr('class', 'icon-' + resp.icon + ' off-line')
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
    $(resp.selector)[resp.action](resp.html)
  })
  chan.on('window:reload', resp => {
    window.location.reload()
  })

  chan.join()
    .receive("ok", resp => { console.log('Joined client successfully', resp)})
    .receive("error", resp => { console.log('Unable to client lobby', resp)})

  chan.push('subscribe', {})
}

export function restart_socket() {
  let event = jQuery.Event( "restart-socket" );
  $("body").trigger(event)
}

function start_room_channel(typing) {
  // socket.connect({user: ucxchat.nickname})
  let room = ucxchat.room
  // Now that you are connected, you can join channels with a topic:
  roomchan = socket.channel(chan_room + room, {user: ucxchat.nickname, user_id: ucxchat.client_id})

  let chan = roomchan

  if (debug) { console.log('start socket', ucxchat) }
  chan.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  chan.on("user:entered", msg => {
    console.warn("user:entered", msg)

  })

  chan.on("user:leave", msg => {
    console.warn("user:leave", msg)

  })

  chan.on("message:new", msg => {
    if (debug) { console.log('message:new current id, msg.client_id', msg, ucxchat.client_id, msg.client_id) }
      // console.log('message:new', chan.params.user)
    Messages.new_message(msg)
  })

  chan.on("typing:update", msg => {
    if (debug) { console.log('typing:update', msg) }
    typing.update_typing(msg.typing)
  })

  chan.on("room:update", msg => {
    RoomManager.update(msg)
  })

  if (!window.flexbar) {
    flexbar.init_flexbar()
  }
  main.run()
  main.update_flexbar()

}

// function checkVisible(elm, threshold, mode) {
//   threshold = threshold || 0;
//   mode = mode || 'visible';

//   var rect = elm.getBoundingClientRect();
//   var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
//   var above = rect.bottom - threshold < 0;
//   var below = rect.top - viewHeight + threshold >= 0;

//   return mode === 'above' ? above : (mode === 'below' ? below : !above && !below);
// }
function checkVisible(elm, threshold, mode) {
  threshold = threshold || 0;
  mode = mode || 'visible';
  // elm = elm[0]
  var rect = elm.getBoundingClientRect();
  // var viewHeight = Math.max(document.documentElement.clientHeight, window.innerHeight);
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
window.cv = checkVisible
// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.


export default socket
