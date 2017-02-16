import UnreadManager from "./unread_manager"
import * as utils from "./utils"

class Messages {

  static new_message(msg) {
    let html = msg.html
    $('.messages-box .wrapper > ul').append(html)

    this.scroll_bottom()


    if (ucxchat.client_id == msg.client_id) {
      console.log('adding own to', msg.id, $('#' + msg.id))
      $('#' + msg.id).addClass("own")
    }

    unread.new_message(msg.id)
  }
  static scroll_bottom() {
    let mypanel = $('.messages-box .wrapper')
    myPanel.scrollTop(myPanel[0].scrollHeight - myPanel.height());
  }

  static send_message(msg) {
    let user = window.ucxchat.user_id
    let ucxchat = window.ucxchat

    if (!utils.empty_string(msg)) {
      roomchan.push("message", {message: msg, user_id: user, room: ucxchat.room, nickname: ucxchat.nickname,
        client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})

      unread.remove_unread()
    }

    $('.message-form-text').val('')
  }
}
export default Messages;
