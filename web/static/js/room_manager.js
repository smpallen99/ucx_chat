import Messages from "./messages"
import * as socket from './socket'

class RoomManager {

  static render_room(resp) {
    console.log('render_room', resp)
    $('.room-link').removeClass("active")
    console.log('room:render', resp)
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
    console.log('toggle_favorite')
    roomchan.push("room:favorite", {client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
      })
  }
  static add_private(elem) {
    let nickname = elem.parent().attr('data-username')
    console.log('pvt-msg button clicked...', nickname)
    roomchan.push("room:add-direct", {nickname: nickname, client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      .receive("ok", resp => {
        $('.messages-container .fixed-title h2').html(resp.messages_html)
        $('aside .rooms-list').html(resp.side_nav_html)
        // flex_bar.close_flex_tab()
        if ($('section.flex-tab').parent().hasClass('opened')) {
          $('section.flex-tab').html('').parent().removeClass('opened')
        }
    })
  }

}

export default RoomManager;
