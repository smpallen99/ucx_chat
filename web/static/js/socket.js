// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"

// let socket = new Socket("/socket", {params: {token: window.userToken}})
let socket = new Socket("/socket")


$(document).ready(function() {

  socket.connect()
  let ucxchat = window.ucxchat
  let room = ucxchat.room

  // Now that you are connected, you can join channels with a topic:
  let chan = socket.channel("ucxchat:room-"+room, {})
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

  $('body').on('submit', '.message-form', function(e) {
    console.log('message-form submit', e)
  })
  $('body').on('keypress', '.message-form-text', function(e) {
    // console.log('message-form-text keypress', e)
    if(e.keyCode == 13) {
      let msg = $('.message-form-text').val()
      console.log('msg', msg)
      send_message(chan, room, msg)
      $('.message-form-text').val('')
      return false
    }
  })

  // $("body").keypress(function(e) {
  //   console.log('keypress', e.keyCode)
  //   let keycode = e.keyCode
  //   if(keycode == 13) {

  //   }

  // })
})
function send_message(chan, room, msg) {
  let user = window.ucxchat.user_id
  let ucxchat = window.ucxchat
  console.log('user', user)
  chan.push("message", {message: msg, user_id: user, room: ucxchat.room, nickname: ucxchat.nickname,
    client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
}
function add_message(msg, sequential) {
  let seq = ""
  if(sequential) seq = sequential
  let entry =
   `<li id="${msg.id}" class="message background-transparent-dark-hover${seq}" data-username="${msg.nickname}" data-date="${msg.date}" data-timestamp="${msg.timestamp}">
      <button class="thumb user-card-message" data-username="${msg.nickname}" tabindex="1">
        <div class="avatar">
          <div class="avatar-image" style="background-image:url(https://cdn-demo.rocket.chat/avatar/steve.pallen?_dc=0);"></div>
        </div>
      </button>
      <button type="button" class="user user-card-message color-primary-font-color" data-username="${msg.nickname}" tabindex="1">${msg.nickname}</button>
      <span class="info border-component-color color-info-font-color">
        <span class="time" title="February 10, 2017 9:49 AM">9:49 AM</span>
        <div class="message-cog-container ">
          <i class="icon-cog message-cog" aria-label="Actions"></i>
        </div>
      </span>
      <div class="body color-primary-font-color " dir="auto">
        ${msg.message}
      </div>
      <ul class="actionLinks hidden">
      </ul>
      <ul class="reactions hidden">
        <li class="add-reaction"><span class="icon-people-plus"></span></li>
      </ul>
    </li>`
  $('.messages-box .wrapper > ul').append(entry)
  let myPanel = $('.messages-box .wrapper')
  myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());
}
function add_short_message(msg) {
  let entry =
    `<li id="${msg.id}" class="message background-transparent-dark-hover sequential own" data-username="${msg.nickname}" data-date="February 10, 2017" data-timestamp="1486738189297">


        <button class="thumb user-card-message" data-username="${msg.nickname}" tabindex="1">
          <div class="avatar">
            <div class="avatar-image" style="background-image:url(https://cdn-demo.rocket.chat/avatar/smpallen99?_dc=0);"></div>
          </div></button>



      <button type="button" class="user user-card-message color-primary-font-color" data-username="smpallen99" tabindex="1">smpallen99</button>

    <span class="info border-component-color color-info-font-color">


    <span class="time" title="February 10, 2017 9:49 AM">9:49 AM</span>


      <div class="message-cog-container ">
        <i class="icon-cog message-cog" aria-label="Actions"></i>
      </div>
    </span>
    <div class="body color-primary-font-color " dir="auto">
      and more


    </div>
    <ul class="actionLinks hidden">

    </ul>
    <ul class="reactions hidden">

      <li class="add-reaction">
        <span class="icon-people-plus"></span>
      </li>
    </ul>
  </li>`
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
