import Messages from "./messages"
import * as socket from './socket'
import * as cc from "./chat_channel"

const debug = false;

class RoomManager {
  constructor() {
    this.account_menu = false

    $('aside.side-nav > span.arrow').on('click', function() {
      if ($(this).hasClass('top')) {
        $(this).removeClass('top').addClass('bottom')
        RoomManager.hide_account_box_menu()
      } else {
        $(this).addClass('top').removeClass('bottom')
        RoomManager.show_account_box_menu()
      }
    })
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
    $('.room-title').html(ucxchat.display_name)
    $('.link-room-' + ucxchat.room).addClass("active")
    Messages.scroll_bottom()
    roomchan.leave()
    socket.restart_socket()
  }
  static toggle_favorite() {
    if (debug) { console.log('toggle_favorite') }
    // roomchan.push("room:favorite", {client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
    cc.put("/room/favorite")
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
  }
  static add_private(elem) {
    let nickname = elem.parent().attr('data-username')
    if (debug) { console.log('pvt-msg button clicked...', nickname) }
    // roomchan.push("room:add-direct", {nickname: nickname, client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
    cc.put("direct/" + nickname)
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
        // flex_bar.close_flex_tab()
        if ($('section.flex-tab').parent().hasClass('opened')) {
          $('section.flex-tab').html('').parent().removeClass('opened')
        }
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
  static show_account_box_menu() {
    console.log('show_account_box_menu')
    $('.account-box').addClass('active')
    $('.account-box nav.options').removeClass('animated-hidden')
  }
  static hide_account_box_menu() {
    console.log('hide_account_box_menu')
    $('.account-box').removeClass('active')
    $('.account-box nav.options').addClass('animated-hidden')
  }
}

export default RoomManager;
