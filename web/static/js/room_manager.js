import Messages from "./messages"
import * as socket from './socket'
import * as cc from "./chat_channel"
import sweetAlert from "./sweetalert.min"
import toastr from 'toastr'

const debug = false;

class RoomManager {
  constructor() {
    this.register_events()
  }

  static render_room(resp) {
    if (debug) { console.log('render_room', resp) }
    $('.room-link').removeClass("active")
    if (debug) { console.log('room:render', resp) }
    $('.messages-box').html(resp.box_html)
    $('.messages-container .fixed-title h2').html(resp.header_html)
    ucxchat.channel_id = resp.channel_id
    ucxchat.room = resp.room_title
    ucxchat.display_name = resp.display_name
    ucxchat.room_route = resp.room_route
    $('.room-title').html(ucxchat.display_name)
    $('.link-room-' + ucxchat.room).addClass("active")
    Messages.scroll_bottom()
    roomchan.leave()
    socket.restart_socket()
  }
  static toggle_favorite() {
    if (debug) { console.log('toggle_favorite') }
    // roomchan.push("room:favorite", {user_id: ucxchat.user_id, channel_id: ucxchat.channel_id})
    cc.put("/room/favorite")
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
  }
  static add_private(elem) {
    let username = elem.parent().attr('data-username')
    if (debug) { console.log('pvt-msg button clicked...', username) }
    // roomchan.push("room:add-direct", {username: username, user_id: ucxchat.user_id, channel_id: ucxchat.channel_id})
    cc.put("direct/" + username)
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
        ucxchat.channel_id = resp.channel_id
        ucxchat.room = resp.room
        ucxchat.display_name = resp.display_name
        ucxchat.room_route = resp.room_route
        // flex_bar.close_flex_tab()
        if ($('section.flex-tab').parent().hasClass('opened')) {
          $('section.flex-tab').html('').parent().removeClass('opened')
        }
        roomchan.leave()
        socket.restart_socket()
    })
  }
  static update(msg) {
    let fname = msg.field_name
    if ( fname == "topic"  || fname == "title") {
      $('.room-' + fname).html(msg.value)
    } else if (fname == "name") {
      $('.room-title').html(msg.value)
    }

    $('.current-setting[data-edit="' + msg.field_name + '"]').html(msg.value)
    console.warn('RoomManager.update', msg)
  }

  register_events() {
    $('body').on('click', 'a.open-room', function(e) {
      e.preventDefault();
      if (debug) { console.log('clicked a.open-room', e, $(this), $(this).attr('data-room')) }
      // roomchan.push("room:open", {user_id: ucxchat.user_id, display_name: $(this).attr('data-name'), room: $(this).attr('data-room'), old_room: ucxchat.room})
      //   .receive("ok", resp => { RoomManager.render_room(resp) })

      cc.get("/room/" + $(this).attr('data-room'), {display_name: $(this).attr('data-name'), room: ucxchat.room})
        .receive("ok", resp => {
          console.log('open room response', resp)
          if (resp.redirect) {
            window.location = resp.redirect
          } else {
            RoomManager.render_room(resp)
          }
        })
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
    $('body').on('click', 'button.set-owner', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    $('body').on('click', 'button.unset-owner', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    $('body').on('click', 'button.set-moderator', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-moderator/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    $('body').on('click', 'button.unset-moderator', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-moderator/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    $('body').on('click', 'button.unmute-user', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unmute-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    $('body').on('click', 'button.mute-user', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: "Are you sure?",
        text: "The user wont be able to type in " + ucxchat.room,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes, mute user!",
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/mute-user/" + username)
          .receive("ok", resp => {
            swal({
                title: 'Muted',
                text: "The user has been muted in " + ucxchat.room,
                type: 'success',
                timer: 2000,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
    })
    $('body').on('click', 'button.remove-user', function(e) {
      let username = $(this).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: "Are you sure?",
        text: "The user will be removed from " + ucxchat.room,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: "Yes, remove user!",
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/remove-user/" + username)
          .receive("ok", resp => {
            swal({
                title: 'Removed',
                text: "The user has been removed from " + ucxchat.room,
                type: 'success',
                timer: 2000,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
    })
  }
}

export default RoomManager;
