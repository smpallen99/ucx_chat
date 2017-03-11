import UnreadManager from "./unread_manager"
import * as cc from "./chat_channel"
import hljs from "highlight.js"
import * as utils from "./utils"
import * as main from "./main"

const debug = false;

class Messages {

  static new_message(msg) {
    let html = msg.html
    $('.messages-box .wrapper > ul').append(html)

    this.scroll_bottom()
    $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
      hljs.highlightBlock(block)
    })

    if (ucxchat.user_id == msg.user_id) {
      if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
      $('#' + msg.id).addClass("own")
      main.run()
    }

    unread.new_message(msg.id)
  }
  static update_message(msg) {
    $('#' + msg.id).replaceWith(msg.html)
      .find('pre').each(function(i, block) {
        hljs.highlightBlock(block)
      })

    if (ucxchat.user_id == msg.user_id) {
      // if (debug) { console.log('adding own to', msg.id, $('#' + msg.id)) }
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
    if (msg.update) {
      cc.put("/messages/" + msg.update, {message: msg.value, user_id: user})
        .receive("ok", resp => {
          $('.message-form-text').removeClass('editing')
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            Messages.scroll_bottom()
          }
        })

    } else if (msg.startsWith('/')) {
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
      // roomchan.push("message", {message: msg, user_id: user, room: ucxchat.room, username: ucxchat.username,
      //   user_id: ucxchat.user_id, channel_id: ucxchat.channel_id})
      // cc.push("message", {message: msg, user_id: user})
      cc.post("/messages", {message: msg, user_id: user})
        .receive("ok", resp => {
          if (resp.html) {
            $('.messages-box .wrapper > ul').append(resp.html)
            $('.messages-box').children('.wrapper').children('ul').children(':last-child').find('pre').each(function(i, block) {
              hljs.highlightBlock(block)
            })
            Messages.scroll_bottom()
          }
        })

      unread.remove_unread()
    }

    $('.message-form-text').val('')
  }
}
export default Messages;
