import UnreadManager from "./unread_manager"
import * as cc from "./chat_channel"
import * as utils from "./utils"

const debug = false;

class Messages {

  static new_message(msg) {
    let html = msg.html
    $('.messages-box .wrapper > ul').append(html)

    this.scroll_bottom()


    if (ucxchat.client_id == msg.client_id) {
      if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
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
    if (msg.startsWith('/')) {
      let match = msg.match(/^\/([^\s]+)(.*)/)
      let route = "/slashcommand/" + match[1]
      cc.put(route, {args: match[2].trim()})
        .receive("ok", resp => {
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            Messages.scroll_bottom()
          }
        })

      unread.remove_unread()

    } else if (!utils.empty_string(msg)) {
      // roomchan.push("message", {message: msg, user_id: user, room: ucxchat.room, nickname: ucxchat.nickname,
      //   client_id: ucxchat.client_id, channel_id: ucxchat.channel_id})
      cc.push("message", {message: msg, user_id: user})
        .receive("ok", resp => {
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            Messages.scroll_bottom()
          }
        })

      unread.remove_unread()
    }

    $('.message-form-text').val('')
  }
}
export default Messages;
