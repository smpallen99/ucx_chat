import Messages from "./messages"
import * as socket from './socket'
import * as cc from "./chat_channel"
import * as utils from './utils'
import sweetAlert from "./sweetalert.min"
import toastr from 'toastr'

const debug = true;
const animation = `<div class="loading-animation"><div class="bounce1"></div><div class="bounce2"></div><div class="bounce3"></div></div>`

class RoomManager {
  constructor() {
    // $('body').off('click', '.mention-link[data-channel]')
    this.register_events()
  }

  render_room(resp) {
    if (debug) { console.log('render_room', resp) }
    $('.room-link').removeClass("active")
    // $('.messages-box').html(resp.box_html)
    // $('.messages-container .fixed-title h2').html(resp.header_html)
    $('.main-content').html(resp.html)
    ucxchat.channel_id = resp.channel_id
    ucxchat.room = resp.room_title
    ucxchat.display_name = resp.display_name
    ucxchat.room_route = resp.room_route
    if (resp.side_nav_html) {
      $('aside .rooms-list').html(resp.side_nav_html)
    }
    $('.room-title').html(ucxchat.display_name)
    $('.link-room-' + ucxchat.room).addClass("active")
    utils.scroll_bottom()
    roomchan.leave()
    socket.restart_socket()
  }
  toggle_favorite() {
    if (debug) { console.log('toggle_favorite') }
    // roomchan.push("room:favorite", {user_id: ucxchat.user_id, channel_id: ucxchat.channel_id})
    cc.put("/room/favorite")
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
  }
  add_private(elem) {
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
  update(msg) {
    console.log('update...', msg)
    let fname = msg.field_name
    if ( fname == "topic"  || fname == "title") {
      $('.room-' + fname).html(msg.value)
    } else if (fname == "name") {
      $('.room-title').html(msg.value)
      ucxchat.room = msg.value
      ucxchat.display_name = msg.value
      utils.replace_history()
    }

    $('.current-setting[data-edit="' + msg.field_name + '"]').html(msg.value)
    console.warn('RoomManager.update', msg)
  }
  room_mention(resp) {
    let parent = `a.open-room[data-name="${resp.room}"]`
    let elem = $(parent + ' span.unread')
    console.log('room_manager', resp, elem)
    if (elem.length == []) {
      $(parent).prepend(`<span class="unread">${resp.unread}</span>`)
    } else {
      elem.text(resp.unread)
    }
  }

  register_events() {
    $('body').on('click', 'a.open-room', e => {
      e.preventDefault();
      if (debug) { console.log('clicked a.open-room', e, $(e.currentTarget), $(e.currentTarget).attr('data-room')) }
      utils.page_loading()
      $('.main-content').html(utils.loading_animation())
      this.open_room($(e.currentTarget).attr('data-room'), $(e.currentTarget).attr('data-name'))
    })
    .on('click', 'a.toggle-favorite', e => {
      if (debug) { console.log('click a.toggle-favorite') }
      e.preventDefault();
      this.toggle_favorite()
    })
    .on('click', '.button.pvt-msg', e => {
      if (debug) { console.log('click .button.pvt-msg') }
      e.preventDefault();
      this.add_private(e.currentTarget)
    })
    .on('click', 'button.set-owner', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unset-owner', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-owner/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.set-moderator', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/set-moderator/" + username)
        .receive("ok", resp => {
          if (resp.redirect) {
            window.location = resp.redirect
          }
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unset-moderator', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unset-moderator/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unmute-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unmute-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.unblock-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/unblock-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.block-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      cc.put("/room/block-user/" + username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'button.mute-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.the_user_wont_able_type + ' ' + ucxchat.room,
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_mute_user,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/mute-user/" + username)
          .receive("ok", resp => {
            swal({
                title: gettext.muted,
                text: gettext.the_user_wont_able_type + ' ' + ucxchat.room,
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
    .on('click', 'button.remove-user', e => {
      let username = $(e.currentTarget).parent().attr('data-username')
      e.preventDefault()
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.the_user_will_be_removed_from + ' ' + ucxchat.room,
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
                title: gettext.removed,
                text: gettext.the_user_was_remove_from + ' ' + ucxchat.room,
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
    .on('click', 'button.join', e => {
      cc.put("/room/join/" + ucxchat.username)
        .receive("ok", resp => {
        })
        .receive("error", resp => {
          toastr.error(resp.error)
        })
    })
    .on('click', 'a.open-room i.hide-room', e => {
      e.preventDefault()
      let room = $(e.currentTarget).closest('.open-room').data('room')
      // console.log('cliecked open-room', room)
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.are_you_sure_you_want_to_hide_the_room + ' "' + room + '"?',
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_hide_it,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/hide/" + room)
          .receive("ok", resp => {
            if (resp.redirect) {
              window.location = resp.redirect
            }
            // swal({
            //     timer: 1,
            //     showConfirmButton: false,
            // })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
      return false
    })
    .on('click', 'a.open-room i.leave-room', e => {
      e.preventDefault()
      let room = $(e.currentTarget).closest('.open-room').data('room')
      console.log('cliecked leave-room', room)
      sweetAlert({
        title: gettext.are_you_sure,
        text: gettext.are_you_sure_leave_the_room + ' "' + room + '"?',
        type: "warning",
        showCancelButton: true,
        confirmButtonColor: "#DD6B55",
        confirmButtonText: gettext.yes_leave_it,
        closeOnConfirm: false
      },
      function(){
        cc.put("/room/leave/" + room)
          .receive("ok", resp => {
            swal({
                title: gettext.left_the_room,
                text: gettext.you_have_left_the_room + " " + ucxchat.room,
                type: 'success',
                timer: 500,
                showConfirmButton: false,
            })
          })
          .receive("error", resp => {
            toastr.error(resp.error)
          })
      });
      return false
    })
    .on('click', '.mention-link[data-channel]', (e) => {
      e.preventDefault()
      let target = $(e.currentTarget)
      let room = target.data('channel')
      console.log('clicked channel link', room)
      this.open_room(room, room)
      return false
    })
    // .on('scroll', '.messages-box .wrapper', _.throttle(() => {
    $('.messages-box .wrapper').on('scroll', _.throttle((e) => {
      if (utils.is_scroll_bottom()) {
        console.log('scroller scrolling at bottom' )
      } else {
        console.log('scroller keep scrolling ' )
      }
    }, 150))

    $(window).on('focus', () => {
      this.clear_unread()
      console.log('room_manager focus')
    })

  }


  clear_unread() {
    setTimeout(function() {
      let parent = `a.open-room[data-name="${ucxchat.room}"]`
      $(parent + ' span.unread').remove()
    }, 1000)
  }

  open_room(room, display_name, callback) {
    cc.get("/room/" + room, {display_name: display_name, room: ucxchat.room})
      .receive("ok", resp => {
        console.log('open room response', resp)
        if (resp.redirect) {
          window.location = resp.redirect
        } else {
          this.render_room(resp)
        }
        if (callback) { callback() }
        utils.remove_page_loading()
      })
  }
}

export default RoomManager;
