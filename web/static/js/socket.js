// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

// let socket = new Socket("/socket", {params: {token: window.userToken}})
let socket = new Socket("/socket")

$(document).ready(function() {

  let ucxchat = window.ucxchat

  start_socket()

  $('body').on('submit', '.message-form', function(e) {
    console.log('message-form submit', e)
  })
  $('body').on('keypress', '.message-form-text', function(e) {
    console.log('message-form-text keypress', e)
    if(e.keyCode == 13) {
      let msg = $('.message-form-text').val()
      console.log('msg', msg)
      send_message(ucxchat.chan, ucxchat.room, msg)
      $('.message-form-text').val('')
      ucxchat.typing = false
      return false
    }
    if (!ucxchat.typing) {
      ucxchat.typing = true
      setTimeout(typing_timer_timeout, 15000, ucxchat.channel_id, ucxchat.client_id)
      ucxchat.chan.push("typing:start", {channel_id: ucxchat.channel_id,
        client_id: ucxchat.client_id, nickname: ucxchat.nickname, room: ucxchat.room})
    }
    return true
  })


  $('body').on('click', 'a.open-room', function() {
    console.log('clicked...', $(this).attr('data-room'))
    ucxchat.chan.push("room:open", {client_id: ucxchat.client_id, room: $(this).attr('data-room'), old_room: ucxchat.room})
      .receive("ok", resp => { render_room(resp) })
  })

})

function start_socket() {

  let room = ucxchat.room
  socket.connect()
  // Now that you are connected, you can join channels with a topic:
  let chan = socket.channel("ucxchat:room-"+room, {})
  ucxchat.chan = chan

  chan.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  chan.on("user:join", msg => {
    console.log("user:join", msg)

  })
  chan.on("user:leave", msg => {
    console.log("user:leave", msg)

  })
  chan.on("message", msg => {
    let sequential = false
    console.log("received message", msg)
    if(msg.client_id == ucxchat.last_client_id) {
      if(msg.client_id == ucxchat.client_id)
        sequential = " sequential own"
      else
        sequential = " sequential"
    } else {
      sequential = false
    }
    ucxchat.sequential = sequential
    ucxchat.last_client_id = msg.client_id
    add_message(msg, sequential)
  })

  chan.on("message:new", msg => {
    console.log('message:new current id, msg.client_id', msg, ucxchat.client_id, msg.client_id )
    $('.messages-box .wrapper > ul').append(msg.html)

    let myPanel = $('.messages-box .wrapper')
    myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());


    if (ucxchat.client_id == msg.client_id) {
      console.log('adding own to', msg.id, $('#' + msg.id))
      $('#' + msg.id).addClass("own")
    }
  })

  chan.on("typing:update", msg => {
    console.log('typing:update', msg)
    let typing = msg.typing

    if (typing.indexOf(ucxchat.nickname) < 0) {
      update_typing(false, typing)
    } else {
      remove(typing, ucxchat.nickname)
      update_typing(true, typing)
    }
  })

}

function render_room(msg) {
  $('.link-room-' + ucxchat.room).removeClass("active")
  console.log('room:render', msg, msg.html.length)
  $('.messages-box').html(msg.html)
  ucxchat.channel_id = msg.channel_id
  ucxchat.room = msg.room_title
  $('.room-title').html(ucxchat.room)
  $('.link-room-' + ucxchat.room).addClass("active")
  socket.disconnect()
  start_socket()
}

function remove(arr, item) {
  console.log('remove', arr, item)
    for(var i = arr.length; i--;) {
        if(arr[i] === item) {
            arr.splice(i, 1);
        }
    }
}

function update_typing(self_typing, list) {
  console.log('update_typing', self_typing, list)
  let len = list.length
  let prepend = ""
  if (len > 1) {
    if (self_typing)
      prepend = " are also typing"
    else
      prepend = " are typing"
  } else if (len == 0) {
    $('form.message-form .users-typing').html('')
    return
  } else {
    if (self_typing)
      prepend = " is also typing"
    else
      prepend = " is typing"
  }

  $('form.message-form .users-typing').html("<strong>" + list.join(", ") + "</strong>" + prepend)
}

function typing_timer_timeout(channel_id, client_id) {
  console.log('typing_timer_timeout')
  if ($('.message-form-text').val() == '') {
    if (ucxchat.typing) {
      // assume they cleared the textedit and did not send
      ucxchat.typing = false
      ucxchat.chan.push("typing:stop", {channel_id: channel_id, client_id: client_id, room: ucxchat.room})
    }
  } else {
    setTimeout(typing_timer_timeout, 15000, channel_id, client_id)
  }
}
function send_message(chan, room, msg) {
  let user = window.ucxchat.user_id
  let ucxchat = window.ucxchat
  console.log('user', user)
  chan.push("message", {message: msg, user_id: user, room: ucxchat.room, nickname: ucxchat.nickname,
    client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
}
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
